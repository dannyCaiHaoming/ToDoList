//
//  UIView+Ext.swift
//  绘制
//
//  Created by 蔡浩铭 on 2020/10/28.
//

import Foundation
import UIKit

extension UIView {
    func addSubviews(_ views: UIView...){
        views.forEach { (view) in
            self.addSubview(view)
        }
    }
    
    func addSubviews(_ views: [UIView]) {
        views.forEach { (view) in
            self.addSubview(view)
        }
    }
}
