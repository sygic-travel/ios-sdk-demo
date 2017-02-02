//
//  PoiListViewController.swift
//  SygicTravel-Demo
//
//  Created by Marek Stana on 2/1/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import TravelCore
import UIKit

class ActivityListViewController: UITableViewController {

	var activities:[Activity] = [Activity]()
	var currentTagFilters:[String]?

	var activeCategoryFilter:ActivityFilter?
	var activeTagFilters:[String]?
	var activeSearching:String?

	var searchBarHidden:Bool = true
	var searchingActive:Bool = false
	var searchBar:UISearchBar!

	override func viewDidLoad() {
		super.viewDidLoad()

		let categoryButton = UIBarButtonItem(title: "Category", style: .plain, target: self, action: #selector(MapViewController.showCategoryFilter))
		let tagButton = UIBarButtonItem(title: "Tag", style: .plain, target: self, action: #selector(MapViewController.showtagFilter))
		navigationItem.rightBarButtonItems = [categoryButton, tagButton]

		self.title = "Activities List"
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		self.tableView.tableFooterView = UIView()

		if !searchBarHidden {
			searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
			searchBar.placeholder = NSLocalizedString("What are you looking for?", comment: "Placeholder in searchBar")
			self.tableView.tableHeaderView = searchBar
			searchBar.delegate = self
		}

		fetchData()
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return activities.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
		cell.textLabel?.text = activities[indexPath.row].name
		return cell
	}


	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ActivityDetailViewController()
		vc.activity = activities[indexPath.row]
		self.navigationController?.pushViewController(vc, animated: true)
	}

	func fetchData() {

		let query = ActivityQuery()

		query.parentID = "city:1"

		if let safeCategoryFilter = activeCategoryFilter {
			query.filter = safeCategoryFilter
		}

		if let safeTagsFilter = activeTagFilters {
			query.tags = safeTagsFilter
		}

		if let safeSearching = activeSearching {
			query.searchTerm = safeSearching
		}

		let lfo = LoadFeaturesOperation(delegate: self)
		lfo?.query = query
		lfo?.start()
	}

	func showCategoryFilter() {

		let actionSheet = UIAlertController(title: "Choose Category", message: nil, preferredStyle: .actionSheet)
		let categoryArray:[ActivityFilter] = [.sightseeing, .shopping, .eating, .discovering, .playing, .travelling, .goingOut, .hiking, .sports, .relaxing]

		for category in categoryArray {
			actionSheet.addAction(UIAlertAction(title: Activity.title(for: category), style: .default, handler: { (action:UIAlertAction!) -> Void in
				self.activeCategoryFilter = category
				self.fetchData()
			}))
		}

		actionSheet.addAction(UIAlertAction(title: "All", style: .destructive, handler: { (action:UIAlertAction!) -> Void in
			self.activeCategoryFilter = nil
			self.fetchData()
		}))

		actionSheet.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))

		self.present(actionSheet, animated: true, completion: nil)
	}

	func showtagFilter() {


		let actionSheet = UIAlertController(title: "Choose Tag", message: nil, preferredStyle: .actionSheet)

		if let saveArray = self.currentTagFilters {
			for tag in saveArray {
				actionSheet.addAction(UIAlertAction(title: tag, style: .default, handler: { (action:UIAlertAction!) -> Void in
					self.activeTagFilters = [tag]
					self.fetchData()
				}))
			}
		}

		actionSheet.addAction(UIAlertAction(title: "All", style: .destructive, handler: { (action:UIAlertAction!) -> Void in
			self.activeTagFilters = nil
			self.fetchData()
		}))

		actionSheet.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))

		self.present(actionSheet, animated: true, completion: nil)
	}
}


//MARK: LoadFeaturesOperationDelegate

extension ActivityListViewController : LoadFeaturesOperationDelegate {

	func loadFeaturesOperation(_ operation: LoadFeaturesOperation!, didFinishWith resultSet: FeatureResultSet!) {
		activities = resultSet.features
		self.currentTagFilters = [String]()
		if resultSet.tagStats.count > 10 {
			for tag in  resultSet.tagStats[0 ... 10] {
				self.currentTagFilters?.append(tag.name)
			}
		} else {
			for tag in  resultSet.tagStats {
				self.currentTagFilters?.append(tag.name)
			}
		}
		self.tableView.reloadData()
	}

	func loadFeaturesOperationDidCancel(_ operation: LoadFeaturesOperation!) {
	}
}



//MARK: UISearchBarDelegate

extension ActivityListViewController : UISearchBarDelegate {

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
		activeSearching = searchText
		self.fetchData()
	}
}
