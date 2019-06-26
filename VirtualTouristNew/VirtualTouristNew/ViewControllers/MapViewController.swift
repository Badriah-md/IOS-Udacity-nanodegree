//
//  MapViewController.swift
//  VirtualTouristNew
//
//  Created by bdoor on 1/25/19.
//  Copyright © 2019 UdacityHS. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var managedContext: NSManagedObjectContext!
    let longPressGesture = UILongPressGestureRecognizer()
    
    var regions: MKCoordinateRegion?
    var pin: Pin?
    
    var pins: [Pin] = []
    
    var fetchRequestPins: NSAsynchronousFetchRequest<Pin>!
    
    var falgRestoring = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapView.delegate = self
        
        longPressGesture.addTarget(self, action: #selector(MapViewController.longPressed))
        view!.addGestureRecognizer(longPressGesture)
        
        restoreMap(animated: true)
        
        
        let pinFetch: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            
            let pins = try managedContext.fetch(pinFetch)
            self.pins = pins
            self.showPins(pins: pins)
            
        } catch let error as NSError {
            print("error: \(error)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveCurrentMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("error \(error)")
        }
        
    }
    
    func saveCurrentMap() {
        
        let dict = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        NSKeyedArchiver.archiveRootObject(dict, toFile: filePath)
    }
    
    var filePath: String = {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("mapRegionArchive").path
    }()
    
    func restoreMap(animated: Bool) {
        
        falgRestoring = true
        
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [String:AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            mapView.setRegion(savedRegion, animated: animated)
        }
        
        falgRestoring = false
    }
    
    
    func showPins(pins: [Pin]) {
        
        for pin in pins {
            var locationCoordinate = CLLocationCoordinate2D()
            locationCoordinate.latitude = pin.latitude
            locationCoordinate.longitude = pin.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationCoordinate
            
            mapView.addAnnotation(annotation)
        }
        
    }
    
    @objc func longPressed(_ sender: AnyObject) {
        
        if longPressGesture.state == UIGestureRecognizer.State.began {
            
            let location = sender.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            let pin = Pin(context: managedContext)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("error: \(error)")
            }
            
            mapView.addAnnotation(annotation)
            
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cont = segue.destination as! PhotoAlbumViewController
        
        cont.managedContext = managedContext
        cont.focusedRegion = regions
        cont.pin = pin
        
    }
    
    func presentPhotosViewController(pin: Pin, coordinate: CLLocationCoordinate2D) {
        
        let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let latitudeDelta = mapView.region.span.latitudeDelta / 4
        let longitudeDelta = mapView.region.span.longitudeDelta
        
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
 
        regions = MKCoordinateRegion(center: center, span: span)
        
        performSegue(withIdentifier: "PhotoAlbumViewController", sender: self)
    }
    
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if falgRestoring == false {
            saveCurrentMap()
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        } else {
           pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        mapView.deselectAnnotation(view.annotation! , animated: true)
        
        guard view.annotation != nil else {
            print("error")
            return
            
        }
        
        let coordinate = view.annotation!.coordinate
        
        let pinFetch: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            let pins = try managedContext.fetch(pinFetch)
            
            if pins.count > 0 {
                self.pin = pins.first
                self.presentPhotosViewController(pin: self.pin!, coordinate: coordinate)
                
            } else {
                print("no matching pin")
            }
            
        } catch let error as NSError {
            print("error: \(error)")
        }
        
        
    }
    
}
