//
//  ExtensionHelper.swift
//  SygicTravel-Demo
//
//  Created by Marek Stana on 2/2/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import UIKit
import TravelKit

extension UINavigationController {

	open override var preferredStatusBarStyle: UIStatusBarStyle {
		if let vc = self.viewControllers.last {
			return vc.preferredStatusBarStyle
		}
		return super.preferredStatusBarStyle
	}
}

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

	class func fromRGB(_ rgb: UInt) -> UIColor {

		let red = CGFloat(Double((rgb & 0xFF0000) >> 16)/255.0)
		let green = CGFloat(Double((rgb & 0xFF00) >> 8)/255.0)
		let blue = CGFloat(Double((rgb & 0xFF))/255.0)

		return UIColor(red: red, green: green, blue: blue, alpha: 1)
	}
}

extension TKPlace {

	var primaryColor: UIColor { return UIColor.fromRGB(self.displayableHexColor) }

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
