//
//  Copyright © Marc Rollin.
//

import Foundation
import SwiftUI

//struct BuildSizesTable: View {
//    @State var build: Build
//    @State var sizes: [BuildBundleFileSize]
//
//    private let columns: [GridItem] = [
//        GridItem(.flexible(), spacing: 16),
//        GridItem(.flexible(), spacing: 16),
//        GridItem(.flexible(), spacing: 16),
//    ]
//
//    var body: some View {
//        Group {
//            Section(header: VStack {
//                Text("Build \(build.version)").font(.title)
//                Text("Uploaded \(build.uploadedDate.formatted())").font(.subheadline)
//            }) {
//                Grid(alignment: .leadingFirstTextBaseline) {
//                    GridRow {
//                        Text("Device Model").font(.headline).gridColumnAlignment(.leading)
//                        Text("Download Size").font(.headline).gridColumnAlignment(.trailing)
//                        Text("Install Size").font(.headline).gridColumnAlignment(.trailing)
//                    }
//                    Divider()
//                    ForEach(sizes) { size in
//                        GridRow {
//                            Text(size.deviceModel)
//                            Text(size.downloadSize)
//                            Text(size.installSize)
//                        }
//                    }
//                }
//            }
//            .padding()
//        }
//        .background(.white)
//        .frame(minWidth: 500)
//    }
//}
