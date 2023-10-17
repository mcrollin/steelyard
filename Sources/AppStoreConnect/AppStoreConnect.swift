//
//  Copyright © Marc Rollin.
//

import Foundation
import HTTPTypes

public actor AppStoreConnect {
    static let baseURL = "api.appstoreconnect.apple.com"
    static let version = "v1"

    private let client: APIClient
    private let decoder = JSONDecoder()

    private enum Endpoint {
        case apps
        case app(appID: String)
        case versions(appID: String, limit: Int)
        case build(versionID: String)
        case builds(appID: String, limit: Int)
        case buildBundles(buildID: String)
        case buildBundleFileSizes(bundleID: String)

        var httpMethod: HTTPRequest.Method {
            .get
        }

        var path: String {
            switch self {
            case .apps:
                return "apps?fields[apps]=bundleId,name"
            case let .app(appID):
                return "apps/\(appID)?fields[apps]=bundleId,name"
            case let .versions(appID, limit):
                return "apps/\(appID)?include=appStoreVersions&fields[apps]=bundleId&fields[appStoreVersions]=versionString&limit[appStoreVersions]=\(limit)"
            case let .build(versionID):
                return "appStoreVersions/\(versionID)?include=build&fields[appStoreVersions]=&fields[builds]=uploadedDate,version"
            case let .builds(appID, limit):
                return "builds?filter[app]=\(appID)&limit=\(limit)&fields[builds]=uploadedDate,version"
            case let .buildBundles(buildID):
                return "builds/\(buildID)?include=buildBundles&fields[builds]=&fields[buildBundles]="
            case let .buildBundleFileSizes(bundleID):
                return "buildBundles/\(bundleID)/buildBundleFileSizes"
            }
        }

        var request: HTTPRequest {
            .init(
                method: httpMethod,
                scheme: "https",
                authority: AppStoreConnect.baseURL,
                path: "/\(AppStoreConnect.version)/\(path)"
            )
        }
    }

    enum ConnectError: Error, CustomStringConvertible {
        case missingBuildBundle(buildID: String, buildVersion: String)

        var description: String {
            switch self {
            case let .missingBuildBundle(_, buildVersion):
                return "No build bundle found for build #\(buildVersion)"
            }
        }
    }

    public init(keyID: String, issuerID: String, privateKeyPath: String) throws {
        client = try .init(
            keyID: keyID,
            issuerID: issuerID,
            audience: "appstoreconnect-v1",
            privateKeyPath: privateKeyPath
        )

        decoder.dateDecodingStrategy = .iso8601
    }

    public func apps() async throws -> [Application] {
        try await requestData(endpoint: .apps)
    }

    public func app(appID: String) async throws -> Application {
        try await requestData(endpoint: .app(appID: appID))
    }

    public func versions(app: Application, limit: Int) async throws -> [Version] {
        try await requestIncluded(endpoint: .versions(appID: app.id, limit: limit))
    }

    public func build(version: Version) async throws -> Build {
        let builds: [Build] = try await requestIncluded(endpoint: .build(versionID: version.id))
        return builds.first!
    }

    public func builds(app: Application, limit: Int) async throws -> [Build] {
        try await requestData(endpoint: .builds(appID: app.id, limit: limit))
    }

    public func buildBundles(build: Build) async throws -> [BuildBundle] {
        try await requestIncluded(endpoint: .buildBundles(buildID: build.id))
    }

    public func buildBundleFileSizes(buildBundle: BuildBundle) async throws -> [BuildBundleFileSize] {
        try await requestData(endpoint: .buildBundleFileSizes(bundleID: buildBundle.id))
    }

    public func sizes(versions: [Version], progress: ((Float) -> Void)?) async throws -> [SizesByBuildAndVersion] {
        guard !versions.isEmpty else { return [] }

        return try await sizes(totalCount: versions.count, progress: progress) { group in
            for version in versions {
                group.addTask {
                    try await self.sizes(
                        byBuild: self.build(version: version),
                        version: version
                    )
                }
            }
        }
    }

    public func sizes(builds: [Build], progress: ((Float) -> Void)?) async throws -> [SizesByBuildAndVersion] {
        guard !builds.isEmpty else { return [] }

        return try await sizes(totalCount: builds.count, progress: progress) { group in
            for build in builds {
                group.addTask {
                    try await self.sizes(
                        byBuild: build,
                        version: nil
                    )
                }
            }
        }
    }

    private func sizes(
        totalCount: Int,
        progress: ((Float) -> Void)?,
        addTasks: (inout ThrowingTaskGroup<SizesByBuildAndVersion, Error>) -> Void
    ) async throws -> [SizesByBuildAndVersion] {
        try await withThrowingTaskGroup(of: SizesByBuildAndVersion.self) { group in
            addTasks(&group)

            var sizesByBuildAndVersion: [SizesByBuildAndVersion] = []
            let totalCount = Float(totalCount)
            progress?(Float(sizesByBuildAndVersion.count)/totalCount)
            for try await sizes in group {
                sizesByBuildAndVersion.append(sizes)
                progress?(Float(sizesByBuildAndVersion.count)/totalCount)
            }
            sizesByBuildAndVersion.sort { lhs, rhs in
                lhs.build.uploadedDate < rhs.build.uploadedDate
            }

            return sizesByBuildAndVersion
        }
    }

    private func sizes(byBuild build: Build, version: Version?) async throws -> SizesByBuildAndVersion {
        guard let mainBundle = try await buildBundles(build: build).first else {
            throw ConnectError.missingBuildBundle(buildID: build.id, buildVersion: build.version)
        }

        return .init(
            version: version,
            build: build,
            fileSizes: try await buildBundleFileSizes(buildBundle: mainBundle)
        )
    }

    private func requestData<DataType: Decodable>(endpoint: Endpoint) async throws -> DataType {
        try await decoder.decode(
            ResultData<DataType>.self,
            from: data(endpoint: endpoint)
        ).data
    }

    private func requestIncluded<IncludedType: Decodable>(endpoint: Endpoint) async throws -> IncludedType {
        try await decoder.decode(
            ResultIncluded<IncludedType>.self,
            from: data(endpoint: endpoint)
        ).included
    }

    private func data(endpoint: Endpoint) async throws -> Data {
        do {
            return try await client.send(request: endpoint.request)
        } catch let error as APIClient.RequestError {
            switch error {
            case let .http(_, data):
                throw (try? decoder.decode(ErrorResponse.self, from: data)) ?? error
            }
        } catch {
            throw error
        }
    }
}
