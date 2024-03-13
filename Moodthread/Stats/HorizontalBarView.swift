//
//  HorizontalBarView.swift
//  Moodthread
//
//  Created by AC on 2/15/24.
//

import SwiftUI
import Charts

struct BoolData: Identifiable {
    var id = UUID()
    
    let stat: String
    let type: String
    let count: Int
}

struct HorizontalBarView: View {

    var stats = [String]()
    
    var field: String = ""
    
    var datasets: [BoolData] = []
    
    init(statsManager: StatsManager, field: String) {
        let statsOptions = statsManager.getStatsOptions(statFilter: StatsManager.booleanStats)
        self.field = field
        self.stats = statsOptions.filter { $0.0 == field }.map { $0.1 }
        self.datasets = stats.flatMap { stat in
            let data = statsManager.getBooleanStats(for: (field, stat)).map{ $0.v }
            let trueCount = data.filter { $0 }.count
            let falseCount = data.count - trueCount
            return [BoolData(stat: stat, type: "True", count: trueCount), BoolData(stat: stat, type: "False", count: falseCount)]
        }
    }
    
    var body: some View {
        Text(field)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
        Chart(datasets) { dataset in
            BarMark(
                x: .value("Count", dataset.count),
                y: .value("Stat", dataset.stat)
            )
            .foregroundStyle(by: .value("Type", dataset.type))
        }
        .chartForegroundStyleScale(
            domain: ["True", "False"],
            range: [.green, .red]
        )
        .chartXAxis {}
        .chartYAxis {
            AxisMarks(values: .automatic) { date in
                AxisValueLabel()
            }
        }
        .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 15))
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}
