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

struct FontInfoView : View {
    var loader: FontLoader
    var records:  [NameRecord] = []
        
    init(loader: FontLoader) {
        self.loader = loader
        
        do {
            let nameTable = try loader.getFontNameTable()
            records = nameTable.records
        } catch {
            records = []
        }
    }
    
    var body: some View {
        Table(records) {
            TableColumn("Name ID") { record in
                Text(record.nameID.toString())
            }
            TableColumn("Platform ID") { record in
                Text(record.platformID.toString())
            }
            TableColumn("Platform Specific ID") { record in
                Text(record.platformSpecificID.toString())
            }
            TableColumn("Language ID") { record in
                Text(record.languageID.toString())
            }
            TableColumn("Text") { record in
                Text(record.message)
            }
        }
    }
}
