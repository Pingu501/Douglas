//
//  ViewController.swift
//  Douglas
//
//  Created by Alexander Hesse on 29.04.16.
//  Copyright © 2016 Suedwolf. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationLabel.text = "loading ..."
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWeather(latitude: Double, longitude: Double) {
        let url = "http://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=8c0de5377117f2900604f8ff069e6fae"
        
        let requestURL: NSURL = NSURL(string: url)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    if let city = json["city"] as? [String: AnyObject], let name = city["name"] as? String {
                        print(name)
                        
                        dispatch_async(dispatch_get_main_queue(), { 
                            self.locationLabel.text = name
                        })
                    }
                }catch {
                    print("Error with Json: \(error)")
                    self.locationLabel.text = "ERROR"
                }
            }
        }
        
        task.resume()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("hello")
        let loc:CLLocationCoordinate2D = manager.location!.coordinate
        print(loc.latitude)
        print(loc.longitude)
        
        getWeather(loc.latitude,longitude: loc.longitude)
    }
    
}

