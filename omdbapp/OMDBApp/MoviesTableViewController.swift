//
//  MoviesTableViewController.swift
//  OMDBApp
//
//  Created by Lucas Da Silva on 2016-07-21.
//  Copyright (c) 2016 Lucas da Silva. All rights reserved.
//

import UIKit

class MoviesTableViewController: UITableViewController, UISearchBarDelegate {
    var moviesSearch:SearchPagination?
    var selectedImdbID:String?
    
    @IBOutlet weak var searchField: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search"
        searchField.delegate = self
        searchField.showsCancelButton = true
    }
    
    override func viewWillAppear(animated: Bool) {
        selectedImdbID = nil
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //Fecha o teclado
        self.view.endEditing(true)
        //Se for a primeira busca ou uma keyword diferente, cria um novo objeto SearchPagination
        if(moviesSearch == nil || moviesSearch?.getKeyword() != searchField.text) {
            moviesSearch = SearchPagination(keyword: searchField.text)
            //realiza a busca
            self.performTaskWithLoading({() -> Void in
                moviesSearch?.fecthNextPage({error in
                if error == nil {
                    self.hideLoading()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
                else {
                    self.hideLoading()
                    
                    var alertController = UIAlertController(title: "Something went wrong", message: error!.localizedDescription, preferredStyle: .Alert)
                    var okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
                        UIAlertAction in
                        
                    }
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                })}, message:"Searching...")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if(moviesSearch != nil) {
            return moviesSearch!.getResults().count
        }
        else {
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("movieIdentifier", forIndexPath: indexPath) as! UITableViewCell
        let movie:SearchResult = moviesSearch!.getResults()[indexPath.row]
        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = movie.year.stringValue
        cell.imageView?.image = UIImage(named: "noimage")
        if(movie.posterURL != "N/A") {
            //Se o filme possuir poster, carrega a imagem de forma assincrona
            cell.imageView?.imageFromUrl(movie.posterURL)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //Se o ultimo filme carregado estiver para ser mostrado na tela, carrega a próxima página de resultados (se houver)
        if(indexPath.row == moviesSearch!.getResults().count-1) {
            moviesSearch!.fecthNextPage({error in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
                else {
                    print(error)
                }
            })
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedImdbID = self.moviesSearch!.getResults()[indexPath.row].imdbID
        self.performSegueWithIdentifier("detailsSegue", sender: self)
    }
    
    // MARK: - Navigation
    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool {
        if(identifier == "detailsSegue") {
            return self.selectedImdbID != nil
        }
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "detailsSegue") {
            var detailVC = segue.destinationViewController as! DetailViewController
            detailVC.imdbIDToAdd = self.selectedImdbID
        }
    }
    
    func performTaskWithLoading(task:()->Void, message:String) {
        //Cria uma view de loading
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        alert.view.tintColor = UIColor.blackColor()
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        self.presentViewController(alert, animated: true, completion: task)
    }
    
    func hideLoading() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if let imageData = data as NSData? {
                    self.image = UIImage(data: imageData)
                    self.contentMode = UIViewContentMode.ScaleToFill
                }
            }
        }
    }
}
