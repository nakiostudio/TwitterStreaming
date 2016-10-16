//
//  Created by Carlos Vidal Pallin on 15/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation

/**
 
 */
class ResponseDeserializer {
    
    ///
    private static let delimiter = "\r\n"
    
    ///
    private weak var dataManager: DataManager?
    
    ///
    private let endpoint: StreamEndpoint
    
    ///
    private var message = ""
    
    ///
    private var length: Int?
    
    /**
     
     */
    init(dataManager: DataManager, endpoint: StreamEndpoint) {
        self.dataManager = dataManager
        self.endpoint = endpoint
    }
    
    // MARK: - Public methods
    
    /**
     
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
 
     */
    private func process(chunks chunks: [String]) {
        //
        defer {
            if chunks.count > 1 {
                self.process(chunks: Array(chunks.dropFirst()))
            }
        }
        
        //
        guard let chunk = chunks.first, length = self.length else {
            if let chunk = chunks.first, length = Int(chunk) {
                self.length = length - ResponseDeserializer.delimiter.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            }
            return
        }
        
        //
        let message = self.message.stringByAppendingString(chunk)
        if message.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == length {
            if let data = message.dataUsingEncoding(NSUTF8StringEncoding) {
                self.parse(data: data)
            }
            self.message = ""
            self.length = nil
            return
        }
        
        //
        self.message = message
    }
    
    /**
 
     */
    private func parse(data data: NSData) {
        let dict = try! NSJSONSerialization.JSONObjectWithData(data, options: [])
        dump(dict)
    }
    
}
