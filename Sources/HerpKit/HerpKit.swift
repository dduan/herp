
extension Character {
    var isUpper: Bool { return self >= "A" && self <= "Z" }
    var isLower: Bool { return self >= "a" && self <= "z" }
    var isAlpha: Bool { return isUpper || isLower }
}

/*
               !isAlpha                       isUpper & peek().isUpper
               +------+                              +-------+
               |      |                              |       |
               |      |                              |       |
               |      |                              |       |
               |      v            !isAlpha          |       v
             +----------+ <----------------------+ +-----------+
             | NonAlpha |                          | UpperCase |
             +----------+ -----------------------> +-----------+ ------+
               |  ^   ^   isUpper & peek().isUpper           ^         |
               |  |   |                                      |         |
               |  +----------------------------------+       |         |
               |      |                              |       |         |
  isLower |    |      |                              |       |         |
  isUpper &    +      |!isAlpha              !isAlpha|       |         |
  peek().isLower |    |                              |       |         |
  isUpper      +      |                              |       |         |
               |      |                              |       |         |
               |      |                              |       |         |
               v      |   isUpper & peek().isLower   |       |         |
             +----------+ <----------------------- +-----------+       |
             |   Head   |                          |   Tail    |       |
             +----------+ -----------------------> +-----------+       |
                      ^           isLower            |       ^         |
                      |                              |       |         |
                      |                              |       |         |
                      |                              |       |         |
                      |                              +-------+         |
                      |                               isLower          |
                      |                                                |
                      +------------------------------------------------+
                                  isUpper & peek().isLower
*/

public struct Source {

    enum ParseState {
        case NonAlpha
        case UpperCase
        case Head
        case LowerTail
    }

    public struct WordPosition {
        public let start: Int
        public let end: Int
        public let line: Int
        public var length: Int {
            return end - start
        }
        public var range: Range<Int> {
            return start..<end
        }
        init(_ start: Int, _ end: Int, _ line: Int) {
            self.start = start
            self.end = end
            self.line = line
        }
    }

    var state = ParseState.NonAlpha

    var content: [Character]
    var ranges: [WordPosition] = []

    var count: Int {
        return ranges.count
    }

    func word(i: Int) -> String {
        let range = ranges[i]
        return String(content[range.range])
    }

    func word(position: WordPosition) -> String {
        return String(content[position.range])
    }

    public init(text: String) {
        var start: Int = 0
        var lineCount = 0
        content = Array(text.characters)
        let count = content.count
        for (i, c) in content.enumerate() {
            if c == "\n" { lineCount += 1 }

            switch state {
            case .NonAlpha:
                if !c.isAlpha { continue }
                start = i
                if c.isLower {
                    state = .Head
                } else {
                    if i < count - 1 {
                        let next = content[i+1]
                        if next.isUpper {
                            state = .UpperCase
                        } else if next.isLower {
                            state = .Head
                        }
                    } else if c.isUpper {
                        state = .Head
                    }
                }
            case .UpperCase:
                if !c.isAlpha {
                    ranges.append(WordPosition(start, i, lineCount))
                    state = .NonAlpha
                } else if c.isUpper && i < count - 1 {
                    if content[i + 1].isLower {
                        ranges.append(WordPosition(start, i, lineCount))
                        start = i
                    }
                }
            case .Head:
                if !c.isAlpha {
                    ranges.append(WordPosition(start, i, lineCount))
                    state = .NonAlpha
                } else if c.isLower {
                    state = .LowerTail
                }
            case .LowerTail:
                if c.isLower {
                    continue
                } else if c.isUpper {
                    if i < count - 1 {
                        let next = content[i+1]
                        ranges.append(WordPosition(start, i, lineCount))
                        start = i
                        if next.isUpper {
                            state = .UpperCase
                        } else if next.isLower {
                            state = .Head
                        }
                    }
                } else {
                    ranges.append(WordPosition(start, i, lineCount))
                    state = .NonAlpha
                }
            }
        }
        if state != .NonAlpha {
            ranges.append(WordPosition(start, count, lineCount))
        }
    }
}

extension Source: SequenceType {
    public func generate() -> AnyGenerator<(String, WordPosition)> {
        var nextIndex = 0
        return AnyGenerator {
            if nextIndex >= self.count {
                return nil
            }
            let r = (
                self.word(nextIndex),
                self.ranges[nextIndex]
            )
            nextIndex += 1
            return r
        }
    }
}
