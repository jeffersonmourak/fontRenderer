//
//  SharedDebugFontInputView.swift
//
//
//  Created by Jefferson Oliveira on 4/29/24.
//

import Foundation
import SwiftUI

struct DebugToggleButton: View {
    let target: DebugLevel
    @Binding var debugLevels: [DebugLevel]
    let icon: String
    let help: String
    @State var isOn: Bool = false
    
    var body: some View {
        Toggle(isOn: $isOn){
            Image(systemName: icon).foregroundColor(isOn ? .green : .primary)
        }
        .onChange(of: isOn) {
            if !isOn {
                debugLevels = debugLevels.filter{ e in e != target }
            } else {
                debugLevels.append(target)
            }
        }
        .help(help)
        .toggleStyle(.button)
        
    }
}

struct SharedDebugFontInputView : View {
    @State var debugBorders: Bool = false
    @State var debugBaseline: Bool = false
    @State var debugContours: Bool = false
    @Binding var enabledDebugLevels: [DebugLevel]
    
    var body: some View {
        HStack {
            Spacer()
            HStack {
                ControlGroup {
                    DebugToggleButton(target: .Baseline, debugLevels: $enabledDebugLevels, icon: "underline", help: "Debug Glyph baseline")
                    DebugToggleButton(target: .Contours, debugLevels: $enabledDebugLevels, icon: "skew", help: "Debug Glyph contours")
                    DebugToggleButton(target: .Borders, debugLevels: $enabledDebugLevels, icon: "squareshape.squareshape.dotted", help: "Debug Glyph border")
                }
            }
        }
    }
}
