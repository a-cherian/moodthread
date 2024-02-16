//
//  LineChartView.swift
//  Moodthread
//
//  Created by AC on 2/14/24.
//

import SwiftUI
import Charts

struct Dataset: Identifiable {
    let id = UUID()
    
    let field: String
    let stat: String
    let data: [DataPoint]
}

struct DataPoint: Identifiable {
    var id = UUID()
    
    let num: Float
    let date: Date
    
    init(num: Float = 0, date: Date = Date()) {
        self.num = num
        self.date = date
    }
}

class Option: /*Identifiable, Hashable*/ObservableObject {
    //    var id = UUID()
    
    @Published var field: String = ""
    @Published var stat: String = ""
    @Published var active: Bool = false
    
    init(field: String, stat: String, active: Bool = true) {
        self.field = field
        self.stat = stat
        self.active = active
    }
    
    func reloadView() {
        objectWillChange.send()
    }
}

struct LineChartView: View {
    var statsManager: StatsManager = StatsManager(entries: [], dates: [])
    var minDate: Date = Date()
    var maxDate: Date = Date()
    var minValue: Float? = nil
    var maxValue: Float? = nil
    var options: [(String, [String])] = []
    var fixedField: String? = nil
    
    @ObservedObject var option1: Option = Option(field: "Mood", stat: "Average", active: true)
    @ObservedObject var option2: Option = Option(field: "Mood", stat: "Lowest", active: true)
    @ObservedObject var option3: Option = Option(field: "Mood", stat: "Highest", active: true)
    
    var activeOptions: [Option] {
        return [option1, option2, option3].compactMap { option in
            if(!option.active) { return nil }
            return option
        }
    }
    var datasets: [Dataset] {
        return activeOptions.compactMap { option in
            if(!option.active) { return nil }
            if(option.field == "" || option.stat == "") { return nil}
            if(!StatsManager.numberStats.contains(option.stat)) { return nil }
            return Dataset(field: option.field, stat: option.stat, data: statsManager.getNumberStats(for: (option.field, option.stat)).map{ DataPoint(num: $0.v, date: $0.date) })
        }
    }
    
    init(statsManager: StatsManager, fixedField: String? = nil) {
        self.statsManager = statsManager
        
        let statsOptions = statsManager.getStatsOptions(statFilter: StatsManager.numberStats)
        options = [(String, [String])]()
        statsOptions.forEach { option in
            let index = options.firstIndex(where: { $0.0 == option.0 })
            if let index = index {
                options[index].1.append(option.1)
            }
            else { options.append((option.0, [option.1])) }
        }

        if let minDate = statsManager.dates?.first { self.minDate = Calendar.current.date(from: minDate) ?? Date() }
        else { self.minDate = datasets[0].data.map { $0.date }.min() ?? Date() }

        if let maxDate = statsManager.dates?.last { self.maxDate = Calendar.current.date(from: maxDate) ?? Date() }
        else { self.maxDate = datasets[0].data.map { $0.date }.max() ?? Date() }
        
        self.minValue = nil
        self.maxValue = nil
        self.fixedField = fixedField
        
        if let field = fixedField {
            option1 = Option(field: field, stat: "Average", active: true)
            option2 = Option(field: field, stat: "Lowest", active: true)
            option3 = Option(field: field, stat: "Highest", active: true)
        }
        else {
            let defValue = options.first(where: { $0.0 != "Mood" && $0.0 != "Energy" }) ?? (("Mood", ["Average", "Lowest", "Highest"]))
            option1 = Option(field: defValue.0, stat: defValue.1[0 % defValue.1.count], active: true)
            option2 = Option(field: defValue.0, stat: defValue.1[1 % defValue.1.count], active: false)
            option3 = Option(field: defValue.0, stat: defValue.1[2 % defValue.1.count], active: false)
        }
    }
    
    var body: some View {
        if(fixedField == nil) {
//            Text("Custom Comparison Chart")
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
            VStack(spacing: 10) {
                if(option1.active) {
                    HStack {
                        Picker("Field", selection: $option1.field) {
                            ForEach(options.map { $0.0 }, id: \.self) {
                                Text($0.count < 8 ? $0 : $0.prefix(8) + "...").tag($0)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .clipped()
                        
                        Picker("Stat", selection: $option1.stat) {
                            ForEach(options.first(where: {$0.0 == option1.field})?.1 ?? [], id: \.self) {
                                Text($0.count < 8 ? $0 : $0.prefix(8) + "...").tag($0)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .clipped()
                        
                        HidableButton(hideIf: true, img: "plus", action: { option2.active = true })
                        HidableButton(hideIf: option2.active, img: "plus", action: { option2.active = true })
                    }
                    .frame(maxHeight: 30)
                }
                
                if(option2.active) {
                    HStack {
                        Picker("Field", selection: $option2.field) {
                            ForEach(options.map { $0.0 }, id: \.self) {
                                Text($0.count < 8 ? $0 : $0.prefix(8) + "...").tag($0)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .clipped()
                        
                        Picker("Stat", selection: $option2.stat) {
                            ForEach(options.first(where: {$0.0 == option2.field})?.1 ?? [], id: \.self) {
                                Text($0.count < 8 ? $0 : $0.prefix(8) + "...").tag($0)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .clipped()
                        
                        HidableButton(hideIf: option3.active, img: "minus", action: { option2.active = false })
                        HidableButton(hideIf: option3.active, img: "plus", action: { option3.active = true })
                    }
                    .frame(maxHeight: 30)
                }
                
                
                if(option3.active) {
                    HStack {
                        Picker("Field", selection: $option3.field) {
                            ForEach(options.map { $0.0 }, id: \.self) {
                                Text($0.count < 8 ? $0 : $0.prefix(8) + "...").tag($0)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .clipped()
                        
                        Picker("Stat", selection: $option3.stat) {
                            ForEach(options.first(where: {$0.0 == option3.field})?.1 ?? [], id: \.self) {
                                Text($0.count < 8 ? $0 : $0.prefix(8) + "...").tag($0)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .clipped()
                        
                        HidableButton(hideIf: !option3.active, img: "minus", action: { option3.active = false })
                        HidableButton(hideIf: true, img: "minus", action: { option3.active = false })
                    }
                    .frame(maxHeight: 30)
                }
            }
            .frame(minHeight: 120)
        }
            
        else {
            VStack(spacing: 10) {
                Text(fixedField ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
                HStack() {
                    Button(option1.stat, systemImage: option1.active ? "eye" : "eye.slash", action: { option1.active = !option1.active })
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15))
                    Button(option2.stat, systemImage: option2.active ? "eye" : "eye.slash", action: { option2.active = !option2.active })
                    //                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    Button(option3.stat, systemImage: option3.active ? "eye" : "eye.slash", action: { option3.active = !option3.active })
                        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
                }
            }
        }
        
        Chart(datasets) { dataset in
            ForEach(Array(dataset.data.enumerated()), id: \.offset) { index, point in
                let fieldText = (dataset.field.count < 8 ? dataset.field : dataset.field.prefix(5) + "...") + " " + dataset.stat
                LineMark(
                    x: .value("Day", point.date),
                    y: .value("Value", point.num)
                )
                .foregroundStyle(by: .value("Stat", fieldText))
                PointMark(
                    x: .value("Day", point.date),
                    y: .value("Value", point.num)
                )
                .foregroundStyle(by: .value("Stat", fieldText))
            }
        }
        .chartXScale(domain: minDate...maxDate)
        .chartXAxis {
            AxisMarks(values: .automatic) { date in
                AxisValueLabel(format: Date.FormatStyle().month(.defaultDigits).day())
            }
        }
        .chartYAxis {
//            AxisMarks(format: Decimal.FormatStyle.Percent.percent.scale(1), .automatic(desiredCount: 4)) {
//                AxisGridLine()
//            }
            AxisMarks(values: .automatic) {
                AxisValueLabel()
                AxisGridLine()
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, minHeight: 300)
        .aspectRatio(13/9, contentMode: .fit)
    }
    
    func HidableButton(hideIf: Bool, img: String, action: @escaping () -> Void) -> some View {
        let shown = !hideIf && fixedField == nil
        let button = Button("", systemImage: img, action: action)
        .opacity(shown ? 1 : 0) // Make it invisibile
        .allowsHitTesting(shown) // Disable user interaction
        return button
    }
}
