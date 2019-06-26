//
//  Client.swift
//  VirtualTouristNew
//
//  Created by bdoor on 1/25/19.
//  Copyright © 2019 UdacityHS. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Client: NSObject {
    
    
    static func sendRequest(_ pin: Pin, completion: @escaping (_ photosDict: [[String:AnyObject]]?, String?)->Void) {
        
        let session = URLSession.shared
        let parametersFlicker = [
            "method": APIConstants.PhotoSearch,
            "lat": "\(pin.latitude)",
            "lon": "\(pin.longitude)",
            "format": "json",
            "extras": "url_m",
            "nojsoncallback": "1",
            "api_key": APIConstants.API_KEY,
            "radius": APIConstants.PhotoSearchRadius,
            "per_page": APIConstants.PerPage,
            "page": "\(arc4random_uniform(10))"
        ]
        
        var errorString: String?
        guard var url = URL(string: APIConstants.BaseURL) else { return }
        url = url.URLByAppendingQueryParameters(parametersFlicker)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            
            guard error == nil else {
                
                errorString = "Flickr API returned an error: \(error?.localizedDescription ?? "")"
                completion(nil,errorString)
                print("error")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode < 300 else {
                errorString = "Flickr API returned status code > 300 \(error?.localizedDescription ?? "")"
                completion(nil,errorString)
                print("error")
                return
            }
            
            guard let data = data else {
                errorString = "no data returned : \(error?.localizedDescription ?? "")"
                completion(nil,errorString)
                print("error")
                return
            }
            
            let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            
            guard let element = result??[APIConstants.Photos] as? [String:AnyObject] else {
                errorString = "error in finding results, try again"
                completion(nil,errorString)
                print("error")
                return
            }
            
            guard let photoArray = element[APIConstants.Photo] as? [[String:AnyObject]] else {
                errorString = "error in finding photos, try again"
                completion(nil,errorString)
                print("error")
                return
            }
            
            DispatchQueue.main.async {
                completion(photoArray,errorString)
                
            }
            
            
        })
        
        task.resume()
        
    }
    
    
    static func requestPhotoData(photoURL: String, completionHandlerForConvertData: @escaping (_ result: NSData?, _ error: String?) -> Void) {
        
        let requestURL: NSURL = NSURL(string: photoURL)!
        let task = URLSession.shared.dataTask(with: requestURL as URL) { (data, response, error) in
            
            guard error == nil else {
                print("error")
                completionHandlerForConvertData(nil, "Could not parse data")
                return
            }
            
            guard let data = data else {
                print("error")
                completionHandlerForConvertData(nil, "No data returned for photo")
                return
            }
            
            completionHandlerForConvertData(data as NSData, nil)
        }
        
        task.resume()
        
    }
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension URL {
    
    func URLByAppendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : NSString = NSString(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString as String)!
    }
}

extension Dictionary : URLQueryParameterStringConvertible {
    
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = NSString(format: "%@=%@",
                                String(describing: key).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!,
                                String(describing: value).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}



