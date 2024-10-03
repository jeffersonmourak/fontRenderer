//
//  FrGlyphView.swift
//
//
//  Created by Jefferson Oliveira on 5/9/24.
//

import Foundation
import SwiftUI
import FontLoader

struct FrGlyphView: View {
    var glyph: Glyph
    var scale: Double = 1
    var renderOptions: RenderGlyphOptions = RenderGlyphOptions.create()
    @Binding var debugLevels: [DEBUG__FrOverlayOptions]
    
    var path = Path()
    
    var body: some View {
        let fontGlyph = FrGlyphManager.shared.loadGlyph(from: glyph, scale: scale, debug: debugLevels)
        let width = fontGlyph.width.toScaled(by: scale)
        let height = fontGlyph.height.toScaled(by: scale)
        @State var focusPoint: CGPoint = .zero
        
        VStack {
            FrGlyphCanvas(glyphs: [glyph], scale: scale, debugLevels: $debugLevels, focusPoint: $focusPoint).frame(width: width, height: height)
            VStack{
                Text(glyph.name)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text("Index: \(glyph.index)")
                    .font(.caption)
            }.padding()
        }.frame(width: width * 1.5)
    }
}
