//
//  Render.swift
//  MetalProject
//
//  Created by 蔡浩铭 on 2021/7/26.
//

import Foundation
import MetalKit
import simd


class Render: NSObject, MTKViewDelegate {

    
    
    var mtkView: MTKView?
    
    var device: MTLDevice? = MTLCreateSystemDefaultDevice()
    
    var pipelineState: MTLRenderPipelineState?
    
    var commandQueue: MTLCommandQueue?
    
    var vertexBuffer: MTLBuffer?
    
    var fragmentBuffer: MTLBuffer?
    
    var vertexArray: [RenderVertex] = []
    
    
    func setup(_ mtkView: MTKView?) {
        self.mtkView = mtkView
        guard let mtkView = self.mtkView else {
            return
        }
        setupMTKView()
        // 生成library
        let library = device?.makeDefaultLibrary()
        // 装载shader到library
        let vFunction = library?.makeFunction(name: "vertexShader")
        let fFunction = library?.makeFunction(name: "fragmentShader")
        // 管线初始化 ----  管线状态描述器
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "render pipeline"
        pipelineStateDescriptor.sampleCount = mtkView.sampleCount
        pipelineStateDescriptor.vertexFunction = vFunction
        pipelineStateDescriptor.fragmentFunction = fFunction
        // ?? colorAttachments数组 ??
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = mtkView.depthStencilPixelFormat
        
        do {
            self.pipelineState = try self.device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            print(error)
        }
        
        
        self.commandQueue = device?.makeCommandQueue()
        
        
//        vertexBuffer = device?.makeBuffer(bytes: <#T##UnsafeRawPointer#>, length: <#T##Int#>, options: <#T##MTLResourceOptions#>)
    }
    
    func setupMTKView(){
        guard let mtkView = self.mtkView else {
            return
        }
        mtkView.device = self.device
        mtkView.delegate = self
        mtkView.sampleCount = 4
//        mtkView.depthStencilPixelFormat = .depth32Float_stencil8
        mtkView.preferredFramesPerSecond = 60
    }
    
    func generateVertex() {
        
        let colors: [simd_float4] = [
            .init(1, 0, 0, 1),
            .init(0, 1, 0, 1),
            .init(0, 0, 1, 1)
        ]
        
        let vertex: [simd_float4] = [
            .init(0, 1, 0, 1),
            .init(-1, -1, 0, 1),
            .init(1, -1, 0, 1),
        ]
        
        for i in 0...2 {
            let v = RenderVertex.init(position: vertex[i], color: colors[i])
            self.vertexArray.append(v)
        }
        
        
    }
    
    /*
     1.setVertexBytes & setVertexBuffer 区别
        介绍里面setVertexBytes等于与创建一个buffer，且将数据扔进buffer里面
    但是区别在于，这个方法避免过度创建buffer来存储数据，而由metal帮忙管理。但是这也有限制，
     小于4kb的数据用setVertexBytes会比较好，大于的话还是用setVertexBuffer。
     */
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    
    func draw(in view: MTKView) {
        /*
        绘制:
         绘制需要给GPU传输一车车的指令。
         指令载体在commandQueue上。
         指令需要由commandBuffer当载体。
         
         
        */
        guard let commandBuffer = self.commandQueue?.makeCommandBuffer() else {
            return
        }
        commandBuffer.label = "render Comman Buffer"
        
        guard let renderPassDescriptor = mtkView?.currentRenderPassDescriptor,
              let renderPipelineState = self.pipelineState,
              let drawable = mtkView?.currentDrawable else {
            return
        }
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.label = "render Encoder"
        renderEncoder?.setRenderPipelineState(renderPipelineState)
//        renderEncoder?.setVertexBuffer(<#T##buffer: MTLBuffer?##MTLBuffer?#>, offset: <#T##Int#>, index: <#T##Int#>)
//        renderEncoder?.setFragmentBuffer(<#T##buffer: MTLBuffer?##MTLBuffer?#>, offset: <#T##Int#>, index: <#T##Int#>)
        
        generateVertex()
        
        renderEncoder?.setVertexBytes(self.vertexArray, length: MemoryLayout<RenderVertex>.stride * 3, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        renderEncoder?.endEncoding()
        commandBuffer.present(drawable)
        
        commandBuffer.commit()
        
    }
    
}
