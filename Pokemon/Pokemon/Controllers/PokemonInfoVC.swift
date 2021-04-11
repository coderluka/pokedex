//
//  ViewController.swift
//  Pokemon
//
//  Created by Luka Dimitrijevic on 03.02.21.
//

import UIKit

import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class PokemonInfoVC: UIViewController {
    
    var db: Firestore!
    
    // MARK:- Local Variables
    private var identifier : String = "cell"
    private var data : [String] = []
    private var tableView : UITableView!
    private var imgView : UIImageView!
    private var isLiked : Bool = false
    private var selectedPokemon : String?
    private var amountOfFavourites : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView = UIImageView(frame: CGRect(x: self.view.center.x/3, y: self.view.center.y/3, width: 200, height: 200))
        imgView.contentMode = UIView.ContentMode.scaleAspectFill
        view.addSubview(imgView)
        
        //let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height      // deprecated in 13.0
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height - 100

        tableView = UITableView(frame: CGRect(x: 0, y: 300, width: displayWidth, height: displayHeight - 300))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        
        let firestoreSettings = FirestoreSettings()

        Firestore.firestore().settings = firestoreSettings
        db = Firestore.firestore()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(addToFavourites))
    
        checkIfLiked()
        getLikedAmount()
    }
    
    @objc func addToFavourites() {
        if isLiked {
            isLiked = false
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
            
            let ref = db.collection("favourites")
            let query = ref
                .whereField("user", isEqualTo: Auth.auth().currentUser?.uid)
                .whereField("pokeUrl", isEqualTo: selectedPokemon)
            query.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        document.reference.delete()
                        print("Document deleted with ID: \(document.documentID)")
                    }
                }
            }
        } else if amountOfFavourites < 7 {
            isLiked = true
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
           
            var ref: DocumentReference? = nil
            ref = db.collection("favourites").addDocument(data: [
                "user": Auth.auth().currentUser?.uid,
                "pokeUrl": selectedPokemon
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            
            getPokemon()
        } else {
            self.popUpError(title: "Too many pokémons", msg: "You cannot add more than 7 pokémons to your favourites!", action: "OK")
        }
    }
    
    @objc func getLikedAmount() {
        let ref = db.collection("favourites")
        let query = ref
            .whereField("user", isEqualTo: Auth.auth().currentUser?.uid)
        query.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.amountOfFavourites = querySnapshot!.documents.count
            }
        }
    }
    
    @objc func checkIfLiked() {
        let ref = db.collection("favourites")
        let query = ref
            .whereField("user", isEqualTo: Auth.auth().currentUser?.uid)
            .whereField("pokeUrl", isEqualTo: selectedPokemon)
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if querySnapshot!.documents.count > 0 {
                self.isLiked = true
                self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
            }
        }
    }

    func setSelection(stringURL: String) {
        selectedPokemon = stringURL
    }
    
    func getPokemon() {
        let pokeURL     = URL(string: selectedPokemon!)
        let request     = URLRequest(url: pokeURL!)
        let config      = URLSessionConfiguration.default
        let urlSession  = URLSession(configuration: config)
        let uiiv        = UIImageView()
        var name        : String?
        
        urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else {
                if let data = data, let pokeResponse = try? JSONDecoder().decode(PokemonInfo.self, from: data) {
                    DispatchQueue.main.async {
                        // add image from URL to the UIImageView
                        guard let imgURL : URL = URL(string: pokeResponse.sprites.front_default) else {
                            uiiv.backgroundColor = .red
                            return
                        }
                        uiiv.loadImage(withURL: imgURL)
                        
                    }
                }
                else{
                    print("error in parsing")
                }
                if let data = data, let pokeResponse = try? JSONDecoder().decode(Pokemon.self, from: data) {
                    DispatchQueue.main.async {
                        // add image from URL to the UIImageView
                        guard let _ : URL = URL(string: pokeResponse.name) else {
                            name = "POKEMON"
                            return
                        }
                        
                    }
                }
                else{
                    print("error in parsing")
                }
            }
        }.resume()
    }
    
    func setData(url: String){
        let pokeURL     = URL(string: url)!
        let request     = URLRequest(url: pokeURL)
        let config      = URLSessionConfiguration.default
        let urlSession  = URLSession(configuration: config)
        
        var localData : [String] = []
        
        urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else {
                if let data = data, let pokeResponse = try? JSONDecoder().decode(PokemonInfo.self, from: data) {
                    DispatchQueue.main.async {
                        // add image from URL to the UIImageView
                        print(pokeResponse.sprites.front_default)
                        guard let imgURL : URL = URL(string: pokeResponse.sprites.front_default) else {
                            self.imgView.backgroundColor = .red
                            return
                        }
                        self.imgView.loadImage(withURL: imgURL)
                        localData.append("Height: \(pokeResponse.height)")
                        localData.append("Weight: \(pokeResponse.weight)")
                        
                        self.data = localData
                        print(localData)
                        self.tableView.reloadData()
                    }
                }
                else{
                    print("error in parsing")
                }
            }
        }.resume()
    }
    
    func popUpError(title: String, msg: String, action: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: action, style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIImageView {
    func loadImage(withURL url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension PokemonInfoVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PokemonInfoVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath as IndexPath)
        cell.textLabel?.text = self.data[indexPath.row]
        return cell
    }
}

