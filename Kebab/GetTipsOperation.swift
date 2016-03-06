//
//  GetTips.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 10/1/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import RealmSwift
import PSOperations

class GetTipsOperation : GroupOperation {
  
  // MARK: Properties
  let downloadOperation: DownloadTipsOperation
  let parseOperation: ParsedTipsOperation
  
  private var hasProducedAlert = false
  
  
  init(realm: Realm, completionHandler: Void -> Void) {
    
    
    let cachesFolder = try! NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    let cacheFile = cachesFolder.URLByAppendingPathComponent("tips.json")
    
    /*
    This operation is made of three child operations:
    1. The operation to download the JSON feed
    2. The operation to parse the JSON feed and insert the elements into the Core Data store
    3. The operation to invoke the completion handler
    */
    
    downloadOperation = DownloadTipsOperation(cacheFile: cacheFile)
    parseOperation = ParsedTipsOperation(cacheFile: cacheFile)
    
    
    let finishOperation = NSBlockOperation(block: completionHandler)
    
    // These operations must be executed in order
    parseOperation.addDependency(downloadOperation)
    finishOperation.addDependency(parseOperation)
    
    super.init(operations: [downloadOperation, parseOperation, finishOperation])
    
    name = "Get Tips"
  
  }

  
  // I don't care if I can't download some photos
  override func operationDidFinish(operation: NSOperation, withErrors errors: [NSError]) {
    
    if let firstError = errors.first where (operation === downloadOperation || operation === parseOperation) {
      produceAlert(firstError)
      print(firstError)
    }
    
//    print("GetPhotosOperation operationDidFinish")
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
      
      alert.title = "No internet"
      alert.message = "Make sure your device is connected to the internet and try again."
      
    case failedJSON:
      // We failed because the JSON was malformed.
      alert.title = "Unable to Download"
      alert.message = "Cannot download photos. Try again later."
      
    default:
      return
    }
    
    produceOperation(alert)
    hasProducedAlert = true
  }
}