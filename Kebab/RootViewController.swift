//
//  RootViewController.swift
//  Kebab
//
//  Created by Sasha Prokhorenko on 9/24/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import UIKit
import CoreLocation

import PSOperations
import Mapbox
import RealmSwift
import Kingfisher
import GSMessages


class RootViewController: UIViewController {
  
  /// Outlet for the collectionView (bottom)
  @IBOutlet weak var venueCollectionView: UICollectionView!
  
  /// Outlet for the map view
  @IBOutlet weak var mapView: MGLMapView!
  
  // MARK: Properties
  
  /// Operation queue
  let operationQueue = OperationQueue()
  
  /// stopUpdateLocation BOOL
  var stopUpdateLocation = false
  
  /// Convenient property to remember the last location
  var lastLocation: MGLUserLocation?
  
  /// Location manager to get the user's location
  var locationManager:CLLocationManager?

  // Realm properties
  
  let realm = try! Realm()
  var venuesArray = [PlaceModel]()
  var notificationToken: NotificationToken?

  // NSUserDefaults
  
  let defaults = NSUserDefaults.standardUserDefaults()
  
  var userLocation : CLLocation?

  var annotationImage : MGLAnnotationImage?

  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      // Set Mapbox
      
      mapView.styleURL = NSURL(string: "mapbox://styles/mapbox/dark-v8")
      mapView.delegate = self
      mapView.showsUserLocation = true
      mapView.userTrackingMode = .FollowWithHeading
      mapView.attributionButton.hidden = true
      annotationImage = self.mapView.dequeueReusableAnnotationImageWithIdentifier("nonSelectedImage")
    
      // Set collectionView delegate & datasource
      
      self.venueCollectionView.delegate = self
      self.venueCollectionView.dataSource = self
      self.venueCollectionView.backgroundColor = UIColor.clearColor()
      
      // Set navigation bar style
      
      setNavigationBarStyle()
      
      // Realm instances send out notifications to other instances on other threads every time a write transaction is committed.
      
      notificationToken = realm.addNotificationBlock { notification, realm in
        // RELOAD ALL THE DATA!
        self.venueCollectionView.reloadData()
      }
 
    
      // Observer : NSUserDefaultsDidChangeNotification
      
      NSNotificationCenter.defaultCenter().addObserverForName(NSUserDefaultsDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()){ _ in
        self.refreshVenues(self.userLocation)
      }
      
      /*
        We can use a `KebabLocationOperation` to retrieve the user's current location.
        Once we have the location, we can compute how far they currently are
        from the epicenter of the earthquake.
        
        If this operation fails (ie, we are denied access to their location),
        then the text in the `UILabel` will remain as what it is defined to
        be in the storyboard.
      */
      
      let locationOperation = KebabLocationOperation(accuracy: kCLLocationAccuracyKilometer) { location in
   
        self.userLocation = location
        
        if self.userLocation != nil {
              self.refreshVenues(self.userLocation)
            } else {
              self.locationError()
          }
      }
      
      let networkObserver = NetworkObserver()
      locationOperation.addObserver(networkObserver)
      
      operationQueue.addOperation(locationOperation)
    }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(false)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector:"loadingDataMsg", name: Notifications.kebabGetPlaceOperationStarted, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector:"locatingUser", name: Notifications.kebabDidStartLocatingUser, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector:"locationError", name: Notifications.kebabDidFinishLocatingUserWithError, object:nil)
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewDidAppear(false)
    
    // Remove realm notification notification
    realm.removeNotification(notificationToken!)
  }
  
  // Populate view with data
  
  private func refreshVenues(location: CLLocation?) {

    // If location isn't nil, set it as the last location else show error message to user
    
    if location != nil {
      
      userLocation = location
      
    } else {
      
      return locationError()
    }
    
    // If the last location isn't nil, i.e. if a lastLocation was set OR parameter location wasn't nil
    
    guard let location = userLocation else { return }
    
    let venueCategory = defaults.stringForKey("Junkfood categories")!
    let searchRadius = defaults.stringForKey("Search radius")!

    print(venueCategory, searchRadius)
    
    /*
      Algorithm for offsetting a latitude/longitude by some amount of meters
      http://gis.stackexchange.com/questions/2951/algorithm-for-offsetting-a-latitude-longitude-by-some-amount-of-meters
    */
    
    let dLat = ((Double(searchRadius)! / Utils.earthRadius ) * 180.0/M_PI ).roundToPlaces(4)
    let dLon = ((Double(searchRadius)! / (Utils.earthRadius * cos(M_PI * location.coordinate.latitude/180.0))) * 180.0/M_PI).roundToPlaces(4)
    
    // Set up predicate that ensures the fetched venues are within the region
    
    let predicate = NSPredicate(format:"latitude > %f AND latitude < %f AND longitude > %f AND longitude < %f AND venueCategory == %@",
      location.coordinate.latitude - dLat,
      location.coordinate.latitude + dLat,
      location.coordinate.longitude - dLon,
      location.coordinate.longitude + dLon,
      venueCategory)
    
    
    // Download data from the internet and save to Realm.
    // Please, check GetPlaces.swift, ParsePlace.swift, DownloadPlaces.swift
  
    let getPlaceOperation = GetPlacesOperation (location: userLocation!) {
            dispatch_async(dispatch_get_main_queue()) {
              // Get the venues from Realm. Note that the "sort" isn't part of Realm, it's Swift, and it defeats Realm's lazy loading nature!
      
              self.venuesArray = self.realm.objects(PlaceModel).filter(predicate).sort{
                $0.venueRating > $1.venueRating
              }
              
              self.updateUI()
          }
    }
    
    operationQueue.addOperation(getPlaceOperation)    
  }
  
  /// Updtae UI
  
  func updateUI() {
    
    if venuesArray.count == 0 {
      
      removeAllAnnotations()
      
      venueCollectionView.reloadData()
      
      self.showMessage("Sorry, we can't find any venues.",
                      type: .Warning  ,
                      options: [.Animation(.Fade),
                        .AnimationDuration(0.3),
                        .AutoHide(true),
                        .AutoHideDelay(8.0),
                        .Height(44.0),
                        .Position(.Top),
                        .TextColor(UIColor.blackColor())])

    } else {
      removeAllAnnotations()
      venueCollectionView.reloadData()
      mapView.addAnnotations(venuesArray)
      zoomToFitAllAnnotation()
      self.hideMessage()
    }
  }
  
  /// Remove all annotation from mapView (MapBox)
  
  func removeAllAnnotations() {
    
    guard let annotations = mapView.annotations else { return }
    
    if annotations.count != 0 {
      for annotation in annotations {
        mapView.removeAnnotation(annotation)
      }
    } else {
      return
    }
  }
  
  
  /// Zoom out mapView to fit all annotations on screen
  
  func zoomToFitAllAnnotation() {
    
    if mapView.annotations != nil {
      
      let annotations =  mapView.annotations!
      
      guard annotations.count > 1 else { return }
      
      let firstCoordinate = mapView.annotations![0].coordinate
      
      //Find the southwest and northeast point
      
      var northEastLatitude = firstCoordinate.latitude
      var northEastLongitude = firstCoordinate.longitude
      var southWestLatitude = firstCoordinate.latitude
      var southWestLongitude = firstCoordinate.longitude
      
      //
      
      for annotation in mapView.annotations!{
        let coordinate = annotation.coordinate
        
        northEastLatitude = max(northEastLatitude, coordinate.latitude)
        northEastLongitude = max(northEastLongitude, coordinate.longitude)
        southWestLatitude = min(southWestLatitude, coordinate.latitude)
        southWestLongitude = min(southWestLongitude, coordinate.longitude)
        
      }
      
      let verticalMarginInPixels = 80.0
      let horizontalMarginInPixels = 40.0
      
      let verticalMarginPercentage = verticalMarginInPixels/Double(self.view.bounds.size.height)
      let horizontalMarginPercentage = horizontalMarginInPixels/Double(self.view.bounds.size.width)
      
      let verticalMargin = (northEastLatitude-southWestLatitude)*verticalMarginPercentage
      let horizontalMargin = (northEastLongitude-southWestLongitude)*horizontalMarginPercentage
      
      southWestLatitude -= verticalMargin
      southWestLongitude -= horizontalMargin
      
      northEastLatitude += verticalMargin
      northEastLongitude += horizontalMargin
      
      if (southWestLatitude < -85.0) {
        southWestLatitude = -85.0
      }
      if (southWestLongitude < -180.0) {
        southWestLongitude = -180.0
      }
      if (northEastLatitude > 85) {
        northEastLatitude = 85.0
      }
      if (northEastLongitude > 180.0) {
        northEastLongitude = 180.0
      }
      
      // Final step
      
      let rectToDisplay = MGLCoordinateBounds(sw: CLLocationCoordinate2DMake(southWestLatitude, southWestLongitude), ne: CLLocationCoordinate2DMake(northEastLatitude, northEastLongitude))
      mapView.setVisibleCoordinateBounds(rectToDisplay, edgePadding: UIEdgeInsetsMake(0, 0, 140, 0), animated: true)
      
    } else if mapView.annotations?.count <= 2 {
    
      mapView.setCenterCoordinate(CLLocationCoordinate2DMake((lastLocation?.coordinate.latitude)!, (lastLocation?.coordinate.longitude)!), zoomLevel: 15, animated: true)
      
    } else {
      print("No annotations yet")
    }
    
  }
  
  // Get new data and zoom to fit all annotations
  
  @IBAction func centerOnUser(sender: AnyObject) {
    
    // When a new location update comes in, reload from Realm and from Foursquare

    if userLocation != nil {
      refreshVenues(userLocation)
    } else {
      locationError()
    }
    
  }
  
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
    guard let indexPaths = venueCollectionView.indexPathsForSelectedItems(),
      detailVC = segue.destinationViewController as? DetailsTableViewController else {
        return
    }
    // Send data to Deatails View Controller
    detailVC.venueModel = venuesArray[indexPaths[0].row]
    detailVC.queue = operationQueue
  }
  
  
  // Style for navigationBar
  
  func setNavigationBarStyle() {
    
    // Set navigation bar title, back button image and navigation bar appareance
    
    navigationController!.navigationBar.barTintColor = UIColor(red: 0.13, green:0.13, blue: 0.13, alpha: 1.0)
    navigationController!.navigationBar.tintColor = .whiteColor()
    navigationItem.titleView = UIImageView(image: UIImage(named: "kebab"))
    navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    let backItem = UIBarButtonItem(title: "", style:.Plain, target: nil, action: nil)
    navigationItem.backBarButtonItem = backItem
    navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Back")
    navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Back")
  }
  
  
  // MARK: -  Error & Info messages
  
  
  // Display location error
  
  func locationError() {
          switch CLLocationManager.authorizationStatus() {
          case .Denied:
            showNoPermissionsAlert()
          case .Restricted:
            showNoPermissionsAlert()
          default:
            self.showMessage("Sorry, we can't determine your location.",
              type: .Error,
              options: [.Animation(.Slide),
                .AnimationDuration(0.3),
                .AutoHide(true),
                .AutoHideDelay(10.0),
                .Height(44.0),
                .Position(.Top),
                .TextColor(UIColor.blackColor())])
        }
  }
  
  // Hide loading data message after operation is finished
  
  func hideMsg() {
    self.hideMessage()
  }
  
  // ShowNoPermissionsAlert
  
  func showNoPermissionsAlert() {
  
  let alertController = UIAlertController(title: "Sorry, we can't determine your location.", message: "Please, enable location updates in settings and restart the app.", preferredStyle: .Alert)
  let openSettings = UIAlertAction(title: "Open settings", style: .Default, handler: { (action) -> Void in
    let URL = NSURL(string: UIApplicationOpenSettingsURLString)
    
    defer {
      dispatch_async( dispatch_get_main_queue(),{
         UIApplication.sharedApplication().openURL(URL!)
      })
    }
  })
    
  let okAction = UIAlertAction(title: "Cancel", style: .Default, handler: {
      (action) -> Void in
      self.dismissViewControllerAnimated(true, completion: nil)
    })
    
  alertController.addAction(okAction)
  alertController.addAction(openSettings)
  presentViewController(alertController, animated: true, completion: nil)
}

  func loadingDataMsg() {
    
    self.showMessage("Loading data ...",
                    type: .Info,
                    options: [.Animation(.Fade),
                              .AnimationDuration(0.3),
                              .Height(44.0),
                              .AutoHide(false),
                              .Position(.Top),
                              .TextColor(UIColor.blackColor())])
  }
  
  
  func locatingUser() {
    
    self.showMessage("Determining your location ...",
                    type: .Info,
                    options: [.Animation(.Fade),
                      .AnimationDuration(0.3),
                      .Height(44.0),
                      .AutoHide(false),
                      .Position(.Top),
                      .TextColor(UIColor.blackColor())])
  }
  
  
}

  // MARK: -  MGLMapViewDelegate

extension RootViewController: MGLMapViewDelegate {
  
  // Load data after we get user location
  
  func mapView(mapView: MGLMapView, didUpdateUserLocation userLocation: MGLUserLocation?) {
    
    if stopUpdateLocation {
      return
    }

    stopUpdateLocation = true
    lastLocation = userLocation
  }
  
  // Set custom image for imageForAnnotation
  
  func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
    
    // Attempt to reuse a cached image

  
    if annotationImage == nil {
      
      let image = UIImage(named: "Pin")
      
      // Instantiate MGLAnnotationImage with our image and use it for this annotation
    
      annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: "nonSelectedImage")
    }
    
    return annotationImage
  }
  
  func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
    
    
    if let title = annotation.title where title == "Some Annotation" {
      annotationImage!.image = UIImage(named: "selectedPin")!
    }
    
    
  }
  
  // Show callout
  
  func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }
  
  func mapView(mapView: MGLMapView, didFailToLocateUserWithError error: NSError) {
   locationError()
  }
  
  // In case we can't load a mapView show an error
  
  func mapViewDidFailLoadingMap(mapView: MGLMapView, withError error: NSError) {
    
    self.showMessage("Sorry, we can't load map. Check you internet connection.",
                      type: .Error,
                      options: [.Animation(.Slide),
                        .AnimationDuration(0.3),
                        .AutoHide(true),
                        .AutoHideDelay(5.0),
                        .Height(88.0),
                        .Position(.Top),
                        .TextNumberOfLines(2),
                        .TextColor(UIColor.blackColor())])
  }
  
}

  // MARK: - UICollectionViewDataSource &  UICollectionViewDelegate

extension RootViewController : UICollectionViewDataSource, UICollectionViewDelegate {
  
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
      return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
      // When venues is nil, this will return 0 (nil-coalescing operator ??)
      return venuesArray.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("venueCell", forIndexPath: indexPath) as! PlaceCollectionViewCell
      
      // Make Venue picture round and add border
      
      cell.venueImage.layer.cornerRadius = cell.venueImage.frame.size.width / 2
      cell.venueImage.clipsToBounds = true
      cell.venueImage.layer.borderWidth = 2
      cell.venueImage.layer.borderColor = Theme.ImageHelper.mainColor.CGColor
  
      // Set data for cell
      
      let venue = venuesArray[indexPath.row]
      
      cell.venueName.text = venue.venueName
      cell.venueAddress.text = venue.venueAddress
        
      // Setting cell image with Kingfisher
      
      guard let imgUrl = NSURL(string: venue.featuredPhoto) else {
        KebabError.NoPhotoUrl
        return cell
      }
      
      cell.venueImage.kf_showIndicatorWhenLoading = true
      cell.venueImage.kf_indicator?.color = Theme.ImageHelper.mainColor
      cell.venueImage.kf_setImageWithURL(imgUrl,
                                        placeholderImage: UIImage(contentsOfFile: "noImage"),
                                        optionsInfo: [.Transition(ImageTransition.Fade(0.5))])
                                        { (_, error, _, imageURL) in
                                          if error != nil {
                                            print("PRINT ERROR:", error)
                                        }
                                        
      }
      
      return cell
    }
  
  func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("venueCell", forIndexPath: indexPath) as! PlaceCollectionViewCell
  
    // This will cancel all unfinished downloading task when the cell disappearing.
    cell.venueImage.kf_cancelDownloadTask()
  }
  

  // TODO: - ADD ERROR CONDITIONS OR NOT
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    /*
    Instead of performing the segue directly, we can wrap it in a `BlockOperation`.
    This allows us to attach conditions to the operation. For example, you
    could make it so that you could only perform the segue if the network
    is reachable and you have access to the user's Photos library.
    
    If you decide to use this pattern in your apps, choose conditions that
    are sensible and do not place onerous requirements on the user.
    
    It's also worth noting that the Observer attached to the `BlockOperation`
    will cause the tableview row to be deselected automatically if the
    `Operation` fails.
    
    You may choose to add your own observer to introspect the errors reported
    as the operation finishes. Doing so would allow you to present a message
    to the user about why you were unable to perform the requested action.
    */
    
    let operation = BlockOperation {
      self.performSegueWithIdentifier("showVenue", sender: nil)
    }
    
    operation.addCondition(MutuallyExclusive<UIViewController>())
    
    let blockObserver = BlockObserver { _, errors in
      
      /*
      If the operation errored (ex: a condition failed) then the segue
      isn't going to happen. We shouldn't leave the row selected.
      */
      
      if !errors.isEmpty  {
        dispatch_async(dispatch_get_main_queue()) {
          self.venueCollectionView.deselectItemAtIndexPath(indexPath, animated: true)
        }
      }
    }
    
    operation.addObserver(blockObserver)
    operationQueue.addOperation(operation)
  }
  
  
  // MARK: - Show callout on map
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    
    // This works especially well when each item in your collection view takes up the whole screen.
    
    let visibleRect = CGRect(origin:venueCollectionView.contentOffset, size:venueCollectionView.bounds.size)
    let visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect))
    guard let visibileIndexPath = venueCollectionView.indexPathForItemAtPoint(visiblePoint) else { return print("No cells to display")}
    
    let selectedCell = venueCollectionView.cellForItemAtIndexPath(visibileIndexPath) as!  PlaceCollectionViewCell

    
    if self.mapView.annotations!.count > 0 {
      let cellTitle = selectedCell.venueName.text
      for annotation in self.mapView.annotations! {
        let annotationTitle = annotation.title!
        if cellTitle == annotationTitle {
          self.mapView.selectAnnotation(annotation, animated: true)
        }
      }
      
    } else {
      return
    }
    
  }

}