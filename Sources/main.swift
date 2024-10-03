import ArgumentParser
import Cocoa
import Darwin.C
import FontLoader
import Foundation
import SwiftDotenv
import SwiftUI

try Dotenv.configure()
struct FontRenderer: ParsableCommand {
    @Argument() var fontPath: String?

    func run() {
        let targetFont: String? = fontPath ?? Dotenv["FR_FONT_PATH"]?.stringValue

        let app: FontRendererApplication = FontRendererApplication()
        if targetFont != nil {
            app.inputPath = targetFont!
        }
        app.run()
    }
}

FontRenderer.main()
