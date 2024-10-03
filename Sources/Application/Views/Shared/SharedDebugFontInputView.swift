//
//  SharedDebugFontInputView.swift
//
//
//  Created by Jefferson Oliveira on 4/29/24.
//

import Foundation
import SwiftUI

struct DebugToggleButton: View {
    let target: DEBUG__FrOverlayOptions
    let icon: String
    var offIcon: String? = nil
    let help: String
    @State var isOn: Bool = false
    @Binding var debugLevels: [DEBUG__FrOverlayOptions]
    
    var body: some View {
        let currentIcon = Binding(get: {
            if offIcon == nil {
                return icon
            }
            
            return isOn ? icon : offIcon!
        },set: { _ in })
        
        Toggle(isOn: $isOn){
            Image(systemName: currentIcon.wrappedValue)
                .foregroundColor(isOn ? .green : .primary)
        }
        .onChange(of: isOn) {
            if !isOn {
                debugLevels = debugLevels.filter { e in e != target }
            } else {
                debugLevels.append(target)
            }
        }
        .help(help)
        .toggleStyle(.button)
    }
}

struct DebugButton: View {
    let target: DEBUG__FrOverlayOptions
    let action: () -> Void
    let icon: String
    let help: String
    @State var debugLevels: [DEBUG__FrOverlayOptions]
    
    init(target: DEBUG__FrOverlayOptions, action: @escaping () -> Void, icon: String, help: String, debugLevels: [DEBUG__FrOverlayOptions]) {
        self.target = target
        self.action = action
        self.icon = icon
        self.help = help
        self.debugLevels = debugLevels
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
            .foregroundColor(.primary)
        }
        .help(help)
        .toggleStyle(.button)
        
    }
}

func isColorOverlay(option: DEBUG__FrOverlayOptions) -> Bool {
    switch option {
        case .FontColorOverlay(_):
            return true
        default:
            return false
    }
}

func isColorOverlayEnabled(options: [DEBUG__FrOverlayOptions]) -> Bool {
    for option in options {
        if (!isColorOverlay(option: option)) {
            continue
        }
        return true
    }
    return false
}

struct SharedDebugFontInputView : View {
    @State var debugBorders: Bool = false
    @State var debugBaseline: Bool = false
    @State var debugContours: Bool = false
    @Binding var enabledDebugLevels: [DEBUG__FrOverlayOptions]
    @State var bgColor: Color = .gray
    
    var body: some View {
        
        HStack {
            Spacer()
            HStack {
                ControlGroup {
                    DebugToggleButton(
                        target: .BaselineOverlay,
                        icon: "underline",
                        help: "Debug Glyph baseline",
                        debugLevels: $enabledDebugLevels
                    )
                    DebugToggleButton(
                        target: .ColorContoursOverlay,
                        icon: "skew",
                        help: "Debug Glyph contours",
                        debugLevels: $enabledDebugLevels
                    )
                    DebugToggleButton(
                        target: .RealPointsOverlay,
                        icon: "point.3.filled.connected.trianglepath.dotted",
                        help: "Debug Glyph Points",
                        debugLevels: $enabledDebugLevels
                    )
                    DebugToggleButton(
                        target: .ImpliedPointsOverlay,
                        icon: "point.3.connected.trianglepath.dotted",
                        help: "Debug Glyph Implied Points",
                        debugLevels: $enabledDebugLevels
                    )
                    DebugToggleButton(
                        target: .PointsOutlineOverlay,
                        icon: "scope",
                        help: "Step over points",
                        debugLevels: $enabledDebugLevels
                    )
                    DebugToggleButton(
                        target: .MainLayerOutlineOverlay,
                        icon: "diamond",
                        offIcon: "diamond.inset.filled",
                        help: "Toggle Glyph outline",
                        debugLevels: $enabledDebugLevels
                    )
                    HStack {
                        Divider()
                        DebugToggleButton(
                            target: .FontColorOverlay(color: bgColor),
                            icon: "paintbrush.pointed.fill",
                            offIcon: "paintbrush.pointed",
                            help: "Step over points",
                            debugLevels: $enabledDebugLevels
                        )
                        if isColorOverlayEnabled(options: enabledDebugLevels) {
                            ColorPicker(selection: $bgColor, label: { Text("asd")}).onChange(of: bgColor) {
                                if isColorOverlayEnabled(options: enabledDebugLevels) {
                                    var updatedRules = enabledDebugLevels.filter({ !isColorOverlay(option: $0) })
                                    updatedRules.append(.FontColorOverlay(color: bgColor))
                                    
                                    enabledDebugLevels = updatedRules
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
