import Foundation

class Regex {
	let regex: NSRegularExpression
	init(pattern: String) {
		self.regex = try! NSRegularExpression(pattern: pattern)
	}

	func FindSubmatch<T: StringProtocol>(in input: T) -> [String] {
		let myInput = String(input)
		guard let firstMatch = self.regex.firstMatch(in: myInput, options: [], range: NSMakeRange(0, input.count)) else {
			return []
		}

		var submatches = [String]()
		for i in 0..<firstMatch.numberOfRanges {
			if let thisRange = Range(firstMatch.range(at: i), in:myInput) {
				submatches.append(String(myInput[thisRange]))
			} else {
				submatches.append("")
			}
		}

		return submatches
	}
}

func getExtents(from: [Coord]) -> (min: Coord, max: Coord) {
	let min = from.reduce(Coord(Int.max,Int.max), { current, next in 
		return Coord(
			next.x < current.x ? next.x : current.x,
			next.y < current.y ? next.y : current.y
		)
	})
	let max = from.reduce(Coord(0,0), { current, next in 
		return Coord(
			next.x > current.x ? next.x : current.x,
			next.y > current.y ? next.y : current.y
		)
	})
	return (min, max)
}
