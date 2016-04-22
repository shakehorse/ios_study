//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Jun YAO on 16/4/21.
//  Copyright © 2016年 Jun YAO. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImageWithURL(url: NSURL) -> NSURLSessionDownloadTask{
        
        let session = NSURLSession.sharedSession()
        //1
        let downloadTask = session.downloadTaskWithURL(url, completionHandler:
            {[weak self] url, response, error in //'self' refers UIImageView
                //2 given a URL where find the download file (local)
                if error == nil,
                    //3 with local url, load the file into an NSData object, and then make a image from that NSData object
                    let url = url,let data = NSData(contentsOfURL: url), let image = UIImage(data: data)
                {
                    dispatch_async(dispatch_get_main_queue())
                    {
                        if let strongSelf = self
                        {
                            strongSelf.image = image
                        }
                    }
                }
            })
        //after creating the download task, we call resume() to start it, then return the NSURLSessionDownloadTask object to the caller. return gives the app oppotunity to call cancel() on the download task
        downloadTask.resume()
        return downloadTask
    }
}
