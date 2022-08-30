//
//  Astronaut.swift
//  PeopleInSpace
//
//  Created by Hanna Chen on 2022/8/30.
//

import Foundation

struct Astronaut: Decodable, Hashable {
    let name: String
    let craft: String
}

struct AstrosResponse: Decodable {
    let people: [Astronaut]
}
