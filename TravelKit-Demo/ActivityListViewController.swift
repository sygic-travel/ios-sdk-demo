//
//  PlacesListViewController.swift
//  TravelKit Demo
//
//  Created by Marek Stana on 2/1/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import UIKit
import TravelKit

class PlacesListViewController: UITableViewController {

	var places: [TKPlace] = [TKPlace]()

	var currentTagFilters: [String]?
	var activeCategoryFilter: String?
	var activeTagFilters: [String]?
	var activeSearchTerm: String?

	var searchBarHidden: Bool = true
	var searchingActive: Bool = false
	var searchBar: UISearchBar!

	var devSwitch: UISwitch?

	override func viewDidLoad() {
		super.viewDidLoad()

		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)

		let categoryButton = UIBarButtonItem(title: "Category", style: .plain, target: self, action: #selector(MapViewController.showCategoryFilter))
		navigationItem.rightBarButtonItem = categoryButton

		self.title = "Activities List"
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		self.tableView.tableFooterView = UIView()

		devSwitch = UISwitch()
		devSwitch?.isOn = true
		self.navigationItem.titleView = devSwitch!

		if !searchBarHidden {
			searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
			searchBar.placeholder = NSLocalizedString("What are you looking for?", comment: "Placeholder in searchBar")
			self.tableView.tableHeaderView = searchBar
			searchBar.delegate = self
		}

		fetchData()
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return places.count
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 70
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
		let place = places[indexPath.row] as TKPlace!

		if let thumbnailURL = place?.thumbnailURL {
			cell.imageView?.downloadedFrom(url: thumbnailURL, finished: {
				cell.setNeedsLayout()
			})
		}
		cell.textLabel?.text = place?.name
		cell.detailTextLabel?.text = place?.perex
		cell.detailTextLabel?.numberOfLines = 3
		cell.detailTextLabel?.textColor = UIColor(white: 0.7, alpha: 1)
		return cell
	}


	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		let place = places[indexPath.row]

		if (devSwitch?.isOn == true) {
			let vc = PlaceDetailViewController()
			vc.place = place
			self.navigationController?.pushViewController(vc, animated: true)
		} else {
			let vc = TKPlaceDetailViewController(place: place)
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}

	func fetchData() {

		let query = TKPlacesQuery()
		query.level = .POI
		query.parentID = "city:1"
		query.categories = (activeCategoryFilter != nil) ? [ activeCategoryFilter! ] : nil
		query.tags = activeTagFilters
		query.limit = 128

		if activeSearchTerm?.lengthOfBytes(using: .utf8) ?? 0 > 0 {
			query.searchTerm = activeSearchTerm!
			query.limit = 10
		}

		TravelKit.shared().places(for: query) { (places, error) in
			DispatchQueue.main.async {
				self.places = places ?? [ ]
				self.tableView.reloadData()
			}
		}
	}

	func showCategoryFilter() {

		let actionSheet = UIAlertController(title: "Choose Category", message: nil, preferredStyle: .actionSheet)

		let categoryArray = ["sightseeing", "shopping", "eating", "discovering", "playing", "traveling", "going_out", "hiking", "sports", "relaxing"]

		actionSheet.addAction(UIAlertAction(title: "All", style: .destructive,
		  handler: { (action:UIAlertAction!) -> Void in
			self.activeCategoryFilter = nil
			self.fetchData()
		}))

		for category in categoryArray {
			actionSheet.addAction(UIAlertAction(title: category, style: .default,
			  handler: { (action:UIAlertAction!) -> Void in
				self.activeCategoryFilter = category
				self.fetchData()
			}))
		}

		actionSheet.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))

		self.present(actionSheet, animated: true, completion: nil)
	}
}


// MARK: UISearchBarDelegate

extension PlacesListViewController : UISearchBarDelegate {

	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchingActive = true;
		searchBar.setShowsCancelButton(true, animated: true)
	}

	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		searchingActive = false;
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchingActive = false;
		self.fetchData()
		searchBar.text = ""
		searchBar.resignFirstResponder()
		searchBar.setShowsCancelButton(false, animated: true)
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchingActive = false;
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		activeSearchTerm = searchText
		self.fetchData()
	}
}
