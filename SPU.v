module SPU(
	input RESET_N,

	input SYS_CLK,
	
	input SPU_CS,	// Active HIGH!!
	input SPU_WE,	// Active HIGH!!
	input SPU_OE,	// Active HIGH!!
	
	input [8:0] CPU_ADDR,
	inout [31:0] CPU_DATA,
	
	
	output [17:0] SPU_RAM_ADDR,
	inout  [15:0] SPU_RAM_DATA,
	
	output SPU_RAM_WE_N,	// Active LOW!!
	output SPU_RAM_OE_N,	// Active LOW!!
	
	input [15:0] CD_AUDIO_IN_L,
	input [15:0] CD_AUDIO_IN_R,
	
	output [15:0] AUDIO_OUT_L,
	output [15:0] AUDIO_OUT_R
);

// SPU Notes...
//
// Each SPU Voice consists of eight 16-bit registers...
//
// (some regs are 32-bit, but not sure yet if the CPU can access that as one 32-bit Word? Probably? OzOnE).
//
// Voice 0...
//
// 0x1F801C00 = [15:0]  VOL_L. [15]=0=Volume Mode. [14:1]=Voice volume/2. (-4000h..+3FFFh = Volume -8000h..+7FFEh). [15]=1=Sweep mode.
// 0x1F801C02 = [15:0]  VOL_R. [15]=0=Volume Mode. [14:1]=Voice volume/2. (-4000h..+3FFFh = Volume -8000h..+7FFEh). [15]=1=Sweep mode.
// 0x1F801C04 = [15:0]  ADPCM_SAMPLE_RATE. Sample rate (0=stop, 4000h=fastest, 4001h..FFFFh=usually same as 4000h)
// 0x1F801C06 = [15:0]  ADPCM_START_ADDR.  Startaddress of sound in Sound buffer (in 8-byte units)
// 0x1F801C08 = [15:0]  ADSR (32-bit, lower 16-bit Word).
// 0x1F801C0A = [31:16] ADSR (32-bit, upper 16-bit Word).
// 0x1F801C0C = [15:0]  ADSR_CURRENT_VOL. Current ADSR Volume  (0..+7FFFh) (or -8000h..+7FFFh on manual write)
// 0x1F801C0E = [15:0]  ADSR_REPEAT_ADDR. Address sample loops to at end (in 8-byte units)
//
// Voice 1 starts at 0x1F081C10. Voice 2 starts at 0x1F081C20. etc.
//
// So, essentially, the Voice slot number is nibble "V", and the parameter addr for that Voice is nibble "P"...
// 0x1F801CVP
//
// Then, there are the SPU control regs, then the reverb regs etc.
//

/*
// Will probably need to implement the VOICE register file as a RAM. OzOnE.
reg [15:0] V0_VOL_L;
reg [15:0] V0_VOL_R;
reg [15:0] V0_ADPCM_SAMP_RATE;
reg [15:0] V0_ADPCM_START_ADDR;
reg [15:0] V0_ADSR_LOWER;
reg [15:0] V0_ADSR_UPPER;
reg [15:0] V0_ADSR_CURR_VOL;
reg [15:0] V0_ADSR_REPEAT_ADDR;
*/

wire VOICE_RAM_WREN = (SPU_CS && SPU_WE);

SPU_VOICE_RAM	SPU_VOICE_RAM_inst (
	.address ( CPU_ADDR[5:0] ),
	.clock ( SYS_CLK ),
	.data ( VOICE_RAM_IN ),
	.wren ( VOICE_RAM_WREN ),
	.q ( VOICE_RAM_OUT )
);
wire [31:0] VOICE_RAM_IN = CPU_DATA;
wire [31:0] VOICE_RAM_OUT/*synthesis keep*/;


reg [31:0] SPU_DATA_OUT_REG;

assign CPU_DATA = (SPU_OE) ? SPU_DATA_OUT_REG : 32'hzzzzzzzz;


always @(posedge SYS_CLK or negedge RESET_N)
if (!RESET_N) begin

end
else begin




end



endmodule
