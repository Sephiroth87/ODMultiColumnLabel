//
//  ViewController.m
//  ODMultiColumnLabelDemo
//
//  Created by Fabio Ritrovato on 15/07/2014.
//  Copyright (c) 2014 orange in a day. All rights reserved.
//

#import "ViewController.h"
#import "ODMultiColumnLabel.h"

@interface ViewController ()

@property IBOutlet ODMultiColumnLabel *label;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.label.text = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
}

- (IBAction)numberOfColumnsSliderValueChanged:(UISlider *)slider
{
    self.label.numberOfColumns = nearbyint(slider.value * 3);
}

- (IBAction)columnsSpacingSliderValueChanged:(UISlider *)slider
{
    self.label.columnsSpacing = nearbyint(slider.value * 14);
}

@end
