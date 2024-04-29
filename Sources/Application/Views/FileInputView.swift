//
//  FileInputView.swift
//
//
//  Created by Jefferson Oliveira on 4/29/24.
//

import Foundation
import SwiftUI

struct FileInputView : View {
    @Binding var fontPath: String
    
    func openDialog () {
        if let url = NSOpenPanel().selectUrl {
            fontPath = url.path
        }
    }
    
    var body: some View {
        HStack {
            Text(fontPath)
            Button(action: { openDialog() }, label: {
                Text("Open Font file")
            })
        }
    }
}
