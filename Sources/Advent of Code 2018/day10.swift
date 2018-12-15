func day10(part: Int, testMode: Bool) -> String {
	let input = testMode ? day10TestInput : day10Input

	// parse all points from input
	var allPoints = parseDay10Input(input)
	// declare top left and bottom right coords, used to find vertical extent
	var tl, br: Coord
	// declare initial minimal vertical extent
	var minVerticalExtent: Int = Int.max
	// declare second timer
	var second = 0

	// main run loop - every second adjust point positions based on given velocities
	repeat {
		second += 1
		for (i,p) in allPoints.enumerated() {
			allPoints[i].pos = Coord(
				p.pos.x + p.velocity.x,
				p.pos.y + p.velocity.y
			)
		}

		// after a move find new vertical extent
		(tl, br) = getExtents(from: allPoints)
		let verticalExtent = br.y-tl.y
		if verticalExtent < minVerticalExtent {
			minVerticalExtent = verticalExtent
		} else if verticalExtent > minVerticalExtent {
			// if we have started to expand then abandon
			break
		}

	} while true

	// convert points array to a set, noting we need to reverse the delta by 1 second
	// as we abandoned the run loop 1 second after the minimal extent.
	let pointSet = allPoints.reduce(into: Set<Coord>(), { current, p in 
		current.insert(Coord(
			p.pos.x - p.velocity.x,
			p.pos.y - p.velocity.y
		))
	})
	// now print out message
	for y in tl.y...br.y {
		for x in tl.x...br.x {
			let thisCoord = Coord(x,y)
			if pointSet.contains(thisCoord) {
				print("#", terminator:"")
			} else {
				print(" ", terminator:"")
			}
		}
		print()
	}

	return "Message seen after \(second-1)s"
}

func getExtents(from inputPoints: [Day10Point]) -> (Coord,Coord) {
	return inputPoints.reduce((Coord(Int.max,Int.max),Coord(0,0)), { (current, next) in
		return (
			Coord(
				next.pos.x < current.0.x ? next.pos.x : current.0.x,
				next.pos.y < current.0.y ? next.pos.y : current.0.y
			),
			Coord(
				next.pos.x > current.1.x ? next.pos.x : current.1.x,
				next.pos.y > current.1.y ? next.pos.y : current.1.y
			)
		)
	})
}

func parseDay10Input(_ input: String) -> [Day10Point] {

	// position=< 5,  9> velocity=< 1, -2>
	let regex = Regex(pattern:"^position=<([- 0-9]+), ([- 0-9]+)> velocity=<([- 0-9]+), ([- 0-9]+)>$")

	return input.split(separator: "\n").map({ pointDetails in
		let matches = regex.FindSubmatch(in: pointDetails)
		return Day10Point(
			withPosition: Coord(
				Int(matches[1].trimmingCharacters(in: .whitespacesAndNewlines))!,
				Int(matches[2].trimmingCharacters(in: .whitespacesAndNewlines))!
			),
			andVelocity: Coord(
				Int(matches[3].trimmingCharacters(in: .whitespacesAndNewlines))!,
				Int(matches[4].trimmingCharacters(in: .whitespacesAndNewlines))!
			)
		)
	})

}

struct Day10Point {
	var pos: Coord
	let velocity: Coord
	init(withPosition pos:Coord, andVelocity vel:Coord) {
		self.pos = pos
		self.velocity = vel
	}
}