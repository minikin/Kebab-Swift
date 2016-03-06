//
//  ParsedPhotoOperation.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 10/1/15.
//  Copyright © 2015 Minikin. All rights reserved.
//  
//  Abstract:
//  Contains the logic to parse a JSON file of photos and insert them as RealmObject


import RealmSwift
import PSOperations

// A struct to represent a parsed photo.
private struct ParsedPhoto {
  
  // MARK: Properties.
  
  let photoId, prefix, suffix : String
  
  // MARK: Initialization
  
  init?(photos:[String:AnyObject]){
  
    photoId = JSON(photos)?[key:"id"] as? String ?? ""
    
    // Host no-image pic on Flick
    prefix = JSON(photos)?[key:"prefix"] as? String ?? ""
    suffix = JSON(photos)?[key:"suffix"] as? String ?? ""
    
  }
}

/// An `Operation` to parse photos out of a downloaded feed from the Foursquare.
class ParsedPhotoOperation: Operation {
  
  let cacheFile: NSURL
  
  /**
      parameter cacheFile: The file `NSURL` from which to load place data.
  */
  init(cacheFile: NSURL) {
    
    self.cacheFile = cacheFile
    
    super.init()
    
    name = "Parse Photos"
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
      if let photos = JSON(json)?[key:"photos"]?[key:"items"] as? [[String: AnyObject]] {
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
  
  private func parseSave (photos:[[String: AnyObject]]) {
    
    let parsedPhotos = photos.flatMap {ParsedPhoto(photos: $0)}
    
    do {
      // Realms are used to save data
      // Create realm pointing to default file
      let realm = try! Realm()
        try realm.write {
          
          for photo in parsedPhotos {
            self.insert(photo)
          }
          
        }
    } catch let parseError as NSError{
      self.finishWithError(parseError)
    }
  }

  private func insert(parsed:ParsedPhoto) {
    
    let realm = try! Realm()
    let newPhoto = PlacePhotosModel()
    
    guard let selectedVenue = realm.objects(PlaceModel).filter("venueId = '\(publicVenueId)'").first else { return print("selectedVenue error")}
    
    newPhoto.photoId = parsed.photoId
    if parsed.prefix == "" || parsed.suffix == "" {
      newPhoto.photoString = Utils.flickrPhotoUrl
    } else {
      newPhoto.photoString = parsed.prefix  + "original" + parsed.suffix
    }
    
    realm.add(newPhoto, update: true)
    
    if selectedVenue.photos.count > 4 {
      return
    } else {
      selectedVenue.photos.append(newPhoto)
      selectedVenue.photos.realm?.add(newPhoto)
    }
  
  }
}