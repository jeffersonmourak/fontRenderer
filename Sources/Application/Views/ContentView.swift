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
    
    init (
        _ description: String
    ) {
        self.description = description
    }
    
    var errorDescription: String? {
        description
    }
}

enum ViewState {
    case loading
    case loaded(
        FontLoader
    )
    case error(
        String
    )
}

func readFile(
    fromPath path: String
) -> Data? {
    let fileURL = URL(
        fileURLWithPath: path
    )
    
    do {
        let data = try Data(
            contentsOf: fileURL
        )
        return data
    } catch {
        //        print("Error reading data: \(error)")
        return nil
    }
}

func loadFont(
    _ path: String
) throws -> FontLoader {
    guard path != "" else {
        throw FontValidationError(
            "No font file provided"
        )
    }
    
    guard let fontData = readFile(
        fromPath: path
    ) else {
        throw FontValidationError(
            "File not found"
        )
    }
    
    do {
        return try FontLoader(
            withData: fontData
        )
    } catch {
        throw error
    }
}

enum FontViews: String {
    case type = "type"
    case all = "all"
}

struct ContentView : View {
    @State private var fontPath: String
    @State private var enabledDebugLevels: [DEBUG__FrOverlayOptions] = []
    @State private var contentState: ViewState
    @State private var currentView: FontViews = .type
    
    init(
        _ initialPath: String = ""
    ) {
        fontPath = initialPath
        do {
            let font = try loadFont(
                initialPath
            )
            self.contentState = .loaded(
                font
            )
        } catch {
            self.contentState = .error(
                error.localizedDescription
            )
        }
    }
    
    @ViewBuilder
    func LoadFontView(
        for state: ViewState
    ) -> some View {
        switch state {
        case let .error(
            message
        ):
            Text(
                message
            )
        case let .loaded(
            loader
        ):
            switch currentView {
            case .type:
                FontRenderView(
                    loader: loader,
                    debugLevels: $enabledDebugLevels
                )
            case .all:
                FontRenderAllView(
                    loader: loader,
                    debugLevels: $enabledDebugLevels
                )
            }
        case .loading:
            Text(
                "Loaded!"
            )
        }
    }
    
    var body: some View {
        NavigationSplitView{
            List(
                selection: $currentView
            ) {
                NavigationLink(
                    value: FontViews.type
                ) {
                    Label(
                        "Type Text",
                        systemImage: "text.quote"
                    )
                }
                NavigationLink(
                    value: FontViews.all
                ) {
                    Label(
                        "All Glyphs",
                        systemImage: "square.grid.3x2"
                    )
                }
            }.toolbar(
                removing: .sidebarToggle
            )
            
            
        } detail: {
            LoadFontView(
                for: contentState
            )
        }.toolbar {
            ToolbarItemGroup(
                placement: .status
            ) {
                SharedDebugFontInputView(
                    enabledDebugLevels: $enabledDebugLevels
                ).onChange(
                    of: enabledDebugLevels
                ) {
                    self.enabledDebugLevels = enabledDebugLevels
                }
            }
        }.toolbar {
            ToolbarItemGroup(
                placement: .navigation
            ) {
                SharedFontInputView(
                    fontPath: $fontPath
                ).onChange(
                    of: fontPath
                ) {
                    do {
                        let font = try loadFont(
                            fontPath
                        )
                        self.contentState = .loaded(
                            font
                        )
                    } catch {
                        self.contentState = .error(
                            error.localizedDescription
                        )
                    }
                }
            }
        }
    }
}


extension NSOpenPanel {
    var selectUrl: URL? {
        title = "Select Font File"
        allowsMultipleSelection = false
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        allowedContentTypes = [.font]
        return runModal() == .OK ? urls.first : nil
    }
}


extension ViewState {
    func isState(
        _ name: String
    ) -> Bool {
        switch (
            self
        ) {
        case .loading:
            return name == "loading"
        case .error(
            _
        ):
            return name == "error"
        case .loaded(
            _
        ):
            return name == "loaded"
        }
    }
}
