//
//  AstrosAPI.swift
//  PeopleInSpace
//
//  Created by Hanna Chen on 2022/8/30.
//

import Foundation

enum AstrosAPI {
    static let url = "http://api.open-notify.org/astros.json"

    static let publisher = URLSession.shared
        .dataTaskPublisher(for: URL(string: url)!)
        .map(\.data)
        .decode(type: AstrosResponse.self, decoder: JSONDecoder())
        .map(\.people)
        .replaceError(with: [])
        .eraseToAnyPublisher()
}
