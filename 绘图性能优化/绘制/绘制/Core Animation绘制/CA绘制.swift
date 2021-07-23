//
//  CA绘制.swift
//  绘制
//
//  Created by 蔡浩铭 on 2020/10/28.
//

/*
 CALayer 也可以实现画笔橡皮擦功能
 
 同样的使用UIView的事件响应，获取begin，move，end事件
 
 在begin的时候创建UIBezierPath，且生成开始点moveToPoint
 
 在move和end的时候为UIBezierPath添加点，且配置linecap和linejoin圆滑属性
 
 ///  使用图片作为临时值保存
 在end的时候，将UIBezierPah的cgpath赋值到CAShapeLayer，让CAShaperLayer生成绘制路径
 
 且根据CAShapeLayer生成图片赋值到CAShaperLayer的content属性上，下次可以继续绘制。
 
 当需要擦除的时候，只需要对画笔的stroke颜色，使用图层原本的颜色或者内容作为颜色。
 
 这个方法不需要手动调用setNeedDisplay
    
 ///  使用点作为临时值保存
 每次end的时候，对这次绘制路径生成一个UIBezierPath路径对象，作为临时存储对象。在前进后退的时候，根据
 
 已经保存的UIBezierPath对象，重新一次性添加到一个UIBezierPath上面。就能达到对每次绘制进行保存以及前进后退
 
 */

import Foundation
import UIKit

enum PathState {
    case start
    case change
    case end
}

class CAView: UIView,Input {
    
    var bezierPath =  UIBezierPath()
    
    var showLayer = CAShapeLayer()
    var drawLayer = CAShapeLayer()
    
    var points: [CGPoint] = []
    
    var paths: Stack<UIBezierPath> = Stack.init(list: [])
    var tempPaths: Stack<UIBezierPath> = Stack.init(list: [])
    
    var resultImage: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(){
        showLayer.backgroundColor = UIColor.yellow.cgColor
        showLayer.frame = self.bounds
        self.layer.addSublayer(showLayer)
        
        drawLayer.backgroundColor = UIColor.clear.cgColor
        drawLayer.frame = self.bounds
        self.layer.addSublayer(drawLayer)
        
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
            updateShapreLayer()
            generateResult()
//            shapeLayer.contents = resultImage?.cgImage
            return
        }
        updateShapreLayer()
    }
    
    func updateShapreLayer(){
        
        drawLayer.path = bezierPath.cgPath
        drawLayer.fillColor = UIColor.clear.cgColor
        if switchValue {
            drawLayer.strokeColor = self.drawLayer.backgroundColor
        }else {
            drawLayer.strokeColor = UIColor.blue.cgColor
        }
        drawLayer.lineCap = .round
        drawLayer.lineJoin = .round
        drawLayer.lineWidth = 10
    }
    
    func generateResult() {
        
        paths.push(bezierPath)
        drawLayer.path = nil
        showLayer.path = nil
        let r = UIBezierPath()
        for path in paths.list {
            r.append(path)
        }
        
        showLayer.fillColor = UIColor.clear.cgColor
        if switchValue {
            showLayer.strokeColor = self.showLayer.backgroundColor
        }else {
            showLayer.strokeColor = UIColor.blue.cgColor
        }
        showLayer.lineCap = .round
        showLayer.lineJoin = .round
        showLayer.lineWidth = 10
        showLayer.path = r.cgPath
//        UIGraphicsBeginImageContext(self.shapeLayer.bounds.size)
//        guard let ctx = UIGraphicsGetCurrentContext() else {
//            return
//        }
//        self.shapeLayer.render(in: ctx)
//        self.resultImage = UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    func backward() {
        guard let temp = paths.pop() else {
            return
        }
        tempPaths.push(temp)
        let r = UIBezierPath()
        for path in paths.list {
            r.append(path)
        }
        showLayer.path = r.cgPath
        
    }
    func forward() {
        guard let temp = tempPaths.pop() else {
            return
        }
        paths.push(temp)
        let r = UIBezierPath()
        for path in paths.list {
            r.append(path)
        }
        showLayer.path = r.cgPath
    }

    
}
