//
//  Created by Carlos Vidal Pallin on 15/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import Foundation
import Social

/**
 
 */
enum TwitterStreamEndpoint {
    
    ///
    case Statuses(track: String)
    
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
            return SLRequestMethod.GET
        }
    }
    
    ///
    var parameters: [NSObject: AnyObject] {
        switch self {
        case let .Statuses(track):
            return ["track": track]
        }
    }
    
}
