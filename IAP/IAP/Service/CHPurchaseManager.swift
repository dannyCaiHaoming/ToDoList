//
//  PurchaseManager.swift
//  SuperWallpaper
//
//  Created by 蔡浩铭 on 2020/10/13.
//  Copyright © 2020 com.hundreds.SuperWallpaper. All rights reserved.
//

import Foundation
import StoreKit

/*
 需要展示默认价格，需要请求刷新价格，
 没有区分用户，如果要区分用户怎么办？  就以需要区分用户设计，当不区分用户的时候，
 现在商品数量少，因为是订阅商品，如果是可消耗商品，如果数量多的时候，就要考虑队列对receipt进行出列校验
 这个队列驱动的方式也可设计：(a)初始化这个内购服务的时候 (b)新建一个内购服务的时候 (c)网络切换的时候 (d)前后台切换的时候
 
 本地模型<->productId<->获取最新product<->最新product入列
 根据状态结束回调，获取沙盒中的receipt收据去跟IAP校验
 收据可能存在丢失，网络问题，用户购买完就卸载了，总之就是没收到IAP服务器发回来的收据receipt
 A:如果获取到receipt，万事大吉，直接存储起来，然后立刻发出去IAP服务器校验
 B:如果没有找到那就惨了，需要发起receiptRefresh的请求，等receipt回来再重复A操作
 C:提供restore方式，让用户直接走恢复购买
 提供校验失败重复校验机制，以及下次启动继续校验
 如果仅适用SKPurchaseQueueObserver提供的观察者方法，只有会在程序重启的时候回重新发起一次校验，这样明显是不够的，可以增加几个时机，就是上面队列驱动的设计。（订单校验要做去重复设计）
 
 疑问：
 purchased的订单，但是没有校验完成，PurchaseQueue里面应该还会有这个记录，所以这个东西restore的时候会怎么样？
 restore之后，回把之前finish的订单全部找回来了，然后感觉需要把这些新生成的交易(跟之前purchased的时候应该不一样的)，全部finish了，然后在restore结束后，去找本地的
 收据去验单，看看能不能重新获取有效能使用的订单
 
 
 内购管理类设计成单例，用于全局唯一控制商品数据没有问题，但是delegate,block只能设置单一接受者
 
 */

let receiptPassword = "213989a3415c4283a217f33b08485354"

let receiptURL = Bundle.main.appStoreReceiptURL

enum PurchaseError: Error {
    case unknown
    case invalidData
    case notFoundReceipt
    case verifyReceiptError
    case needAppstoreVerify
}


enum PurchaseProductRefreshPurpose{
    case onlyRefresh
    case refreshAndPurchse
}

typealias PurchaseProductUpdatedCompletion = ([PurchaseModel])->()

class CHPurchaseManager: NSObject {
    
    static let share = CHPurchaseManager()
    
    var refreshPurpose: PurchaseProductRefreshPurpose = .onlyRefresh
    
    var products:[SKProduct] = []
    
    let purchaseDataManager = PurchaseDataManager.share
    
    let verifyManager:ReceiptVerifyManager = ReceiptVerifyManager.share
    
    var productUpdatedCompletion: PurchaseProductUpdatedCompletion?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        addNotification()
    }
    
    /// 刷新商品价格
    /// - Parameters:
    ///   - productIds: 商品id 可从运营获取，Itune Store
    ///   - purpose: 刷新价格目的，只刷新或者刷新且购买
    func refreshProduct(productIds: Set<String>,
                        purpose: PurchaseProductRefreshPurpose = .onlyRefresh){
        self.refreshPurpose = purpose
        let request = SKProductsRequest(productIdentifiers: productIds)
        request.delegate = self
        request.start()
    }
    
    func resore(){
        /*
         注释里面是调用了 finishTransaction(_:)的交易才有用。
         
         */
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func verifyReceipt(){
        guard Bundle.main.appStoreReceiptURL != nil else {
            // 可手动调用刷新receipt，如果当做异常
            // 只能等待用户再次重复点击购买，重新使用上次没有完成的交易继续
            // 或者等待用户走恢复购买流程
//            startRefreshReceipt()
            return
        }
//        verifyManager
    }
    
    func startRefreshReceipt(){
        // 需要添加去重
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
    }
    
    
    func addNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(onDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func onDidBecomeActiveNotification(){
//        self.verifyManager.
    }
    

}

//MARK: - SKPaymentTransactionObserver
extension CHPurchaseManager: SKPaymentTransactionObserver {
    
    //MARK: - Purchase Observer
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]){
        CHLog("transactions count = \(transactions.count)")
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionPurchasing()
            case .purchased:
                transactionPurchased(transaction: transaction)
            case .deferred:
                transactionDeferred()
            case .restored:
                transactionRestored(transaction: transaction)
            case .failed:
                transactionFailed()
            @unknown default:
                fatalError()
            }
        }
        CHLog("\(SKPaymentQueue.default().transactions)")
        
    }
    
    private func transactionPurchasing(){
        CHLog("")
    }
    
    private func transactionPurchased(transaction: SKPaymentTransaction){
        CHLog("")
        try? self.purchaseDataManager.saveReceiptToSandbox(transaction: transaction)
        self.verifyManager.iapVerify { [weak self] (error, data) in
            guard let self = self,
                  error == nil,
                  let data_ = data else {
                return
            }
            self.purchaseDataManager.cleanReceipt(transaction: transaction)
            // 解析返回的校验收据结果（提取最新一单），保存到sandbox，
            if let model = self.purchaseDataManager.parseVerifyResponseToLatestTransaction(data: data_) {
                try? self.purchaseDataManager.saveLatestTransactionToSandbox(transaction: model)
            }
            if transaction.transactionState != .purchasing {
                CHLog("\(String(describing: transaction.transactionIdentifier)) finishTransaction")
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    private func transactionDeferred(){
        CHLog("")
    }
    
    private func transactionRestored(transaction: SKPaymentTransaction){
        CHLog("")
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func transactionFailed(){
        CHLog("")
    }
    
    //MARK: Restore Observer
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        CHLog("")
    }
    
    private func restoreFinished(){
        CHLog("")
    }
    
}


extension CHPurchaseManager: SKProductsRequestDelegate,SKRequestDelegate {
    
    //MARK: - SKRequestDelegate
    func requestDidFinish(_ request: SKRequest) {
        
    }
    
    //MARK: -  SKProductsRequestDelegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        let products = response.products
        switch self.refreshPurpose {
        case .onlyRefresh:
            self.products = products
        case .refreshAndPurchse:
            guard let purchaseProduct = products.first else {
                // 目前只考虑单一商品购买，应该没有多组商品同时购买吧?
                // 可能商品id变更
                // 可能网络原因导致商品没找到?
                return
            }
            if products.contains(where: { (product) -> Bool in
                return product.productIdentifier == purchaseProduct.productIdentifier
            }) {
                self.products = self.products.map { (product) -> SKProduct in
                    if product.productIdentifier == purchaseProduct.productIdentifier {
                        return purchaseProduct
                    }
                    return product
                }
                if SKPaymentQueue.canMakePayments() {
                    let payment = SKPayment(product: purchaseProduct)
                    SKPaymentQueue.default().add(payment)
                }
            }else {
                self.products.append(purchaseProduct)
            }
        }
        let models = self.products.compactMap({ parseProductToPurchaseModel($0) })
        DispatchQueue.main.async {
            self.productUpdatedCompletion?(models)
        }
    }
    
    private func parseProductToPurchaseModel(_ product:SKProduct) -> PurchaseModel? {
        var model = PurchaseModel()
        model.price = Float(truncating: product.price)
        let local = product.priceLocale
        model.currencyCode = local.currencyCode
        model.currencySymbol = local.currencySymbol
        model.productId = product.productIdentifier
        return model
    }
    
}

let receiptInfoKey = "latest_receipt_info"
let expiresDateKey = "expires_date"

class PurchaseDataManager: NSObject {
    
    static let share = PurchaseDataManager()
    
    //MARK: Save
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    lazy var receiptDataPath: String = {
        return (documentDirectory as NSString).appendingPathComponent("ReceiptData")
    }()
    
    lazy var latestTranscationPath: String = {
        return (documentDirectory as NSString).appendingPathComponent("LatestTransaction")
    }()
    
    func receiptDataPathFiles() {
        let enumerator = FileManager.default.enumerator(atPath: documentDirectory)
        while let next = enumerator?.nextObject() as? String,
              next.contains("ReceiptData"){
            CHLog("next = \(next)")
        }
    }
    
    func latestTranscationPathFiles() {
        let enumerator = FileManager.default.enumerator(atPath: documentDirectory)
        while let next = enumerator?.nextObject() as? String,
              next.contains("LatestTransaction"){
            CHLog("next = \(next)")
        }
    }
    
    //MARK: - Save ReceiptData to Sandbox
    
    /// 保存收据到沙盒
    /// - Throws: 异常
    func saveReceiptToSandbox(transaction: SKPaymentTransaction) throws {
        CHLog("saveReceiptToSandbox \(String(describing: transaction.transactionIdentifier))")
        guard let url = receiptURL ,
              FileManager.default.fileExists(atPath: url.path),
              let receiptData = try? Data(contentsOf: url,options: .alwaysMapped) else {
            return
        }
        do {
            var path = receiptDataPath
            if let id = transaction.transactionIdentifier {
                path += "\(id)"
            }
            try receiptData.write(to: URL(fileURLWithPath: path))
        } catch {
            CHLog(error.localizedDescription)
            throw error
        }
    }
    
    
    /// 获取沙盒中收据数据
    /// - Throws: 异常
    /// - Returns: 收据数据
    func fetchReceipt() throws -> Data? {
        try Data(contentsOf: URL(fileURLWithPath: receiptDataPath))
    }
    
    
    /// 清除沙盒收据数据
    func cleanReceipt(transaction: SKPaymentTransaction) {
        CHLog("cleanReceipt \(String(describing: transaction.transactionIdentifier))")
        var path = receiptDataPath
        if let id = transaction.transactionIdentifier {
            path += "\(id)"
        }
        if FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
    }
    
    //MARK: - Save latestTransaction to Sandbox
    
    
    /// 保存最新交易数据到沙盒
    /// - Parameter transaction: 最新的交易数据
    /// - Throws: 异常
    func saveLatestTransactionToSandbox(transaction: TransactionModel) throws {
        CHLog("saveLatestTransactionToSandbox \(String(describing: transaction.transactionId))")
        _ = try NSKeyedArchiver.archiveRootObject(transaction, toFile: latestTranscationPath)
    }
    
    func parseVerifyResponseToLatestTransaction(data: Data) -> TransactionModel? {
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject] else {
            return nil
        }
        if let receiptInfos = dict[receiptInfoKey] as? [[String:AnyObject]]{
            var latestReceipt:[String:AnyObject]? = nil
            for info in receiptInfos {
                guard let expires_date_str = info[expiresDateKey] as? String,
                      let expires_date = Date.UTCDateFromETCString(expires_date_str) else {
                    continue
                }
                if let latest = latestReceipt,
                   let latestDate_str = latest[expiresDateKey] as? String,
                   let latestDate = Date.UTCDateFromETCString(latestDate_str),
                   expires_date.compare(latestDate) == .orderedDescending
                   {
                    latestReceipt = info
                }else {
                    latestReceipt = info
                }
            }
            if let latestReceipt_ = latestReceipt {
                do {
                    let data = try JSONSerialization.data(withJSONObject: latestReceipt_, options: [.fragmentsAllowed])
                    let model = try JSONDecoder().decode(TransactionModel.self, from: data)
                    return model
                } catch let error {
                    CHLog(error)
                    return nil
                }
            }
        }
        return nil
    }
    
    
    /// 获取沙盒
    /// - Throws: 获取沙盒中最新交易单
    /// - Returns: 最新交易数据
    func fetchLatestTransaction() throws -> TransactionModel? {
        let data = try Data(contentsOf: URL(fileURLWithPath: latestTranscationPath))
        return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? TransactionModel
    }
}

typealias IAPVerifyCompletion = (_ error: Error?,_ data:Data?) -> ()

class ReceiptVerifyManager: NSObject {
    
    static let share = ReceiptVerifyManager()
    
    func iapVerify(completion:IAPVerifyCompletion? = nil) {
        CHLog("iapVerify start")
        guard let url = receiptURL ,
              FileManager.default.fileExists(atPath: url.path),
              let receiptData = NSData.init(contentsOf: url) else {
            completion?(PurchaseError.notFoundReceipt,nil)
            return
        }
        //获取bundle中的收据，需要先进行base-64转码
        let receiptString = receiptData.base64EncodedString(options: [.endLineWithLineFeed])//receiptData.base64EncodedData(options: [.endLineWithLineFeed])
        let requestStr = "{\"receipt-data\" : \"\(receiptString)\",\"password\":\"\(receiptPassword)\"}"
        guard let requestData = requestStr.data(using: .utf8) else {
            completion?(PurchaseError.invalidData,nil)
            return
        }
        //由于沙盒账号内购只能在沙盒服务器校验，同时苹果审核时候的TestFlight版本也只是在沙盒环境中购买及验证
        //因此校验这一步需要先请求苹果服务器，然后判断如果是沙盒的收据后，再请求一次沙盒服务器，不然等着悲剧。

        let sandboxUrl = "https://sandbox.itunes.apple.com/verifyReceipt"
        let appstoreUrl = "https://buy.itunes.apple.com/verifyReceipt"
        
        CHLog("iapVerifySendRequest sandbox start")
        self.iapVerifySendRequest(requestUrl: URL(string: sandboxUrl)!, requestData: requestData) { [weak self] (error, data) in
            if let e = error as? PurchaseError,
               e == PurchaseError.needAppstoreVerify {
                CHLog("iapVerifySendRequest appstore start")
                self?.iapVerifySendRequest(requestUrl: URL(string: appstoreUrl)!, requestData: requestData, completion: { (error, data) in
                    if error == nil {
                        completion?(error,data)
                    }
                })
            }else if error == nil {
                completion?(error,data)
            }
        }
        
        
        
    }
    
    private func iapVerifySendRequest(requestUrl:URL,requestData:Data,completion:IAPVerifyCompletion? = nil){
        
        var receiptRequest = URLRequest.init(url: requestUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15)
        receiptRequest.httpBody = requestData
        receiptRequest.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: receiptRequest) { (data, response, error) in
            guard let data_ = data,
                  error == nil,
                  let receiptDic = try? JSONSerialization.jsonObject(with: data_, options: .allowFragments) as? [String:AnyObject] else {
                completion?(PurchaseError.verifyReceiptError,nil)
                return
            }
            
            guard let status = receiptDic["status"] as? Int else {
                completion?(PurchaseError.invalidData,nil)
                return
            }
            
            switch status {
            case 0,21006:
                completion?(nil,data_)
            case 21007:
                completion?(PurchaseError.needAppstoreVerify,nil)
            default:
                break
            }
            completion?(PurchaseError.invalidData,nil)
        }
        
        task.resume()
    }
    

}
