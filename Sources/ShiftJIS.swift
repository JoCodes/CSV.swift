//
//  ShiftJIS.swift
//  CSV
//
//  Created by Yasuhiro Hatta on 2016/11/17.
//  Copyright © 2016 yaslab. All rights reserved.
//

import Foundation

public struct ShiftJIS: UnicodeCodec {

    public typealias CodeUnit = UInt8

    public init() {}

    internal var _decodeBuffer = Data()

    public mutating func decode<I: IteratorProtocol>(
        _ input: inout I
    ) -> UnicodeDecodingResult where I.Element == CodeUnit {

        guard let codeUnit = input.next() else { return .emptyInput }

        if (CodeUnit(0x00)...0x1f).contains(codeUnit)
        || (CodeUnit(0x20)...0x7f).contains(codeUnit) {
            // ASCII
            return .scalarValue(UnicodeScalar(codeUnit))
        } else if (CodeUnit(0x81)...0x9f).contains(codeUnit)
               || (CodeUnit(0xe0)...0xef).contains(codeUnit) {
            // Non-ASCII
            _decodeBuffer.removeAll(keepingCapacity: true)
            _decodeBuffer.append(codeUnit)
            guard let codeUnit = input.next() else { return .error }
            _decodeBuffer.append(codeUnit)
            let str = String(data: _decodeBuffer, encoding: .shiftJIS)
            guard let unicodeScalar = str?.unicodeScalars.first else { return .error }
            return .scalarValue(unicodeScalar)
        } else {
            return .error
        }
    }

    public static func encode(
        _ input: UnicodeScalar,
        into processCodeUnit: (CodeUnit) -> Void
    ) {
        guard let data = String(input).data(using: .shiftJIS) else { return }
        for codeUnit in data {
            processCodeUnit(codeUnit)
        }
    }

}
