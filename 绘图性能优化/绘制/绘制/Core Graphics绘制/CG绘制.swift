//
//  CG绘制.swift
//  绘制
//
//  Created by 蔡浩铭 on 2020/10/28.
//

import Foundation
import UIKit

/*
 为啥选用UIView，而不用CALayer，为啥选用CoreGraphics。
 1.因为使用UIView能直接有事件响应，能获取到每个下笔点
 2.CoreGraphics能直接提供绘制的入口和比较成熟的绘制API，例如能使用UIBezierth绘制圆滑曲线，和简单修改颜色。
 
 
 同样绘制同样可以使用CAShapeLayer，只不过这个功能还需要擦除，所以就没太深入研究CAShapeLayer怎么实现擦除。
 */

class CGView: UIView,Input {
    
    var bezierPath =  UIBezierPath()
    var points: [CGPoint] = []
    
    var result: UIImage? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(){
        self.backgroundColor = UIColor.clear
    }
    
    func touchBegan(_ point: CGPoint) {
        points.removeAll()
        points.append(point)
        updatePath(state: .start)
    }
    
    func touchMove(_ point: CGPoint) {
        points.append(point)
        updatePath(state: .change)
    }
    
    func touchEnd(_ point: CGPoint) {
        points.append(point)
        updatePath(state: .end)
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
        case .end:
            getResult()
            return
        default:
            break
        }
//        updateShapreLayer()
        self.setNeedsDisplay()
    }
    
    func getResult() {
        
        UIGraphicsBeginImageContext(self.bounds.size)
        
        if let ctx = UIGraphicsGetCurrentContext() {
            self.layer.draw(in: ctx)
            let result =  UIGraphicsGetImageFromCurrentImageContext()
            self.result = result
            UIGraphicsEndImageContext()
        }
    
    }
    
    override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        
        result?.draw(at: .zero)
        
        ctx?.addPath(self.bezierPath.cgPath)
        
        ctx?.setLineWidth(10.0)
        
        if switchValue {
            ctx?.setStrokeColor(UIColor.clear.cgColor)
            ctx?.setBlendMode(.clear)
            
        }else {
            ctx?.setStrokeColor(UIColor.purple.cgColor)
        }
        
        
        ctx?.setFillColor(UIColor.clear.cgColor)
        
        ctx?.strokePath()
        
        
    }
    
}
