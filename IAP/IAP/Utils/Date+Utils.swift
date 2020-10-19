//
//  Date+Utils.swift
//  IAP
//
//  Created by 蔡浩铭 on 2020/10/19.
//

import Foundation

extension Date {
    
    static func UTCDateFromETCString(_ etcString: String) -> Date? {
        let index = etcString.index(etcString.startIndex, offsetBy: etcString.count - 8)
        let time = etcString.prefix(upTo: index)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.date(from: String(time))
    }
     
}
