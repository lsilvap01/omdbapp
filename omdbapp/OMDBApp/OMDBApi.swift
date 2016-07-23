//
//  OMDBApi.swift
//  OMDBApp
//
//  Created by Lucas Da Silva on 2016-07-21.
//  Copyright (c) 2016 Lucas da Silva. All rights reserved.
//

import Foundation
import UIKit

class OMDBApi {
    static let sharedInstance = OMDBApi()
    
    let baseURL = "http://www.omdbapi.com/?r=json&type=movie"
    
    func search(title:String, _page:Int, onCompletion:([SearchResult], Int, NSError?)->Void) {
        var page = _page
        if (page < 1) {
            page = 1
        }
        let escapedTitle:String = title.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
        let requestURL: NSURL = NSURL(string: String(format: "%@&s=%@&page=%i", arguments: [baseURL, escapedTitle, page]))!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            if(error == nil) {
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            var err: NSError? = error
            
            var movies: [SearchResult] = []
            var totalResults:Int = 0
            
            if (statusCode == 200) {
                if let json: AnyObject = NSJSONSerialization.JSONObjectWithData (data!, options:.AllowFragments, error:&err) {
                    if let arMovies = json["Search"] as? [[String: AnyObject]] {
                        if let total = json["totalResults"] as? String {
                            totalResults = total.toInt()!
                            for m in arMovies {
                                var movie = SearchResult()
                                if let title = m["Title"] as? String {
                                    movie.title = title
                                    if let year = m["Year"] as? String {
                                        movie.year = year.toInt()!
                                        if let imdbID = m["imdbID"] as? String {
                                            movie.imdbID = imdbID
                                            if let poster = m["Poster"] as? String {
                                                movie.posterURL = poster
                                                movies.append(movie)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            onCompletion(movies, totalResults, err);
            }
            else {
                onCompletion([], 0, error);
            }
        }
        task.resume()
    }
    
    
    func getMovieByImdbID(imdbID:String, onCompletion:(Movie?, NSError?)->Void) {
        let requestURL: NSURL = NSURL(string: baseURL + "&i=" + imdbID + "&plot=full")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            var err: NSError? = error
            
            var movie:Movie? = nil
            
            if (statusCode == 200) {
                if let json: AnyObject = NSJSONSerialization.JSONObjectWithData (data!, options:.AllowFragments, error:&err) {
                    if let jsonResponse = json["Response"] as? String {
                        if jsonResponse.lowercaseString == "true" {
                            if let title = json["Title"] as? String {
                            if let year = json["Year"] as? String {
                                var yearInt:NSNumber = 0
                                if (year != "N/A") {
                                    yearInt = year.toInt()!
                                }
                            if let rated = json["Rated"] as? String {
                            if let released = json["Released"] as? String {
                            if let released = json["Released"] as? String {
                            if let runtime = json["Runtime"] as? String {
                            if let genre = json["Genre"] as? String {
                            if let director = json["Director"] as? String {
                            if let writer = json["Writer"] as? String {
                            if let actors = json["Actors"] as? String {
                            if let plot = json["Plot"] as? String {
                            if let genre = json["Genre"] as? String {
                            if let language = json["Language"] as? String {
                            if let country = json["Country"] as? String {
                            if let awards = json["Awards"] as? String {
                            if let poster = json["Poster"] as? String {
                            if let metascore = json["Metascore"] as? String {
                                var metascoreInt:NSNumber = 0
                                if (metascore != "N/A") {
                                    metascoreInt = metascore.toInt()!
                                }
                            if let imdbRating = json["imdbRating"] as? String {
                                var imdbRatingFloat:NSNumber = 0
                                if (imdbRating != "N/A") {
                                    imdbRatingFloat = (imdbRating as NSString).floatValue
                                }
                            if let imdbVotes = json["imdbVotes"] as? String {
                                var imdbVotesInt:NSNumber = 0
                                if (imdbVotes != "N/A") {
                                    imdbVotesInt = imdbVotes.stringByReplacingOccurrencesOfString(",", withString: "").toInt()!
                                }
                                let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
                                
                                if let url = NSURL(string: poster) {
                                    let request = NSURLRequest(URL: url)
                                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                                        (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                                        if let imageData = data as NSData? {
                                            //Cadastra o filme com a imagem do poster
                                            movie = Movie.insertMovie(managedObjectContext!, imdbID: imdbID, title: title, plot: plot, runtime: runtime, genre: genre, director: director, writer: writer, actors: actors, year: yearInt, language: language, country: country, poster: imageData, imdbRating: imdbRatingFloat, imdbVotes: imdbVotesInt, metascore: metascoreInt)
                                        }
                                        else {
                                            //Cadastra o filme sem a imagem do poster
                                            movie = Movie.insertMovie(managedObjectContext!, imdbID: imdbID, title: title, plot: plot, runtime: runtime, genre: genre, director: director, writer: writer, actors: actors, year: yearInt, language: language, country: country, poster: nil, imdbRating: imdbRatingFloat, imdbVotes: imdbVotesInt, metascore: metascoreInt)
                                        }
                                        onCompletion(movie, err);
                                    }
                                }
                                else {
                                    //Cadastra o filme sem a imagem do poster
                                    movie = Movie.insertMovie(managedObjectContext!, imdbID: imdbID, title: title, plot: plot, runtime: runtime, genre: genre, director: director, writer: writer, actors: actors, year: yearInt, language: language, country: country, poster: nil, imdbRating: imdbRatingFloat, imdbVotes: imdbVotesInt, metascore: metascoreInt)
                                    onCompletion(movie, err);
                                }
                            }
                            }
                            }
                            }
                            }
                            }
                            }
                            }
                            }
                            }
                            }
                            }
                            }
                            }
                            }
                            }
                            }
                            }
                            }
                        }
                    }
                }
            }
            
            if movie == nil {
                onCompletion(nil, err);
            }
        }
        task.resume()
    }
}