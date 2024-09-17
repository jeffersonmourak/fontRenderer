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
  let glyphs: [FrGlyph]
  let scale: Double
  let debugLevels: [DEBUG__FrOverlayOptions]

  let width: Double

  init(glyphs: [Glyph], scale: Double, debugLevels: [DEBUG__FrOverlayOptions]) {
    self.scale = scale
    self.debugLevels = debugLevels

    self.glyphs = glyphs.map {
      FrGlyphManager.shared.loadGlyph(from: $0, scale: scale, debug: debugLevels)
    }

    self.width = self.glyphs.reduce(0) { $0 + $1.width.toScaled(by: scale) }
  }

  var body: some View {
    Canvas {
      context,
      size in
      for fontGlyph in glyphs {
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
