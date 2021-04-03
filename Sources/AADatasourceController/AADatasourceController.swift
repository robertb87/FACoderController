//
//  File.swift
//  
//
//  Created by Robert Bradish on 30/12/2020.
//

import Foundation
import AACoder

public class AADatasourceController<DataItem: DataType> {

    private var _data: [DataItem.ID: DataItem]?
    private var _coder: AACoder<DataItem>?

    public init() {
        
    }

    deinit {
       // NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: .AADatasourceUpdated, object: nil)
        print("AADatasourceController Deinit'd")
    }
    //Read
    public func readAll() -> [DataItem] {
        return toArray(_data)
    }

    public func read(where dataFilter: (DataItem) -> Bool) -> [DataItem] {
        return toArray(_data?.filter({dataFilter($0.value)}))
    }

    //Update
    public func update(item: DataItem) {
        let key = item.id
        _data?[key] = item
        updateSubscribers()
    }

    //Remove
    public func remove(item: DataItem) {
        checkForNil()
        _data?.removeValue(forKey: item.id)
        updateSubscribers()
    }

    //Create
    public func create(items: [DataItem]) {
        checkForNil()
        for item in items {
            _data?[item.id] = item
        }
        updateSubscribers()
    }

    public func create(item: DataItem) {
        checkForNil()
        _data?[item.id] = item
        updateSubscribers()
    }

    private func updateSubscribers() {
        let note = Notification(name: .AADatasourceUpdated, object: nil, userInfo: nil)
        NotificationCenter.default.post(note)

        let dataArray = readAll()
        if !dataArray.isEmpty {
            _coder?.encode(countries: dataArray)
        }
    }

    private func toArray(_ data: [DataItem.ID:DataItem]?) -> [DataItem] {
        guard let safeData = data else { return [DataItem]()}
        var output = [DataItem]()

        for value in safeData.values {
            output.append(value)
        }
        return output
    }
    private func checkForNil() {
        if _data == nil {
            _data = [DataItem.ID: DataItem]()
        }
    }
}

public extension AADatasourceController {

     func configure(codedDocumentURL: URL, bundleDocumentURL: URL) {
        var dataTemp: [DataItem]?
        checkForNil()
        _coder = AACoder(withCodedDocumentURL: codedDocumentURL)

        if _coder?.documentExists() == false {
            let bundleURL = bundleDocumentURL
            _coder?.copyDocument(fromBundleURL: bundleURL)
        }

        do {
            dataTemp = try _coder?.decode()

            if let dataTemp = dataTemp {
                for item in dataTemp {
                    _data?[item.id] = item
                }
            }

        } catch {
            print(error.localizedDescription)
            fatalError("Country decoder error")
        }

//        NotificationCenter.default.addObserver(forName: .AADatasourceUpdated, object: self, queue: nil) { [unowned self] note in
//            let dataArray = readAll()
//            if !dataArray.isEmpty {
//                _coder?.encode(countries: dataArray)
//            }
//        }
    }
}


public extension Notification.Name {
    static let AADatasourceUpdated = Notification.Name("AADatasourceUpdated")
    static let AARequestUpdate = Notification.Name("AARequestUpdate")
}

public protocol AADataRequestResponseDelegate {
    associatedtype DataItem = DataType

    func acceptDataArray(data: [DataItem])
}
