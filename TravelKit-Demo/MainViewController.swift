//
//  ViewController.swift
//  TravelKit Demo
//
//  Created by Marek Stana on 1/31/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

	let options = ["Map", "Places List", "Tours List",
				   "Places List - Dev", "Tours List - Dev",
				   "Full Text Search", "Synchronize", "Playground",
				   "Sign in", "Sign out"]

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = "TravelKit Demo"

		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		self.tableView.tableFooterView = UIView()
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 64
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return options.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		let opt = options[section]

		if opt == "Synchronize" { return TravelKit.shared.session.session != nil ? 1 : 0 }
		if opt == "Sign in" { return TravelKit.shared.session.session == nil ? 1 : 0 }
		if opt == "Sign out" { return TravelKit.shared.session.session != nil ? 1 : 0 }

		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
		cell.textLabel?.text = options[indexPath.section]
		cell.accessoryType = .disclosureIndicator
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		var vc: UIViewController!

		let opt = options[indexPath.section]

		switch opt {

		case "Map":
			vc = TKMapViewController()
			break

		case "Places List":
			let query = TKPlacesQuery()
			query.parentIDs = ["city:1"]
			query.levels = .POI
			query.limit = 200
			let controller = TKPlacesListViewController(query: query)
			vc = controller
			break

		case "Tours List":
			vc = TKToursListViewController()
			break

		case "Places List - Dev":
			let controller = DevPlacesListViewController()
			controller.searchBarHidden = true
			vc = controller
			break

		case "Tours List - Dev":
			let controller = DevToursListViewController()
			vc = controller
			break

		case "Full Text Search":
			let controller = DevPlacesListViewController()
			controller.searchBarHidden = false
			vc = controller
			break

		case "Sign in":

			let alert = UIAlertController(title: "Sign in with credentials", message: nil, preferredStyle: .alert)

			alert.addTextField(configurationHandler: { (textfield) in
				textfield.placeholder = "Username"
				textfield.tag = 1
			})

			alert.addTextField(configurationHandler: { (textfield) in
				textfield.placeholder = "Password"
				textfield.tag = 2
			})

			alert.addAction(UIAlertAction(title: "Sign in", style: .default, handler: { (action) in

				let usernameField = alert.textFields?.first(where: { (tf) -> Bool in
					return tf.tag == 1
				})

				let passwordField = alert.textFields?.first(where: { (tf) -> Bool in
					return tf.tag == 2
				})

				let username = usernameField?.text ?? ""
				let password = passwordField?.text ?? ""

				TravelKit.shared.session.performUserCredentialsAuth(withEmail: username, password: password, success: { (session) in
					OperationQueue.main.addOperation {
						print(session)
						tableView.reloadData()
					}
				}, failure: { (error) in
					OperationQueue.main.addOperation {
						print(error)
					}
				})
			}))

			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

			self.present(alert, animated: true, completion: nil)
			break

		case "Sign out":
			TravelKit.shared.session.performSignOut {
				print("Signed out")
				tableView.reloadData()
			}
			break

		case "Playground":
			vc = PlaygroundViewController()
			break

		case "Synchronize":
			TravelKit.shared.sync.synchronize()
			break

		default:
			return

		}

		if (vc == nil) { return }

		self.navigationController?.pushViewController(vc, animated: true)
	}
}

