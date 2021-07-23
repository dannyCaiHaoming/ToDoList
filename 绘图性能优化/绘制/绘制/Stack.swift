//
//  Stack.swift
//  绘制
//
//  Created by 蔡浩铭 on 2021/7/22.
//

import Foundation

struct Stack<T> {
    var list:[T] = []
    
    mutating func push(_ e: T) {
        self.list.append(e)
    }
    
    mutating func pop() -> T? {
        if self.list.count > 0 {
            return self.list.removeLast()
        }
        return nil
    }
    
    func peek() -> T? {
        if self.list.count > 0 {
            return self.list.last
        }
        return nil
    }
}
