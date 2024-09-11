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
    var fontRenderScale = 0.3
    var fontHeight: Double = 800
    @State var glyph: Glyph
    @State var debugLevels: [DebugLevel]
    
    
    init(_ loader: FontLoader, _ offset: Int, debugLevels: [DebugLevel] = []) {
        self.debugLevels = debugLevels
        do {
            glyph = try loader.getGlyphContours(at: offset)
        } catch {
            glyph = try! loader.getGlyphContours(at: 0)
        }
    }
    
    var body: some View {
        SharedGlyphView(
            glyph: glyph,
            scale: fontRenderScale,
            fontHeight: fontHeight,
            renderOptions: .create(
                usingGlyph: .init(color: .white, width: 2),
                usingOutline: .init(color: .white, width: 1)    
            ),
            debugLevels: debugLevels
        )
    }
}

