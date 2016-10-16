//
//  Created by Carlos Vidal Pallin on 15/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation

/**
 
 */
public class Service {
    
    ///
    private static let mappingQueue = dispatch_queue_create("com.nakiostudio.background", DISPATCH_QUEUE_SERIAL)
    
    ///
    public let baseURL: NSURL
    
    ///
    public let dataManager: DataManager
    
    ///
    let streamSessionManager: StreamSessionManager
    
    ///
    public private(set) lazy var streamAPI: StreamAPI = {
        let api = StreamAPI(
            baseURL: self.baseURL,
            dataManager: self.dataManager,
            streamSessionManager: self.streamSessionManager
        )
        return api
    }()
    
    ///
    public init(baseURL: NSURL) {
        self.baseURL = baseURL
        self.streamSessionManager = StreamSessionManager(dispatchQueue: Service.mappingQueue)
        self.dataManager = DataManager()
        self.dataManager.loadStack()
    }
    
}
