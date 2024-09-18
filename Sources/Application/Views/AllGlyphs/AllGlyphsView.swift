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

struct GlyphRow: Identifiable {
    var id = UUID()
    var items: [Glyph]
}

struct FontRenderAllView : View {
    var loader: FontLoader
    @Binding var debugLevels: [DEBUG__FrOverlayOptions]
    var rowCount = 8
        
    func toIndex(_ base: Int, offset: Int = 0) -> Int { (base * rowCount) + offset }
    
    var body: some View {
        ScrollView{
            LazyVStack {
                ForEach(0..<Int(loader.memoryInfo.numGlyphs) / rowCount, id: \.self) { index in
                    HStack {
                        GlyphRowView(loader: loader, offset: toIndex(index, offset: 0), debugLevels: $debugLevels, fontRenderScale: 0.1)
                        GlyphRowView(loader: loader, offset: toIndex(index, offset: 1), debugLevels: $debugLevels, fontRenderScale: 0.1)
                        GlyphRowView(loader: loader, offset: toIndex(index, offset: 2), debugLevels: $debugLevels, fontRenderScale: 0.1)
                        GlyphRowView(loader: loader, offset: toIndex(index, offset: 3), debugLevels: $debugLevels, fontRenderScale: 0.1)
                        GlyphRowView(loader: loader, offset: toIndex(index, offset: 4), debugLevels: $debugLevels, fontRenderScale: 0.1)
                        GlyphRowView(loader: loader, offset: toIndex(index, offset: 5), debugLevels: $debugLevels, fontRenderScale: 0.1)
                        GlyphRowView(loader: loader, offset: toIndex(index, offset: 6), debugLevels: $debugLevels, fontRenderScale: 0.1)
                        GlyphRowView(loader: loader, offset: toIndex(index, offset: 7), debugLevels: $debugLevels, fontRenderScale: 0.1)
                    }
                }
            }.padding()
        }
    }
}
