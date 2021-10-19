//
//  VMaxAdsLogger.swift

import Foundation

enum VMaxLogType: String {
    case debug
    case error
    case info
    case verbose
    case warning
    case severe
}

let seprator = ": "
let tag = "VMaxZeeAdsPlugin"

func vmLog(_ mes: String, _ type: VMaxLogType = .info, lNo: Int = #line, fun: String = #function, file: String = #file) {
    let dateTimeTagLogType = getDate() + seprator + tag + seprator + "[" + type.rawValue.uppercased() + "]" + seprator
    let fileFunctionLineInfo = getFileName(fileName: file) + seprator + fun + seprator + String(describing: lNo)
    let messageToPrint = mes.isEmpty ? mes: seprator + mes
    print("\(dateTimeTagLogType)\(fileFunctionLineInfo)\(messageToPrint)")
}

func getFileName(fileName: String) -> String {
    let notFound = "notFound"
    guard let url = URL(string: fileName) else {
        return notFound
    }
    guard let fileName = url.lastPathComponent.components(separatedBy: ".").first else {
        return notFound + "."
    }
    return fileName
}

func getDate() -> String {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "y-MM-dd H:mm:ss.SSSS"
    return dateFormat.string(from: Date())
}
