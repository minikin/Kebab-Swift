//
//  ParseTips.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 10/1/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import RealmSwift
import PSOperations

// A struct to represent a parsed photo.
private struct ParsedTip {
  
  // MARK: Properties.
  
  let tipsId, userId, userFirstName, userLastName, text : String
  
  // MARK: Initialization
  
  init?(tips:[String:AnyObject]){
    
    tipsId = JSON(tips)?[key:"id"] as? String ?? ""
    userId = JSON(tips)?[key:"user"]?[key:"id"] as? String ?? ""
    userFirstName = JSON(tips)?[key:"user"]?[key:"firstName"] as? String ?? ""
    userLastName = JSON(tips)?[key:"user"]?[key:"lastName"] as? String ?? ""
    text = JSON(tips)?[key:"text"] as? String ?? ""
    
  }
}


/// An `Operation` to parse photos out of a downloaded feed from the Foursquare.
class ParsedTipsOperation: Operation {
  
  let cacheFile: NSURL
  
  /**
   parameter cacheFile: The file `NSURL` from which to load place data.
   */
  init(cacheFile: NSURL) {
    
    self.cacheFile = cacheFile
    
    super.init()
    
    name = "Parse Tips"
  }
  
  override func execute() {
    guard let stream = NSInputStream(URL: cacheFile) else {
      finish()
      return
    }
    
    stream.open()
    
    defer {
      stream.close()
    }
    
    do {
      
      let json = try (NSJSONSerialization.JSONObjectWithStream(stream, options: []) as! NSDictionary)["response"]
      
      if let photos = JSON(json)?[key:"tips"]?[key:"items"] as? [[String: AnyObject]] {
        parseSave(photos)
      } else {
        finish()
      }
      
      finish()
    }
    catch let jsonError as NSError {
      finishWithError(jsonError)
    }
  }
  
  private func parseSave (tips:[[String: AnyObject]]) {
    let parsedTips = tips.flatMap{ParsedTip(tips: $0)}
    
    do {
      // Realms are used to save data
      // Create realm pointing to default file
      let realm = try! Realm()
      try realm.write({ () -> Void in
        for photo in parsedTips {
          self.insert(photo)
        }
      })
    } catch let parseError as NSError{
      self.finishWithError(parseError)
    }
  }
  
  private func insert(parsed:ParsedTip) {
    let realm = try! Realm()
    
    let newTips = PlaceTipsModel()
    guard let selectedVenue = realm.objects(PlaceModel).filter("venueId = '\(publicVenueId)'").first else { return }
    
//    let newTipsExists = realm.objectForPrimaryKey(PlaceTipsModel.self, key: "\(parsed.tipsId)")
    
    newTips.tipsId  = parsed.tipsId
    newTips.userId = parsed.userId
    newTips.userFirstName = parsed.userFirstName
    newTips.userLastName = parsed.userLastName
    newTips.text = parsed.text
  
    realm.add(newTips, update: true)
    
    if selectedVenue.tips.count > 5 {
      return
    } else {
      selectedVenue.tips.append(newTips)
    }
    
  }
}
