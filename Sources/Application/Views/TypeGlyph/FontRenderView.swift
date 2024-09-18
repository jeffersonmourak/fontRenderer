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
    @State var inputText: String = ""
    @State var showDefaultGlyph: Bool = false
    @Binding var debugLevels: [DEBUG__FrOverlayOptions]
    
    @ViewBuilder
    func viewGlyph(for state: CurrentGlyph) -> some View {
        let initialChars: [Glyph] = showDefaultGlyph ? [try! loader.getGlyphContours(at: 0)] : []
        
        let chars: [Glyph] = inputText.reduce(initialChars) { chars, char in
            guard let charMapItem = loader.characters[char] else {
                return chars
            }
            var newChars = chars

            let charIndex =  char == " " ? loader.getSpaceGlyphIndex() : charMapItem.glyphIndex
            

            let glyph = try! loader.getGlyphContours(at: charIndex)

            newChars.append(glyph)

            return newChars
        }
        
        HStack {
            FrGlyphCanvas(glyphs: chars, scale: fontRenderScale, debugLevels: $debugLevels)
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
        }.toolbar {
            ToolbarItemGroup(placement: .automatic) {
                HStack{
                    Divider()
                    HStack {
                        Toggle(isOn: $showDefaultGlyph){
                            Image(systemName: showDefaultGlyph ? "eye" : "eye.slash")
                        }
                        .help("Toggle display default glyph")
                        .toggleStyle(.button)
                    }
                    Image(systemName: "textformat.size")
                    Picker("Font scale", selection: $fontRenderScale) {
                        Text("0.0075 em").tag(0.0075)
                        Text("0.025 em").tag(0.025)
                        Text("0.05 em").tag(0.05)
                        Text("0.1 em").tag(0.1)
                        Text("0.30 em").tag(0.3)
                        Text("0.75 em").tag(0.75)
                        Text("1 em").tag(1)
                        Text("1.30 em").tag(1.3)
                        Text("1.75 em").tag(1.75)
                        Text("2 em").tag(2)
                        Text("2.30 em").tag(2.3)
                        Text("2.75 em").tag(2.75)
                    }
                }
            }
        }
    }
}
