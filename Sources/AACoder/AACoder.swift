//
//  File.swift
//  
//
//  Created by Robert Bradish on 08/11/2020.
//

import Foundation

/// A wrapper class that manages coding of a file for an app.  One instance will manage one file.
public class AACoder<CoderItem: Codable> {
    
    private let _codedDocumentURL: URL //FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("countries.json")
    
    public init(withCodedDocumentURL documentURL: URL) {
        self._codedDocumentURL = documentURL
    }
    
    
    /// Checks if the coded document that is being managed by the Coder exists, if the file exists it at the loaction it will return true.
    /// - Returns: Bool
    public func documentExists() -> Bool {
        return FileManager.default.fileExists(atPath: _codedDocumentURL.path)
    }
    
    /// Copies the file from the bundle from the full bundle URL provided to the location managed by the Coder
    /// - Parameter bundleURL: The URL of the parent Bundle where the master copy of the file is located
    public func copyDocument(fromBundleURL bundleURL: URL) {
        do {
            try FileManager.default.copyItem(at: bundleURL, to: _codedDocumentURL)
        } catch {
            print("\(error)")
        }
    }
    
    public func decode() throws -> [CoderItem] {
                
        guard let data = try? Data(contentsOf: _codedDocumentURL) else {
            throw DatabaseError.noData
        }
        
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode([CoderItem].self, from: data)
        } catch {
            throw DatabaseError.notDecoded
        }
    }
    
    public func encode(countries: [CoderItem]) {
        let encoder = JSONEncoder()
        var data: Data = Data()
        
        do {
            data = try encoder.encode(countries.self)

            try data.write(to: _codedDocumentURL)
            
        } catch {
            print(error)
        }
    }
    
    @discardableResult public func resetFile() -> Bool{
        do {
            try FileManager.default.removeItem(at: _codedDocumentURL)
        } catch {
            print("\(error)")
            #warning("handle this error properly or it could lead to unsafe state")
            return false
        }
        
        return true
    }

}

enum DatabaseError: Error {
    case notFound
    case noData
    case notDecoded
}
