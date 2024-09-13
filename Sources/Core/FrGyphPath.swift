//
//  FrLayerFragment.swift
//
//
//  Created by Jefferson Oliveira on 9/12/24.
//

import Foundation
import SwiftUI

struct RenderStrokeOptions {
    var color: Color
    var width: CGFloat
}

fileprivate let DEFAULT_GLYPH_STROKE_OPTIONS: RenderStrokeOptions = .init(
    color: .gray,
    width: 2
)
fileprivate let DEFAULT_OUTLINE_STROKE_OPTIONS: RenderStrokeOptions = .init(
    color: .purple,
    width: 4
)

struct RenderGlyphOptions {
    var glyph: RenderStrokeOptions
    var outline: RenderStrokeOptions
    
    public static func create(
        usingGlyph glyph: RenderStrokeOptions = DEFAULT_GLYPH_STROKE_OPTIONS,
        usingOutline outline: RenderStrokeOptions = DEFAULT_OUTLINE_STROKE_OPTIONS
    ) -> RenderGlyphOptions {
        
        return .init(
            glyph: glyph,
            outline: outline
        )
    }
}

//        let capH = (upm - (ascender - lineGap)) * scale
//        let baseL = ((upm - ascender) + lineGap + sCapHeight) * scale
//        let des = (descender / upm)

enum RenderMode {
    case Fill
    case Stroke
}

public struct FrGyphPath {
    let path: Path
    let color: GraphicsContext.Shading
    let style: StrokeStyle
    let direction: FrContourDirection
    var renderMode: RenderMode = .Stroke
    
    public func render(at context: inout GraphicsContext, with shading: GraphicsContext.Shading = .color(.accentColor)) {
        if renderMode == .Fill {
            context.fill(path,with: shading)
        } else {
            context.stroke(path, with: color, style: style)
        }
    }
}

extension Array where Element == FrGyphPath {
    public func render(at context: inout GraphicsContext, with shading: GraphicsContext.Shading = .color(.accentColor), mergePaths: Bool = false) {
        if !mergePaths {
            for instruction in self { instruction.render(at: &context, with: shading) }
            
            return
        }
        
        var unifiedPath = Path()
        
        for instruction in self {
            unifiedPath = instruction.direction == .Clockwise
                ? unifiedPath.subtracting(instruction.path, eoFill: true)
                : unifiedPath.union(instruction.path, eoFill: true)
        }
        
        let unifiedInstruction = FrGyphPath(
            path: unifiedPath,
            color: self[0].color,
            style: self[0].style,
            direction: self[0].direction,
            renderMode: self[0].renderMode
        )
        
        unifiedInstruction.render(at: &context, with: shading)
    }
}
