//
//  Created by Carlos Vidal Pallin on 15/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation
import Social

/**
 
 */
enum StreamEndpoint {
    
    ///
    case Statuses
    
    ///
    var path: String {
        switch self {
        case .Statuses:
            return "statuses/filter.json"
        }
    }
    
    ///
    var method: SLRequestMethod {
        switch self {
        case .Statuses:
            return .POST
        }
    }
    
}
