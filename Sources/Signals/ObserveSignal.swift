//
//  ObserveSignal.swift
//
//
//  Created by Jefferson Oliveira on 4/29/24.
//


import SwiftUI

class ObserveSignal<T: Equatable>: ObservableObject {
    private let signal: Signal<T>
    private var runningEffect: Effect?
    @Published var value: T
    
    init(_ signal: Signal<T>) {
        self.signal = signal
        self.value = signal.value
        
        self.runningEffect = Effect {
            self.value = self.signal.value
        }
    }
    
    deinit {
        runningEffect?.dispose()
    }
}
