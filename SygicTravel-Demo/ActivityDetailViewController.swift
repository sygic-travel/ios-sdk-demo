//
//  ActivityDetailViewController.swift
//  SygicTravel-Demo
//
//  Created by Marek Stana on 2/1/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import UIKit
import TravelCore

class ActivityDetailViewController : UIViewController {

	var activity:Activity! {
		didSet {
			activity = ActivityManager.default().activity(withID: self.activity.ID)
			refreshData()
		}
	}
	
	let scrollView = UIScrollView(frame: UIScreen.main.bounds)

	var imageView:UIImageView!

	override func loadView() {

		self.view = self.scrollView
		self.view.backgroundColor = .white
		self.title = activity.name

		let operation = ActivityUpdateOperation(activity: activity)
		operation?.delegate = self
		operation?.start()
	}

	func refreshData() {

		for subview in scrollView.subviews {
			subview.removeFromSuperview()
		}

		setUpImageView()

		let padding = CGFloat(8)
		var startHeight = CGFloat(padding + imageView.frame.origin.y + imageView.frame.size.height)

		for pair in self.pairInformationForActivity(forActivity: activity) {
			if let safeSecondPair = pair.1 as String!{
				let titleLabel = UILabel(frame: CGRect(x: padding, y: startHeight, width: self.view.frame.size.width - 2*padding, height: 60))
				titleLabel.text = pair.0;
				titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
				titleLabel.numberOfLines = 3
				titleLabel.sizeToFit()
				self.scrollView.addSubview(titleLabel)

				let subtitleLabel = UILabel(frame: CGRect(x: padding, y: titleLabel.frame.origin.y + titleLabel.frame.size.height, width: self.view.frame.size.width - 2*padding, height: 60))
				subtitleLabel.text = safeSecondPair
				subtitleLabel.font = UIFont.systemFont(ofSize: 12)
				subtitleLabel.numberOfLines = 0
				subtitleLabel.sizeToFit()
				self.scrollView.addSubview(subtitleLabel)

				startHeight = subtitleLabel.frame.origin.y + subtitleLabel.frame.size.height + 30
			}
		}

		let galleryButton = UIButton(type: .system)
		galleryButton.frame = CGRect(x: 0,y: startHeight, width:self.view.frame.width, height:40)
		galleryButton.setTitle("Gallery", for: .normal)
		galleryButton.contentHorizontalAlignment = .center
		galleryButton.addTarget(self, action: #selector(ActivityDetailViewController.openGallery), for: .touchUpInside)
		self.scrollView.addSubview(galleryButton)
		startHeight += galleryButton.frame.height + padding

		self.scrollView.contentSize = CGSize(width:self.view.frame.size.width, height: startHeight)
	}

	func setUpImageView() {
		if imageView == nil {
			imageView = UIImageView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width))
			imageView.backgroundColor = activity.categoryColor()

			let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(openGallery))
			imageView.isUserInteractionEnabled = true
			imageView.addGestureRecognizer(tapGestureRecognizer)
		}
		self.scrollView.addSubview(imageView)

		if let safeMedium = MediaManager.default().imageForItem(withID: activity.ID, type:.fullscreen) {
			imageView.downloadedFrom(url: URL(string: safeMedium.url.absoluteString.replacingOccurrences(of: "__SIZE__", with: "400x400"))!, finished:{})
		}
	}

	func openGallery() {
		let vc = GalleryViewController()
		vc.activity = self.activity
		self.navigationController?.pushViewController(vc, animated: true)
	}

	func pairInformationForActivity(forActivity:Activity) -> [(String, String?)]{
		var pairs = [(String,String?)]()
		pairs.append(("Name",forActivity.name))
		pairs.append(("Sufix",forActivity.suffix))
		pairs.append(("Subtitle",forActivity.subtitle))
		pairs.append(("Text Description",forActivity.textDescription))
		pairs.append(("Duration",self.timeFormatted(totalSeconds: forActivity.duration as Int? ?? 0 as Int)))
		pairs.append(("Rating",forActivity.rating.description))
		pairs.append(("Tags",forActivity.tags.description))
		pairs.append(("Categories",forActivity.categories.description))

		var referencesString = ""
		for reference in ActivityManager.default().referencesForActivity(withID: forActivity.ID) {
			if let safePrice = reference.price {
				referencesString += reference.title + " , price: " + safePrice.description + "\n\n"
			} else {
				referencesString += reference.title
			}
		}

		pairs.append(("References",referencesString))

		return pairs
	}

	private func timeFormatted(totalSeconds: Int) -> String {
		let seconds: Int = totalSeconds % 60
		let minutes: Int = (totalSeconds / 60) % 60
		let hours: Int = totalSeconds / 3600
		return String(format: "%02d hours %02d minutes %02d seconds", hours, minutes, seconds)
	}

}


//MARK: BatchActivityUpdateOperationDelegate

extension ActivityDetailViewController : ActivityUpdateOperationDelegate {
	func activityUpdateOperation(_ operation: ActivityUpdateOperation!, didFinishWith activity: Activity!) {
		self.activity = activity
	}

	func activityUpdateOperation(_ operation: ActivityUpdateOperation!, didFinishWithPhotosFor activity: Activity!) {
		setUpImageView()
	}
}
