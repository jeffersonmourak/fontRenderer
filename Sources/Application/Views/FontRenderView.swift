//
//  FontRenderView.swift
//
//
//  Created by Jefferson Oliveira on 4/29/24.
//

import Foundation
import SwiftUI
import FontLoader

struct FontValidationError : LocalizedError {
    let description: String
    
    init (_ description: String) {
        self.description = description
    }
    
    var errorDescription: String? {
        description
    }
}

@Observable class Font {
    var path: String
    let font: FontLoader
    
    
    init(path: String) throws {
        self.path = path
        
        guard let fontData = readFile(fromPath: path) else {
           throw FontValidationError("Unable to read")
        }
        
        font = FontLoader(withData: fontData)
    }
    
    
    func getGlyph(at index: Int) -> SimpleGlyphTable? {
        return font.glyphs[index]
    }
}

struct FontRenderView : View {
    @State var font: Font
    @State var _selectedGlyph: Int
    @State var glyphCount: Range<Int>
    @State var currentGlyph: SimpleGlyphTable?
    
    init(fontPath: String) throws {
        let fontData = try Font(path: fontPath)
        self.font = fontData
        _selectedGlyph = 0
        glyphCount = 0..<fontData.font.glyphs.count
        currentGlyph = self.font.getGlyph(at: 0)
    }
    
    var body: some View {
        let selectedGlyph = Binding(
            get: {
                return self._selectedGlyph
            },
            set: {
                self.currentGlyph = self.font.getGlyph(at: $0)
                self._selectedGlyph = $0
            }
        )
        VStack {
            Picker("Glyph Index", selection: selectedGlyph) {
                ForEach(glyphCount) { glyphIndex in
                    Text("\(glyphIndex)")
                }
            }.frame(width: 200, height: 30)
            HStack(alignment: .center){
                if currentGlyph != nil {
                    Triangle(glyphData: currentGlyph, scale: 0.3)
                        .stroke(.red, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                } else {
                    Text("Cant load Glyph!")
                }
            }.padding().frame(width: 640, height: 400)
            
        }
    }
}

struct Coordinates {
    let x: Int
    let y: Int
}

struct Triangle: Shape {
    var glyphData: SimpleGlyphTable?
    var scale: Float = 1
    
    func toScale<T: BinaryInteger>(_ value: T) -> CGFloat {
        return CGFloat(value) * CGFloat(scale)
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
                guard let glyph = glyphData else {
                    return path
                }
        
                let coordinatesCount = glyph.xCoordinates.count
        
                let xCoord = glyph.xCoordinates.map(toScale)
                let yCoord = glyph.yCoordinates.map(toScale)
        
                let yOffset = toScale(glyph.yMax)
                let xOffset = toScale(glyph.xMax)
        
                path.move(to: CGPoint(x: xOffset - xCoord[0], y: yOffset - yCoord[0]))
        
                let colors: [NSColor] = [
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
        
                print(glyph)
        
                for i in 1..<coordinatesCount {
        //            let color = colors[i - 1]
        
                    let current = CGPoint(x: xOffset - xCoord[i], y: yOffset - yCoord[i])
        
                    if (glyph.endPtsOfContours.contains(i)) {
                        path.move(to: current)
                    } else {
                        path.addLine(to: current)
                    }
                }
        
        
        
//                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
//                path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}
