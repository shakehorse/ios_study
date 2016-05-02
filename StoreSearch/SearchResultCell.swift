//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Jun YAO on 16/4/17.
//  Copyright © 2016年 Jun YAO. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    var downloadTask: NSURLSessionDownloadTask?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
        
        nameLabel.text = nil
        artistNameLabel.text = nil
        artworkImageView.image = nil
    }
    
    
    func configureForSearchResult(searchResult: SearchResult){
        nameLabel.text = searchResult.name  
        
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = "Unknown"
        }else {
            artistNameLabel.text = String(format: "%@(%@)", searchResult.artistName, searchResult.kindForDisplay())
        }
        
        artworkImageView.image = UIImage(named: "Placeholder")
        if let url = NSURL(string: searchResult.artworkURL60){
            downloadTask = artworkImageView.loadImageWithURL(url)
        }
    }
    

    
}