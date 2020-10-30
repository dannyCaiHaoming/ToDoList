//
//  CG绘制.swift
//  绘制
//
//  Created by 蔡浩铭 on 2020/10/28.
//

import Foundation
import UIKit

class CGView: UIView,Input {
    
    var bezierPath =  UIBezierPath()
    var points: [CGPoint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(){
        self.backgroundColor = UIColor.green
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
//        updateShapreLayer()
        self.setNeedsDisplay()
    }
    
    
    override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        
        ctx?.addPath(self.bezierPath.cgPath)
        
        ctx?.setLineWidth(10.0)
        
        ctx?.setStrokeColor(UIColor.purple.cgColor)
        
        ctx?.setFillColor(UIColor.clear.cgColor)
        
        ctx?.strokePath()
        

        
        
        
        
    }
    
}
