//
//  File.swift
//  
//
//  Created by Jefferson Oliveira on 4/29/24.
//

import Foundation
import SwiftUI
import FontLoader

/**

 */

class FontRendererApplication: ViewportApplication {
    var font: FontLoader? = nil
    var inputPath: String = ""
    
    override init() {
        super.init()
    }
    
    override func applicationCreate() {
        var rect = window.frame
        rect.origin.x = 0.0
        rect.origin.y = 0.0
        
        let controller = NSHostingController(
            rootView: ContentView(
                inputPath
            )
        )
        controller.sizingOptions = [.standardBounds]
        controller.view.frame = rect
        self.window.contentViewController = controller
        
    }
}
