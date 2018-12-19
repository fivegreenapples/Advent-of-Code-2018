func day18(part: Int, testMode: Bool, verboseMode: Bool) -> String {
	let input = testMode ? day18TestInput : day18Input

	var currentArea = parseDay18Input(input)
	if verboseMode {
		renderArea(currentArea)
	}

	if part == 1 {
		for _ in 1...10 {
			currentArea = runOneMinute(forArea: currentArea)
			if verboseMode {
				renderArea(currentArea)
				print()
			}
		}
	} else {

		// keep running until we spot a repeat
		var seenAreaPatterns = [[Coord:AcreType]:Int]()
		var currentMinute = 0
		repeat {
			seenAreaPatterns[currentArea] = currentMinute
			currentArea = runOneMinute(forArea: currentArea)
			if verboseMode {
				renderArea(currentArea)
				print()
			}
			currentMinute += 1
		} while seenAreaPatterns[currentArea] == nil

		let repeatingPeriod = currentMinute - seenAreaPatterns[currentArea]!
		let surplusMinutesAfterAllRepeats = (1000000000-currentMinute) % repeatingPeriod

		if verboseMode {
			print("Repeating period is \(repeatingPeriod) minutes, leaving \(surplusMinutesAfterAllRepeats) minutes to run")
		}

		for _ in 1...surplusMinutesAfterAllRepeats {
			currentArea = runOneMinute(forArea: currentArea)
		}
		if verboseMode {
			renderArea(currentArea)
			print()
		}
	}

	let treeCount = currentArea.count(where: { (_,typ) in 
		typ == .Trees
	})
	let lumberCount = currentArea.count(where: { (_,typ) in 
		typ == .LumberYard
	})

	return "\(treeCount * lumberCount)"

}

func runOneMinute(forArea input: [Coord:AcreType]) -> [Coord:AcreType] {
	var convertedArea = [Coord:AcreType]()
	for (pos, type) in input {

		let neighbours = getNeighbourPositions(for: pos)
		let treeCount = neighbours.count(where: { pos in 
			input[pos] != nil && input[pos]! == .Trees
		})
		let lumberCount = neighbours.count(where: { pos in 
			input[pos] != nil && input[pos]! == .LumberYard
		})

		switch type {
			case .LumberYard:
				convertedArea[pos] = lumberCount >= 1 && treeCount >= 1 ? .LumberYard : .Open
			case .Trees:
				convertedArea[pos] = lumberCount >= 3 ? .LumberYard : .Trees
			case .Open:
				convertedArea[pos] = treeCount >= 3 ? .Trees : .Open
		}
	}

	return convertedArea

}

func getNeighbourPositions(for centre: Coord) -> [Coord] {
	return [
		Coord(centre.x-1, centre.y-1),
		Coord(centre.x,   centre.y-1),
		Coord(centre.x+1, centre.y-1),
		Coord(centre.x-1, centre.y),
		// Coord(centre.x,   centre.y),
		Coord(centre.x+1, centre.y),
		Coord(centre.x-1, centre.y+1),
		Coord(centre.x,   centre.y+1),
		Coord(centre.x+1, centre.y+1),
	]
}


func renderArea(_ area: [Coord:AcreType]) {

	let (minGridExtent, maxGridExtent) = getExtents(from:Array(area.keys))
	
	for y in minGridExtent.y...maxGridExtent.y {
		for x in minGridExtent.x...maxGridExtent.x {
			let toPrint: Character
			if let g = area[Coord(x,y)] {
				toPrint = g.rawValue
			} else {
				toPrint = "."
			}
			print(toPrint, terminator: "")
		}
		print()
	}



}

func parseDay18Input(_ input:String) -> [Coord:AcreType] {
	let lines = input.split(separator: "\n")
	// .#.#...|#.
	// .....#|##|

	var area = [Coord:AcreType]()
	for (y,line) in lines.enumerated() {
		for (x,char) in line.enumerated() {
			area[Coord(x,y)] = AcreType(rawValue: char)
		}
	}

	return area
}

enum AcreType: Character {
	case Open = "."
	case Trees = "|"
	case LumberYard = "#"
}