//
//  SharedDebugFontInputView.swift
//
//
//  Created by Jefferson Oliveira on 4/29/24.
//

import Foundation
import SwiftUI

struct SharedDebugFontInputView : View {
    @State var debugBaseline: Bool = false
    @State var debugContours: Bool = false
    @Binding var enabledDebugLevels: [DebugLevel]
    
    func toggleBaseline() {
        if enabledDebugLevels.contains(.Baseline) {
            enabledDebugLevels = enabledDebugLevels.filter{ e in e != .Baseline }
        } else {
            enabledDebugLevels.append(.Baseline)
        }
    }
    
    var body: some View {
        HStack {
            Spacer()
            HStack {
                Toggle(isOn: $debugBaseline){
                    Image(systemName: "underline")
                }
                .onChange(of: debugBaseline) {
                    if !debugBaseline {
                        enabledDebugLevels = enabledDebugLevels.filter{ e in e != .Baseline }
                    } else {
                        enabledDebugLevels.append(.Baseline)
                    }
                }
                .help("Debug Glyph contours")
                .toggleStyle(.button)
                
                Toggle(isOn: $debugContours){
                    Image(systemName: "skew")
                }
                .onChange(of: debugContours) {
                    if !debugContours {
                        enabledDebugLevels = enabledDebugLevels.filter{ e in e != .Contours }
                    } else {
                        enabledDebugLevels.append(.Contours)
                    }
                }
                .help("Debug Glyph baseline")
                .toggleStyle(.button)
            }
        }
    }
}
