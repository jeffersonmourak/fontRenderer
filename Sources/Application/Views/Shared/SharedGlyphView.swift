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

fileprivate let DEFAULT_GLYPH_STROKE_OPTIONS: RenderStrokeOptions = .init(color: .gray, width: 2)
fileprivate let DEFAULT_OUTLINE_STROKE_OPTIONS: RenderStrokeOptions = .init(color: .purple, width: 4)

struct RenderGlyphOptions {
    var glyph: RenderStrokeOptions
    var outline: RenderStrokeOptions
    
    public static func create(
        usingGlyph glyph: RenderStrokeOptions = DEFAULT_GLYPH_STROKE_OPTIONS,
        usingOutline outline: RenderStrokeOptions = DEFAULT_OUTLINE_STROKE_OPTIONS) -> RenderGlyphOptions {
        
        return .init(glyph: glyph, outline: outline)
    }
}

//        let capH = (upm - (ascender - lineGap)) * scale
//        let baseL = ((upm - ascender) + lineGap + sCapHeight) * scale
//        let des = (descender / upm)

struct SharedGlyphView: View {
    var glyph: Glyph
    var scale: Double = 1
    var fontHeight: Double
    var renderOptions: RenderGlyphOptions = RenderGlyphOptions.create()
    @Binding var debugLevels: [DebugLevel]
    @State var contourLayer: Int = 0
    @State var amounts: [Double] = []
    
    var path = Path()
    
    let colors: [Color] = [
        .red,
        .green,
        .blue,
        .yellow,
        .purple,
        .brown,
        .cyan,
        .orange,
        .gray,
    ]
    
    func getContourColor(_ input: DebugColors) -> Color {
        switch input {
        case .RED :
            .red
        case .GREEN :
            .green
        case .BLUE :
            .blue
        case .YELLOW :
            .yellow
        case .PURPLE :
            .purple
        case .BROWN :
            .brown
        case .CYAN :
            .cyan
        case .ORANGE :
            .orange
        case .GRAY :
            .gray
        case .PINK :
            .pink
        case .INDIGO:
            .indigo
        }
    }
    
    var body: some View {
        let fontGlyph = FontGlyphContours(from: glyph, scale: scale, debug: debugLevels)
        
        let computedAmounts = Binding<[Double]>(get: {
            
            if !debugLevels.contains(.SteppedPoints) {
                return fontGlyph.layers[0].map { c in
                    return Double(c.points.count)
                }
            }
            
            if amounts.count == 0 {
                let localAmounts = fontGlyph.mainRenderLayer.map { c in
//                    return Double(c.points.count)
                    return 0.0
                }
                
                amounts = localAmounts
                return localAmounts
            }
            
            return amounts
        }, set: { val in
            amounts = val
        })
        
        VStack {
            Canvas { context, size in
                var path = Path()
                for i in 0..<fontGlyph.mainRenderLayer.count {
                    let contour = fontGlyph.mainRenderLayer[i]
                    
                    breakdownBezierSegments(from: contour)
                    
                    path = Path()
                    path.move(to: contour.origin.cgPoint())
                    
                    var points: [CGPoint] = []
                    
                    if contour.renderLayer == .Debug {
                        points = contour.points.asCGPointArray()
                    } else {
                        points.append(contentsOf: contour.points.asCGPointArray()[0..<Int(computedAmounts[i].wrappedValue)])
                    }
                    
                    path.addLines(points)
                    
                    context.stroke(
                        path,
                        with: .color(getContourColor(contour.debugRenderOptions.color)),
                        style: contour.debugRenderOptions.asStrokeStyle()
                    )
                }
                
                for i in 0..<fontGlyph.debugLayer.count {
                    let contour = fontGlyph.debugLayer[i]
                    
                    path = Path()
                    path.move(to: contour.origin.cgPoint())
                    
                    var points: [CGPoint] = []
                    
                    if contour.renderLayer == .Debug {
                        points = contour.points.asCGPointArray()
                    } else {
                        points.append(contentsOf: contour.points.asCGPointArray()[0..<Int(computedAmounts[i].wrappedValue)])
                    }
                    
                    path.addLines(points)
                    
                    context.stroke(
                        path,
                        with: .color(getContourColor(contour.debugRenderOptions.color)),
                        style: contour.debugRenderOptions.asStrokeStyle()
                    )
                }
            }.frame(width: fontGlyph.width, height: fontGlyph.height)
            
            if debugLevels.contains(.SteppedPoints) {
                VStack {
                    Stepper("Contour #\(contourLayer + 1)", value: $contourLayer, in: 0...fontGlyph.mainRenderLayer.count - 1)
                    Slider(
                        value: computedAmounts[contourLayer],
                        in: 0...Double(fontGlyph.mainRenderLayer[contourLayer].points.count),
                        step: 1
                    )
                }
            }
        }
    }
}

func breakdownBezierSegments(from contour: ContoursInstructions) {
//    print(contour.points)
    
    var firstOnCurvePointIndex: Int = 0
    
    for i in 0..<contour.points.count {
        if contour.points[i].onCurve {
            firstOnCurvePointIndex = i
        }
    }
    
    var segments: [[ContourPoint]] = []
    var currentSegment: [ContourPoint] = [contour.points[firstOnCurvePointIndex]]
    
//    print("#######")
    
    for i in 0..<contour.points.count {
        let curr = contour.points[(i + firstOnCurvePointIndex + 0) % contour.points.count]
        let next = contour.points[(i + firstOnCurvePointIndex + 1) % contour.points.count]
        
        if curr.onCurve && next.onCurve {
            currentSegment.append(next)
            segments.append(currentSegment)
            currentSegment = []
        }
        
//        print(curr, next, currentSegment)
        
//        print(">>>>>")
    }
    
//    print("################ >>>>>>>>>>>>> ########")
//    print(segments)
}
