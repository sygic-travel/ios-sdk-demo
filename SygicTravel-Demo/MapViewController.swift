//
//  MapViewController.swift
//  SygicTravel-Demo
//
//  Created by Marek Stana on 1/31/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import UIKit
import MapKit
import TravelCore


class MapViewController: UIViewController {

	var mapView:MKMapView!

	var activities:[Activity] = [Activity]()
	var currentTagFilters:[String]?

	var activeCategoryFilter:ActivityFilter?
	var activeTagFilters:[String]?
	

	override func viewDidLoad() {
		super.viewDidLoad()

		let categoryButton = UIBarButtonItem(title: "Category", style: .plain, target: self, action: #selector(MapViewController.showCategoryFilter))
		let tagButton = UIBarButtonItem(title: "Tag", style: .plain, target: self, action: #selector(MapViewController.showtagFilter))
		navigationItem.rightBarButtonItems = [categoryButton, tagButton]

		mapView = MKMapView(frame: self.view.frame)
		mapView.delegate = self
		mapView.mapType = .standard
		mapView.showsPointsOfInterest = false
		mapView.showsBuildings = false
		self.view.addSubview(mapView)

		self.title = "Map"

		let regionRadius = 1000.0
		let location:CLLocation = CLLocation(latitude: 51.5, longitude: -0.1)
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
		                                                          regionRadius * 2.0, regionRadius * 2.0)
		mapView.setRegion(coordinateRegion, animated: true)
		fetchData()
	}

	func reloadData() {
		mapView.removeAnnotations(mapView.annotations)

		for activity in activities {
			mapView.addAnnotation(MapPin(activity: activity))
		}
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

		if let saveArray = currentTagFilters {
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



//MARK: MKMapViewDelegate

extension MapViewController : MKMapViewDelegate {

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		let annotationView = MKAnnotationView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
		annotationView.isUserInteractionEnabled = true
		annotationView.backgroundColor = .lightGray
		annotationView.layer.cornerRadius = 10
		if let mapPinAnnotation = annotation as? MapPin {
			annotationView.backgroundColor = mapPinAnnotation.activity.categoryColor()
		}
		return annotationView
	}

	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		if let mapPinAnnotation = view.annotation as? MapPin {
			let vc = ActivityDetailViewController()
			vc.activity = mapPinAnnotation.activity
			self.navigationController?.pushViewController(vc, animated: true)
			mapView.deselectAnnotation(view.annotation, animated: false)
		}
	}
}


//MARK: LoadFeaturesOperationDelegate

extension MapViewController : LoadFeaturesOperationDelegate {

	func loadFeaturesOperation(_ operation: LoadFeaturesOperation!, didFinishWith resultSet: FeatureResultSet!) {
		activities = resultSet.features
		self.currentTagFilters = [String]()
		for tag in  resultSet.tagStats[0 ... 10] {
			self.currentTagFilters?.append(tag.name)
		}
		reloadData()
	}

	func loadFeaturesOperationDidCancel(_ operation: LoadFeaturesOperation!) {
		NSLog("Operation Canceled!")
	}
}

//MARK: MapPin Annotation

class MapPin : NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D
	var title: String?
	var activity: Activity!

	init(coordinate: CLLocationCoordinate2D, title: String) {
		self.coordinate = coordinate
		self.title = title
	}

	init(activity:Activity) {
		self.coordinate = activity.location.coordinate
		self.title = activity.name
		self.activity = activity
	}
}
