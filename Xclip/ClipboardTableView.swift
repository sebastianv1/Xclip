//
//  ClipboardTableView.swift
//  MultilevelClipboard
//
//  Created by sebastians on 7/17/16.
//  Copyright © 2016 sebastians. All rights reserved.
//

import Foundation
import AppKit

class ClipboardTableView : NSView, NSTableViewDelegate, NSTableViewDataSource {
    let tableView : NSTableView!
    let tableContainer : NSScrollView!
    var clipboardItems : [String] = []
    var originalWindow : NSWindow = NSWindow()

    init(frame frameRect: NSRect, clipboardItems: [String]) {
        self.tableView = NSTableView(frame: frameRect)
        self.tableContainer = NSScrollView(frame: frameRect)
        self.clipboardItems = clipboardItems
        
        let mainColumn = NSTableColumn(identifier: "Copies")
        mainColumn.title = "Active Copies"
        self.tableView.addTableColumn(mainColumn)
        
        self.tableContainer.documentView = self.tableView
        self.tableContainer.hasVerticalScroller = true
        super.init(frame: frameRect)
        
        self.tableView.setDelegate(self)
        self.tableView.setDataSource(self)
        self.tableView.sizeLastColumnToFit()
        self.tableView.allowsColumnResizing = false
        self.tableView.doubleAction = #selector(ClipboardTableView.executePaste(_:))
        
        self.addSubview(self.tableContainer)
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NSTableViewDelegate.tableViewSelectionDidChange(_:)), name: NSTableViewSelectionDidChangeNotification, object: self.tableView)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: String formatting for cells
    func cellTitleString(string: String) -> String {
        let maxCharCount = 50
        let trimmedString = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if trimmedString.characters.count > maxCharCount {
            var shorterString = trimmedString.substringToIndex(trimmedString.startIndex.advancedBy(maxCharCount - 3))
            shorterString = shorterString + "..."
            return shorterString
        } else {
            return trimmedString
        }
    }
    
    func insertCopyItem(copyStr: String) {
        self.clipboardItems.insert(copyStr, atIndex: 0)
        self.tableView.reloadData()
    }
    
    
    // MARK: Paste actions
    func executePaste(event: AnyObject?) {
        let index = self.tableView.selectedRow
        self.window?.orderBack(NSApp)
        self.window?.resignKeyWindow()
        self.originalWindow.orderFront(NSApp)
        self.originalWindow.makeKeyAndOrderFront(NSApp)
        
        NSPasteboard.generalPasteboard().setString(self.clipboardItems[index], forType: NSPasteboardTypeString)
        NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self)
        NSPasteboard.generalPasteboard().setString(self.clipboardItems[0], forType: NSPasteboardTypeString)
        
        self.window?.close()
    }
    
    
    // MARK: NSTableView delegate methods
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.clipboardItems.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Frame doesn't matter since table cell will do the sizing
        let tableString = NSTextField(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
        tableString.stringValue = cellTitleString(self.clipboardItems[row])
        tableString.drawsBackground = false
        tableString.backgroundColor = NSColor.clearColor()
        tableString.editable = false
        tableString.bezeled = false
        tableString.selectable = false
        return tableString
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 25.0
    }
    
    // MARK: Notification methods
    func tableViewSelectionDidChange(notification: NSNotification) {
        guard let tableView = notification.object as? NSTableView else {
            NSLog("Failed cast")
            return
        }
        let index = tableView.selectedRow
        let copyText = self.clipboardItems[index]
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.updateDetailNotification, object: copyText)

    }
    
    override func keyDown(theEvent: NSEvent) {
        self.interpretKeyEvents([theEvent])
    }
    
    override func insertNewline(sender: AnyObject?) {
        self.executePaste(nil)
    }
    
    
}
