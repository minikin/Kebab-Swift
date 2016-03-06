//
//  Constants.swift
//  Kebab
//
//  Created by Sasha Prokhorenko  on 9/21/15.
//  Copyright © 2015 Minikin. All rights reserved.
//


// MARK: - Notifications constants

enum Notifications {
  
  static let kebabFailedtoParseJSON = "me.minikin.kebab.failed.to.parse.json"
  static let hideTipsCollectionViewNotification = "kebab.ocklock.hide.tips.collection.view."
  
  static let kebabGeoCoderCantParseData = "me.minikin.kebab.geo.coder.cant.parse.data"
  
  static let kebabGetPlaceOperationStarted = "me.minikin.kebab.get.place.data.started"
  static let kebabGetPlaceOperationFinished = "me.minikin.kebab.get.place.data.finished"
  
  static let kebabFailToConnectToTheInternet = "me.minikin.kebab.fail.to.connect.to.the.internet"
  
  static let kebabDidStartLocatingUser = "me.minikin.kebab.did.start.locating.user"
  static let kebabDidFinishLocatingUser = "me.minikin.kebab.did.finish.locating.user"
  static let kebabDidFinishLocatingUserWithError = "me.minikin.kebab.did.finish.with.error.locating.user"
}

// MARK: - Properties

enum Utils {
  
  // Used in predicate in RootViewController
  
  static let earthRadius = 6378137.0
  
  // In case we can't get a correct img url we use this one. Check ParsePhotoOperation & ParsePlaceOperation for details.
  
  static  let flickrPhotoUrl = "https://c2.staticflickr.com/2/1509/24246343163_50164b3e0f_o.png"
}

// MARK: - Foursquare data

enum FoursquareData : String {
  
  // FIXME:- PUT YOUR CLINET ID & SECRET HERE!
  case clientId = "Your client Id"
  case clientSecret = "Your client secret"
  
  case baseFoursquareUrl = "https://api.foursquare.com/v2/venues/"
  case version = "20150920"
  case limitSearch = "50"
  case limitPhotos = "5"
  case limitTips = "10"
  
}

// MARK: - Junkfood categories

enum JunkFoodType: String {
  case Kebab
  case Burger
  case Chips
  case Pizza
  case Chicken
  case Pies
  case Sandwiches
  case Sushi
  case Rolls
  case Coffee
}

// MARK: - Search radius

enum SearchRadius : String {
  case one = "1500"
  case two = "1000"
  case three = "700"
  case four = "500"
  case five = "200"
}

// MARK: - Photo sizes

enum PhotoSize : String {
  case small = "36x36"
  case medium = "200x200"
  case large = "500x500"
}

// MARK: - KebabError Type

enum KebabError : ErrorType {
  case NoPhotoUrl
}
