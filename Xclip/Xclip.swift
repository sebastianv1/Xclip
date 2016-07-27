//
//  Xclip.swift
//
//  Created by sebastians on 7/26/16.
//  Copyright © 2016 sebastians. All rights reserved.
//

import AppKit

var sharedPlugin: Xclip?

class Xclip: NSObject {

    var bundle: NSBundle
    lazy var center = NSNotificationCenter.defaultCenter()
    var clipboardMenu : ClipboardWindow!

    // MARK: - Initialization

    class func pluginDidLoad(bundle: NSBundle) {
        let allowedLoaders = bundle.objectForInfoDictionaryKey("me.delisa.XcodePluginBase.AllowedLoaders") as! Array<String>
        if allowedLoaders.contains(NSBundle.mainBundle().bundleIdentifier ?? "") {
            sharedPlugin = Xclip(bundle: bundle)
        }
    }

    init(bundle: NSBundle) {
        self.bundle = bundle

        super.init()
        // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
        if (NSApp != nil && NSApp.mainMenu == nil) {
            center.addObserver(self, selector: #selector(self.applicationDidFinishLaunching), name: NSApplicationDidFinishLaunchingNotification, object: nil)
        } else {
            initializeAndLog()
        }
    }

    private func initializeAndLog() {
        let name = bundle.objectForInfoDictionaryKey("CFBundleName")
        let version = bundle.objectForInfoDictionaryKey("CFBundleShortVersionString")
        let status = initialize() ? "loaded successfully" : "failed to load"
        NSLog("\(name) : \(version) : \(status)")
    }

    func applicationDidFinishLaunching() {
        center.removeObserver(self, name: NSApplicationDidFinishLaunchingNotification, object: nil)
        initializeAndLog()
    }

    // MARK: - Implementation

    func initialize() -> Bool {
        guard let mainMenu = NSApp.mainMenu else { return false }
        guard let item = mainMenu.itemWithTitle("Edit") else { return false }
        guard let submenu = item.submenu else { return false }
        
        let actionMenuItem = NSMenuItem(title:"Xclip", action:#selector(self.doMenuAction), keyEquivalent:"V")
        
        actionMenuItem.target = self
        
        submenu.addItem(NSMenuItem.separatorItem())
        submenu.addItem(actionMenuItem)
        
        let height = 500.0 as CGFloat
        let width = 400.0 as CGFloat
        
        self.clipboardMenu = ClipboardWindow(contentRect: NSMakeRect(0, 0, width, height), styleMask: NSTitledWindowMask | NSClosableWindowMask, backing: NSBackingStoreType.Buffered, defer: false)
        self.clipboardMenu.center()
        self.clipboardMenu.releasedWhenClosed = false
        
        return true

    }

    func doMenuAction() {
        // Present clipboard window
        self.clipboardMenu.setOriginalWindow(NSApp.mainWindow!)
        self.clipboardMenu.makeKeyAndOrderFront(NSApp)
        
        self.clipboardMenu.selectTableViewIndex(0)
    }
}

