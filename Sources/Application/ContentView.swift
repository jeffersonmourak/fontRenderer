//
//  ContentView.swift
//
//
//  Created by Jefferson Oliveira on 4/29/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import FontLoader

struct FontValidationError: LocalizedError {
    let description: String
    
    init (_ description: String) {
        self.description = description
    }
    
    var errorDescription: String? {
        description
    }
}

enum ViewState {
    case loading
    case loaded(FontLoader)
    case error(String)
}

func readFile(fromPath path: String) -> Data? {
    let fileURL = URL(fileURLWithPath: path)

    do {
        let data = try Data(contentsOf: fileURL)
        return data
    } catch {
//        print("Error reading data: \(error)")
        return nil
    }
}

func loadFont(_ path: String) throws -> FontLoader {
    guard path != "" else {
        throw FontValidationError("No font file provided")
    }
    
    guard let fontData = readFile(fromPath: path) else {
        throw FontValidationError("File not found")
    }
    
    do {
        return try FontLoader(withData: fontData)
    } catch {
        throw error
    }
}

struct ContentView : View {
    //    private var font: FontFile?
    @State private var fontPath: String
    //    @State private var renderEnabled: Bool = false
    //    @State private var stateMessage: String = ""
    
    @State private var contentState: ViewState
    
    
    
    init(_ initialPath: String) {
        fontPath = initialPath
        do {
            let font = try loadFont(initialPath)
            self.contentState = .loaded(font)
        } catch {
            self.contentState = .error(error.localizedDescription)
        }
    }
    
    @ViewBuilder
    func view(for state: ViewState) -> some View {
        switch state {
        case let .error(message):
            Text(message)
        case let .loaded(loader):
            FontRenderView(loader).frame(width: 640, height: 430)
        case .loading:
            Text("Loaded!")
        }
    }
    
    var body: some View {
        
        VStack() {
            FileInputView(fontPath: $fontPath).onChange(of: fontPath) {
                do {
                    let font = try loadFont(fontPath)
                    self.contentState = .loaded(font)
                } catch {
                    self.contentState = .error(error.localizedDescription)
                }
            }
            view(for: contentState)
//            if contentState.isState("loading") {
//                Text("Loading...")
//            } else if contentState.isState("error") {
//                Text("error")
//            } else if contentState.isState("loaded") {
//
//            }
            //            Group { () -> Text in
            //                switch(contentState) {
            //                case .loading:
            //
            //                case let .error(message):
            //
            //                case let .loaded(loader): do {
            //                    return
            //                }
            //                }
            //            }
            
            //            if renderEnabled {
            //
            //            } else {
            //                Text(stateMessage)
            //            }
            
            
            //            if let fontRenderView = try? {
            //                fontRenderView
            //            } else {
            //                Text("Error loading")
            //            }
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


extension ViewState {
    func isState(_ name: String) -> Bool {
        switch (self) {
        case .loading:
            return name == "loading"
        case .error(_):
            return name == "error"
        case .loaded(_):
            return name == "loaded"
        }
    }
}
