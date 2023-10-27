//
//  Copyright © Marc Rollin.
//

import ApplicationArchive
import Foundation

// MARK: - Inspector

@Observable
final class Inspector {

    // MARK: Lifecycle

    init(tree: ApplicationArchive) {
        self.tree = tree
        selectedNode = tree.root
    }

    // MARK: Internal

    var selectedNode: ApplicationArchive.Node

    // MARK: Private

    private let tree: ApplicationArchive
}
