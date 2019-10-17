//
//  TvShowsViewController.swift
//  Movie
//
//  Created by Idris on 12/09/19.
//  Copyright © 2019 Idris-labs. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class TvShowsViewController: UIViewController {
    @IBOutlet weak var tvShowCollectionView: UICollectionView!
    let api = API()
    var selectedSegmentIndex = 0
    var listDataTvShows:[MovieModel] = []
    var rowSelected:MovieModel?
    var tvShowID:String?
    let tvShowRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSelectedDataTvShow(selected: selectedSegmentIndex)
        tvShowCollectionView.delegate = self
        tvShowCollectionView.dataSource = self
        tvShowRefreshControl.addTarget(self, action: #selector(refreshMovie), for: .valueChanged)
        tvShowCollectionView.addSubview(tvShowRefreshControl)
    }
    
    @objc func refreshMovie(){
        DispatchQueue.main.async {
            self.getSelectedDataTvShow(selected: self.selectedSegmentIndex)
            self.tvShowRefreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getSelectedDataTvShow(selected: selectedSegmentIndex)
    }
    
    func getSelectedDataTvShow(selected:Int){
        switch selectedSegmentIndex {
        case 0:
            getDataTvShows(category: "airing_today")
        case 1:
            getDataTvShows(category: "popular")
        default:
            getDataTvShows(category: "airing_today")
        }
    }
    
    func getDataTvShows(category:String){
        SVProgressHUD.show()
        Alamofire.request(api.API_URL+"tv/\(category)?api_key=\(api.API_KEY)&language=en-US&page=1").responseJSON { (response) in
            if response.result.isSuccess{
                let jsonDictionary = response.result.value as! [String:Any]
                let listMovie = jsonDictionary["results"] as! [[String:Any]]
//                print(listMovie)
                if listMovie.count > 0{
                    self.listDataTvShows = []
                    for item in listMovie{
                        let stringImage = item["poster_path"] as! String
                        let movieID = item["id"] as! NSNumber
                        let movieTitle = item["name"] as! String
                        if let dataImage = try? Data(contentsOf:NSURL(string: "http://image.tmdb.org/t/p/w500"+stringImage)! as URL){
                            self.listDataTvShows.append(MovieModel(movieImage: UIImage(data: dataImage)!,movieID: movieID.stringValue, movieTitle: movieTitle))
                        }
                    }
                    DispatchQueue.main.async {
                        self.tvShowCollectionView.reloadData()
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
    
    @IBAction func tvShowSegmented(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedSegmentIndex = 0
            getSelectedDataTvShow(selected: selectedSegmentIndex)
        case 1:
            selectedSegmentIndex = 1
            getSelectedDataTvShow(selected: selectedSegmentIndex)
        default:
            selectedSegmentIndex = 0
            getSelectedDataTvShow(selected: selectedSegmentIndex)
        }
    }
}

extension TvShowsViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listDataTvShows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = tvShowCollectionView.dequeueReusableCell(withReuseIdentifier: "TvShowCell", for: indexPath) as! TvShowCollectionViewCell
        cell.tvShowsImage.image = listDataTvShows[indexPath.row].movieImage
        cell.originalTitle.text = listDataTvShows[indexPath.row].movieTitle
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        cell.layer.shadowRadius = 8.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tvShowID = listDataTvShows[indexPath.row].movieID
        performSegue(withIdentifier: "GoToDetailTV", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToDetailTV" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.movieID = tvShowID
            detailVC.category = "tv"
        }
    }
}
