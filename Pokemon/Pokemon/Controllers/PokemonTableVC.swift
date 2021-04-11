//
//  PokemonTableVC.swift
//  Pokemon
//
//  Created by Luka Dimitrijevic on 05.02.21.
//

import UIKit

class PokemonTableVC : UIViewController
{
    var pokemons : [Pokemon] = []
    private var id : Int = 1
    private let pavc = ProgressActivityVC()
    
    @IBOutlet weak var pokeTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        id = 1
        let pokeURL     = URL(string: "https://pokeapi.co/api/v2/pokemon/")!
        let request     = URLRequest(url: pokeURL)
        let config      = URLSessionConfiguration.default
        let urlSession  = URLSession(configuration: config)
        
        pokeTable.delegate   = self
        pokeTable.dataSource = self
        
        catchThemAll(session: urlSession, request: request, amount: 20)
    }
}

// API data extraction extension
extension PokemonTableVC
{
    func catchThemAll(session: URLSession, request: URLRequest, amount: Int)
    {
        self.pavc.createProgressView()
        
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else {
                if let data = data, let pokeResponse = try? JSONDecoder().decode(PokemonResponse.self, from: data) {
                    if amount >= pokeResponse.count {
                        return
                    }
                    DispatchQueue.main.async {
                        for pokemon in pokeResponse.pokemon{
                            pokemon.name = "\(self.id)" + " - " + pokemon.name
                            self.id = self.id + 1
                            self.pokemons.append(pokemon)
                        }
                        self.pokeTable.reloadData()
                    }
                    self.catchThemAll(session: session, request: URLRequest(url: URL(string: "https://pokeapi.co/api/v2/pokemon/?offset=\(amount)&limit=20")!), amount: amount + 20)
                }
                else{
                    print("error in parsing")
                }
            }
        }.resume()
    }
}

extension PokemonTableVC : UITableViewDelegate
{
    // deselect and animate tap of a cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(identifier: "pokemonInfo") as! PokemonInfoVC
        destination.navigationItem.title = pokemons[indexPath.row].name
        destination.setData(url: pokemons[indexPath.row].url)
        destination.setSelection(stringURL: pokemons[indexPath.row].url)
        // MARK:-TODO Call to firebase save pokemon URL
        self.navigationController?.pushViewController(destination, animated: true)
    }
}

extension PokemonTableVC : UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Pokémon"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    // create and populate the UIViewCell that is displayed to the user
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokeName", for: indexPath)
        cell.textLabel?.text = pokemons[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension   // based on constraints and content, cells adjust appropriately - certain constraints are necessary
    }
}
