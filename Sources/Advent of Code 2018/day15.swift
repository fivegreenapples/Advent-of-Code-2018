func day15(part: Int, testMode: Bool, debugMode: Bool) -> String {
	let input = testMode ? day15TestInput : day15Input


	var finalAnswer = ""
	if part == 1 {
		let battleResults = runBattle(inDebugMode: debugMode, withInput: input, elfAttackPower: 3)
		print("Power: 3 Battle won with", battleResults.elfLosses, "elf losses in", battleResults.roundsCompleted, "rounds and remaining health:", battleResults.totalRemainingHealth)
		finalAnswer = "\(battleResults.roundsCompleted * battleResults.totalRemainingHealth)"
	} else {
		for power in 4...200 {
			let battleResults = runBattle(inDebugMode: debugMode, withInput: input, elfAttackPower: power)
			print("Power:", power, "Battle won with", battleResults.elfLosses, "elf losses in", battleResults.roundsCompleted, "rounds and remaining health:", battleResults.totalRemainingHealth)
			finalAnswer = "\(battleResults.roundsCompleted * battleResults.totalRemainingHealth)"
			if battleResults.elfLosses == 0 {
				break
			}
		}
	}

	return finalAnswer
}

func runBattle(inDebugMode debugMode: Bool, withInput input:String, elfAttackPower: Int) -> (roundsCompleted:Int, totalRemainingHealth:Int, elfLosses: Int) {

	var cavern = parseDay15Input(input)
	if debugMode {
		renderCavern(cavern)
	}

	let initialElves = getElfPositions(from: cavern).count
	var combatInprogress = true
	var roundsCompleted = 0

	repeat {
		var deadPlayers = Set<Coord>()
		let sortedPlayerPositions = getSortedPlayerPositions(from: cavern)
		for pos in sortedPlayerPositions {
			if deadPlayers.contains(pos) {
				continue
			}
			let currentActor = cavern[pos]!.occupant!

			let enemyPositions: [Coord]
			if currentActor.type == .Elf {
				enemyPositions = getGoblinPositions(from: cavern)
			} else {
				enemyPositions = getElfPositions(from: cavern)
			}

			if enemyPositions.count == 0 {
				// no more enemies
				combatInprogress = false
				break
			}

			var thisTarget: Coord?
			// check if already in range
			thisTarget = findTargetIfInRange(of: pos, for: enemyPositions, in:cavern)
			if thisTarget == nil {
				// nothing currently in range so find positions in range of given enemies
				let inRangePositions = findSortedPositionsInRange(of: enemyPositions, in: cavern)
				if inRangePositions.count == 0 {
					// no positions exist to which we can move to so must abandon turn
					continue
				}

				// now find the nearest reachable inRange position
				let nearestReachableInRangePosition = findNearestReachable(from: pos, to: inRangePositions, in: cavern)
				if nearestReachableInRangePosition == nil {
					// no reachable positions. abandon turn
					continue
				}

				// need to establish whether there are multiple ways to get there
				let nextMovePosition = findMove(from: pos, to: nearestReachableInRangePosition!, in: cavern)

				// now move the currentActor to this nextMovePosition
				cavern[pos]!.occupant = nil
				cavern[nextMovePosition]!.occupant = currentActor

				// and find next target, now we have moved
				thisTarget = findTargetIfInRange(of: nextMovePosition, for: enemyPositions, in:cavern)
			}
			if thisTarget == nil {
				// means we have moved but not close enough to an enemy
				continue
			}
			// Now attack target
			cavern[thisTarget!]!.occupant!.health -= (currentActor.type == .Elf ? elfAttackPower : 3)
			if cavern[thisTarget!]!.occupant!.health <= 0 {
				cavern[thisTarget!]!.occupant = nil
				deadPlayers.insert(thisTarget!)
			}


		}
		if debugMode {
			renderCavern(cavern)
		}
		if !combatInprogress {
			break
		}
		roundsCompleted += 1
	} while true

	// total remaining health
	let totalRemainingHealth = cavern.reduce(0, { current, next in
		if let thisOccupant = next.value.occupant {
			return current + thisOccupant.health
		}
		return current
	})
	let finalElves = getElfPositions(from: cavern).count

	return (roundsCompleted, totalRemainingHealth, initialElves-finalElves)
}

func findMove(from base: Coord, to target: Coord, in cavern:[Coord:MapTile]) -> Coord {
	var currentPositions = Set<Coord>([target])
	var visitedPositions = Set<Coord>([target])
	repeat {

		let potentialMoves = findPositionsNeighbourOf(position: base, potentialNeighbours: currentPositions)
		if potentialMoves.count > 0 {
			// next to the base. returned first in sorted list of new positions
			return potentialMoves.min(by: readingOrderPredicate)!
		}


		let nextPositions = getEmptyNeighbours(of: currentPositions, in:cavern, ignoring:visitedPositions)
		if nextPositions.count == 0 {
			// this shouldn't happen - should always be able to get from base to target
			preconditionFailure("Failed to find route from \(base) to \(target)")
		}

		for nextPos in nextPositions {
			visitedPositions.insert(nextPos)
		}
		currentPositions = nextPositions
	} while true
}

func findNearestReachable(from base: Coord, to targets: [Coord], in cavern:[Coord:MapTile]) -> Coord? {

	// strategy is to expand from the base, one hop at a time and test if the
	// latest hop reaches one of the target positions. If so we return any we've hit.

	var currentPositions = Set<Coord>([base])
	var visitedPositions = Set<Coord>([base])
	repeat {
		let nextPositions = getEmptyNeighbours(of: currentPositions, in:cavern, ignoring:visitedPositions)
		if nextPositions.count == 0 {
			// none of the targets are reachable
			return nil
		}
		if nextPositions.intersection(targets).count > 0 {
			// reached some targets - return them sorted
			return nextPositions.intersection(targets).min(by: readingOrderPredicate)
		}

		for nextPos in nextPositions {
			visitedPositions.insert(nextPos)
		}
		currentPositions = nextPositions
	} while true

}

func findPositionsNeighbourOf(position: Coord, potentialNeighbours:Set<Coord>) -> Set<Coord> {
	let neighbours = Set<Coord>([
		Coord(position.x,  position.y-1),
		Coord(position.x-1,position.y),
		Coord(position.x+1,position.y),
		Coord(position.x,  position.y+1)
	])
	return potentialNeighbours.intersection(neighbours)
}


func getEmptyNeighbours(of bases:Set<Coord>, in cavern:[Coord:MapTile], ignoring ignore:Set<Coord>) -> Set<Coord> {
	var potentialNeighbours = Set<Coord>()
	for base in bases {
		potentialNeighbours.insert(Coord(base.x,  base.y-1))
		potentialNeighbours.insert(Coord(base.x-1,base.y))
		potentialNeighbours.insert(Coord(base.x+1,base.y))
		potentialNeighbours.insert(Coord(base.x,  base.y+1))
	}
	var validNeighbours = Set<Coord>()
	for p in potentialNeighbours {
		if ignore.contains(p) {
			continue
		}

		guard let tile = cavern[p] else {
			continue
		}

		if !tile.isWall && tile.occupant == nil {
			validNeighbours.insert(p)
		}
	}
	return validNeighbours
}

// Returns all valid positions that are in range of the given targets. Positions
// are returned sorted in reading order.
func findSortedPositionsInRange(of targets:[Coord], in cavern:[Coord:MapTile]) -> [Coord] {

	var potentialInRangePositions = Set<Coord>()
	for t in targets {
		potentialInRangePositions.insert(Coord(t.x,  t.y-1))
		potentialInRangePositions.insert(Coord(t.x-1,t.y))
		potentialInRangePositions.insert(Coord(t.x+1,t.y))
		potentialInRangePositions.insert(Coord(t.x,  t.y+1))
	}

	var validInRangePositions = Set<Coord>()
	for p in potentialInRangePositions {
		guard let tile = cavern[p] else {
			continue
		}
		if !tile.isWall && tile.occupant == nil {
			validInRangePositions.insert(p)
		}
	}

	return validInRangePositions.sorted(by: readingOrderPredicate)

}

// Returns an optional Coord representing the first Coord in "reading order" that
// is in range of the given base coordinate.
func findTargetIfInRange(of base:Coord, for targets:[Coord], in cavern:[Coord:MapTile]) -> Coord? {
	let inRangeOfBase = Set<Coord>([
		Coord(base.x,  base.y-1),
		Coord(base.x-1,base.y),
		Coord(base.x+1,base.y),
		Coord(base.x,  base.y+1)
	])
	let targetsInRange = Set(targets).intersection(inRangeOfBase)
	if targetsInRange.count == 0 {
		return nil
	}
	let targetWithLowestHealth = targetsInRange.min(by: { cavern[$0]!.occupant!.health < cavern[$1]!.occupant!.health })
	let lowestHealth = cavern[targetWithLowestHealth!]!.occupant!.health
	return targetsInRange.filter({ cavern[$0]!.occupant!.health == lowestHealth }).min(by: readingOrderPredicate)
}
func readingOrderPredicate(A: Coord, B: Coord) -> Bool {
	return A.y == B.y ? A.x < B.x : A.y < B.y
}

func getSortedPlayerPositions(from cavern: [Coord:MapTile]) -> [Coord] {
	return cavern.filter({ (_, tile) in
		return tile.occupant != nil
	}).keys.sorted(by: readingOrderPredicate)
}
func getElfPositions(from cavern: [Coord:MapTile]) -> [Coord] {
	return Array(cavern.filter({ (_, tile) in
		return tile.occupant?.type == .Elf
	}).keys)
}
func getGoblinPositions(from cavern: [Coord:MapTile]) -> [Coord] {
	return Array(cavern.filter({ (_, tile) in
		return tile.occupant?.type == .Goblin
	}).keys)
}

func renderCavern(_ cavern: [Coord:MapTile]) {
	// Find the min and max boundaries of our coordinates
	let maxExtent = cavern.keys.reduce(Coord(0,0), { (current: Coord, next: Coord) in
		return (
			Coord(
				next.x > current.x ? next.x : current.x,
				next.y > current.y ? next.y : current.y
			)
		)
	})

	for y in 0...maxExtent.y {
		for x in 0...maxExtent.x {
			print(cavern[Coord(x,y)]!, terminator:"")
		}
		print()
	}

}


func parseDay15Input(_ input: String) -> [Coord:MapTile] {

	let rows = input.split(separator: "\n")
	var map = [Coord:MapTile]()

	for (y,row) in rows.enumerated() {
		for (x,char) in row.enumerated() {
			let thisMapTile: MapTile
			if char == "E" {
				thisMapTile = MapTile.init(isWall: false, occupant: Player(withType: .Elf))
			} else if char == "G" {
				thisMapTile = MapTile.init(isWall: false, occupant: Player(withType: .Goblin))
			} else {
				thisMapTile = MapTile.init(isWall: char == "#", occupant: nil)
			}
			map[Coord(x,y)] = thisMapTile
		}
	}

	return map

}

struct MapTile: CustomStringConvertible {
	let isWall: Bool
	var occupant: Player?

	var description: String {
		if isWall {
			return "#"
		}
		guard let theOccupant = occupant else {
			return "."
		}
		return String(theOccupant.type.rawValue)
	}

}

class Player {
	let type: PlayerType
	var health = 200
	init(withType typ: PlayerType) {
		type = typ
	}
}

enum PlayerType: Character {
	case Elf = "E"
	case Goblin = "G"
}

