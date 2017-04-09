//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FiltersViewControllerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var businesses: [Business]!
    var filteredData: [Business]!
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var offset = 0
    var categories: [String]?
    var filters = [String: AnyObject]()
    var searchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        // Dynamically set the row height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        // Create search bar in nav bar
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.searchBarStyle = .minimal
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .white
        
        // Put search bar in the title view
        navigationItem.titleView = searchBar
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        let radiusFilter = filters["radius_filter"] as? Int ?? 40000
        let dealsFilter = filters["deals_filter"] as? Bool ?? false
        let sortByFilter = filters["sort"] as? Int ?? 0
        
        self.searchText = self.searchText ?? "Food"
        
        Business.searchWithTerm(term: self.searchText!, distance: radiusFilter, sort: YelpSortMode(rawValue: sortByFilter), categories: self.categories, deals: dealsFilter, offset: 0, limit: 1000, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.filteredData = self.businesses
            self.tableView.reloadData()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
            
            }
        )
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.contentOffset.y = 0 - self.tableView.contentInset.top
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredData != nil {
            return filteredData.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        cell.business = filteredData[indexPath.row]
        return cell
    }
    
    // Search bar delegate methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.categories?.removeAll()
        let radiusFilter = filters["radius_filter"] as? Int ?? 40000
        let dealsFilter = filters["deals_filter"] as? Bool ?? false
        let sortByFilter = filters["sort"] as? Int ?? 0
        
        Business.searchWithTerm(term: searchText, distance: radiusFilter, sort: YelpSortMode(rawValue: sortByFilter), categories: self.categories, deals: dealsFilter, offset: 0, limit: 1000, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.searchText = searchText
            self.businesses = businesses
            self.filteredData = self.businesses
            self.tableView.reloadData()
        }
        )

    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    // Scroll delegate methods
    func loadMoreData() {
        
        self.offset = self.offset + 20
        let radiusFilter = filters["radius_filter"] as? Int ?? 40000
        let dealsFilter = filters["deals_filter"] as? Bool ?? false
        let sortByFilter = filters["sort"] as? Int ?? 0
        
        self.searchText = self.searchText ?? "Food"

        Business.searchWithTerm(term: self.searchText!, distance: radiusFilter, sort: YelpSortMode(rawValue: sortByFilter), categories: self.categories, deals: dealsFilter, offset: self.offset, limit: 1000, completion: { (businesses: [Business]?, error: Error?) -> Void in
        
            if (businesses != nil) {
                for business in businesses! {
                    self.businesses.append(business)
                }
                self.filteredData = self.businesses
            }
            
            // Update flag
            self.isMoreDataLoading = false
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
            self.tableView.reloadData()
        })
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadMoreData()
            }
        }
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mapView" {
            _ = segue.destination as! MapViewController
            let backItem = UIBarButtonItem()
            backItem.title = "List"
            navigationItem.backBarButtonItem = backItem
            //mapVC.businesses = businesses
        } else {
            let navigationController = segue.destination as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            
            filtersViewController.delegate = self
        }
        
     
    }
 
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        
        self.categories?.removeAll()
        categories = filters["categories"] as? [String] ?? nil
        let radiusFilter = filters["radius_filter"] as? Int ?? 40000
        let dealsFilter = filters["deals_filter"] as? Bool ?? false
        let sortByFilter = filters["sort"] as? Int ?? 0
    
        Business.searchWithTerm(term: "Food", distance: radiusFilter, sort: YelpSortMode(rawValue: sortByFilter), categories: categories, deals: dealsFilter, offset: 20, limit: 1000, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            if (businesses != nil && (businesses?.count)! > 0) {
                self.businesses?.removeAll()
                for business in businesses! {
                    self.businesses.append(business)
                }
                for biz in self.businesses {
                    print("biz \(biz.name)")
                }
                self.filteredData = self.businesses
                // TODO: Add animation here
                self.tableView.reloadData()

            } else {
                let alert = UIAlertController(title: "Search results", message: "We're sorry, there are no results matching your search at this time.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                print("No matches for \(self.categories)")
                self.categories?.removeAll()
            }
            
            self.filters["radius_filter"] = radiusFilter as AnyObject?
            self.filters["deals_filter"] = dealsFilter as AnyObject?
            self.filters["sort"] = sortByFilter as AnyObject?
        })
    }
}

