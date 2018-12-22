import Foundation

func day20(part: Int, testMode: Bool, verboseMode: Bool) -> String {
	let input = testMode ? day20TestInput : day20Input

	var roomStats = (furthestRoom:0,number1000Away:0)
	for regex in parseDay20Input(input) {
		let newRegex = massageInput(regex)
		let map = constructMap(with:newRegex)
		roomStats = findFurthestMinimalPathlength(with: map)
		if verboseMode {
			renderMap(map)
		}
	}

	if part == 1 {
		return "\(roomStats.furthestRoom)"
	} else {
		return "\(roomStats.number1000Away)"
	}
}

func massageInput(_ input: String) -> String {
	// input contains lots of instances of (XXXX|) where XXXX has a zero delta
	// these can be reduced to simply XXXX and thus avoid a fork.

	var newInput = input
	let regex = Regex(pattern: "\\(([NSEW]+)\\|\\)")
	let submatches = regex.FindAllSubmatch(in: input)
	for sm in submatches {
		if pathDelta(for: sm[1]) == Coord(0,0) {
			newInput = newInput.replacingOccurrences(of: sm[0], with: sm[1])
		}
	}
	return newInput
}

func pathDelta(for path: String) -> Coord {
	var currentPos = Coord(0,0)
	for c in path {
		switch c {
			case "N":
			currentPos.y -= 1
			case "E":
			currentPos.x += 1
			case "S":
			currentPos.y += 1
			case "W":
			currentPos.x -= 1
			default:
			preconditionFailure("unexpected char in path for pathDelta: \(c)")
		}
	}
	return currentPos
}

func findFurthestMinimalPathlength(with map: [Coord:Character]) -> (furthestRoom:Int, number1000Away:Int) {
	// Starting at 0,0 move out along paths one step at a time.
	// If we hit somewhere we've been before then abandon that route

	var stepMap = [Coord:Int]()
	var currentPositions = [Coord(0,0)]
	var currentStep = 0
	var rooms1000DoorsAway = 0
	stepMap[currentPositions[0]] = currentStep

	while currentPositions.count > 0 {
		var nextPositions = [Coord]()
		for currentPos in currentPositions {
			var possibleNextSteps = [Coord]()
			if map[Coord(currentPos.x,currentPos.y-1)]! != "#" {
				possibleNextSteps.append(Coord(currentPos.x,currentPos.y-2))
			}
			if map[Coord(currentPos.x+1,currentPos.y)]! != "#" {
				possibleNextSteps.append(Coord(currentPos.x+2,currentPos.y))
			}
			if map[Coord(currentPos.x,currentPos.y+1)]! != "#" {
				possibleNextSteps.append(Coord(currentPos.x,currentPos.y+2))
			}
			if map[Coord(currentPos.x-1,currentPos.y)]! != "#" {
				possibleNextSteps.append(Coord(currentPos.x-2,currentPos.y))
			}
			for pns in possibleNextSteps {
				if stepMap[pns] == nil {
					if currentStep >= 999 {
						rooms1000DoorsAway += 1
					}
					stepMap[pns] = currentStep + 1
					nextPositions.append(pns)
				}
			}
		}
		currentPositions = nextPositions
		currentStep += 1
	}

	return (currentStep-1,rooms1000DoorsAway)
}


func renderMap(_ map: [Coord:Character]) {
	let (minGridExtent, maxGridExtent) = getExtents(from:Array(map.keys))
	
	for y in minGridExtent.y...maxGridExtent.y {
		for x in minGridExtent.x...maxGridExtent.x {
			print(map[Coord(x,y), default: " "], terminator: "")
		}
		print()
	}
}
func constructMap(with regex: String) -> [Coord:Character] {

	var map = [Coord:Character]()
	let currentPos = Coord(0,0)
	updateMapForNewRoomAt(currentPos, in: &map)

	followPath([Character](regex), fromOffset: 0, fromPosition: currentPos, in: &map)

	// override zero pos with X
	map[Coord(0,0)] = "X"
	// convert any unknowns to walls
	for (c,char) in map {
		if char == "?" {
			map[c] = "#"
		}
	}
	return map
}
func followPath(_ chars: [Character], fromOffset offset: Int, fromPosition pos: Coord, in map: inout [Coord:Character]) {

	var currentPos = pos
	var i = offset
	var forkPoints = [Int]()
	while i < chars.count {
		let char = chars[i]

		if char == "N" || char == "E" || char == "S" || char == "W" {
			switch char {
				case "N":
				map[Coord(currentPos.x,currentPos.y-1)] = "-"
				currentPos.y -= 2
				case "E":
				map[Coord(currentPos.x+1,currentPos.y)] = "|"
				currentPos.x += 2
				case "S":
				map[Coord(currentPos.x,currentPos.y+1)] = "-"
				currentPos.y += 2
				case "W":
				map[Coord(currentPos.x-1,currentPos.y)] = "|"
				currentPos.x -= 2
				default:
				break
			}
			updateMapForNewRoomAt(currentPos, in: &map)
			i += 1
		} else if char == "(" {

			// fork
			// find fork points - these come immediately after ( or | at this forking depth
			var currentDepth = 0
			repeat {
				let forkchar = chars[i]
				i += 1
				if forkchar == "(" {
					currentDepth += 1
				}
				if forkchar == ")" {
					currentDepth -= 1
				}
				if currentDepth == 1 && (forkchar == "(" || forkchar == "|") {
					forkPoints.append(i)
				}
			} while currentDepth > 0
			break

		} else if char == "|" {
			// end of current branch - skip to end of fork options
			var currentDepth = 1
			repeat {
				let branchchar = chars[i]
				i += 1
				if branchchar == "(" {
					currentDepth += 1
				}
				if branchchar == ")" {
					currentDepth -= 1
				}
			} while currentDepth > 0

		} else if char == ")" {
			// end of a set of forks. just continue
			i += 1
		} else {
			preconditionFailure("unhandled character \(char)")
		}

	}

	for fp in forkPoints {
		followPath(chars, fromOffset: fp, fromPosition: currentPos, in: &map)
	}
}

func updateMapForNewRoomAt(_ room: Coord, in map: inout [Coord:Character]) {
		// mark that we're in a room
		map[room] = "."
		// mark all corners as walls
		for n in getDiagonalNeighbours(for: room) {
			map[n] = "#"
		}
		// mark all NESW positions as unknowns unless already determined
		for n in getOrthogonalNeighbours(for: room) {
			if map[n] == nil {
				map[n] = "?"
			}
		}
}

func getOrthogonalNeighbours(for centre: Coord) -> [Coord] {
	return [
		Coord(centre.x,   centre.y-1),
		Coord(centre.x-1, centre.y),
		// Coord(centre.x,   centre.y),
		Coord(centre.x+1, centre.y),
		Coord(centre.x,   centre.y+1),
	]
}
func getDiagonalNeighbours(for centre: Coord) -> [Coord] {
	return [
		Coord(centre.x-1, centre.y-1),
		Coord(centre.x+1, centre.y-1),
		// Coord(centre.x,   centre.y),
		Coord(centre.x-1, centre.y+1),
		Coord(centre.x+1, centre.y+1),
	]
}


func parseDay20Input(_ input: String) -> [String] {

	return input.split(separator: "\n").map {
		$0.trimmingCharacters(in: CharacterSet(charactersIn: "^$"))
	}

}

