//
//  ExtensionHelper.swift
//  SygicTravel-Demo
//
//  Created by Marek Stana on 2/2/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import UIKit

extension UIImageView {


	func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit, finished: @escaping () -> Void) {

		let iv = UIActivityIndicatorView(frame: self.bounds)
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
