import Foundation
import ArgumentParser
import FontLoader
import Darwin.C
import Cocoa

struct FontRenderer: ParsableCommand {
    @Argument() var fontPath: String
   
    func run() {
        let app = FontRendererApplication()
        app.inputPath = fontPath
        app.run() 
    }
}

FontRenderer.main()
