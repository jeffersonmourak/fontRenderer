//
//  SharedGlyphView.swift
//
//
//  Created by Jefferson Oliveira on 5/9/24.
//

import Foundation
import SwiftUI
import FontLoader

struct RenderStrokeOptions {
    var color: Color
    var width: CGFloat
}

fileprivate let DEFAULT_GLYPH_STROKE_OPTIONS: RenderStrokeOptions = .init(
    color: .gray,
    width: 2
)
fileprivate let DEFAULT_OUTLINE_STROKE_OPTIONS: RenderStrokeOptions = .init(
    color: .purple,
    width: 4
)

struct RenderGlyphOptions {
    var glyph: RenderStrokeOptions
    var outline: RenderStrokeOptions
    
    public static func create(
        usingGlyph glyph: RenderStrokeOptions = DEFAULT_GLYPH_STROKE_OPTIONS,
        usingOutline outline: RenderStrokeOptions = DEFAULT_OUTLINE_STROKE_OPTIONS
    ) -> RenderGlyphOptions {
        
        return .init(
            glyph: glyph,
            outline: outline
        )
    }
}

//        let capH = (upm - (ascender - lineGap)) * scale
//        let baseL = ((upm - ascender) + lineGap + sCapHeight) * scale
//        let des = (descender / upm)

struct StrokeIntruction {
    let path: Path
    let color: GraphicsContext.Shading
    let style: StrokeStyle
    let direction: FrContourDirection
}

func makeStrokes(
    fromlayer layer: FrRenderLayer,
    DEBUG_mainLayerMaxPoints: [Double] = []
) -> [StrokeIntruction] {
    var instructions: [StrokeIntruction] = []
    
    if layer.contours.count == 0 {
        return instructions
    }
    
    for i in 0..<layer.contours.count {
        let contour = layer.contours[i]
        var path = Path()
        
        path.move(
            to: contour.origin.cgPoint()
        )
        
        if layer.layerType == .Main {
            let points = DEBUG_mainLayerMaxPoints.count > 0 ? contour.points[0..<Int(
                DEBUG_mainLayerMaxPoints[i]
            )].asArray() : contour.points
            
            path = breakdownBezierSegments(
                from: points,
                origin: contour.origin
            )
        } else {
            path.addLines(
                contour.points.asCGPointArray()
            )
        }
        
        instructions.append(
            .init(
                path: path,
                color: .color(
                    DEBUG__toSUIColor(
                        contour.DEBUG__renderOptions.color
                    )
                ),
                style: contour.DEBUG__renderOptions.asStrokeStyle(),
                direction: contour.direction
            )
        )
    }
    
    return instructions
}

extension CGPoint : Hashable {
    public func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(
            x
        )
        hasher.combine(
            y
        )
    }
}

func pointsCleanup(
    _ points: [FrPoint]
) -> [FrPoint] {
    let onCurve = points.filter(
        FrPoint.filterOnCurve
    ).map {
        $0.cgPoint()
    }
    
    var cleanPoints: [FrPoint] = []
    var visitedPoints: [CGPoint] = []
    
    
    for i in 0..<points.count {
        let currI = (
            i + 0
        ) % points.count
        let nextI = (
            i + 1
        ) % points.count
        
        let curr = points[currI].clean()
        let next = points[nextI].clean()
        
        if curr.cgPoint() == next.cgPoint() {
            if !visitedPoints.contains(
                curr.cgPoint()
            ) {
                if onCurve.contains(
                    curr.cgPoint()
                ) {
                    cleanPoints.append(
                        .init(
                            x: curr.x,
                            y: curr.y,
                            onCurve: true
                        )
                    )
                    visitedPoints.append(
                        curr.cgPoint()
                    )
                } else {
                    cleanPoints.append(
                        curr
                    )
                    visitedPoints.append(
                        curr.cgPoint()
                    )
                }
            }
        }
        
        if !curr.onCurve && onCurve.contains(
            curr.cgPoint()
        ) {
            cleanPoints.append(
                .init(
                    x: curr.x,
                    y: curr.y,
                    onCurve: true
                )
            )
        } else {
            cleanPoints.append(
                curr
            )
        }
        visitedPoints.append(
            curr.cgPoint()
        )
    }
    
    if cleanPoints.first != nil {
        cleanPoints.append(
            cleanPoints.first!
        )
    }
    
    
    
    return cleanPoints
}

func breakdownBezierSegments(
    from allPoints: [FrPoint],
    origin: FrPoint
) -> Path {
    var path: Path = Path()
    
    path.move(
        to: origin.cgPoint()
    )
    
    let cleanPoints = pointsCleanup(
        allPoints
    )
    
    if cleanPoints.count == 0 {
        return path;
    }
    
    var firstOnCurvePointIndex: Int = 0
    
    for i in 0..<cleanPoints.count {
        if cleanPoints[i].onCurve {
            firstOnCurvePointIndex = i
            break
        }
    }
    
    var segments: [[FrPoint]] = []
    var currentSegment: [FrPoint] = []
    
    for i in 0..<cleanPoints.count {
        let currI = (
            i + firstOnCurvePointIndex + 0
        ) % cleanPoints.count
        let nextI = (
            i + firstOnCurvePointIndex + 1
        ) % cleanPoints.count
        
        let curr = cleanPoints[currI]
        let next = cleanPoints[nextI]
        
        if curr.onCurve && next.onCurve {
            var segment = [
                next,
                curr
            ]
            segment.append(
                contentsOf: currentSegment
            )
            segments.append(
                segment
            )
        }
        
        if curr.onCurve && !next.onCurve {
            currentSegment.append(
                curr
            )
        }
        
        if !curr.onCurve && next.onCurve {
            var segment = [
                next,
                curr
            ]
            segment.append(
                contentsOf: currentSegment
            )
            segments.append(
                segment
            )
            currentSegment.removeAll()
        }
    }
    
    for segment in segments {
        if segment.count == 2 {
            path.move(
                to: segment[0].cgPoint()
            )
            path.addLine(
                to: segment[1].cgPoint()
            )
        }
        
        if segment.count == 3 {
            let a = segment[0]
            let b = segment[1]
            
            path.addQuadCurve(
                to: a.cgPoint(),
                control: b.cgPoint()
            )
        }
    }
    
    
    path.addLine(
        to: origin.cgPoint()
    )
    
    return path
}

func prettyPrintSegments(
    _ segments: [[FrPoint]]
) {
    print(
        "Total \(segments.count)"
    )
    
    for sI in 0..<segments.count {
        print(
            "Segment \(sI)"
        )
        
        let segment = segments[sI]
        
        for pI in 0..<segment.count {
            let point = segment[pI]
            
            print(
                "- \(point)"
            )
        }
    }
}

func getFillColorFromDebug(debugLevels: [DEBUG__FrOverlayOptions]) -> Color {
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

struct SharedGlyphView: View {
    var glyph: Glyph
    var scale: Double = 1
    var fontHeight: Double
    var renderOptions: RenderGlyphOptions = RenderGlyphOptions.create()
    @Binding var debugLevels: [DEBUG__FrOverlayOptions]
    @State var contourLayer: Int = 0
    @State var DEBUG_mainLayerMaxPoints: [Double] = []
    
    var path = Path()
    
    var body: some View {
        let fontGlyph = FrGlyph(
            from: glyph,
            scale: scale,
            debug: debugLevels
        )
        
        let computedAmounts = Binding<[Double]>(get: {
            if !debugLevels.contains(
                .SteppedPointsOverlay
            ) {
                return fontGlyph.mainLayer.contours.map { c in
                    return Double(
                        c.points.count
                    )
                }
            }
            
            if DEBUG_mainLayerMaxPoints.count == 0 {
                let localAmounts = fontGlyph.mainLayer.contours.map { c in
                    //                    return Double(c.points.count)
                    return 0.0
                }
                
                DEBUG_mainLayerMaxPoints = localAmounts
                return localAmounts
            }
            
            return DEBUG_mainLayerMaxPoints
        },
                                                set: { val in
            DEBUG_mainLayerMaxPoints = val
        })
        
        VStack {
            Canvas {
                context,
                size in
                for layer in fontGlyph.layers {
                    let scaled = layer.toScaled(by: scale)
                    var strokes: [StrokeIntruction] = []
                    
                    if scaled.layerType == .Main {
                        strokes = makeStrokes(
                            fromlayer: scaled,
                            DEBUG_mainLayerMaxPoints: DEBUG_mainLayerMaxPoints
                        )
                    } else {
                        strokes = makeStrokes(
                            fromlayer: scaled
                        )
                    }
                                        
                    for instruction in strokes {
                        if scaled.layerType == .Main {
                            context.blendMode = .xor
                            
                            context.fill(
                                instruction.path,
                                with: .color(getFillColorFromDebug(debugLevels: debugLevels))
                            )
                            context.blendMode = .normal
                        } else {
                            context.stroke(
                                instruction.path,
                                with: instruction.color,
                                style: instruction.style
                            )
                        }
                    }
                }
            }.frame(
                width: fontGlyph.width.toScaled(by: scale),
                height: fontGlyph.height.toScaled(by: scale)
            )
            
            if debugLevels.contains(
                .SteppedPointsOverlay
            ) {
                VStack {
                    Stepper(
                        "Contour #\(contourLayer + 1)",
                        value: $contourLayer,
                        in: 0...fontGlyph.mainLayer.contours.count - 1
                    )
                    Slider(
                        value: computedAmounts[contourLayer],
                        in: 0...Double(
                            fontGlyph.mainLayer.contours[contourLayer].points.count
                        ),
                        step: 1
                    )
                }
            }
        }
    }
}
