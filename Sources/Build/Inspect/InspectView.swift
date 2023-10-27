//
//  Copyright © Marc Rollin.
//

import Foundation
import SwiftUI
import TreeMap

// MARK: - InspectView

struct InspectView: View {

    // MARK: Lifecycle

    init(inspector: Inspector) {
        self.inspector = inspector
    }

    // MARK: Internal

    var body: some View {
        VStack {
            TreeMap(node: inspector.selectedNode) { node in
                print("Tapped on node \(node)")
                withAnimation(.easeOut(duration: 0.2)) {
                    inspector.selectedNode = node
                }
            } onHover: { node in
                print("Hovering on node \(node?.description ?? "nothing")")
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .environment(inspector)
    }

    // MARK: Private

    @State private var inspector: Inspector

}
