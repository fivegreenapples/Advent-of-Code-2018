func day17(part: Int, testMode: Bool, verboseMode: Bool) -> String {
	let input = testMode ? day17TestInput : day17Input

	let clay = parseDay17Input(input)

	var underGroundGrid = [Coord:GroundType]()
	for c in clay {
		underGroundGrid[c] = .Clay
	}

	let spring = Coord(500,0)
	flowWater(from: spring, into: &underGroundGrid)
	renderGround(with:underGroundGrid)

	if part == 1 {
		let totalWetAndWater = underGroundGrid.count(where: { _, type in
			type == .Water || type == .WetSoil
		})
		return "\(totalWetAndWater)"
	}

	let totalWater = underGroundGrid.count(where: { _, type in
		type == .Water
	})
	return "\(totalWater)"

}

func flowWater(from source: Coord, into ground: inout [Coord:GroundType]) {

	let (minGridExtent, maxGridExtent) = getExtents(from:Array(ground.keys))

	// find start of vertical stream that we care about
	var start = source
	if start.y < minGridExtent.y {
		start.y = minGridExtent.y
	}

	// falling mode
	var currentPos = start
	var hitHorizontalBoundary = false
	while currentPos.y <= maxGridExtent.y && !hitHorizontalBoundary {
		if let groundType = ground[currentPos] {
			switch groundType {
				case .Clay, .Water: // hit clay or water, need to spread horizontally
				hitHorizontalBoundary = true
				case .WetSoil: // wet soil, previous water flows have convered this. so abandon
				return
			}
		} else {
			// mark soil as wet and keep falling
			ground[currentPos] = .WetSoil
			currentPos.y += 1
		}
	}

	if !hitHorizontalBoundary {
		return
	}

	// fill mode
	repeat {
		// backup one
		currentPos.y -= 1
		// look left and right for a boundary while keeping a "foundation" boundary below
		var foundLeftBoundary: Coord?
		var foundRightBoundary: Coord?
		// first go left
		var boundarySearchPos = currentPos
		repeat {
			let foundation = ground[Coord(boundarySearchPos.x,boundarySearchPos.y+1)]
			if foundation == nil || foundation! == .WetSoil {
				// abandon search - convert to flow mode
				break
			}
			let boundary = ground[Coord(boundarySearchPos.x-1,boundarySearchPos.y)]
			if boundary != nil && boundary! == .Clay {
				// abandon search, found a boundary
				foundLeftBoundary = Coord(boundarySearchPos.x-1,boundarySearchPos.y)
				break
			}
			boundarySearchPos.x -= 1
		} while true

		if foundLeftBoundary != nil {
			// now go right
			var boundarySearchPos = currentPos
			repeat {
				let foundation = ground[Coord(boundarySearchPos.x,boundarySearchPos.y+1)]
				if foundation == nil || foundation! == .WetSoil {
					// abandon search - convert to flow mode
					break
				}
				let boundary = ground[Coord(boundarySearchPos.x+1,boundarySearchPos.y)]
				if boundary != nil && boundary! == .Clay {
					// abandon search, found a boundary
					foundRightBoundary = Coord(boundarySearchPos.x+1,boundarySearchPos.y)
					break
				}
				boundarySearchPos.x += 1
			} while true
		}

		if foundLeftBoundary != nil && foundRightBoundary != nil {
			// found boundaries so fill with water
			for x in (foundLeftBoundary!.x+1)..<foundRightBoundary!.x {
				ground[Coord(x, currentPos.y)] = .Water
			}
		} else {
			break
		}
	} while true


	// flow horizontal mode
	var newSources = [Coord]()
	// first flow left
	var flowPos = currentPos
	repeat {
		let foundation = ground[Coord(flowPos.x,flowPos.y+1)]
		if foundation == nil {
			// flowed over dry soil. this is a new source
			newSources.append(flowPos)
			// abandon flow
			break
		} else {
			ground[Coord(flowPos.x, flowPos.y)] = .WetSoil
			if foundation! == .WetSoil {
				// abandon flow
				break
			}
			let boundary = ground[Coord(flowPos.x-1,flowPos.y)]
			if boundary != nil && boundary! == .Clay {
				// abandon flow, found a boundary
				break
			}
		}
		flowPos.x -= 1
	} while true
	// now flow right
	flowPos = currentPos
	repeat {
		let foundation = ground[Coord(flowPos.x,flowPos.y+1)]
		if foundation == nil {
			// flowed over dry soil. this is a new source
			newSources.append(flowPos)
			// abandon flow
			break
		} else {
			ground[Coord(flowPos.x, flowPos.y)] = .WetSoil
			if foundation! == .WetSoil {
				// abandon flow
				break
			}
			let boundary = ground[Coord(flowPos.x+1,flowPos.y)]
			if boundary != nil && boundary! == .Clay {
				// abandon flow, found a boundary
				break
			}
		}
		flowPos.x += 1
	} while true


	for newS in newSources {
		print("flowing",newS)
		flowWater(from: newS, into: &ground)
	}


}

func renderGround(with clay: [Coord:GroundType]) {

	let (minGridExtent, maxGridExtent) = getExtents(from:Array(clay.keys))

	for y in minGridExtent.y...maxGridExtent.y {
		for x in minGridExtent.x...maxGridExtent.x {
			let toPrint: Character
			if let g = clay[Coord(x,y)] {
				toPrint = g.rawValue
			} else {
				toPrint = "."
			}
			print(toPrint, terminator: "")
		}
		print()
	}

}

func parseDay17Input(_ input: String) -> Set<Coord> {

	var claySet = Set<Coord>()
	let xyRegex = Regex(pattern: "^x=([0-9]+), y=([0-9]+)\\.\\.([0-9]+)$")
	let yxRegex = Regex(pattern: "^y=([0-9]+), x=([0-9]+)\\.\\.([0-9]+)$")
	for line in input.split(separator: "\n") {
		let xyMatches = xyRegex.FindSubmatch(in: line)
		if xyMatches.count > 0 {
			let x = Int(xyMatches[1])!
			let y1 = Int(xyMatches[2])!
			let y2 = Int(xyMatches[3])!
			for y in y1...y2 {
				claySet.insert(Coord(x,y))
			}
			continue
		}

		let yxMatches = yxRegex.FindSubmatch(in: line)
		if yxMatches.count > 0 {
			let y = Int(yxMatches[1])!
			let x1 = Int(yxMatches[2])!
			let x2 = Int(yxMatches[3])!
			for x in x1...x2 {
				claySet.insert(Coord(x,y))
			}
			continue
		}

		preconditionFailure("parse failed for \(line)")
	}

	return claySet

}

enum GroundType: Character {
	case WetSoil = "|"
	case Water = "~"
	case Clay = "#"
}