//
//  DownloadTips.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 10/1/15.
//  Copyright © 2015 Minikin. All rights reserved.
//
//Abstract:
//This file contains the code to download the feed of place tips
//
// https://developer.foursquare.com/docs/venues/tips
//

import PSOperations

class DownloadTipsOperation : GroupOperation {
  
  
  // MARK: Properties
  
  let cacheFile: NSURL
  var venueId : String
  
  init(cacheFile : NSURL){
    
    self.cacheFile = cacheFile
    self.venueId = publicVenueId
    
  
    super.init(operations: [])
    
    name = "Download Tips"
    
    
    let url = FoursquareEndpoints.getTipsURLforVenue("\(venueId)")
    
    let task = NSURLSession.sharedSession().downloadTaskWithURL(url) {url, response, error in
        self.downloadFinished(url, response: response as?  NSHTTPURLResponse, error: error)
    }
    
    let taskOperation = URLSessionTaskOperation(task: task)
    
    let reachabilityCondition = ReachabilityCondition(host: url)
    taskOperation.addCondition(reachabilityCondition)
    
    let networkObserver = NetworkObserver()
    taskOperation.addObserver(networkObserver)
    
    addOperation(taskOperation)
  }
  
  
  // TODO: - REFACTOR THIS CODE!!!
  
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