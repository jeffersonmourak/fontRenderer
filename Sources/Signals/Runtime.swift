//
//  Runtime.swift
//  reactivity
//
//  Created by Jefferson Oliveira on 2/20/24.
//

import Foundation

protocol DependencyProtocol: Hashable {
    func notifyUpdate()
    
    func onDispose(_: @escaping (any DependencyProtocol) -> Void)
    
    func dispose()
}

typealias ComputableValues = Any

class Runtime {
    var dependencyRef: (any DependencyProtocol)? = nil;
    
    static var shared: Runtime = {
        let instance = Runtime();
        
        return instance;
    }()
}

extension Runtime: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
