//
//  DevPlaceDetailViewController.swift
//  TravelKit Demo
//
//  Created by Marek Stana on 2/1/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import UIKit
import TravelKit

class DevPlaceDetailViewController : UIViewController {

	var place: TKPlace! {
		didSet {
			OperationQueue.main.addOperation { self.refreshData() }
		}
	}

	let scrollView = UIScrollView(frame: UIScreen.main.bounds)

	var imageView:UIImageView!

	override func loadView() {

		self.view = self.scrollView
		self.view.backgroundColor = .white
		self.title = place.name

		// Fetch detailed information of the place

		TravelKit.shared.places.detailedPlace(withID: place.ID) { (place, error) in
			if (place != nil) { self.place = place }
		}
	}

	func refreshData() {

		for subview in scrollView.subviews {
			subview.removeFromSuperview()
		}

		setUpImageView()

		let padding = CGFloat(8)
		var startHeight = CGFloat(padding + imageView.frame.origin.y + imageView.frame.size.height)

		for pair in self.pairInformation(forPlace: place) {
			if let safeSecondPair = pair.1 as String? {
				let titleLabel = UILabel(frame: CGRect(x: padding, y: startHeight, width: self.view.frame.size.width - 2*padding, height: 60))
				titleLabel.text = pair.0
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
		galleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
		self.scrollView.addSubview(galleryButton)
		startHeight += galleryButton.frame.height + padding

		self.scrollView.contentSize = CGSize(width:self.view.frame.size.width, height: startHeight)
	}

	func setUpImageView() {
		if imageView == nil {
			imageView = UIImageView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width))
			imageView.backgroundColor = place.primaryColor

			let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(openGallery))
			imageView.isUserInteractionEnabled = true
			imageView.addGestureRecognizer(tapGestureRecognizer)
		}
		self.scrollView.addSubview(imageView)

		TravelKit.shared.places.mediaForPlace(withID: place.ID) { (media, error) in

			if let medium = media?.first {

				if let url = medium.displayableImageURL(for: CGSize(width: 640, height: 640)) {
					DispatchQueue.main.async() { () -> Void in
						self.imageView.downloadedFrom(url: url, finished: {})
					}
				}
			}
		}
	}

	@objc func openGallery() {
		let vc = DevGalleryViewController()
		vc.place = place
		self.navigationController?.pushViewController(vc, animated: true)
	}

	func pairInformation(forPlace place:TKPlace) -> [(String, String?)] {
		var pairs = [(String,String?)]()

		let detailedPlace = place as? TKDetailedPlace
		let detail = detailedPlace?.detail

		pairs.append(("Name", place.name))
		if let kind = place.kind { pairs.append(("Kind", kind)) }
		if let tzone = detail?.timezone { pairs.append(("Time zone", tzone)) }

		if let name = detail?.localName { pairs.append(("Local name", name)) }
		if let name = detail?.translatedName { pairs.append(("Translated name", name)) }
		if let name = detail?.englishName { pairs.append(("English name", name)) }

		pairs.append(("Suffix", place.suffix))
		pairs.append(("Perex", place.perex))

		if let description = detail?.fullDescription?.text {
			pairs.append(("Description", description))
		}

		if let duration = detail?.duration {
			pairs.append(("Duration", self.timeFormatted(totalSeconds: duration.intValue)))
		}
		if let rating = place.rating {
			pairs.append(("Rating", rating.description))
		}
		let cats = place.localisedCategories()
		if cats.count > 0 {
			pairs.append(("Categories", cats.joined(separator: " • ")))
		}
		if let tags = detail?.tags, tags.count > 0 {
			let tags = tags.map({ (placeTag) -> String in
				return placeTag.name ?? placeTag.key
			})
			pairs.append(("Tags", tags.joined(separator: " • ")))
		}

		if let address = detail?.address {
			pairs.append(("Address", address))
		}

		if let hours = detail?.openingHours {
			pairs.append(("OSM Opening hours", hours))
		}

		if let hours = detail?.openingHoursNote {
			pairs.append(("Opening hours note", hours))
		}

		if let attributesString = detail?.attributes?.map({ (key: String, value: String) -> String in
			"\(key) => \(value)"
		}).joined(separator: "\n") {
			pairs.append(("Attributes", attributesString))
		}

		var referencesString = ""

		for reference in detail?.references ?? [ ] {

			var pieces = [String]()

			pieces.append(reference.title)
			pieces.append(reference.onlineURL.absoluteString)
			if let price = reference.price { pieces.append("$" + price.description) }

			referencesString += pieces.joined(separator: "\n")
			referencesString += "\n\n"
		}

		pairs.append(("References", referencesString))

		return pairs
	}

	private func timeFormatted(totalSeconds: Int) -> String {
		let seconds: Int = totalSeconds % 60
		let minutes: Int = (totalSeconds / 60) % 60
		let hours: Int = totalSeconds / 3600
		return String(format: "%02d hours %02d minutes %02d seconds", hours, minutes, seconds)
	}

}
