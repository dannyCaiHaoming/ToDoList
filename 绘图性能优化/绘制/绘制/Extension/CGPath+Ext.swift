//
//  CGPath+Ext.swift
//  绘制
//
//  Created by 蔡浩铭 on 2020/10/30.
//

import Foundation
@_exported import UIKit

extension CGPath {
    func forEach(body:@escaping  @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        let callback:@convention(c) (UnsafeMutableRawPointer,UnsafePointer<CGPathElement>) -> Void = { (function,param) in
            
            let function_ = unsafeBitCast(function, to: Body.self)
            function_(param.pointee)
        }
        let unsafeFunction = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeFunction, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }
    
    
//    case moveToPoint = 0
//
//    case addLineToPoint = 1
//
//    case addQuadCurveToPoint = 2
//
//    case addCurveToPoint = 3
//
//    case closeSubpath = 4
    func getPathElementPoints(_ filter: [CGPathElementType] = [.moveToPoint,.addLineToPoint,.addQuadCurveToPoint,.addCurveToPoint,.closeSubpath]) -> [CGPoint] {
        var points:[CGPoint] = []
        self.forEach { (element) in
            switch element.type {
            case .moveToPoint where filter.contains(element.type):
//                debugPrint("CH--- moveToPoint")
                points.append(element.points[0])
            case .addLineToPoint where filter.contains(element.type):
//                debugPrint("CH--- addLineToPoint")
                points.append(element.points[0])
            case .addCurveToPoint where filter.contains(element.type):
//                debugPrint("CH--- LogaddCurveToPoint")
                points.append(element.points[0])
                points.append(element.points[1])
            case .addQuadCurveToPoint where filter.contains(element.type):
//                debugPrint("CH--- addQuadCurveToPoint")
                points.append(element.points[0])
                points.append(element.points[1])
                points.append(element.points[2])
            default:
                break
            }
        }
        return points
    }
    
    func getPathElementsPointsAndTypes() -> ([CGPoint],[CGPathElementType]) {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        var arrayTypes : [CGPathElementType]! = [CGPathElementType]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            default: break
            }
        }
        return (arrayPoints,arrayTypes)
    }
    
    
}
