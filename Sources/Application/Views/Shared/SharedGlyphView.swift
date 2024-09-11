//
//  SharedGlyphView.swift
//
//
//  Created by Jefferson Oliveira on 5/9/24.
//

import Foundation
import SwiftUI
import FontLoader

struct RenderStrokeOptions {
    var color: Color
    var width: CGFloat
}

fileprivate let DEFAULT_GLYPH_STROKE_OPTIONS: RenderStrokeOptions = .init(color: .gray, width: 2)
fileprivate let DEFAULT_OUTLINE_STROKE_OPTIONS: RenderStrokeOptions = .init(color: .purple, width: 4)

struct RenderGlyphOptions {
    var glyph: RenderStrokeOptions
    var outline: RenderStrokeOptions
    
    public static func create(
        usingGlyph glyph: RenderStrokeOptions = DEFAULT_GLYPH_STROKE_OPTIONS,
        usingOutline outline: RenderStrokeOptions = DEFAULT_OUTLINE_STROKE_OPTIONS) -> RenderGlyphOptions {
        
        return .init(glyph: glyph, outline: outline)
    }
}

//        let capH = (upm - (ascender - lineGap)) * scale
//        let baseL = ((upm - ascender) + lineGap + sCapHeight) * scale
//        let des = (descender / upm)

struct SharedGlyphView: View {
    var glyph: Glyph
    var scale: Double = 1
    var fontHeight: Double
    var renderOptions: RenderGlyphOptions = RenderGlyphOptions.create()
    @Binding var debugLevels: [DebugLevel]
    
    var path = Path()
    
    let colors: [Color] = [
        .red,
        .green,
        .blue,
        .yellow,
        .purple,
        .brown,
        .cyan,
        .orange,
        .gray,
    ]
    
    func getContourColor(_ input: DebugColors) -> Color {
        switch input {
        case .RED :
            .red
        case .GREEN :
            .green
        case .BLUE :
            .blue
        case .YELLOW :
            .yellow
        case .PURPLE :
            .purple
        case .BROWN :
            .brown
        case .CYAN :
            .cyan
        case .ORANGE :
            .orange
        case .GRAY :
            .gray
        case .PINK :
            .pink
        case .INDIGO:
            .indigo
        }
    }
    
    var body: some View {
        let fontGlyph = FontGlyphContours(from: glyph, scale: scale, debug: debugLevels)
        Canvas { context, size in
            var path = Path()
            for contour in fontGlyph.contours {
                path = Path()
                path.move(to: contour.origin)
                path.addLines(contour.points)
                
                context.stroke(path, with: .color(getContourColor(contour.debugRenderColor)), lineWidth: renderOptions.glyph.width)
            }
        }.frame(width: fontGlyph.width, height: fontGlyph.height)
    }
}
