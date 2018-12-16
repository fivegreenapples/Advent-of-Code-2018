func day11(part: Int, testMode: Bool) -> String {
	let serial = testMode ? day11TestInput : day11Input

	if testMode {
		// Fuel cell at 3,5, grid serial number 8: power level  4.
		print(powerlevel(at: Coord(3,5), withSerial: 8))
		// Fuel cell at  122,79, grid serial number 57: power level -5.
		print(powerlevel(at: Coord(122,79), withSerial: 57))
		// Fuel cell at 217,196, grid serial number 39: power level  0.
		print(powerlevel(at: Coord(217,196), withSerial: 39))
		// Fuel cell at 101,153, grid serial number 71: power level  4.
		print(powerlevel(at: Coord(101,153), withSerial: 71))
	}

	// establish grid of coords to powerlevels
	var grid = [Coord:Int]()
	for y in 1...300 {
		for x in 1...300 {
			grid[Coord(x,y)] = powerlevel(at: Coord(x,y), withSerial: serial)
		}
	}

	// We're going to establish the total powerlevel over a square of varying size
	// For part 1, we only consider 2x2 and 3x3 squares (noting that 2x2 squares
	// wouldn't be a valid answer if they happen to have a highest total power).
	// For part 2, we consider up to 300x300.
	let minSquareSize = 2
	let maxSquareSize: Int
	if part == 1 {
		maxSquareSize = 3
	} else {
		maxSquareSize = 300
	}

	// The accumulators cache power level sums so we can avoid and awful lot of
	// addition operations.
	var squareAccumulator = grid
	var rowAccumulator = grid
	var colAccumulator = grid
	var maxTotalPower = 0
	for squareSize in minSquareSize...maxSquareSize {
		print("Processing square size \(squareSize)")
		for y in 1...301-squareSize {
			for x in 1...301-squareSize {
				let rowPower = grid[Coord(x, y)]! + rowAccumulator[Coord(x+1, y)]!
				let colPower = grid[Coord(x, y)]! + colAccumulator[Coord(x, y+1)]!
				let totalPower = rowPower + colPower + squareAccumulator[Coord(x+1, y+1)]! - grid[Coord(x, y)]!
				if totalPower > maxTotalPower {
					print("New max power at \(x),\(y),\(squareSize) with \(totalPower)")
					maxTotalPower = totalPower
				}
				squareAccumulator[Coord(x, y)] = totalPower
				rowAccumulator[Coord(x, y)] = rowPower
				colAccumulator[Coord(x, y)] = colPower
			}
		}


	}

	if testMode {
		let tl = Coord(20,60)
		let br = Coord(24,64)
		for y in tl.y...br.y {
			for x in tl.x...br.x {
				let thisCoord = Coord(x,y)
				print(grid[thisCoord]!, " ", terminator:"")
			}
			print()
		}
	}

	return ""
}

func powerlevel(at pos:Coord, withSerial serial:Int) -> Int {

	// Find the fuel cell's rack ID, which is its X coordinate plus 10.
	// Begin with a power level of the rack ID times the Y coordinate.
	// Increase the power level by the value of the grid serial number (your puzzle input).
	// Set the power level to itself multiplied by the rack ID.
	// Keep only the hundreds digit of the power level (so 12345 becomes 3; numbers with no hundreds digit become 0).
	// Subtract 5 from the power level.

	var pl = (((pos.x + 10) * pos.y) + serial) * (pos.x + 10)
	pl = ((pl / 100) % 10) - 5

	return pl
}