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
            Canvas {
                context,
                size in
                for layer in fontGlyph.layers {
                    let scaled = layer.toScaled(by: scale)
                    var paths: [FrGyphPath] = []
                    
                    paths = RenderHelper.buildFrGlyphPaths(fromlayer: scaled)
                    paths.render(
                        at: &context,
                        with: .color(DEBUG_getGlyphFillColor(debugLevels: debugLevels)),
                        mergePaths: scaled.layerType == .Main
                    )
                }
            }.frame(width: width, height: height)
        }
    }
}
