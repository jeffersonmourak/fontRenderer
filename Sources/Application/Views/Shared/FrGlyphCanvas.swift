//
//  FrGlyphCanvas.swift
//
//
//  Created by Jefferson Oliveira on 16/9/24.
//

import FontLoader
import Foundation
import SwiftUI

struct FrGlyphCanvas: View {
  let glyphs: [Glyph]
  var scale: Double
  @Binding var debugLevels: [DEBUG__FrOverlayOptions]
  var width: Double {
    return glyphs.reduce(0) {
      let fontGlyph: FrGlyph = FrGlyphManager.shared.loadGlyph(
        from: $1, scale: scale, debug: debugLevels)
      return $0 + fontGlyph.width.toScaled(by: scale)
    }
  }

  var body: some View {
    Canvas {
      context,
      size in
      for glyph: Glyph in glyphs {

        let fontGlyph: FrGlyph =
          FrGlyphManager.shared.loadGlyph(
            from: glyph,
            scale: scale,
            debug: debugLevels
          )

        fontGlyph.DEBUG__SetDebugOptions(debugLevels)

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

        context.translateBy(x: fontGlyph.width.toScaled(by: scale), y: 0)
      }
    }.frame(width: width)
  }
}
