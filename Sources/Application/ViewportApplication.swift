//
//  ViewportApplication.swift
//  SwiftEngine
//
//  Created by Jefferson Oliveira on 2/20/24.
//
import Foundation
import AppKit
import SwiftMath
import SwiftUI

class ViewportApplication: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var windowSize = Signal<Size>(Size(640, 480));
    var window: NSWindow!
    
    func makeMainMenu() -> NSMenu {
        let mainMenu            = NSMenu() // `title` really doesn't matter.
        let mainAppMenuItem     = NSMenuItem(title: "Application", action: nil, keyEquivalent: "") // `title` really doesn't matter.
        mainMenu.addItem(mainAppMenuItem)
        
        let appMenu             = NSMenu() // `title` really doesn't matter.
        mainAppMenuItem.submenu = appMenu
        
        let appServicesMenu     = NSMenu()
        NSApp.servicesMenu      = appServicesMenu
        
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Hide Me", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem({ () -> NSMenuItem in
            let m = NSMenuItem(title: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
            m.keyEquivalentModifierMask = [.command, .option]
            return m
        }())
        appMenu.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        
        return mainMenu
    }
    
    public override init() {
        let window = NSWindow(contentRect: NSMakeRect(0, 0, CGFloat(windowSize.value.width), CGFloat(windowSize.value.height)), styleMask: [NSWindow.StyleMask.titled, NSWindow.StyleMask.closable, NSWindow.StyleMask.miniaturizable, NSWindow.StyleMask.resizable], backing: .buffered, defer: false)
        window.center()
        window.title = "Font Renderer"
        self.window = window
        super.init()
        let application = NSApplication.shared
        application.setActivationPolicy(NSApplication.ActivationPolicy.regular)
        application.delegate = self
        application.activate(ignoringOtherApps:true)
        NSApplication.shared.mainMenu = makeMainMenu()
    }
    
    open func applicationDidFinishLaunching(_ notification: Notification) {
        var rect = window.frame
        rect.origin.x = 0.0
        rect.origin.y = 0.0
        
        let child = NSHostingController(rootView: ContentView())
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.frame = rect
        self.window.contentView = child.view
        self.window.delegate = self
        self.window.makeKeyAndOrderFront(window)
        self.applicationCreate()
    }
    
    open func windowWillClose(_ notification: Notification) {
        self.applicationClose()
        NSApplication.shared.terminate(0)
    }
    
    open func windowDidResize(_ notification: Notification) {
        let size = Size(Float(window.frame.size.width), Float(window.frame.size.height))
        self.windowDidResize(size)
    }
    
    open func run() {
        NSApplication.shared.run()
    }
    
    // base functions
    open func applicationCreate() {}
    open func applicationClose() {}
    
    open func windowDidResize(_ size:Size) {}
    
    // MouseEventDelegate
    
    open func mouseDown(_ point:Point, button:Int) {}
    open func mouseMove(_ point:Point) {}
    open func mouseUp(_ point:Point) {}
}