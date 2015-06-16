//
//  KBHDatePicker.swift
//  KBHDatePicker
//
//  Created by Keith Hunter on 6/15/15.
//  Copyright © 2015 Keith Hunter. All rights reserved.
//

import UIKit


public protocol KBHDatePickerDelegate {
    func datePicker(datePicker: KBHDatePicker, monthChangedFrom oldMonth: String, toMonth newMonth: String)
    func datePicker(datePicker: KBHDatePicker, dateChangedFrom oldDate: NSDate, toDate newDate: NSDate)
}


public class KBHDatePicker: UICollectionView, KBHDatePickerDataSourceDelegate {

    public var datePickerDelegate: KBHDatePickerDelegate?
    public var selectedDate: NSDate { return _selectedDate.withoutTime() }
    public var month: String { return _month }
    public var indexPathForShowingSunday: NSIndexPath { return NSIndexPath(forRow: 7, inSection: 0) }
    
    private var datePickerDataSource: KBHDatePickerDataSource!
    private var _selectedDate: NSDate = NSDate()
    private var _month: String = ""
    
    
    // MARK: - Init
    
    private func setup() {
        self.pagingEnabled = true
        self.bounces = false
        self.bouncesZoom = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.backgroundColor = .whiteColor()
        
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .Horizontal
        flow.minimumInteritemSpacing = 0
        self.collectionViewLayout = flow
        
        self.datePickerDataSource = KBHDatePickerDataSource(collectionView: self, delegate: self)
        self.dataSource = self.datePickerDataSource
        self.delegate = self.datePickerDataSource
        
        self.selectToday()
        self.focusViewAnimated(false)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    public init(frame: CGRect) {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .Horizontal
        flow.minimumInteritemSpacing = 0
        
        super.init(frame: frame, collectionViewLayout: flow)
        self.setup()
    }
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setup()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    
    // MARK: - Misc
    
    override public func willMoveToWindow(newWindow: UIWindow?) {
        self.layer.shadowOffset = CGSizeMake(0, CGFloat(1)/UIScreen.mainScreen().scale)
        self.layer.shadowRadius = 0
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.25
    }
    
    public func reloadDataAnimated(animated: Bool) {
        super.reloadData()
        self.layoutSubviews()
        self.focusViewAnimated(animated)
    }
    
    
    // MARK: - Select/Scroll to Dates
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches where touch.tapCount == 1 {
            let point = touch.locationInView(self)
            let indexPath = self.indexPathForItemAtPoint(point)!
            let cell = self.cellForItemAtIndexPath(indexPath) as! KBHDatePickerCell
            self.selectDate(cell.date)
        }
    }
    
    public func selectToday() {
        self.datePickerDataSource.selectedDate = NSDate()
    }
    
    public func selectDate(date: NSDate) {
        self.datePickerDataSource.selectedDate = date
    }
    
    public func focusViewAnimated(animated: Bool) {
        self.scrollToItemAtIndexPath(self.indexPathForShowingSunday, atScrollPosition: .Left, animated: animated)
    }
    
    
    // MARK: - KBHDatePickerDataSourceDelegate
    
    public func datePickerDataSourceMonthChanged(newMonth: String) {
        let oldMonth = _month
        _month = newMonth
        self.datePickerDelegate?.datePicker(self, monthChangedFrom: oldMonth, toMonth: newMonth)
    }
    
    public func datePickerDataSourceSelectedDateChanged(newDate: NSDate) {
        let oldDate = _selectedDate
        _selectedDate = newDate
        self.datePickerDelegate?.datePicker(self, dateChangedFrom: oldDate, toDate: newDate)
    }
    
}
