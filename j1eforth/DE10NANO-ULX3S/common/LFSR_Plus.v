////-- 	Pseudo-Random Number Generator with LFSRs
////------------------------------------------------------------------------------------
////-- ***********************************************************************
////-- FileName: LFSR_Plus.v
////-- FPGA: MachXO2-7000HE
////-- IDE: Lattice Diamond 2.0.1
////--
////-- HDL IS PROVIDED "AS IS." DIGI-KEY EXPRESSLY DISCLAIMS ANY
////-- WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
////-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
////-- PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
////-- BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
////-- DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
////-- PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
////-- BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
////-- ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
////-- DIGI-KEY ALSO DISCLAIMS ANY LIABILITY FOR PATENT OR COPYRIGHT
////-- INFRINGEMENT.
////--
////-- Version History
////-- Version 1.0 5/1/2013 Tony Storey
////-- Initial Public Release
////-- N-bit look ahead carry combinational adder with overflow detection and saturated output 
////----------------------------------------------------------------------------------

`timescale 1 ns/ 100 ps

//// W is width LFSR scaleable from 24 down to 4 bits
//// V is width LFSR for non uniform clocking scalable from 24 down to 18 bit
//// g_type gausian distribution type, 0 = unimodal, 1 = bimodal, from g_noise_out
//// u_type uniform distribution type, 0 = uniform, 1 =  ave-uniform, from u_noise_out

module LFSR_Plus #(parameter W = 16, V = 18, g_type = 0, u_type = 1)      
	(
		output	reg [W-1 : 0]		g_noise_out,
		output 	reg	[W-1 : 0]		u_noise_out,
		input 	clk,
		input		n_reset,
		input		enable
	);
	
////---------------- internal variables ----------------------------------
	reg		[W-1 : 0] 	rand_out;
	//// flip flops for shift registers
	reg		[W-1 : 0]	rand_ff;
	reg		[V-1 : 0]	rand_en_ff;
	//// registers for gaussian distribution, these form bus wide shift registers
	reg  	[W-1 : 0]	temp_u_noise3;
	reg  	[W-1 : 0]	temp_u_noise2;
	reg  	[W-1 : 0]	temp_u_noise1;
	reg 	[W-1 : 0]	temp_u_noise0;
	reg 	[W-1 : 0]	temp_g_noise_nxt;

	
	//// LFSR for timing purposes to control output 
	//// reg can be scaled from 18 up to 24 bit by parameter V above
	///////////////////////////////////////////////////////
	always @(posedge clk)
		begin
			if(n_reset == 1'b 0)
					rand_en_ff[V-1 :0] <= 24'b 0011_0001_0011_0111_0110_0101;		// seed word for timer lsfr
			else if(enable == 1'b 1)
				begin
					case( V) 
						24 			: rand_en_ff <= {(rand_en_ff[7] ^ rand_en_ff[2] ^ rand_en_ff[1] ^ rand_en_ff[0]) , rand_en_ff[V-1 : 1]};		//	x^24 + x^23 + x^22 + x^17 + 1 
						23 			: rand_en_ff <= {(rand_en_ff[5] ^ rand_en_ff[0] ) , rand_en_ff[V-1 : 1]};																		//	x^23+ x^18 + 1
						22 			: rand_en_ff <= {(rand_en_ff[1] ^ rand_en_ff[0]) , rand_en_ff[V-1 : 1]};																			//	x^22+ x^21 + 1	
						21 			: rand_en_ff <= {(rand_en_ff[2] ^ rand_en_ff[0]) , rand_en_ff[V-1 : 1]};																			// 	x^21+ x^19 + 1
						20 			: rand_en_ff <= {(rand_en_ff[3] ^ rand_en_ff[0]) , rand_en_ff[V-1 : 1]};																			//	x^20+ x^17 + 1
						19 			: rand_en_ff <= {(rand_en_ff[15] ^ rand_en_ff[13] ^ rand_en_ff[0]) , rand_en_ff[V-1 : 1]};									//	x^19 + x^5 + x^2 + 1 					
						default : rand_en_ff <= {(rand_en_ff[7] ^ rand_en_ff[0]) , rand_en_ff[V-1 : 1]};																			//	x^18 + x^11 + 1	
					endcase
				end
			else
				rand_en_ff <= rand_en_ff;
		end

	//// always block for random number generator using LINEAR FEEDBACK SHIFT REG with polys for Maximal-length
	//// scaleable between 24 bits down to 4 bits
	///////////////////////////////////////////////////////
	always @(posedge clk)
		begin
			if(n_reset == 1'b 0)
				begin
					rand_ff[W-1 :0] <= 24'b 0110_0011_0111_0110_1001_1101;		// seed for pseudo random number sequencer
					rand_out <= {W-1{1'b 0}};
				end
			else if(enable == 1'b 1)
				begin
					case (W) 
						24 			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[7] ^ rand_ff[2] ^ rand_ff[1] ^ rand_ff[0]) , rand_ff[W-1 : 1] };    				// x^24 + x^23 + x^22 + x^17 + 1
												rand_out <=  rand_ff;
											end
						23 			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[5] ^ rand_ff[0] ) , rand_ff[W-1 : 1] };    																// x^23+ x^18 + 1
												rand_out <=  rand_ff;
											end
						22 			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[1] ^ rand_ff[0] ) , rand_ff[W-1 : 1] };    																// x^22+ x^21 + 1
												rand_out <=  rand_ff;			
											end
						21 			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[2] ^ rand_ff[0] ), rand_ff[W-1 : 1] };         															// x^21+ x^19 + 1
												rand_out <=  rand_ff;			
											end
						20			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[3] ^ rand_ff[0] ), rand_ff[W-1 : 1] };       																// x^20+ x^17 + 1
												rand_out <=  rand_ff;									
											end											
						19			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[15] ^ rand_ff[13] ^ rand_ff[0] ), rand_ff[W-1 : 1] };        								// x^19 + x^5 + x^2 + 1  
												rand_out <=  rand_ff;									
											end
						18			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[7] ^ rand_ff[0] ) , rand_ff[W-1 : 1] };      																// x^18 + x^11 + 1
												rand_out <=  rand_ff;							
											end
						17 			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[3] ^ rand_ff[0] ) , rand_ff[W-1 : 1] };      																// x^17 + x^14 + 1
												rand_out <=  rand_ff;									
											end											
						16 			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[5] ^ rand_ff[3] ^ rand_ff[2] ^ rand_ff[0]) , rand_ff[W-1 : 1] };        			// x^16 + x^14 + x^13 + x^11 + 1
												rand_out <=  rand_ff;										
											end
						15			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[1] ^ rand_ff[0] ), rand_ff[W-1 : 1] };       																// x^15 + x^14 + 1
												rand_out <=  rand_ff;							
											end
						14 			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[12] ^ rand_ff[2] ^ rand_ff[1] ^ rand_ff[0]), rand_ff[W-1 : 1] };    				// x^14 + x^13 + x^12 + x^2 + 1
												rand_out <=  rand_ff;								
											end
						13			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[5] ^ rand_ff[2] ^ rand_ff[1] ^ rand_ff[0] ), rand_ff[W-1 : 1] };       			// x^13 + x^12 + x^11 + x^8 + 1
												rand_out <=  rand_ff;							
											end
						12 			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[8] ^ rand_ff[2] ^ rand_ff[1] ^ rand_ff[0] ), rand_ff[W-1 : 1] };      			// x^12 + x^11 + x^10 + x^4 + 1
												rand_out <=  rand_ff;										
											end
						11 			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[1] ^ rand_ff[0] ), rand_ff[W-1 : 1] };      																// x^11 + x^9 + 1
												rand_out <=  rand_ff;								
											end
						10 			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[3] ^ rand_ff[0] ), rand_ff[W-1 : 1] };   																	// x^10 + x^7 + 1
												rand_out <=  rand_ff;	
											end
						9 			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[4] ^ rand_ff[0] ), rand_ff[W-1 : 1] };       																// x^9 + x^5 + 1
												rand_out <=  rand_ff;								
											end
						8				:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[4] ^ rand_ff[3] ^ rand_ff[2] ^ rand_ff[0]), rand_ff[W-1 : 1] };     				// x^8 + x^6 + x^5 + x^4 + 1
												rand_out <=  rand_ff;								
											end
						7				:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[1] ^ rand_ff[0] ) , rand_ff[W-1 : 1] };     																// x^7 + x^6 + 1
												rand_out <=  rand_ff;
											end
						6				:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[1] ^ rand_ff[0] ) , rand_ff[W-1 : 1] };       															// x^6 + x^5 + 1
												rand_out <=  rand_ff;								
											end
											
						5 			:	begin
												rand_ff[W-1 : 0] <= { ( rand_ff[2] ^ rand_ff[0] ), rand_ff[W-1 : 1] };      															// x^5 + x^3 + 1
												rand_out <=  rand_ff;		
											end
						default	:	begin
												rand_ff[W-1 : 0] <= { (rand_ff[1] ^ rand_ff[0]) , rand_ff[W-1 : 0]};																	// x^4 + x^3 + 1
												rand_out <=  rand_ff;										
											end
					endcase
				end  // end else if(enable == 1'b 1)
			else
				rand_out <= rand_out;
		end 	// end always

	//// FIFO for inputs from rand_out, tool should prune two msb and sign extend in adder below
	///////////////////////////////////////////////////////	
	always @(posedge clk)
		begin
			if(n_reset == 1'b 0)
				begin
					temp_u_noise3 <= {W-1{1'b 0}};		
					temp_u_noise2 <= {W-1{1'b 0}};
					temp_u_noise1 <= {W-1{1'b 0}};
					temp_u_noise0 <= {W-1{1'b 0}};
				end
			else if(enable == 1'b 1)
				begin
					temp_u_noise3 <= { rand_out[W-1] ,  rand_out[W-1] ,  rand_out[W-1 : 2] } ;						// numbers/4 are shifted in  
					temp_u_noise2 <= temp_u_noise3;	
					temp_u_noise1 <= temp_u_noise2;	
					temp_u_noise0 <= temp_u_noise1;		
				end 	// end if(enable == 1'b 1)	
			else
				begin
					temp_u_noise3 <= temp_u_noise3;			
					temp_u_noise2 <= temp_u_noise2;
					temp_u_noise1 <= temp_u_noise1;
					temp_u_noise0 <= temp_u_noise0;
				end
		end 	// end of always		


	//// always block to create distributions using the central limit theorom, variable duty cycle time multiplexing, and feedback
	///////////////////////////////////////////////////////
	always @(posedge clk)
		begin
			if(enable == 1'b 1)
				begin
					case (g_type)
						1					:	temp_g_noise_nxt <= temp_u_noise3 + temp_u_noise2 + temp_u_noise1 + temp_u_noise0 + g_noise_out;  					// numbers in shift register are added with feedback term for bimodal
						default		:	begin
													if(rand_en_ff[9] == 1'b 1)
														temp_g_noise_nxt  <= temp_u_noise3 + temp_u_noise2 + temp_u_noise1 + temp_u_noise0 + g_noise_out;			// numbers in shift register are added with feedback term
													else
														temp_g_noise_nxt  <= temp_u_noise3 + temp_u_noise2 + temp_u_noise1 + temp_u_noise0;  										// numbers in shift register are added														
												end 	// end default case
					endcase
					case (u_type)
						1					:	begin
													if( rand_en_ff[17] == 1'b 1)
														u_noise_out <= rand_out[W-1 : 0];			// average-uniform
													else
														u_noise_out <= u_noise_out;	
												end 	// end case 1
						default		:	u_noise_out <= rand_out[W-1 : 0];					// uniform
					endcase	
				end
			else
				begin
					temp_g_noise_nxt <= temp_g_noise_nxt;
				end	
		end	// end always
	

	//// The outputs for the number generator, a timer controls an output multiplexer
	//// g_noise_out goes through latch for feedback
	///////////////////////////////////////////////////////	
	always @(*)
		begin
			if(n_reset == 1'b 0)
				g_noise_out = {W-1{1'b 0}};
			else if(rand_en_ff[17] == 1'b 1)
				g_noise_out = temp_g_noise_nxt[W-1 : 0];
			else if(rand_en_ff[10] == 1'b 1)
				g_noise_out = rand_out[W-1 : 0];
			else
				g_noise_out = g_noise_out;				
		end	// end always

				
endmodule
	
	
	
	
	
	
	
	
	
	
