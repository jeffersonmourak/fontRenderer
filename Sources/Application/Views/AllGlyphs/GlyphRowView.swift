//
//  GlyphRowView.swift
//
//
//  Created by Jefferson Oliveira on 5/12/24.
//

import FontLoader
import Foundation
import SwiftUI

struct GlyphRowView: View {
    var loader: FontLoader
    var offset: Int = 0
    @Binding var debugLevels: [DEBUG__FrOverlayOptions]
    @State var hoverScale: Double = 1.0
    @State var backgroundColor: Color = .clear
    @State var presentPopover: Bool = false

    var glyph: Glyph {
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

    var fontRenderScale = 0.3

    var body: some View {
        Button(action: { presentPopover.toggle() }) {
            FrGlyphView(
                glyph: glyph,
                scale: fontRenderScale,
                renderOptions: .create(
                    usingGlyph: .init(color: .white, width: 2),
                    usingOutline: .init(color: .white, width: 1)),
                debugLevels: $debugLevels
            ).frame(width: 120)
        }
        .buttonStyle(.borderless)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
        .scaleEffect(hoverScale)
        .onHover { isHovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                hoverScale = isHovering ? 1.1 : 1.0
                backgroundColor = isHovering ? Color.gray.opacity(0.1) : .clear
            }
        }
        .popover(isPresented: $presentPopover, arrowEdge: .trailing) {
            FrGlyphView(glyph: glyph, scale: fontRenderScale * 3, debugLevels: $debugLevels).padding()
        }
    }
}
