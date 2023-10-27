//
//  Copyright © Marc Rollin.
//

import CoreGraphics
import Foundation

// MARK: - Partitionable

public protocol Partitionable {
    var size: CGFloat { get }
    var segments: [Self] { get }
}

// MARK: - Partition

struct Partition<Item: Partitionable> {
    public let rect: CGRect
    public let item: Item
}

// MARK: - SquarifyPartitioner

/// Squarify algorithm implementation loosely based on [Squarified Treemaps](https://www.win.tue.nl/~vanwijk/stm.pdf)
enum SquarifyPartitioner {

    // MARK: Internal

    static func partition<Item: Partitionable>(item: Item, frame: CGRect) -> [Partition<Item>] {
        guard item.segments.count > 1 else {
            guard let singleSegment = item.segments.first else {
                return []
            }
            return [Partition(rect: frame, item: singleSegment)]
        }

        var frame = frame
        var partitions: [Partition<Item>] = []
        var scaledItems: [ScaledItem<Item>] = item.segments
            .sorted(by: { $0.size > $1.size })
            .filter { $0.size > 0 }
            .map { .init(scaledSize: ($0.size * frame.size.height * frame.size.width) / item.size, item: $0) }

        squarify(
            scaledNodes: &scaledItems,
            width: biggestFittingSquare(for: frame.size).side,
            partitions: &partitions,
            frame: &frame
        )

        return partitions
    }

    // MARK: Private

    private struct SquareFit {
        enum Orientation {
            case vertical, horizontal
        }

        let orientation: Orientation
        let side: CGFloat
    }

    private struct ScaledItem<Item: Partitionable> {
        let scaledSize: CGFloat
        let item: Item
    }

    private static func worstRatio(row: [ScaledItem<some Partitionable>], width: CGFloat) -> CGFloat {
        let rowScaledSizes = row.map(\.scaledSize)
        let sum = rowScaledSizes.reduce(0, +)

        guard let rowMax = rowScaledSizes.max(),
              let rowMin = rowScaledSizes.min(),
              sum != 0, width != 0
        else {
            return 0
        }

        let squareSum = pow(sum, 2)
        let squareWidth = pow(width, 2)

        return max(
            (squareWidth * rowMax) / squareSum,
            squareSum / (squareWidth * rowMin)
        )
    }

    private static func biggestFittingSquare(for size: CGSize) -> SquareFit {
        pow(size.height, 2) <= pow(size.width, 2)
            ? .init(orientation: .vertical, side: size.height)
            : .init(orientation: .horizontal, side: size.width)
    }

    private static func layoutRow<Item: Partitionable>(
        row: [ScaledItem<Item>],
        width: CGFloat,
        orientation: SquareFit.Orientation,
        partitions: inout [Partition<Item>],
        frame: inout CGRect
    ) {
        guard width > 0 else { return }

        let rowHeight = row.map(\.scaledSize).reduce(0, +) / width

        guard rowHeight > 0 else { return }

        for scaledItem in row {
            let rowWidth = scaledItem.scaledSize / rowHeight

            var newFrame: CGRect
            switch orientation {
            case .vertical:
                newFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: rowHeight, height: rowWidth)
                frame.origin.y += rowWidth
            case .horizontal:
                newFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: rowWidth, height: rowHeight)
                frame.origin.x += rowWidth
            }

            partitions.append(.init(rect: newFrame, item: scaledItem.item))
        }

        switch orientation {
        case .vertical:
            frame.origin.x += rowHeight
            frame.origin.y -= width
            frame.size.width -= rowHeight
        case .horizontal:
            frame.origin.x -= width
            frame.origin.y += rowHeight
            frame.size.height -= rowHeight
        }
    }

    private static func squarify<Item: Partitionable>(
        scaledNodes: inout [ScaledItem<Item>],
        row: [ScaledItem<Item>] = [],
        width: CGFloat,
        partitions: inout [Partition<Item>],
        frame: inout CGRect
    ) {
        guard scaledNodes.count != 1 else {
            let maxSquareFit = biggestFittingSquare(for: frame.size)
            layoutRow(
                row: row,
                width: width,
                orientation: maxSquareFit.orientation,
                partitions: &partitions,
                frame: &frame
            )
            layoutRow(
                row: scaledNodes,
                width: width,
                orientation: maxSquareFit.orientation,
                partitions: &partitions,
                frame: &frame
            )
            return
        }

        guard let firstNode = scaledNodes.first else {
            return
        }

        let rowWithChild = row + CollectionOfOne(firstNode)
        if row.isEmpty || worstRatio(row: row, width: width) >= worstRatio(row: rowWithChild, width: width) {
            scaledNodes.removeFirst()
            squarify(scaledNodes: &scaledNodes, row: rowWithChild, width: width, partitions: &partitions, frame: &frame)
        } else {
            layoutRow(
                row: row,
                width: width,
                orientation: biggestFittingSquare(for: frame.size).orientation,
                partitions: &partitions,
                frame: &frame
            )
            squarify(
                scaledNodes: &scaledNodes,
                width: biggestFittingSquare(for: frame.size).side,
                partitions: &partitions,
                frame: &frame
            )
        }
    }
}
