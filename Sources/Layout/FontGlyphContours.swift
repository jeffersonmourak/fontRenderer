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
    case Borders
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
    case PINK
    case INDIGO
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


func getContourBoundary(points: [CGPoint]) -> ((CGFloat, CGFloat), (CGFloat, CGFloat)) {
    var minX = points[0].x
    var maxX = points[0].x
    var minY = points[0].y
    var maxY = points[0].y
    
    for point in points {
        if point.x < minX {
            minX = point.x
        }
        if (point.x > maxX) {
            maxX = point.x
        }
        
        if (point.y < minY) {
            minY = point.y
        }
        
        if (point.y > maxY) {
            maxY = point.y
        }
    }
    
    return ((minX, minY), (maxX, maxY))
}

func getContoursBoundaries(contours: [[CGPoint]]) -> ((CGFloat, CGFloat), (CGFloat, CGFloat)) {
    var ((minX, minY), (maxX, maxY)) = getContourBoundary(points: contours[0])
    
    for points in contours {
        let ((cMinX, cMinY), (cMaxX, cMaxY)) = getContourBoundary(points: points)
        
        if cMinX < minX {
            minX = cMinX
        }
        if (cMaxX > maxX) {
            maxX = cMaxX
        }
        
        if (cMinY < minY) {
            maxY = cMinY
        }
        
        if (cMaxY > maxY) {
            maxY = cMaxY
        }
    }
    
    return ((minX, minY), (maxX, maxY))
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
            return .init(origin: a, points: [a, b], debugRenderColor: DebugColors.INDIGO)
        }
    }
    
    private var DEBUG_BORDER_CONTOURS: ContoursInstructions {
        get {
            
            let ((minX, minY), (maxX, maxY)) = getContoursBoundaries(contours: glyph.contours)
            
            let tl: CGPoint = .init(x: toScale(minX), y: toScale(minY))
            let tr: CGPoint = .init(x: toScale(maxX), y: toScale(minY))
            let br: CGPoint = .init(x: toScale(maxX), y: toScale(maxY))
            let bl: CGPoint = .init(x: toScale(minX), y: toScale(maxY))
            return .init(origin: tl, points: [tl, tr, br, bl, tl], debugRenderColor: DebugColors.PINK)
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
            
            if debugInstructions.contains(.Borders) {
                instructions.append(DEBUG_BORDER_CONTOURS)
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
