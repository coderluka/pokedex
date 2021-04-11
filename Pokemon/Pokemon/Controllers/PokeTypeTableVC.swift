//
//  PokeTypeTableVC.swift
//  Pokemon
//
//  Created by Luka Dimitrijevic on 05.02.21.
//

import UIKit

class PokeTypeTableVC : UIViewController
{
    var types : [Pokemon] = []
    private let pavc = ProgressActivityVC()
    
    @IBOutlet weak var typesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pokeURL     = URL(string: "https://pokeapi.co/api/v2/type/")!
        let request     = URLRequest(url: pokeURL)
        let config      = URLSessionConfiguration.default
        let urlSession  = URLSession(configuration: config)
        
        typesTable.delegate = self
        typesTable.dataSource = self
        
        gatherAllTypes(session: urlSession, request: request, amount: 0)
    }
}

extension PokeTypeTableVC
{
    func gatherAllTypes(session: URLSession, request: URLRequest, amount: Int)
    {
        self.pavc.createProgressView()
        
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else {
                if let data = data, let pokeResponse = try? JSONDecoder().decode(PokemonResponse.self, from: data) {
                    DispatchQueue.main.async {
                        for type in pokeResponse.pokemon{
                            self.types.append(type)
                        }
                        self.typesTable.reloadData()
                    }
                }
                else{
                    print("error in parsing")
                }
            }
        }.resume()
    }
}

extension PokeTypeTableVC : UITableViewDelegate
{
    // deselect and animate tap of a cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PokeTypeTableVC : UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Types Of Pokémon"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokeType", for: indexPath)
        cell.textLabel?.text = types[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension   // based on constraints and contetn, cells adjust appropriately - certain constraints are necessary
    }
}
