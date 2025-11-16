//
//  CreditRegistrationView.swift
//  ios-kaiyo
//
//  Created on 2025/11/17.
//

import SwiftUI

/// 過去の履修単位を登録する画面
struct CreditRegistrationView: View {
    @Bindable var viewModel: AppViewModel
    
    @State private var currentSemesterIndex = 0
    @State private var selectedCourses: [String: [String]] = [:] // semester -> course names
    @State private var showingCourseSelector = false
    
    private var semesters: [String] {
        generateSemesters()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // 学期の進捗表示
                if !semesters.isEmpty {
                    ProgressView(value: Double(currentSemesterIndex + 1), total: Double(semesters.count))
                        .padding()
                    
                    Text("\(semesters[currentSemesterIndex])")
                        .font(.headline)
                        .padding(.bottom, 8)
                }
                
                // 選択済み科目のリスト
                List {
                    if let courses = selectedCourses[semesters[safe: currentSemesterIndex] ?? ""], !courses.isEmpty {
                        ForEach(courses, id: \.self) { course in
                            HStack {
                                Text(course)
                                Spacer()
                                Button {
                                    removeCourse(course)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    } else {
                        ContentUnavailableView(
                            "履修科目なし",
                            systemImage: "book.closed",
                            description: Text("「科目を追加」ボタンから履修した科目を追加してください")
                        )
                    }
                }
                
                // ボタン
                VStack(spacing: 12) {
                    Button {
                        showingCourseSelector = true
                    } label: {
                        Label("科目を追加", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    HStack(spacing: 12) {
                        if currentSemesterIndex > 0 {
                            Button("前へ") {
                                currentSemesterIndex -= 1
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Button(currentSemesterIndex < semesters.count - 1 ? "次へ" : "完了") {
                            if currentSemesterIndex < semesters.count - 1 {
                                currentSemesterIndex += 1
                            } else {
                                saveCredits()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
            .navigationTitle("📝 過去の単位登録")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCourseSelector) {
                CourseSelectorView(
                    semester: semesters[safe: currentSemesterIndex] ?? "",
                    selectedCourses: Binding(
                        get: { selectedCourses[semesters[safe: currentSemesterIndex] ?? ""] ?? [] },
                        set: { selectedCourses[semesters[safe: currentSemesterIndex] ?? ""] = $0 }
                    )
                )
            }
        }
    }
    
    /// 入学年度から現在までの学期リストを生成
    private func generateSemesters() -> [String] {
        guard let profile = viewModel.userProfile else { return [] }
        
        var semesters: [String] = []
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        // 現在の学期を判定
        let currentSemester = (currentMonth >= 3 && currentMonth <= 8) ? "前期" : "後期"
        
        // 入学年度から現在の学期までのリストを作成
        for year in profile.enrollmentYear...currentYear {
            if year == currentYear {
                // 現在年度は現在の学期まで
                semesters.append("\(year)-前期")
                if currentSemester == "後期" {
                    semesters.append("\(year)-後期")
                }
            } else {
                semesters.append("\(year)-前期")
                semesters.append("\(year)-後期")
            }
        }
        
        return semesters
    }
    
    private func removeCourse(_ course: String) {
        guard let semester = semesters[safe: currentSemesterIndex] else { return }
        selectedCourses[semester]?.removeAll { $0 == course }
    }
    
    private func saveCredits() {
        // 選択された科目を AcquiredCredit として保存
        var credits: [AcquiredCredit] = []
        
        for (semester, courses) in selectedCourses {
            for course in courses {
                let credit = AcquiredCredit(
                    courseName: course,
                    credits: 2, // デフォルト値、後で変更可能にする
                    difficulty: .medium,
                    category: "未分類", // 後で適切なカテゴリを設定
                    semester: semester,
                    isOverCredit: false
                )
                credits.append(credit)
            }
        }
        
        viewModel.addCreditsBatch(credits)
        // 登録完了後は自動的にメイン画面に遷移（isFirstLaunchがfalseになっているため）
    }
}

/// 科目選択シート
struct CourseSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    let semester: String
    @Binding var selectedCourses: [String]
    
    @State private var searchText = ""
    @State private var customCourseName = ""
    @State private var showingAddCustomCourse = false
    
    // サンプル科目リスト（実際はJSONから読み込む）
    private let availableCourses = [
        "Basic English I", "Basic English II", "Practical English I",
        "微分積分Ⅰ", "線形代数Ⅰ", "物理学",
        "化学", "生物学", "情報リテラシー"
    ]
    
    private var filteredCourses: [String] {
        if searchText.isEmpty {
            return availableCourses
        }
        return availableCourses.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showingAddCustomCourse = true
                    } label: {
                        Label("カスタム科目を追加", systemImage: "plus.circle")
                    }
                }
                
                Section {
                    ForEach(filteredCourses, id: \.self) { course in
                        Button {
                            toggleCourse(course)
                        } label: {
                            HStack {
                                Text(course)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedCourses.contains(course) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                } header: {
                    Text("科目一覧")
                }
            }
            .searchable(text: $searchText, prompt: "科目名で検索")
            .navigationTitle("\(semester)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
            .alert("カスタム科目を追加", isPresented: $showingAddCustomCourse) {
                TextField("科目名", text: $customCourseName)
                Button("追加") {
                    if !customCourseName.isEmpty {
                        selectedCourses.append(customCourseName)
                        customCourseName = ""
                    }
                }
                Button("キャンセル", role: .cancel) {
                    customCourseName = ""
                }
            }
        }
    }
    
    private func toggleCourse(_ course: String) {
        if let index = selectedCourses.firstIndex(of: course) {
            selectedCourses.remove(at: index)
        } else {
            selectedCourses.append(course)
        }
    }
}

// Array拡張: 安全な添字アクセス
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    CreditRegistrationView(viewModel: AppViewModel())
}
