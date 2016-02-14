
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

    var state = ParseState.NonAlpha

    var content: [Character]
    var ranges: [(Int, Int)] = []

    var count: Int {
        return ranges.count
    }
    func word(i: Int) -> String {
        let range = ranges[i]
        return String(content[range.0..<range.1])
    }
    public init(text: String) {
        var start: Int = 0
        content = Array(text.characters)
        let count = content.count
        for (i, c) in content.enumerate() {
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
                    ranges.append((start, i))
                    state = .NonAlpha
                } else if c.isUpper && i < count - 1 {
                    if content[i + 1].isLower {
                        ranges.append((start, i))
                        start = i
                    }
                }
            case .Head:
                if !c.isAlpha {
                    ranges.append((start, i))
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
                        ranges.append((start, i))
                        start = i
                        if next.isUpper {
                            state = .UpperCase
                        } else if next.isLower {
                            state = .Head
                        }
                    }
                } else {
                    ranges.append((start, i))
                    state = .NonAlpha
                }
            }
        }
        if state != .NonAlpha {
            ranges.append((start, count))
        }
    }
}

extension Source: SequenceType {
    public func generate() -> AnyGenerator<(String, Int, Int)> {
        var nextIndex = 0
        return AnyGenerator {
            if nextIndex >= self.count {
                return nil
            }
            let r = (
                self.word(nextIndex),
                self.ranges[nextIndex].0,
                self.ranges[nextIndex].1
            )
            nextIndex += 1
            return r
        }
    }
}
