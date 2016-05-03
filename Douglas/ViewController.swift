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
        
        self.view.backgroundColor = UIColor(hue: 52/360, saturation: 0.2, brightness: 0.90, alpha: 1)
        
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
        
        //print(url)
        
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
                    
                    if let weather = json["list"]!![1]["weather"] as? [AnyObject]{
                        let weatherid = weather[0]["id"] as! Int
                        
                        print(weatherid)
                        
                        //yellow
                        var bgColor = UIColor(hue: 52/360, saturation: 0.468, brightness: 0.90, alpha: 1)
                        if (weatherid < 800) {
                            //blue
                            //bgColor = UIColor(hue: 219/360, saturation: 0.468, brightness: 0.90, alpha: 1)
                        } else {
                            bgColor = UIColor(hue: 52/360, saturation: 0.468, brightness: 0.90, alpha: 1)
                        }
                    
                        dispatch_async(dispatch_get_main_queue(), {
                            self.view.backgroundColor = bgColor
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
        let loc:CLLocationCoordinate2D = manager.location!.coordinate
        //print(loc.latitude)
        //print(loc.longitude)
        //locationManager.stopUpdatingLocation()
        print("update")
        
        getWeather(loc.latitude,longitude: loc.longitude)
        
    }
    
}

