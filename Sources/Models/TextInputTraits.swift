//
//  TextInputTraits.swift
//  
//
//  Created by Anastasia Eleftheriadi on 21/12/22.
//

import Foundation

public struct TextInputTraits: IBDecodable, IBKeyable {
    public let key: String?
    public let secureTextEntry: Bool?
    
    static func decode(_ xml: XMLIndexerType) throws -> TextInputTraits {
        let container = xml.container(keys: CodingKeys.self)
        return TextInputTraits(
            key:                   container.attributeIfPresent(of: .key),
            secureTextEntry:       container.attributeIfPresent(of: .secureTextEntry)
        )
    }
}
