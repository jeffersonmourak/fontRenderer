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
    var fontHeight: Double
    var renderOptions: RenderGlyphOptions = RenderGlyphOptions.create()
    @Binding var debugLevels: [DEBUG__FrOverlayOptions]
    @State var contourLayer: Int = 0
    @State var DEBUG_mainLayerMaxPoints: [Double] = []
    
    var path = Path()
    
    var body: some View {
        let fontGlyph = FrGlyphManager.shared.loadGlyph(from: glyph, scale: scale, debug: debugLevels)
        let width = fontGlyph.width.toScaled(by: scale)
        let height = fontGlyph.height.toScaled(by: scale)
        
        VStack {
            FrGlyphCanvas(glyphs: [glyph], scale: scale, debugLevels: debugLevels).frame(width: width, height: height)
            VStack{
                Text("Glyph: \(glyph.name)")
                    .font(.caption)
                Text("Index: \(glyph.index)")
                    .font(.caption)
            }.padding()
        }.frame(width: width * 1.5)
    }
}
