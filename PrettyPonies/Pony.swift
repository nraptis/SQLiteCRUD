//
//  Pony.swift
//  PrettyPoniesCLPA
//
//  Created by Tiger Nixon on 5/12/23.
//

import Foundation

struct Pony {
    let id: Int
    let name: String
    let superpower: String
}

extension Pony: Identifiable { }
extension Pony: Hashable { }
extension Pony: Sendable { }
