//
//  FrGlyphView.swift
//
//
//  Created by Jefferson Oliveira on 5/9/24.
//

import Foundation
import SwiftUI
import FontLoader

func getComputedAmount(mainLayer: FrRenderLayer, debugLevels: [DEBUG__FrOverlayOptions], DEBUG_mainLayerMaxPoints: inout [Double]) -> [Double] {
    if !debugLevels.contains(.SteppedPointsOverlay) {
        return mainLayer.contours.map { Double($0.points.count) }
    }
    
    if DEBUG_mainLayerMaxPoints.count == 0 {
        let localAmounts = mainLayer.contours.map({ _ in /*Double($0.points.count)*/ 0.0 })
        DEBUG_mainLayerMaxPoints = localAmounts
        
        return localAmounts
    }
    
    return DEBUG_mainLayerMaxPoints
}

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
        let fontGlyph = FrGlyph(from: glyph, scale: scale, debug: debugLevels)
        let width = fontGlyph.width.toScaled(by: scale)
        let height = fontGlyph.height.toScaled(by: scale)
        
        let computedAmounts = Binding<[Double]>(
            get: { getComputedAmount(mainLayer: fontGlyph.mainLayer, debugLevels: debugLevels, DEBUG_mainLayerMaxPoints: &DEBUG_mainLayerMaxPoints) },
            set: { DEBUG_mainLayerMaxPoints = $0 }
        )
        
        VStack {
            Canvas {
                context,
                size in
                for layer in fontGlyph.layers {
                    let scaled = layer.toScaled(by: scale)
                    var strokes: [FrGyphPath] = []
                    
                    if scaled.layerType == .Main {
                        strokes = RenderHelper.buildFrGlyphPaths(fromlayer: scaled, DEBUG_mainLayerMaxPoints: DEBUG_mainLayerMaxPoints)
                    } else {
                        strokes = RenderHelper.buildFrGlyphPaths(fromlayer: scaled)
                    }
                                        
                    strokes.render(
                        at: &context,
                        with: .color(DEBUG_getGlyphFillColor(debugLevels: debugLevels)),
                        mergePaths: scaled.layerType == .Main
                    )
                }
            }.frame(width: width, height: height)
            
            if debugLevels.contains(.SteppedPointsOverlay) {
                VStack {
                    Stepper(
                        "Contour #\(contourLayer + 1)",
                        value: $contourLayer,
                        in: 0...fontGlyph.mainLayer.contours.count - 1
                    )
                    Slider(
                        value: computedAmounts[contourLayer],
                        in: 0...Double(
                            fontGlyph.mainLayer.contours[contourLayer].points.count
                        ),
                        step: 1
                    )
                }
            }
        }
    }
}
