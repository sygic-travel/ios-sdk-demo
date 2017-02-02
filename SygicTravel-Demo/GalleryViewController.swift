//
//  GalleryViewController.swift
//  SygicTravel-Demo
//
//  Created by Marek Stana on 2/2/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import UIKit
import TravelCore


class GalleryViewController : UIViewController {

	let scrollView = UIScrollView(frame: UIScreen.main.bounds)
	var activity:Activity!
	var media:[Medium] = [Medium]()

	override func loadView() {
		self.view = self.scrollView
		self.view.backgroundColor = .white
		self.title = activity.name

		let padding = CGFloat(0)
		var startHeight = CGFloat(padding)
		if let save = MediaManager.default().mediaForItem(withID: activity.ID) {
			for medium in  save {

				let imageView = UIImageView(frame:CGRect(x: 0, y: startHeight, width: self.view.frame.size.width, height: self.view.frame.size.width))
				imageView.backgroundColor = activity.categoryColor()

				imageView.downloadedFrom(url: URL(string: medium.url.absoluteString.replacingOccurrences(of: "__SIZE__", with: Medium.sizeString(for: .large)))!, contentMode: .scaleAspectFit, finished: {})
				self.scrollView.addSubview(imageView)
				startHeight += imageView.frame.height + padding
			}

			self.scrollView.contentSize = CGSize(width:self.view.frame.size.width, height: startHeight)
		}
	}
}
