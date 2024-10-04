//
//  Render.swift
//
//
//  Created by Jefferson Oliveira on 9/12/24.
//

import FontLoader
import Foundation
import SwiftUI

enum RenderMode {
    case Both
    case Stroke
    case Fill

    public func toFrRenderMode(_ layer: FrContourLayerType) -> FrGlyphRenderMode {
        switch self {
        case .Both:
            return layer == .Main ? .Fill : .Stroke
        case .Stroke:
            return .Stroke
        case .Fill:
            return .Fill
        }
    }
}

extension Array {
    func getCircularIndex(at index: Int, offsetBy offset: Int = 0) -> Int {
        return (index + offset) % self.count
    }

    func getCircular(at index: Int, offsetBy offset: Int = 0) -> Element {
        let targetIndex = self.getCircularIndex(at: index, offsetBy: offset)

        return self[targetIndex]
    }
}

private func getFirstOnCurveIndex(from points: [FrPoint]) -> Int {
    for i in 0..<points.count {
        if points[i].onCurve {
            return i
        }
    }

    return 0
}

struct RenderHelper {
    public static func buildBezierPath(from layerPoints: [FrPoint], origin: FrPoint) -> Path {
        var path: Path = Path()

        path.move(to: origin.cgPoint())

        if layerPoints.count == 0 { return path }

        path.move(to: layerPoints[0].cgPoint())

        var i = 1

        var pointsStack: [FrPoint] = []

        while i < layerPoints.count {
            let curr = layerPoints[i]
            let prev = layerPoints[i - 1]

            if pointsStack.count == 2 {
                let a = pointsStack[1]
                let b = pointsStack[0]

                path.addQuadCurve(to: a.cgPoint(), control: b.cgPoint())

                pointsStack.removeAll()
            }

            if prev.onCurve && curr.onCurve {
                path.addLine(to: curr.cgPoint())
                i += 1
                continue
            }

            if prev.onCurve && !curr.onCurve {
                pointsStack.append(curr)
                i += 1
                continue
            }

            if !prev.onCurve && curr.onCurve {
                pointsStack.append(curr)
                i += 1
                continue
            }

            i += 1
        }

        if pointsStack.count == 1 {
            pointsStack.append(layerPoints[0])

            let a = pointsStack[1]
            let b = pointsStack[0]

            path.addQuadCurve(to: a.cgPoint(), control: b.cgPoint())

            pointsStack.removeAll()
        }

        return path
    }

    public static func buildFrGlyphPaths(
        fromlayer layer: FrRenderLayer, renderMode: RenderMode = .Both
    ) -> [FrGyphPath] {
        var instructions: [FrGyphPath] = []

        if layer.contours.count == 0 {
            return instructions
        }

        for i in 0..<layer.contours.count {
            let contour = layer.contours[i]
            var path = Path()

            path.move(to: contour.origin.cgPoint())

            if layer.layerType == .Main {
                path = RenderHelper.buildBezierPath(from: contour.points, origin: contour.origin)
            } else {
                path.addLines(contour.points.asCGPointArray())
            }

            instructions.append(
                .init(
                    path: path,
                    color: .color(DEBUG__toSUIColor(contour.DEBUG__renderOptions.color)),
                    style: contour.DEBUG__renderOptions.asStrokeStyle(),
                    direction: contour.direction,
                    renderMode: renderMode.toFrRenderMode(layer.layerType)
                )
            )
        }

        return instructions
    }

}
