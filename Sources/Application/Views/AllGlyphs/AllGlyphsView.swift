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
    @State var debugLevels: [DebugLevel]
    var loader: FontLoader
    var rowCount = 3
    
    init(_ loader: FontLoader, debugLevels: [DebugLevel] = []) {
        self.loader = loader
        self.debugLevels = debugLevels
    }
    
    func toIndex(_ base: Int, offset: Int = 0) -> Int {
        return (base * rowCount) + offset
    }
    
    var body: some View {
        ScrollView{
            LazyVStack {
                ForEach(0..<Int(loader.memoryInfo.numGlyphs) / rowCount, id: \.self) { index in
                    HStack {
                        GlyphRowView(loader, toIndex(index, offset: 0), debugLevels: debugLevels)
                        GlyphRowView(loader, toIndex(index, offset: 1), debugLevels: debugLevels)
                        GlyphRowView(loader, toIndex(index, offset: 2), debugLevels: debugLevels)
                    }
                }
            }
        }
    }
}
