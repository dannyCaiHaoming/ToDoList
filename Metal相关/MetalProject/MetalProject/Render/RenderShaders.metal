//
//  RenderShaders.metal
//  MetalProject
//
//  Created by 蔡浩铭 on 2021/7/26.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
//    var position: vector_float2
    float4 position [[position]];
//    var color: vector_float4
    float4 color;
}RenderVertex;


vertex RenderVertex vertexShader(const device RenderVertex *vertexs,
                                 uint vid [[vertex_id]]){
    RenderVertex out = vertexs[vid];
//    float4 outColor = out.color;
    return out;
}


fragment float4 fragmentShader(RenderVertex in [[stage_in]]){
    return in.color;
}
