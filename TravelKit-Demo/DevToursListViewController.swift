//
//  DevToursListViewController.swift
//  TravelKit Demo
//
//  Created by Marek Stana on 2/1/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import UIKit
import TravelKit

class DevToursListViewController: UITableViewController {

	var tours: [TKTour] = [TKTour]()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)

		self.title = "Tours List"
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		self.tableView.tableFooterView = UIView()

		fetchData()
	}

	func fetchData() {

		let query = TKToursViatorQuery()
		query.parentID = "city:5"
		query.sortingType = .topSellers

		TravelKit.shared.tours.tours(for: query) { (tours, error) in
			DispatchQueue.main.async {
				self.tours = tours ?? [ ]
				self.tableView.reloadData()
			}
		}
	}
}

extension DevToursListViewController /* UITableViewController delegates */ {

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tours.count
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 76
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
		guard let tour = tours[safe: indexPath.row] else { return cell }

//		if let thumbnailURL = tour?.thumbnailURL {
//			cell.imageView?.downloadedFrom(url: thumbnailURL, finished: {
//				cell.setNeedsLayout()
//			})
//		}
		cell.textLabel?.text = tour.title

		var detailTexts = [String]()

		if let price = tour.price {
			detailTexts.append(String(format: "$%.0f", price.floatValue))
		}

		if let rating = tour.rating {
			detailTexts.append(String(format: "%.0f★", rating.floatValue))
		}

		if let duration = tour.duration { detailTexts.append(duration) }

		if let perex = tour.perex { detailTexts.append(perex) }

		cell.detailTextLabel?.text = detailTexts.joined(separator: " • ")
		cell.detailTextLabel?.numberOfLines = 3
		cell.detailTextLabel?.textColor = UIColor(white: 0.7, alpha: 1)
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		let tour = tours[indexPath.row]

		let vc = TKBrowserViewController(url: tour.url!)
		self.navigationController?.pushViewController(vc, animated: true)
	}
}
