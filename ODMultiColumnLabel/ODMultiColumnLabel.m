//
//  ODMultiColumnLabel.m
//  ODMultiColumnLabel
//
//  Created by Fabio Ritrovato on 15/07/2014.
//  Copyright (c) 2014 orange in a day. All rights reserved.
//
// https://github.com/Sephiroth87/ODMultiColumnLabel
//

#import "ODMultiColumnLabel.h"

@interface ODMultiColumnLabel ()
{
    NSTextStorage *_textStorage;
    NSLayoutManager *_multicolumnManager;
    NSLayoutManager *_singlecolumnManager;
}

@end

@implementation ODMultiColumnLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _textStorage = [NSTextStorage new];
    
    _multicolumnManager = [NSLayoutManager new];
    
    _singlecolumnManager = [NSLayoutManager new];
    NSTextContainer *singlecolumnContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    singlecolumnContainer.lineFragmentPadding = 0.0f;
    [_singlecolumnManager addTextContainer:singlecolumnContainer];
    
    [_textStorage addLayoutManager:_multicolumnManager];
    [_textStorage addLayoutManager:_singlecolumnManager];
    
    _numberOfColumns = 1;
    _columnsSpacing = 14.0f;
    [self updateText];
}

- (void)updateText
{
    if (!self.text || !_multicolumnManager) {
        return;
    }
    
    // Ensure text storage has at least all attributes from the label properties
    NSShadow *shadow = [NSShadow new];
    shadow.shadowOffset = self.shadowOffset;
    shadow.shadowColor = self.shadowColor;
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.alignment = self.textAlignment;
    // BUG: with different line break modes at range 0, the text manager seems to layout only the first line fragment
    // and then stop, investigate more, for now, force WordWrapping
    // paragraph.lineBreakMode = self.lineBreakMode;
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{
                                 NSFontAttributeName: self.font,
                                 NSForegroundColorAttributeName: self.textColor,
                                 NSShadowAttributeName: shadow,
                                 NSParagraphStyleAttributeName: paragraph
                                 };
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.text attributes:attributes];
    // Copy existing attributes, we do it after because they may override the label default values
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, [self.attributedText length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        [string addAttributes:attrs range:range];
        if (range.location == 0 && attrs[NSParagraphStyleAttributeName]) {
            NSMutableParagraphStyle *paragraph = [attrs[NSParagraphStyleAttributeName] mutableCopy];
            // Same as above
            paragraph.lineBreakMode = NSLineBreakByWordWrapping;
            [string addAttribute:NSParagraphStyleAttributeName value:paragraph range:range];
        }
    }];
    [_textStorage setAttributedString:string];
    
    CGFloat columnWidth = (self.frame.size.width - MAX(0, (NSInteger)_numberOfColumns - 1) * _columnsSpacing) / (float)_numberOfColumns;
    
    NSTextContainer *singlecolumnContainer = _singlecolumnManager.textContainers[0];
    singlecolumnContainer.size = CGSizeMake( columnWidth, CGFLOAT_MAX);
    [_singlecolumnManager glyphRangeForTextContainer:singlecolumnContainer];
    
    __block CGFloat columnHeight = 0.0f;
    CGFloat proposedColumnHeight = ceilf([_singlecolumnManager usedRectForTextContainer:singlecolumnContainer].size.height / (float)_numberOfColumns);
    [_singlecolumnManager enumerateLineFragmentsForGlyphRange:NSMakeRange(0, [_textStorage length]) usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer *textContainer, NSRange glyphRange, BOOL *stop) {
        columnHeight += rect.size.height;
        if (columnHeight >= proposedColumnHeight) {
            *stop = YES;
        }
    }];
    
    while ([_multicolumnManager.textContainers count] != _numberOfColumns) {
        if ([_multicolumnManager.textContainers count] < _numberOfColumns) {
            NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeZero];
            container.lineFragmentPadding = 0;
            [_multicolumnManager addTextContainer:container];
            [_multicolumnManager glyphRangeForTextContainer:container];
        } else {
            [_multicolumnManager removeTextContainerAtIndex:[_multicolumnManager.textContainers count] - 1];
        }
    }
    
    [_multicolumnManager.textContainers enumerateObjectsUsingBlock:^(NSTextContainer *container, NSUInteger idx, BOOL *stop) {
        container.size = CGSizeMake(columnWidth, columnHeight);
    }];
    
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGFloat columnWidth = (self.frame.size.width - MAX(0, (NSInteger)_numberOfColumns - 1) * _columnsSpacing) / (float)_numberOfColumns;
    [_multicolumnManager.textContainers enumerateObjectsUsingBlock:^(NSTextContainer *container, NSUInteger idx, BOOL *stop) {
        CGPoint containerOrigin = CGPointMake(idx * (columnWidth + _columnsSpacing), 0.0f);
        NSRange containerRange = [_multicolumnManager glyphRangeForTextContainer:container];
        [_multicolumnManager drawBackgroundForGlyphRange:containerRange atPoint:containerOrigin];
        [_multicolumnManager drawGlyphsForGlyphRange:containerRange atPoint:containerOrigin];
    }];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateText];
}

- (CGSize)intrinsicContentSize
{
    return [self sizeThatFits:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    __block CGFloat height = 0.0f;
    [_multicolumnManager.textContainers enumerateObjectsUsingBlock:^(NSTextContainer *container, NSUInteger idx, BOOL *stop) {
        height = MAX(height, [_multicolumnManager usedRectForTextContainer:container].size.height);
    }];
    return CGSizeMake(size.width, height);
}

#pragma mark - Setters

- (void)setNumberOfColumns:(NSUInteger)numberOfColumns
{
    if (_numberOfColumns != numberOfColumns) {
        _numberOfColumns = numberOfColumns;
        [self updateText];
    }
}

- (void)setColumnsSpacing:(CGFloat)columnsSpacing
{
    _columnsSpacing = columnsSpacing;
    [self updateText];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self updateText];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self updateText];
}

- (void)setTextColor:(UIColor *)textColor
{
    [super setTextColor:textColor];
    [self updateText];
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    [super setShadowColor:shadowColor];
    [self updateText];
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    [super setShadowOffset:shadowOffset];
    [self updateText];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self updateText];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    [super setLineBreakMode:lineBreakMode];
    [self updateText];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self updateText];
}

@end
