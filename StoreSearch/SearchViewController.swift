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
        
        searchBar.becomeFirstResponder()
        
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

    //search items
    func urlWithSearchText(searchText:String) -> NSURL {
        let escapeSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", escapeSearchText)
        let url = NSURL(string: urlString)
        return url!
}

    //call to String(contentsofURL, encoding) that returns a new string object with the data it receives from the server at other end of the URL
    func performStoreRequestWithURL(url:NSURL) -> String?{
        do{
            return try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        }catch{
            print("Download Error: \(error)")
            return nil
        }
    }


func parseJSON(jsonString:String) -> [String:AnyObject]? {
    guard let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        else {
            return nil
    }
    do{
        return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
    }catch {
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


//*********************************//

    //add delegate code into an extension
    extension SearchViewController: UISearchBarDelegate{
        
        
        func searchBarSearchButtonClicked(searchBar: UISearchBar) { //searchBar is actully the input string
            if !searchBar.text!.isEmpty{
            searchBar.resignFirstResponder()//hide keyboard after finishing searching
            
            searchResults = [SearchResult]()
            hasSearched = true
                
            let url = urlWithSearchText(searchBar.text!)
            //print("URL:'\(url)'")
                
                if let jsonString = performStoreRequestWithURL(url){
                    if let dictionary = parseJSON(jsonString){
                        print("Dictionary \(dictionary)")
                        
                        searchResults = parseDictionary(dictionary)
                        //parseDictionary(dictionary)
                        
                        //sorting the searching result
                        searchResults.sortInPlace(<)
                        //searchResults.sortInPlace({result1, result2 in
                        //    return result1.name.localizedStandardCompare(result2.name) == .OrderedAscending
                        //searchResults.sortInPlace { &0.name.localizedStandardCompare($1.name) == .OrderedAscending }
                        //})
                        
                        tableView.reloadData()
                        return
                    }
                }
            
           // showNetworkError()
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
                //cell.artistNameLabel!.text = searchResult.artistName
                if searchResult.artistName.isEmpty {
                    cell.artistNameLabel.text = "Unknown"
                }else{
                    cell.artistNameLabel.text = String(format: "%@(%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
                }
                return cell
            }
        }
        
        
        func kindForDisplay(kind:String) -> String {
            switch kind{
            case "album": return "Album"
            case "audiobook": return "Audio Book"
            case "book": return "Book"
            case "ebook": return "E-Book"
            case "feature-movie": return "Movie"
            case "music-video": return "Music Video"
            case "podcast": return "Podcast"
            case "software": return "App"
            case "song": return "Song"
            case "tv-episode": return "TV Episode"
            default: return kind
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





