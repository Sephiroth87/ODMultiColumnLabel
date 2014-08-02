//
//  ViewController.swift
//  ODMultiColumnLabelDemo-Swift
//
//  Created by Fabio Ritrovato on 31/07/2014.
//  Copyright (c) 2014 orange in a day. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var label: ODMultiColumnLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    }
    
    @IBAction func numberOfColumnsSliderValueChanged(slider: UISlider) {
        label.numberOfColumns = UInt(nearbyint(slider.value * 3))
    }
    
    @IBAction func columnsSpacingSliderValueChanged(slider: UISlider) {
        label.columnsSpacing = CGFloat(nearbyint(slider.value * 14))
    }
    
}

