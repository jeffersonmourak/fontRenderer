//
//  SharedFontInputView.swift
//
//
//  Created by Jefferson Oliveira on 4/29/24.
//

import Foundation
import SwiftUI

struct SharedFontInputView : View {
    @Binding var fontPath: String
    
    func openDialog () {
        if let url = NSOpenPanel().selectUrl {
            fontPath = url.path
            
        }
    }
    
    var body: some View {
        var naviationTitle = Binding(get: {
            return fontPath.components(separatedBy: "/").last ?? Constants.productName
        }, set: { _ in
            
        })
        HStack {
            Spacer()
            Button(action: { openDialog() }, label: {
                Image(systemName: "square.and.arrow.down")
            }).help("Open a font file").navigationTitle(naviationTitle)
        }
    }
}
