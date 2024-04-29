//
//  Effect.swift
//  reactivity
//
//  Created by Jefferson Oliveira on 2/20/24.
//

import Foundation

class Effect: DependencyProtocol {
    private var isStale: Bool = true;
    private var executeFn: () -> Void
    private var _deInitRef: ((any DependencyProtocol) -> Void)? = nil
    
    init(_ executeFn: @escaping () -> Void) {
        self.executeFn = executeFn;
        
        execute();
    }
    
    static func == (lhs: Effect, rhs: Effect) -> Bool {
        return lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    deinit {
        dispose()
    }
    
    func dispose() {
        guard _deInitRef != nil else {
            return
        }
        
        _deInitRef!(self)
    }
    
    func onDispose(_ removeFromDependency: @escaping (any DependencyProtocol) -> Void) {
        _deInitRef = removeFromDependency
    }
    
    private func execute() {
        guard isStale else {
            return
        }
        
        Runtime.shared.dependencyRef = self
        executeFn()
        isStale = false
        Runtime.shared.dependencyRef = nil
    }
    
    func notifyUpdate() {
        isStale = true
        execute()
    }
}
