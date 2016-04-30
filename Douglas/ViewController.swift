//
//  ViewController.swift
//  Douglas
//
//  Created by Alexander Hesse on 29.04.16.
//  Copyright © 2016 Suedwolf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationLabel.text = "loading ..."
        
        getWeather()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWeather() {
        let url = "http://api.openweathermap.org/data/2.5/forecast?lat=51.0278436&lon=13.7210183&appid=8c0de5377117f2900604f8ff069e6fae"
        
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
                        self.locationLabel.text = name
                    }
                }catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        
        task.resume()
    }
    @IBOutlet weak var locationLabel: UILabel!
}

