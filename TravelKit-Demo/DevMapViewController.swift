//
//  MapViewController.swift
//  TravelKit Demo
//
//  Created by Marek Stana on 1/31/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import UIKit
import MapKit
import TravelKit


class DevMapViewController: UIViewController {

	var mapView:MKMapView!

	var places: [TKPlace] = [TKPlace]()

	var activeCategoryFilter: TKPlaceCategory = [ ]

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.backBarButtonItem = UIBarButtonItem.empty()
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Category", style: .plain, target: self, action: #selector(DevMapViewController.showCategoryFilter))

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

		var annotations = [TKMapPlaceAnnotation]()

		for place in places {
			annotations.append(TKMapPlaceAnnotation(place: place))
		}

		OperationQueue.main.addOperation {
			self.mapView.removeAnnotations(self.mapView.annotations)
			self.mapView.addAnnotations(annotations)
		}
	}

	func fetchData() {

		let query = TKPlacesQuery()
		query.levels = .POI
		query.bounds = TKMapRegion(coordinateRegion: mapView.region)
		query.categories = activeCategoryFilter

		TravelKit.shared().places(for: query) { (places, error) in
			self.places = places ?? [ ]
			self.reloadData()
		}
	}

	@objc func showCategoryFilter() {

		let actionSheet = UIAlertController(title: "Choose Category", message: nil, preferredStyle: .actionSheet)

		let categoryArray: [TKPlaceCategory] = [
			.sightseeing, .shopping, .eating, .discovering, .playing,
			.traveling, .goingOut, .hiking, .sports, .relaxing, .sleeping
		]

		actionSheet.addAction(UIAlertAction(title: "All", style: .destructive,
		  handler: { (action:UIAlertAction!) -> Void in
			self.activeCategoryFilter = [ ]
			self.fetchData()
		}))

		for category in categoryArray {
			if let title = TKPlace.localisedName(for: category) {
				actionSheet.addAction(UIAlertAction(title: title, style: .default,
				  handler: { (action:UIAlertAction!) -> Void in
					self.activeCategoryFilter = category
					self.fetchData()
				}))
			}
		}

		actionSheet.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))

		self.present(actionSheet, animated: true, completion: nil)
	}
}


// MARK: MKMapViewDelegate

extension DevMapViewController : MKMapViewDelegate {

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		let annotationView = MKAnnotationView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
		annotationView.isUserInteractionEnabled = true
		annotationView.backgroundColor = .lightGray
		annotationView.layer.cornerRadius = 10
		if let annotation = annotation as? TKMapPlaceAnnotation {
			annotationView.backgroundColor = annotation.place.primaryColor
		}
		return annotationView
	}

	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		if let annotation = view.annotation as? TKMapPlaceAnnotation {
			let vc = TKPlaceDetailViewController(place: annotation.place)
			self.navigationController?.pushViewController(vc, animated: true)
			mapView.deselectAnnotation(view.annotation, animated: false)
		}
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		fetchData()
	}
}
