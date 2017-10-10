Status Register
===

Carry
---
| instr		| description                       |
| --------- | ----------------------------------|
| ADC 		| carry from MSB of result			|  
| ADD 		| carry from MSB of result  		|
| ADIW 		| carry from MSB of result (16-bit) |
| INC 		| not set  							|
| SUB 		| carry from MSB of result  		|
| SBC 		| carry from MSB of result  		|
| SBIW 		| carry from MSB of result (16-bit) |
| DEC 		| not set  							|
| NEG 		| carry from MSB of result  		|
| AND 		| not set  							|
| OR 		| not set  							|
| XOR 		| not set  							|
| NOT 		| 1  								|
| MULU 		| 15th bit of result  				|
| MULS 		| 15th bit of result  				|
| MULSU 	| 15th bit of result  				|
| FMULU 	| 15th bit of result (before shift) |  
| FMULS 	| 15th bit of result (before shift) | 
| FMULSU 	| 15th bit of result (before shift) | 
| LSL 		| X(7)  							|
| LSR 		| X(0)  							|
| ASR 		| X(0)  							|
| ROL 		| X(7)  							|
| ROR 		| X(0)  							|

Zero
---
| instr		| description                       |
| --------- | ----------------------------------|
| ADC 		| zero (8-bit)						|  
| ADD 		| zero (8-bit)						|  
| ADIW 		| zero (16-bit)						|  
| INC 		| zero (8-bit)						|  
| SUB 		| zero (8-bit)						|  
| SBC 		| zero (8-bit)						|  
| SBIW 		| zero (16-bit)						|  
| DEC 		| zero (8-bit)						|  
| NEG 		| zero (8-bit)						|  
| AND 		| zero (8-bit)						|  
| OR 		| zero (8-bit)						|  
| XOR 		| zero (8-bit)						|  
| NOT 		| zero (8-bit)						|  
| MULU 		| zero (16-bit)						|  
| MULS 		| zero (16-bit)						|  
| MULSU 	| zero (16-bit)						|  
| FMULU 	| zero (16-bit)						|  
| FMULS 	| zero (16-bit)						|  
| FMULSU 	| zero (16-bit)						|  
| LSL 		| zero (8-bit)						|  
| LSR 		| zero (8-bit)						|  
| ASR 		| zero (8-bit)						|  
| ROL 		| zero (8-bit)						|  
| ROR 		| zero (8-bit)						|  

Negative
---
| instr		| description                       |
| --------- | ----------------------------------|
| ADC 		| 7th bit of result					|  
| ADD 		| 7th bit of result					|  
| ADIW 		| 15th bit of result				|  
| INC 		| 7th bit of result					|  
| SUB 		| 7th bit of result					|  
| SBC 		| 7th bit of result					|  
| SBIW 		| 15th bit of result				|  
| DEC 		| 7th bit of result					|  
| NEG 		| 7th bit of result					|  
| AND 		| 7th bit of result					|  
| OR 		| 7th bit of result					|  
| XOR 		| 7th bit of result					|  
| NOT 		| 7th bit of result					|  
| MULU 		| not set   						|  
| MULS 		| not set   						|  
| MULSU 	| not set   						|  
| FMULU 	| not set   						|  
| FMULS 	| not set   						|  
| FMULSU 	| not set   						|  
| LSL 		| 7th bit of result					|  
| LSR 		| 7th bit of result					|  
| ASR 		| 7th bit of result					|  
| ROL 		| 7th bit of result					|  
| ROR 		| 7th bit of result					|  

Overflow
---
| instr		| description                       |
| --------- | ----------------------------------|
| ADC 		| two's compliment overflow			|  
| ADD 		| two's compliment overflow			|  
| ADIW 		| two's compliment overflow			|  
| INC 		| two's compliment overflow			|  
| SUB 		| two's compliment overflow			|  
| SBC 		| two's compliment overflow			|  
| SBIW 		| two's compliment overflow			|  
| DEC 		| two's compliment overflow			|  
| NEG 		| two's compliment overflow			|  
| AND 		| 0									|  
| OR 		| 0									|  
| XOR 		| 0									|  
| NOT 		| 0									|  
| MULU 		| not set 							|  
| MULS 		| not set 							|  
| MULSU 	| not set 							|  
| FMULU 	| not set 							|  
| FMULS 	| not set 							|  
| FMULSU 	| not set 							|  
| LSL 		| negative ⊕ carry					|  
| LSR 		| negative ⊕ carry					|  
| ASR 		| negative ⊕ carry					|  
| ROL 		| negative ⊕ carry					|  
| ROR 		| negative ⊕ carry					|  

Signed
---
| instr		| description                       |
| --------- | ----------------------------------|
| ADC 		| negative ⊕ overflow				|  
| ADD 		| negative ⊕ overflow				|  
| ADIW 		| negative ⊕ overflow				|  
| INC 		| negative ⊕ overflow				|  
| SUB 		| negative ⊕ overflow				|  
| SBC 		| negative ⊕ overflow				|  
| SBIW 		| negative ⊕ overflow				|  
| DEC 		| negative ⊕ overflow				|  
| NEG 		| negative ⊕ overflow				|  
| AND 		| negative ⊕ overflow				|  
| OR 		| negative ⊕ overflow				|  
| XOR 		| negative ⊕ overflow				|  
| NOT 		| negative ⊕ overflow				|  
| MULU 		| not set							|  
| MULS 		| not set							|  
| MULSU 	| not set 							|  
| FMULU 	| not set 							|  
| FMULS 	| not set 							|  
| FMULSU 	| not set 							|  
| LSL 		| negative ⊕ overflow				|  
| LSR 		| negative ⊕ overflow				|  
| ASR 		| negative ⊕ overflow				|  
| ROL 		| negative ⊕ overflow				|  
| ROR 		| negative ⊕ overflow				|  

Half Carry
---
| instr		| description                       |
| --------- | ----------------------------------|
| ADC 		| carry from bit 3					|  
| ADD 		| carry from bit 3					|  
| ADIW 		| not set 							|  
| INC 		| not set 							|  
| SUB 		| borrow from bit 3					|  
| SBC 		| borrow from bit 3					|  
| SBIW 		| not set 							|  
| DEC 		| not set 							|  
| NEG 		| borrow from bit 3					|  
| AND 		| not set 							|  
| OR 		| not set 							|  
| XOR 		| not set 							|  
| NOT 		| not set 							|  
| MULU 		| not set 							|  
| MULS 		| not set 							|  
| MULSU 	| not set 							|  
| FMULU 	| not set 							|  
| FMULS 	| not set 							|  
| FMULSU 	| not set 							|  
| LSL 		| X(3)								|  
| LSR 		| not set 							|  
| ASR 		| not set 							|  
| ROL 		| X(3)								|  
| ROR 		| not set 							|  