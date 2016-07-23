//
//  ViewController.swift
//  OMDBApp
//
//  Created by Lucas Da Silva on 2016-07-21.
//  Copyright (c) 2016 Lucas da Silva. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    let omdbAPI:OMDBApi = OMDBApi.sharedInstance
    let fontDefault:UIFont = UIFont.systemFontOfSize(14)
    var movie:Movie!
    var imdbIDToAdd:String? = nil
    
    var posterImageView: UIImageView!
    
    var titleLabel: UILabel!
    
    var runtimeLabel: UILabel!
    
    var yearLabel: UILabel!
    
    var plotLabel: UILabel!
    
    var contentScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(self.imdbIDToAdd != nil) {
            let _self = self
            self.performTaskWithLoading({() -> Void in
                self.omdbAPI.getMovieByImdbID(self.imdbIDToAdd!, onCompletion: {movie, error in
                    if movie != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.imdbIDToAdd = nil
                            self.movie = movie!
                            self.hideLoading()
                            self.setViews()
                        })
                    }
                })
            }, message:"Adding to collection...")
        }
        else if(movie != nil) {
            self.setViews()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setViews() {
        if(movie != nil) {
            let defaultMargin:CGFloat = 10
            //Titulo da view
            self.title = movie.title
            
            //Pega altura e largura da tela do dispositivo
            var screenWidth:CGFloat = self.view.frame.size.width
            var screenHeight:CGFloat = self.view.frame.size.height;
            
            let navigationBarHeight:CGFloat = self.navigationController!.navigationBar.frame.size.height
            
            contentScrollView = UIScrollView(frame: CGRectMake(0, navigationBarHeight + defaultMargin, screenWidth, screenHeight-navigationBarHeight))
            self.view.addSubview(contentScrollView)
            
            //Poster ImageView
            posterImageView = UIImageView(frame: CGRectMake(10, 20, 0.5*screenWidth, 1.3*0.5*screenWidth))
            contentScrollView.addSubview(posterImageView)
            if(movie.poster != nil) {
                posterImageView.image = UIImage(data: movie.poster!)
            }
            else {
                posterImageView.image = UIImage(named: "noimage")
            }
            
            //Title Label
            titleLabel = UILabel(frame: CGRectMake(posterImageView.frame.origin.x + posterImageView.frame.size.width+defaultMargin, posterImageView.frame.origin.y, posterImageView.frame.size.width-defaultMargin, self.heightForView(movie.title, font: fontDefault, width: posterImageView.frame.size.width-defaultMargin)))
            titleLabel.numberOfLines = 0
            titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            titleLabel.text = movie.title
            contentScrollView.addSubview(titleLabel)
            
            //Runtime Label
            runtimeLabel = UILabel(frame: CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + titleLabel.frame.size.height + defaultMargin, titleLabel.frame.size.width, 20))
            runtimeLabel.numberOfLines = 1
            runtimeLabel.font = fontDefault
            runtimeLabel.text = movie.runtime
            contentScrollView.addSubview(runtimeLabel)
            
            //Year Label
            yearLabel = UILabel(frame: CGRectMake(titleLabel.frame.origin.x, runtimeLabel.frame.origin.y + runtimeLabel.frame.size.height + defaultMargin, titleLabel.frame.size.width, 20))
            yearLabel.numberOfLines = 1
            yearLabel.font = fontDefault
            yearLabel.text = "Year: " + movie.year.stringValue
            contentScrollView.addSubview(yearLabel)
            
            //Plot Label
            plotLabel = UILabel(frame: CGRectMake(posterImageView.frame.origin.x, posterImageView.frame.origin.y + posterImageView.frame.height + defaultMargin, screenWidth - 2*defaultMargin, self.heightForView(movie.plot, font: fontDefault, width: screenWidth - 2*defaultMargin)))
            plotLabel.numberOfLines = 0
            plotLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            plotLabel.text = movie.plot
            contentScrollView.addSubview(plotLabel)
            
            contentScrollView.contentSize = CGSizeMake(screenWidth, plotLabel.frame.origin.y + plotLabel.frame.height + defaultMargin)
        }
    }
    
    //Retorna a altura
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
    
        label.sizeToFit()
        return 1.5*label.frame.height
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
        //super.navigationController!.popViewControllerAnimated(false)
    }
}

