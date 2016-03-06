//
//  NewDownloadPlacesOperation.swift
//  Kebab
//
//  Created by Sasha Minikin on 2/24/16.
//  Copyright © 2016 Minikin. All rights reserved.
//

import PSOperations
import CoreLocation

class  DownloadPlacesOperation: GroupOperation {
  
  // MARK:- Class Properties
  let cacheFile: NSURL
  let location : CLLocation
  
  // MARK:- Request properties
  
  let defaults = NSUserDefaults.standardUserDefaults()
  var venueType = ""
  var searchRadius = ""
  var switchState = true
  var placeOpen = 1
  
  
  init(location: CLLocation, cacheFile: NSURL) {
    
    // Post notification
    
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.kebabGetPlaceOperationStarted, object: nil)
    
    self.location = location
    self.cacheFile = cacheFile
    super.init(operations: [])
    
    name  = "Download Places"
    
    self.venueType = self.defaults.stringForKey("Junkfood categories")!
    self.searchRadius = self.defaults.stringForKey("Search radius")!
    self.switchState = self.defaults.boolForKey("SwitchState")
    
    if self.switchState == true {
      self.placeOpen = 1
    } else {
      self.placeOpen = 0
    }
    
    // MARK: - Build URL
    let url = FoursquareEndpoints.getVenues(location, placeType: self.venueType, searchRadiuis: self.searchRadius, placeOpen: self.placeOpen)
    
    let task = NSURLSession.sharedSession().downloadTaskWithURL(url) { url, response, error in
      self.downloadFinished(url, response: response as? NSHTTPURLResponse, error: error)
    }
    
    let taskOperation = URLSessionTaskOperation(task: task)
    
    let networkObserver = NetworkObserver()
    taskOperation.addObserver(networkObserver)
    
    let reachabilityCondition = ReachabilityCondition(host:NSURL(string: "https://www.google.com")!)
    taskOperation.addCondition(reachabilityCondition)
    
    self.addOperation(taskOperation)
  }
  
  func downloadFinished(url: NSURL?, response: NSHTTPURLResponse?, error: NSError?) {
    if let localURL = url {
      do {
        /*
        If we already have a file at this location, just delete it.
        Also, swallow the error, because we don't really care about it.
        */
        try NSFileManager.defaultManager().removeItemAtURL(cacheFile)
      }
      catch { }
      
      do {
        try NSFileManager.defaultManager().moveItemAtURL(localURL, toURL: cacheFile)
      }
      catch let error as NSError {
        aggregateError(error)
      }
      
    }
    else if let error = error {
      aggregateError(error)
    }
    else {
      // Do nothing, and the operation will automatically finish.
    }
  }

}
