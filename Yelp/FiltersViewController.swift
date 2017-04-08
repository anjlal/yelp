//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Angie Lal on 4/5/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

enum FilterRowIdentifier : String {
    case Deals = "Deals"
    case Distance = "Distance"
    case Sort = "Sort"
    case Category = "Category"
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var distanceExpanded = false
    var sortByExpanded = false
    var categoryExapanded = false
    
    var sort = [YelpSortMode]()
    var distance = [[String:String]]()
    var categories: [[String:String]]!
    var currentDistance = "Auto"
    var currentDistanceValue = -1
    var currentSort : YelpSortMode = .bestMatched
    
    weak var delegate: FiltersViewControllerDelegate?
    var switchStates = [IndexPath:Bool]()
    let tableStructure: [[FilterRowIdentifier]] = [[.Deals], [.Distance], [.Sort], [.Category]]

    var filterValues = [FilterRowIdentifier: AnyObject] ()
    var currentFilters: Filters! {
        didSet {
            filterValues[.Deals] = currentFilters.deals as AnyObject?
            filterValues[.Distance] = currentFilters.distance as AnyObject?
            filterValues[.Sort] = currentFilters.sort as AnyObject?
            filterValues[.Category] = currentFilters.categories as AnyObject?
            
            tableView?.reloadData()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        // Do any additional setup after loading the view.
        
        // TODO: this should be done in initializer
        categories = Filters.yelpCategories()
        distance = Filters.yelpDistance()
        sort = Filters.yelpSort()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearchButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        var filters = [String: AnyObject]()
        var selectedCategories = [String]()
        var deal = false
        
        for (indexPath, isSelected) in switchStates {
            if isSelected {
                if indexPath.section == 0 {
                    deal = true
                }
                if indexPath.section == 3 {
                    selectedCategories.append(categories[indexPath.row]["code"]!)
                }
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject?
        }
        if currentDistanceValue > 0 {
            filters["radius_filter"] = currentDistanceValue as AnyObject?
        }
        
        filters["deals_filter"] = deal as AnyObject?
        filters["sort"] = currentSort.rawValue as AnyObject?

        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructure.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title: String
        
        let filterType = tableStructure[section][0].rawValue
        switch(filterType) {
            case "Deals":
                title = ""
            case "Distance":
                title = filterType
                break
            case "Sort":
                title = "Sort by"
                break
            default:
                title = "Category"
        }
        
        return title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            print("distance \(distance.count)")

            return distance.count
        case 2:
            print("sort \(sort.count)")

            return sort.count
            
        default:
            print("categories \(categories.count)")

            return categories.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
         cell.delegate = self
        let filterIdentifier = tableStructure[indexPath.section][0]
        //cell.filterRowIdentifier = filterIdentifier
        switch (filterIdentifier) {
            case .Deals:
                cell.switchLabel.text = "Offering a Deal"
                cell.onSwitch.isOn = switchStates[indexPath] ?? false
                cell.onSwitch.isHidden = false
                break
            case .Distance:
//                if (!distanceExpanded) {
//                    
//                    cell.checkLabel.text = currentDistance
//                    cell.checkImage.image = #imageLiteral(resourceName: "ExpandArrow")
//                } else {
//                    
//                    cell.checkLabel.text = distanceArray[indexPath.row]["distance"]
//                    if currentDistance == distanceArray[indexPath.row]["distance"] {
//                        
//                        cell.checkImage.image = #imageLiteral(resourceName: "Checked")
//                    } else {
//                        
//                        cell.checkImage.image = #imageLiteral(resourceName: "NotChecked")
//                    }
//                }
                cell.switchLabel.text = distance[indexPath.row]["distance"]
                break
            case .Sort:
                switch(sort[indexPath.row]) {
                case .bestMatched:
                    cell.switchLabel.text = "Best Matched"
                    break
                case .distance:
                    cell.switchLabel.text = "Distance"
                    break
                default:
                    cell.switchLabel.text = "Highest Rated"
                }
            default:
                cell.switchLabel.text = categories[indexPath.row]["name"]
                cell.onSwitch.isOn = switchStates[indexPath] ?? false
        }
      
       
        return cell
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        
        switchStates[indexPath] = value

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
