//
//  Movie.swift
//  OMDBApp
//
//  Created by Lucas Da Silva on 2016-07-22.
//  Copyright (c) 2016 Lucas da Silva. All rights reserved.
//

import Foundation
import CoreData

class Movie: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var plot: String
    @NSManaged var runtime: String
    @NSManaged var genre: String
    @NSManaged var director: String
    @NSManaged var writer: String
    @NSManaged var actors: String
    @NSManaged var year: NSNumber
    @NSManaged var language: String
    @NSManaged var country: String
    @NSManaged var awards: String
    @NSManaged var imdbID: String
    @NSManaged var poster: NSData?
    @NSManaged var imdbRating: NSNumber
    @NSManaged var metascore: NSNumber
    @NSManaged var imdbVotes: NSNumber
    
    //Insere o filme no banco de dados caso ainda não tenha sido cadastrado
    static func insertMovie(managedObjectContext:NSManagedObjectContext, imdbID:String, title:String, plot:String, runtime:String, genre:String, director:String, writer:String, actors:String, year:NSNumber, language:String, country:String, poster:NSData?, imdbRating:NSNumber, imdbVotes:NSNumber, metascore:NSNumber) -> Movie {
        //Verifica se o filme já foi cadastrado
        var movie:Movie? = getMovieByImdbID(managedObjectContext, imdbID: imdbID)
        
        //Se não tiver sido cadastrado, insere um novo com os parametros passados
        if movie == nil {
            let newMovie = NSEntityDescription.insertNewObjectForEntityForName("Movie", inManagedObjectContext: managedObjectContext) as! Movie
            newMovie.imdbID = imdbID
            newMovie.title = title
            newMovie.plot = plot
            newMovie.runtime = runtime
            newMovie.genre = genre
            newMovie.director = director
            newMovie.writer = writer
            newMovie.actors = actors
            newMovie.year = year
            newMovie.language = language
            newMovie.country = country
            if(poster != nil) {
                newMovie.poster = poster!
            }
            newMovie.imdbRating = imdbRating
            newMovie.imdbVotes = imdbVotes
            newMovie.metascore = metascore
            managedObjectContext.save(nil)
            //retorna novo filme
            return newMovie
            
        }
        
        //retorna filme que já estava cadastrado
        return movie!
    }
    
    //Retorna o filme com o imdbID igual ao passado como parametro
    static func getMovieByImdbID(managedObjectContext:NSManagedObjectContext, imdbID:String) -> Movie? {
        let query = NSFetchRequest(entityName: "Movie")
        
        // busca pelo filme com imdbID igual ao passado como parametro
        let predicate = NSPredicate(format: "imdbID == %@", imdbID)
        query.predicate = predicate
        
        if let results = managedObjectContext.executeFetchRequest(query, error: nil) as? [Movie] {
            if results.count > 0 {
                return results[0]
            }
        }
        
        return nil
    }
    
    //Retorna todos os filmes cadastrados
    static func getAllMovies(managedObjectContext:NSManagedObjectContext) -> [Movie] {
        let query = NSFetchRequest(entityName: "Movie")
        //Ordena pelo titulo de forma crescente
        let sortByName = NSSortDescriptor(key: "title", ascending: true)
        query.sortDescriptors = [sortByName]
        
        if let movies = managedObjectContext.executeFetchRequest(query, error: nil) as? [Movie] {
            return movies
        }
        
        return []
    }
    
    static func deleteMovie(managedObjectContext:NSManagedObjectContext, movie:Movie) {
        managedObjectContext.deleteObject(movie)
        managedObjectContext.save(nil)
    }
}
