//
//  Semester.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import Foundation

// MARK: - 学期判定
enum Semester {
    case first  // 前期: 3月1日 〜 8月31日
    case second // 後期: 9月1日 〜 2月28/29日

    static func current(from date: Date = Date()) -> Semester {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)

        // 3月〜8月: 前期、9月〜2月: 後期
        return (3...8).contains(month) ? .first : .second
    }

    var displayName: String {
        switch self {
        case .first: return "前期"
        case .second: return "後期"
        }
    }
}
