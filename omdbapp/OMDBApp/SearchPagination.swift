//
//  SearchPagination.swift
//  OMDBApp
//
//  Created by Lucas Da Silva on 2016-07-21.
//  Copyright (c) 2016 Lucas da Silva. All rights reserved.
//

import Foundation

class SearchPagination {
    private let omdbAPI:OMDBApi = OMDBApi.sharedInstance
    private var keyword:String = ""
    private var results:[SearchResult] = []
    private var totalResults:Int = 0
    private var currentPage:Int = 0
    private var searching:Bool = false
    
    init(keyword:String) {
        self.keyword = keyword
    }
    
    func getKeyword() -> String {
        return self.keyword
    }
    
    func getResults() -> [SearchResult] {
        return self.results
    }
    
    func getTotalResults() -> Int {
        return self.totalResults
    }
    
    func fecthNextPage(onCompletion:(NSError?) -> Void) {
        if(!searching && (totalResults == 0 || (currentPage*10) < totalResults)) {
            searching = true
            omdbAPI.search(self.keyword, _page: self.currentPage + 1, onCompletion: {movies, total, error in
                self.searching = false
                if error == nil {
                    self.results += movies
                    self.totalResults = total
                    self.currentPage++
                }
            
                onCompletion(error)
            })
        }
    }
}