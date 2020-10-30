//
//  CA绘制.swift
//  绘制
//
//  Created by 蔡浩铭 on 2020/10/28.
//

import Foundation
import UIKit

enum PathState {
    case start
    case change
    case end
}

class CAView: UIView,Input {
    
    var bezierPath =  UIBezierPath()
    
    var shapeLayer = CAShapeLayer()
    
    var points: [CGPoint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(){
        shapeLayer.backgroundColor = UIColor.yellow.cgColor
        shapeLayer.frame = self.bounds
        self.layer.addSublayer(shapeLayer)
        
    }
    
    func touchBegan(_ point: CGPoint) {
        points.removeAll()
        points.append(point)
        updatePath(state: .start)
    }
    
    func touchMove(_ point: CGPoint) {
        points.append(point)
        updatePath()
    }
    
    func touchEnd(_ point: CGPoint) {
        points.append(point)
        updatePath()
    }
    
    func updatePath(state: PathState = .change) {
        guard points.count > 0 else {
            return
        }
        switch state {
        case .start:
            bezierPath = UIBezierPath()
            if let point = points.first {
                bezierPath.move(to: point)
            }
        case .change:
            if let point = points.last {
                bezierPath.addLine(to: point)
            }
        default:
            break
        }
        updateShapreLayer()
    }
    
    func updateShapreLayer(){
        
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.lineCap = .square//.round
        shapeLayer.lineWidth = 10
    }
    
    
}
