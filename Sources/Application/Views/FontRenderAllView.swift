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
    var fontRenderScale = 0.3
    var fontHeight: Double = 800
    var rows: [GlyphRow] = []
    
    
    init(_ loader: FontLoader) {
        self.loader = loader
    
        var glyphRows: [GlyphRow] = []
        var rowCount = 3
        for i in stride(from: 0, to: Int(loader.memoryInfo.numGlyphs - 1), by: rowCount){
            var row: [Glyph] = []
            
            for j in 0..<rowCount {
                do {
                    row.append(try loader.getGlyphContours(at: i + j))
                } catch {
                    row.append(try! loader.getGlyphContours(at: 0))
                }
            }
            
            glyphRows.append(.init(items: row))
        }
        
        rows = glyphRows
    }
    
    var body: some View {
        VStack {
            ForEach(rows) { row in
                HStack {
                    ForEach(row.items) { glyph in
                        RenderGlyphView(
                            glyph: glyph,
                            scale: fontRenderScale,
                            fontHeight: fontHeight,
                            renderOptions: .create(
                                usingGlyph: .init(color: .black, width: 1),
                                usingOutline: .init(color: .clear, width: 1)
                            )
                        ).background(.gray)
                    }
                }
            }
        }
    }
}
