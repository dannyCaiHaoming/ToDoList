//
//  ViewController.swift
//  绘制
//
//  Created by 蔡浩铭 on 2020/10/28.
//

import UIKit
import Foundation


class ViewController: UIViewController {
    
    lazy var caView: CAView = {
        let view = CAView(frame: .init(x: 0, y: 0, width: screen_width, height: screen_height / 2))
        return view
    }()
    
    lazy var cgView: CGView = {
        let view = CGView(frame: .init(x: 0, y: screen_height / 2, width: screen_width, height: screen_height / 2))
        return view
    }()
    
    lazy var oilView: OilView = {
        let view = OilView(frame: UIScreen.main.bounds)
        view.backgroundColor = .green
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        test()
    }

    
    func setupUI(){
//        caView,cgView,
        self.view.addSubviews(oilView)
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panAction(_:)))
        pan.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(pan)
    }
    
    
    @objc func panAction(_ panGesture: UIPanGestureRecognizer) {
        var input: Input?
        var point = CGPoint.zero
        let location = panGesture.location(in: self.view)
        if caView.superview != nil, caView.frame.contains(location)  {
            input = caView
            point = panGesture.location(in: caView)
        }else if cgView.superview != nil, cgView.frame.contains(location){
            input = cgView
            point = panGesture.location(in: cgView)
        }else if oilView.superview != nil, oilView.frame.contains(location){
            input = oilView
            point = panGesture.location(in: oilView)
        }
        switch panGesture.state {
        case .began:
            input?.touchBegan(point)
        case .changed:
            input?.touchMove(point)
        case .ended,.cancelled,.failed:
            input?.touchEnd(point)
        default:
            break
        }
    }
    
    func test(){
        
        if let path = Bundle.main.path(forResource: "test", ofType: "plist"),
           let array = NSArray.init(contentsOf: URL(fileURLWithPath: path)) as? [String] {
            
            print(array.count)
            
            let points = array.map({ NSCoder.cgPoint(for: $0) })
        
            NSLog("start")
            
//            caView.touchBegan(points.first!)
//            points[1...].forEach({ caView.touchMove($0) })
            
            cgView.touchBegan(points.first!)
            points[1...].forEach({ cgView.touchMove($0) })
            
            
            NSLog("end")
        }
    }
    

}

