//
//  Signal.swift
//  reactivity
//
//  Created by Jefferson Oliveira on 2/20/24.
//

import Foundation

class Signal<T: Equatable> {
    private var _value: T;
    private var _dependents: [any DependencyProtocol] = [];
    
    init(_ initialValue: T){
        _value = initialValue
    }
    
    var value: T {
        get {
            let dependencyRef = Runtime.shared.dependencyRef;
            
            if (dependencyRef != nil) {
                addDependent(dependencyRef!)
            }
            
            return _value
        }
        set(newValue) {
            guard newValue != _value else {
                return
            }
            
            _value = newValue
            notifyDependents()
        }
    }
    
    private func addDependent(_ dependent: any DependencyProtocol) {
        if (_dependents.contains { $0.hashValue == dependent.hashValue }) {
            return
        }
        
        dependent.onDispose { [weak self] in self?.removeDependent($0) }
        
        _dependents.append(dependent)
    }
    
    private func removeDependent(_ dependent: any DependencyProtocol) {
        _dependents = _dependents.filter { $0.hashValue != dependent.hashValue }
    }
    
    private func notifyDependents() {
        for dependent in _dependents {
            dependent.notifyUpdate()
        }
    }
}
