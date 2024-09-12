//
//  GlyphRowView.swift
//
//
//  Created by Jefferson Oliveira on 5/12/24.
//

import Foundation
import SwiftUI
import FontLoader

struct GlyphRowView: View {
    var loader: FontLoader
    var offset: Int = 0
    @Binding var debugLevels: [DEBUG__FrOverlayOptions]
    
    var glyph: Glyph {
        get {
            do {
                return try loader.getGlyphContours(
                    at: offset
                )
            } catch {
                return try! loader.getGlyphContours(
                    at: 0
                )
            }
        }
    }
    
    var fontRenderScale = 0.3
    var fontHeight: Double = 800
    
    var body: some View {
        FrGlyphView(
            glyph: glyph,
            scale: fontRenderScale,
            fontHeight: fontHeight,
            renderOptions: .create(usingGlyph: .init(color: .white, width: 2),usingOutline: .init(color: .white, width: 1)),
            debugLevels: $debugLevels
        )
    }
}

