//
//  Model.swift
//  Pokemon
//
//  Created by Luka Dimitrijevic on 05.02.21.
//

import UIKit

// MARK:- Pokemon Data Model
class PokemonResponse : Decodable {
    let count  : Int
    let next   : String?
    let prev   : String?
    let pokemon: [Pokemon]
    
    enum CodingKeys: String, CodingKey {
        case count
        case next
        case prev
        case pokemon = "results"        // map json format 'results' to my property 'pokemon'
    }
}

class Pokemon : Decodable {
    var name: String
    let url : String                    // holds the reference to the next pokemon via another URL request
}

class Sprite : Decodable {
    let front_default : String
}

class PokemonInfo : Decodable {
    let height  : Int
    let sprites : Sprite
    let weight  : Int
}

class Poke {
    var name: String?
    var img: UIImageView?
    
    init(name: String, img: UIImageView) {
        self.name = name
        self.img = img
    }
}

class FavPokemon {
    var name: String?
    var weight: Int?
    var height: Int?
    var img:    String?
    
    init(name: String, w: Int, h: Int, img: String) {
        self.name   = name
        self.weight = w
        self.height = h
        self.img    = img
    }
}

class Favourites {
    static let shared = Favourites()
    private init() {}
    private var urls : [String] = []
    private var liked : [Int : FavPokemon] = [:]
    
    public func addUrl(url: String) {
        urls.append(url)
    }
    
    public func addLike(pokemon: FavPokemon, position: Int) {
        liked[position] = pokemon
    }
    
    public func removeUrl(url: String) {
        if urls.contains(where: {$0 == url}) {
            urls.remove(at: urls.firstIndex(where: {$0 == url})!)
        }
    }
    
    public func removeLike(pokemon: FavPokemon) {
        if liked.contains(where: {$0.value.name == pokemon.name}) {
            liked.remove(at: liked.firstIndex(where: {$0.value.name == pokemon.name})!)
        }
    }
    
    public func getUrls() -> [String] {
        return urls
    }
    
    public func getLiked() -> [Int:FavPokemon] {
        return liked
    }
}
