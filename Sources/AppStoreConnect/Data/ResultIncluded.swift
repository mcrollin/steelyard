//
//  Copyright © Marc Rollin.
//

import Foundation

struct ResultIncluded<IncludedType: Decodable>: Decodable {
    let included: IncludedType
}
