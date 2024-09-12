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
    case Points
    case ImpliedPoints
    case SteppedPoints
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

enum RenderLayer {
    case Main
    case Debug
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

struct DebugRenderOptions {
    let color: DebugColors
    var width: CGFloat = 2
    var lineCap: CGLineCap = .butt
    var lineJoin: CGLineJoin = .miter
    
    public func asStrokeStyle() -> StrokeStyle {
        return StrokeStyle(
            lineWidth: width,
            lineCap: lineCap,
            lineJoin: lineJoin
        )
    }
}

public struct ContourPoint {
    public let x: Double
    public let y: Double
    public var onCurve: Bool = false
    
    public func cgPoint() -> CGPoint {
        .init(x: x, y: y)
    }
}


extension Array where Element == ContourPoint {
    func asCGPointArray() -> [CGPoint] {
        self.map { item in item.cgPoint() }
    }
}

struct ContoursInstructions {
    let origin: ContourPoint
    let points: [ContourPoint]
    let debugRenderOptions: DebugRenderOptions
    var renderLayer: RenderLayer = .Main
    
    func DEBUG_truncatePoints(_ length: Int) -> Self {
        var truncatedPoints: [ContourPoint] = []
        
        truncatedPoints.append(contentsOf: points[0..<length])
        
        return .init(origin: origin, points: truncatedPoints, debugRenderOptions: debugRenderOptions)
    }
}

func getContourBoundary(points: [GlyphPoint]) -> ((CGFloat, CGFloat), (CGFloat, CGFloat)) {
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

func getContoursBoundaries(contours: [[GlyphPoint]]) -> ((CGFloat, CGFloat), (CGFloat, CGFloat)) {
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

func getPointColor(_ point: GlyphPoint, _ index: Int, _ count: Int) -> DebugColors {
    if count - 1 == index {
        return .PINK
    }
    
    if index == 1 {
        return .INDIGO
    }
    
    return point.flag.onCurve ? .GREEN : .YELLOW
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
            let a: ContourPoint = .init(x: 0, y: toScale(glyph.layout.height))
            let b: ContourPoint = .init(x: glyph.layout.width, y: toScale(glyph.layout.height))
            return .init(origin: a, points: [a, b], debugRenderOptions: .init(color: DebugColors.INDIGO), renderLayer: .Debug)
        }
    }
    
    private var DEBUG_BORDER_CONTOURS: ContoursInstructions {
        get {
            
            let ((minX, minY), (maxX, maxY)) = getContoursBoundaries(contours: glyph.contours)
            
            let tl: ContourPoint = .init(x: toScale(minX), y: toScale(minY))
            let tr: ContourPoint = .init(x: toScale(maxX), y: toScale(minY))
            let br: ContourPoint = .init(x: toScale(maxX), y: toScale(maxY))
            let bl: ContourPoint = .init(x: toScale(minX), y: toScale(maxY))
            return .init(origin: tl, points: [tl, tr, br, bl, tl], debugRenderOptions: .init(color: DebugColors.PINK), renderLayer: .Debug)
        }
    }
    
    private var DEBUG_CONTOURS_POINTS: [ContoursInstructions] {
        get {
            var pointInstructions: [ContoursInstructions] = []
            
            for contour in glyph.contours {
                for i in 0..<contour.count {
                    let point = contour[i]
                    let contourPoint = point.toCGPoint()
                    let points: [ContourPoint] = [
                        .init(x: toScale(contourPoint.x), y: toScale(contourPoint.y)),
                        .init(x: toScale(contourPoint.x), y: toScale(contourPoint.y))
                    ]
                    
                    if point.isImplied{
                        continue
                    }
                    
                    pointInstructions.append(
                        .init(
                            origin: points[0],
                            points: points, 
                            debugRenderOptions: .init(
                                color: getPointColor(point, i, contour.count),
                                width: 8, 
                                lineCap: .round, lineJoin: .round
                            ),
                            renderLayer: .Debug
                        )
                    )
                }
            }
            
            return pointInstructions
        }
    }
    
    private var DEBUG_CONTOURS_IMPLIED_POINTS: [ContoursInstructions] {
        get {
            
            var pointInstructions: [ContoursInstructions] = []
            
            for contour in glyph.contours {
                for i in 0..<contour.count {
                    let point = contour[i]
                    let contourPoint = point.toCGPoint()
                    let points: [ContourPoint] = [
                        .init(x: toScale(contourPoint.x), y: toScale(contourPoint.y)),
                        .init(x: toScale(contourPoint.x), y: toScale(contourPoint.y))
                    ]
                    
                    if !point.isImplied {
                        continue
                    }
                    
                    pointInstructions.append(
                        .init(
                            origin: points[0],
                            points: points,
                            debugRenderOptions: .init(
                                color: getPointColor(point, i, contour.count),
                                width: 8,
                                lineCap: .round, lineJoin: .round
                            ),
                            renderLayer: .Debug
                        )
                    )
                }
            }
            
            return pointInstructions
        }
    }
    
    public var debugLayer: [ContoursInstructions] {
        get {
            var instructions: [ContoursInstructions] = []
            
            if debugInstructions.contains(.Baseline) {
                instructions.append(DEBUG_BASELINE_CONTOURS)
            }
            
            if debugInstructions.contains(.Points) {
                instructions.append(contentsOf: DEBUG_CONTOURS_POINTS)
            }

            if debugInstructions.contains(.ImpliedPoints) {
                instructions.append(contentsOf: DEBUG_CONTOURS_IMPLIED_POINTS)
            }
            
            if debugInstructions.contains(.Borders) {
                instructions.append(DEBUG_BORDER_CONTOURS)
            }
            
            return instructions
        }
    }
    
    public var mainRenderLayer: [ContoursInstructions] {
        var instructions: [ContoursInstructions] = []
        
        for i in 0..<glyph.contours.count {
            let glyphContours = glyph.contours[i]
            
            let coords = glyphContours.map { ContourPoint(x: toScale($0.x), y: toScale($0.y), onCurve: $0.flag.onCurve) }
            
            if coords.count == 0 {
                return [];
            }
            
            let debugColor = debugInstructions.contains(.Contours) ? getDebugColor(i) : .GRAY
            instructions.append(.init(origin: coords[0], points: coords, debugRenderOptions: .init(color: debugColor)))
        }

        return instructions
    }
    
    public var layers: [[ContoursInstructions]] {
        get {
            return [
                mainRenderLayer,
                debugLayer,
            ]
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
