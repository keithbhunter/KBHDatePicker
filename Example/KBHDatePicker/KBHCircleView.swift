//
//  KBHCircleView.swift
//  KBHDatePicker
//
//  Created by Keith Hunter on 6/15/15.
//  Copyright © 2015 Keith Hunter. All rights reserved.
//

import UIKit

class KBHCircleView: UIView {
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        self.tintColor.setFill()
        CGContextFillEllipseInRect(context, rect)
    }
    
}
