import Foundation
import ArgumentParser
import FontLoader
import Darwin.C
import Cocoa


func readFile(fromPath path: String) -> Data? {
    let fileURL = URL(fileURLWithPath: path)

    do {
        let data = try Data(contentsOf: fileURL)
        return data
    } catch {
        print("Error reading data: \(error)")
        return nil
    }
}


struct FontRenderer: ParsableCommand {
    @Argument() var fontPath: String
   

    func run() {
        guard let fontData = readFile(fromPath: fontPath) else {
            print("No File at \(fontPath)")
            return
        }
        
        print("Using Font: \(fontPath)")
        
        let app = ViewportApplication()
        app.run()
        
        let font = FontLoader(withData: fontData)
        font.getGlyph()
        
        
        
//        var data :NSData? = FileUtility.dataFromPath("data") as? NSData
        
//        let content = NSString(contentsOfFile: fontPath, encoding: )
        
        
    }
}

FontRenderer.main()
