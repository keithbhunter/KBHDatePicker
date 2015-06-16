//
//  KBHDatePickerCell.swift
//  KBHDatePicker
//
//  Created by Keith Hunter on 6/15/15.
//  Copyright © 2015 Keith Hunter. All rights reserved.
//

import UIKit

public class KBHDatePickerCell: UICollectionViewCell {
    
    public var date: NSDate = NSDate() {
        didSet {
            self.weekdayLabel.font = self.isPhone ? UIFont.systemFontOfSize(12) : UIFont.systemFontOfSize(17)
            self.weekdayLabel.text = self.isPhone ? self.date.oneLetterWeekday : self.date.threeLetterWeekday
            self.weekdayLabel.textColor = self.defaultTextColor
            self.weekdayLabel.sizeToFit()
            
            self.dayLabel.font = self.isPhone ? UIFont.systemFontOfSize(16) : UIFont.systemFontOfSize(17)
            self.dayLabel.text = "\(self.date.day)"
            self.dayLabel.textColor = self.selected ? .whiteColor() : self.defaultTextColor
            self.dayLabel.sizeToFit()
        }
    }
    override public var selected: Bool {
        didSet {
            self.backgroundCircle.hidden = !self.selected
            self.dayLabel.textColor = self.selected ? .whiteColor() : self.defaultTextColor
        }
    }
    
    private var weekdayLabel: UILabel!
    private var dayLabel: UILabel!
    private var backgroundCircle: KBHCircleView!
    private var isPhone: Bool { return UIDevice.currentDevice().userInterfaceIdiom == .Phone }
    private var defaultTextColor: UIColor { return self.date.isWeekend ? UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.0) : .blackColor() }
    
    
    // MARK: - Init
    
    public class func reuseIdentifier() -> String {
        return "KBHDatePickerCell"
    }
    
    private func setup() {
        self.weekdayLabel = UILabel()
        self.dayLabel = UILabel()
        self.backgroundCircle = KBHCircleView()
        
        self.addSubview(self.weekdayLabel)
        self.addSubview(self.backgroundCircle)
        self.addSubview(self.dayLabel)
        
        self.weekdayLabel.font = UIFont.systemFontOfSize(12)
        self.dayLabel.font = UIFont.boldSystemFontOfSize(16)
        self.backgroundCircle.tintColor = UIApplication.sharedApplication().keyWindow!.tintColor
        self.backgroundCircle.backgroundColor = .clearColor()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.weekdayLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dayLabel.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundCircle.translatesAutoresizingMaskIntoConstraints = false
        
        self.addDefaultConstraints()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    public init() {
        super.init(frame: CGRectZero)
        self.setup()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    
    // MARK: - Constraints
    
    private func addDefaultConstraints() {
        self.removeConstraints(self.constraints)
        
        if self.isPhone {
            self.addConstraintsForPhone()
        } else {
            self.addConstraintsForPad()
        }
        
        self.setNeedsDisplay()
    }
    
    private func addConstraintsForPhone() {
        let weekdayCenterX = NSLayoutConstraint(
            item: self.weekdayLabel,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0
        )
        let weekdayCenterY = NSLayoutConstraint(
            item: self.weekdayLabel,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterY,
            multiplier: 1,
            constant: -(self.frame.size.height / 6.0)
        )
        
        let dayCenterX = NSLayoutConstraint(
            item: self.dayLabel,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0
        )
        let dayCenterY = NSLayoutConstraint(
            item: self.dayLabel,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterY,
            multiplier: 1,
            constant: self.frame.size.height / 6.0
        )
        
        self.addConstraints([weekdayCenterX, weekdayCenterY, dayCenterX, dayCenterY])
        
        self.addConstraintsForCircle()
    }
    
    private func addConstraintsForPad() {
        let weekdayCenterX = NSLayoutConstraint(
            item: self.weekdayLabel,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterX,
            multiplier: 1,
            constant: -(self.frame.size.height / 6.0)
        )
        let weekdayCenterY = NSLayoutConstraint(
            item: self.weekdayLabel,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0
        )
        
        let dayCenterX = NSLayoutConstraint(
            item: self.dayLabel,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterX,
            multiplier: 1,
            constant: self.frame.size.height / 6.0
        )
        let dayCenterY = NSLayoutConstraint(
            item: self.dayLabel,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0
        )
        
        self.addConstraints([weekdayCenterX, weekdayCenterY, dayCenterX, dayCenterY])
        
        self.addConstraintsForCircle()
    }
    
    private func addConstraintsForCircle() {
        let circleCenterX = NSLayoutConstraint(
            item: self.backgroundCircle,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: self.dayLabel,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0
        )
        let circleCenterY = NSLayoutConstraint(
            item: self.backgroundCircle,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self.dayLabel,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0
        )

        let circleWidth = NSLayoutConstraint(
            item: self.backgroundCircle,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: 25
        )
        let circleHeight = NSLayoutConstraint(
            item: self.backgroundCircle,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: 25
        )
        
        self.backgroundCircle.addConstraints([circleHeight, circleWidth])
        self.addConstraints([circleCenterX, circleCenterY])
    }
    
}
