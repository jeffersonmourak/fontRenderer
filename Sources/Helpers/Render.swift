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

private func buildSegments(from points: [FrPoint]) -> [[FrPoint]] {
    var segments: [[FrPoint]] = []
    var currentSegment: [FrPoint] = []
    let offsetBy = getFirstOnCurveIndex(from: points)

    for i in 0..<points.count {
        let curr = points.getCircular(at: i, offsetBy: offsetBy)
        let next = points.getCircular(at: i + 1, offsetBy: offsetBy)

        if curr.onCurve && next.onCurve {
            var segment = [next, curr]
            segment.append(contentsOf: currentSegment)
            segments.append(segment)
            continue
        }

        if curr.onCurve && !next.onCurve {
            currentSegment.append(curr)
            continue
        }

        if !curr.onCurve && next.onCurve {
            var segment = [next, curr]
            segment.append(contentsOf: currentSegment)
            segments.append(segment)

            currentSegment.removeAll()
            continue
        }
    }

    return segments
}

struct RenderHelper {
    public static func buildBezierPath(from layerPoints: [FrPoint], origin: FrPoint) -> Path {
        var path: Path = Path()

        path.move(to: origin.cgPoint())

        if layerPoints.count == 0 { return path }

        for segment in buildSegments(from: layerPoints[0..<layerPoints.count].asArray()) {
            // print(segment)
            // print("####")
            if segment.count == 2 {
                path.addLine(to: segment[1].cgPoint())
                // path.move(to: segment[0].cgPoint())
            }

            if segment.count == 3 {
                let a = segment[0]
                let b = segment[1]
                let c = segment[2]

                path.addQuadCurve(to: a.cgPoint(), control: b.cgPoint())
                // path.move(to: c.cgPoint())
            }
        }

        // print(layerPoints.last)

        path.addLine(to: origin.cgPoint())

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
