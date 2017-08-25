//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation
import Social

/**
 Different endpoints available in this API
 */
enum StreamEndpoint {
    
    /// Stream of statuses filtered by keyword
    case statuses
    
    /// Path of the endpoint
    var path: String {
        switch self {
        case .statuses:
            return "statuses/filter.json"
        }
    }
    
    /// Method of the endpoint
    var method: SLRequestMethod {
        switch self {
        case .statuses:
            return .POST
        }
    }
    
}
