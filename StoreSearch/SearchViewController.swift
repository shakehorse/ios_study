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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        performSearch() 
    }
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false //show the loading cell boolean
    var dataTask: NSURLSessionTask?

    struct TableViewCellIdentifiers{
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.becomeFirstResponder()
        
        tableView.rowHeight = 80
        
        // Do any additional setup after loading the view, typically from a nib.
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        
        //below 2 rows indicates load the nib and ask the tableview to register this nib for the reuse identifier "SearchResultCell"
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        //Nothing Found NIB
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        //Loading Cell NIB
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //search items
    func urlWithSearchText(searchText:String, category: Int) -> NSURL {
        
        let entityName: String
        switch category {
            case 1: entityName = "musicTrack"
            case 2: entityName = "software"
            case 3: entityName = "ebook"
            default: entityName = ""
        }
        
        let escapeSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapeSearchText, entityName)
        let url = NSURL(string: urlString)
        return url!
}


    func parseJSON(data:NSData) -> [String:AnyObject]? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        }catch{
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    

    func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult]{
        //1 make sure the dictionary has a key named results that contains an array
        guard let array = dictionary["results"] as? [AnyObject] else{
            print("Expected 'results' array")
            return []
        }
    
        var searchResults = [SearchResult]()
    
        //2 once its satisfied that array exists, the method uses a for-in loop to look at each of the array's elements in turn
        for resultDict in array {
            //3
            if let resultDict = resultDict as? [String: AnyObject]{
            
                var searchResult:SearchResult?
            //4
                if let wrapperType = resultDict["wrapperType"] as? String{
                
                switch wrapperType{
                    case "track": searchResult = parseTrack(resultDict)
                    case "audioBook": searchResult = parseAudioBook(resultDict)
                    case "software": searchResult = parseSoftware(resultDict)
                    default: break
                }
            }else if let kind = resultDict["kind"] as? String
                    where kind == "ebook"{     // ebook do not have a wrapperType field
                    searchResult = parseEBook(resultDict)
            }
            if let result = searchResult {
                searchResults.append(result)
            }
        }
    }
    return searchResults
}



func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    searchResult.currency = dictionary["currency"] as! String
    
    //only price is a number not a string
    if let price = dictionary["trackPrice"] as? Double {
        searchResult.price = price
    }
    if let genre = dictionary["primaryGenreName"] as? String {
        searchResult.genre = genre
    }
    
    return searchResult
}


/////////////////////////////////
/// 3 kinds of contents /////////
/////////////////////////////////


func parseAudioBook(dictionary:[String:AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    searchResult.name = dictionary["collectionName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["collectionViewUrl"] as! String
    searchResult.kind = "audiobook"
    searchResult.currency = dictionary["currency"] as! String
    if let price = dictionary["collectionPrice"] as? Double {
        searchResult.price = price
    }
    if let genre = dictionary["primaryGenreName"] as? String {
        searchResult.genre = genre
    }
    return searchResult
}

func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    searchResult.currency = dictionary["currency"] as! String
    if let price = dictionary["price"] as? Double {
        searchResult.price = price
    }
    if let genre = dictionary["primaryGenreName"] as? String {
        searchResult.genre = genre
    }
    return searchResult
}

func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    searchResult.currency = dictionary["currency"] as! String
    if let price = dictionary["price"] as? Double {
        searchResult.price = price
    }
    if let genres: AnyObject = dictionary["genres"] {
        searchResult.genre = (genres as! [String]).joinWithSeparator(", ")
    }
    return searchResult
}

    
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let detailViewController = segue.destinationViewController as! DetailViewController
            let indexPath = sender as! NSIndexPath
            let searchResult = searchResults[indexPath.row]
            detailViewController.searchResult = searchResult
        }
    }

func showNetworkError() {
    let alert = UIAlertController(
        title: "Whooops",
        message: "There was an error reading from the Itune Store, please try again!",
        preferredStyle: .Alert)
    
    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(action)
    
    presentViewController(alert, animated: true, completion: nil)
  }

}
//here } indicates the end of the class: SearchViewController:UIViewController

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch(){
            if !searchBar.text!.isEmpty{
            searchBar.resignFirstResponder()//hide keyboard after finishing searching
            
            dataTask?.cancel()
            isLoading = true //loading cell activiry indicator start animation
            tableView.reloadData()
            
            
            searchResults = [SearchResult]()
            hasSearched = true
            
      
            let url = urlWithSearchText(searchBar.text!, category: segmentedControl.selectedSegmentIndex)
                
            let session = NSURLSession.sharedSession()
                
            dataTask = session.dataTaskWithURL(url, completionHandler: {
                    data, response, error in
                    
                    if let error = error where error.code == -999{
                        return 
                    }else if let httpResponse = response as? NSHTTPURLResponse
                        where httpResponse.statusCode == 200{
                        //parse data
                        if let data = data, dictionary = self.parseJSON(data){
                            self.searchResults = self.parseDictionary(dictionary)
                            self.searchResults.sortInPlace(<)
                            
                            dispatch_async(dispatch_get_main_queue()){
                                self.isLoading = false
                                self.tableView.reloadData()
                                //print("on the main thread?" + (NSThread.currentThread().isMainThread ? "YES" : "No"))
                            }
                            return
                        }
                    }else {
                        print("Failure! \(response!)")
                    }
                dispatch_async(dispatch_get_main_queue()) {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
            })
            dataTask!.resume()
             }
            }
                
                
                
                /*let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                
            dispatch_async(queue){
                //code that needs to run in the background
                let url = self.urlWithSearchText(searchBar.text!)
                
                if let jsonString = self.performStoreRequestWithURL(url),
                   let dictionary = self.parseJSON(jsonString){
                    
                        self.searchResults = self.parseDictionary(dictionary)
                        self.searchResults.sortInPlace(<)
                       
                        dispatch_async(dispatch_get_main_queue()){
                            //update the UI
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                }
                
                dispatch_async(dispatch_get_main_queue()){
                    self.showNetworkError()
                    }
                }
            }
        }*/
            
        //remove the top white in status bar
        func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
            return .TopAttached
        }
}



    extension SearchViewController: UITableViewDataSource {
        
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if isLoading   {
                return 1
            }else if !hasSearched {
                return 0
            }else if searchResults.count == 0 {
                return 1
            }else{
            return searchResults.count 
            }
        }
        
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            if isLoading {
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
                let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                spinner.startAnimating()
                return cell
            }
            
            if searchResults.count == 0 {
                return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
                let searchResult = searchResults[indexPath.row]
                cell.configureForSearchResult(searchResult)
                return cell
            }
        }
        
        
}

    
    extension SearchViewController: UITableViewDelegate {
        
        //simply deselect the row with an animation
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            performSegueWithIdentifier("ShowDetail", sender: indexPath)
        }
        
        //you can only select row with actual search results
        func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
            if searchResults.count == 0 || isLoading {
                return nil
            }else {
                return indexPath
            }
        }
    }





