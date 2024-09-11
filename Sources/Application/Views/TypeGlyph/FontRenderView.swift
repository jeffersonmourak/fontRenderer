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
    
    @State var currentGlyph: CurrentGlyph = .missing
    @State var fontRenderScale = 0.3
    @State var fontHeight: Double = 730
    @State var inputText: String = ""
    @State var showDefaultGlyph: Bool = false
    @Binding var debugLevels: [DebugLevel]
    

    @ViewBuilder
    func RenderGlyph(withType type: GlyphRenderType) -> some View {
        switch type {
        case .space:
            Rectangle().fill(.clear).frame(width: Double(loader.horizontalHeader.advanceWidthMax) * fontRenderScale, height: CGFloat(loader.fontInfo.unitsPerEm) * fontRenderScale)
        case let .character(char):
            SharedGlyphView(glyph: try! loader.getGlyphContours(at: char.glyphIndex), scale: fontRenderScale, fontHeight: fontHeight, debugLevels: $debugLevels)
        case let .glyph(index):
            SharedGlyphView(glyph: try! loader.getGlyphContours(at: index), scale: fontRenderScale, fontHeight: fontHeight, debugLevels: $debugLevels)
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
            }.frame(minHeight: 410, maxHeight: .infinity)
            VStack {
                TextEditor(text: $inputText)
                    .lineLimit(3, reservesSpace: true)
                    .font(.system(.body))
                    .frame(height: 60)
                    .onReceive(Just(inputText)) { _ in limitText(100) }
                
            }
            .padding()
        }.toolbar(content: {
            ToolbarItemGroup(placement: .principal) {
                HStack {
                    Toggle(isOn: $showDefaultGlyph){
                        Image(systemName: showDefaultGlyph ? "eye" : "eye.slash")
                    }
                    .help("Toggle display default glyph")
                    .toggleStyle(.button)
                }
                Spacer()
                Image(systemName: "textformat.size")
                Slider(
                    value: $fontRenderScale,
                    in: 0.1...3
                )
                .help("Font render scale")
                .disabled(!showDefaultGlyph && inputText.count == 0)
                .frame(minWidth: 200, maxWidth: 400)
                Text("\(String(format: "%.2f", fontRenderScale)) em")
                Spacer()
            }
        })
    }
}
