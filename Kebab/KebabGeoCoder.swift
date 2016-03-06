//
//  KebabGeoCoder.swift
//  Kebab
//
//  Created by Sasha Minikin on 1/21/16.
//  Copyright © 2016 Minikin. All rights reserved.
//

import Foundation
import CoreLocation
import Contacts
import MapKit
import PSOperations

class KebabGeoCoder : Operation {
  
  var location: CLLocation

 // MARK: - Reverse geocoding function
  
//  This method submits the specified location data to the geocoding server asynchronously and returns.
//  Completion handler block will be executed on the main thread. After initiating a reverse-geocoding request, 
//  do not attempt to initiate another reverse- or forward-geocoding request.
  
  init(location:CLLocation) {
    
    self.location = location
    
    super.init()
    
    let geoCoder = CLGeocoder()
    
    let networkObserver = NetworkObserver()
    
    addCondition(MutuallyExclusive<CLGeocoder>())
    addObserver(networkObserver)
    
    geoCoder.reverseGeocodeLocation(location) {(placemarks:[CLPlacemark]?, error) in
      
      if error != nil {
        
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.kebabGeoCoderCantParseData, object: nil)
        
        self.finish()
        
      } else if placemarks!.count > 0 {
        
        let placemark = placemarks![0]
      
        self.showReverseMap(placemark)
      }
    }
  
  }
  
  // MARK: Overrides
  
  override func execute() {
    // I'm not sure what I should to override here
  }
  
  // Open maps.app and build route
  
  private func showReverseMap (placemark:CLPlacemark) {
      
      let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking]
      let place = MKPlacemark(placemark: placemark)
      let mapItem = MKMapItem(placemark: place)
      
      mapItem.openInMapsWithLaunchOptions(options)
    
      self.finish()
    }

  
}
