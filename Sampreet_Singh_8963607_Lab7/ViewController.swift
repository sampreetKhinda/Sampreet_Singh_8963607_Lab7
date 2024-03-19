//
//  ViewController.swift
//  Sampreet_Singh_8963607_Lab7
//
//  Created by Sampreet singh on 18/03/24.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var currSpeedLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var aveSpeedLabel: UILabel!
    @IBOutlet weak var disLabel: UILabel!
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var stopView: UIView!
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var maxAcceLabel: UILabel!
    
    let speedLimit = 115.0 // km/h
    var clLocationManager: CLLocationManager!
    var clStartLocation: CLLocation?
    var clLastLocation: CLLocation?
    var clMaxSpeed: CLLocationSpeed = 0.0
    var clDistance: CLLocationDistance = 0.0
    var clSpeed: CLLocationSpeed = 0.0
    var startTime: Date?
    var endTime: Date?
    var totalSpeed: CLLocationSpeed = 0.0
    var speedReadings: Int = 0
    var isUpdatingLocation: Bool = false
    let speedFormat = "%.1f km/h"
    let speedMesaueUnit = 3.6

    override func viewDidLoad() {
        super.viewDidLoad()
        clLocationManager = CLLocationManager()
        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        clLocationManager.requestWhenInUseAuthorization()
    }

    // Function called when user clicked start tracking button
    @IBAction func startTrackingBtn(_ sender: UIButton) {
        clLocationManager.startUpdatingLocation()
        startTime = Date()
        startView.backgroundColor = .green
        stopView.isHidden = true
        myMap.showsUserLocation = true
        myMap.setUserTrackingMode(.follow, animated: true)
        isUpdatingLocation = true
    }
    
    // Function called when user clicked stop tracking button
    @IBAction func stopTrackingBtn(_ sender: UIButton) {
        clLocationManager.stopUpdatingLocation()
        endTime = Date()
        startView.backgroundColor = .gray
        currSpeedLabel.text = "0.00 km/h"
        myMap.showsUserLocation = false
        myMap.setUserTrackingMode(.none, animated: true)
        isUpdatingLocation = false
    }
    
    // Function called to get location from location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isUpdatingLocation, let liveLocation = locations.last else { return }
        let currentSpeed = liveLocation.speed
        currSpeedLabel.text = String(format: speedFormat, abs(currentSpeed) * speedMesaueUnit)
        if(abs(currentSpeed)*3.6) >= speedLimit {
            stopView.isHidden = false
        }else{
            stopView.isHidden = true
        }
        
        if currentSpeed > clMaxSpeed {
            clMaxSpeed = currentSpeed
            maxSpeedLabel.text = String(format: speedFormat, abs(clMaxSpeed) * speedMesaueUnit)
        }
        
        totalSpeed += currentSpeed
        speedReadings += 1
        let averageSpeed = totalSpeed / Double(speedReadings)
        aveSpeedLabel.text = String(format: speedFormat, abs(averageSpeed) * speedMesaueUnit)
        
        if let lastLocation = clLastLocation {
            let distanceIncrement = liveLocation.distance(from: lastLocation)
            clDistance += distanceIncrement
            disLabel.text = String(format: "%.2f km", clDistance / 1000)
            
            let timeIncrement = liveLocation.timestamp.timeIntervalSince(lastLocation.timestamp)
            clSpeed = (currentSpeed - lastLocation.speed) / timeIncrement
            maxAcceLabel.text = String(format: "%.1f m/s²", abs(clSpeed))
        }
        
        clLastLocation = liveLocation
        
        // Update map to show driver's location with zoom in
        myMap.setCenter(liveLocation.coordinate, animated: true)
        let region = MKCoordinateRegion(center: liveLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        myMap.setRegion(region, animated: true)
    }
    
    func calculateDistanceToExceedSpeedLimit() -> CLLocationDistance {
        let averageSpeed = totalSpeed / Double(speedReadings)
        let timeToExceedLimit = (speedLimit / (averageSpeed * speedMesaueUnit))
        let distanceToExceedLimit = timeToExceedLimit * clMaxSpeed * speedMesaueUnit * 1000
        return distanceToExceedLimit
    }
}
