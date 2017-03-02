//
//  MapViewController.swift
//  SygicTravel-Demo
//
//  Created by Marek Stana on 1/31/17.
//  Copyright © 2017 Marek Stana. All rights reserved.
//

import UIKit
import MapKit
import TravelKit


class MapViewController: UIViewController {

	var mapView:MKMapView!

	var places: [TKPlace] = [TKPlace]()

	var activeCategoryFilter: String?

	override func viewDidLoad() {
		super.viewDidLoad()

		let categoryButton = UIBarButtonItem(title: "Category", style: .plain, target: self, action: #selector(MapViewController.showCategoryFilter))
		navigationItem.rightBarButtonItems = [categoryButton]

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

		var annotations = [MapPin]()

		for place in places {
			annotations.append(MapPin(place: place))
		}

		mapView.removeAnnotations(mapView.annotations)
		mapView.addAnnotations(annotations)
	}

	func fetchData() {

		let query = TKPlacesQuery()
		query.type = .POI
		query.region = TKMapRegion(coordinateRegion: mapView.region)
		query.categories = (activeCategoryFilter != nil) ? [ activeCategoryFilter! ] : nil

		TravelKit.places(for: query) { (places, error) in
			self.places = places ?? [ ]
			self.reloadData()
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



// MARK: MKMapViewDelegate

extension MapViewController : MKMapViewDelegate {

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		let annotationView = MKAnnotationView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
		annotationView.isUserInteractionEnabled = true
		annotationView.backgroundColor = .lightGray
		annotationView.layer.cornerRadius = 10
		if let mapPinAnnotation = annotation as? MapPin {
			annotationView.backgroundColor = mapPinAnnotation.place.primaryColor
		}
		return annotationView
	}

	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		if let mapPinAnnotation = view.annotation as? MapPin {
			let vc = PlaceDetailViewController()
			vc.place = mapPinAnnotation.place
			self.navigationController?.pushViewController(vc, animated: true)
			mapView.deselectAnnotation(view.annotation, animated: false)
		}
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		fetchData()
	}
}


// MARK: MapPin Annotation

class MapPin : NSObject, MKAnnotation {
	var place: TKPlace!
	var title: String?
	var coordinate: CLLocationCoordinate2D

	init(coordinate: CLLocationCoordinate2D, title: String) {
		self.coordinate = coordinate
		self.title = title
	}

	init(place: TKPlace) {
		self.place = place
		self.title = place.name
		self.coordinate = place.location?.coordinate ?? kCLLocationCoordinate2DInvalid
	}
}
