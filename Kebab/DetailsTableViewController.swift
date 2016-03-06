//
//  DetailTableViewController.swift
//  Kebab
//
//  Created by Sasha Minikin on 12/8/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import UIKit
import AVFoundation

import PSOperations
import RealmSwift
import Kingfisher
import GSMessages
import Mapbox

// I can't find better solution :(
public var publicVenueId = ""

protocol VeneuModelDelegate {
  var vanueIdTest : String { get }
}

class DetailsTableViewController: StaticDataTableViewController {
  
  var queue = OperationQueue()
  let realm = try! Realm()
  
  var venueModel : PlaceModel?
  var venuePhotos = [PlacePhotosModel]()
  var venueTips = [PlaceTipsModel]()
  
  //DATA for GeoCoding
  var venueNewStreet = ""
  var venueNewCity  = ""
  var venueNewState  = ""
  var venueNewZip  = ""
  var venueLatitude = 0.0
  var venueLongitude = 0.0
//  let geoCoder = KebabGeoCoder()
  
  @IBOutlet weak var photosCollection: UICollectionView!
  @IBOutlet weak var tipsCollectionView: UICollectionView!
  @IBOutlet weak var photosCell: PhotosTableViewCell!
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var tipsTVCell: UITableViewCell!
  @IBOutlet weak var msgTVCell: UITableViewCell!
  @IBOutlet weak var venueRating: FloatRatingView!
  @IBOutlet weak var venueName: UILabel!
  @IBOutlet weak var venueAddress: UILabel!
  @IBOutlet weak var venueOpen: UILabel!
  @IBOutlet weak var venueTipsCount: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()

      // Set image for navigation bar
      
      navigationItem.titleView = UIImageView(image: UIImage(named: "kebab"))
      
      // Hide header and footer sections and adjust insets for table separator
      
      tableView.tableHeaderView = UIView(frame: CGRectMake(0.0, 0.0, tableView.bounds.size.width, 0.01))
      tableView.tableFooterView = UIView(frame: CGRectMake(0.0, 0.0, tableView.bounds.size.width, 0.01))
      photosCell.separatorInset = UIEdgeInsetsZero
      photosCell.layoutMargins = UIEdgeInsetsZero
      tableView.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0)
      tableView.estimatedRowHeight = 68.0
      tableView.rowHeight = UITableViewAutomaticDimension
      
      // Set layout for tips collection view
      
      tipsCollectionView.delegate = nil
      tipsCollectionView.dataSource = nil
      
      tipsCollectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 5)
      let nibHeader = UINib(nibName: "TipsHeaderView", bundle: nil)
      tipsCollectionView.registerNib(nibHeader, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "tipsHeaderView")
      
      // Custom CollectionVieLayout for TipsCollectionView
      self.tipsCollectionView.delegate = self
      self.tipsCollectionView.dataSource = self
      
      let tipLayout = tipsCollectionView.collectionViewLayout as! TipsLayout
      tipLayout.delegate = self
      tipLayout.numberOfColumns = 2
      tipLayout.cellPadding = 5

      // PhotosCollectionView set-up
      
      photosCollection.delegate = self
      photosCollection.dataSource = self
   
      let layout = photosCollection.collectionViewLayout as! UICollectionViewFlowLayout
      layout.itemSize = CGSize(width: CGRectGetWidth(photosCollection!.bounds), height: 250)
      
      // WARNING: - DO NOT DELETE THIS!
      
      self.tableView.setNeedsLayout()
      self.tableView.layoutIfNeeded()
      
      // Show tips cell and hide short tips discription cell
      
      insertTableViewRowAnimation = .Right
      deleteTableViewRowAnimation = .Left
      cell(msgTVCell, setHidden: true)
      reloadDataAnimated(false)
      
      // Get notification when button pressed to hide tips
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideTipsCollection", name:Notifications.hideTipsCollectionViewNotification, object: nil)
      
      // Get notification if geocoder can't build route
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector:"routeAlert", name: Notifications.kebabGeoCoderCantParseData, object: nil)
    
      // Set model data
      
      setUpVenueModel()
      
      // Get photos & tips for selected venue
      
      getPhotosAndTips()
      
    }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(false)
    
    // Remove from all notifications being observed
    
    NSNotificationCenter.defaultCenter().removeObserver(self)
    
    //Cancel all operations
    
    queue.cancelAllOperations()
  }
  
  // Set venue model
  func setUpVenueModel() {
    
    // Default all labels if there's no venueModel.
    
    guard let venueModel = venueModel else {
      venueRating.rating = 0.0
      venueName.text = "Unnamed"
      venueAddress.text = "Address is unknown"
      venueOpen.text = "🤖"
      venueTipsCount.text =  "No tips"
      
      return
    }
    
    venueRating.rating = Float(venueModel.venueRating) / 2
    venueName.text = venueModel.venueName
    venueAddress.text = venueModel.venueAddress
    venueOpen.text = venueModel.venueStatus
    venueTipsCount.text = "Tips"
    
    venueNewStreet = venueModel.venueAddress
    venueNewCity  = venueModel.venueCity
    venueNewState  = venueModel.venueState
    venueNewZip  = venueModel.venuePostalCode
    
    venueLatitude = venueModel.latitude
    venueLongitude = venueModel.longitude
    
    publicVenueId = venueModel.venueId
    print("venueId :", publicVenueId)
    
  }
  

  // Download data from the internet, save to Realm, from Realm and update UI.
  
   func getPhotosAndTips() {
    
      let getPhotosOperation = GetPhotosOperation(realm: realm) {
        
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
        
        dispatch_after(when, dispatch_get_main_queue()) {
          
          self.venuePhotos = (self.realm.objectForPrimaryKey(PlaceModel.self, key: publicVenueId)?.photos.sort {
            $0.photoId < $1.photoId
          })!
          
          // Set pageControl number of pages
          
          self.pageControl.numberOfPages = self.venuePhotos.count

          // Reload photo collectionView
          
          self.photosCollection.reloadData()
        }

      }
    
    let getTipsOperation = GetTipsOperation(realm: realm) {
      
      dispatch_async(dispatch_get_main_queue()) {
        
        self.venueTips = (self.realm.objectForPrimaryKey(PlaceModel.self, key: publicVenueId)?.tips.sort {
          $0.userId < $1.userId
        })!
        
        // Reload tips collectionView
        
        self.tipsCollectionView.reloadData()

        // Reload custom layout
        
          self.tipsCollectionView.performBatchUpdates({
            
            self.tipsCollectionView.collectionViewLayout.prepareLayout()
        
          }){ completed in
            print("Bactch update finished : tipsCollectionView.contentSize.height:", self.tipsCollectionView.contentSize.height)
        }
      }
    }
    
    queue.addOperations([getPhotosOperation, getTipsOperation], waitUntilFinished:false)

  }

  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    
    let pageWidth = CGRectGetWidth(scrollView.bounds)
    let pageFraction = scrollView.contentOffset.x / pageWidth
    pageControl.currentPage = Int(round(pageFraction))
    
  }
  
  @IBAction func pageChanged(sender: AnyObject) {
    
    let layout = photosCollection.collectionViewLayout as! UICollectionViewFlowLayout
    layout.itemSize = CGSize(width: CGRectGetWidth(photosCollection!.bounds), height: 250)
    
    let currentPage = sender.currentPage
    let pageWidth = layout.itemSize.width
    let targetContentOffsetX = CGFloat(currentPage) * pageWidth
    
    UIView.animateWithDuration(0.35, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.photosCollection.contentOffset.x = targetContentOffsetX
      }, completion: nil)
  }
  
  // Hide tips (TipsCollectionView in TableViewCell) and show "Suumary: 99 Tips" TableViewCell
  
  func hideTipsCollection () {
    
    cell(msgTVCell, setHidden: true)
    cell(tipsTVCell, setHidden: false)
  
    reloadDataAnimated(true)
  }

  // Display TableViewCell with CollectionView Tips
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let cellIndex = tableView.indexPathForSelectedRow

    if cellIndex?.row == 4 && venueTips.count != 0 {
    
      cell(msgTVCell, setHidden: false)
      cell(tipsTVCell, setHidden: true)
      
      // Set collectionView contens size
      
      cell(msgTVCell, setHeight:(tipsCollectionView.contentSize.height + 20))
      
      // StaticTableView
      reloadDataAnimated(true)
      
      // Scroll to cell to top
      
      tableView.scrollToRowAtIndexPath(cellIndex!, atScrollPosition:.Top, animated: true)

    } else if cellIndex?.row == 2 {
      
      let veneuLocation = CLLocation(latitude: venueLatitude, longitude: venueLongitude)
      
      let buildRouteOperation = KebabGeoCoder(location: veneuLocation)
      queue.addOperation(buildRouteOperation)
      
    } else if cellIndex?.row == 4 && queue.operations.count == 2 {
      
      loadingData()
      
    } else if cellIndex?.row == 4 && venueTips.count == 0 && queue.operations.count == 0 {
      noTipsForTheVenue()
    }
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
  }
  

  // Show alert message when we can't build the route to the venus
  
  func routeAlert() {
    
    tableView.showMessage("Sorry, we can't build route to the venue.",
                        type: .Error  ,
                        options: [.Animation(.Slide),
                                  .AnimationDuration(0.3),
                                  .AutoHide(true),
                                  .AutoHideDelay(5.0),
                                  .Height(44.0),
                                  .Position(.Top),
                                  .TextColor(UIColor.blackColor())])
  }
  
  func noTipsForTheVenue() {
    
    tableView.showMessage("Sorry, no tips for the venue.",
                          type: .Warning ,
                          options: [.Animation(.Slide),
                                    .AnimationDuration(0.3),
                                    .AutoHide(true),
                                    .AutoHideDelay(5.0),
                                    .Height(44.0),
                                    .Position(.Top),
                                    .TextColor(UIColor.blackColor())])
  }
  
  func loadingData() {
    
    tableView.showMessage("Please wait, loading data...",
                          type: .Info,
                          options: [.Animation(.Slide),
                                    .AnimationDuration(0.3),
                                    .AutoHide(true),
                                    .AutoHideDelay(4.0),
                                    .Height(44.0),
                                    .Position(.Top),
                                    .TextColor(UIColor.blackColor())])
  }
  

}


extension DetailsTableViewController : UICollectionViewDataSource, UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
  
     // When venues is nil, this will return 0 (nil-coalescing operator ??)
    
    if collectionView == photosCollection {
      return venuePhotos.count ?? 0
    } else  {
      return venueTips.count ?? 0
    }
    
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    
    if collectionView == photosCollection {
      
      let photo = venuePhotos[indexPath.row]
      
      let cell = photosCollection.dequeueReusableCellWithReuseIdentifier("photosCVCell", forIndexPath: indexPath) as! PhotosCollectionViewCell
      
      cell.progressView.progress = 0
  
      guard let imgUrl = NSURL(string: photo.photoString) else {
        KebabError.NoPhotoUrl
        return cell
      }
    
      cell.venueImage.kf_setImageWithURL(imgUrl,
                                        placeholderImage: UIImage(contentsOfFile: "noImage"),
                                        optionsInfo: [.Transition(ImageTransition.Fade(0.5))], progressBlock: { (receivedSize, totalSize) -> () in
        
                                          
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        cell.progressView.hidden = false
        cell.progressView.progress = Float( Double(receivedSize) / Double(totalSize))
        
        }, completionHandler: { (_, error, _, _) -> () in
          cell.progressView.hidden = true
          UIApplication.sharedApplication().networkActivityIndicatorVisible = false
          if error != nil {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            print("PRINT ERROR:", error)
          }
      })
      
      return cell
    
    } else if collectionView == tipsCollectionView {
      
        let tips = venueTips[indexPath.row]
        let cell = tipsCollectionView.dequeueReusableCellWithReuseIdentifier("tipsCVCell", forIndexPath: indexPath) as! TipsCollectionViewCell
      
        cell.tipsLabel.text = tips.text
        cell.userName.text = tips.userFirstName + " " + tips.userLastName
      
        return cell
      
    } else {

      let cell = UICollectionViewCell()
      return cell
    }
    
  }
  
  func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    
    let cell = photosCollection.dequeueReusableCellWithReuseIdentifier("photosCVCell", forIndexPath: indexPath) as! PhotosCollectionViewCell
    
    // This will cancel all unfinished downloading task when the cell disappearing.
    cell.venueImage.kf_cancelDownloadTask()
  }
  
  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

      let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "tipsHeaderView", forIndexPath: indexPath) as! TipsHeaderView
      
      return headerView
  }
}

extension DetailsTableViewController : TipsLayoutDelegate {
  
  // Returns the tip height
  
  func collectionView(collectionView: UICollectionView, heightForCommentAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {

    let tips = venueTips[indexPath.row]
    let font = UIFont(name: "SanFranciscoDisplay-Light", size: 16)!
    let commentHeight = tips.heightForTips(font, width: width) + 20

    return commentHeight
  }
  
  // Returns the annotation size based on the text
  
  func collectionView(collectionView: UICollectionView, heightForAnnotationtAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
    return 40
  }
  
}