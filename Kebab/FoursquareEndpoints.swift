//
//  FoursquareEndpoints.swift
//  Kebab
//
//  Created by Sasha Minikin on 1/20/16.
//  Copyright © 2016 Minikin. All rights reserved.
//

import Foundation
import CoreLocation

// FIXME: - I need to change this. !!!
public var venueType = ""

struct FoursquareEndpoints {
  
  // Buils venues request URL
  
  static func getVenues(userLocation: CLLocation, placeType: String, searchRadiuis: String, placeOpen: Int) -> NSURL {
    
    var URL = NSURL(string: "\(FoursquareData.baseFoursquareUrl.rawValue)explore")
    
    if FoursquareData.clientId.rawValue != "Your client Id" ||  FoursquareData.clientSecret.rawValue != "Your client secret" {
      
      let URLParams = [
        "client_id": "\(FoursquareData.clientId.rawValue)",
        "client_secret": "\(FoursquareData.clientSecret.rawValue)",
        "ll" : "\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)",
        "query" : "\(placeType)",
        "radius" : "\(searchRadiuis)",
        "openNow" : "\(placeOpen)",
        "venuePhotos" : "1",
        "limit" : "\(FoursquareData.limitSearch.rawValue)",
        "v": "\(FoursquareData.version.rawValue)"
        
      ]
      
      // TODO: - FIX!
      venueType = placeType
      
      URL = NSURLByAppendingQueryParameters(URL, queryParameters: URLParams)
      
    } else {
      
      print("Please, put your Foursquare client Id & client secret at Constants.swift. Check official documentation: https://developer.foursquare.com/start")
      
    }

    
    return URL!
  }
  
  
  //  Build request for Venue photos
  
  static func getPhotosURLforVenue(veneuId: String) -> NSURL {
    
    var URL = NSURL(string: "\(FoursquareData.baseFoursquareUrl.rawValue)\(veneuId)/photos")
    
    let URLParams = [
      "v": "\(FoursquareData.version.rawValue)",
      "client_id": "\(FoursquareData.clientId.rawValue)",
      "client_secret": "\(FoursquareData.clientSecret.rawValue)",
      "limit": "\(FoursquareData.limitPhotos.rawValue)"
    ]
    
    URL = NSURLByAppendingQueryParameters(URL, queryParameters: URLParams)
    
    return URL!
  }
  
  
  //  Build request for Venue tips
  
  static func getTipsURLforVenue(veneuId: String) -> NSURL {
    
    var URL = NSURL(string: "\(FoursquareData.baseFoursquareUrl.rawValue)\(veneuId)/tips")
    
    let URLParams = [
      "v": "\(FoursquareData.version.rawValue)",
      "client_id": "\(FoursquareData.clientId.rawValue)",
      "client_secret": "\(FoursquareData.clientSecret.rawValue)",
      "limit": "\(FoursquareData.limitPhotos.rawValue)",
      "sort": "popular"
    ]
    
    URL = NSURLByAppendingQueryParameters(URL, queryParameters: URLParams)
    
    return URL!
  }
  

}