//
//  ArticlesImageDownloader.swift
//  Home24
//
//  Created by Erick Martins on 25/06/18.
//  Copyright © 2018 Lyelo. All rights reserved.
//

import Foundation
import Kingfisher

class ArticlesImageDownloader{
    
    public static var shared = ArticlesImageDownloader()
    
    private var articles: [Article] = [];
    private let concurrentDownloads = 8;
    private var latestIndex = 0;
    private var downloadedItems = 0;
    private var downloadingNow:[RetrieveImageDownloadTask] = []
    
    public var delegate:ArticlesImagesDownloadProtocol?
    
    public var downloaded: Int {
        get {
            return downloadedItems;
        }
    }
    
    public static func download(these articles: [Article]) -> ArticlesImageDownloader{
        let instance = ArticlesImageDownloader.shared;
        instance.download(these: articles)
        return instance
    }
    
    
    
    private func addToQueue(article: Article){
        let task = ImageDownloader.default.downloadImage(
            with: article.media![0].uri!,
            options: [],
            progressBlock: nil) { (image, error, url, data) in
                self.downloadedItems += 1
                if let error = error {
                    if let delegate = self.delegate {
                        delegate.articlesImageDownloaderErrorGetting(article: article, error: error, url: url, data:data, dowloader: self)
                    }
                }else{
                    ImageCache.default.store(image!, forKey: "article_image_\(article.sku!)")
                    if let delegate = self.delegate {
                        delegate.articlesImageDownloaderDoneGetting(article: article, image: image!, dowloader: self)
                    }
                }
                self.updateDownloadQueue()
        }
        
        downloadingNow.append(task!)
    }
    
    public func checkForCachedImage(from article: Article){
        ImageCache.default.retrieveImage(forKey: "article_image_\(article.sku!)", options: nil) {
            image, cacheType in
            if let image = image {
                print("Get image \(image), cacheType: \(cacheType).")
                self.downloadedItems += 1
                if let delegate = self.delegate {
                    delegate.articlesImageDownloaderDoneGetting(article: article, image: image, dowloader: self)
                }
                self.updateDownloadQueue()
                //In this code snippet, the `cacheType` is .disk
            } else {
                self.addToQueue(article: article)
                print("Not exist in cache.")
            }
        }
    }
    
    
    private func updateDownloadQueue(){
        
        if articles.count == downloaded {
            if let delegate = self.delegate {
                delegate.articlesImageDownloaderDoneGettingAll(articles: articles, dowloader: self)
            }
            return
        }
        let count = concurrentDownloads - (downloadingNow.count - downloadedItems)
        if count > 0 {
            let finalIndex = min(latestIndex + count, articles.count)
            while(latestIndex < finalIndex){
                let article = articles[latestIndex]
                checkForCachedImage(from: article)
                latestIndex += 1
            }
        }
    }
    
    public func download(these articles: [Article]){
        self.articles = articles
        print("Starting downloads")
        self.updateDownloadQueue()
    }
    
    
}

/**
 Articles Image Downloader Protocol
 */
protocol ArticlesImagesDownloadProtocol {
    func articlesImageDownloaderErrorGetting(article: Article, error: NSError, url:URL?, data:Data?, dowloader: ArticlesImageDownloader) -> Void
    func articlesImageDownloaderDoneGetting(article: Article, image: Image, dowloader: ArticlesImageDownloader) -> Void
    func articlesImageDownloaderDoneGettingAll(articles: [Article], dowloader: ArticlesImageDownloader) -> Void
}










