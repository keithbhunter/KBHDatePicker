//
//  KBHDatePickerDataSource.swift
//  KBHDatePicker
//
//  Created by Keith Hunter on 6/15/15.
//  Copyright © 2015 Keith Hunter. All rights reserved.
//

import UIKit

private let kNumberOfDaysToShow = 7


public protocol KBHDatePickerDataSourceDelegate {
    func datePickerDataSourceMonthChanged(newMonth: String)
    func datePickerDataSourceSelectedDateChanged(newDate: NSDate)
}


public class KBHDatePickerDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public var selectedDate: NSDate = NSDate() { didSet { self.selectDate(self.selectedDate) } }
    public var delegate: KBHDatePickerDataSourceDelegate?
    
    private var collectionView: UICollectionView!
    private var isScrolling: Bool = false
    private var dates: [NSDate] = []
    
    
    // MARK: - Init
    
    private func setupCollectionView(collectionView: UICollectionView) {
        collectionView.registerClass(KBHDatePickerCell.classForCoder(), forCellWithReuseIdentifier: KBHDatePickerCell.reuseIdentifier())
        self.collectionView = collectionView
        
        let today =  NSDate().withoutTime()
        self.loadDaysAroundDate(today)
        self.selectedDate = today
    }
    
    public required init(collectionView: UICollectionView, delegate: KBHDatePickerDataSourceDelegate? = nil) {
        super.init()
        self.delegate = delegate
        self.setupCollectionView(collectionView)
    }
    
    
    // MARK: - Select/Scroll Dates
    
    private func selectDate(date: NSDate) {
        let newDate = date.withoutTime()
        var x = self.collectionView.frame.size.width
        var offset = 0
        
        // Determine if the selected date is showing right now
        if newDate.earlierDate(self.dates[kNumberOfDaysToShow - 1]).isEqualToDate(newDate) {
            x = 0  // scroll left
            offset = kNumberOfDaysToShow
        } else if newDate.laterDate(self.dates[2 * kNumberOfDaysToShow]).isEqualToDate(newDate) {
            x = self.collectionView.frame.size.width * 2.0  // scroll right
            offset = -kNumberOfDaysToShow
        }
        
        // If needed, show fake scrolling motion so the user gets visual feedback
        if offset != 0 {
            let fakeDate = NSDate.dateWithOffset(offset, fromDate: newDate).withoutTime()
            self.scrollCollectionViewToXPosition(x, usingFakeDate: fakeDate, realDate: newDate)
        } else {
            self.loadDaysAroundDate(newDate)
            self.collectionView.reloadData()
        }
        
        // Notify delegate of date change
        self.delegate?.datePickerDataSourceSelectedDateChanged(newDate)
    }
    
    private func scrollCollectionViewToXPosition(x: CGFloat, usingFakeDate fakeDate: NSDate, realDate: NSDate) {
        // Fake scroll for visual feedback
        self.isScrolling = true
        let visibleRect = CGRectMake(x, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height)
        self.collectionView.scrollRectToVisible(visibleRect, animated: true)
        
        self.loadDaysAroundDate(fakeDate)
        self.collectionView.reloadData()
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        // Update date to real date, completing the fake scroll
        // TODO:
        // self.loadDaysAroundDate(self.selectedDate)'
        let middleRect = CGRectMake(self.collectionView.frame.size.width, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height)
        self.collectionView.scrollRectToVisible(middleRect, animated: false)
        self.isScrolling = false
        self.collectionView.reloadData()
    }
    
    private func loadDaysAroundDate(date: NSDate) {
        // Get the sunday for the week before selected date
        let sunday = date.earlierSunday().withoutTime()
        let startDate = NSDate.dateWithOffset(-7, fromDate: sunday)
        
        // Load days for 3 weeks from start date
        self.dates = []
        for index in 0...(KBHDaysInAWeek * 3) - 1 {
            self.dates.append(NSDate.dateWithOffset(index, fromDate: startDate))
        }
    }
    
    private func updateMonthShown() {
        // Swift's version of static variable. Revisit this.
        struct StaticVar {
            static var currentMonth: NSString = ""
        }
        
        if self.dates.count >= kNumberOfDaysToShow {
            let firstDateShown = self.dates[kNumberOfDaysToShow]
            
            if !StaticVar.currentMonth.isEqualToString(firstDateShown.month) {
                StaticVar.currentMonth = firstDateShown.month
                self.delegate?.datePickerDataSourceMonthChanged(firstDateShown.month)
            }
        }
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        self.updateMonthShown()
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dates.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let dateCell = collectionView.dequeueReusableCellWithReuseIdentifier(KBHDatePickerCell.reuseIdentifier(), forIndexPath: indexPath) as! KBHDatePickerCell
        dateCell.date = self.dates[indexPath.row]
        dateCell.selected = self.selectedDate.isEqualToDate(dateCell.date) && !self.isScrolling
        return dateCell
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedDate = self.dates[indexPath.row]
        collectionView.reloadData()
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // Cell frames in the collection view need to have an integer width/height. Since we are dividing the collection view width by 7 to get
        // the cell width, this will likely be a floating point number; which we don't want. Floating point numbers will result in weird
        // transitions with paging enabled. To get around this, round the width down to the integer value. Then alternate cell frame widths,
        // so that the cell widths will go width, width + 1, width, width + 1... This will make it so that the last cell will either need
        // to be width or width + 1. Do the math to figure out what the last cell needs to be and assign it.
        
        var width = collectionView.frame.size.width / CGFloat(kNumberOfDaysToShow)
        
        if indexPath.row % 7 != kNumberOfDaysToShow - 1 {
            // rows 0-5
            width = (indexPath.row % 2) != 0 ? width : width + 1
        } else {
            // row 6 - There will be 3 rows of width and 3 rows of width + 1. Figure out what needs to be added to equal the collection view width.
            // Equation: 3width + 3(width+1) + remaining = collectionViewWidth -> remaining = collectionViewWidth - 6width - 3
            width = collectionView.frame.size.width - (6 * width) - 3
        }
        
        return CGSizeMake(width, collectionView.frame.size.height)
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollView.userInteractionEnabled = false
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // scrollViewDidEndDecelerating will not be called if the view ends dragging at the same place it began dragging.
        // This delegate method is used to re-enable user interaction in that case.
        scrollView.userInteractionEnabled = true
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let collectionView = scrollView as! UICollectionView
        collectionView.userInteractionEnabled = true
        let visibleRect = CGRectMake(collectionView.frame.size.width, 0, collectionView.frame.size.width, collectionView.frame.size.height)
        
        if collectionView.contentOffset.x == 0 {
            // load previous
            self.addOffsetToDates(offset: -kNumberOfDaysToShow)
            collectionView.reloadData()
            collectionView.scrollRectToVisible(visibleRect, animated: false)
        } else if collectionView.contentOffset.x >= collectionView.frame.size.width * 2 {
            // load next
            self.addOffsetToDates(offset: kNumberOfDaysToShow)
            collectionView.reloadData()
            collectionView.scrollRectToVisible(visibleRect, animated: false)
        }
    }
    
    private func addOffsetToDates(offset offset: Int) {
        for index in 0...self.dates.count - 1 {
            let newDate = NSDate.dateWithOffset(offset, fromDate: self.dates[index])
            self.dates[index] = newDate
        }
    }
    
}
