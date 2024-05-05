//
//  FontRenderView.swift
//
//
//  Created by Jefferson Oliveira on 4/29/24.
//

import Foundation
import SwiftUI
import FontLoader
import Combine

enum CurrentGlyph {
    case missing
    case error(String)
    case existing(SimpleGlyphTable)
}

enum GlyphRenderType: Identifiable {
    var id: UUID {
        return UUID()
    }
    
    case space
    case character(CharacterMapItem)
    case glyph(Int)
}

struct FontRenderView : View {
    var loader: FontLoader
    
    @State var glyphCount: Int
    @State var currentGlyph: CurrentGlyph
    @State var fontScale = 0.3
    @State var inputText: String = ""
    @State var showDefaultGlyph: Bool = false
    
    init(_ loader: FontLoader) {
        
        self.loader = loader
        glyphCount = loader.glyphs.count
        let glyphData =  loader.glyphs[0]
        
        currentGlyph = glyphData != nil ? .existing(glyphData!) : .missing
    }
    
    @ViewBuilder
    func RenderGlyph(withType type: GlyphRenderType) -> some View {
        switch type {
        case .space:
            Rectangle().fill(.clear).frame(width: 500 * fontScale, height: 730 * fontScale)
        case let .character(char):
            RenderGlyphView(glyphData: loader.glyphs[char.glyphIndex], scale: fontScale)
        case let .glyph(index):
            RenderGlyphView(glyphData: loader.glyphs[index], scale: fontScale)
        }
    }
    
    @ViewBuilder
    func viewGlyph(for state: CurrentGlyph) -> some View {
        let initialChars: [GlyphRenderType] = showDefaultGlyph ? [.glyph(0)] : []
        
        let chars: [GlyphRenderType] = inputText.reduce(initialChars) { chars, char in
            guard let charMapItem = loader.characters[char] else {
                return chars
            }
            var newChars = chars
            
            if char == " " {
                newChars.append(.space)
                
                return newChars
            }
            
            newChars.append(.character(charMapItem))
            
            return newChars
        }
        
        HStack {
            ForEach(chars) { char in
                RenderGlyph(withType: char)
            }
        }
    }
    
    func limitText(_ upper: Int) {
        if inputText.count > upper {
            inputText = String(inputText.prefix(upper))
        }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center){
                ScrollView(.horizontal) {
                    viewGlyph(for: currentGlyph).padding()
                }
            }.frame(maxHeight: .infinity)
            VStack {
                HStack {
                    Toggle(isOn: $showDefaultGlyph) {
                        Text("Show Default Glyph")
                    }
                    .toggleStyle(.checkbox)
                    Text("Font Scale \(fontScale)")
                    Slider(
                        value: $fontScale,
                        in: 0.1...1
                        
                    )
                }.padding()
                
                TextEditor(text: $inputText)
                    .lineLimit(3, reservesSpace: true)
                    .font(.system(.body))
                    .frame(height: 60)
                    .onReceive(Just(inputText)) { _ in limitText(100) }
                
            }
            .frame(height: 90)
            .padding()
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
        
//        print(glyph)
        
        for i in 0..<glyph.xCoordinates.count {
            let x = toScale(glyph.xCoordinates[i])
            
            let rawY = (730 - glyph.yCoordinates[i])
            
            let y = toScale(rawY)
            
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
        let width = (Int(glyphData?.xMax ?? 0) - Int(glyphData?.xMin ?? 0)) + 100
        
        Canvas { context, size in
            
            guard let glyph = glyphData else {
                return
            }
            let coords = getPoints()
            var nextSegmentIndex = 0
            var beginOfContour: Int = 0
            
//            print(glyph)
            
            let minPoints = CGPoint(x: Int(glyph.xMin), y: Int(glyph.yMin))
            let maxPoints = CGPoint(x: Int(glyph.xMax), y: Int(glyph.yMax))
            
            if coords.count == 0 {
                return;
            }
            
            let _ = SafeCanvas(withBoundary: .init(a: minPoints, b:maxPoints))
            
            var path = Path()
            path.move(to: .init(x: Int(glyph.xMin), y: Int(glyph.yMin)))
            path.addLines([
                .init(x: 0, y: 0),
                .init(x: size.width, y: .zero),
                .init(x: size.width, y: size.height),
                .init(x: .zero, y: size.height),
                .init(x: 0, y: 0)
                ]
            )
            
            context.stroke(path, with: .color(.purple), lineWidth: 5)
            
            path = Path()
            path.move(to: .init(x: Int(glyph.xMin), y: Int(glyph.yMin)))
            path.addLines([
                .init(x: toScale(glyph.xMin), y: toScale(730 - Int(glyph.yMin))),
                .init(x: toScale(glyph.xMax), y: toScale(730 - Int(glyph.yMin))),
                .init(x: toScale(glyph.xMax), y: toScale(730 - Int(glyph.yMax))),
                .init(x: toScale(glyph.xMin), y: toScale(730 - Int(glyph.yMax))),
                .init(x: toScale(glyph.xMin), y: toScale(730 - Int(glyph.yMin)))
                ]
            )
            
            context.stroke(path, with: .color(.green), lineWidth: 5)
            
            path = Path()
            path.move(to: coords[0])
            
            var points: [CGPoint] = [coords[0]]
            for i in 1..<coords.count {
                let current = coords[i]
                let nextSegment = nextSegmentIndex < glyph.endPtsOfContours.count ? glyph.endPtsOfContours[nextSegmentIndex] : glyph.endPtsOfContours.last!
                
                points.append(current)
                
                if (i == nextSegment) {
                    points.append(coords[beginOfContour])
                    path.addLines(points)
                    context.stroke(path, with: .color(.gray), lineWidth: 2)
//                    print(points)
                    points = []
                    beginOfContour = nextSegment + 1
                    nextSegmentIndex += 1
                }
            }
        }.frame(width: toScale(width))
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

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}
