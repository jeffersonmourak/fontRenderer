//
//  FrGlyphManager.swift
//
//
//  Created by Jefferson Oliveira on 9/12/24.
//

import Foundation
import FontLoader

class FrGlyphManager {
    static let shared = FrGlyphManager()
    
    private var glyphCache: [Int: FrGlyph] = [:]
    
    private init() {}
    
    public func loadGlyph(from inputGlyph: Glyph, scale: Double = 0, debug: [DEBUG__FrOverlayOptions] = []) -> FrGlyph {
        
        if (glyphCache[inputGlyph.index] == nil) {
            let glyph = FrGlyph(from: inputGlyph, scale: scale, debug: debug)

            glyphCache[inputGlyph.index] = glyph
            
            return glyph
        }
        
        return glyphCache[inputGlyph.index]!
    }
}
