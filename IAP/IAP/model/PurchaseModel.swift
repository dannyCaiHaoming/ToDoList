//
//  PurchaseModel.swift
//  IAP
//
//  Created by 蔡浩铭 on 2020/10/16.
//

import Foundation

struct PurchaseModel:Codable {
    var price:Float?
    var currencySymbol: String?
    var currencyCode: String?
    var productId: String?
    
    func displayPrice() -> String {
        guard let symbol = currencySymbol,
              let price = price else {
            return ""
        }
        return String.init(format: "\(symbol)%.2f", price)
    }
}
