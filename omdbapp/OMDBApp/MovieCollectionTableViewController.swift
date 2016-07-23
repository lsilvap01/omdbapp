//
//  MovieCollectionTableViewController.swift
//  OMDBApp
//
//  Created by Lucas Da Silva on 2016-07-22.
//  Copyright (c) 2016 Lucas da Silva. All rights reserved.
//

import UIKit

class MovieCollectionTableViewController: UITableViewController {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var movies:[Movie] = []
    var selectedMovie:Movie? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Movie Collection"
    }
    
    override func viewDidAppear(animated: Bool) {
        self.reloadData()
    }
    
    func reloadData() {
        selectedMovie = nil
        movies = Movie.getAllMovies(managedObjectContext!)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return movies.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("collectionMovieCell", forIndexPath: indexPath) as! UITableViewCell
        let movie:Movie = movies[indexPath.row]
        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = movie.year.stringValue
        if(movie.poster == nil) {
            cell.imageView?.image = UIImage(named: "noimage")
        }
        else {
            //Se o filme possuir poster, carrega a imagem de forma assincrona
            cell.imageView?.image = UIImage(data: movie.poster!)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedMovie = movies[indexPath.row]
        self.performSegueWithIdentifier("collectionDetailSegue", sender: self)
    }
    

    // MARK: - Navigation
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if (identifier == "collectionDetailSegue") {
            return self.selectedMovie != nil
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "collectionDetailSegue") {
            var detailVC = segue.destinationViewController as! DetailViewController;
            detailVC.movie = self.selectedMovie
            self.selectedMovie = nil
        }
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }


    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            let movie = movies[indexPath.row]
            Movie.deleteMovie(managedObjectContext!, movie: movie)
            movies.removeAtIndex(indexPath.row)
            // Remove linha da tabela
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            //self.reloadData()
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
