//
//  FrPoint.swift
//
//
//  Created by Jefferson Oliveira on 9/12/24.
//

import Foundation

private func toCGPoint(_ frPoint: FrPoint) -> CGPoint {
    .init(x: frPoint.x, y: frPoint.y)
}

private func clearPoint(_ frPoint: FrPoint) -> FrPoint {
    let newX = Double(round(1000 * frPoint.x) / 1000)
    let newY = Double(round(1000 * frPoint.y) / 1000)

    return .init(x: newX, y: newY, onCurve: frPoint.onCurve)
}

private func scalePoint(_ frPoint: FrPoint, by scale: Double) -> FrPoint {
    return .init(
        x: frPoint.x.toScaled(by: scale),
        y: frPoint.y.toScaled(by: scale),
        onCurve: frPoint.onCurve
    )
}

private func areEqual(lhs: FrPoint, rhs: FrPoint) -> Bool {
    let areXEqual = lhs.x == rhs.x
    let areYEqual = lhs.y == rhs.y
    let areOnCurveEqual = lhs.onCurve == rhs.onCurve

    return areXEqual && areYEqual && areOnCurveEqual
}

private func isPointOnCurve(_ item: FrPoint) -> Bool {
    item.onCurve
}

public struct FrPoint: Equatable {
    public let x: Double
    public let y: Double
    public var onCurve: Bool = false

    init(x: Double, y: Double, onCurve: Bool = false) {
        self.x = x
        self.y = y
        self.onCurve = onCurve
    }

    init(from: CGPoint, onCurve: Bool = false) {
        self.init(x: from.x, y: from.y, onCurve: onCurve)
    }

    init(from: FrPoint, onCurve: Bool = false) {
        self.init(x: from.x, y: from.y, onCurve: onCurve)
    }

    init(from: FrPoint, x: Double) {
        self.init(x: x, y: from.y, onCurve: from.onCurve)
    }

    init(from: FrPoint, y: Double) {
        self.init(x: from.x, y: y, onCurve: from.onCurve)
    }

    init(from: FrPoint, x: Double, onCurve: Bool = false) {
        self.init(x: x, y: from.y, onCurve: from.onCurve)
    }

    init(from: FrPoint, y: Double, onCurve: Bool = false) {
        self.init(x: from.x, y: y, onCurve: from.onCurve)
    }

    init(from: FrPoint, x: Double, y: Double) {
        self.init(x: x, y: y, onCurve: from.onCurve)
    }

    init(from: FrPoint, x: Double, y: Double, onCurve: Bool = false) {
        self.init(x: x, y: y, onCurve: onCurve)
    }

    // MARK: x & y aliases
    public var width: Double { x }

    public var height: Double { y }

    public var a: Double { x }

    public var b: Double { y }

    public func cgPoint() -> CGPoint { toCGPoint(self) }

    public func cGFloatTuple() -> (CGFloat, CGFloat) { (x, y) }

    public func clean() -> Self { clearPoint(self) }

    public func toScaled(by scale: Double) -> Self { scalePoint(self, by: scale) }

    public static func == (lhs: Self, rhs: Self) -> Bool { areEqual(lhs: lhs, rhs: rhs) }

    public static func filterOnCurve(_ item: Self) -> Bool { isPointOnCurve(item) }
}

extension Array where Element == FrPoint {
    func asCGPointArray() -> [CGPoint] {
        self.map { $0.cgPoint() }
    }
}

extension ArraySlice where Element == FrPoint {
    func asCGPointArray() -> [CGPoint] {
        self.map { $0.cgPoint() }
    }

    func asArray() -> [FrPoint] {
        var items: [FrPoint] = []
        items.append(contentsOf: self)
        return items
    }
}

extension Double {
    public func toScaled(by scale: Double) -> Self {
        return (self * scale) * 1000 / 1000
    }
}
