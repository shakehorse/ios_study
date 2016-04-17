//
//  ViewController.swift
//  StoreSearch
//
//  Created by Jun YAO on 16/4/15.
//  Copyright © 2016年 Jun YAO. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [SearchResult]()
    
    var hasSearched = false

    struct TableViewCellIdentifiers{
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80
        
        // Do any additional setup after loading the view, typically from a nib.
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        //below 2 rows indicates load the nib and ask the tableview to register this nib for the reuse identifier "SearchResultCell"
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

    //add delegate code into an extension
    extension SearchViewController: UISearchBarDelegate{
        
        
        func searchBarSearchButtonClicked(searchBar: UISearchBar) { //searchBar is actully the input string
            searchBar.resignFirstResponder()//hide keyboard after finishing searching
            searchResults = [SearchResult]()
            hasSearched = true
            
            if searchBar.text! != "justin bieber" {
            for i in 0...2 {
                let searchResult = SearchResult() //let searchResut = one instance of SearchResult class
                searchResult.name = String(format: "Fake Result %d for", i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)  //searchResults is a array, this line means add the current instance into this array
            }
            tableView.reloadData()
            }
        }
        
        //remove the top white in status bar
        func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
            return .TopAttached
        }
    }



    extension SearchViewController: UITableViewDataSource {
        
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if !hasSearched {
                return 0
            }else if searchResults.count == 0 {
                return 1
            }else{
            return searchResults.count
            }
        }
        
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            if searchResults.count == 0 {
                return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
                let searchResult = searchResults[indexPath.row]
                cell.nameLabel!.text = searchResult.name
                cell.artistNameLabel!.text = searchResult.artistName
                return cell
            }
            
        }
}

    
    extension SearchViewController: UITableViewDelegate {
        
        //simply deselect the row with an animation
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        //you can only select row with actual search results
        func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
            if searchResults.count == 0 {
                return nil
            }else {
                return indexPath
            }
        }
    }





