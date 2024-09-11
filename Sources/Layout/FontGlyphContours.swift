//
//  SafeCanvas.swift
//
//
//  Created by Jefferson Oliveira on 4/30/24.
//

import Foundation
import FontLoader
import SwiftUI

enum DebugLevel {
    case Contours
    case Baseline
}

enum DebugColors {
    case RED
    case GREEN
    case BLUE
    case YELLOW
    case PURPLE
    case BROWN
    case CYAN
    case ORANGE
    case GRAY
}

let DEBUG_COLORS: [DebugColors] = [
    .RED,
    .GREEN,
    .BLUE,
    .YELLOW,
    .PURPLE,
    .BROWN,
    .CYAN,
    .ORANGE,
    .GRAY
]

struct ContoursInstructions {
    let origin: CGPoint
    let points: [CGPoint]
    let debugRenderColor: DebugColors
}

struct Vector4 {
    let a: CGPoint
    let b: CGPoint
}

class FontGlyphContours {
    var scale: Double
    let glyph: Glyph
    let debugInstructions: [DebugLevel]
    
    func toScale<T: BinaryInteger>(_ value: T) -> CGFloat {
        return CGFloat(value) * CGFloat(scale)
    }
    
    func toScale(_ value: CGFloat) -> CGFloat {
        return CGFloat((value * CGFloat(scale)) * 1000 / 1000)
    }
    
    private func getDebugColor(_ index: Int) -> DebugColors {
        let max = DEBUG_COLORS.count
        
        let normalIndex = (index + max) % max
        
        return DEBUG_COLORS[normalIndex]
    }
    
    init (from inputGlyph: Glyph, scale: Double = 0, debug: [DebugLevel] = []) {
        self.glyph = inputGlyph
        self.scale = scale
        self.debugInstructions = debug
    }
    
    private var DEBUG_BASELINE_CONTOURS: ContoursInstructions {
        get {
            let a: CGPoint = .init(x: 0, y: toScale(glyph.layout.height))
            let b: CGPoint = .init(x: glyph.layout.width, y: toScale(glyph.layout.height))
            return .init(origin: a, points: [a, b], debugRenderColor: DebugColors.GREEN)
        }
    }
    
    public var contours: [ContoursInstructions] {
        get {
            var instructions: [ContoursInstructions] = []
            
            for i in 0..<glyph.contours.count {
                let glyphContours = glyph.contours[i]
                let coords = glyphContours.map { CGPoint(x: toScale($0.x), y: toScale($0.y)) }
                
                if coords.count == 0 {
                    return [];
                }
                
                let debugColor = debugInstructions.contains(.Contours) ? getDebugColor(i) : .GRAY
                
                instructions.append(.init(origin: coords[0], points: coords, debugRenderColor: debugColor))
            }
            
            
            if debugInstructions.contains(.Baseline) {
                instructions.append(DEBUG_BASELINE_CONTOURS)
            }
            
            
            return instructions
        }
    }
    
    public var width: CGFloat {
        get {
            return toScale(glyph.layout.width)
        }
    }
    
    public var height: CGFloat {
        get {
            return toScale(glyph.layout.height - Double(glyph.layout.horizontalMetrics.descent))
        }
    }
}
