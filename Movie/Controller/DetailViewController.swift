//
//  DetailViewController.swift
//  Movie
//
//  Created by Idris on 13/09/19.
//  Copyright © 2019 Idris-labs. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

class DetailViewController: UIViewController {
    @IBOutlet weak var detailRating: UILabel!
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var detailOverview: UITextView!
    @IBOutlet weak var detailTitle: UILabel!
    var movieID:String?
    var category:String?
    let api = API()
    var blurView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let anyMovieId = movieID,let anyCategory = category{
            blurView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            blurView.backgroundColor = UIColor(white: 1, alpha: 1)
            view.addSubview(blurView)
            getDataById(movieID: anyMovieId,category: anyCategory)
            
        }
    }
    
    func getDataById(movieID:String,category:String){
        SVProgressHUD.show()
        Alamofire.request(api.API_URL+"\(category)/\(movieID)?api_key=\(api.API_KEY)&language=en-US").responseJSON { (res) in
            if res.result.isSuccess{
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    let items = res.result.value as! [String:Any]
                    let stringImage = items["poster_path"] as! String
                    if let dataImage = try? Data(contentsOf:NSURL(string: "http://image.tmdb.org/t/p/w500"+stringImage)! as URL){
                        self.detailOverview.text = items["overview"] as? String
                        self.detailImage.image = UIImage(data: dataImage)!
                        self.detailTitle.text = items["original_title"] as? String
                        self.blurView.isHidden = true
                    }
                }
            }
        }
    }
}
