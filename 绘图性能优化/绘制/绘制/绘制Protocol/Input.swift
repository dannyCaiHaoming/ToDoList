//
//  Input.swift
//  绘制
//
//  Created by 蔡浩铭 on 2020/10/28.
//

import Foundation
import UIKit

protocol Input {
    var points: [CGPoint] {get set}
    func touchBegan(_ point: CGPoint)
    func touchMove(_ point: CGPoint)
    func touchEnd(_ point: CGPoint)
    
    func forward()
    func backward()
}


extension Input {
    func forward() {}
    func backward() {}
}
