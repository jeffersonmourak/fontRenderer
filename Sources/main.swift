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

//        
//        print("Using Font: \(fontPath)")
        
//        
        
        let app = FontRendererApplication()
        app.inputPath = fontPath
        app.run()
        
        
//        var data :NSData? = FileUtility.dataFromPath("data") as? NSData
        
//        let content = NSString(contentsOfFile: fontPath, encoding: )
        
        
    }
}

FontRenderer.main()
