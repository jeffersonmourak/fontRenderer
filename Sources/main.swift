import Foundation
import ArgumentParser
import FontLoader
import Darwin.C
import Cocoa
import SwiftUI

struct FontRenderer: ParsableCommand {
    @Argument() var fontPath: String?
   
    func run() {
        let app = FontRendererApplication()
        if fontPath != nil {
            app.inputPath = fontPath!
        }
        app.run()
    }
}

FontRenderer.main()
