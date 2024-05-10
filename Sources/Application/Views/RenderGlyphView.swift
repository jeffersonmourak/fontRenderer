//
//  RenderGlyphView.swift
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

struct RenderGlyphView: View {
    var glyph: Glyph
    var scale: Double = 1
    var fontHeight: Double
    var renderOptions: RenderGlyphOptions = RenderGlyphOptions.create()
    
    var path = Path()
    
    func toScale<T: BinaryInteger>(_ value: T) -> CGFloat {
        return CGFloat(Int((CGFloat(value) * CGFloat(scale)) * 1000) / 1000)
    }
    
    func toScale(_ value: CGFloat) -> CGFloat {
        return CGFloat((value * CGFloat(scale)) * 1000 / 1000)
    }
    
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
    
    
    
    var body: some View {
        let width = glyph.glyphBox.xMax > Double(glyph.fontLayout.horizontalMetrics.advanceWidth) ? CGFloat(glyph.glyphBox.xMax) : CGFloat(glyph.fontLayout.horizontalMetrics.advanceWidth)
        
        Canvas { context, size in
            // @TODO: Find what to do with SafeCanvas
            //let _ = SafeCanvas(withBoundary: .init(a: minPoints, b:maxPoints))
            
            var path = Path()
            path.addLines([
                .init(x: 0, y: 0),
                .init(x: size.width, y: .zero),
                .init(x: size.width, y: size.height),
                .init(x: .zero, y: size.height),
                .init(x: 0, y: 0)
            ]
            )
            context.stroke(path, with: .color(renderOptions.outline.color), lineWidth: renderOptions.outline.width)
            
            for glyphContours in glyph.contours {
                let coords = glyphContours.map {
                    let newY = ((glyph.fontLayout.fontBoundaries.1.y * 0.7) - $0.y) - Double(glyph.baseLineDistance)
                    let newX = $0.x
                    
                    return CGPoint(x: toScale(newX), y: toScale(newY))
                }
                
                if coords.count == 0 {
                    return;
                }
                
                path = Path()
                path.move(to: coords[0])
                path.addLines(coords)
                context.stroke(path, with: .color(renderOptions.glyph.color), lineWidth: renderOptions.glyph.width)
            }
            
        }.frame(width: toScale(width), height: toScale(glyph.fontLayout.fontBoundaries.1.y * 0.7))
    }
}
