// ADV video out DDR
// Paul Honig 2020
//

// When register 0x16 = 0 first byte in middle of positive
// https://www.analog.com/media/en/technical-documentation/user-guides/ADV7511_Hardware_Users_Guide.pdf
// Page 35
module adv_ddr 
(
	// INPUT
	input clk_out,			// DDR clock at 4xpixel clock
	input clk_in,        // Pixel clock
	input reset,
	
	input de_in,		// Used to generate DE
	input vsync, hsync,     // 
	input [23:0 ] data,     // Pixel data in 24-bpp

	// OUTPUT
	output reg clk_pixel_out,   // Output pixel clock after synchronization to clk_out
	output reg de_out = 1'b0,			// Data enable signal
	output reg vsync_out, hsync_out,
	output reg [11:0] data_out  // DDR data stream out
);

// The amount of pixels before the Data enabled is triggered
//
// 	{ XVIDC_VM_1280x720_50_P, "1280x720@50Hz", XVIDC_FR_50HZ,
//		{1280, 440, 40, 220, 1980, 1,
//		720, 5, 5, 20, 750, 0, 0, 0, 0, 1} },
parameter PX_TO_DE = 36;
parameter PX_ACT_DE = 1280;
parameter PX_TOTAL = 1360;

parameter PY_TO_DE = 5;
parameter ACT_720P = 720;
parameter V_LINES_TOTAL = 806;

// reg clk_pixel_, clk_pixel__;
reg [2:0] clk_pixel_s;
// reg de_in_, de_in__;
reg [1:0] de_in_s;

// reg vsync_, vsync__;
reg [2:0] vsync_s;
// reg hsync_, hsync__;
reg [2:0] hsync_s;

//reg [23:0] data_, data__;
reg [23:0] data_s [1:0];

// Set and reset Data enable
reg set_de = 1'b0;
reg reset_de = 1'b0;


// Synchronize signal to clk_out
always @(posedge clk_out) begin
	clk_pixel_s <= {clk_pixel_s[1], clk_pixel_s[0], clk_in};
	de_in_s <= {de_in_s[0], de_in};
	vsync_s <= {vsync_s[1], vsync_s[0], vsync};
	hsync_s <= {hsync_s[1], hsync_s[0], hsync};
	// Sync 2d array
	data_s[0] <= data;
	data_s[1] <= data_s[0];
end

// line counter
reg [$clog2(V_LINES_TOTAL):0] v_counter = 0;
reg                           v_active = 1'b0; // Active reagion 720p

// Make sure the DE lines are only active when data is displayed
always @(posedge clk_out) begin
	v_active <= 1'b0;

	if (hsync_s[2:1] == 2'b01) begin
		v_counter <= v_counter + 1;
	end

	// On vsync reset line counter
	if (vsync_s[2:1] == 2'b10) begin
		v_counter <= 0;
	end

	// Only have the video DE active in the active reagon
	if ((v_counter > PY_TO_DE) && (v_counter <= (PY_TO_DE + ACT_720P))) begin
		v_active <= 1'b1;
	end

	if (reset) begin
		v_counter <= 0;
		v_active <= 0;
	end
end


// Generate DDR signals
reg clk_pixel_prev = 0;
// reg phase_count = 0;
reg [$clog2(PX_TOTAL):0] px_count = 0;
always @(posedge clk_out) begin
	reset_de <= 1'b0;
	if (reset) begin
		clk_pixel_prev <= 0;
		// phase_count <= 0;
		px_count <= 0;
	end else begin
		// Next phase
		// phase_count <= ~phase_count; 

		// Handle positive pixel clock edge
		// if (!clk_pixel_s[2] && clk_pixel_s[1]) begin
		// 	phase_count <= 1'b0;
		// end

		// Do actions according to phases
		if (clk_pixel_s[1] == 1'b1) begin // Phase 0
			// Output the lower (1st) part
			data_out <= data_s[1][11:0];
			// Output vsync and hsync as well
			vsync_out <= vsync_s[1];
			hsync_out <= hsync_s[1];
			// Generate data enable
			if (px_count == PX_TO_DE && v_active) set_de <= ~set_de;
			if (px_count == (PX_TO_DE + PX_ACT_DE)) reset_de <= ~reset_de;
		end else begin
			// Output the high (2nd) part
			data_out <= data_s[1][23:12];
			// Handle pixel counter to Data enable
			px_count <= px_count + 1;
			// Reset horizontal counter
			if (hsync_s[1]) px_count <= 0;
		end

		// Output synchronized pixel clock 
		clk_pixel_out <= clk_pixel_s[1];
	end

	// Negative edge set
	// if (hsync_s[2] && !hsync_s[1] && v_active) begin
	// 	set_de <= 1'b1;
	// end

	// Positive edge reset
	// if (!hsync_s[2] && hsync_s[1]) begin
	// 	reset_de <= 1'b1;
	// end
end

// 180 degrees later switch the data enable
reg [2:0] r_neg_set_de = 2'b00;
reg [2:0] r_neg_reset_de = 2'b00;
always @(negedge clk_out) begin

	if (clk_pixel_out == 1'b1) begin
		r_neg_set_de <= {r_neg_set_de[1], r_neg_set_de[0], set_de};
		r_neg_reset_de <= {r_neg_reset_de[1], r_neg_reset_de[0], reset_de};

		if (r_neg_set_de[0] != r_neg_set_de[1]) begin
			de_out <= 1'b1;	
		end

		if (r_neg_reset_de[0] != r_neg_reset_de[1]) begin
			de_out <= 1'b0;
		end
	end
end

endmodule
