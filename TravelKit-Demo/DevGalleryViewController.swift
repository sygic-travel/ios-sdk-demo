//
//  DevGalleryViewController.swift
//  TravelKit Demo
//
//  Created by Marek Stana on 2/2/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import UIKit
import TravelKit

class DevGalleryViewController : UIViewController {

	let scrollView = UIScrollView(frame: UIScreen.main.bounds)
	var place: TKPlace!
	var media:[TKMedium] = [TKMedium]()

	override func loadView() {
		self.view = self.scrollView
		self.view.backgroundColor = .white
		self.title = place.name

		let padding = CGFloat(0)
		var startHeight = CGFloat(padding)

		TravelKit.shared.places.mediaForPlace(withID: place.ID) { (media, error) in

			for medium in media ?? [ ] {

				let imageView = UIImageView(frame:CGRect(x: 0, y: startHeight, width: self.view.frame.size.width, height: self.view.frame.size.width))
				imageView.backgroundColor = self.place.primaryColor

				if let url = medium.displayableImageURL(for: CGSize(width: 400, height: 400)) {
					imageView.downloadedFrom(url: url, finished: {})
				}

				self.scrollView.addSubview(imageView)
				startHeight += imageView.frame.height + padding
			}

			self.scrollView.contentSize = CGSize(width:self.view.frame.size.width, height: startHeight)
		}
	}
}
