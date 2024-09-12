//
//  FrContour.swift
//
//
//  Created by Jefferson Oliveira on 9/12/24.
//

import Foundation

public enum FrContourLayerType {
    case Main
    case Debug
}

public enum FrContourDirection {
    case Clockwise
    case CounterClockwise
}

public struct FrContour {
    let origin: FrPoint
    let points: [FrPoint]
    let direction: FrContourDirection
    let DEBUG__renderOptions: DEBUG__RenderOptions
    
    public func DEBUG__setStrokeColor(
        _ color: DEBUG__FrStrokeColors
    ) -> Self {
        .init(
            origin: origin,
            points: points,
            direction: direction,
            DEBUG__renderOptions: DEBUG__renderOptions.DEBUG__setColor(
                color
            )
        )
    }
    
    public func toScaled(
        by scale: Double
    ) -> Self {
        let newOrigin = origin.toScaled(
            by: scale
        )
        let newPoints = points.map {
            $0.toScaled(
                by: scale
            )
        }
        
        return .init(
            origin: newOrigin,
            points: newPoints,
            direction: direction,
            DEBUG__renderOptions: DEBUG__renderOptions
        )
    }
}
