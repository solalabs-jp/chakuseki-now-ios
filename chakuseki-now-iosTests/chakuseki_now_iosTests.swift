//
//  chakuseki_now_iosTests.swift
//  chakuseki-now-iosTests
//
//  Created by 鈴木拓也 on 2026/04/22.
//

import Testing
@testable import chakuseki_now_ios

struct chakuseki_now_iosTests {

    @Test func growthSystem_counts_exp_and_level() async throws {
        let records = [
            AttendanceRecord(sessionNumber: 1, date: .now, status: .attendance),
            AttendanceRecord(sessionNumber: 2, date: .now, status: .attendance),
            AttendanceRecord(sessionNumber: 3, date: .now, status: .tardiness),
            AttendanceRecord(sessionNumber: 4, date: .now, status: .officialAbsence)
        ]

        #expect(GrowthSystem.totalExp(from: records) == 33)

        let info = GrowthSystem.levelInfo(for: records)
        #expect(info.level == 1)
        #expect(info.remainingExpText == "進化まであと 147EXP!")
    }

    @Test func growthSystem_works_for_full_four_years() async throws {
        let records = Array(repeating: AttendanceRecord(sessionNumber: 1, date: .now, status: .attendance), count: 1800)
        let info = GrowthSystem.levelInfo(for: records)
        #expect(info.level == 100)
    }

}
