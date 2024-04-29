//
//  Computed.swift
//  reactivity
//
//  Created by Jefferson Oliveira on 2/20/24.
//

import Foundation



class Computed<T>: DependencyProtocol {
    static func == (lhs: Computed, rhs: Computed) -> Bool {
        return lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    private var _value: T?;
    private var isStale: Bool = true;
    private var computeFn: () -> T
    private var _deInitRef: ((any DependencyProtocol) -> Void)? = nil
    
    init(_ computeFn: @escaping () -> T) {
        self.computeFn = computeFn
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
    
    var value: T {
        get {
            guard isStale else {
                return _value!
            }
            
            Runtime.shared.dependencyRef = self
            recomputeValue()
            Runtime.shared.dependencyRef = nil
            
            return _value!
        }
    }
    
    private func recomputeValue() {
        _value = computeFn()
        isStale = false
    }
    
    func notifyUpdate() {
        isStale = true
    }
}
