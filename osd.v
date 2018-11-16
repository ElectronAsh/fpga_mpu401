module  OSD (
	input clk,

	input reset_n,
	
	input [11:0] pixel,
	input [11:0] line,		// Note: line count will repeat twice per frame (on both the odd AND even fields)!

	input [23:0] vid_in,
	output reg [23:0] vid_out,
	
	input wire osd_enable,

	input wire [15:0] total_lines,
	
	input wire write_clk,
	input wire [31:0] char_in,
	input wire [4:0] char_wr_addr,
	input wire char_wren,
	input wire [3:0] char_byteena,
	
	input wire [31:0] if_pc,
	input wire [31:0] cpu_data,
	
	input wire [31:0] BIU,
	
	input wire [63:0] string0,
	
	input wire [7:0] RXDATA,
	
	input wire KEY_PRESSED,
	input wire KEY_RELEASED,
	
	output wire BP_MATCHED,
	
	output reg osd_frame_out,
	
	output reg charbit
);
	
	wire [7:0] font_data;

	wire [31:0] ram_out;
	
	reg [10:0] char_pixel;
	reg [9:0] char_line;
	
	reg [10:0] count;


wire [7:0] row = {font_data[0],font_data[1],font_data[2],font_data[3],font_data[4],font_data[5],font_data[6],font_data[7]}; // Need to reverse row bit order (font rom rows are MSB first)

parameter OSD_X = 128+1;
parameter OSD_Y = 64;

parameter OSD_WIDTH = 128;
parameter OSD_HEIGHT = 512-1;

reg osd_frame;

wire main_frame        = (pixel>=OSD_X &&    (pixel<=OSD_X+OSD_WIDTH) && (line>=OSD_Y) &&   (line<=OSD_Y+OSD_HEIGHT));
wire force_top_line    = (pixel>=OSD_X &&     pixel<=OSD_X+384 &&         line>=OSD_Y-32 &&  line<=OSD_Y-16);
wire force_bottom_line = (pixel>=OSD_X &&     pixel<=OSD_X+384 &&         line>=OSD_Y+528 && line<=OSD_Y+544);
wire force_left_line   = (pixel>=OSD_X-112 && pixel<=OSD_X-16 &&          line>=OSD_Y-32 &&  line<=OSD_Y+OSD_HEIGHT);

wire force_biu_line = (pixel>=OSD_X && pixel<=OSD_X+384 && line>=OSD_Y-16 && line<=OSD_Y);
wire force_pc_line  = (pixel>=OSD_X && pixel<=OSD_X+384 && line>=OSD_Y-32 && line<=OSD_Y-16);

wire [63:0] text_pc  = "    PC  ";

wire [63:0] text_biu = "   biu  ";

wire [63:0] text_r0  = "0   R0  ";
wire [63:0] text_r1  = "1   R1  ";
wire [63:0] text_r2  = "2   R2  ";
wire [63:0] text_r3  = "3   R3  ";
wire [63:0] text_r4  = "4   R4  ";
wire [63:0] text_r5  = "5   R5  ";
wire [63:0] text_r6  = "6   R6  ";
wire [63:0] text_r7  = "7   R7  ";
wire [63:0] text_r8  = "8   R8  ";
wire [63:0] text_r9  = "9   R9  ";
wire [63:0] text_r10 = "10 R10  ";
wire [63:0] text_r11 = "11 R11  ";
wire [63:0] text_r12 = "12 R12  ";
wire [63:0] text_r13 = "13 R13  ";
wire [63:0] text_r14 = "14 R14  ";
wire [63:0] text_r15 = "15 R15  ";
wire [63:0] text_r16 = "16 CM0  ";
wire [63:0] text_r17 = "17 CM1  ";
wire [63:0] text_r18 = "18 CM2  ";
wire [63:0] text_r19 = "19 CM3  ";
wire [63:0] text_r20 = "20      ";
wire [63:0] text_r21 = "21      ";
wire [63:0] text_r22 = "22      ";
wire [63:0] text_r23 = "23      ";
wire [63:0] text_r24 = "24      ";
wire [63:0] text_r25 = "25      ";
wire [63:0] text_r26 = "28      ";
wire [63:0] text_r27 = "27      ";
wire [63:0] text_r28 = "28      ";
wire [63:0] text_r29 = "29      ";
wire [63:0] text_r30 = "30      ";
wire [63:0] text_r31 = "31      ";


wire [7:0] my_char = (force_top_line && char_pixel[8:4]==0) ? nibble2ascii( if_pc[31:28] )  :
							(force_top_line && char_pixel[8:4]==1) ? nibble2ascii( if_pc[27:24] )  :
							(force_top_line && char_pixel[8:4]==2) ? nibble2ascii( if_pc[23:20] )  :
							(force_top_line && char_pixel[8:4]==3) ? nibble2ascii( if_pc[19:16] )  :
							(force_top_line && char_pixel[8:4]==4) ? nibble2ascii( if_pc[15:12] )  :
							(force_top_line && char_pixel[8:4]==5) ? nibble2ascii( if_pc[11:8] )  :
							(force_top_line && char_pixel[8:4]==6) ? nibble2ascii( if_pc[7:4] )  :
							(force_top_line && char_pixel[8:4]==7) ? nibble2ascii( if_pc[3:0] )  :
							
							(force_top_line && char_pixel[8:4]==16) ? nibble2ascii( cpu_data[31:28] ) :
							(force_top_line && char_pixel[8:4]==17) ? nibble2ascii( cpu_data[27:24] ) :
							(force_top_line && char_pixel[8:4]==18) ? nibble2ascii( cpu_data[23:20] ) :
							(force_top_line && char_pixel[8:4]==19) ? nibble2ascii( cpu_data[19:16] ) :
							(force_top_line && char_pixel[8:4]==20) ? nibble2ascii( cpu_data[15:12] ) :
							(force_top_line && char_pixel[8:4]==21) ? nibble2ascii( cpu_data[11:8] ) :
							(force_top_line && char_pixel[8:4]==22) ? nibble2ascii( cpu_data[7:4] ) :
							(force_top_line && char_pixel[8:4]==23) ? nibble2ascii( cpu_data[3:0] ) :

							(force_left_line && line[9:4]==2) ? charout( text_pc, char_pixel[9:4] ) :
							(force_top_line && char_pixel[8:4]>=16) ? charout( string0, char_pixel[6:4] ) :

							(force_left_line && line[9:4]==3) ? charout( text_biu, char_pixel[9:4] ) :					
							(force_biu_line && char_pixel[8:4]==0) ? nibble2ascii( BIU[31:28] ) :
							(force_biu_line && char_pixel[8:4]==1) ? nibble2ascii( BIU[27:24] ) :
							(force_biu_line && char_pixel[8:4]==2) ? nibble2ascii( BIU[23:20] ) :
							(force_biu_line && char_pixel[8:4]==3) ? nibble2ascii( BIU[19:16] ) :
							(force_biu_line && char_pixel[8:4]==4) ? nibble2ascii( BIU[15:12] ) :
							(force_biu_line && char_pixel[8:4]==5) ? nibble2ascii( BIU[11:8] ) :
							(force_biu_line && char_pixel[8:4]==6) ? nibble2ascii( BIU[7:4] ) :
							(force_biu_line && char_pixel[8:4]==7) ? nibble2ascii( BIU[3:0] ) :
							(force_biu_line && char_pixel[8:4]>=16) ? charout( string0, char_pixel[6:4] ) :

							(force_left_line & line[9:4]==4)  ? charout( text_r0, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==5)  ? charout( text_r1, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==6)  ? charout( text_r2, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==7)  ? charout( text_r3, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==8)  ? charout( text_r4, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==9)  ? charout( text_r5, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==10) ? charout( text_r6, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==11) ? charout( text_r7, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==12) ? charout( text_r8, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==13) ? charout( text_r9, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==14) ? charout( text_r10, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==15) ? charout( text_r11, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==16) ? charout( text_r12, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==17) ? charout( text_r13, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==18) ? charout( text_r14, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==19) ? charout( text_r15, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==20) ? charout( text_r16, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==21) ? charout( text_r17, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==22) ? charout( text_r18, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==23) ? charout( text_r19, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==24) ? charout( text_r20, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==25) ? charout( text_r21, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==26) ? charout( text_r22, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==27) ? charout( text_r23, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==28) ? charout( text_r24, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==29) ? charout( text_r25, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==30) ? charout( text_r26, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==31) ? charout( text_r27, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==32) ? charout( text_r28, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==33) ? charout( text_r29, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==34) ? charout( text_r30, char_pixel[9:4] ) :
							(force_left_line & line[9:4]==35) ? charout( text_r31, char_pixel[9:4] ) :							
							
							(main_frame && char_pixel[6:4]==0) ? nibble2ascii( ram_out[31:28] ) :
							(main_frame && char_pixel[6:4]==1) ? nibble2ascii( ram_out[27:24] ) :
							(main_frame && char_pixel[6:4]==2) ? nibble2ascii( ram_out[23:20] ) :
							(main_frame && char_pixel[6:4]==3) ? nibble2ascii( ram_out[19:16] ) :
							(main_frame && char_pixel[6:4]==4) ? nibble2ascii( ram_out[15:12] ) :
							(main_frame && char_pixel[6:4]==5) ? nibble2ascii( ram_out[11:8] ) :
							(main_frame && char_pixel[6:4]==6) ? nibble2ascii( ram_out[7:4] ) :
							(main_frame && char_pixel[6:4]==7) ? nibble2ascii( ram_out[3:0] ) :
							
							(force_bottom_line && char_pixel[8:4]==0) ? nibble2ascii( BREAKPOINT[31:28] ) :
							(force_bottom_line && char_pixel[8:4]==1) ? nibble2ascii( BREAKPOINT[27:24] ) :
							(force_bottom_line && char_pixel[8:4]==2) ? nibble2ascii( BREAKPOINT[23:20] ) :
							(force_bottom_line && char_pixel[8:4]==3) ? nibble2ascii( BREAKPOINT[19:16] ) :
							(force_bottom_line && char_pixel[8:4]==4) ? nibble2ascii( BREAKPOINT[15:12] ) :
							(force_bottom_line && char_pixel[8:4]==5) ? nibble2ascii( BREAKPOINT[11:8] ) :
							(force_bottom_line && char_pixel[8:4]==6) ? nibble2ascii( BREAKPOINT[7:4] ) :
							(force_bottom_line && char_pixel[8:4]==7) ? nibble2ascii( BREAKPOINT[3:0] ) :
							
							8'h20;	// SPACE character for all other chars.



wire [4:0] char_rd_addr = line[8:4] - 68;	// Generate char rom read address using bits of "line" and "char_pixel".
																
wire [10:0] font_addr = {my_char, line[3:0]};

																
reg [31:0] BREAKPOINT;
reg [2:0] BP_NIBBLE;



assign BP_MATCHED = (if_pc==BREAKPOINT);

initial begin
	BREAKPOINT <= 32'hDEADBEEF;
end

wire KEY_0 = RXDATA==8'h45;
wire KEY_1 = RXDATA==8'h16;
wire KEY_2 = RXDATA==8'h1E;
wire KEY_3 = RXDATA==8'h26;
wire KEY_4 = RXDATA==8'h25;
wire KEY_5 = RXDATA==8'h2E;
wire KEY_6 = RXDATA==8'h36;
wire KEY_7 = RXDATA==8'h3D;
wire KEY_8 = RXDATA==8'h3E;
wire KEY_9 = RXDATA==8'h46;
wire KEY_A = RXDATA==8'h1C;
wire KEY_B = RXDATA==8'h32;
wire KEY_C = RXDATA==8'h21;
wire KEY_D = RXDATA==8'h23;
wire KEY_E = RXDATA==8'h24;
wire KEY_F = RXDATA==8'h2B;

wire KEY_UP    = RXDATA==8'h75;
wire KEY_DOWN  = RXDATA==8'h72;
wire KEY_LEFT  = RXDATA==8'h6B;
wire KEY_RIGHT = RXDATA==8'h74;

wire KEY_HOME	= RXDATA==8'h6C;
wire KEY_END	= RXDATA==8'h69;

wire HEX_TRIG = KEY_0 | KEY_1 | KEY_2 | KEY_3 | KEY_4 | KEY_5 | KEY_6 | KEY_7 |
					 KEY_8 | KEY_9 | KEY_A | KEY_B | KEY_C | KEY_D | KEY_E | KEY_F;

wire [3:0] HEX_KEY = (KEY_0) ? 4'h0 : (KEY_1) ? 4'h1 : (KEY_2) ? 4'h2 : (KEY_3) ? 4'h3 :
							(KEY_4) ? 4'h4 : (KEY_5) ? 4'h5 : (KEY_6) ? 4'h6 : (KEY_7) ? 4'h7 :
							(KEY_8) ? 4'h8 : (KEY_9) ? 4'h9 : (KEY_A) ? 4'hA : (KEY_B) ? 4'hB :
							(KEY_C) ? 4'hC : (KEY_D) ? 4'hD : (KEY_E) ? 4'hE : 4'hF;

always @(posedge write_clk or negedge reset_n)
if (!reset_n) begin
	BP_NIBBLE <= 3'd0;
end
else begin
	if (KEY_PRESSED && KEY_RIGHT) BP_NIBBLE <= BP_NIBBLE + 1;
	if (KEY_PRESSED && KEY_LEFT) BP_NIBBLE <= BP_NIBBLE - 1;
	if (KEY_PRESSED && KEY_HOME) BP_NIBBLE <= 0;
	if (KEY_PRESSED && KEY_END) BP_NIBBLE <= 7;
	
	if (KEY_PRESSED && HEX_TRIG) begin
		case (BP_NIBBLE)
		0: BREAKPOINT[31:28] <= HEX_KEY;
		1: BREAKPOINT[27:24] <= HEX_KEY;
		2: BREAKPOINT[23:20] <= HEX_KEY;
		3: BREAKPOINT[19:16] <= HEX_KEY;
		4: BREAKPOINT[15:12] <= HEX_KEY;
		5: BREAKPOINT[11:8]  <= HEX_KEY;
		6: BREAKPOINT[7:4]   <= HEX_KEY;
		7: BREAKPOINT[3:0]   <= HEX_KEY;
		default:;
		endcase
		BP_NIBBLE <= BP_NIBBLE + 1;
	end
end


always @(posedge clk) begin
	osd_frame <= main_frame | force_top_line | force_bottom_line | force_left_line | force_biu_line | force_pc_line;

	osd_frame_out <= osd_frame;

	if (osd_frame_out & !osd_frame) begin		// Reset "char_pixel" counter at same horizontal position on each line
		char_pixel <= 0;
	end
	else begin
		if (osd_frame) begin							// Test if we're within the text rectangle.
			char_pixel <= char_pixel + 1;			// Increment "char_pixel"
			charbit <= row[ char_pixel[3:1]-1 ];// Test if selected pixel from font rom is set to generate "charbit"
		end
		else begin
			charbit <= 1'b0;
		end
	end

	if (osd_enable & charbit) vid_out <= 24'hFF_FF_FF;	// Output fixed pixel color if "charbit" is set...
	else if (osd_enable && osd_frame && line[9:4]>=4  && line[9:4]<=7)  vid_out <= 24'h21_63_CE;	// DARK BLUE
	else if (osd_enable && osd_frame && line[9:4]>=8  && line[9:4]<=11) vid_out <= 24'h89_3C_E0;	// PURPLE
	else if (osd_enable && osd_frame && line[9:4]>=12 && line[9:4]<=15) vid_out <= 24'h67_CC_24;	// MINT GREEN
	else if (osd_enable && osd_frame && line[9:4]>=16 && line[9:4]<=19) vid_out <= 24'h23_BE_80;	// CYAN
	else if (osd_enable && osd_frame && line[9:4]>=20 && line[9:4]<=23) vid_out <= 24'hB3_B5_3B;	// DUSTY YELLOW
	else if (osd_enable && osd_frame && line[9:4]>=24 && line[9:4]<=27) vid_out <= 24'hB5_57_20;	// BROWN
	else if (osd_enable && osd_frame && line[9:4]>=28 && line[9:4]<=31) vid_out <= 24'hD2_3A_1C;	// RED
	else if (osd_enable && osd_frame && line[9:4]>=32 && line[9:4]<=35) vid_out <= 24'hE8_A5_29;	// DARK ORANGE
	
	else if (force_bottom_line && char_pixel[8:4]==BP_NIBBLE) vid_out <= 24'h66_66_66;	// Highlight (background) of each BREAKPOINT nibble. ;)
	
	else if (osd_enable & osd_frame) vid_out <= 24'h00_00_FF;	// Background colour.
	else vid_out <= vid_in;						// ...else, pass video through unchanged.
end
	

font_rom	font_rom_inst (
	.address ( font_addr ),
	.clock ( clk ),
	.q ( font_data )
);


char_ram	char_ram_inst (
	.data ( char_in ),
	.rdaddress ( char_rd_addr ),
	.rdclock ( clk ),
	
	.wraddress ( char_wr_addr ),
	.wrclock ( write_clk ),
	.wren ( char_wren ),
	.byteena_a ( char_byteena ),
	
	.q ( ram_out )
);


function  [7:0] nibble2ascii;
input [3:0] nibble;
begin
  nibble2ascii = (nibble<10) ? nibble+48 : nibble+(65-10);
end
endfunction


function  [7:0] charout;
input [63:0] string;
input [2:0] select;
begin
	charout = (select==0) ? string[63:56] :
				 (select==1) ? string[55:48] :
				 (select==2) ? string[47:40] :
				 (select==3) ? string[39:32] :
				 (select==4) ? string[31:24] :
				 (select==5) ? string[23:16] :
				 (select==6) ? string[15:8]  : string[7:0];
end
endfunction


endmodule
