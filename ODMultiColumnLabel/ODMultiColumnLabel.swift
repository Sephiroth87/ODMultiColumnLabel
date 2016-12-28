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
    
    required init?(coder aDecoder: NSCoder) {
        textStorage = NSTextStorage()
        multicolumnManager = NSLayoutManager()
        singleColumnManager = NSLayoutManager()
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let singlecolumnContainer = NSTextContainer(size: .zero)
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
        paragraph.lineBreakMode = .byWordWrapping
        let attributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor,
            NSShadowAttributeName: shadow,
            NSParagraphStyleAttributeName: paragraph
        ] as [String : Any]
        var string = NSMutableAttributedString(string: text, attributes: attributes)
        // Copy existing attributes, we do it after because they may override the label default values
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length), options: []) { (attrs, range, stop) in
            string.addAttributes(attrs, range: range)
            if range.location == 0 {
                if let paragraph = attrs[NSParagraphStyleAttributeName] as? NSParagraphStyle {
                    var newParagraph = paragraph.mutableCopy() as! NSMutableParagraphStyle
                    // Same as above
                    newParagraph.lineBreakMode = .byWordWrapping
                    string.addAttribute(NSParagraphStyleAttributeName, value: newParagraph, range: range)
                }
            }
        }
        textStorage.setAttributedString(string)
        
        let columnWidth = (frame.width - CGFloat(max(0, UInt(numberOfColumns - 1))) * columnsSpacing) / CGFloat(numberOfColumns)
        
        let singlecolumnContainer = singleColumnManager.textContainers[0] as NSTextContainer
        singlecolumnContainer.size = CGSize(width: columnWidth, height: CGFloat.greatestFiniteMagnitude)
        singleColumnManager.glyphRange(for: singlecolumnContainer)

        var columnHeight: CGFloat = 0.0
        let proposedColumnHeight = ceil(singleColumnManager.usedRect(for: singlecolumnContainer).height / CGFloat(numberOfColumns))
        singleColumnManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: textStorage.length)) { (rect, usedRect, textContainer, glyphRange, stop) in
            columnHeight += rect.height
            if columnHeight >= proposedColumnHeight {
                stop.initialize(to: true)
            }
        }

        while multicolumnManager.textContainers.count != Int(numberOfColumns) {
            if multicolumnManager.textContainers.count < Int(numberOfColumns) {
                let container = NSTextContainer(size: .zero)
                container.lineFragmentPadding = 0.0
                multicolumnManager.addTextContainer(container)
                multicolumnManager.glyphRange(for: container)
            } else {
                multicolumnManager.removeTextContainer(at: multicolumnManager.textContainers.count - 1)
            }
        }
     
        for container in multicolumnManager.textContainers as [NSTextContainer] {
            container.size = CGSize(width: CGFloat(columnWidth), height: columnHeight)
        }
        
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        let columnWidth = (frame.width - CGFloat(max(0, UInt(numberOfColumns - 1))) * columnsSpacing) / CGFloat(numberOfColumns)
        for (index, container) in (multicolumnManager.textContainers as [NSTextContainer]).enumerated() {
            let containerOrigin = CGPoint(x: CGFloat(index) * (columnWidth + columnsSpacing), y: 0.0)
            let containerRange = multicolumnManager.glyphRange(for: container)
            multicolumnManager.drawBackground(forGlyphRange: containerRange, at: containerOrigin)
            multicolumnManager.drawGlyphs(forGlyphRange: containerRange, at: containerOrigin)
        }
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateText()
    }
    
    override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude))
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var height: CGFloat = 0.0
        for container in multicolumnManager.textContainers as [NSTextContainer] {
            height = max(height, multicolumnManager.usedRect(for: container).height)
        }
        return CGSize(width: size.width, height: height)
    }
    
}
