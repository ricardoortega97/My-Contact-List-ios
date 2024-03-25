//
//  DateViewController.swift
//  My Contact List
//
//  Created by Ricardo Ortega on 3/25/24.
//

import UIKit
protocol DateControllerDelegate: AnyObject {
    func dateChanged(date: Date)
}

class DateViewController: UIViewController {
    
    @IBOutlet weak var dtpDate: UIDatePicker!
    
    //Delegate may not always be set, so it's weak, and the type is optional (?)
    //opitional types are set to nil by default no need for init methods 
    weak var delegate: DateControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let saveButton: UIBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save, target: self
            , action: #selector(saveDate))
        
        self.navigationItem.rightBarButtonItem = saveButton
        self.title = "Pick Birthday"
        
    }
    //functions and methods
    @objc func saveDate() {
        self.delegate?.dateChanged(date: dtpDate.date)
        self.navigationController?.popViewController(animated: true)
    }
}
