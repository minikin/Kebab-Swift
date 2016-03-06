//
//  NEWGetPlacesOperation.swift
//  Kebab
//
//  Created by Sasha Minikin on 2/24/16.
//  Copyright © 2016 Minikin. All rights reserved.
//

import PSOperations
import RealmSwift
import CoreLocation

class  GetPlacesOperation: GroupOperation {
  
  // MARK: Properties
  let downloadOperation: DownloadPlacesOperation
  let parseOperation: ParsePlaceOperation
  
  private var hasProducedAlert = false
  
  /**
   - parameter location: The `CLLocation` with which we build url for request data from Foursquare.
   
   - parameter completionHandler: The handler to call after downloading and
   parsing are complete. This handler will be
   invoked on an arbitrary queue.
   */
  init(location: CLLocation, completionHandler: Void -> Void) {
    
    let cachesFolder = try! NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    
    let cacheFile = cachesFolder.URLByAppendingPathComponent("places.json")

    /*
    This operation is made of three child operations:
    1. The operation to download the JSON feed
    2. The operation to parse the JSON feed and insert the elements into the Core Data store
    3. The operation to invoke the completion handler
    */
    
    downloadOperation = DownloadPlacesOperation(location: location, cacheFile: cacheFile)
    
    parseOperation = ParsePlaceOperation(cacheFile: cacheFile)
    
    let finishOperation = NSBlockOperation(block: completionHandler)
  
    parseOperation.addDependency(downloadOperation)
    finishOperation.addDependency(parseOperation)
    
    super.init(operations: [downloadOperation, parseOperation, finishOperation])
    
    name = "Get New Places"
    
  }
  
  override func operationDidFinish(operation: NSOperation, withErrors errors: [NSError]) {
    
    if let firstError = errors.first where (operation === downloadOperation || operation === parseOperation) {
      produceAlert(firstError)
    }
  }
  
  private func produceAlert(error: NSError) {
    /*
    We only want to show the first error, since subsequent errors might
    be caused by the first.
    */
    if hasProducedAlert { return }
    
    let alert = AlertOperation()
    
    let errorReason = (error.domain, error.code, error.userInfo[OperationConditionKey] as? String)
    
    // These are examples of errors for which we might choose to display an error to the user
    let failedReachability = (OperationErrorDomain, OperationErrorCode.ConditionFailed, ReachabilityCondition.name)
    
    let failedJSON = (NSCocoaErrorDomain, NSPropertyListReadCorruptError, nil as String?)
    
    switch errorReason {
    case failedReachability:
      // We failed because the network isn't reachable.
//      let hostURL = error.userInfo[ReachabilityCondition.hostKey] as! NSURL
      
      alert.title = "No internet"
      alert.message = "Make sure your device is connected to the internet and try again."
      
    case failedJSON:
      // We failed because the JSON was malformed.
      alert.title = "Unable to Download"
      alert.message = "Cannot download venues data. Try again later."
      
    default:
      return
    }
    
    produceOperation(alert)
    hasProducedAlert = true
  }

}