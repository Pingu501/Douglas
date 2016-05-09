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
    @IBOutlet weak var weatherIcon: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        weatherIcon.text = "\u{f082}"
        locationLabel.text = "loading ..."
        
        self.view.backgroundColor = UIColor(hue: 52/360, saturation: 0, brightness: 0.47, alpha: 1)
        
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
        //let url = "http://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=8c0de5377117f2900604f8ff069e6fae"
        let url = "https://api.forecast.io/forecast/c3558c4014d176377086e6951837eacb/\(latitude),\(longitude)"
        
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
                        //print(name)

                        //set the UI change into the main frame
                        dispatch_async(dispatch_get_main_queue(), {
                            print(name)
                            self.locationLabel.text = name
                        })
                    }
                    //if let weather = json["list"]!![1]["weather"] as? [AnyObject]{
                    //print(json)
                    if let weather = json["hourly"]!!["data"] as? [AnyObject]{
                        let precipProbability = weather[0]["precipProbability"] as! Double
                        let precipIntensity = weather[0]["precipIntensity"] as! Double
                        
                        //yellow
                        var icon: String
                        var bgColor = UIColor(hue: 52/360, saturation: 0.468, brightness: 0.90, alpha: 1)
                        if (precipProbability >  0.2 || precipIntensity > 0.017) {
                            //blue
                            bgColor = UIColor(hue: 219/360, saturation: 0.468, brightness: 0.90, alpha: 1)
                            icon = "\u{f0c2}"
                        } else {
                            bgColor = UIColor(hue: 52/360, saturation: 0.468, brightness: 0.90, alpha: 1)
                            icon = "\u{f185}"
                        }
                    
                        dispatch_async(dispatch_get_main_queue(), {
                            self.view.backgroundColor = bgColor
                            self.weatherIcon.text = icon
                        })
                    }
                    
                }catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            if error == nil && placemarks!.count > 0 {
                let placemark = placemarks![0] as CLPlacemark
                if(placemark.locality != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.locationLabel.text = placemark.locality!
                    })
                }
            }
        })
        
        let loc:CLLocationCoordinate2D = manager.location!.coordinate
        //print(loc.latitude)
        //print(loc.longitude)
        locationManager.stopUpdatingLocation()
        
        getWeather(loc.latitude,longitude: loc.longitude)
        
    }
    
}

