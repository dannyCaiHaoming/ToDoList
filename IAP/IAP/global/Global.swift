//
//  Global.swift
//  IAP
//
//  Created by 蔡浩铭 on 2020/10/16.
//

import Foundation

func CHLog<T>(_ message:T, file:String = #file, function:String = #function,
           line:Int = #line) {
    #if DEBUG
        //获取文件名
        let fileName = (file as NSString).lastPathComponent
        //打印日志内容
        print("\(fileName):\(line) \(function) | \(message)")
    #endif
}
