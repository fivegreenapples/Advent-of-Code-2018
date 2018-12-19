func day16(part: Int, testMode: Bool) -> String {
	if part == 1 {
		let input = testMode ? day16Part1TestInput : day16Part1Input

		var scenariosWith3OrMoreMatchingOpcodes = 0
		let scenarios = parseDay16Part1Input(input)
		for s in scenarios {
			var matchingOpcodes = 0
			for op in Opcode.all() {
				var device = WristDevice(reg1: s.beforeRegisters[0], reg2: s.beforeRegisters[1], reg3: s.beforeRegisters[2], reg4: s.beforeRegisters[3])
				device.runOne(op, A: s.instructionA, B: s.instructionB, C: s.instructionC)
				if device.registers == s.afterRegisters {
					matchingOpcodes += 1
				}
			}
			if matchingOpcodes >= 3 {
				scenariosWith3OrMoreMatchingOpcodes += 1
			}
		}

		return "\(scenariosWith3OrMoreMatchingOpcodes)"
	}


	// work out opcode map
	var matchedOpcodeToVal = [Opcode:Int]()
	var matchedValToOpcode = [Int:Opcode]()
	let input = testMode ? day16Part1TestInput : day16Part1Input
	let scenarios = parseDay16Part1Input(input)
	var matchedOne = false
	repeat {
		matchedOne = false
		for s in scenarios {
			if matchedValToOpcode[s.instructionOpcodeVal] != nil {
				// ignore known matches
				continue
			}
			var matchingOpcodes = 0
			var matchedOpcode: Opcode?
			for op in Opcode.all() {
				if matchedOpcodeToVal[op] != nil {
					// ignore known matches
					continue
				}
				var device = WristDevice(reg1: s.beforeRegisters[0], reg2: s.beforeRegisters[1], reg3: s.beforeRegisters[2], reg4: s.beforeRegisters[3])
				device.runOne(op, A: s.instructionA, B: s.instructionB, C: s.instructionC)
				if device.registers == s.afterRegisters {
					matchedOpcode = op
					matchingOpcodes += 1
				}
			}
			if matchingOpcodes == 1 {
				print("Found \(matchedOpcode!) equals \(s.instructionOpcodeVal)")
				matchedOpcodeToVal[matchedOpcode!] = s.instructionOpcodeVal
				matchedValToOpcode[s.instructionOpcodeVal] = matchedOpcode!
				matchedOne = true
			}
		}

	} while matchedOne

	for (op,val) in matchedOpcodeToVal {
		print("\(op) -> \(val)")
	}
	if matchedOpcodeToVal.count == 16 {
		print("Success!")
	}

	let instructionList = parseDay16Part2Input(day16Part2Input)
	var device = WristDevice(reg1: 0, reg2: 0, reg3: 0, reg4: 0)
	for instr in instructionList {
		device.runOne(matchedValToOpcode[instr[0]]!, A: instr[1], B: instr[2], C: instr[3])
	}

	return "\(device.registers[0])"
}

func parseDay16Part2Input(_ input:String) -> [[Int]] {
	let lines = input.split(separator:"\n")
	return lines.map({ line in 
		return line.split(separator: " ").map({ Int($0)! })
	})
}

func parseDay16Part1Input(_ input:String) -> [Scenario] {
	// Before: [3, 2, 1, 1]
	// 9 2 1 2
	// After:  [3, 2, 2, 1]

	var scenarios = [Scenario]()
	let lines = input.split(separator:"\n")

	for i in stride(from: 0, to: lines.count, by: 3) {

		let beforeRegisters = String(lines[i])[9...18].components(separatedBy: ", ").map({ Int($0)! })
		let instructionParts = lines[i+1].split(separator: " ").map({ Int($0)! })
		let afterRegisters = String(lines[i+2])[9...18].components(separatedBy: ", ").map({ Int($0)! })

		let s = Scenario(
			beforeRegisters: beforeRegisters,
			afterRegisters: afterRegisters,
			instructionOpcodeVal: instructionParts[0],
			instructionA: instructionParts[1],
			instructionB: instructionParts[2],
			instructionC: instructionParts[3]
		)
		scenarios.append(s)
	}
	return scenarios
}

struct Scenario {
	let beforeRegisters: [Int]
	let afterRegisters: [Int]
	let instructionOpcodeVal: Int
	let instructionA: Int
	let instructionB: Int
	let instructionC: Int
}

struct WristDevice {
	var registers: [Int]
	init(reg1:Int, reg2:Int, reg3:Int, reg4:Int) {
		registers = [reg1,reg2,reg3,reg4]
	}
	mutating func runOne(_ opcode:Opcode, A:Int, B:Int, C:Int) {
		switch opcode {
			case .addr: // (add register) stores into register C the result of adding register A and register B.
			registers[C] = registers[A] + registers[B]
			case .addi: // (add immediate) stores into register C the result of adding register A and value B.
			registers[C] = registers[A] + B
			case .mulr: // (multiply register) stores into register C the result of multiplying register A and register B.
			registers[C] = registers[A] * registers[B]
			case .muli: // (multiply immediate) stores into register C the result of multiplying register A and value B.
			registers[C] = registers[A] * B
			case .banr: // (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B.
			registers[C] = registers[A] & registers[B]
			case .bani: // (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B.
			registers[C] = registers[A] & B
			case .borr: // (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B.
			registers[C] = registers[A] | registers[B]
			case .bori: // (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B.
			registers[C] = registers[A] | B
			case .setr: // (set register) copies the contents of register A into register C. (Input B is ignored.)
			registers[C] = registers[A]
			case .seti: // (set immediate) stores value A into register C. (Input B is ignored.)
			registers[C] = A
			case .gtir: // (greater-than immediate/register) sets register C to 1 if value A is greater than register B. Otherwise, register C is set to 0.
			registers[C] = (A > registers[B] ? 1 : 0)
			case .gtri: // (greater-than register/immediate) sets register C to 1 if register A is greater than value B. Otherwise, register C is set to 0.
			registers[C] = (registers[A] > B ? 1 : 0)
			case .gtrr: // (greater-than register/register) sets register C to 1 if register A is greater than register B. Otherwise, register C is set to 0.
			registers[C] = (registers[A] > registers[B] ? 1 : 0)
			case .eqir: // (equal immediate/register) sets register C to 1 if value A is equal to register B. Otherwise, register C is set to 0.
			registers[C] = (A == registers[B] ? 1 : 0)
			case .eqri: // (equal register/immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
			registers[C] = (registers[A] == B ? 1 : 0)
			case .eqrr: // (equal register/register) sets register C to 1 if register A is equal to register B. Otherwise, register C is set to 0.
			registers[C] = (registers[A] == registers[B] ? 1 : 0)
		}
	}

}



enum Opcode {
	case addr
	case addi
	case mulr
	case muli
	case banr
	case bani
	case borr
	case bori
	case setr
	case seti
	case gtir
	case gtri
	case gtrr
	case eqir
	case eqri
	case eqrr

	static func all() -> [Opcode] {
		return [
			.addr,
			.addi,
			.mulr,
			.muli,
			.banr,
			.bani,
			.borr,
			.bori,
			.setr,
			.seti,
			.gtir,
			.gtri,
			.gtrr,
			.eqir,
			.eqri,
			.eqrr,
		]
	}
}

