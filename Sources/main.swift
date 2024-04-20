import Foundation
import ArgumentParser
import FontLoader

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


struct Random: ParsableCommand {
    @Argument() var fontPath: String

    func run() {
        
        guard let fontData = readFile(fromPath: fontPath) else {
            print("No File at \(fontPath)")
            return
        }
        
        let font = FontLoader(withData: fontData)
        
        print(font.glyf)
        
//        var data :NSData? = FileUtility.dataFromPath("data") as? NSData
        
//        let content = NSString(contentsOfFile: fontPath, encoding: )
        
        
    }
}

Random.main()
