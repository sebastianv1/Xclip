//
//  ClipboardWindow.swift
//  MultilevelClipboard
//
//  Created by sebastians on 7/20/16.
//  Copyright © 2016 sebastians. All rights reserved.
//

import Foundation
import AppKit

class ClipboardWindow : NSWindow {
    
    var clipboardTableView : ClipboardTableView!
    var clipboardDetailView : DetailTextScrollView!
    
    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        self.contentView = ClipboardSubview(frame: self.contentLayoutRect)
        self.title = "Xclipper"
        
        // Add tableview with list of copies
        let clipboardTableLayout = NSRect(x: 0, y: 0, width: self.contentLayoutRect.size.width, height: self.contentLayoutRect.height / 3)
        self.clipboardTableView = ClipboardTableView(frame: clipboardTableLayout, clipboardItems: [])
        self.contentView?.addSubview(self.clipboardTableView)
        
        // Add detail to diplay entire copy
        let detailLayout = NSRect(x: 0, y: clipboardTableLayout.size.height, width: clipboardTableLayout.size.width, height: self.contentLayoutRect.size.height - clipboardTableLayout.size.height)
        self.clipboardDetailView = DetailTextScrollView(frame: detailLayout)
        self.contentView?.addSubview(self.clipboardDetailView)
        
        // Poll the pasteboard
        NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: #selector(ClipboardWindow.pollClipboard), userInfo: nil, repeats: true)
        
        // Register notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ClipboardWindow.updateDetailText(_:)), name:Constants.Notifications.updateDetailNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateDetailText(notification: NSNotification) {
        guard let copyText = notification.object as? String else {
            NSLog("Couldn't cast as string to detail veiw")
            return
        }
        self.clipboardDetailView.textView.string = copyText
    }
    
    func setOriginalWindow(window: NSWindow) {
        self.clipboardTableView.originalWindow = window
    }
    
    func selectTableViewIndex(index: NSInteger) {
        self.clipboardTableView.tableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
    }
    
    // Last known copy in clipboard list
    private func getTopClipboardString() -> String {
        if self.clipboardTableView.clipboardItems.count != 0 {
            return self.clipboardTableView.clipboardItems.first!
        } else {
            return ""
        }
    }
    // Current clipboard value
    private func currentClipboardString() -> String {
        if let str = NSPasteboard.generalPasteboard().pasteboardItems?.first {
            return str.stringForType(NSPasteboardTypeString)!
        } else {
            return ""
        }
    }
    
    @objc private func pollClipboard() {
        if currentClipboardString() != getTopClipboardString() {
            if self.clipboardTableView.clipboardItems.count == 10 {
                self.clipboardTableView.clipboardItems.popLast()
            }
            self.clipboardTableView.insertCopyItem(currentClipboardString())
        }
    }
}

// Override subview class since I want to layout views with origin at top left instead of bottom left
class ClipboardSubview : NSView {
    override var flipped: Bool {
        get {
            return true
        }
    }
}
