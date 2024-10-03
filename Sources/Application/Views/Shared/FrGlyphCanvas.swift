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
  var autoWidth: Bool = false
  @Binding var debugLevels: [DEBUG__FrOverlayOptions]
  @Binding var focusPoint: CGPoint
  var width: Double {

    if autoWidth {
      return .infinity
    }

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

      // Grid line color
      let gridColor = Color.gray.opacity(0.5)

      // Draw vertical grid lines
      for x in stride(from: 0, to: size.width, by: 10) {
        context.stroke(
          Path(CGPath(rect: CGRect(x: x, y: 0, width: 1, height: size.height), transform: nil)),
          with: .color(gridColor)
        )
      }

      // Draw horizontal grid lines
      for y in stride(from: 0, to: size.height, by: 10) {
        context.stroke(
          Path(CGPath(rect: CGRect(x: 0, y: y, width: size.width, height: 1), transform: nil)),
          with: .color(gridColor)
        )
      }

      context.transform.tx = focusPoint.x
      context.transform.ty = focusPoint.y

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

          paths = RenderHelper.buildFrGlyphPaths(
            fromlayer: scaled,
            renderMode: debugLevels.contains(.MainLayerOutlineOverlay) ? .Stroke : .Both)
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
