//
//  PlaceModel.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 9/19/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import CoreLocation
import RealmSwift
import Mapbox

class PlaceModel: Object {
  
  // MARK: Properties
  
  dynamic var venueCategory = ""
  dynamic var venueId = ""
  dynamic var venueName = ""
  dynamic var venueAddress = ""
  dynamic var venueCity = ""
  dynamic var venueState = ""
  dynamic var venuePostalCode = ""
  dynamic var venueCountryCode = ""
  dynamic var latitude = 0.0
  dynamic var longitude = 0.0
  dynamic var distanceToVenue = 0.0
  dynamic var venueRating = 0.0
  dynamic var venueStatus = ""
  dynamic var featuredPhoto = ""
  
  dynamic var updatedAt = NSDate()

  override static func primaryKey() -> String? {
    return "venueId"
  }
  
  override static func ignoredProperties() -> [String] {
    return ["timestamp"]
  }
  
  let photos = List<PlacePhotosModel>()
  let tips = List<PlaceTipsModel>()
  
}

extension PlaceModel: MGLAnnotation {
  
  var title: String? {
    return venueName
  }
  
  var subtitle: String? {
    return venueAddress
  }
  
  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  
  var venueLocation: CLLocation {
    return  CLLocation(coordinate: coordinate, altitude: 0, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: updatedAt)
  }
  
}