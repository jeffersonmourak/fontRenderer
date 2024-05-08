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
    
    @State var currentGlyph: CurrentGlyph
    @State var fontRenderScale = 0.3
    @State var fontHeight: Double = 730
    @State var inputText: String = ""
    @State var showDefaultGlyph: Bool = false
    
    init(_ loader: FontLoader) {
        
        self.loader = loader
        currentGlyph = .missing
    }
    
    @ViewBuilder
    func RenderGlyph(withType type: GlyphRenderType) -> some View {
        switch type {
        case .space:
            Rectangle().fill(.clear).frame(width: Double(loader.horizontalHeader.advanceWidthMax) * fontRenderScale, height: fontHeight * fontRenderScale)
        case let .character(char):
            RenderGlyphView(glyph: loader.getGlyphContours(at: char.glyphIndex), scale: fontRenderScale, fontHeight: fontHeight)
        case let .glyph(index):
            RenderGlyphView(glyph: loader.getGlyphContours(at: index), scale: fontRenderScale, fontHeight: fontHeight)
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
                VStack(alignment: .leading) {
                    Toggle(isOn: $showDefaultGlyph) {
                        Text("Show Default Glyph")
                    }
                    .toggleStyle(.checkbox)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Font Scale \(fontRenderScale)")
                            Slider(
                                value: $fontRenderScale,
                                in: 0.1...1
                                
                            )
                        }
                        VStack(alignment: .leading) {
                            Text("Font Height \(Int(fontHeight))")
                            Slider(
                                value: $fontHeight,
                                in: Double(loader.fontInfo.yMin)...Double(loader.fontInfo.yMax)
                            )
                        }
                    }
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
    var glyph: Glyph
    var scale: Double = 1
    var fontHeight: Double
    
    var path = Path()
    
    func toScale<T: BinaryInteger>(_ value: T) -> CGFloat {
        return CGFloat(Int((CGFloat(value) * CGFloat(scale)) * 1000) / 1000)
    }
    
    func toScale(_ value: CGFloat) -> CGFloat {
        return CGFloat((value * CGFloat(scale)) * 1000 / 1000)
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
        let width = glyph.glyphBox.max.width > glyph.fontLayout.horizontalMetrics.advanceWidth ? CGFloat(glyph.glyphBox.max.width) : CGFloat(glyph.fontLayout.horizontalMetrics.advanceWidth)
        
        Canvas { context, size in
            // @TODO: Find what to do with SafeCanvas
            //let _ = SafeCanvas(withBoundary: .init(a: minPoints, b:maxPoints))
            
            var path = Path()
            path.addLines([
                .init(x: 0, y: 0),
                .init(x: size.width, y: .zero),
                .init(x: size.width, y: size.height),
                .init(x: .zero, y: size.height),
                .init(x: 0, y: 0)
                ]
            )
            
            context.stroke(path, with: .color(.purple), lineWidth: 5)
            
            for glyphContours in glyph.contours {
                let coords = glyphContours.map {
                    let newY = Int(glyph.glyphBox.max.y) - $0.y
                    
                    
                    return CGPoint(x: toScale($0.x), y: toScale(newY))
                }
     
                if coords.count == 0 {
                    return;
                }
                
                path = Path()
                path.move(to: coords[0])
                path.addLines(coords)
                context.stroke(path, with: .color(.gray), lineWidth: 2)
            }
            
        }.frame(width: toScale(width), height: toScale(Int(glyph.glyphBox.max.y) + glyph.baseLineDistance))
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
