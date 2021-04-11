//
//  DashboardViewController.swift
//  Pokemon
//
//  Created by Luka Dimitrijevic on 25.03.21.
//

import UIKit

import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class DashboardViewController : UIViewController {
    
    private var db: Firestore!
    private var listener : ListenerRegistration?
    
    // MARK:- Outlets
    @IBOutlet weak var greetingLbl: UILabel!
    @IBOutlet weak var sectionTextLbl: UILabel!
    @IBOutlet weak var favImg01: UIImageView!
    @IBOutlet weak var favImg02: UIImageView!
    @IBOutlet weak var favImg03: UIImageView!
    @IBOutlet weak var favImg04: UIImageView!
    @IBOutlet weak var favImg05: UIImageView!
    @IBOutlet weak var favImg06: UIImageView!
    @IBOutlet weak var favImg07: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let firestoreSettings = FirestoreSettings()

        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
        
        let username = Auth.auth().currentUser?.email?.getEmails().first
        greetingLbl.text = "Hello, \(username ?? "Pokemon Trainer")!"
        
        getFavourites()
        
        setTapGestures(imgs: [
            favImg01,
            favImg02,
            favImg03,
            favImg04,
            favImg05,
            favImg06,
            favImg07
        ])
        
        self.listener = db.collection("favourites").addSnapshotListener{ querySnapshot, error in
            guard let document = querySnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            let value = document.documents
            for d in value {
                print("[ debug ] ===> \(d)")
            }
        }
        
        for i in 0..<Favourites.shared.getUrls().count {
            let pokeURL     = URL(string: Favourites.shared.getUrls()[i])!
            let request = URLRequest(url: URL(string: Favourites.shared.getUrls()[i])!)
            let config      = URLSessionConfiguration.default
            let urlSession  = URLSession(configuration: config)
            getPokemon(urlSession: urlSession, request: request, id: i)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        listener?.remove()
    }
    
    func setTapGestures(imgs : [UIImageView]) {
        for i in 0..<imgs.count {
            let rec = UITapGestureRecognizer(target: self, action: switchSelectorFunc(id: i))
            imgs[i].addGestureRecognizer(rec)
            imgs[i].isUserInteractionEnabled = true
            imgs[i].isHidden = true
        }
    }
    
    func getFavourites() {
        let ref = db.collection("favourites")
        let query = ref.whereField("user", isEqualTo: Auth.auth().currentUser?.uid)
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let url = document.data()["pokeUrl"] as! String
                    Favourites.shared.addUrl(url: url)
                    self.setImg(url: url, imgID: Favourites.shared.getUrls().firstIndex(of: url)!)
                }
            }
        }
    }
    
    func getPokemon(urlSession: URLSession, request: URLRequest, id: Int) {
        
        var name : String?
        var img  : String?
        var w    : Int?
        var h    : Int?
        
        urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else {
                if let data = data, let pokeResponse = try? JSONDecoder().decode(PokemonInfo.self, from: data) {
                    DispatchQueue.main.async {
                        // add image from URL to the UIImageView
                        guard let _ : URL = URL(string: pokeResponse.sprites.front_default) else {
                            print("error with image")
                            return
                        }
                        img = pokeResponse.sprites.front_default
                        h   = pokeResponse.height
                        w   = pokeResponse.weight
                    }
                }
                else{
                    print("error in parsing")
                }
                if let data = data, let pokeResponse = try? JSONDecoder().decode(Pokemon.self, from: data) {
                    DispatchQueue.main.async {
                        // add image from URL to the UIImageView
                        guard let _ : URL = URL(string: pokeResponse.name) else {
                            
                            return
                        }
                        name = pokeResponse.name
                    }
                }
                else{
                    print("error in parsing")
                }
            }
            Favourites.shared.addLike(pokemon: FavPokemon(name: name ?? "DEFAULT", w: w ?? 0, h: h ?? 0, img: img ?? "IMAGE"), position: id)
        }.resume()
    }
    
    func setImg(url: String, imgID: Int) {
        print("imgID ===> \(imgID)")
        let pokeURL     = URL(string: url)!
        let request     = URLRequest(url: pokeURL)
        let config      = URLSessionConfiguration.default
        let urlSession  = URLSession(configuration: config)
        
        urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else {
                if let data = data, let pokeResponse = try? JSONDecoder().decode(PokemonInfo.self, from: data) {
                    DispatchQueue.main.async {
                        print(pokeResponse.sprites.front_default)
                        guard let imgURL : URL = URL(string: pokeResponse.sprites.front_default) else {
                            self.switchImgIDs(imgID: imgID).backgroundColor = .red
                            return
                        }
                        self.switchImgIDs(imgID: imgID).loadImage(withURL: imgURL)
                    }
                }
                else{
                    print("error in parsing")
                }
            }
        }.resume()
        return
    }
    
    @objc func settings() {
        print("settings")
        performSegue(withIdentifier: "toSettings", sender: self)
    }
}

// MARK:- Mail Username extraction
extension String {
  func getEmails() -> [String] {
    if let regex = try? NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+", options: .caseInsensitive)
    {
        let string = self as NSString

        return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
            string.substring(with: $0.range).replacingOccurrences(of: "", with: "").lowercased()
        }
    }
    return []
  }
}

// MARK:- Action Functions
extension DashboardViewController {
    
    func switchImgIDs(imgID: Int) -> UIImageView {
        switch imgID {
        case 0:
            favImg01.isHidden = false
            return favImg01
        case 1:
            favImg02.isHidden = false
            return favImg02
        case 2:
            favImg03.isHidden = false
            return favImg03
        case 3:
            favImg04.isHidden = false
            return favImg04
        case 4:
            favImg05.isHidden = false
            return favImg05
        case 5:
            favImg06.isHidden = false
            return favImg06
        case 6:
            favImg07.isHidden = false
            return favImg07
        default:
            return UIImageView()
        }
    }
    
    func switchSelectorFunc(id: Int) -> Selector {
        switch id {
            case 0:
                return #selector(tap1)
            case 1:
                return #selector(tap2)
            case 2:
                return #selector(tap3)
            case 3:
                return #selector(tap4)
            case 4:
                return #selector(tap5)
            case 5:
                return #selector(tap6)
            case 6:
                return #selector(tap7)
            default:
                return Selector("")
        }
        return Selector("")
    }
    
    @objc func tap1() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(identifier: "favPokemon") as! FavouritesViewController
        destination.setIdx(i:0)
        performSegue(withIdentifier: "toPokemon", sender: self)
    }
    
    @objc func tap2() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(identifier: "favPokemon") as! FavouritesViewController
        destination.setIdx(i:1)
        performSegue(withIdentifier: "toPokemon", sender: self)
    }
    
    @objc func tap3() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(identifier: "favPokemon") as! FavouritesViewController
        destination.setIdx(i:2)
        performSegue(withIdentifier: "toPokemon", sender: self)
    }
    
    @objc func tap4() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(identifier: "favPokemon") as! FavouritesViewController
        destination.setIdx(i:4)
        performSegue(withIdentifier: "toPokemon", sender: self)
    }
    
    @objc func tap5() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(identifier: "favPokemon") as! FavouritesViewController
        destination.setIdx(i:4)
        performSegue(withIdentifier: "toPokemon", sender: self)
    }
    
    @objc func tap6() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(identifier: "favPokemon") as! FavouritesViewController
        destination.setIdx(i:5)
        performSegue(withIdentifier: "toPokemon", sender: self)
    }
    
    @objc func tap7() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(identifier: "favPokemon") as! FavouritesViewController
        destination.setIdx(i:6)
        performSegue(withIdentifier: "toPokemon", sender: self)
    }
}
