//
//  ODMultiColumnLabel.h
//  ODMultiColumnLabel
//
//  Created by Fabio Ritrovato on 15/07/2014.
//  Copyright (c) 2014 orange in a day. All rights reserved.
//
// https://github.com/Sephiroth87/ODMultiColumnLabel
//

#import <UIKit/UIKit.h>

@interface ODMultiColumnLabel : UILabel

@property (nonatomic, assign) IBInspectable NSUInteger numberOfColumns;   // default is 1
@property (nonatomic, assign) IBInspectable CGFloat columnsSpacing;       // default is 14.0

@end
