//
//  ViewController.swift
//  Places to Eat & Drink on Campus
//
//  Created by Chockalingam, Nitya on 29/11/2024.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

struct FoodData: Codable {
    var food_venues : [ Venue_Info ]
    let last_modified : String
}

struct Venue_Info: Codable {
    let name: String
    let building: String
    let lat: String
    let lon: String
    let description: String
    let opening_times: [String]
    let amenities: [String]?
    let photos: [String]?
    let URL: URL?
    let last_modified: String
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    //var venues: [Venue_Info] = []
    let locationManager = CLLocationManager()
    var firstRun = true
    var startTrackingTheUser = false
    var userLocation: CLLocation?
    var venuesCD: [Venues1] = []
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationOfUser = locations[0] //this method returns an array of locations
        //generally we always want the first one (usually there's only 1 anyway)
        let latitude = locationOfUser.coordinate.latitude
        let longitude = locationOfUser.coordinate.longitude
        //get the users location (latitude & longitude)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if firstRun {
            firstRun = false
            let latDelta: CLLocationDegrees = 0.0025
            let lonDelta: CLLocationDegrees = 0.0025
            //a span defines how large an area is depicted on the map.
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            
            //a region defines a centre and a size of area covered.
            let region = MKCoordinateRegion(center: location, span: span)
            //make the map show that region we just defined.
            self.mapView.setRegion(region, animated: true)
            
            //the following code is to prevent a bug which affects the zooming of the map to the user's location.
            //We have to leave a little time after our initial setting of the map's location and span,
            //before we can start centering on the user's location, otherwise the map never zooms in because the
            //intial zoom level and span are applied to the setCenter( ) method call, rather than our "requested" ones,
            //once they have taken effect on the map.
            
            //we setup a timer to set our boolean to true in 5 seconds.
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector:
                                        #selector(startUserTracking), userInfo: nil, repeats: false)
        }
        
        if startTrackingTheUser == true {
            mapView.setCenter(location, animated: true)
        }
        userLocation = locationOfUser
        sortVenuesByDistance()
    }
    
    //this method sets the startTrackingTheUser boolean class property to true. Once it's true,
    //subsequent calls to didUpdateLocations will cause the map to centre on the user's location.
    
    @objc func startUserTracking() {
        startTrackingTheUser = true
    }
    
    // MARK: View related Stuff
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
            
        // Make this view controller a delegate of the Location Manager, so that it
        //is able to call functions provided in this view controller.
        locationManager.delegate = self as CLLocationManagerDelegate
            
        //set the level of accuracy for the user's location.
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
   
        //Ask the location manager to request authorisation from the user. Note that this
        //only happens once if the user selects the "when in use" option. If the user
        //denies access, then your app will not be provided with details of the user's
        //location.
        locationManager.requestWhenInUseAuthorization()
            
        //Once the user's location is being provided then ask for updates when the user
        //moves around.
        locationManager.startUpdatingLocation()
            
        //configure the map to show the user's location (with a blue dot).
        mapView.delegate = self
        mapView.showsUserLocation = true
            
        tableView.delegate = self
        tableView.dataSource = self
            
        fetchVenueData()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venuesCD.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        var content = UIListContentConfiguration.subtitleCell()
        content.text = venuesCD[indexPath.row].venueName
        content.secondaryText = venuesCD[indexPath.row].building
        
        
        let isLiked = venuesCD[indexPath.row].isLiked
        
        if isLiked == "1" {
            content.image = UIImage(systemName: "hand.thumbsup.fill")
        } else if isLiked == "-1" {
            content.image = UIImage(systemName: "hand.thumbsdown.fill")
        }
        
        //content.image = UIImage(systemName: "SOMETHING")
        
        
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let venue = venuesCD[indexPath.row]
        if let latitude = Double(venue.lat!), let longitude = Double(venue.lon!) {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            centerMapOnLocation(coordinate: coordinate, title: venue.venueName)
            performSegue(withIdentifier: "showVenueDetails", sender: venue)
        }
    }
    
    
    func fetchVenueData() {
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/eating_venues/data.json") {
                let session = URLSession.shared
                session.dataTask(with: url) { (data, response, err) in
                    guard let jsonData = data else { return }
                    do {
                        let decoder = JSONDecoder()
                        let venuInfo = try decoder.decode(FoodData.self, from: jsonData)
                       // self.venues = venuInfo.food_venues
                    
                        
                        
                        DispatchQueue.main.async {
                            self.fetchData()
                            
                            if self.venuesCD.count == 0 {
                                for venue in venuInfo.food_venues {
                                    self.save(venueName: venue.name, building: venue.building, amenities: venue.amenities ?? [], desc: venue.description, isLiked: "0", /* MAKE DISLIKED */ lastMod: venue.last_modified, lat: venue.lat, lon: venue.lon, openTimes: venue.opening_times, url: venue.URL?.absoluteString ?? "")
                                }
                                self.fetchData()
                            }
                            //else, compared JSON venue to Core Data venue
                            //if last modified newer on JSON, update core data
                            
                           
                            
                            
                            self.addVenueAnnotations()
                            self.tableView.reloadData()
//                            self.saveVenueToCoreData(venueInfo: venuInfo.food_venues)
                        }
                    } catch let jsonErr {
                        print("Error decoding JSON", jsonErr)
                    }
                }.resume()
            }
        }
    
    // MARK: - Map View
    func addVenueAnnotations() {
        for venue in venuesCD {
            let annotation = MKPointAnnotation()
            if let latitude = Double(venue.lat!), let longitude = Double(venue.lon!) {
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = venue.venueName
                annotation.subtitle = venue.building
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func centerMapOnLocation(coordinate: CLLocationCoordinate2D, title: String?) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let title = view.annotation?.title {
            print("Selected annotation: \(title ?? "")")
            
            // Find the corresponding venue based on the annotation's title
            if let venueTitle = view.annotation?.title, let selectedVenue = venuesCD.first(where: { $0.venueName == venueTitle }) {
                // Perform the segue and pass the selected venue to the new view controller
                performSegue(withIdentifier: "showVenueDetails", sender: selectedVenue)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVenueDetails" {
            // Get the destination view controller
            if let destinationVC = segue.destination as? VenueDetailsViewController {
                // Pass the selected venue to the destination view controller
                if let selectedVenue = sender as? Venues1 {
                    destinationVC.venue = selectedVenue
                }
            }
        }
    }
    
    // MARK: - Utilities

    
    func sortVenuesByDistance() {
        guard let userLocation = userLocation else { return }
        venuesCD.sort { venue1, venue2 in
            let location1 = CLLocation(latitude: Double(venue1.lat!) ?? 0, longitude: Double(venue1.lon!) ?? 0)
            let location2 = CLLocation(latitude: Double(venue2.lat!) ?? 0, longitude: Double(venue2.lon!) ?? 0)
            return location1.distance(from: userLocation) < location2.distance(from: userLocation)
        }
        tableView.reloadData()
    }
    
    
    
    func fetchData() {
       guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
       }

       let managedContext = appDelegate.persistentContainer.viewContext
       let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"Venues1")

       do {
           venuesCD = try managedContext.fetch(fetchRequest) as! [Venues1]

       } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
       }
    }
    
    func save(venueName: String, building: String, amenities: [String], desc: String, isLiked: String, /* MAKE DISLIKED */ lastMod: String, lat: String, lon: String, openTimes: [String], url: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let venue = NSEntityDescription.insertNewObject(forEntityName: "Venues1", into: managedContext) as! Venues1
        
//            contact.firstName = theFirstName
//            contact.lastName = theLastName
//            contact.telephoneNumber = theTelephoneNumber
        
        let openString = openTimes.joined(separator: "|")
        
        var amenString = ""
        
        if amenities.count != 0 {
            amenString = amenities.joined(separator: "|")
        }
       
        
        venue.venueName = venueName
        venue.building = building
        venue.amenities = amenString
        venue.descriptionText = desc
        venue.isLiked = isLiked
        //MAKE DISLIKED
        venue.last_modified = lastMod
        venue.lat = lat
        venue.lon = lon
        venue.opening_times = openString
        venue.url = url
        
        
        do {
            try managedContext.save()
            print("SAVED")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    
    
}
