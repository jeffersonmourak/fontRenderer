//
//  FontRenderView.swift
//
//
//  Created by Jefferson Oliveira on 4/29/24.
//

import Combine
import FontLoader
import Foundation
import SwiftUI
import SwiftDotenv

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

struct FontRenderView: View {
    var loader: FontLoader

    @State var currentGlyph: CurrentGlyph = .missing
    @State var fontRenderScale = 0.3
    @State var currentScale = 0.0
    @State var inputText: String = Dotenv["FR_FONT_DEBUG_STRING"]?.stringValue ?? ""
    @State var showDefaultGlyph: Bool = false
    @State var focusPoint: CGPoint = .zero
    @Binding var debugLevels: [DEBUG__FrOverlayOptions]

    @ViewBuilder
    func viewGlyph(for state: CurrentGlyph) -> some View {
        let initialChars: [Glyph] = showDefaultGlyph ? [try! loader.getGlyphContours(at: 0)] : []

        let chars: [Glyph] = inputText.reduce(initialChars) { chars, char in
            guard let charMapItem = loader.characters[char] else {
                return chars
            }
            var newChars = chars

            let charIndex = char == " " ? loader.getSpaceGlyphIndex() : charMapItem.glyphIndex

            let glyph = try! loader.getGlyphContours(at: charIndex)

            newChars.append(glyph)

            return newChars
        }

        FrGlyphCanvas(
            glyphs: chars, scale: fontRenderScale, autoWidth: true, debugLevels: $debugLevels,
            focusPoint: $focusPoint
        )
        .frame(minWidth: 10, maxWidth: .infinity)
        .gesture(
            MagnifyGesture()
                .onChanged { value in

                    let movement = (value.magnification - 1)

                    focusPoint = .init(
                        x: focusPoint.x - (movement / 2),
                        y: focusPoint.y - (movement / 2))
                    fontRenderScale += movement.scaled(by: 0.03)

                }
        )
        .gesture(
            DragGesture()
                .onChanged { value in
                    // It doesn't work as expected but it's a start and close enough
                    focusPoint = .init(
                        x: focusPoint.x + value.velocity.width.scaled(by: fontRenderScale / 50),
                        y: focusPoint.y + value.velocity.height.scaled(by: fontRenderScale / 50))
                }
        )
    }

    func limitText(_ upper: Int) {
        if inputText.count > upper {
            inputText = String(inputText.prefix(upper))
        }
    }

    var body: some View {
        VStack {
            viewGlyph(for: currentGlyph)
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
                HStack {
                    Divider()
                    HStack {
                        Button(action: {
                            fontRenderScale = 0.3
                            focusPoint = .zero
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                        Toggle(isOn: $showDefaultGlyph) {
                            Image(systemName: showDefaultGlyph ? "eye" : "eye.slash")
                        }
                        .help("Toggle display default glyph")
                        .toggleStyle(.button)
                    }
                }
            }
        }
    }
}
