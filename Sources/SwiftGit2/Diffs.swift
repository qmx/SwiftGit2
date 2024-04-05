//
//  Diffs.swift
//  SwiftGit2
//
//  Created by Jake Van Alstyne on 8/20/17.
//  Copyright © 2017 GitHub, Inc. All rights reserved.
//

import libgit2

public struct StatusEntry {
    public var status: Diff.Status
    public var headToIndex: Diff.Delta?
    public var indexToWorkDir: Diff.Delta?

    init(from statusEntry: git_status_entry) {
        status = Diff.Status(rawValue: statusEntry.status.rawValue)

        if let htoi = statusEntry.head_to_index {
            headToIndex = Diff.Delta(htoi.pointee)
        }

        if let itow = statusEntry.index_to_workdir {
            indexToWorkDir = Diff.Delta(itow.pointee)
        }
    }
}

public struct Diff {
    /// The set of deltas.
    public var deltas = [Delta]()

    public struct Delta {
        public static let type: GitObjectType = .deltaGivenByObjectID

        public var status: Status
        public var flags: Flags
        public var oldFile: File?
        public var newFile: File?

        init(_ delta: git_diff_delta) {
            status = Status(rawValue: UInt32(git_diff_status_char(delta.status)))
            flags = Flags(rawValue: delta.flags)
            oldFile = File(delta.old_file)
            newFile = File(delta.new_file)
        }
    }

    public struct File {
        public var oid: OID
        public var path: String
        public var size: UInt64
        public var flags: Flags

        init(_ diffFile: git_diff_file) {
            oid = OID(diffFile.id)
            let path = diffFile.path
            self.path = path.map(String.init(cString:))!
            size = diffFile.size
            flags = Flags(rawValue: diffFile.flags)
        }
    }

    public struct Status: OptionSet {
        // This appears to be necessary due to bug in Swift
        // https://bugs.swift.org/browse/SR-3003
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public let rawValue: UInt32

        public static let current = Status(rawValue: GIT_STATUS_CURRENT.rawValue)
        public static let indexNew = Status(rawValue: GIT_STATUS_INDEX_NEW.rawValue)
        public static let indexModified = Status(rawValue: GIT_STATUS_INDEX_MODIFIED.rawValue)
        public static let indexDeleted = Status(rawValue: GIT_STATUS_INDEX_DELETED.rawValue)
        public static let indexRenamed = Status(rawValue: GIT_STATUS_INDEX_RENAMED.rawValue)
        public static let indexTypeChange = Status(rawValue: GIT_STATUS_INDEX_TYPECHANGE.rawValue)
        public static let workTreeNew = Status(rawValue: GIT_STATUS_WT_NEW.rawValue)
        public static let workTreeModified = Status(rawValue: GIT_STATUS_WT_MODIFIED.rawValue)
        public static let workTreeDeleted = Status(rawValue: GIT_STATUS_WT_DELETED.rawValue)
        public static let workTreeTypeChange = Status(rawValue: GIT_STATUS_WT_TYPECHANGE.rawValue)
        public static let workTreeRenamed = Status(rawValue: GIT_STATUS_WT_RENAMED.rawValue)
        public static let workTreeUnreadable = Status(rawValue: GIT_STATUS_WT_UNREADABLE.rawValue)
        public static let ignored = Status(rawValue: GIT_STATUS_IGNORED.rawValue)
        public static let conflicted = Status(rawValue: GIT_STATUS_CONFLICTED.rawValue)
    }

    public struct Flags: OptionSet {
        // This appears to be necessary due to bug in Swift
        // https://bugs.swift.org/browse/SR-3003
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public let rawValue: UInt32

        public static let binary = Flags([])
        public static let notBinary = Flags(rawValue: 1 << 0)
        public static let validId = Flags(rawValue: 1 << 1)
        public static let exists = Flags(rawValue: 1 << 2)
    }

    /// Create an instance with a libgit2 `git_diff`.
    init(_ pointer: OpaquePointer) {
        for i in 0 ..< git_diff_num_deltas(pointer) {
            if let delta = git_diff_get_delta(pointer, i) {
                deltas.append(Diff.Delta(delta.pointee))
            }
        }
    }
}
