import Foundation

func day6(part: Int, testMode: Bool) -> String {
	let input = testMode ? day6TestInput : day6Input

	// Parse input to get array of coordinates
	let coords: [Coord] = input
					.split(separator: "\n")
					.map({
						let parts = $0.components(separatedBy: ", ")
						return ( Int(parts[0])! , Int(parts[1])! )
					}).map({ 
						Coord($0, $1)
					})

	// Find the min and max boundaries of our coordinates
	let (minExtent, maxExtent) = coords.reduce((Coord(Int.max,Int.max),Coord(0,0)), { (current: (Coord,Coord), next: Coord) in
		return (
			Coord(
				next.x < current.0.x ? next.x : current.0.x,
				next.y < current.0.y ? next.y : current.0.y
			),
			Coord(
				next.x > current.1.x ? next.x : current.1.x,
				next.y > current.1.y ? next.y : current.1.y
			)
		)
	})

	// Create a dictionary mapping coordinates to coordinate ID (A - Z)
	// Only sanely used in test mode.
	let coordDict = coords.enumerated().reduce(into: [Coord:Character](), { (dict, pair) in
		dict[pair.element] = Character(UnicodeScalar(pair.offset + 65)!)
	})

	if part == 1 {
		return part1(testMode, minExtent, maxExtent, coordDict)
	}
	return part2(testMode, minExtent, maxExtent, coordDict)
}

func part1(_ testMode: Bool, _ minExtent: Coord, _ maxExtent: Coord, _ coordDict: [Coord:Character]) -> String {

	// Part 1 finds the largest non infinite area

	// Instantiate our grid and populate it with coordinate info
	var grid = [Coord:mhDist]()
	coordDict.forEach({ (coord, coordId) in
		for y in minExtent.y...maxExtent.y {
			for x in minExtent.x...maxExtent.x {
				let curGridPos = Coord(x,y)
				let dist = abs(curGridPos.x - coord.x) + abs(curGridPos.y - coord.y)
				if let objInGrid = grid[curGridPos] {
					if dist < objInGrid.dist {
						grid[curGridPos] = mhDist(with: coordId, atDistance: dist)
					} else if dist == objInGrid.dist {
						grid[curGridPos] = mhDist(with: ".", atDistance: dist)
					}
				} else {
					grid[Coord(x,y)] = mhDist(with: coordId, atDistance: dist)
				}
			}
		}
	})

	if testMode {
		// Print out our grid
		for y in minExtent.y...maxExtent.y {
			for x in minExtent.x...maxExtent.x {
				let curGridPos = Coord(x,y)
				let objInGrid = grid[curGridPos]!

				if objInGrid.dist == 0 {
					print(objInGrid.id, terminator: "")
				} else {
					print(objInGrid.id.lowercased(), terminator: "")
				}

			}
			print()
		}
	}

	// Now find area Ids that will have infinite areas - these are ones touching
	// the extremities.
	var infiniteAreas = Set<Character>()
	for y in minExtent.y...maxExtent.y {
		for x in minExtent.x...maxExtent.x {
			if x != minExtent.x && x != maxExtent.x && y != minExtent.y && y != maxExtent.y {
				continue
			}
			let objInGrid = grid[Coord(x,y)]!
			if objInGrid.id == "." {
				continue
			}
			infiniteAreas.insert(objInGrid.id)
		}
	}

	if testMode {
		print("Infinite areas:", infiniteAreas)
	}


	// Now loop over all grid cells to total the sizes of contiguous areas while
	// ignoring any areas in the set of inifinite areas.
	var sizesById = [Character:Int]()
	for y in minExtent.y...maxExtent.y {
		for x in minExtent.x...maxExtent.x {
			let objInGrid = grid[Coord(x,y)]!
			if objInGrid.id == "." || infiniteAreas.contains(objInGrid.id) {
				continue
			}
			sizesById[objInGrid.id, default:0] += 1
		}
	}
	// and find largest of the sizes
	let largestSize = sizesById.max(by: { $0.value < $1.value })
	return "\(largestSize!.value)"


}

func part2(_ testMode: Bool, _ minExtent: Coord, _ maxExtent: Coord, _ coordDict: [Coord:Character]) -> String {
	// Part 2 finds the size of the area containing locations that have a total manhattan
	// distance to all coords of <10000 (<32 in testMode)

	let threshold = testMode ? 32 : 10000
	var areaSize = 0

	var grid = [Coord:Int]()
	for y in minExtent.y...maxExtent.y {
		for x in minExtent.x...maxExtent.x {
			let curGridPos = Coord(x,y)
			var totalMHDist = 0
			coordDict.forEach({ (coord, coordId) in
				totalMHDist += ( abs(curGridPos.x - coord.x) + abs(curGridPos.y - coord.y) )
			})
			grid[curGridPos] = totalMHDist
			if totalMHDist < threshold {
				areaSize += 1
			}
		}
	}

	if testMode {
		// Print out our grid
		for y in minExtent.y...maxExtent.y {
			for x in minExtent.x...maxExtent.x {
				let dist = grid[Coord(x,y)]!
				let char = dist < threshold ? "#" : "."
				print(char, terminator: "")
			}
			print()
		}
	}


	return "\(areaSize)"
}

struct mhDist {
	var id: Character
	var dist: Int
	init(with id: Character, atDistance dist: Int) {
		self.id = id
		self.dist = dist
	}
}

