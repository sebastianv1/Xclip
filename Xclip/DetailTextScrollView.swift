//
//  DetailTextScrollView.swift
//  MultilevelClipboard
//
//  Created by sebastians on 7/20/16.
//  Copyright © 2016 sebastians. All rights reserved.
//

import Foundation
import AppKit

class DetailTextScrollView : NSView {
    var scrollView : NSScrollView!
    var textView : NSTextView!

    override init(frame frameRect: NSRect) {
    
        super.init(frame: frameRect)
        let originFrameRect = NSRect(x: 0.0, y: 0.0, width: frameRect.size.width, height: frameRect.size.height)
        self.scrollView = NSScrollView(frame: originFrameRect)
        self.scrollView.borderType = .LineBorder
        self.scrollView.hasVerticalRuler = true
        self.scrollView.hasHorizontalRuler = false
        self.scrollView.autoresizingMask = .ViewHeightSizable
        
        self.textView = NSTextView(frame: originFrameRect)
        self.textView.minSize = NSSize(width: 0, height: 0)
        self.textView.maxSize = NSSize(width: CGFloat.max, height: CGFloat.max)
        self.textView.verticallyResizable = true
        self.textView.horizontallyResizable = false
        self.textView.autoresizingMask = .ViewWidthSizable
        self.textView.textContainer?.containerSize = NSSize(width: self.scrollView.contentSize.width, height: CGFloat.max)
        self.textView.textContainer?.widthTracksTextView = true
        self.textView.editable = false
        self.textView.selectable = false
        
        self.scrollView.documentView = self.textView
        self.addSubview(self.scrollView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
