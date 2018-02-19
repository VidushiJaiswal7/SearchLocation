//
//  ViewController.swift
//  SearchLocation
//
//  Created by VIdushi Jaiswal on 17/02/18.
//  Copyright © 2018 Vidushi Jaiswal. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewController: UIViewController, UISearchBarDelegate, LocateOnTheMap, GMSMapViewDelegate, CLLocationManagerDelegate {

    //MARK: IBOutlets
    @IBOutlet weak var mapViewContainer: UIView!
    
    var searchResultController:SearchResultsController!
    var resultsArray = [String]()
    var googleMapsView:GMSMapView!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var camera = GMSCameraPosition()
    
    //Hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Instantiate a google map view object with the same frames as its container and add it to the root view.
        self.googleMapsView =  GMSMapView(frame: self.mapViewContainer.frame)
        googleMapsView.settings.myLocationButton = true
        googleMapsView.isMyLocationEnabled = true
        
        self.view.addSubview(self.googleMapsView)
        
        
        searchResultController = SearchResultsController()
        searchResultController.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: LocateOnTheMap methods

    //The protocol method will be called from within the SearchResultsController class to show the selected address on the map.
    func locateWithLongitude(lon: Double, andLatitude lat: Double, andTitle title: String) {
        
          DispatchQueue.main.async { () -> Void in
            //Uses the lat lon arguments to construct a marker.
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            marker.icon = UIImage(named: "marker")
            
            let camera  = GMSCameraPosition.camera(withLatitude: lat,
                                                   longitude: lon,
                                                   zoom: 5,
                                                   bearing: 270,
                                                   viewingAngle: 45)
            
            self.googleMapsView.setMinZoom(3, maxZoom: self.googleMapsView.maxZoom)

            self.googleMapsView.camera = camera
            
            //marker.title = title
            marker.snippet = title
            marker.map = self.googleMapsView
        }
        
       
    }
    
 
    //MARK: IBActions
    @IBAction func showSearchController(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        //Setting the styles
        searchController.searchBar.placeholder = NSLocalizedString("Enter a place", comment: "")
        searchController.view.backgroundColor = UIColor(red: 24/255, green: 44/255, blue: 97/255, alpha: 1.0)
        searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        searchController.searchBar.tintColor = UIColor.black
        searchController.searchBar.backgroundColor = UIColor.white
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.sizeToFit()
        self.present(searchController, animated: true, completion: nil)
    }
    
    //MARK: UISearchBarDelegate methods
    
    //Instantiate a UISearchController object, and assign the searchResultController.
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String){
        
        let placesClient = GMSPlacesClient()
        //Invoke the autocompleteQuery API from the Google Maps SDK to look for predicted places each time based on the typed text in the search bar.
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results, error: Error?) -> Void in
            self.resultsArray.removeAll()
            if results == nil {
                return
            }
            //The returned results are appended in an array.
            for result in results!{
                if let result = result as? GMSAutocompletePrediction {
                    self.resultsArray.append(result.attributedFullText.string)
                }
            }
            //The results are then passed to a method of the searchResultController object to reload the table view.
            self.searchResultController.reloadDataWithArray(self.resultsArray)
        }
    }
    
    //MARK: CLLocationManagerDelegate functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.showCurrentLocationOnMap()
    }
    
  
    func showCurrentLocationOnMap() {
        
        let camera = GMSCameraPosition.camera(withLatitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!, zoom: 14)
 
    }
}



