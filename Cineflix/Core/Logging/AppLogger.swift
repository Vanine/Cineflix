//
//  AppLogger.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 19.02.2026.
//

import Foundation
import OSLog

nonisolated struct AppLogger: Sendable {
    private let logger: Logger

    init(subsystem: String, category: String) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }

    func debug(_ message: String) {
        logger.debug("\(message, privacy: .public)")
    }

    func warning(_ message: String) {
        logger.warning("\(message, privacy: .public)")
    }

    func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }
}
