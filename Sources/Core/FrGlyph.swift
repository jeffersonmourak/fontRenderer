//
//  FrGlyph.swift
//
//
//  Created by Jefferson Oliveira on 4/30/24.
//

import FontLoader
import Foundation
import SwiftUI

struct FrLayerInstruction {
    let path: Path
    let color: GraphicsContext.Shading
    let style: StrokeStyle
    let direction: FrContourDirection
}

public struct FrRenderLayer {
    var layerType: FrContourLayerType = .Main
    let contours: [FrContour]

    public func DEBUG__setLayerStrokeColor(_ color: DEBUG__FrStrokeColors) -> Self {
        let newContours = contours.map({ $0.DEBUG__setStrokeColor(color) })

        return .init(layerType: layerType, contours: newContours)
    }

    public func toScaled(by scale: Double) -> Self {
        let newContours = contours.map { $0.toScaled(by: scale) }

        return .init(layerType: layerType, contours: newContours)
    }
}

extension Array where Element == FrRenderLayer {
    func toScaled(by scale: Double) -> [FrRenderLayer] {
        self.map { $0.toScaled(by: scale) }
    }
}

private func calcDotProduct(_ a: FrPoint, _ b: FrPoint) -> Double {
    a.x * b.x + a.y * b.y
}

class FrGlyph {
    let glyph: Glyph
    private var DEBUG__overlayOptions: [DEBUG__FrOverlayOptions]

    init(from inputGlyph: Glyph, scale: Double = 0, debug: [DEBUG__FrOverlayOptions] = []) {
        self.glyph = inputGlyph
        self.DEBUG__overlayOptions = debug
    }

    private func getPointFoldingDirection(_ points: [FrPoint]) -> FrContourDirection {
        if points.count < 2 { return .Clockwise }

        var directionSum: Double = 0

        for i in 1..<points.count {
            let a = points[i - 1]
            let b = points[i]

            let directionOffset = (b.x - a.x) * (b.y + a.y)

            directionSum += directionOffset

        }

        return directionSum > 0 ? .Clockwise : .CounterClockwise
    }

    private func buildMainRenderContours() -> [FrContour] {
        var mainContours: [FrContour] = []

        for i in 0..<glyph.contours.count {
            let contour = glyph.contours[i]

            let coords = contour.map {
                FrPoint(x: $0.x, y: $0.y, onCurve: $0.flag.onCurve)
            }

            if coords.count == 0 {
                return []
            }

            let debugColor =
                DEBUG__overlayOptions.contains(.ColorContoursOverlay)
                ? DEBUG__getColor(i)
                : .GRAY

            mainContours.append(
                .init(
                    origin: coords[0],
                    points: coords,
                    direction: getPointFoldingDirection(coords),
                    DEBUG__renderOptions: .init(color: debugColor)
                )
            )
        }

        return mainContours
    }

    public var mainLayer: FrRenderLayer {
        .init(contours: buildMainRenderContours())
    }

    public var layers: [FrRenderLayer] {
        [
            mainLayer,
            DEBUG__BuildDebugLayer(
                glyph: glyph,
                debugInstructions: DEBUG__overlayOptions,
                mainLayer: .init(contours: buildMainRenderContours())
            ),
        ]
    }

    public var width: Double {
        Double(glyph.layout.width - 50)
    }

    public var height: Double {
        glyph.layout.height - Double(glyph.layout.horizontalMetrics.descent)
    }

    public func DEBUG__SetDebugOptions(_ options: [DEBUG__FrOverlayOptions]) {
        self.DEBUG__overlayOptions = options
    }
}
