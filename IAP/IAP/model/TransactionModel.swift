//
//  TransactionModel.swift
//  IAP
//
//  Created by 蔡浩铭 on 2020/10/16.
//

import Foundation

class TransactionModel: NSObject,Codable,NSCoding {
    var productId : String? //商品Id
    var originalTransactionId : String?  //原始订单Id
    var transactionId : String? //订单id
    var originalPurchaseTime : String?   //原始购买时间，单位微妙
    var expiryTime : String?    //过期时间，单位微秒
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(productId, forKey: "productId")
        aCoder.encode(originalTransactionId, forKey: "originalTransactionId")
        aCoder.encode(transactionId, forKey: "transactionId")
        aCoder.encode(originalPurchaseTime, forKey: "originalPurchaseTime")
        aCoder.encode(expiryTime, forKey: "expiryTime")
    }
    
    required init?(coder aDecoder: NSCoder) {
        productId = aDecoder.decodeObject(forKey: "productId") as? String
        originalTransactionId = aDecoder.decodeObject(forKey: "originalTransactionId") as? String
        transactionId = aDecoder.decodeObject(forKey: "transactionId") as? String
        originalPurchaseTime = aDecoder.decodeObject(forKey: "originalPurchaseTime") as? String
        expiryTime = aDecoder.decodeObject(forKey: "expiryTime") as? String
    }
    
    enum CodingKeys: String,CodingKey {
        case expiryTime = "expires_date_ms"
        case productId = "product_id"
        case originalPurchaseTime = "original_purchase_date"
        case originalTransactionId = "original_transaction_id"
        case transactionId = "transaction_id"
        
    }
    
}
