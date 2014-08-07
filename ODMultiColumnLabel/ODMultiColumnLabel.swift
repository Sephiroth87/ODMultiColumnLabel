//
//  ODMultiColumnLabel.swift
//  ODMultiColumnLabel
//
//  Created by Fabio Ritrovato on 31/07/2014.
//  Copyright (c) 2014 orange in a day. All rights reserved.
//
// https://github.com/Sephiroth87/ODMultiColumnLabel
//

import UIKit

class ODMultiColumnLabel: UILabel {
    
    var numberOfColumns: UInt = 1 { didSet { updateText() } }
    var columnsSpacing: CGFloat = 14.0 { didSet { updateText() } }
    
    private let textStorage: NSTextStorage
    private let multicolumnManager: NSLayoutManager
    private let singleColumnManager: NSLayoutManager
    
    override var text: String! { didSet { updateText() } }
    override var font: UIFont! { didSet { updateText() } }
    override var textColor: UIColor! { didSet { updateText() } }
    override var shadowColor: UIColor! { didSet { updateText() } }
    override var shadowOffset: CGSize { didSet { updateText() } }
    override var textAlignment: NSTextAlignment { didSet { updateText() } }
    override var lineBreakMode: NSLineBreakMode { didSet { updateText() } }
    override var attributedText: NSAttributedString! { didSet { updateText() } }

    override init(frame: CGRect) {
        textStorage = NSTextStorage()
        multicolumnManager = NSLayoutManager()
        singleColumnManager = NSLayoutManager()
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder!) {
        textStorage = NSTextStorage()
        multicolumnManager = NSLayoutManager()
        singleColumnManager = NSLayoutManager()
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let singlecolumnContainer = NSTextContainer(size: CGSizeZero)
        singlecolumnContainer.lineFragmentPadding = 0.0
        singleColumnManager.addTextContainer(singlecolumnContainer)
        
        textStorage.addLayoutManager(multicolumnManager)
        textStorage.addLayoutManager(singleColumnManager)
    }
    
    private func updateText() {
        if (text == nil) {
            return
        }
        
        var shadow = NSShadow()
        shadow.shadowOffset = shadowOffset;
        shadow.shadowColor = shadowColor;
        var paragraph = NSMutableParagraphStyle()
        paragraph.alignment = textAlignment
        // BUG: with different line break modes at range 0, the text manager seems to layout only the first line fragment
        // and then stop, investigate more, for now, force WordWrapping
        // paragraph.lineBreakMode = lineBreakMode
        paragraph.lineBreakMode = .ByWordWrapping
        let attributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor,
            NSShadowAttributeName: shadow,
            NSParagraphStyleAttributeName: paragraph
        ]
        var string = NSMutableAttributedString(string: text, attributes: attributes)
        // Copy existing attributes, we do it after because they may override the label default values
        attributedText.enumerateAttributesInRange(NSRange(location: 0, length: attributedText.length), options: nil) { (attrs, range, stop) in
            string.addAttributes(attrs, range: range)
            if range.location == 0 {
                if let paragraph = attrs[NSParagraphStyleAttributeName] as? NSParagraphStyle {
                    var newParagraph = paragraph.mutableCopy() as NSMutableParagraphStyle
                    // Same as above
                    newParagraph.lineBreakMode = .ByWordWrapping
                    string.addAttribute(NSParagraphStyleAttributeName, value: newParagraph, range: range)
                }
            }
        }
        textStorage.setAttributedString(string)
        
        let columnWidth = (frame.width - CGFloat(max(0, numberOfColumns - 1.0)) * columnsSpacing) / CGFloat(numberOfColumns)
        
        let singlecolumnContainer = singleColumnManager.textContainers[0] as NSTextContainer
        singlecolumnContainer.size = CGSize(width: columnWidth, height: CGFloat.max)
        singleColumnManager.glyphRangeForTextContainer(singlecolumnContainer)

        var columnHeight: CGFloat = 0.0
        let proposedColumnHeight = ceil(singleColumnManager.usedRectForTextContainer(singlecolumnContainer).height / CGFloat(numberOfColumns))
        singleColumnManager.enumerateLineFragmentsForGlyphRange(NSRange(location: 0, length: textStorage.length)) { (rect, usedRect, textContainer, glyphRange, stop) in
            columnHeight += rect.height
            if columnHeight >= proposedColumnHeight {
                stop.initialize(true)
            }
        }

        while multicolumnManager.textContainers.count != Int(numberOfColumns) {
            if multicolumnManager.textContainers.count < Int(numberOfColumns) {
                let container = NSTextContainer(size: CGSize.zeroSize)
                container.lineFragmentPadding = 0.0
                multicolumnManager.addTextContainer(container)
                multicolumnManager.glyphRangeForTextContainer(container)
            } else {
                multicolumnManager.removeTextContainerAtIndex(multicolumnManager.textContainers.count - 1)
            }
        }
     
        for container in multicolumnManager.textContainers as [NSTextContainer] {
            container.size = CGSize(width: CGFloat(columnWidth), height: columnHeight)
        }
        
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
    }
    
    // MARK: - Drawing
    
    override func drawRect(rect: CGRect) {
        let columnWidth = (frame.width - CGFloat(max(0, numberOfColumns - 1.0)) * columnsSpacing) / CGFloat(numberOfColumns)
        for (index, container) in enumerate(multicolumnManager.textContainers as [NSTextContainer]) {
            let containerOrigin = CGPoint(x: CGFloat(index) * (columnWidth + columnsSpacing), y: 0.0)
            let containerRange = multicolumnManager.glyphRangeForTextContainer(container)
            multicolumnManager.drawBackgroundForGlyphRange(containerRange, atPoint: containerOrigin)
            multicolumnManager.drawGlyphsForGlyphRange(containerRange, atPoint: containerOrigin)
        }
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateText()
    }
    
    override func intrinsicContentSize() -> CGSize {
        return sizeThatFits(CGSize(width: frame.width, height: CGFloat.max))
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        var height: CGFloat = 0.0
        for container in multicolumnManager.textContainers as [NSTextContainer] {
            height = max(height, multicolumnManager.usedRectForTextContainer(container).height)
        }
        return CGSize(width: size.width, height: height)
    }
    
}
