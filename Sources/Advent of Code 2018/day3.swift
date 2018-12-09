import Foundation

func day3(part: Int, test: Bool) -> String {

	var input = day3Input
	if test {
		input = day3InputTest
	}
	let claims = input.split(separator: "\n").map() { String($0) }
	// #1 @ 1,3: 4x4
	let regex = Regex(pattern: "^#([0-9]+) @ ([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)$")

	let fabric = Fabric()
	var allClaims = [FabricClaim]()

	for claimString in claims {
		let matches = regex.FindSubmatch(in: claimString)
		let claim = FabricClaim(
			id: Int(matches[1])!,
			offset: Coord(Int(matches[2])!, Int(matches[3])!),
			width: Int(matches[4])!,
			height: Int(matches[5])!
		)

		fabric.addClaim(claim)
		allClaims.append(claim)
	}

	if test {
		fabric.render()
	}
	if part == 1 {
		return "\(fabric.findTotalOverlap())"
	}

	for claim in allClaims {
		if !fabric.doesClaimOverlap(claim) {
			return "\(claim.id)"
		}
	}
	return "All claims apparently overlap :("
}

struct FabricClaim {
	var id: Int
	var offset: Coord
	var width: Int
	var height: Int
	init(id: Int, offset: Coord, width: Int, height: Int) {
		self.id = id
		self.offset = offset
		self.width = width
		self.height = height
	}
}
struct Coord : Hashable {
	var x: Int
	var y: Int
	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}
}
class Fabric {
	var canvasUsage = [Coord:(numClaims:Int, claimId:Int)]()
	var extents: Coord = Coord(0,0)

	func addClaim(_ c: FabricClaim) {
		for x in c.offset.x..<(c.offset.x + c.width) {
			for y in c.offset.y..<(c.offset.y + c.height) {
				if x > self.extents.x {
					self.extents.x = x
				}
				if y > self.extents.y {
					self.extents.y = y
				}
				let pos = Coord(x,y)
				var currentUse = canvasUsage[pos, default: (numClaims:0,claimId:0)]
				currentUse.numClaims += 1
				if currentUse.numClaims == 1 {
					currentUse.claimId = c.id
				}
				canvasUsage[pos] = currentUse
			}
		}
	}

	func findTotalOverlap() -> Int {
		var overlap = 0
		for y in 0...self.extents.y {
			for x in 0...self.extents.x {
				let pos = Coord(x,y)
				if canvasUsage[pos, default:(numClaims:0,claimId:0)].numClaims > 1 {
					overlap += 1
				}
			}
		}
		return overlap
	}

	func doesClaimOverlap(_ c: FabricClaim) -> Bool {
		for x in c.offset.x..<(c.offset.x + c.width) {
			for y in c.offset.y..<(c.offset.y + c.height) {
				let pos = Coord(x,y)
				let currentUse = canvasUsage[pos, default: (numClaims:0,claimId:0)]
				if currentUse.numClaims > 1 {
					return true
				}
			}
		}
		return false
	}

	func render() {
		for x in 0...self.extents.x {
			for y in 0...self.extents.y {
				let pos = Coord(x,y)
				let currentUse = canvasUsage[pos, default: (numClaims:0,claimId:0)]
				if currentUse.numClaims == 0 {
					print(".", separator: "", terminator: "")
				} else if currentUse.numClaims == 1 {
					print(currentUse.claimId, separator: "", terminator: "")
				} else {
					print("X", separator: "", terminator: "")
				}
			}
			print("")
		}
	}

}