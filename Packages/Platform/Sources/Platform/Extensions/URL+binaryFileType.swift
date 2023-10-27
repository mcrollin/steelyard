//
//  Copyright © Marc Rollin.
//

import Foundation

// MARK: - BinaryFileType

public enum BinaryFileType: CustomStringConvertible {
    case machO
    case elf
    case windowsPE
    case unknown

    public var description: String {
        switch self {
        case .machO:
            "Mach-O"
        case .elf:
            "ELF"
        case .windowsPE:
            "Windows PE"
        case .unknown:
            "Binary"
        }
    }
}

extension URL {

    // MARK: Public

    public var binaryFileType: BinaryFileType? {
        guard let fileHandle = try? FileHandle(forReadingFrom: self) else {
            return nil
        }

        let data = fileHandle.readData(ofLength: 64) // Read only the first 64 bytes
        fileHandle.closeFile()

        if isMachO(data: data) {
            return .machO
        } else if isELF(data: data) {
            return .elf
        } else if isWindowsPE(data: data) {
            return .windowsPE
        } else if isUnknownBinary(data: data) { }
        return nil
    }

    // MARK: Private

    private func isMachO(data: Data) -> Bool {
        data.starts(with: [0xFE, 0xED, 0xFA, 0xCF]) || data.starts(with: [0xCF, 0xFA, 0xED, 0xFE])
    }

    private func isELF(data: Data) -> Bool {
        data.starts(with: [0x7F, 0x45, 0x4C, 0x46])
    }

    private func isWindowsPE(data: Data) -> Bool {
        data.starts(with: [0x4D, 0x5A])
    }

    private func isUnknownBinary(data: Data) -> Bool {
        let textChars: Set<UInt8> = Set(9...13).union(Set(32...126)) // Tab, CR, LF, and printable ASCII
        return !data.allSatisfy { textChars.contains($0) }
    }
}
