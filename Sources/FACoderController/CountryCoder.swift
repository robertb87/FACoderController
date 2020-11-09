//
//  File.swift
//  
//
//  Created by Robert Bradish on 08/11/2020.
//

import Foundation

public class FACountryCoder<CoderItem: Codable> {
    
    private let _docURL: URL //FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("countries.json")
    
    public init(withDocumentURL docURL: URL) {
        self._docURL = docURL
    }
    
    public func decode() throws -> [CoderItem] {
        
        performFirstTimeCheck()
        
        guard let data = try? Data(contentsOf: _docURL) else {
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

            try data.write(to: _docURL)
            
        } catch {
            print(error)
        }
    }
    
    @discardableResult public func resetFile() -> Bool{
        do {
            try FileManager.default.removeItem(at: _docURL)
        } catch {
            print("\(error)")
            #warning("handle this error properly or it could lead to unsafe state")
            return false
        }
        
        return true
    }
    
    private func performFirstTimeCheck() {
        let resourceSection = _docURL.pathComponents.last?.split(separator: ".")
        
        if let resource = resourceSection?[0], let ext = resourceSection?[1] {
            guard let url = Bundle.main.url(forResource: "\(resource)", withExtension: ".\(ext)") else { fatalError() }

            let firstTime = FileManager.default.fileExists(atPath: _docURL.path)

            if !firstTime {
                
                do {
                    
                try FileManager.default.copyItem(at: url, to: _docURL)
                    
                } catch {
                    
                    print("\(error)")
                    
                }
            }
        }
    }
}

enum DatabaseError: Error {
    case notFound
    case noData
    case notDecoded
}
