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
        if semesters.isEmpty {
            // 1年生など、登録する学期がない場合は自動的にスキップ
            // (この画面は表示されず、ContentViewがMainTabViewを表示)
            EmptyView()
        } else {
            NavigationStack {
                VStack {
                    // 学期の進捗表示
                    VStack(spacing: 8) {
                        ProgressView(value: Double(currentSemesterIndex + 1), total: Double(semesters.count))
                            .padding(.horizontal)
                        
                        Text("\(semesters[currentSemesterIndex])")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("履修した科目を選択してください")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGroupedBackground))
                    
                    // 選択済み科目のリスト
                    if let courses = selectedCourses[semesters[currentSemesterIndex]], !courses.isEmpty {
                        List {
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
                        }
                    } else {
                        Spacer()
                        ContentUnavailableView(
                            "履修科目なし",
                            systemImage: "book.closed",
                            description: Text("この学期に履修した科目がない場合は\n「スキップ」ボタンで次へ進んでください")
                        )
                        Spacer()
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
                            
                            Button("スキップ") {
                                moveToNextSemester()
                            }
                            .buttonStyle(.bordered)
                            
                            Button(currentSemesterIndex < semesters.count - 1 ? "次へ" : "完了") {
                                moveToNextSemester()
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
                        semester: semesters[currentSemesterIndex],
                        selectedCourses: Binding(
                            get: { selectedCourses[semesters[currentSemesterIndex]] ?? [] },
                            set: { selectedCourses[semesters[currentSemesterIndex]] = $0 }
                        )
                    )
                }
            }
        }
    }
    
    /// 入学年度から現学年の直前の学期までのリストを生成
    private func generateSemesters() -> [String] {
        guard let profile = viewModel.userProfile else { return [] }
        
        var semesters: [String] = []
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        // 現在の学期を判定（3月〜8月: 前期、9月〜2月: 後期）
        let isCurrentSemesterZenki = (currentMonth >= 3 && currentMonth <= 8)
        
        // 1年生の場合、過去の単位登録は不要
        if profile.currentGrade == 1 {
            return []
        }
        
        // 入学年度から現学年の直前の学期までを計算
        let startYear = profile.enrollmentYear
        let endYear: Int
        let includeZenkiOfEndYear: Bool
        
        // 現在の学年に基づいて、登録すべき最後の学期を決定
        if profile.currentGrade == 2 {
            // 2年生：1年次の単位を登録
            endYear = startYear
            includeZenkiOfEndYear = true // 1年後期まで
        } else if profile.currentGrade == 3 {
            // 3年生：1-2年次の単位を登録
            endYear = startYear + 1
            includeZenkiOfEndYear = true // 2年後期まで
        } else {
            // 4年生：1-3年次の単位を登録
            endYear = startYear + 2
            includeZenkiOfEndYear = true // 3年後期まで
        }
        
        // 学期リストを生成
        for year in startYear...endYear {
            if year == endYear {
                semesters.append("\(year)-前期")
                if includeZenkiOfEndYear {
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
        let semester = semesters[currentSemesterIndex]
        selectedCourses[semester]?.removeAll { $0 == course }
    }
    
    private func moveToNextSemester() {
        if currentSemesterIndex < semesters.count - 1 {
            currentSemesterIndex += 1
        } else {
            saveCredits()
        }
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
        // 保存完了後、isFirstLaunchがfalseになるので自動的にMainTabViewに遷移
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
