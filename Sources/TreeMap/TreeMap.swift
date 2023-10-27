//
//  Copyright © Marc Rollin.
//

import Platform
import SwiftUI

// MARK: - TreeMapDisplayable

public protocol TreeMapDisplayable: Partitionable, Identifiable, CustomStringConvertible {
    var color: Color? { get }
    var isDuplicate: Bool { get }
    var shouldShowDetails: Bool { get }
}

// MARK: - TreeMap

public struct TreeMap<Node: TreeMapDisplayable>: View {

    // MARK: Lifecycle

    public init(node: Node, spacing: CGFloat = 16, onTap: @escaping (Node) -> Void, onHover: @escaping (Node?) -> Void) {
        self.node = node
        self.spacing = spacing
        self.onTap = onTap
        self.onHover = onHover
    }

    // MARK: Public

    public var body: some View {
        tree
            .padding(spacing)
            .background(.background)
    }

    // MARK: Internal

    private let node: Node
    private let spacing: CGFloat
    private let onTap: (Node) -> Void
    private let onHover: (Node?) -> Void

    var hoveringNode: Node? {
        hoverStack.last
    }

    // MARK: Private

    @State private var hoverStack: [Node] = []

    @ViewBuilder
    private var tree: some View {
        GeometryReader { geometry in
            drawTreemap(
                in: .init(
                    origin: .zero,
                    size: .init(width: geometry.size.width, height: geometry.size.height)
                ),
                node: node
            )
        }
    }

    private func drawTreemap(in rect: CGRect, node: Node) -> some View {
        drawTreemap(
            node: node,
            includeDetails: rect.size.canDisplayTitle
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap(node)
        }
        .onHover(perform: { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                if hovering {
                    hoverStack.append(node)
                } else {
                    hoverStack.removeLast()
                }
            }
            onHover(hoveringNode)
        })
        .frame(width: rect.width, height: rect.height)
        .position(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
    }

    @ViewBuilder
    private func drawTreemap(node: Node, includeDetails: Bool) -> some View {
        let background = node.color ?? .clear
        let foreground: Color = node.isDuplicate ? .white : (node.shouldShowDetails ? .primary : background)

        if node.shouldShowDetails, includeDetails {
            detailedNode(node: node, background: background, foreground: foreground)
        } else {
            simpleNode(node: node, foreground: foreground, background: background, includeDetails: includeDetails)
        }
    }

    private func detailedNode(node: Node, background: Color, foreground: Color) -> some View {
        VStack(spacing: spacing * 0.7) {
            Text(node.description)
                .font(.headline)
                .foregroundColor(foreground)
                .lineLimit(1)
            GeometryReader { geometry in
                ZStack {
                    let partitions = partition(
                        node: node,
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    ForEach(partitions, id: \.item.id) { partition in
                        AnyView(
                            drawTreemap(
                                in: partition.rect,
                                node: partition.item
                            )
                        )
                    }
                }
                .background(.background)
            }
        }
        .padding(spacing * 0.5)
        .background(background.opacity(0.6))
        .border(hoveringNode?.id == node.id ? .yellow : background)
        .padding(1)
    }

    private func simpleNode(
        node: Node,
        foreground: Color,
        background: Color,
        includeDetails: Bool
    )
    -> some View {
        Rectangle()
            .fill(background.opacity(node.isDuplicate ? 0.8 : (node.shouldShowDetails ? 0.6 : 0.3)))
            .border(hoveringNode?.id == node.id ? .yellow : foreground)
            .padding(1)
            .overlay {
                if includeDetails {
                    Text(node.description)
                        .font(.subheadline)
                        .foregroundColor(foreground)
                        .padding(spacing)
                        .clipped()
                }
            }
    }

    private func partition(
        node: Node,
        width: CGFloat,
        height: CGFloat
    ) -> [Partition<Node>] {
        SquarifyPartitioner
            .partition(
                item: node,
                frame: .init(origin: .zero, size: .init(width: width, height: height))
            )
    }
}

extension CGSize {

    fileprivate var canDisplayTitle: Bool {
        (width >= 80 && height >= 50) || (height >= 80 && width >= 50)
    }
}
