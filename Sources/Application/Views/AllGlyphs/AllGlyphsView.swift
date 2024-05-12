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

    var rows: [GlyphRow] = []
    var rowCount = 3
    
    
    init(_ loader: FontLoader) {
        self.loader = loader
        
        let glyphRows: [GlyphRow] = []
        
        //        for i in stride(from: 0, to: Int(loader.memoryInfo.numGlyphs - 1), by: rowCount){
        
        //

        //
        //            glyphRows.append(.init(items: row))
        //        }
        
        rows = glyphRows
    }
    
    func toIndex(_ base: Int, offset: Int = 0) -> Int {
        return (base * rowCount) + offset
    }
    
    
    var body: some View {
        ScrollView{
            LazyVStack {
                ForEach(0..<Int(loader.memoryInfo.numGlyphs) / rowCount, id: \.self) { index in
                    HStack {
                        GlyphRowView(loader, toIndex(index, offset: 0))
                        GlyphRowView(loader, toIndex(index, offset: 1))
                        GlyphRowView(loader, toIndex(index, offset: 2))
                    }
                }
            }
        }
    }
}
