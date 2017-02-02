//
//  ViewController.swift
//  SygicTravel-Demo
//
//  Created by Marek Stana on 1/31/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

	let options = ["Map", "Activities List", "Full Text Search"]

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = "Sygic Travel Demo"

		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		self.tableView.tableFooterView = UIView()
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return options.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
		cell.textLabel?.text = options[indexPath.row]
		cell.accessoryType = .disclosureIndicator
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var vc:UIViewController!

		switch indexPath.row {
		case 0:
			vc = MapViewController()
			break;
		case 1:
			let controller = ActivityListViewController()
			controller.searchBarHidden = true
			vc = controller
			break;
		case 2:
			let controller = ActivityListViewController()
			controller.searchBarHidden = false
			vc = controller
			break;
		default:
			return
		}

		self.navigationController?.pushViewController(vc, animated: true)
	}
}

