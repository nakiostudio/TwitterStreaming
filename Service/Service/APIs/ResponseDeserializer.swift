//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation

/**
 Class in charge of converting the chunks of data into complete messages, then
 dictionaries and finally database model objects
 */
class ResponseDeserializer {
    
    /// String used by the stream API to delimit messages and lengths
    fileprivate static let delimiter = "\r\n"
    
    /// Database utils
    fileprivate weak var dataManager: DataManager?
    
    /// Endpoint the deserializer applies to. Ignored for now as there is only
    /// one endpoint available
    fileprivate let endpoint: StreamEndpoint
    
    /// Part of the message received so far
    fileprivate var message = ""
    
    /// Length of the message that it's being received
    fileprivate var length: Int?
    
    init(dataManager: DataManager, endpoint: StreamEndpoint) {
        self.dataManager = dataManager
        self.endpoint = endpoint
    }
    
    // MARK: - Public methods
    
    /**
     Process the streamed data, first splitting it by chunks delimited with the
     string defined above
     */
    func process(data: Data) {
        guard let string = String(data: data, encoding: String.Encoding.utf8) else {
            return
        }
        
        let chunks = string.components(separatedBy: ResponseDeserializer.delimiter)
        if chunks.count > 0 {
            self.process(chunks: chunks)
        }
    }
    
    // MARK: - Private methods
    
    /**
     Processes the different chunks identifying lengths or message bodies
     */
    fileprivate func process(chunks: [String]) {
        // Before leaving the scope if there are more chunks process them
        defer {
            if chunks.count > 1 {
                self.process(chunks: Array(chunks.dropFirst()))
            }
        }
        
        guard let chunk = chunks.first, let length = self.length else {
            // If there is no length or current message then this must be a
            // length chunk
            if let chunk = chunks.first, let length = Int(chunk) {
                self.length = length - ResponseDeserializer.delimiter.lengthOfBytes(using: String.Encoding.utf8)
            }
            return
        }
        
        // If the lengths match the map the message into database objects
        let message = self.message + chunk
        let lengthSoFar = message.lengthOfBytes(using: String.Encoding.utf8)
        if lengthSoFar == length {
            if let data = message.data(using: String.Encoding.utf8) {
                self.parse(data: data)
            }
            self.message = ""
            self.length = nil
            return
        }
        else if lengthSoFar > length {
            // If the current size of the message is greater that the length set
            // then throw everything away
            self.message = ""
            self.length = nil
            return
        }
        
        // Keep appending
        self.message = message
    }
    
    /**
     Convert the data into a dictionary and eventually database objects
     */
    fileprivate func parse(data: Data) {
        guard let dataManager = self.dataManager else {
            return
        }
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] {
                let _ = Status.entity(withDictionary: dictionary, objectContext: dataManager.mappingObjectContext)
                dataManager.save() { error in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                    }
                }
            }
        }
        catch _ {
            debugPrint("Unable to convert NSData into Dictionary")
        }
    }
    
}
