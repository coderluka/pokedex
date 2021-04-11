//
//  FavouritesViewController.swift
//  Pokemon
//
//  Created by Luka Dimitrijevic on 01.04.21.
//

import UIKit

class FavouritesViewController : UIViewController {
    
    @IBOutlet weak var titleLbl: UINavigationItem!
    @IBOutlet weak var imageImg: UIImageView!
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    
    private var idx = 0
    
    func setIdx(i: Int) {
        idx = i
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("===> HERE: \(Favourites.shared.getLiked()[idx]?.name)")
        print("===> HERE: \(Favourites.shared.getLiked()[idx]?.img)")
        print("===> HERE: \(Favourites.shared.getLiked()[idx]?.height)")
        print("===> HERE: \(Favourites.shared.getLiked()[idx]?.weight)")
        
        titleLbl.title = Favourites.shared.getLiked()[idx]?.name
        imageImg.image = UIImage(named: Favourites.shared.getLiked()[idx]?.img ?? "pokemon_selected")
        heightLbl.text = String(Favourites.shared.getLiked()[idx]?.height ?? 0)
        weightLbl.text = String(Favourites.shared.getLiked()[idx]?.weight ?? 0)
    }
}
