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
    private static let delimiter = "\r\n"
    
    /// Database utils
    private weak var dataManager: DataManager?
    
    /// Endpoint the deserializer applies to. Ignored for now as there is only
    /// one endpoint available
    private let endpoint: StreamEndpoint
    
    /// Part of the message received so far
    private var message = ""
    
    /// Length of the message that it's being received
    private var length: Int?
    
    init(dataManager: DataManager, endpoint: StreamEndpoint) {
        self.dataManager = dataManager
        self.endpoint = endpoint
    }
    
    // MARK: - Public methods
    
    /**
     Process the streamed data, first splitting it by chunks delimited with the
     string defined above
     */
    func process(data data: NSData) {
        guard let string = String(data: data, encoding: NSUTF8StringEncoding) else {
            return
        }
        
        let chunks = string.componentsSeparatedByString(ResponseDeserializer.delimiter)
        if chunks.count > 0 {
            self.process(chunks: chunks)
        }
    }
    
    // MARK: - Private methods
    
    /**
     Processes the different chunks identifying lengths or message bodies
     */
    private func process(chunks chunks: [String]) {
        // Before leaving the scope if there are more chunks process them
        defer {
            if chunks.count > 1 {
                self.process(chunks: Array(chunks.dropFirst()))
            }
        }
        
        guard let chunk = chunks.first, length = self.length else {
            // If there is no length or current message then this must be a
            // length chunk
            if let chunk = chunks.first, length = Int(chunk) {
                self.length = length - ResponseDeserializer.delimiter.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            }
            return
        }
        
        // If the lengths match the map the message into database objects
        let message = self.message.stringByAppendingString(chunk)
        let lengthSoFar = message.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        if lengthSoFar == length {
            if let data = message.dataUsingEncoding(NSUTF8StringEncoding) {
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
    private func parse(data data: NSData) {
        guard let dataManager = self.dataManager else {
            return
        }
        
        do {
            if let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [NSObject: AnyObject] {
                let status = Status.entity(withDictionary: dictionary, objectContext: dataManager.mappingObjectContext)
                dataManager.save() { error in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                    }
                }
            }
        }
        catch let error as NSError {
            debugPrint("Unable to convert NSData into Dictionary")
        }
    }
    
}
