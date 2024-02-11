//
//  StatsManager.swift
//  Moodthread
//
//  Created by AC on 1/21/24.
//

import UIKit

struct StatsManager {
    var data: Dictionary<[Int], [Array<Entry>.Element]>
    var fields: [ItemConfiguration]
    
//    init(data: Dictionary<[Int], [Array<Entry>.Element]>) {
    init(entries: [Entry]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd"
        data = Dictionary(grouping: entries) { dateFormatter.string(from: $0.time ?? Date()).split(separator: " ").map { Int($0) ?? 0 } }
        
        fields = []
        fields = extractFields(entries: entries)
    }
    
    func getStatsOptions() -> [(String, String)] {
        let options = getStatsOptions(for: Array(data.keys)).flatMap { $0 }
        
        var uniqueOptions = [(String, String)]()
        options.forEach { option in
            if !uniqueOptions.contains(where: {$0.0 == option.0 && $0.1 == option.1}) {
                uniqueOptions.append(option)
            }
        }
        
        return uniqueOptions
    }
    
    func getNumberStats(date: DateComponents, for stat: (String, String)) -> (v: Float, min: Float, max: Float)? {
        if(!["Average", "Highest", "Lowest"].contains(stat.1)) { return nil }
        let dateArray: [Int] = [date.year ?? 0, date.month ?? 0, date.day ?? 0]
        let dayEntries: [Entry] = data[dateArray] ?? []
        
        let configs: [NumberConfiguration] = dayEntries.compactMap {
            guard let config = $0.fields?.first(where: { $0.config.label == stat.0 })?.config as? NumberConfiguration else { return nil }
            return config
        }
        
        let options = getStatsOptions(for: [dateArray])[0]
        if !options.contains(where: {$0.0 == stat.0 && $0.1 == stat.1}) || dayEntries.count == 0 { return nil }
        
        let values: [Float] = dayEntries.flatMap {
            $0.fields?.compactMap {
                guard let config = $0.config as? NumberConfiguration else { return nil }
                if(config.label != stat.0) { return nil }
                return $0.extractFloat()
            } ?? []
        }
        
        // TO DO: fetch global max and min
        let max: Float = configs.max(by: { $0.maxValue < $1.maxValue })?.maxValue ?? 0
        let min: Float = configs.min(by: { $0.minValue < $1.minValue })?.minValue ?? 5
        
        if stat.1 == "Average" { return (values.reduce(0, +) / Float(values.count), min, max) }
        if stat.1 == "Highest" { return (values.max(by: { $0 < $1 }) ?? (max + min) / 2.0, min, max) }
        if stat.1 == "Lowest" { return (values.min(by: { $0 < $1 }) ?? (max + min) / 2.0, min, max) }
        
        return nil
    }
    
    func getBooleanStats(date: DateComponents, for stat: (String, String)) -> Bool {
        if(!["Recorded", "Always True", "Once True"].contains(stat.1)) { return false }
        let dateArray: [Int] = [date.year ?? 0, date.month ?? 0, date.day ?? 0]
        let dayEntries: [Entry] = data[dateArray] ?? []
        
        if stat.1 == "Recorded" {
            let values: [Bool] = dayEntries.flatMap {
                $0.fields?.compactMap {
                    if($0.config.label != stat.0) { return false }
                    return true
                } ?? []
            }
            return values.contains(true)
        }
        if stat.1 == "Always True" {
            let values: [Bool] = dayEntries.flatMap {
                $0.fields?.compactMap {
                    if($0.config.label != stat.0) { return nil }
                    return $0.extractBool()
                } ?? []
            }
            return values.allSatisfy({ $0 }) && values.count > 0
        }
        if stat.1 == "Once True" {
            let values: [Bool] = dayEntries.flatMap {
                $0.fields?.compactMap {
                    if($0.config.label != stat.0) { return nil }
                    return $0.extractBool()
                } ?? []
            }
            return values.contains(true) && values.count > 0
        }
        
        return false
    }
    
    private func getStatsOptions(for dates: [[Int]]) -> [[(String, String)]] {
        var options: [[(String, String)]] = []
        let sortedDates = sortDates(dates: dates)
        
        sortedDates.forEach { date in
            guard let dayData = data[date] else { return }
            
            let dayFields = extractFields(entries: dayData)
            var dayOptions = [(String, String)]()
            dayFields.forEach { field in
                switch(field.type) {
                case .binary:
                    dayOptions.append((field.label, "Always True"))
                    dayOptions.append((field.label, "Once True"))
                case .slider:
                    dayOptions.append((field.label, "Average"))
                    dayOptions.append((field.label, "Highest"))
                    dayOptions.append((field.label, "Lowest"))
//                case .select:
//                    break
//                case .multiSelect:
//                    break
                case .number:
                    dayOptions.append((field.label, "Average"))
                    dayOptions.append((field.label, "Highest"))
                    dayOptions.append((field.label, "Lowest"))
//                case .txt:
//                    break
                case .submit:
                    break
                default:
                    dayOptions.append((field.label, "Recorded"))
                }
            }
            options.append(dayOptions)
        }
        
        return options
    }
    
    private func sortDates(dates: [[Int]]) -> [[Int]] {
        return dates.sorted(by: {(a, b) -> Bool in
            if a[0] == b[0] && a[1] == b[1] {
                return a[2] < b[2]
            }
            return a[1] < b[1] || a[0] < b[0]
        })
    }
    
    private func extractFields(entries: [Entry]) -> [ItemConfiguration] {
        let allFields = entries.flatMap {
            ($0.fields ?? []).map { $0.config }
        }
        
        var uniqueFields = [ItemConfiguration]()
        allFields.forEach { field in
            if !uniqueFields.contains(where: {$0.label == field.label && $0.type == field.type }) {
                uniqueFields.append(field)
            }
        }
        
        return uniqueFields
    }
}
