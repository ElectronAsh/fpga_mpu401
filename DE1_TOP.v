module DE1_TOP
(
	////////////////////////	Clock Input	 	////////////////////////
	input	[1:0]	CLOCK_24,				//	24 MHz
	input	[1:0]	CLOCK_27,				//	27 MHz
	input			CLOCK_50,				//	50 MHz
	input			EXT_CLOCK,				//	External Clock
	////////////////////////	Push Button		////////////////////////
	input	[3:0]	KEY,						//	Pushbutton[3:0]
	////////////////////////	DPDT Switch		////////////////////////
	input	[9:0]	SW,						//	Toggle Switch[9:0]
	////////////////////////	7-SEG Display	////////////////////////
	output	[6:0]	HEX0,					//	Seven Segment Digit 0
	output	[6:0]	HEX1,					//	Seven Segment Digit 1
	output	[6:0]	HEX2,					//	Seven Segment Digit 2
	output	[6:0]	HEX3,					//	Seven Segment Digit 3
	////////////////////////////	LED		////////////////////////////
	output	[7:0]	LEDG,					//	LED Green[7:0]
	output	[9:0]	LEDR,					//	LED Red[9:0]
	////////////////////////////	UART	////////////////////////////
	output			UART_TXD,			//	UART Transmitter
	input			UART_RXD,				//	UART Receiver
	///////////////////////		SDRAM Interface	////////////////////////
	inout	 [15:0]	DRAM_DQ,				//	SDRAM Data bus 16 Bits
	output [11:0]	DRAM_ADDR,			//	SDRAM Address bus 12 Bits
	output			DRAM_LDQM,			//	SDRAM Low-byte Data Mask 
	output			DRAM_UDQM,			//	SDRAM High-byte Data Mask
	output			DRAM_WE_N,			//	SDRAM Write Enable
	output			DRAM_CAS_N,			//	SDRAM Column Address Strobe
	output			DRAM_RAS_N,			//	SDRAM Row Address Strobe
	output			DRAM_CS_N,			//	SDRAM Chip Select
	output			DRAM_BA_0,			//	SDRAM Bank Address 0
	output			DRAM_BA_1,			//	SDRAM Bank Address 0
	output			DRAM_CLK,			//	SDRAM Clock
	output			DRAM_CKE,			//	SDRAM Clock Enable
	////////////////////////	Flash Interface	////////////////////////
	inout	 [7:0]	FL_DQ,				//	FLASH Data bus 8 Bits
	output [21:0]	FL_ADDR,				//	FLASH Address bus 22 Bits
	output			FL_WE_N,				//	FLASH Write Enable
	output			FL_RST_N,			//	FLASH Reset
	output			FL_OE_N,				//	FLASH Output Enable
	output			FL_CE_N,				//	FLASH Chip Enable
	////////////////////////	SRAM Interface	////////////////////////
	inout	 [15:0]	SRAM_DQ,				//	SRAM Data bus 16 Bits
	output [17:0]	SRAM_ADDR,			//	SRAM Address bus 18 Bits
	output			SRAM_UB_N,			//	SRAM High-byte Data Mask 
	output			SRAM_LB_N,			//	SRAM Low-byte Data Mask 
	output			SRAM_WE_N,			//	SRAM Write Enable
	output			SRAM_CE_N,			//	SRAM Chip Enable
	output			SRAM_OE_N,			//	SRAM Output Enable
	////////////////////	SD Card Interface	////////////////////////
	inout				SD_DAT,				//	SD Card Data
	inout				SD_DAT3,				//	SD Card Data 3
	inout				SD_CMD,				//	SD Card Command Signal
	output			SD_CLK,				//	SD Card Clock
	////////////////////////	I2C		////////////////////////////////
	inout				I2C_SDAT,			//	I2C Data
	output			I2C_SCLK,			//	I2C Clock
	////////////////////////	PS2		////////////////////////////////
	input		 		PS2_DAT,				//	PS2 Data
	input				PS2_CLK,				//	PS2 Clock
	////////////////////	USB JTAG link	////////////////////////////
	input  			TDI,					// CPLD -> FPGA (data in)
	input  			TCK,					// CPLD -> FPGA (clk)
	input  			TCS,					// CPLD -> FPGA (CS)
	output 			TDO,					// FPGA -> CPLD (data out)
	////////////////////////	VGA			////////////////////////////
	output			VGA_HS,				//	VGA H_SYNC
	output			VGA_VS,				//	VGA V_SYNC
	output	[3:0]	VGA_R,   			//	VGA Red[3:0]
	output	[3:0]	VGA_G,	 			//	VGA Green[3:0]
	output	[3:0]	VGA_B,   			//	VGA Blue[3:0]
	////////////////////	Audio CODEC		////////////////////////////
	inout				AUD_ADCLRCK,		//	Audio CODEC ADC LR Clock
	input				AUD_ADCDAT,			//	Audio CODEC ADC Data
	inout				AUD_DACLRCK,		//	Audio CODEC DAC LR Clock
	output			AUD_DACDAT,			//	Audio CODEC DAC Data
	inout				AUD_BCLK,			//	Audio CODEC Bit-Stream Clock
	output			AUD_XCK,				//	Audio CODEC Chip Clock
	////////////////////////	GPIO	////////////////////////////////
	inout	[35:0]	GPIO_0,				//	GPIO Connection 0
	inout	[35:0]	GPIO_1				//	GPIO Connection 1
);




rom	rom_inst (
	.clock ( CLK_DIV[0] ),
	.address ( CPU_ADDR[11:0] ),
	.q ( ROM_DATA )
);
wire [7:0] ROM_DATA/*synthesis keep*/;

internal_ram	internal_ram_inst (
	.clock ( SYS_CLK ),
	
	.address ( CPU_ADDR[6:0] ),
	
	.data ( CPU_DATA_OUT ),
	.wren ( INT_RAM_CS && !CPU_RW ),
	.q ( INT_RAM_DATA )
);
wire [7:0] INT_RAM_DATA;


ram	ram_inst (
	.clock ( SYS_CLK ),

	.address ( CPU_ADDR[10:0] ),
	
	.data ( CPU_DATA_OUT ),
	.wren ( RAM_CS && !CPU_RW ),
	.q ( RAM_DATA )
);
wire [7:0] RAM_DATA/*synthesis keep*/;




wire IO_CS  = (CPU_ADDR>=16'h0000 && CPU_ADDR<=16'h001F)/*synthesis keep*/;		// "IO" here, meaning all of the internal CPU regs.

wire GA_CS  = (CPU_ADDR>=16'h0020 && CPU_ADDR<=16'h003F)/*synthesis keep*/;		

wire INT_RAM_CS = (CPU_ADDR>=16'h0080 && CPU_ADDR<=16'h00FF)/*synthesis keep*/;	// Made the internal RAM separate now, since I'm confident that the external is mapped higher up.

wire RAM_CS = (CPU_ADDR>=16'h0800 && CPU_ADDR<=16'h0FFF)/*synthesis keep*/;		// Pretty sure the external SRAM is mapped from 0x800 to 0xFFF,
																											// since the start of code clears the range from 0x800 to 0x690.

wire ROM_CS = (CPU_ADDR>=16'hF000 && CPU_ADDR<=16'hFFFF)/*synthesis keep*/;		// The Roland ROM is only 4KB, and the reset vector jumps to 0xF000 as well.

assign GPIO_0[35] = IO_CS;

wire [7:0] MPU_DATA = 8'h00;
//wire [7:0] MPU_CMD = {1'b0, !KEY[3], 6'b000000};
wire [7:0] MPU_CMD = 8'h85;

//wire [7:0] GA_CONT = 8'h00;
//wire [7:0] GA_MUX = (CPU_ADDR==16'h0020) ? MPU_DATA :
//						  (CPU_ADDR==16'h0021) ? MPU_CMD :
//						  (CPU_ADDR==16'h0030) ? GA_CONT : 8'h00;


wire CPU_RW/*synthesis keep*/;
wire CPU_VMA/*synthesis keep*/;

wire [15:0] CPU_ADDR/*synthesis keep*/;

wire [7:0] CPU_DATA_IN = (IO1_DIR_CS) ? IO1_DIR :
								 (IO2_DIR_CS) ? IO2_DIR :
								 //(IO1_DATA_CS) ? IO1_PORT :
								 (IO1_DATA_CS) ? 8'h80 :			// TESTING !! The MIDI / serial int routine seems to check the MSB of Port 1
																			// to determine whether it should re-transmit the incoming MIDI data? OzOnE.
								 (IO2_DATA_CS) ? IO2_PORT :
								 (IO3_DIR_CS) ? IO3_DIR :
								 (IO4_DIR_CS) ? IO4_DIR :
								 (IO3_DATA_CS) ? IO3_PORT :
								 (IO4_DATA_CS) ? IO4_PORT :
								 
								 (CTR_HIGH_CS) ? CTR_REG[15:8] :
								 (CTR_LOW_CS) ? CTR_REG[7:0] :
								 								 
								 (SCI_INT && CPU_ADDR==16'hFFF8) ? 8'hFC :	// Kludge, to point the normal IRQ vector at the SCI (MIDI IN / OUT) routine.
								 (SCI_INT && CPU_ADDR==16'hFFF9) ? 8'h7C :
								 
								 (TMR_INT && CPU_ADDR==16'hFFF8) ? 8'hFF :	// Kludge, to point the normal IRQ vector at the Timer Overflow interrupt routine.
								 (TMR_INT && CPU_ADDR==16'hFFF9) ? 8'hE0 :

 								 (OCC_INT && CPU_ADDR==16'hFFF8) ? 8'hFE :	// Kludge, to point the normal IRQ vector at the OCC (Output Capture / Compare) routine.
								 (OCC_INT && CPU_ADDR==16'hFFF9) ? 8'hA2 :
								 
								 (ICC_INT && CPU_ADDR==16'hFFF8) ? 8'hFE :	// Kludge, to point the normal IRQ vector at the ICC (Input Capture / Compare) routine.
								 (ICC_INT && CPU_ADDR==16'hFFF9) ? 8'h75 :

								 (TX_RX_CS) ? 8'h80 :
								 (RXDATA_CS) ? RXD_DATA :
								 
								 //(GA_CS) ? GA_MUX :
								 (CPU_ADDR==16'h0020) ? MPU_DATA :
								 (CPU_ADDR==16'h0021) ? MPU_CMD :
								 
								 (INT_RAM_CS) ? INT_RAM_DATA :
								 (RAM_CS) ? RAM_DATA :
								 (ROM_CS) ? ROM_DATA : 8'h00/*synthesis keep*/;
						
wire [7:0] CPU_DATA_OUT/*synthesis keep*/;


cpu68 cpu68_inst
(
	.clk( SYS_CLK ) ,				// input  clk
	.rst( !KEY[0] ) ,				// input  rst (active HIGH!!!!!!!!!!!!!!!!!!)
	
	.rw( CPU_RW ) ,				// output  rw
	.vma( CPU_VMA ) ,				// output  vma
	
	.address( CPU_ADDR ) ,		// output [15:0] address
	
	.data_in( CPU_DATA_IN ) ,	// input [7:0] data_in
	.data_out( CPU_DATA_OUT ) ,// output [7:0] data_out
	
	.hold( 1'b0 ) ,// input  hold
	.halt( 1'b0 ) ,// input  halt
	
	// Roland MPU-401 does NOT use the /IRQ or /NMI pins!
	// (the ROM vectors for those just point to 0xF000 again.)
	//
	// The extra four vectors for the ICF, OCF, TOF, and SCI need to be implemented on
	// this CPU core before we can handle everything that the Hitachi HD6801 does! OzOnE.
	//
	.irq( SCI_INT | TMR_INT | OCC_INT | ICC_INT) ,	// input  irq
	.nmi( 1'b0 ) 	// input  nmi
);




wire IO1_DIR_CS   = (CPU_ADDR==16'h0000)/*synthesis keep*/;
wire IO2_DIR_CS   = (CPU_ADDR==16'h0001)/*synthesis keep*/;
wire IO1_DATA_CS  = (CPU_ADDR==16'h0002)/*synthesis keep*/;
wire IO2_DATA_CS  = (CPU_ADDR==16'h0003)/*synthesis keep*/;
wire IO3_DIR_CS   = (CPU_ADDR==16'h0004)/*synthesis keep*/;
wire IO4_DIR_CS   = (CPU_ADDR==16'h0005)/*synthesis keep*/;
wire IO3_DATA_CS  = (CPU_ADDR==16'h0006)/*synthesis keep*/;
wire IO4_DATA_CS  = (CPU_ADDR==16'h0007)/*synthesis keep*/;

wire TIMER_CS  	= (CPU_ADDR==16'h0008)/*synthesis keep*/;	// TCSR (Timer Control and Status Register).
wire CTR_HIGH_CS  = (CPU_ADDR==16'h0009)/*synthesis keep*/;
wire CTR_LOW_CS 	= (CPU_ADDR==16'h000A)/*synthesis keep*/;
wire OCC_HIGH_CS	= (CPU_ADDR==16'h000B)/*synthesis keep*/;

wire OCC_LOW_CS	= (CPU_ADDR==16'h000C)/*synthesis keep*/;
wire ICC_HIGH_CS	= (CPU_ADDR==16'h000D)/*synthesis keep*/;
wire ICC_LOW_CS	= (CPU_ADDR==16'h000E)/*synthesis keep*/;
wire P3_CONT_CS	= (CPU_ADDR==16'h000F)/*synthesis keep*/;

wire RATE_CS		= (CPU_ADDR==16'h0010)/*synthesis keep*/;
wire TX_RX_CS		= (CPU_ADDR==16'h0011)/*synthesis keep*/;
wire RXDATA_CS		= (CPU_ADDR==16'h0012)/*synthesis keep*/;
wire TXDATA_CS		= (CPU_ADDR==16'h0013)/*synthesis keep*/;

wire RAM_CONT_CS	= (CPU_ADDR==16'h0014)/*synthesis keep*/;


assign LEDR = {IO1_PORT[1:0], IO2_PORT};

assign LEDG = IO3_PORT;

SEG7_LUT_4 SEG7_LUT_4_inst
(
	.oSEG0( HEX0 ) ,	// output [6:0] oSEG0
	.oSEG1( HEX1 ) ,	// output [6:0] oSEG1
	.oSEG2( HEX2 ) ,	// output [6:0] oSEG2
	.oSEG3( HEX3 ) ,	// output [6:0] oSEG3
	.iDIG( CPU_ADDR ) 	// input [15:0] iDIG
);


reg [7:0] IO1_DIR;
reg [7:0] IO2_DIR;
reg [7:0] IO1_PORT;
reg [7:0] IO2_PORT;

reg [7:0] IO3_DIR;
reg [7:0] IO4_DIR;
reg [7:0] IO3_PORT;
reg [7:0] IO4_PORT;

reg [7:0] TIMER_CONT_REG;

reg [15:0] CTR_REG;

reg [15:0] OCC_REG;

reg [15:0] ICC_REG;

reg [7:0] P3_CONT_REG;

reg [7:0] RATE_REG;
reg [7:0] TX_RX_REG;
reg [7:0] RXDATA_REG;
reg [7:0] TXDATA_REG;

reg [7:0] RAM_CONT_REG;


wire MIDI_IN = GPIO_1[0];


async_receiver async_receiver_inst
(
	.clk( SYS_CLK ) ,	// input  clk
	.RxD( MIDI_IN ) ,	// input  RxD
	
	.RxD_data_ready( RXD_DATA_READY ) ,	// output  RxD_data_ready
	.RxD_data( RXD_DATA ) ,	// output [7:0] RxD_data
	.RxD_endofpacket( RXD_EOF ) ,	// output  RxD_endofpacket
	.RxD_idle( RXD_IDLE ) 	// output  RxD_idle
);
wire [7:0] RXD_DATA;
wire RXD_DATA_READY;
wire RXD_EOF;
wire RXD_IDLE;


reg SCI_INT/*synthesis keep*/;
reg ICC_INT/*synthesis keep*/;
reg TMR_INT/*synthesis keep*/;
reg OCC_INT/*synthesis keep*/;

reg [1:0] TIMER_DIV;

always @(posedge SYS_CLK or negedge KEY[0])
if (!KEY[0]) begin
	IO1_DIR <= 8'h00;
	IO1_PORT <= 8'h00;
	IO2_DIR <= 8'h00;
	IO2_PORT <= 8'h00;
	IO3_DIR <= 8'h00;
	IO3_PORT <= 8'h00;
	IO4_DIR <= 8'h00;
	IO4_PORT <= 8'h00;
	
	TIMER_CONT_REG <= 8'h00;	// Offset 0x8.
	
	CTR_REG <= 16'h0000;			// (16-bit). Offsets 0x9 to 0xA.
	OCC_REG <= 16'h0000;			// (16-bit). Offsets 0xB to 0xC.
	ICC_REG <= 16'h0000;			// (16-bit). Offsets 0xD to 0xE.

	P3_CONT_REG <= 8'h00;
	RATE_REG <= 8'h00;
	TX_RX_REG <= 8'h00;
//	RXDATA_REG <= 8'h00;
	TXDATA_REG <= 8'h00;

	RAM_CONT_REG <= 8'h00;
	
	SCI_INT <= 1'b0;
	ICC_INT <= 1'b0;
	OCC_INT <= 1'b0;
	TMR_INT <= 1'b0;
	
	TIMER_DIV <= 4'h0;
end
else begin
	TIMER_DIV <= TIMER_DIV + 1;
	if (TIMER_DIV==4'h0000) CTR_REG <= CTR_REG + 1;

	if (CPU_ADDR==16'h0000 && !CPU_RW) IO1_DIR <= CPU_DATA_OUT;		// Bits are 1=Output, 0=Input.
	if (CPU_ADDR==16'h0002 && !CPU_RW) IO1_PORT <= CPU_DATA_OUT;

	if (CPU_ADDR==16'h0001 && !CPU_RW) IO2_DIR <= CPU_DATA_OUT;
	//if (CPU_ADDR==16'h0003 && !CPU_RW) IO2_PORT <= {CPU_DATA_OUT[7:4], MIDI_IN, CPU_DATA_OUT[2:0]};	// Passing the MIDI data directly to RXDATA reg. This wouldn't have worked anyway.
	if (CPU_ADDR==16'h0003 && !CPU_RW) IO2_PORT <= CPU_DATA_OUT;

	if (CPU_ADDR==16'h0004 && !CPU_RW) IO3_DIR <= CPU_DATA_OUT;
	if (CPU_ADDR==16'h0006 && !CPU_RW) IO3_PORT <= CPU_DATA_OUT;

	if (CPU_ADDR==16'h0005 && !CPU_RW) IO4_DIR <= CPU_DATA_OUT;
	if (CPU_ADDR==16'h0007 && !CPU_RW) IO4_PORT <= CPU_DATA_OUT;
	
	if (TIMER_CS && !CPU_RW) TIMER_CONT_REG <= CPU_DATA_OUT;
	if (CTR_HIGH_CS && !CPU_RW) CTR_REG[15:8] <= CPU_DATA_OUT;
	if (CTR_LOW_CS && !CPU_RW) CTR_REG[7:0] <= CPU_DATA_OUT;
	if (OCC_HIGH_CS && !CPU_RW) OCC_REG[15:8] <= CPU_DATA_OUT;

	if (OCC_LOW_CS && !CPU_RW) OCC_REG[7:0] <= CPU_DATA_OUT;
	if (ICC_HIGH_CS && !CPU_RW) ICC_REG[15:8] <= CPU_DATA_OUT;
	if (ICC_LOW_CS && !CPU_RW) ICC_REG[7:0] <= CPU_DATA_OUT;
	if (P3_CONT_CS && !CPU_RW) P3_CONT_REG <= CPU_DATA_OUT;

	if (RATE_CS && !CPU_RW) RATE_REG <= CPU_DATA_OUT;
	if (TX_RX_CS && !CPU_RW) TX_RX_REG <= CPU_DATA_OUT;
//	if (RXDATA_CS && !CPU_RW) RXDATA_REG <= CPU_DATA_OUT;
	if (TXDATA_CS && !CPU_RW) TXDATA_REG <= CPU_DATA_OUT;

	if (RAM_CONT_CS && !CPU_RW) RAM_CONT_REG <= CPU_DATA_OUT;
	
	if (RXD_DATA_READY) SCI_INT <= 1'b1;		// New MIDI byte received. Trigger an interrupt!
	if (CPU_ADDR==16'hFC7C) SCI_INT <= 1'b0;	// MIDI (SCI) interrupt routine has been triggered, clear the interrupt!

	if (CTR_REG ==16'hFFFF) TMR_INT <= 1'b1;
	if (CPU_ADDR==16'hFFE3) TMR_INT <= 1'b0;
	
	if (!KEY[2]) OCC_INT <= 1'b1;
	if (CPU_ADDR==16'hFEA4) OCC_INT <= 1'b0;
	
	if (!KEY[1]) ICC_INT <= 1'b1;
	if (CPU_ADDR==16'hFE77) ICC_INT <= 1'b0;
end


/*
assign SRAM_ADDR = {2'b00, CPU_ADDR[11:0]};
assign SRAM_UB_N = !(RAM_CS && !CPU_RW);
assign SRAM_LB_N = !(RAM_CS && !CPU_RW);
assign SRAM_CE_N = 1'b0;
assign SRAM_OE_N = !(RAM_CS && CPU_RW); 
assign SRAM_WE_N = !(RAM_CS && !CPU_RW);
assign SRAM_DQ = (!CPU_RW) ? {CPU_DATA_OUT, CPU_DATA_OUT} : 16'hzzzz;
*/




//reg [31:0] FL_DATA_TEMP;
//reg [31:0] SRAM_DATA_MUX;

wire TXD_START = TXDATA_CS && !CPU_RW/*synthesis keep*/;

async_transmitter async_transmitter_inst
(
	.clk( SYS_CLK ) ,			// input  clk
	.TxD_start( TXD_START ) ,	// input  TxD_start
	.TxD_data( CPU_DATA_OUT ) ,	// input [7:0] TxD_data
	.TxD( UART_TXD ) ,		// output  TxD
	.TxD_busy( TXD_BUSY ) 	// output  TxD_busy
);
wire TXD_BUSY;


reg force_mem_stall;
reg [7:0] debug_state;
reg [7:0] run_count;
reg [15:0] pc_backup;
always @(posedge SYS_CLK or negedge KEY[0])
if (!KEY[0]) begin
	debug_state <= 0;
	pc_backup <= 32'h12345678;
	force_mem_stall <= 1'b1;
end
else begin

	case (debug_state)
	
	0: begin
		if (SW[0]) begin
			force_mem_stall <= 1'b0;			// RUN switch HIGH (active). Let CPU run.
			
			if (SW[9] && BP_MATCHED) begin	// Nice breakpoint (using the OSD, and PS/2 keyboard).
				force_mem_stall <= 1'b1;
				debug_state <= 7;
			end
			else begin
				if (SW[8]) debug_state <= 8;
//				if (TXD_BUSY) force_mem_stall <= 1'b1;
//				else force_mem_stall <= 1'b0;
			end
		end
		else begin									// RUN switch LOW (inactive!)...
			force_mem_stall <= 1'b1;
			if (!KEY[3]) begin
				debug_state <= 1;	// KEY[3] pressed (active-low)...
			end
			if (!KEY[2]) begin
				run_count <= 8'd64;
				debug_state <= 4;	// KEY[2] pressed (active-low)...
			end
		end		
	end
	
	8: begin
		force_mem_stall <= 1'b1;
		debug_state <= 0;
	end
	
	// Single-cycle...
	1: begin
		pc_backup <= CPU_ADDR;
		force_mem_stall <= 1'b0;
		debug_state <= debug_state + 1;
	end

	2: if (CPU_ADDR != pc_backup) begin		// Let CPU run, until Program Counter changes...
		force_mem_stall <= 1'b1;
		debug_state <= debug_state + 1;
	end
	
	3: begin
		if (KEY[3]) debug_state <= 0;		// Wait until KEY[3] goes HIGH (not pressed) again.
	end

	
	// Multiple cycles...
	4: begin
		pc_backup <= CPU_ADDR;
		force_mem_stall <= 1'b0;
		debug_state <= debug_state + 1;
	end

	5: if (CPU_ADDR != pc_backup) begin		// Let CPU run, until Program Counter changes...
		force_mem_stall <= 1'b1;
		debug_state <= debug_state + 1;
	end
	
	6: begin
		if (run_count>0) begin
			run_count <= run_count - 1;
			debug_state <= 4;
		end
		else begin
			if (KEY[2] & !SW[0]) debug_state <= 0;	// Wait for KEY[2] to go HIGH (not pressed), and the RUN switch to go LOW, so we can stop after the breakpoint!
		end
	end

	
	// Wait for RUN switch LOW, so we can stop after a breakpoint!
	7: begin
		if (!SW[0]) debug_state <= 0;
	end
	
	default:;
	
	endcase
end



//assign LEDG = {6'b000000, BIOS_CS, MAINRAM_CS|MAINRAM2_CS};


PLL	PLL_inst (
	.inclk0 ( CLOCK_27[0] ),
	.c0 ( DRAM_CONT_CLK ),
	.c1 ( DRAM_CLK ),
	.locked ( PLL_LOCKED )
);


reg [3:0] CLK_DIV;
always @(posedge DRAM_CONT_CLK) CLK_DIV <= CLK_DIV + 1;

wire SYS_CLK = CLK_DIV[2]/*synthesis keep*/;	// SYS_CLK needs to be 1/8th the freq of DRAM_CONT_CLK (so the SDRAM module works properly).



reg [20:0] RESET_COUNT;
initial begin
	RESET_COUNT <= 21'h2FFFFF;
	SDRAM_INIT <= 1'b1;
end


reg SDRAM_INIT;
always @(posedge SYS_CLK or negedge KEY[0]) 
if (!KEY[0]) begin
	RESET_COUNT <= 21'h2FFFFF;
	SDRAM_INIT <= 1'b1;
end
else begin
	if (RESET_COUNT>0 && PLL_LOCKED) RESET_COUNT <= RESET_COUNT - 1;
	else SDRAM_INIT <= 1'b0;
end

wire MRESET_N = RESET_COUNT==0;


assign FL_WE_N = 1'b1;
assign FL_RST_N = 1'b1;
assign FL_OE_N = 1'b0;
assign FL_CE_N = 1'b0;



/*
wire [15:0] STACK_DATA_READ;
STACK_RAM	STACK_RAM_inst (
	.clock( SYS_CLK ),
	
	//.address( BYTE_ADDR[12:2] ),
	.address( SDRAM_ADDR[9:0] ),
	
	//.byteena( {SDRAM_DS[0],SDRAM_DS[1]} ),			// If you swap the DATA byte order, you MUST swap the Byte Enables too! lol
	//.data( {SDRAM_DIN[7:0], SDRAM_DIN[15:8]} ),	// (I'm such a moron. OzOnE)
	
	// "Normal" byte order, for Indy core diag...
	.byteena( SDRAM_DS[1:0] ),	// If you swap the DATA byte order, you MUST swap the Byte Enables too! lol
	.data( SDRAM_DIN ),			// (I'm such a moron. OzOnE)

	.wren( SDRAM_WE ),

	.q( STACK_DATA_READ )
);


SCRATCH_RAM		SCRATCH_RAM_inst (
	.clock( SYS_CLK ),
	
	.address( BYTE_ADDR[10:2] ),
	
	.byteena( BYTE_ENA_BACKUP ),
	.data( WRITE_DATA_BACKUP ),
	
	.wren( (SCRATCH_CS && WRITE_STATE) ),

	.q( SCRATCH_DOUT )
);
*/

/*
reg [15:0] SDRAM_WRITE_DATA;

assign DRAM_CKE = 1'b1;
wire [21:0] SDRAM_ADDR = SDRAM_ADDR_REG;
wire [15:0] SDRAM_DIN = SDRAM_WRITE_DATA;
wire [15:0] SDRAM_DOUT;

reg [1:0] SDRAM_DS;
reg SDRAM_OE;
reg SDRAM_WE;

sdram sdram_inst
(
	// SDRAM chip interface...
	.sd_data( DRAM_DQ ) ,	// inout [15:0] sd_data
	
	.sd_addr( DRAM_ADDR ) ,	// output [11:0] sd_addr
	.sd_ba( {DRAM_BA_1, DRAM_BA_0} ) ,	// output [1:0] sd_ba
	
	.sd_dqm( {DRAM_UDQM, DRAM_LDQM} ) ,	// output [1:0] sd_dqm - ACTIVE LOW !!!
	.sd_cs( DRAM_CS_N ) ,	// output  sd_cs - ACTIVE LOW !!!
	.sd_we( DRAM_WE_N ) ,	// output  sd_we - ACTIVE LOW !!!
	.sd_ras( DRAM_RAS_N ) ,	// output  sd_ras - ACTIVE LOW !!!
	.sd_cas( DRAM_CAS_N ) ,	// output  sd_cas - ACTIVE LOW !!!
	
	
	// User-side interface...
	.init( SDRAM_INIT ) ,	// input  init
	.clk( DRAM_CONT_CLK ) ,	// input  clk
	.clkref( SYS_CLK ) ,		// input  clkref
	
	.din( SDRAM_DIN ) ,		// input [15:0] din
	.dout( SDRAM_DOUT ) ,	// output [15:0] dout
	.addr( SDRAM_ADDR ) ,	// input [21:0] addr
	
	.ds( SDRAM_DS ) ,			// input [1:0] ds	- ACTIVE HIGH!!
	.oe( SDRAM_OE ) ,			// input  oe - ACTIVE HIGH!!
	.we( SDRAM_WE ) 			// input  we - ACTIVE HIGH!!
);


wire CART_OE = (CART_CS & !SH2_WE_O);

wire SH2_SDRAM_WE = (SDRAM_CS & SH2_WE_O);
wire SH2_SDRAM_OE = (SDRAM_CS & !SH2_WE_O);



//assign SRAM_ADDR = MS_ADR_O[17:0];

//assign SRAM_UB_N = 1'b0;
//assign SRAM_LB_N = 1'b0;
//assign SRAM_CE_N = 1'b0;

//assign SRAM_OE_N = !( ( (MS_SDRAM_CS&MS_STB_O) | (SL_SDRAM_CS&SL_STB_O) ) & (!MS_WE_O | !SL_WE_O) );
//assign SRAM_WE_N = !( ( (MS_SDRAM_CS&MS_STB_O) | (SL_SDRAM_CS&SL_STB_O) ) & (MS_WE_O | SL_WE_O) );

//assign SRAM_OE_N = !SH2_SDRAM_OE;
//assign SRAM_WE_N = !SH2_SDRAM_WE;


reg [31:0] DUMMY_REG;

reg [21:0] SDRAM_ADDR_REG;
reg [15:0] SDRAM_DATA_READ;
reg [15:0] SDRAM_DATA_WRITE;

reg [31:0] SDRAM_LONG_WORD;
reg [31:0] DATA_TO_SLAVE;

reg [7:0] FL_BYTE_0;
reg [7:0] FL_BYTE_1;
reg [7:0] FL_BYTE_2;
reg [7:0] FL_BYTE_3;

reg [21:0] FL_ADDR_REG;
assign FL_ADDR = FL_ADDR_REG;

assign FL_RST_N = 1'b1;
assign FL_WE_N = 1'b1;
assign FL_OE_N = 1'b0;
assign FL_CE_N = 1'b0;


reg [3:0] SEL_O_REG;

reg [7:0] STATE;
always @(posedge SYS_CLK or negedge KEY[0])
if (!KEY[0]) begin
	STATE <= 8'd0;
	SDRAM_OE <= 1'b0;
	SDRAM_WE <= 1'b0;
	SDRAM_DS <= 2'b11;
end
else begin

	case (STATE)
	0: begin
		SH2_ACK_I <= 1'b0;
		if (SH2_CYC_O && SH2_STB_O) begin
			SEL_O_REG <= SH2_SEL_O;
			if (SH2_SDRAM_OE) begin
				SDRAM_ADDR_REG <= SH2_ADR_O[18:1];
				SDRAM_DS <= 2'b11;
				SDRAM_OE <= 1'b1;
				STATE <= 1;
			end
			else if (SH2_SDRAM_WE) begin
				SDRAM_ADDR_REG <= SH2_ADR_O[18:1];
				SDRAM_WRITE_DATA <= SH2_DAT_O[31:16];
				SDRAM_DS <= 2'b11;
				SDRAM_WE <= 1'b1;
				if (SH2_SEL_O==4'b1111) begin
					STATE <= 4;
				end
				else STATE <= 16;
			end
			else if (CART_OE) begin
				FL_ADDR_REG <= SH2_ADR_O;
				STATE <= 9;
			end
			else STATE <= 16;
		end
	end
	
	// SDRAM READ...
	1: begin
		SDRAM_LONG_WORD[15:0] <= SDRAM_DOUT;
		if (SH2_SEL_O==4'b1111) begin
			SDRAM_OE <= 1'b1;
			SDRAM_ADDR_REG <= SDRAM_ADDR_REG + 1;
			STATE <= 2;
		end
		else begin
			SDRAM_OE <= 1'b0;
			STATE <= 16;
		end
	end

	2: begin
		SDRAM_LONG_WORD[31:16] <= SDRAM_DOUT;
		SDRAM_OE <= 1'b0;
		STATE <= 16;
	end

	
	// SDRAM_WRITE...
	4: begin
		SDRAM_ADDR_REG <= SDRAM_ADDR_REG + 1;
		SDRAM_WRITE_DATA <= SH2_DAT_O[15:0];
		SDRAM_WE <= 1'b1;
		STATE <= 16;
	end

	
	// FLASH READ...
	9: begin
		FL_BYTE_0 <= FL_DQ;
		STATE <= STATE + 1;
	end
	
	10: begin
		FL_ADDR_REG <= FL_ADDR_REG + 1;
		STATE <= STATE + 1;
	end
	
	11: begin
		FL_BYTE_1 <= FL_DQ;
		//STATE <= STATE + 1;
		STATE <= STATE + 1;
	end
	
	12: begin
		FL_ADDR_REG <= FL_ADDR_REG + 1;
		STATE <= STATE + 1;
	end

	13: begin
		FL_BYTE_2 <= FL_DQ;
		STATE <= STATE + 1;
	end
	
	14: begin
		FL_ADDR_REG <= FL_ADDR_REG + 1;
		STATE <= STATE + 1;
	end
	
	15: begin
		FL_BYTE_3 <= FL_DQ;
		STATE <= STATE + 1;
	end


	// Return state...
	16: begin
		SDRAM_OE <= 1'b0;
		SDRAM_WE <= 1'b0;
//		STATE <= STATE + 1;
//	end

//	17: begin
		if (!force_mem_stall) begin
			SH2_ACK_I <= 1'b1;
			STATE <= STATE + 1;
		end
	end
	
	17: begin
		SH2_ACK_I <= 1'b0;
		STATE <= STATE + 1;
	end

	18: begin
		MASTER_SEL <= !MASTER_SEL;	// Swap between Master and Slave SH2! TESTING !!!!!!!!!!!!!!
		STATE <= 0;
	end

	default: ;
	endcase

end
*/



wire [23:0] PATT_RGB;
wire PATT_HS_N;
wire PATT_VS_N;
wire [11:0] X_OUT;
wire [11:0] Y_OUT;
top_sync_vg_pattern top_sync_vg_pattern_inst
(
//	.clk_27m( CLK_27M ) ,		// input  clk_27m
	.clk_74m( DRAM_CONT_CLK ) ,// input  clk_74m
//	.clk_148m( CLK_148M ) ,		// input  clk_148m
	.resetb( PLL_LOCKED ) ,		// input  resetb
	.adv7513_hs_n( PATT_HS_N ) ,	// output  adv7513_hs_n
	.adv7513_vs_n( PATT_VS_N ) ,	// output  adv7513_vs_n
	.adv7513_clk( PATT_CLK ) ,		// output  adv7513_clk
	.adv7513_d( PATT_RGB ) ,		// output [23:0] adv7513_d
//	.adv7513_de( adv7513_de ) ,	// output  adv7513_de
	.x_out( X_OUT ) ,		// output [11:0] x_out
	.y_out( Y_OUT ) 		// output [11:0] y_out
);



wire CMD_ADDR  = (CPU_ADDR>=16'h0900 && CPU_ADDR<=16'h0954 && !CPU_RW);
wire DAT1_ADDR = (CPU_ADDR>=16'h0955 && CPU_ADDR<=16'h09A9 && !CPU_RW);
wire DAT2_ADDR = (CPU_ADDR>=16'h09AA && CPU_ADDR<=16'h09FF && !CPU_RW);

wire [4:0] CHAR_WR_ADDR = (CMD_ADDR) ? CPU_ADDR-16'h0900 :
								  (DAT1_ADDR) ? CPU_ADDR-16'h0955 :
													 CPU_ADDR-16'h09AA;

wire [31:0] CHAR_IN = {CPU_DATA_OUT,CPU_DATA_OUT,CPU_DATA_OUT,CPU_DATA_OUT};

wire CHAR_WREN =  CMD_ADDR | DAT1_ADDR | DAT2_ADDR;

wire [3:0] CHAR_BYTEENA = {CMD_ADDR, DAT1_ADDR, DAT2_ADDR, 1'b0};


							 
wire [23:0] OSD_RGB;
wire OSD_FRAME;
wire CHARBIT;
OSD OSD_inst
(
	.clk( PATT_CLK ) ,				// input  clk
	.reset_n( KEY[0] ) ,				// input  reset_n
	.pixel( X_OUT ) ,					// input [11:0] pixel
	.line( Y_OUT ) ,					// input [11:0] line
	.vid_in( PATT_RGB ) ,			// input [23:0] vid_in
	.vid_out( OSD_RGB ) ,			// output [23:0] vid_out
	.osd_enable( 1'b1 ) ,			// input osd_enable
//	.total_lines(total_lines) ,	// input [15:0] total_lines

	.write_clk( SYS_CLK ) ,			// input write_clk
	
	.char_wr_addr( CHAR_WR_ADDR ) ,	// input [4:0] char_wr_addr
	.char_in( CHAR_IN ) ,		   	// input [31:0] char_in
	.char_wren( CHAR_WREN ) , 			// input  char_wren
	.char_byteena( CHAR_BYTEENA ) ,	// input [3:0] char_byteena
	
	.if_pc( MS_ADR_O ) ,				// input [31:0] if_pc
	.cpu_data( MS_DAT_I ) ,			// input [31:0] cpu_data
	
	.BIU( BIU_REG ) ,					// input [31:0] BIO
	
	.string0( string0 ) ,			// input [63:0] string0

	.RXDATA( RXDATA ) ,
	.KEY_PRESSED( KEY_PRESSED ) ,
	.KEY_RELEASED( KEY_RELEASED ) ,
	
	.BP_MATCHED( BP_MATCHED ) ,

	.osd_frame_out( OSD_FRAME ) ,	// output osd_frame
	.charbit( CHARBIT )				// output charbit
);


parameter WINDOW_X = 258+2;
parameter WINDOW_Y = 64;

wire [10:0] WINDOW_WIDTH  = 1024/* + source*/;
parameter WINDOW_HEIGHT = 512;


/*
wire [7:0] probe;
wire [7:0] source;
source	source_inst (
	.probe ( probe ),
	.source ( source )
);
*/

reg PS1_WINDOW;
reg PS1_WINDOW_1;
reg [10:0] PS1_PIX;
reg [10:0] PS1_LINE;

reg [15:0] SRAM_PIXEL_DATA;
always @(posedge PATT_CLK) begin
	PS1_WINDOW_1 <= PS1_WINDOW;
	
	if (!PATT_VS_N) begin
		PS1_LINE <= 0;
		PS1_PIX <= 0;
	end
	else begin
		if (PS1_WINDOW_1 & !PS1_WINDOW) begin
			//PS1_PIX <= 0;
			PS1_LINE <= PS1_LINE + 1;
		end
		else if (PS1_WINDOW) begin
			PS1_PIX <= PS1_PIX + 1;		
		end
	end
	
	PS1_WINDOW <= (X_OUT>=WINDOW_X && X_OUT<=WINDOW_X+WINDOW_WIDTH-1 && Y_OUT>=WINDOW_Y && Y_OUT<=WINDOW_Y+WINDOW_HEIGHT-1);
	SRAM_PIXEL_DATA <= SRAM_DQ;
end

assign VGA_R = (PS1_WINDOW) ? SRAM_PIXEL_DATA[4:1] : OSD_RGB[23:20];
assign VGA_G = (PS1_WINDOW) ? SRAM_PIXEL_DATA[9:6]  : OSD_RGB[15:12];
assign VGA_B = (PS1_WINDOW) ? SRAM_PIXEL_DATA[14:11] : OSD_RGB[7:4];

assign VGA_HS = PATT_HS_N;
assign VGA_VS = PATT_VS_N;

//assign SRAM_UB_N = 1'b0;
//assign SRAM_LB_N = 1'b0;

//assign SRAM_WE_N = (RESET_COUNT>0) ? !GPU_DACK : VRAM_WE_N;
//assign SRAM_WE_N = 1'b1;
wire VRAM_WE_N = 1'b1;

//assign SRAM_OE_N = DMA2_ACTIVE;		// Allow SRAM reads (to VGA) while DMA2 is NOT active.
//assign SRAM_OE_N = 1'b0;		// Allow SRAM reads (to VGA) while DMA2 is NOT active.


wire [18:0] MY_SRAM_ADDR = /*(RESET_COUNT>0) ? DMA_BYTE_ADDR[19:1] :*/
									/*(!VRAM_WE_N) ? VRAM_ADDR : */
									{PS1_LINE[8:0], PS1_PIX[9:0]};

/*
wire [18:0] MY_SRAM_ADDR = (RESET_COUNT>0) ? DMA_BYTE_ADDR[19:1] :	// TESTING!! (bypass FPGA GPU for now. Testing real PS1 GPU on GPIO). OzOnE.
									(DMA2_ACTIVE) ? DMA_BYTE_ADDR[19:1] : 
									{PS1_LINE[8:0], PS1_PIX[9:0]};
*/								

//assign SRAM_ADDR = MY_SRAM_ADDR[17:0]; // Lower 512KB (original onboard SRAM on DE1).


//assign SRAM_CE_N = MY_SRAM_ADDR[18];	// Lower 512KB (original onboard SRAM on DE1).
//assign GPIO_0[35] = !MY_SRAM_ADDR[18];	// Upper 512KB (piggy-backed chip!)
							

//assign SRAM_DQ = /*(GPU_DACK && RESET_COUNT>0) ? 16'hF000 :*/
//					  /*(!VRAM_WE_N) ? VRAM_DATA :*/ 16'hzzzz;


//assign SRAM_DQ = (SH2_SDRAM_WE) ? MS_DAT_I : 16'hzzzz;
					  
/*
assign SRAM_DQ = (GPU_DACK && RESET_COUNT>0) ? 16'hF000 :	// TESTING!! (bypass FPGA GPU for now. Testing real PS1 GPU on GPIO). OzOnE.
					  (DMA2_ACTIVE) ? SDRAM_DOUT : 16'hzzzz;
*/
					  
wire [7:0] RXDATA;
keyboard keyboard_inst
(
	.CLK( SYS_CLK ) ,				// input  CLK

	.PS2_CLK( PS2_CLK ) ,		// input  PS2_CLK
	.PS2_DAT( PS2_DAT ) ,		// input  PS2_DATA

	.RXDATA( RXDATA ) ,				// output [7:0] RXDATA
	
	.KEY_PRESSED( KEY_PRESSED ) ,		// output  KEY_PRESSED
	.KEY_RELEASED( KEY_RELEASED ) ,	// output  KEY_RELEASED
	
	.UP_PULSE( UP_PULSE ) ,		// output  UP_PULSE
	.DOWN_PULSE( DOWN_PULSE ) ,// output  DOWN_PULSE
	.LEFT_PULSE( LEFT_PULSE ) ,// output  LEFT_PULSE
	.RIGHT_PULSE( RIGHT_PULSE )// output  RIGHT_PULSE
);



wire [6:0] rf_cmd;

/*
wire [63:0] string0 = (rf_cmd == `CMD_null)			? "null    " :
							 (rf_cmd == `CMD_3arg_add)		? "3argadd " :
							 (rf_cmd == `CMD_3arg_addu)	? "3argaddu" :
							 (rf_cmd == `CMD_3arg_and)		? "3argand " :
							 (rf_cmd == `CMD_3arg_nor)		? "3argnor " :
							 (rf_cmd == `CMD_3arg_or)		? "3argor  " :
							 (rf_cmd == `CMD_3arg_slt)		? "3argslt " :
							 (rf_cmd == `CMD_3arg_sltu)	? "3argsltu" :
							 (rf_cmd == `CMD_3arg_sub)		? "3argsub " :
							 (rf_cmd == `CMD_3arg_subu)	? "3argsubu" :
							 (rf_cmd == `CMD_3arg_xor)		? "3argxor " :
							 (rf_cmd == `CMD_3arg_sllv)	? "3argsllv" :
							 (rf_cmd == `CMD_3arg_srav)	? "3argsrav" :
							 (rf_cmd == `CMD_3arg_srlv)	? "3argsrlv" :
							 (rf_cmd == `CMD_sll)			? "sll     " :
							 (rf_cmd == `CMD_sra)			? "sra     " :
							 (rf_cmd == `CMD_srl)			? "srl     " :
							 (rf_cmd == `CMD_addi)			? "addi    " :
							 (rf_cmd == `CMD_addiu)			? "addiu   " :
							 (rf_cmd == `CMD_andi)			? "andi    " :
							 (rf_cmd == `CMD_ori)			? "ori     " :
							 (rf_cmd == `CMD_slti)			? "slti    " :
							 (rf_cmd == `CMD_sltiu)			? "sltiu   " :
							 (rf_cmd == `CMD_xori)			? "xori    " :
							 (rf_cmd == `CMD_muldiv_mfhi)	? "md_mfhi " :
							 (rf_cmd == `CMD_muldiv_mflo)	? "md_mflo " :
							 (rf_cmd == `CMD_muldiv_mthi)	? "md_mthi " :
							 (rf_cmd == `CMD_muldiv_mtlo)	? "md_mtlo " :
							 (rf_cmd == `CMD_muldiv_mult)	? "md_mult " :
							 (rf_cmd == `CMD_muldiv_multu)? "md_multu" :
							 (rf_cmd == `CMD_muldiv_div)	? "md_div  " :
							 (rf_cmd == `CMD_muldiv_divu)	? "md_divu " :
							 (rf_cmd == `CMD_lui)			? "lui     " :
							 (rf_cmd == `CMD_break)			? "break   " :
							 (rf_cmd == `CMD_syscall)		? "syscall " :
							 (rf_cmd == `CMD_mtc0)			? "mtc0    " :
							 (rf_cmd == `CMD_mfc0)			? "mfc0    " :
							 (rf_cmd == `CMD_cfc1_detect)	? "cfc1_dtc" :
							 (rf_cmd == `CMD_cp0_rfe)		? "cp0rfe  " :
							 (rf_cmd == `CMD_cp0_tlbp)		? "cp0tlbp " :
							 (rf_cmd == `CMD_cp0_tlbr)		? "cp0tlbr " :
							 (rf_cmd == `CMD_cp0_tlbwi)	? "cp0tlbwi" :
							 (rf_cmd == `CMD_cp0_tlbwr)	? "cp0tlbwr" :
							 (rf_cmd == `CMD_lb)				? "lb      " :
							 (rf_cmd == `CMD_lbu)			? "lbu     " :
							 (rf_cmd == `CMD_lh)				? "lh      " :
							 (rf_cmd == `CMD_lhu)			? "lhu     " :
							 (rf_cmd == `CMD_lw)				? "lw      " :
							 (rf_cmd == `CMD_lwl)			? "lwl     " :
							 (rf_cmd == `CMD_lwr)			? "lwr     " :
							 (rf_cmd == `CMD_sb)				? "sb      " :
							 (rf_cmd == `CMD_sh)				? "sh      " :
							 (rf_cmd == `CMD_sw)				? "sw      " :
							 (rf_cmd == `CMD_swl)			? "swl     " :
							 (rf_cmd == `CMD_swr)			? "swr     " :
							 (rf_cmd == `CMD_beq)			? "beq     " :
							 (rf_cmd == `CMD_bne)			? "bne     " :
							 (rf_cmd == `CMD_bgez)			? "bgez    " :
							 (rf_cmd == `CMD_bgtz)			? "bgtz    " :
							 (rf_cmd == `CMD_blez)			? "blez    " :
							 (rf_cmd == `CMD_bltz)			? "bltz    " :
							 (rf_cmd == `CMD_jr)				? "jr      " :
							 (rf_cmd == `CMD_bgezal)		? "bgezal  " :
							 (rf_cmd == `CMD_bltzal)		? "bltzal  " :
							 (rf_cmd == `CMD_jalr)			? "jalr    " :
							 (rf_cmd == `CMD_jal)			? "jal     " :
							 (rf_cmd == `CMD_j)				? "j       " :
							 (rf_cmd == `CMD_cp0_bc0f)		? "cp0bc0f " :
							 (rf_cmd == `CMD_cp0_bc0t)		? "cp0bc0t " :
							 (rf_cmd == `CMD_cp0_bc0_ign)	? "cp0bc0in" :

							 (rf_cmd == `CMD_exc_coproc_unusable)	? "copro_un" :
							 (rf_cmd == `CMD_exc_reserved_instr)	? "reserved" :
							 (rf_cmd == `CMD_exc_int_overflow)		? "int_over" :
							 (rf_cmd == `CMD_exc_load_addr_err)		? "load_adr" :
							 (rf_cmd == `CMD_exc_store_addr_err)	? "stor_adr" :
							 (rf_cmd == `CMD_exc_load_tlb)			? "load_tlb" :
							 (rf_cmd == `CMD_exc_store_tlb)			? "stor_tlb" :
							 (rf_cmd == `CMD_exc_tlb_load_miss)		? "tlb_load" :
							 (rf_cmd == `CMD_exc_tlb_store_miss)	? "tlb_stor" :
							 (rf_cmd == `CMD_exc_tlb_modif)			? "tlb_modi" :

							 (rf_cmd == `CMD_mtc2)						? "mtc2    " :
							 (rf_cmd == `CMD_mfc2)						? "mfc2    " : "        ";
*/		 
							 
endmodule
