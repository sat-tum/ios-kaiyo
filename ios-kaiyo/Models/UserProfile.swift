//
//  UserProfile.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import Foundation
import SwiftData

// MARK: - ユーザーデータモデル
@Model
final class UserProfile {
    var enrollmentYear: Int    // 入学年度 (例: 2024)
    var currentGrade: Int       // 現在の学年 (例: 3)
    var department: String      // 所属学科名

    init(enrollmentYear: Int, currentGrade: Int, department: String) {
        self.enrollmentYear = enrollmentYear
        self.currentGrade = currentGrade
        self.department = department
    }
}
