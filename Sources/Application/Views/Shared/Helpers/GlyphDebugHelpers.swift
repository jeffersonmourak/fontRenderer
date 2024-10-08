//
//  GlyphDebugHelpers.swift
//
//
//  Created by Jefferson Oliveira on 9/11/24.
//

import FontLoader
import Foundation
import SwiftUI

enum DEBUG__FrOverlayOptions: Equatable {
    case ColorContoursOverlay
    case BaselineOverlay
    case RealPointsOverlay
    case ImpliedPointsOverlay
    case PointsOutlineOverlay
    case FontColorOverlay(color: Color)
    case MainLayerOutlineOverlay
    case GridOverlay
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
    .GRAY,
]

struct DEBUG__RenderOptions {
    let color: DEBUG__FrStrokeColors
    var width: CGFloat = 2
    var lineCap: CGLineCap = .butt
    var lineJoin: CGLineJoin = .miter

    public func DEBUG__setColor(_ color: DEBUG__FrStrokeColors) -> Self {
        .init(color: color, width: width, lineCap: lineCap, lineJoin: lineJoin)
    }

    public func asStrokeStyle() -> StrokeStyle {
        StrokeStyle(lineWidth: width, lineCap: lineCap, lineJoin: lineJoin)
    }
}

func getContourBoundary(points: [GlyphPoint]) -> ((CGFloat, CGFloat), (CGFloat, CGFloat)) {
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

func DEBUG__getColor(_ index: Int) -> DEBUG__FrStrokeColors {
    DEBUG__COLORS[(index + DEBUG__COLORS.count) % DEBUG__COLORS.count]
}

func DEBUG__getPointColor(_ point: GlyphPoint, _ index: Int, _ count: Int) -> DEBUG__FrStrokeColors
{
    if count - 1 == index { return .PURPLE }
    if index == 1 { return .ORANGE }
    return point.flag.onCurve ? .GREEN : .YELLOW
}

func DEBUG__toSUIColor(_ input: DEBUG__FrStrokeColors) -> Color {
    switch input {
    case .RED: .red
    case .GREEN: .green
    case .BLUE: .blue
    case .YELLOW: .yellow
    case .PURPLE: .purple
    case .BROWN: .brown
    case .CYAN: .cyan
    case .ORANGE: .orange
    case .GRAY: .gray
    case .PINK: .pink
    case .INDIGO: .indigo
    }
}

func makeHorizontalLineContour(_ y: CGFloat, _ width: CGFloat) -> FrContour {
    let a = FrPoint(x: 0, y: y)
    let b = FrPoint(x: width, y: y)
    return FrContour(
        origin: a, points: [a, b], direction: .Clockwise,
        DEBUG__renderOptions: .init(color: DEBUG__FrStrokeColors.INDIGO))

}

func makeVerticalLineContour(_ x: CGFloat, _ height: CGFloat) -> FrContour {
    let a = FrPoint(x: x, y: 0)
    let b = FrPoint(x: x, y: height)
    return FrContour(
        origin: a, points: [a, b], direction: .Clockwise,
        DEBUG__renderOptions: .init(color: DEBUG__FrStrokeColors.INDIGO))
}

func DEBUG__BuildDebugLayer(
    glyph: Glyph, debugInstructions: [DEBUG__FrOverlayOptions], mainLayer: FrRenderLayer
) -> FrRenderLayer {
    let mainDebugLayer = mainLayer.DEBUG__setLayerStrokeColor(.PINK)

    var DEBUG_HORIZONTAL_LINES: [FrContour] {
        return [
            makeHorizontalLineContour(0, glyph.layout.width),
            makeHorizontalLineContour(
                glyph.layout.height, glyph.layout.width),
            makeHorizontalLineContour(
                glyph.layout.baseline, glyph.layout.width),
        ]
    }

    var DEBUG_VERTICAL_LINES: [FrContour] {
        return [
            makeVerticalLineContour(
                0, glyph.layout.height),
            makeVerticalLineContour(
                glyph.layout.width, glyph.layout.height),
            makeVerticalLineContour(
                CGFloat(glyph.horizontalMetrics.leftSideBearing), glyph.layout.height),
            makeVerticalLineContour(
                CGFloat(glyph.horizontalMetrics.advanceWidth), glyph.layout.height),
        ]
    }

    var DEBUG_CONTOURS_POINTS: [FrContour] {
        var pointInstructions: [FrContour] = []

        for contour in glyph.contours {
            for i in 0..<contour.count {
                let point = contour[i]
                let contourPoint = point.cGPoint()
                let points: [FrPoint] = [FrPoint(from: contourPoint), FrPoint(from: contourPoint)]

                if point.isImplied { continue }

                pointInstructions.append(
                    .init(
                        origin: points[0],
                        points: points,
                        direction: .Clockwise,
                        DEBUG__renderOptions: .init(
                            color: DEBUG__getPointColor(point, i, contour.count), width: 8,
                            lineCap: .round, lineJoin: .round)
                    )
                )
            }
        }

        return pointInstructions
    }

    var DEBUG_CONTOURS_IMPLIED_POINTS: [FrContour] {
        var pointInstructions: [FrContour] = []

        for contour in glyph.contours {
            for i in 0..<contour.count {
                let point = contour[i]
                let contourPoint = point.cGPoint()
                let points: [FrPoint] = [FrPoint(from: contourPoint), FrPoint(from: contourPoint)]

                if !point.isImplied { continue }

                pointInstructions.append(
                    .init(
                        origin: points[0],
                        points: points,
                        direction: .Clockwise,
                        DEBUG__renderOptions: .init(
                            color: DEBUG__getPointColor(point, i, contour.count), width: 8,
                            lineCap: .round, lineJoin: .round)
                    )
                )
            }
        }

        return pointInstructions
    }

    var instructions: [FrContour] =
        debugInstructions.contains(.PointsOutlineOverlay) ? mainDebugLayer.contours : []

    if debugInstructions.contains(.BaselineOverlay) {
        instructions.append(contentsOf: DEBUG_HORIZONTAL_LINES)
        instructions.append(contentsOf: DEBUG_VERTICAL_LINES)
    }

    if debugInstructions.contains(.RealPointsOverlay) {
        instructions.append(contentsOf: DEBUG_CONTOURS_POINTS)
    }

    if debugInstructions.contains(.ImpliedPointsOverlay) {
        instructions.append(contentsOf: DEBUG_CONTOURS_IMPLIED_POINTS)
    }

    return FrRenderLayer(layerType: .Debug, contours: instructions)
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
