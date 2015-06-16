//
//  ViewController.swift
//  KBHDatePicker
//
//  Created by Keith Hunter on 6/15/15.
//  Copyright © 2015 Keith Hunter. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KBHDatePickerDelegate {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let datePicker = KBHDatePicker(frame: CGRectMake(0, 44, self.view.bounds.size.width, 70))
        datePicker.datePickerDelegate = self
        self.view.addSubview(datePicker)
    }
    
    
    // MARK: - KBHDatePickerDelegate
    
    func datePicker(datePicker: KBHDatePicker, dateChangedFrom oldDate: NSDate, toDate newDate: NSDate) {
        print("\(NSStringFromClass(self.classForCoder)) - \(__FUNCTION__) - Old date: \(oldDate) - New date: \(newDate)")
    }
    
    func datePicker(datePicker: KBHDatePicker, monthChangedFrom oldMonth: String, toMonth newMonth: String) {
        print("\(NSStringFromClass(self.classForCoder)) - \(__FUNCTION__) - Old month: \(oldMonth) - New date: \(newMonth)")
    }

}

