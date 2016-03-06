//
//  KebabLocationOperation.swift
//  Kebab
//
//  Created by Sasha Minikin on 2/25/16.
//  Copyright © 2016 Minikin. All rights reserved.
//

import Foundation
import CoreLocation
import PSOperations


/**
 `KebabLocationOperation` is an `Operation` subclass to do a "one-shot" request to
 get the user's current location, with a desired accuracy. This operation will
 prompt for `WhenInUse` location authorization, if the app does not already
 have it.
 */
class KebabLocationOperation: Operation, CLLocationManagerDelegate {
  
  // MARK: Properties
  
  private let accuracy: CLLocationAccuracy
  private var manager: CLLocationManager?
  private let handler: CLLocation -> Void
  
  // MARK: Initialization
  
  init(accuracy: CLLocationAccuracy, locationHandler: CLLocation -> Void) {
    
    self.accuracy = accuracy
    self.handler = locationHandler
    
    super.init()
    
    addCondition(Capability(Location.WhenInUse))

    addCondition(MutuallyExclusive<CLLocationManager>())
    
    addObserver(BlockObserver(cancelHandler: { [weak self] _ in
      dispatch_async(dispatch_get_main_queue()) {
        self?.stopLocationUpdates()
      }
    }))
    
  }
  
  override func execute() {
    dispatch_async(dispatch_get_main_queue()) {
      /*
      `CLLocationManager` needs to be created on a thread with an active
      run loop, so for simplicity we do this on the main queue.
      */
      
      let manager = CLLocationManager()
      
      manager.desiredAccuracy = self.accuracy
      manager.delegate = self
      
      manager.requestLocation()
      
      NSNotificationCenter.defaultCenter().postNotificationName(Notifications.kebabDidStartLocatingUser, object: nil)
      
      self.manager = manager
  
    }
  }
  
  private func stopLocationUpdates() {
    manager?.stopUpdatingLocation()
    manager = nil
  }
  
  // MARK: CLLocationManagerDelegate
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last where location.horizontalAccuracy <= accuracy {
      print(location)
      stopLocationUpdates()
      handler(location)
      NSNotificationCenter.defaultCenter().postNotificationName(Notifications.kebabDidFinishLocatingUser, object: nil)
      finish()
    }
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    stopLocationUpdates()
    print("didFailWithError")
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.kebabDidFinishLocatingUserWithError, object: nil)
    finishWithError(error)
  }
  


}