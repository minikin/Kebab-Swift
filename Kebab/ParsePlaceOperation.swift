//
//  ParsePlaceOperation.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 9/21/15.
//  Copyright © 2015 Minikin. All rights reserved.
//
//Abstract:
//  Contains the logic to parse a JSON file of places and insert them into an RealmObject
//

import PSOperations
import RealmSwift

// A struct to represent a parsed place.
private struct ParsedPlace  {
  
  // MARK: - Properties
  
  let updatedAt : NSDate
  
  let venueCategory, venueId, venueName, venueAddress, venueCity, venueState, venuePostalCode, venueCountryCode, venueStatus, prefix, suffix: String
  
  let venueRating, latitude, longitude, distanceToVenue: Double
  
  // MARK: - Initialization
  
  init?(venues:[String: AnyObject]) {
    
    guard let maybeVenueId = JSON(venues)?[key:"venue"]?[key:"id"] as? String where !maybeVenueId.isEmpty else { return nil }
    venueId = maybeVenueId
    
    venueName = JSON(venues)?[key:"venue"]?[key:"name"] as? String ?? "No name"
    venueRating = JSON(venues)?[key:"venue"]?[key:"rating"] as? Double ?? 1.0
    venueAddress = JSON(venues)?[key:"venue"]?[key:"location"]?[key:"address"] as? String ?? "Sorry, no address."
    venueCity = JSON(venues)?[key:"venue"]?[key:"location"]?[key:"city"] as? String ?? ""
    venueState = JSON(venues)?[key:"venue"]?[key:"location"]?[key:"state"] as? String ?? ""
    venuePostalCode = JSON(venues)?[key:"venue"]?[key:"location"]?[key:"postalCode"] as? String ?? ""
    venueCountryCode = JSON(venues)?[key:"venue"]?[key:"location"]?[key:"country"] as? String ?? ""
    distanceToVenue = JSON(venues)?[key:"venue"]?[key:"location"]?[key:"distance"] as? Double ?? 0.0
    latitude = JSON(venues)?[key:"venue"]?[key:"location"]?[key:"lat"] as? Double ?? 0.0
    longitude = JSON(venues)?[key:"venue"]?[key:"location"]?[key:"lng"] as? Double ?? 0.0
    venueStatus = JSON(venues)?[key:"venue"]?[key:"hours"]?[key:"status"] as? String ?? "Maybe Open 👾"
    
    prefix = JSON(venues)?[key:"venue"]?[key:"featuredPhotos"]?[key:"items"]?[index:0]?[key:"prefix"] as? String ?? ""
    suffix = JSON(venues)?[key:"venue"]?[key:"featuredPhotos"]?[key:"items"]?[index:0]?[key:"suffix"] as? String ?? ""
    
    // FIXME: -  FIX THIS!!!
    venueCategory = venueType
  
    updatedAt = NSDate()
  }
}

/// An `Operation` to parse places out of a downloaded feed from the Foursquare.
class ParsePlaceOperation: Operation {
  
    let cacheFile: NSURL
  
  /**
      - parameter cacheFile: The file `NSURL` from which to load place data.
  */
  
  init(cacheFile: NSURL) {
    
    self.cacheFile = cacheFile
    super.init()
    
    name = "Parse Places"
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
      
      if let venues = JSON(json)?[key:"groups"]?[index:0]?[key:"items"] as? [[String: AnyObject]] {
           parseSave(venues)
      } else {
        print("We're sorry but Foursquare servers are experiencing problems.Please retry later.")
        finish()
      }
            
      finish()
      
    }
    catch let jsonError as NSError {
      finishWithError(jsonError)
    }
  }
  
  private func parseSave (venues:[[String: AnyObject]]) {
    
    let parsedPlaces = venues.flatMap{ParsedPlace(venues: $0)}

        do {
          // Realms are used to save data
          // Create realm pointing to default file
          let realm = try! Realm()
          
          try realm.write {
            for venue in parsedPlaces {
              self.insert(venue)
            }
          }
          
        } catch let parseError as NSError{
          self.finishWithError(parseError)
      }

  }
  
  private func insert(parsed:ParsedPlace) {
    
    let realm = try! Realm()
    let newPlace = PlaceModel()
    
    newPlace.venueId = parsed.venueId
    newPlace.venueName = (parsed.venueName.stringByApplyingTransform(NSStringTransformToLatin, reverse: false)?.localizedCapitalizedString)!
    newPlace.venueAddress = (parsed.venueAddress.stringByApplyingTransform(NSStringTransformToLatin, reverse: false)?.localizedCapitalizedString)!
    newPlace.venueCity = parsed.venueCity
    newPlace.venueState = parsed.venueState
    newPlace.venuePostalCode = parsed.venuePostalCode
    newPlace.venueCountryCode = parsed.venueCountryCode
    newPlace.latitude = parsed.latitude
    newPlace.longitude = parsed.longitude
    newPlace.distanceToVenue = parsed.distanceToVenue
    newPlace.venueRating = parsed.venueRating
    newPlace.venueStatus = parsed.venueStatus
    newPlace.updatedAt = parsed.updatedAt
    newPlace.venueCategory = parsed.venueCategory
    
    if parsed.prefix == "" || parsed.suffix == "" {
      newPlace.featuredPhoto = Utils.flickrPhotoUrl
    } else {
      newPlace.featuredPhoto = parsed.prefix + PhotoSize.medium.rawValue + parsed.suffix
    }

    realm.add(newPlace, update: true)
  }

}