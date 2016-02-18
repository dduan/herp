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

func herpLine(
    line: String,
    lineNumber: Int,
    printWord: Bool,
    printLocation: Bool
) {
    let src = Source(text: line)
    for (word, position) in src {
        if printWord {
            print(word, terminator: "")
        }
        if printLocation {
            print(printWord ? " " : "", terminator: "")
            print(lineNumber, position.start, position.end, terminator: "")
        }
        if (printLocation || printWord) {
            print("")
        }
    }
}

func herp(printWord printWord: Bool, printLocation: Bool) {
    if files.isEmpty {
        var line = 0
        while let s = readLine(stripNewline: false) {
            herpLine(
                s,
                lineNumber: line,
                printWord: printWord,
                printLocation: printLocation
            )
            line += 1
        }
    } else {
        let nlSet = NSCharacterSet.newlineCharacterSet()
        for file in files {
            do {
                var line = 0
                let content = try NSString(
                    contentsOfFile: file,
                    encoding: NSUTF8StringEncoding
                )
                for s in content.componentsSeparatedByCharactersInSet(nlSet) {
                    herpLine(
                        s,
                        lineNumber: line,
                        printWord: printWord,
                        printLocation: printLocation
                    )
                    line += 1

                }
            } catch {
                print("herp: [error] can't open file \(file)")
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
