//
//  ViewController.swift
//  IAP
//
//  Created by 蔡浩铭 on 2020/10/16.
//

/*
 1.使用固定单一商品，进行展示，及购买的逻辑
 
 主要是流程是：
 
 展示 购买 验单 关闭订单
 
 处理productid 刷新  及  购买
 
 处理收据数据返回成功或者失败<->收据验证成功或者失败 <-> 沙盒的receiptData验证成功可以移除  <-> 返回的交易id找回本地的交易关闭
 
 
 */

import UIKit

let ProductId = "geniusart_weekly_notrial"

class ViewController: UIViewController {

    @IBOutlet weak var purchaseBtn: UIButton!
    
    var purchaseModel: PurchaseModel = {
        var model = PurchaseModel()
        model.productId = ProductId
        model.currencySymbol = "$"
        model.price = 3.99
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setup()
    }
    
    func setup(){
        setupUI()
        updatePurchase()
    }
    
    func setupUI(){
        refreshBtn()

    }
    
    func refreshBtn(){
        purchaseBtn.setTitle("价格：\(purchaseModel.displayPrice())", for: .normal)
    }
    
    
    func updatePurchase(){
        guard let productId = purchaseModel.productId else {
            return
        }
        CHPurchaseManager.share.productUpdatedCompletion = { [weak self] (purchases) in
            guard let purchase =  purchases.filter({ $0.productId == self?.purchaseModel.productId }).first else {
                return
            }
            self?.purchaseModel = purchase
            self?.refreshBtn()
        }
        CHPurchaseManager.share.refreshProduct(productIds: [productId], purpose: .onlyRefresh)
    }



    @IBAction func purchaseAction(_ sender: Any) {
        guard let productId = purchaseModel.productId else {
            return
        }
        CHPurchaseManager.share.refreshProduct(productIds: [productId], purpose: .refreshAndPurchse)
    }
    @IBAction func restoreAction(_ sender: Any) {
        CHPurchaseManager.share.resore()
        
    }
}

