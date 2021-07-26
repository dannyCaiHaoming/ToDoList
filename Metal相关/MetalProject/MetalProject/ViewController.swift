//
//  ViewController.swift
//  MetalProject
//
//  Created by 蔡浩铭 on 2021/7/26.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var renderView: RenderView = {
        let v = RenderView(frame: self.view.bounds)
        v.backgroundColor = .clear
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        renderView.loadRender()
    }
    
    func setupUI() {
        
        
        self.view.addSubview(renderView)
        
    }

}

