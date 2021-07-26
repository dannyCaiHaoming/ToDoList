//
//  RenderView.swift
//  MetalProject
//
//  Created by 蔡浩铭 on 2021/7/26.
//

import Foundation
import MetalKit

class RenderView: MTKView {
    
    
    lazy var render: Render = {
        let r = Render()
        r.setup(self)
        return r
    }()
    
    func loadRender(){
        _ = self.render
    }
    
    func startRender() {
        
    }
    
    
    
}
