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
            RenderGlyphView(glyph: try! loader.getGlyphContours(at: char.glyphIndex), scale: fontRenderScale, fontHeight: fontHeight)
        case let .glyph(index):
            RenderGlyphView(glyph: try! loader.getGlyphContours(at: index), scale: fontRenderScale, fontHeight: fontHeight)
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
            .frame(height: 100)
            .padding()
        }.frame(minHeight: 410)
    }
}
