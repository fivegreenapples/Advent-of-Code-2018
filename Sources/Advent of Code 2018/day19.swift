func day19(part: Int, testMode: Bool, verboseMode: Bool) -> String {

	// 17: addi 5 2 5  r5 += 2
	// 18: mulr 5 5 5  r5 = r5 * r5
	// 19: mulr 1 5 5  r5 = r5 * 19 // 19 is ip
	// 20: muli 5 11 5 r5 = r5 * 11
	// 21: addi 3 5 3  r3 += 5
	// 22: mulr 3 1 3  r3 = r3 * 22
	// 23: addi 3 4 3  r3 = r3 + 4
	// 24: addr 5 3 5  r5 = r5 + r3
	var programInput = (2 * 2 * 19 * 11) + ((5 * 22) + 4) // 950
	if part == 2 {
		// 27: setr 1 1 3  r3 = 27
		// 28: mulr 3 1 3  r3 *= 28
		// 29: addr 1 3 3  r3 += 29
		// 30: mulr 1 3 3  r3 *= 30
		// 31: muli 3 14 3 r3 *= 14
		// 32: mulr 3 1 3  r3 *= 32
		// 33: addr 5 3 5  r5 += r3
		programInput += (((27 * 28) + 29) * 30 * 14 * 32) // 10550400
	}

	// let answer = runProgram(input:programInput)
	let answer = runProgramOptimised(input:programInput, inVerboseMode: verboseMode)
	return "\(answer)"

}

// runProgram runs the machine in native swift. It finds the sum of As for the
// integers A and B such that A*B == INPUT
// i.e the sum of the factors of input
func runProgram(input: Int, inVerboseMode: Bool) -> Int {
	var Z = 0

	var a = 1
	repeat {

		var b = 1
		repeat {
			if (a * b) == input {
				Z += a
				if inVerboseMode {
					print (a)
				}
			}
			b += 1

		} while b <= input 

		a += 1

	} while a <= input

	return Z 
}

// runProgramOptimised is a much more efficient version of the above
func runProgramOptimised(input: Int, inVerboseMode: Bool) -> Int {
	var Z = 0
	let upperRange = Int(Double(input).squareRoot())

	for x in 1...upperRange {
		if input % x == 0 {
			// x is a factor of input
			Z += x
			Z += (input / x)
			if inVerboseMode {
				print (x, (input / x))
			}
		}
	}

	return Z 
}

// Analysis
// #ip 1
//                    ip = r0 = r1 = r2 = r3 = r4 = r5 = 0
//  0: addi 1 16 1    r1 = 16; ip = 16 // relative jump - jmp 17

// some massive loop
//  1: seti 1 8 2  r2 = 1
//  2: seti 1 5 4  r4 = 1
//  3: mulr 2 4 3  r3 = r2 * r4
//  4: eqrr 3 5 3  r3 = ( r3 == r5 ? 1 : 0)
//  5: addr 3 1 1  ip = ip + r3 // skip next if r3 == r5
//  6: addi 1 1 1  ip = ip + 1 // skip next
//  7: addr 2 0 0  r0 += r2                         // ** only thing that changes r0
//  8: addi 4 1 4  r4 += 1
//  9: gtrr 4 5 3  r3 = ( r4 > r5 ? 1 : 0)
// 10: addr 1 3 1  ip = ip + r3 // skip next if r4 > r5
// 11: seti 2 8 1  ip = 2 // jmp 3
// 12: addi 2 1 2  r2 += 1
// 13: gtrr 2 5 3  r3 = (r2 > r5 ? 1 : 0)
// 14: addr 3 1 1  ip += r3 // skip next if r2 > r5
// 15: seti 1 8 1  ip = 1// jmp 2
// 16: mulr 1 1 1  ip = ip * ip // ip = 256 // halt

// this block puts 950 in r5
// 17: addi 5 2 5  r5 += 2
// 18: mulr 5 5 5  r5 = r5 * r5
// 19: mulr 1 5 5  r5 = r5 * 19 // 19 is ip
// 20: muli 5 11 5 r5 = r5 * 11
// 21: addi 3 5 3  r3 += 5
// 22: mulr 3 1 3  r3 = r3 * 22
// 23: addi 3 4 3  r3 = r3 + 4
// 24: addr 5 3 5  r5 = r5 + r3
// 25: addr 1 0 1  ip += r0; ip = r1 // ip doesn't change on first run but might later -- part 2 r0 is 1, so skips to 27
// 26: seti 0 7 1  r1 = 0; ip = 0 // jmp to line 1

// part 2 block
// 27: setr 1 1 3  r3 = 27
// 28: mulr 3 1 3  r3 *= 28
// 29: addr 1 3 3  r3 += 29
// 30: mulr 1 3 3  r3 *= 30
// 31: muli 3 14 3 r3 *= 14
// 32: mulr 3 1 3  r3 *= 32
// 33: addr 5 3 5  r5 += r3
// 34: seti 0 9 0  r0 = 0 // reset r0 (output)
// 35: seti 0 0 1  ip = 0 // jmp to 1 
// """



//
// All code below here was used initially but in the end wasn't necessary. Just
// a manual analysis of the instructions was required to understand the program.
//



// func day19(part: Int, testMode: Bool, verboseMode: Bool) -> String {
// 	let input = testMode ? day19TestInput : day19Input

// 	let (ipBoundReg, instructions) = parseDay19Input(input)

// 	var device = Day19WristDevice(reg1: 0, reg2: 0, reg3: 0, reg4: 0, reg5: 0, reg6: 0)
// 	device.setInstructionPointerBoundRegister(ipBoundReg)

// 	var cycleCount = 30
// 	while (device.ip < instructions.count) && cycleCount > 0 {
// 		let instr = instructions[device.ip]
// 		let state = device.runOne(instr.Op, A: instr.A, B: instr.B, C: instr.C)
// 		if verboseMode {
// 			print(state)
// 		}
// 		cycleCount -= 1
// 	}

// 	return "\(device.registers[0])"

// }


// typealias Day19Instruction = (Op:Day19Opcode, A:Int, B:Int, C:Int)

// func parseDay19Input(_ input:String) -> (Int, [Day19Instruction]) {
// 	let lines = input.split(separator:"\n")
// 	let ipBoundRegister = Int(String(lines[0])[4...4])!
// 	let instructions:[Day19Instruction] = lines[1...].map({ line in 
// 		let parts = line.split(separator: " ")
// 		return (Day19Opcode(rawValue: String(parts[0]))!, Int(parts[1])!, Int(parts[2])!, Int(parts[3])!)
// 	})
// 	return (ipBoundRegister,instructions)
// }

// struct Day19WristDevice {
// 	var registers: [Int]
// 	var ipBoundReg = 0
// 	var ip = 0
// 	init(reg1:Int, reg2:Int, reg3:Int, reg4:Int, reg5:Int, reg6:Int) {
// 		registers = [reg1,reg2,reg3,reg4,reg5,reg6]
// 	}
// 	mutating func setInstructionPointerBoundRegister(_ reg:Int) {
// 		ipBoundReg = reg
// 	}
// 	mutating func runOne(_ opcode:Day19Opcode, A:Int, B:Int, C:Int) -> String {
// 		var stateDescription = "ip=\(ip) "
// 		registers[ipBoundReg] = ip
// 		stateDescription += registers.description
// 		stateDescription += " \(opcode) \(A) \(B) \(C) "
// 		switch opcode {
// 			case .addr: // (add register) stores into register C the result of adding register A and register B.
// 			registers[C] = registers[A] + registers[B]
// 			case .addi: // (add immediate) stores into register C the result of adding register A and value B.
// 			registers[C] = registers[A] + B
// 			case .mulr: // (multiply register) stores into register C the result of multiplying register A and register B.
// 			registers[C] = registers[A] * registers[B]
// 			case .muli: // (multiply immediate) stores into register C the result of multiplying register A and value B.
// 			registers[C] = registers[A] * B
// 			case .banr: // (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B.
// 			registers[C] = registers[A] & registers[B]
// 			case .bani: // (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B.
// 			registers[C] = registers[A] & B
// 			case .borr: // (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B.
// 			registers[C] = registers[A] | registers[B]
// 			case .bori: // (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B.
// 			registers[C] = registers[A] | B
// 			case .setr: // (set register) copies the contents of register A into register C. (Input B is ignored.)
// 			registers[C] = registers[A]
// 			case .seti: // (set immediate) stores value A into register C. (Input B is ignored.)
// 			registers[C] = A
// 			case .gtir: // (greater-than immediate/register) sets register C to 1 if value A is greater than register B. Otherwise, register C is set to 0.
// 			registers[C] = (A > registers[B] ? 1 : 0)
// 			case .gtri: // (greater-than register/immediate) sets register C to 1 if register A is greater than value B. Otherwise, register C is set to 0.
// 			registers[C] = (registers[A] > B ? 1 : 0)
// 			case .gtrr: // (greater-than register/register) sets register C to 1 if register A is greater than register B. Otherwise, register C is set to 0.
// 			registers[C] = (registers[A] > registers[B] ? 1 : 0)
// 			case .eqir: // (equal immediate/register) sets register C to 1 if value A is equal to register B. Otherwise, register C is set to 0.
// 			registers[C] = (A == registers[B] ? 1 : 0)
// 			case .eqri: // (equal register/immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
// 			registers[C] = (registers[A] == B ? 1 : 0)
// 			case .eqrr: // (equal register/register) sets register C to 1 if register A is equal to register B. Otherwise, register C is set to 0.
// 			registers[C] = (registers[A] == registers[B] ? 1 : 0)
// 		}
// 		stateDescription += registers.description
// 		ip = registers[ipBoundReg] + 1
// 		return stateDescription
// 	}
// }

// enum Day19Opcode: String {
// 	case addr
// 	case addi
// 	case mulr
// 	case muli
// 	case banr
// 	case bani
// 	case borr
// 	case bori
// 	case setr
// 	case seti
// 	case gtir
// 	case gtri
// 	case gtrr
// 	case eqir
// 	case eqri
// 	case eqrr
// }




