//
//  Copyright © Marc Rollin.
//

import Charts
import Platform
import SwiftUI

struct Dashboard: View {

    // MARK: Lifecycle

    init(model: DashboardModel) {
        self.model = model
    }

    // MARK: Internal

    @State var model: DashboardModel

    var body: some View {
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

    // MARK: Private

    private func chart(title: String, sizes: [DashboardModel.Size]) -> some View {
        Section {
            Chart(sizes, id: \.version) { size in
                ForEach(DashboardModel.Size.Categories.allCases) { category in
                    thinnedRange(size: size, name: category.name)
                }
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
                        AxisValueLabel(size.formattedBytes())
                    }
                }
            }
            .frame(width: CGFloat(sizes.count * 80), height: 600)
        } header: {
            Text(title)
                .font(.title)
                .foregroundColor(.primary)
        }
        .frame(minWidth: 400)
        .padding()
    }

    @ChartContentBuilder
    private func referenceLineMark(size: DashboardModel.Size) -> some ChartContent {
        if let reference = size.reference, let device = model.referenceDeviceIdentifier {
            PointMark(
                x: .value("Version", size.version),
                y: .value(device, reference)
            )
            .foregroundStyle(by: .value("Type", device))
            .annotation(spacing: 6) {
                Text(reference.formattedBytes())
                    .font(.caption.monospacedDigit().bold())
                    .foregroundColor(.secondary)
            }

            dottedLineMark(size: size, value: reference, name: device)
        }
    }

    @ChartContentBuilder
    private func universalLineMark(size: DashboardModel.Size) -> some ChartContent {
        if let universal = size.universal {
            dottedLineMark(size: size, value: universal, name: DashboardModel.universalIdentifier)
                .symbolSize(.zero)
        }
    }

    @ChartContentBuilder
    private func dottedLineMark(size: DashboardModel.Size, value: Int, name: String) -> some ChartContent {
        LineMark(
            x: .value("Version", size.version),
            y: .value(name, value)
        )
        .foregroundStyle(by: .value("Type", name))
        .interpolationMethod(.catmullRom)
        .lineStyle(StrokeStyle(lineWidth: 2))
    }

    @ChartContentBuilder
    private func thinnedRange(size: DashboardModel.Size, name: String) -> some ChartContent {
        if let range = size.thinned[name] {
            thinnedRange(size: size, range: range, name: name)
                .opacity(size.reference == nil ? 1 : 0.4)
                .foregroundStyle(by: .value("Type", name))
                .position(by: .value("Type", name))
        }
    }

    @ChartContentBuilder
    private func thinnedRange(size: DashboardModel.Size, range: ClosedRange<Int>, name: String) -> some ChartContent {
        if range.count > 2 {
            BarMark(
                x: .value("Version", size.version),
                yStart: .value("Min", range.lowerBound),
                yEnd: .value("Max", range.upperBound),
                width: .fixed(8)
            )
        } else {
            PointMark(
                x: .value("Version", size.version),
                y: .value("Average", Double(range.lowerBound + range.upperBound) / 2.0)
            )
        }
    }
}
