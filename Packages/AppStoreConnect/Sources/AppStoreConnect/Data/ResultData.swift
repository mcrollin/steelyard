//
//  Copyright © Marc Rollin.
//

import Foundation

struct ResultData<DataType: Decodable>: Decodable {
    let data: DataType
}
