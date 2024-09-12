//
//  FrPoint.swift
//
//
//  Created by Jefferson Oliveira on 9/12/24.
//

import Foundation

fileprivate func toCGPoint(
    _ frPoint: FrPoint
) -> CGPoint {
    .init(
        x: frPoint.x,
        y: frPoint.y
    )
}

fileprivate func clearPoint(
    _ frPoint: FrPoint
) -> FrPoint {
    let newX = Double(
        round(
            1000 * frPoint.x
        ) / 1000
    )
    let newY = Double(
        round(
            1000 * frPoint.y
        ) / 1000
    )
    
    return .init(
        x: newX,
        y: newY,
        onCurve: frPoint.onCurve
    )
}

fileprivate func scalePoint(
    _ frPoint: FrPoint,
    by scale: Double
) -> FrPoint {
    return .init(
        x: frPoint.x.toScaled(
            by: scale
        ),
        y: frPoint.y.toScaled(
            by: scale
        ),
        onCurve: frPoint.onCurve
    )
}

fileprivate func areEqual(
    lhs: FrPoint,
    rhs: FrPoint
) -> Bool {
    let areXEqual = lhs.x == rhs.x
    let areYEqual = lhs.y == rhs.y
    let areOnCurveEqual = lhs.onCurve == rhs.onCurve
    
    return areXEqual && areYEqual && areOnCurveEqual
}

fileprivate func isPointOnCurve(
    _ item: FrPoint
) -> Bool {
    item.onCurve
}

public struct FrPoint: Equatable {
    public let x: Double
    public let y: Double
    public var onCurve: Bool = false
    
    // MARK: x & y aliases
    public var width: Double {
        get {
            x
        }
    }
    public var height: Double {
        get {
            y
        }
    }
    
    public var a: Double {
        get {
            x
        }
    }
    public var b: Double {
        get {
            y
        }
    }
    
    public func cgPoint() -> CGPoint {
        toCGPoint(
            self
        )
    }
    
    public func cGFloatTuple() -> (CGFloat, CGFloat) {
        (x, y)
    }
    
    public func clean() -> Self {
        clearPoint(
            self
        )
    }
    public func toScaled(
        by scale: Double
    ) -> Self {
        scalePoint(
            self,
            by: scale
        )
    }
    
    public static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        areEqual(
            lhs: lhs,
            rhs: rhs
        )
    }
    
    public static func filterOnCurve(
        _ item: Self
    ) -> Bool {
        isPointOnCurve(
            item
        )
    }
}


extension Array where Element == FrPoint {
    func asCGPointArray() -> [CGPoint] {
        self.map {
            $0.cgPoint()
        }
    }
}

extension ArraySlice where Element == FrPoint {
    func asCGPointArray() -> [CGPoint] {
        self.map {
            $0.cgPoint()
        }
    }
    
    func asArray() -> [FrPoint] {
        var items: [FrPoint] = []
        items.append(
            contentsOf: self
        )
        return items
    }
}

extension Double {
    public func toScaled(
        by scale: Double
    ) -> Self {
        return Double(
            (
                self * scale
            ) * 1000 / 1000
        )
    }
}
