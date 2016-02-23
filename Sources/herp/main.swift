import HerpKit
import Foundation

var options = Set<String>()
var files = [String]()

for arg in Process.arguments[1..<Process.arguments.count] {
    if arg.hasPrefix("-") {
        options.insert(arg)
    } else {
        files.append(arg)
    }

}

func herpProcess(
    fileHandle: NSFileHandle,
    printWord: Bool,
    printLocation: Bool
) {
    var data: NSData = fileHandle.availableData
    while data.length > 0 {
        if let content = String(data: data, encoding: NSUTF8StringEncoding) {
            let src = Source(text: content)
            for (word, position) in src {
                if printWord {
                    print(word, terminator: "")
                }
                if printLocation {
                    print(printWord ? " " : "", terminator: "")
                    print(
                        position.line,
                        position.start,
                        position.end - position.start,
                        terminator: ""
                    )
                }
                if (printLocation || printWord) {
                    print("")
                }
            }
        }
        data = fileHandle.availableData
    }
}

func herp(printWord printWord: Bool, printLocation: Bool) {
    if files.isEmpty {
        let input = NSFileHandle.fileHandleWithStandardInput()
        herpProcess(input, printWord: printWord, printLocation: printLocation)
    } else {
        for filePath in files {
            if let file = NSFileHandle(forReadingAtPath: filePath) {
                herpProcess(
                    file, printWord: printWord, printLocation: printLocation
                )
            }
        }
    }

}

let word = !options.contains("-W") && !options.contains("--noword")
let location = !options.contains("-L") && !options.contains("--nolocation")

if options.contains("-h") || options.contains("--help") {
    print("Help Extract Real Phrases\n")
    print("Finds possible English words from source code. Prints line, start and end")
    print("in-line position for each found word.\n")
    print("usage: herp [options] [file ...]\n")
    print("options:")
    print("\t-h --help          print this message")
    print("\t-W --noword        omit word")
    print("\t-L --nolocation    omit word location in file")
} else {
    herp(printWord: word, printLocation: location)
}
