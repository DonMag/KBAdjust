//
//  ViewController.swift
//  KBAdjust
//
//  Created by Don Mag on 10/26/18.
//  Copyright © 2018 DonMag. All rights reserved.
//

import UIKit

// scrollToBottomRow UITableView extension from
// John Rogers
// https://stackoverflow.com/a/51940222/6257435
extension UITableView {
	func scrollToBottomRow() {
		DispatchQueue.main.async {
			guard self.numberOfSections > 0 else { return }
			
			// Make an attempt to use the bottom-most section with at least one row
			var section = max(self.numberOfSections - 1, 0)
			var row = max(self.numberOfRows(inSection: section) - 1, 0)
			var indexPath = IndexPath(row: row, section: section)
			
			// Ensure the index path is valid, otherwise use the section above (sections can
			// contain 0 rows which leads to an invalid index path)
			while !self.indexPathIsValid(indexPath) {
				section = max(section - 1, 0)
				row = max(self.numberOfRows(inSection: section) - 1, 0)
				indexPath = IndexPath(row: row, section: section)
				
				// If we're down to the last section, attempt to use the first row
				if indexPath.section == 0 {
					indexPath = IndexPath(row: 0, section: 0)
					break
				}
			}
			
			// In the case that [0, 0] is valid (perhaps no data source?), ensure we don't encounter an
			// exception here
			guard self.indexPathIsValid(indexPath) else { return }
			
			self.scrollToRow(at: indexPath, at: .bottom, animated: true)
		}
	}
	
	func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
		let section = indexPath.section
		let row = indexPath.row
		return section < self.numberOfSections && row < self.numberOfRows(inSection: section)
	}
}

class KBCell: UITableViewCell {
	
	@IBOutlet var theLabel: UILabel!
	
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	
	@IBOutlet var theTableView: UITableView!
	
	@IBOutlet var theTextField: UITextField!
	
	@IBOutlet var textViewBottomConstraint: NSLayoutConstraint!
	
	var theData: [String] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		theTableView.dataSource = self
		theTableView.delegate = self
		
		theTextField.delegate = self
		
		theTableView.tableFooterView = UIView()
		
		// use 1...20 to see scrollToBottom functionality
		// use 1...4 to see functionality with only a few rows
		for i in 1...4 {
			theData.append("Row \(i)")
		}
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(self.keyboardNotification(notification:)),
											   name: NSNotification.Name.UIKeyboardWillChangeFrame,
											   object: nil)
		
	}
	
	@objc func keyboardNotification(notification: NSNotification) {
		if let userInfo = notification.userInfo {
			let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			let endFrameY = endFrame?.origin.y ?? 0
			let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
			let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
			let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
			let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
			if endFrameY >= UIScreen.main.bounds.size.height {
				self.textViewBottomConstraint?.constant = 0.0
			} else {
				self.textViewBottomConstraint?.constant = endFrame?.size.height ?? 0.0
			}
			self.theTableView.scrollToBottomRow()
			UIView.animate(withDuration: duration,
						   delay: TimeInterval(0),
						   options: animationCurve,
						   animations: { self.view.layoutIfNeeded() },
						   completion: nil
			)
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return theData.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "KBCell", for: indexPath) as! KBCell
		
		cell.theLabel.text = theData[indexPath.row]
		
		return cell
	}
	
}
