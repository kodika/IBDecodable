//
//  InterfaceBuilder.swift
//  IBLinterCore
//
//  Created by SaitoYuta on 2017/12/05.
//

import SWXMLHash
import Foundation

private let cocoaTouchKey = "com.apple.InterfaceBuilder3.CocoaTouch.XIB"
private let cocoaKey = "com.apple.InterfaceBuilder3.Cocoa.XIB"
private let cocoaStoryboard = "com.apple.InterfaceBuilder3.Cocoa.Storyboard.XIB"

public struct InterfaceBuilderParser {
    struct XMLHeader: XMLDecodable, KeyDecodable {
        let archiveType: String?
        let documentType: String?
        let version: String?
        
        enum CodingKeys: String, CodingKey {
            case archiveType = "archive"
            case documentType = "document"
        }
        
        enum ArchiveCodingKeys: CodingKey { case type }
        
        static func decode(_ xml: XMLIndexerType) throws -> XMLHeader {
            let container = xml.container(keys: CodingKeys.self)
            let archiveContainer = try? container.nestedContainer(of: .archiveType, keys: ArchiveCodingKeys.self)
            
            if archiveContainer != nil {
                return try XMLHeader(
                    archiveType: archiveContainer?.attribute(of: .type) ?? "", documentType: nil, version: archiveContainer?.attribute(of: .type) ?? ""
                )
            } else {
                let documentContainer = try? container.nestedContainer(of: .documentType, keys: ArchiveCodingKeys.self)
                return try XMLHeader(
                    archiveType: nil, documentType: documentContainer?.attribute(of: .type), version: documentContainer?.attribute(of: .type)
                )
            }
        }
        
        func getType() -> String? {
            if let archieveType = self.archiveType {
                return archieveType
            } else {
                return documentType
            }
        }
    }
    
    let xmlParser: SWXMLHash
    
    public init(detectParsingErrors: Bool = true) {
        xmlParser = SWXMLHash.config { options in
            options.detectParsingErrors = detectParsingErrors
        }
    }
    
    public func parseXib(xml: String) throws -> XibDocument {
        return try parseDocument(xml: xml)
    }
    
    public func parseStoryboard(xml: String) throws -> StoryboardDocument {
        return try parseDocument(xml: xml)
    }
    
    internal func parseDocument<D: InterfaceBuilderDocument & IBDecodable>(xml: String) throws -> D {
        return try parseDocument(xmlIndexer: xmlParser.parse(xml))
    }
    
    internal func parseDocument<D: InterfaceBuilderDocument & IBDecodable>(data: Data) throws -> D {
        return try parseDocument(xmlIndexer: xmlParser.parse(data))
    }
    
    enum Keys: CodingKey { case document }
    
    internal func parseDocument<D: InterfaceBuilderDocument & IBDecodable>(xmlIndexer: XMLIndexerType) throws -> D {
        if let swxmlIndexer = xmlIndexer as? XMLIndexer {
            if let error = swxmlIndexer.error {
                throw error
            }
        }
        let xmlHeader: XMLHeader? = try? decodeValue(xmlIndexer)
        let xmlHeaderType = xmlHeader?.getType()
        
        if [cocoaKey, cocoaStoryboard].contains(xmlHeaderType) {
            throw Error.macFormat
        } else if xmlHeader?.archiveType != nil || xmlHeader?.version != "3.0" {
            throw Error.legacyFormat
        }
        
        let container = xmlIndexer.container(keys: Keys.self)
        do {
            return try container.element(of: .document)
        } catch {
            if let err = error as? ParsingError {
                throw Error.parsingError(err)
            }
            
            if let err = error as? IndexingError {
                throw Error.xmlError(err)
            }
            
            throw error
        }
    }
    
    public enum Error: Swift.Error {
        case invalidFormatFile
        case legacyFormat
        case macFormat
        case parsingError(ParsingError)
        case xmlError(IndexingError)
    }
}

extension XMLIndexer {
    var error: InterfaceBuilderParser.Error? {
        switch self {
        case .parsingError(let error):
            return .parsingError(error)
        case .xmlError(let error):
            return .xmlError(error)
        default:
            return nil
        }
    }
}