//
//  ContentView.swift
//
//
//  Created by Jefferson Oliveira on 4/29/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers



struct ContentView : View {
    var initialPath: String
    @State private var fontPath: String
    
    init(_ initialPath: String) {
        self.initialPath = initialPath
        self.fontPath = initialPath
    }
    
    var body: some View {
        VStack() {
            FileInputView(fontPath: $fontPath)
            if let fontRenderView = try? FontRenderView(fontPath: fontPath){
                fontRenderView.frame(width: 640, height: 430)
            } else {
                Text("Error loading")
            }
        }.padding().frame(width: 640, height: 480)
    }
}


extension NSOpenPanel {
    var selectUrl: URL? {
        title = "Select Image"
        allowsMultipleSelection = false
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        allowedContentTypes = [.font]
        return runModal() == .OK ? urls.first : nil
    }
}
