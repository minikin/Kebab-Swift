//
//  CategoriesTableViewController.swift
//  Kebab
//
//  Created by Sasha Minikin on 12/6/15.
//  Copyright © 2015 Minikin. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {
  
  @IBOutlet var categoriesTableView: UITableView!
  
  @IBOutlet weak var junkCellOne: UITableViewCell!
  @IBOutlet weak var junkCellTwo: UITableViewCell!
  @IBOutlet weak var junkCellThree: UITableViewCell!
  @IBOutlet weak var junkCellFour: UITableViewCell!
  @IBOutlet weak var junkCellFive: UITableViewCell!
  @IBOutlet weak var junkCellSix: UITableViewCell!
  @IBOutlet weak var junkCellSeven: UITableViewCell!
  @IBOutlet weak var junkCellEight: UITableViewCell!
  @IBOutlet weak var junkCellNine: UITableViewCell!
  @IBOutlet weak var junkCellTen: UITableViewCell!
  
  
  // Create view to draw the line bellow navigation bar
  var lineView: UIView = UIView(frame: CGRectMake(0,0,0,0))

    override func viewDidLoad() {
        super.viewDidLoad()
      
      navigationItem.titleView = UIImageView(image: UIImage(named: "kebab"))
      
      tableView.backgroundColor = Theme.Background.mainColor
      tableView.separatorColor = Theme.Lines.mainColor
      tableView.sectionHeaderHeight = 40
      tableView.sectionFooterHeight = 20
      self.clearsSelectionOnViewWillAppear = true

      // Set cells title and image
      
      setCellsStyle()
    }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section:Int) {
    
    let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
    
    header.textLabel!.textColor = Theme.Text.mainColor
    header.textLabel!.font = Theme.HelpText.textStyle
    
  }
  
  override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
    let footer:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
    
    footer.textLabel!.textColor = Theme.Text.mainColor
    footer.textLabel!.font = Theme.HelpText.textStyle
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    /*
    Even though each cell is designed initially in the storyboard, I can still implementtable - cellForRowAtIndexPath: 
    to call super and then add further functionality. 
    That’s how I’ll add the checkmarks. The user defaults are storing the current choice categories.
    there’s a "Junkfood categories" preference consisting of a string denoting the title of the chosen cell:
    */
    
    
    let cell =  super.tableView(categoriesTableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
    
    // Set
    cell.accessoryType = .None
    cell.backgroundColor = Theme.Background.mainColor
    cell.textLabel?.font = Theme.RegularText.textStyle
    cell.textLabel?.textColor  = Theme.Text.mainColor
    
    
    let ud = NSUserDefaults.standardUserDefaults()
    if ud.valueForKey("Junkfood categories") as? String == cell.textLabel?.text {
      cell.accessoryType = .Checkmark
    }
    
    return cell
  }
  
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    /*
    
    When the user taps a cell, the cell is selected. I want the user to see that selection mo‐ mentarily, as feedback, 
    but then I want to deselect, adjusting the checkmarks so that that cell is the only one checked in its section. 
    In tableView:didSelectRowAtIndex- Path:, 
    I set the user defaults, and then I reload the table view’s data. 
    This removes the selection and causes tableView:cellForRowAtIndexPath: to be called to adjust the checkmarks:
    
    */
    
    let ud = NSUserDefaults.standardUserDefaults()
    let settings = categoriesTableView.cellForRowAtIndexPath(indexPath)!.textLabel!.text
    let header = self.tableView(categoriesTableView, titleForHeaderInSection:indexPath.section)
    
    ud.setValue(settings, forKey: header!)
    
    categoriesTableView.reloadData()
  }
  
  
  func setCellsStyle(){
    
    junkCellOne.imageView?.image = UIImage(named: "kebab_icn")
    junkCellTwo.imageView?.image = UIImage(named: "burgers_icn")
    junkCellThree.imageView?.image = UIImage(named: "chips_icn")
    junkCellFour.imageView?.image = UIImage(named: "pizza_icn")
    junkCellFive.imageView?.image = UIImage(named: "chicken_icn")
    junkCellSix.imageView?.image = UIImage(named: "pies_icn")
    junkCellSeven.imageView?.image = UIImage(named: "sandwiches_icn")
    junkCellEight.imageView?.image = UIImage(named: "sushi_icn")
    junkCellNine.imageView?.image = UIImage(named: "rolls_icn")
    junkCellTen.imageView?.image = UIImage(named: "coffee_icn")
    
    junkCellOne.textLabel?.text = JunkFoodType.Kebab.rawValue
    junkCellTwo.textLabel?.text = JunkFoodType.Burger.rawValue
    junkCellThree.textLabel?.text = JunkFoodType.Chips.rawValue
    junkCellFour.textLabel?.text = JunkFoodType.Pizza.rawValue
    junkCellFive.textLabel?.text = JunkFoodType.Chicken.rawValue
    junkCellSix.textLabel?.text = JunkFoodType.Pies.rawValue
    junkCellSeven.textLabel?.text = JunkFoodType.Sandwiches.rawValue
    junkCellEight.textLabel?.text = JunkFoodType.Sushi.rawValue
    junkCellNine.textLabel?.text = JunkFoodType.Rolls.rawValue
    junkCellTen.textLabel?.text = JunkFoodType.Coffee.rawValue

  }
  
  override func viewWillAppear(animated: Bool) {
    
    //Add line below navigationbar
    if let navigationController = self.navigationController {
      let navigationBar = navigationController.navigationBar
      let navBorder: UIView = UIView(frame: CGRectMake(0, navigationBar.frame.size.height - 1, navigationBar.frame.size.width, 1))
      // Set the color you want here
      navBorder.backgroundColor = Theme.Lines.mainColor
      navBorder.opaque = true
      lineView = navBorder
      self.navigationController?.navigationBar.addSubview(lineView)
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    // Remove line when we moving to another viewController
    lineView.removeFromSuperview()
  }
}