//
//  FontRenderView.swift
//
//
//  Created by Jefferson Oliveira on 4/29/24.
//

import Foundation
import SwiftUI
import FontLoader

enum CurrentGlyph {
    case missing
    case error(String)
    case existing(SimpleGlyphTable)
}

struct FontRenderView : View {
    var loader: FontLoader
    
    @State var selectedGlyph: Int = 0
    @State var glyphCount: Int
    @State var currentGlyph: CurrentGlyph
    @State var fontScale = 0.3
    
    init(_ loader: FontLoader, startingAt selectedGlyph: Int = 2) {
        
        self.loader = loader
        self.selectedGlyph = selectedGlyph
        glyphCount = loader.glyphs.count
        let glyphData =  loader.glyphs[selectedGlyph]
        
        currentGlyph = glyphData != nil ? .existing(glyphData!) : .missing
    }
    
    @ViewBuilder
    func viewGlyph(for state: CurrentGlyph) -> some View {
        switch state {
        case let .error(message):
            Text(message)
        case let .existing(glyph):
            RenderGlyphView(glyphData: glyph, scale: fontScale)
        case .missing:
            Text("Missing Glyph")
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker("Glyph Index", selection: $selectedGlyph) {
                    ForEach(0..<glyphCount) { glyphIndex in
                        Text("\(glyphIndex)")
                    }
                }.onChange(of: selectedGlyph) {
                    let glyphData =  loader.glyphs[selectedGlyph]
                    
                    currentGlyph = glyphData != nil ? .existing(glyphData!) : .missing
                }
                Slider(
                    value: $fontScale,
                    in: 0.1...1
                    
                )
                Text("\(fontScale)")
            }.frame(height: 30)
            HStack(alignment: .center){
                viewGlyph(for: currentGlyph)
            }.padding().frame(width: 640, height: 400)
            
        }
    }
}

struct Coordinates {
    let x: Int
    let y: Int
}

struct Line: Shape {
    var a: CGPoint
    var b: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: a)
        path.addLine(to: b)
        
        return path
    }
}

struct RenderGlyphView: View {
    var glyphData: SimpleGlyphTable?
    var scale: Double = 1
    
    var path = Path()
    
    func getPoints() -> [CGPoint] {
        guard let glyph = glyphData else {
            return []
        }
        
        var coords: [CGPoint] = []
        
        for i in 0..<glyph.xCoordinates.count {
            let x = toScale(glyph.xCoordinates[i])
            let y = toScale(glyph.yCoordinates[i])
            coords.append(CGPoint(x: x, y: y))
        }
        
        return coords
    }
    
    func toScale<T: BinaryInteger>(_ value: T) -> CGFloat {
        return CGFloat(Int((CGFloat(value) * CGFloat(scale)) * 1000) / 1000)
    }
    
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
    
    var body: some View {
        Canvas { context, size in
            guard let glyph = glyphData else {
                return
            }
            let coords = getPoints()
            var nextSegmentIndex = 0
            var beginOfContour: Int = 0
            
            var path = Path()
            path.move(to: coords[0])
            
            var points: [CGPoint] = [coords[0]]
            for i in 1..<coords.count {
                let current = coords[i]
                let nextSegment = glyph.endPtsOfContours[nextSegmentIndex]
                
                points.append(current)

                if (i == nextSegment) {
                    
                    points.append(coords[beginOfContour])
                    
                    path.addLines(points)
                    context.stroke(path, with: .color(colors[nextSegmentIndex]), lineWidth: 2)
                    
                    points = []
                    beginOfContour = nextSegment + 1
                    nextSegmentIndex += 1
                }
            }
        }
    }
}

extension CGPoint: AdditiveArithmetic {
    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    public static func - (lhs: CGPoint, rhs: Double) -> CGPoint {
        return CGPoint(x: lhs.x - rhs, y: lhs.y - rhs)
    }
    
    public static func + (lhs: CGPoint, rhs: Double) -> CGPoint {
        return CGPoint(x: lhs.x + rhs, y: lhs.y + rhs)
    }
}
