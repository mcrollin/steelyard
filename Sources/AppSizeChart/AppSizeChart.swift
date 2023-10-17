//
//  Copyright © Marc Rollin.
//

import Charts
import Foundation
import SwiftUI

public struct AppSizeChart: View {
    @State public var model: AppSizeChartModel

    public init(model: AppSizeChartModel) {
        self.model = model
    }

    private static let byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter
    }()

    private func formatBytes(_ bytes: Int) -> String {
        Self.byteCountFormatter.string(fromByteCount: Int64(bytes))
    }

    public var body: some View {
        VStack {
            Text(model.appName).font(.largeTitle).foregroundColor(.primary)
            if let downloadSizes = model.downloadSizes {
                Divider()
                chart(title: "Download size", sizes: downloadSizes)
            }
            if let installSizes = model.installSizes {
                Divider()
                chart(title: "Install size", sizes: installSizes)
            }
        }
        .padding()
        .background(.background)
    }

    private func chart(title: String, sizes: [AppSizeChartModel.Size]) -> some View {
        Section {
            Chart(sizes, id: \.version) { size in
                thinnedRangeBarMark(size: size)
                universalLineMark(size: size)
                referenceLineMark(size: size)
                    .symbol(Circle().strokeBorder(style: StrokeStyle(lineWidth: 2)))
                    .symbolSize(80)
            }
            .chartLegend(.visible)
            .chartLegend(position: .automatic, spacing: 8)
            .chartXAxis(.automatic)
            .chartYAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()

                    if let size = value.as(Int.self) {
                        AxisValueLabel(formatBytes(size))
                    }
                }
            }
            .frame(width: CGFloat(sizes.count * 60), height: 600)
        } header: {
            Text(title)
                .font(.title)
                .foregroundColor(.primary)
        }
        .padding()
    }

    @ChartContentBuilder
    private func referenceLineMark(size: AppSizeChartModel.Size) -> some ChartContent {
        if let reference = size.reference, let device = model.referenceDeviceIdentifier {
            PointMark(
                x: .value("Version", size.version),
                y: .value(device, reference)
            )
            .foregroundStyle(by: .value("Type", device))
            .annotation(
                position: size.thinned.lowerBound.distance(to: reference)
                    < reference.distance(to: size.thinned.upperBound)
                    ? .bottom
                    : .top,
                spacing: 6
            ) {
                Text(formatBytes(reference))
                    .font(.caption.monospacedDigit().bold())
                    .foregroundColor(.secondary)
            }

            dottedLineMark(size: size, value: reference, name: device)
        }
    }

    @ChartContentBuilder
    private func universalLineMark(size: AppSizeChartModel.Size) -> some ChartContent {
        if let universal = size.universal {
            dottedLineMark(size: size, value: universal, name: AppSizeChartModel.universalIdentifier)
                .symbolSize(.zero)
        }
    }

    @ChartContentBuilder
    private func dottedLineMark(size: AppSizeChartModel.Size, value: Int, name: String) -> some ChartContent {
        LineMark(
            x: .value("Version", size.version),
            y: .value(name, value)
        )
        .foregroundStyle(by: .value("Type", name))
        .interpolationMethod(.catmullRom)
        .lineStyle(StrokeStyle(lineWidth: 2))
    }

    @ChartContentBuilder
    private func thinnedRangeBarMark(size: AppSizeChartModel.Size) -> some ChartContent {
        BarMark(
            x: .value("Version", size.version),
            yStart: .value("Thinned Min", size.thinned.lowerBound),
            yEnd: .value("Thinned Max", size.thinned.upperBound),
            width: .fixed(8)
        )
        .clipShape(Capsule())
        .foregroundStyle(by: .value("Type", "Thinned variants"))
    }
}
