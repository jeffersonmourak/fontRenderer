//
//  FrGlyph.swift
//
//
//  Created by Jefferson Oliveira on 4/30/24.
//

import Foundation
import FontLoader
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


class FrGlyph {
    let glyph: Glyph
    private var DEBUG__overlayOptions: [DEBUG__FrOverlayOptions]
    
    init (from inputGlyph: Glyph, scale: Double = 0, debug: [DEBUG__FrOverlayOptions] = []) {
        self.glyph = inputGlyph
        self.DEBUG__overlayOptions = debug
    }
    
    private func getPointFoldingDirection(_ points: [FrPoint]) -> FrContourDirection {
        if points.count < 2 { return .Clockwise }
        
        for i in 0..<points.count {
            let a1 = points.getCircular(at: i)
            let b2 = points.getCircular(at: i + 1)
            let c3 = points.count > 2 ? points.getCircular(at: i + 2) : points[0]
            
            let A = (b2.x * a1.y) + (c3.x * b2.y) + (a1.x * c3.y)
            let B = (a1.x * b2.y) + (b2.x * c3.y) + (c3.x * a1.y)
            
            if A != B {
                return A > B ? .Clockwise : .CounterClockwise
            }
        }
        
        return .CounterClockwise
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
            
            let debugColor = DEBUG__overlayOptions.contains(.ColorContoursOverlay) 
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
        get { .init(contours: buildMainRenderContours()) }
    }
    
    public var layers: [FrRenderLayer] {
        get {
            [
                mainLayer,
                DEBUG__BuildDebugLayer(
                    glyph: glyph,
                    debugInstructions: DEBUG__overlayOptions,
                    mainLayer: .init(contours: buildMainRenderContours())
                ),
            ]
        }
    }
    
    public var width: Double {
        get { Double(glyph.layout.width - 50) }
    }
    
    public var height: Double {
        get { glyph.layout.height - Double(glyph.layout.horizontalMetrics.descent) }
    }

    public func DEBUG__SetDebugOptions(_ options: [DEBUG__FrOverlayOptions]) {
        self.DEBUG__overlayOptions = options
    }
}
