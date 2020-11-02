//
//  油画笔.swift
//  绘制
//
//  Created by 蔡浩铭 on 2020/10/29.
//

@_exported import UIKit
import Foundation
import CoreGraphics


class OilView: UIView,Input {
    
    static var penSize:CGSize = CGSize.init(width: 30, height: 30)
    static var penColor:UIColor = UIColor.red
    
    var points: [CGPoint] = []
    var totalDrawPoints: [CGPoint] = []
    var increaseDrawPoints: [CGPoint] = []
    var bezierPath =  UIBezierPath()
    var cglayer :CGLayer? = nil
    var fullCGLayer: CGLayer? = nil
    
    lazy var oliPenImage: UIImage? = {
        getOilPenImage()
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.backgroundColor = UIColor.clear.cgColor
        
        self.layer.drawsAsynchronously = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getOilPenImage() -> UIImage? {
        var image: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(OilView.penSize, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        
        if let cgimage = UIImage(named: "PenMask")?.cgImage {
            ctx?.clip(to: CGRect.init(origin: .zero, size: OilView.penSize), mask: cgimage)
        }
        
        ctx?.setFillColor(OilView.penColor.cgColor)
        ctx?.fill(CGRect.init(origin: .zero, size: OilView.penSize))
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    func touchBegan(_ point: CGPoint) {
        clear()
        points.append(point)
        updatePath(.start)
    }
    
    func touchMove(_ point: CGPoint) {
        points.append(point)
        updatePath()
    }
    
    func touchEnd(_ point: CGPoint) {
        points.append(point)
        updatePath(.end)
    }
    
    
    func clear(){
        points.removeAll()
        totalDrawPoints.removeAll()
        increaseDrawPoints.removeAll()
    }
    
    func updatePath(_ state: PathState = .change){
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
            break
        }
        
        getIncreasePoints()
    }
    
    // 需要将BezierPath变成虚线，取出上面的点，计算出每次多增加的点
    private func getIncreasePoints() {
        
        let dashPath = self.bezierPath.cgPath.copy(dashingWithPhase: 0, lengths: [OilView.penSize.width*0.3,0])
        let dashBezierPath = UIBezierPath(cgPath: dashPath)
        
        // 虚线只要moveToPoint
        DispatchQueue.global().async {
            let points = dashBezierPath.cgPath.getPathElementPoints([.moveToPoint])
            
            var frame: CGRect?
            
            if self.totalDrawPoints.isEmpty {
                self.increaseDrawPoints = points
                self.totalDrawPoints = points
            }else{
                guard points.count > self.totalDrawPoints.count else {
                    return
                }
                self.increaseDrawPoints = Array(points[(self.totalDrawPoints.count)...])
                self.totalDrawPoints = points
                
                if self.increaseDrawPoints.count > 1 {
                    var minX:CGFloat = CGFloat.greatestFiniteMagnitude
                    var maxX:CGFloat = CGFloat.leastNonzeroMagnitude
                    var minY:CGFloat = CGFloat.greatestFiniteMagnitude
                    var maxY:CGFloat = CGFloat.leastNonzeroMagnitude
                    self.increaseDrawPoints.forEach { (point) in
                        if point.x < minX {
                            minX = point.x
                        }
                        if point.y < minY {
                            minY = point.y
                        }
                        if point.x > maxX {
                            maxX = point.x
                        }
                        if point.y > maxY {
                            maxY = point.y
                        }
                    }
                    let width = max(maxX-minX, OilView.penSize.width)
                    let heigth = max(maxY-minY, OilView.penSize.height)
                    frame = CGRect.init(x: minX, y: minY, width: width, height: heigth)
                    let transWidth = OilView.penSize.width
                    frame = frame?.applying(.init(translationX: -transWidth/2, y: -transWidth/2))
                }else if self.increaseDrawPoints.count == 1,
                         var point = self.increaseDrawPoints.first {
                    let width = OilView.penSize.width
                    point = point.applying(.init(translationX: -width/2, y: -width/2))
                    frame = CGRect(origin: point, size: OilView.penSize)
                }

                debugPrint("CHLog--  total = \(self.totalDrawPoints.count)")
                debugPrint("CHLog--  increase = \(self.increaseDrawPoints.count)")
            }
            
//            DispatchQueue.main.async {
//                self.layer.setNeedsDisplay()
//            }
            
            if let frame_ = frame {
                debugPrint("CHLog--  frame_ = \(frame_)")
                DispatchQueue.main.async {
                    self.layer.setNeedsDisplay(frame_)
                }
            }

            
        }

    }
    
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
//        super.draw(layer, in: ctx)
        
        guard let penImage = self.oliPenImage else {
            return
        }
        
        var fullCGLayer_ = self.fullCGLayer
        if fullCGLayer_ == nil {
            fullCGLayer_ = CGLayer(ctx, size: self.bounds.size, auxiliaryInfo: nil)
        }

        var cglayer_ = self.cglayer
        if cglayer_ == nil {
            cglayer_ = CGLayer(ctx, size: OilView.penSize, auxiliaryInfo: nil)
            self.cglayer = cglayer_
            guard let cgCtx = cglayer_?.context else {
                return
            }
            UIGraphicsPushContext(cgCtx)
//            cgCtx.setFillColor(UIColor.clear.cgColor)
//            cgCtx.fill(.init(origin: .zero, size: OilView.penSize))
            cgCtx.clear(.init(origin: .zero, size: OilView.penSize))
            penImage.draw(at: .zero)
            UIGraphicsPopContext()
        }

        

        guard let fullCGLayer = fullCGLayer_,
              let fullLayerCtx = fullCGLayer_?.context else {
            return
        }
        
        fullLayerCtx.saveGState()
        let width = OilView.penSize.width
        fullLayerCtx.translateBy(x: -width/2, y: -width/2)
        self.increaseDrawPoints.forEach { (point) in
            fullLayerCtx.draw(cglayer_!, in: .init(origin: point, size: OilView.penSize))
        }
        fullLayerCtx.restoreGState()
        
        ctx.draw(fullCGLayer, in: self.bounds)
        
        
        
        //使用layer 添加penImage
        
    }
    
    
    
    
    
    
    
}
