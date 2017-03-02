//
//  ExtensionHelper.swift
//  SygicTravel-Demo
//
//  Created by Marek Stana on 2/2/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import UIKit
import TravelKit

extension UIImageView {


	func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit, finished: @escaping () -> Void) {

		let iv = UIActivityIndicatorView(frame: self.bounds)
		iv.activityIndicatorViewStyle = .gray
		iv.startAnimating()
		self.addSubview(iv)

		contentMode = mode
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard
				let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
				let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
				let data = data, error == nil,
				let image = UIImage(data: data)
				else { return }
			DispatchQueue.main.async() { () -> Void in
				self.image = image
				iv.stopAnimating()
				iv.removeFromSuperview()
				finished()
			}
			}.resume()
	}
}

extension UIColor {

	class func fromRGB(_ rgb: Int) -> UIColor {

		let red = CGFloat(Double((rgb & 0xFF0000) >> 16)/255.0)
		let green = CGFloat(Double((rgb & 0xFF00) >> 8)/255.0)
		let blue = CGFloat(Double((rgb & 0xFF))/255.0)

		return UIColor(red: red, green: green, blue: blue, alpha: 1)
	}
}

extension TKPlace {

	var primaryColor: UIColor {

		if let firstCategory = categories?.first {
			if (firstCategory == "sightseeing") { return UIColor.fromRGB(0xF6746C) }
			if (firstCategory == "shopping") { return UIColor.fromRGB(0xE7A41C) }
			if (firstCategory == "eating") { return UIColor.fromRGB(0xF6936C) }
			if (firstCategory == "discovering") { return UIColor.fromRGB(0x898F9A) }
			if (firstCategory == "playing") { return UIColor.fromRGB(0x6CD8F6) }
			if (firstCategory == "traveling") { return UIColor.fromRGB(0x6B91F6) }
			if (firstCategory == "going_out") { return UIColor.fromRGB(0xE76CA0) }
			if (firstCategory == "hiking") { return UIColor.fromRGB(0xD59B6B) }
			if (firstCategory == "sports") { return UIColor.fromRGB(0x68B277) }
			if (firstCategory == "relaxing") { return UIColor.fromRGB(0xA06CF6) }
			if (firstCategory == "sleeping") { return UIColor.fromRGB(0xA4CB69) }
		}

		return UIColor(white: 0.6, alpha: 1)
	}

	var thumbnailURL: URL {
		return URL(string: "https://media-cdn.sygictraveldata.com/photo/" + ID)!
	}
}

extension TKMedium {

	func previewURL(forSize size: CGSize) -> URL? {

		if let previewURL = previewURL {

			let sizeString = String(format: "%dx%d", Int(size.width), Int(size.height))

			var s = previewURL.absoluteString
			s = s.replacingOccurrences(of: "__SIZE__", with: sizeString)

			return URL(string: s)
		}

		return nil
	}
}
