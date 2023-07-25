//
//  VideoPreview.swift
//  YoutubeAPI
//
//  Created by Zach Mommaerts on 7/25/23.
//

import Foundation
import Alamofire

class VideoPreview: ObservableObject {
    
    @Published var thumbnailData = Data()
    @Published var title: String
    @Published var date: String
    
    var video: Video
    
    init(video: Video) {
        
        // Set the video and Title
        self.video = video
        self.title = video.title
        
        // Set the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        self.date = dateFormatter.string(from: video.published)
        
        // Download the image data
        guard video.thumbnail != "" else { return }
        
        // Check cache before downloading data
        if let cachedData = CacheManager.getVideoCache(video.thumbnail) {
            // Set the thumbnail data
            thumbnailData = cachedData
            return
        }
        
        // Get a url from the thumbnail
        guard let url = URL(string: video.thumbnail) else { return }
        
        // Create the request
        AF.request(url).validate().responseData { response in
            
            if let data = response.data {
                // Save the data in the cache
                CacheManager.setVideoCache(video.thumbnail, data)
                
                // Set the image
                DispatchQueue.main.async {
                    self.thumbnailData = data
                }
            }
        }
    }
}
