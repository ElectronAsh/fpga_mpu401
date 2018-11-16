module keyboard (
	input CLK,
	
	input PS2_DAT,
	input PS2_CLK,
	
	output reg [7:0] RXDATA,
	
	output reg KEY_PRESSED,
	output reg KEY_RELEASED,
  
	output wire UP_PULSE,
	output wire DOWN_PULSE,
	output wire LEFT_PULSE,
	output wire RIGHT_PULSE
);


wire [7:0] ARROW_UP = 8'h75;	//codes for arrows
wire [7:0] ARROW_DOWN = 8'h72;
wire [7:0] ARROW_LEFT = 8'h6B;
wire [7:0] ARROW_RIGHT = 8'h74;
//wire [7:0] EXTENDED = 8'hE0;	//codes 
//wire [7:0] RELEASED = 8'hF0;
	
assign UP_PULSE 	 = KEY_PRESSED & (RXDATA==ARROW_UP);
assign DOWN_PULSE  = KEY_PRESSED & (RXDATA==ARROW_DOWN);
assign LEFT_PULSE  = KEY_PRESSED & (RXDATA==ARROW_LEFT);
assign RIGHT_PULSE = KEY_PRESSED & (RXDATA==ARROW_RIGHT);

reg LAST_KEY_F0;


parameter idle    = 2'b01;
parameter receive = 2'b10;
parameter ready   = 2'b11;


reg [1:0]  state=idle;
reg [15:0] rxtimeout=16'b0000000000000000;
reg [10:0] rxregister=11'b11111111111;
reg [1:0]  datasr=2'b11;
reg [1:0]  clksr=2'b11;



always @(posedge CLK ) 
begin
	KEY_PRESSED <= 1'b0;
	KEY_RELEASED <= 1'b0;


	datasr <= {datasr[0],PS2_DAT};
	clksr  <= {clksr[0],PS2_CLK};


	if(clksr==2'b10) rxregister <= {datasr[1],rxregister[10:1]};

	case (state) 
	idle: 
	begin
		rxregister <=11'b11111111111;

		if(datasr[1]==0 && clksr[1]==1)
		begin
			rxtimeout  <=16'd50000;
			state<=receive;
		end   
	end
    
	receive:
	begin
		rxtimeout <= rxtimeout-1;
		
		if(!rxtimeout) begin
			state<=idle;
		end
		else if(rxregister[0]==0)
		begin
			RXDATA<=rxregister[8:1];
						
			if (rxregister[8:1]==8'hF0) LAST_KEY_F0<=1;
			else begin
				if (LAST_KEY_F0) begin	// If PREVIOUS value set LAST_KEY_F0...
					LAST_KEY_F0<=1'b0;
					KEY_RELEASED<=1'b1;	// Then this is a KEY_RELEASED value.
				end
				else KEY_PRESSED<=1'b1;
			end
			
			state<=idle;
		end
	end
   
	endcase
end 

endmodule
