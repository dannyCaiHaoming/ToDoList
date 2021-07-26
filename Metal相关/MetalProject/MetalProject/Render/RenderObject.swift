//
//  RenderObject.swift
//  MetalProject
//
//  Created by 蔡浩铭 on 2021/7/26.
//

import Foundation
import simd


enum RenderVertexInputIndex: Int {
    case vertex = 0
}

struct RenderVertex {
    var position: vector_float4
    var color: vector_float4
}
