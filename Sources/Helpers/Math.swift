//
//  Math.swift
//
//
//  Created by Jefferson Oliveira on 9/12/24.
//

import Foundation
import FontLoader

struct FontMath {
    public static func ptDistance(
        _ a: FrPoint,
        _ b: FrPoint
    ) -> (
        CGFloat,
        CGFloat
    ) {
        let (
            aX,
            aY
        ) = a.cGFloatTuple()
        let (
            bX,
            bY
        ) = b.cGFloatTuple()
        
        let xDis = bX - aX
        let yDis = bY - aY
        
        return (
            xDis,
            yDis
        )
    }
}
