//
//  ApplicationContext.swift
//
//
//  Created by Jefferson Oliveira on 4/29/24.
//

import Foundation
import FontLoader

struct ContextObject: Equatable {
    let glyph: SimpleGlyphTable?
    
    static func == (lhs: ContextObject, rhs: ContextObject) -> Bool {
        return lhs.glyph == rhs.glyph
    }
}

class ApplicationContext: Equatable {
    private var state: Signal<ContextObject>
    
    init(_ context: ContextObject) {
        self.state = Signal(context)
    }
    
    static func == (lhs: ApplicationContext, rhs: ApplicationContext) -> Bool {
        return false
    }
    
    var observe: ObserveSignal<ContextObject> {
        get{
            return ObserveSignal(state)
        }
    }
}
