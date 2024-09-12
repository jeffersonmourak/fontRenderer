//
//  GlyphDebugHelpers.swift
//
//
//  Created by Jefferson Oliveira on 9/11/24.
//

import Foundation
import FontLoader
import SwiftUI

enum DEBUG__FrOverlayOptions: Equatable {
    case ColorContoursOverlay
    case BaselineOverlay
    case BoundBoxOverlay
    case RealPointsOverlay
    case ImpliedPointsOverlay
    case SteppedPointsOverlay
    case FontColorOverlay(color: Color)
}

public enum DEBUG__FrStrokeColors {
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

let DEBUG__COLORS: [DEBUG__FrStrokeColors] = [
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

struct DEBUG__RenderOptions {
    let color: DEBUG__FrStrokeColors
    var width: CGFloat = 2
    var lineCap: CGLineCap = .butt
    var lineJoin: CGLineJoin = .miter
    
    public func DEBUG__setColor(
        _ color: DEBUG__FrStrokeColors
    ) -> Self { .init(color: color, width: width, lineCap: lineCap, lineJoin: lineJoin) }
    
    public func asStrokeStyle() -> StrokeStyle {
        StrokeStyle(lineWidth: width, lineCap: lineCap, lineJoin: lineJoin)
    }
}

func getContourBoundary(points: [GlyphPoint]) -> (
    (CGFloat, CGFloat),
    (CGFloat, CGFloat)
) {
    var minX = points[0].x
    var maxX = points[0].x
    var minY = points[0].y
    var maxY = points[0].y
    
    for point in points {
        if point.x < minX { minX = point.x }
        if point.x > maxX { maxX = point.x }
        
        if point.y < minY { minY = point.y }
        
        if point.y > maxY { maxY = point.y }
    }
    
    return ((minX, minY), (maxX, maxY))
}

func getContoursBoundaries(contours: [[GlyphPoint]]) -> ((CGFloat, CGFloat), (CGFloat, CGFloat)) {
    var ((minX, minY), (maxX, maxY)) = getContourBoundary(points: contours[0])
    
    for points in contours {
        let ((cMinX, cMinY), (cMaxX, cMaxY)) = getContourBoundary(points: points)
        
        if cMinX < minX { minX = cMinX }
        if cMaxX > maxX { maxX = cMaxX }
        
        if cMinY < minY { maxY = cMinY }
        
        if cMaxY > maxY { maxY = cMaxY }
    }
    
    return ((minX, minY), (maxX, maxY))
}


func DEBUG__getColor(_ index: Int) -> DEBUG__FrStrokeColors { DEBUG__COLORS[(index + DEBUG__COLORS.count) % DEBUG__COLORS.count] }

func DEBUG__getPointColor(_ point: GlyphPoint, _ index: Int, _ count: Int) -> DEBUG__FrStrokeColors {
    if count - 1 == index {
        return .PINK
    }
    
    if index == 1 {
        return .INDIGO
    }
    
    return point.flag.onCurve ? .GREEN : .YELLOW
}

func DEBUG__toSUIColor(_ input: DEBUG__FrStrokeColors) -> Color {
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


func DEBUG__BuildDebugLayer(glyph: Glyph, debugInstructions: [DEBUG__FrOverlayOptions], mainLayer: FrRenderLayer) -> FrRenderLayer {
    
    let mainDebugLayer = mainLayer.DEBUG__setLayerStrokeColor(.PINK)
    
    var DEBUG_BASELINE_CONTOURS: FrContour {
        get {
            let a: FrPoint = .init(x: 0, y: glyph.layout.height)
            let b: FrPoint = .init(x: glyph.layout.width, y: glyph.layout.height)
            return .init(origin: a, points: [a, b], direction: .Clockwise, DEBUG__renderOptions: .init(color: DEBUG__FrStrokeColors.INDIGO))
        }
    }
    
    var DEBUG_BORDER_CONTOURS: FrContour {
        get {
            
            let ((minX, minY), (maxX, maxY)) = getContoursBoundaries(contours: glyph.contours)
            
            let tl: FrPoint = .init(x: minX, y: minY)
            let tr: FrPoint = .init(x: maxX, y: minY)
            let br: FrPoint = .init(x: maxX, y: maxY)
            let bl: FrPoint = .init(x: minX, y: maxY)
            return .init(origin: tl, points: [tl, tr, br, bl, tl], direction: .Clockwise, DEBUG__renderOptions: .init(color: DEBUG__FrStrokeColors.PINK))
        }
    }
    
    var DEBUG_CONTOURS_POINTS: [FrContour] {
        get {
            var pointInstructions: [FrContour] = []
            
            for contour in glyph.contours {
                for i in 0..<contour.count {
                    let point = contour[i]
                    let contourPoint = point.cGPoint()
                    let points: [FrPoint] = [
                        .init(x: contourPoint.x,y: contourPoint.y),
                        .init(x: contourPoint.x,y: contourPoint.y)
                    ]
                    
                    if point.isImplied { continue }
                    
                    pointInstructions.append(
                        .init(
                            origin: points[0],
                            points: points,
                            direction: .Clockwise,
                            DEBUG__renderOptions: .init(color: DEBUG__getPointColor(point, i, contour.count), width: 8, lineCap: .round, lineJoin: .round)
                        )
                    )
                }
            }
            
            return pointInstructions
        }
    }
    
    var DEBUG_CONTOURS_IMPLIED_POINTS: [FrContour] {
        get {
            
            var pointInstructions: [FrContour] = []
            
            for contour in glyph.contours {
                for i in 0..<contour.count {
                    let point = contour[i]
                    let contourPoint = point.cGPoint()
                    let points: [FrPoint] = [
                        .init(x: contourPoint.x, y: contourPoint.y),
                        .init(x: contourPoint.x, y: contourPoint.y)
                    ]
                    
                    if !point.isImplied { continue }
                    
                    pointInstructions.append(
                        .init(
                            origin: points[0],
                            points: points,
                            direction: .Clockwise,
                            DEBUG__renderOptions: .init(color: DEBUG__getPointColor(point, i, contour.count), width: 8, lineCap: .round, lineJoin: .round)
                        )
                    )
                }
            }
            
            return pointInstructions
        }
    }
    
    var debugLayer: FrRenderLayer {
        get {
            var instructions: [FrContour] = debugInstructions.contains(.SteppedPointsOverlay) ? mainDebugLayer.contours : []
            
            if debugInstructions.contains(.BaselineOverlay) {
                instructions.append(DEBUG_BASELINE_CONTOURS)
            }
            
            if debugInstructions.contains(.RealPointsOverlay) {
                instructions.append(contentsOf: DEBUG_CONTOURS_POINTS)
            }
            
            if debugInstructions.contains(.ImpliedPointsOverlay) {
                instructions.append(contentsOf: DEBUG_CONTOURS_IMPLIED_POINTS)
            }
            
            if debugInstructions.contains(.BoundBoxOverlay) {
                instructions.append(DEBUG_BORDER_CONTOURS)
            }
            
            return .init(layerType: .Debug, contours: instructions)
        }
    }
    
    return debugLayer
}

func DEBUG_getGlyphFillColor(debugLevels: [DEBUG__FrOverlayOptions]) -> Color {
    for debugLevel in debugLevels {
        switch debugLevel {
        case let .FontColorOverlay(color):
            return color
        default:
            continue
        }
    }
    
    return .white
}
