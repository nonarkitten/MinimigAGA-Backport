`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/02/2020 06:22:06 PM
// Design Name: 
// Module Name: aars_video_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module pal_to_ddr(
        input clk,
        input reset,
        // Pal input
        input i_pal_hsync,
        input i_pal_vsync,
        input [7:0] i_pal_r,
        input [7:0] i_pal_g,
        input [7:0] i_pal_b,
        // Offset
        input [7:0] i_hoffset,
        input [7:0] i_voffset,
        // OUTPUT
        output o_clk_pixel,    // Output pixel clock after synchronization to clk_ddr
        output o_de,            // Data enable signal
        output o_vsync,
        output o_hsync,
        output [11:0] o_data           // DDR data stream out
);
    // Generated RGB values
    wire [7:0] w_r;
    wire [7:0] w_g;
    wire [7:0] w_b;
    wire       w_vsync;

    // Upsample routine
    wire [6:0] w_vblank_width;
    wire w_hd_hsync;
    wire w_hd_vsync;

    // Current video postion
    wire [11:0] w_x;
    wire [11:0] w_y;

    // enable to indicate the next data point is needed
    wire w_adv_de;
    wire w_adv_clk;

    // RGB signal in 720p@50Hz before DDR
    wire [7:0] w_o_r;
    wire [7:0] w_o_g;
    wire [7:0] w_o_b;
    wire [7:0] w_50_o_r;
    wire [7:0] w_50_o_g;
    wire [7:0] w_50_o_b;
    wire [7:0] w_60_o_r;
    wire [7:0] w_60_o_g;
    wire [7:0] w_60_o_b;

    reg _i_pal_hsync;
    reg __i_pal_hsync;
    reg _i_pal_vsync;
    reg __i_pal_vsync;
    reg [7:0] _i_pal_r;
    reg [7:0] __i_pal_r;
    reg [7:0] _i_pal_g;
    reg [7:0] __i_pal_g;
    reg [7:0] _i_pal_b;
    reg [7:0] __i_pal_b;

    reg [7:0] r_hoffset [0:1];
    reg [7:0] r_voffset [0:1];

    // Synchronize the signal
    always @(posedge clk) begin
        // Hsync
        _i_pal_hsync  <= i_pal_hsync;
        __i_pal_hsync <= _i_pal_hsync;
        // Vsync
        _i_pal_vsync  <= i_pal_vsync;
        __i_pal_vsync <= _i_pal_vsync;
        // Red
        _i_pal_r      <= i_pal_r;
        __i_pal_r     <= _i_pal_r;
        // Green
        _i_pal_g      <= i_pal_g;
        __i_pal_g     <= _i_pal_g;
        // Blue
        _i_pal_b      <= i_pal_b;
        __i_pal_b     <= _i_pal_b;
        // Offset registers
        r_hoffset     <= {r_hoffset[1], i_hoffset};
        r_voffset     <= {r_voffset[1], i_voffset};
    end

    // Detect FPS
    (* mark_debug = "true" *)
    wire [$clog2(100):0] cur_fps; 
    wire                   fps_valid;
    (* mark_debug = "true" *)
    reg                    r_50hz = 1'b0;
    reg                    r_60hz = 1'b0;
    frame_freq myfreq(
        .clk(clk),
        .reset(1'b0),
        .i_vsync(__i_pal_vsync),
        .o_freq(cur_fps),        // 7 bits frequency, 2 bits fraction
        .o_valid(fps_valid)      // 
    );
    always @(posedge clk) begin
        r_50hz <= 1'b0;
        r_60hz <= 1'b0;
        if (fps_valid == 1'b1) begin
            if (cur_fps < 56) begin
                r_50hz <= 1'b1;
            end else begin
                r_60hz <= 1'b1;
            end
        end
    end

    // Switch wires 50 Hz
    wire        w_50_hd_vsync;
    wire        w_50_hd_hsync;
    wire [11:0] w_50_x;
    wire [11:0] w_50_y;
    wire [7:0]  w_50_r;
    wire [7:0]  w_50_g;
    wire [7:0]  w_50_b;
    wire        w_50_adv_clk;
    wire        w_50_hsync;
    wire        w_50_vsync;
    wire        w_50_frame_end;
    wire        w_50_adv_de;
    // Switch wires 50 Hz
    wire        w_60_hd_hsync;
    wire        w_60_hd_vsync;
    wire [11:0] w_60_x;
    wire [11:0] w_60_y;
    wire [7:0]  w_60_r;
    wire [7:0]  w_60_g;
    wire [7:0]  w_60_b;
    wire        w_60_adv_clk;
    wire        w_60_hsync;
    wire        w_60_vsync;
    wire        w_60_frame_end;
    wire        w_60_adv_de;

    // Upscale the video signal using a line buffer
    pal_to_hd_upsample #(
        .PAL_HD_H_RES(1360)
    ) my50hzupsample(
        .clk(clk),
        .reset(reset),
        // Pal input
        .i_pal_hsync(__i_pal_hsync),
        .i_pal_vsync(__i_pal_vsync),
        .i_pal_r(__i_pal_r),
        .i_pal_g(__i_pal_g),
        .i_pal_b(__i_pal_b),
        // HD upsampled output
        .o_hd_r(w_50_r),
        .o_hd_g(w_50_g),
        .o_hd_b(w_50_b),
        .o_hd_vsync(w_50_vsync),
        //.o_vblank_width(w_50_vblank_width),
        .o_frame_end(w_50_frame_end),
        // HD sync pulse
        .i_hd_hsync(w_50_hd_hsync),
        .i_hd_vsync(w_50_hd_vsync),
        .i_hd_clk(w_50_adv_clk),
        .i_hd_four_three(1'b0),
        // horizontal and vertical offsets
        .i_hd_hoffset(r_hoffset[0]),
        .i_hd_voffset(r_voffset[0])
    );

    // Generate the 720p Hsync and Vsync signals
    signal_generator #(
        .PAL_HZ_ACT_PIX(1280),
        .PAL_HZ_FRONT_PORCH(8),
        .PAL_HZ_SYNC_WIDTH(32),
        .PAL_HZ_BACK_PORCH(38),
        .PAL_VT_ACT_LN(720),
        .PAL_VT_FRONT_PORCH(3),
        .PAL_VT_SYNC_WIDTH(7),
        .PAL_VT_BACK_PORCH(9)
    ) hd_50hz_gen(
        .clk(clk),
        .reset(reset),
        //.i_vblank_width(w_vblank_width),
        .i_frame_end(w_50_frame_end),
        .i_r(w_50_r),
        .i_g(w_50_g),
        .i_b(w_50_b),
        // Output signals
        .o_x(w_50_x),
        .o_y(w_50_y),
        .o_r(w_50_o_r),
        .o_g(w_50_o_g),
        .o_b(w_50_o_b),
        .o_adv_clk(w_50_adv_clk),
        .o_hsync(w_50_hd_hsync),
        .o_vsync(w_50_hd_vsync),
        .o_adv_de(w_50_adv_de)
    );

    // Upscale the video signal using a line buffer
    pal_to_hd_upsample #(
        .PAL_HD_H_RES(1107) // Total pixels in a line
    ) my60hzupsample (
        .clk(clk),
        .reset(reset),
        // Pal input
        .i_pal_hsync(__i_pal_hsync),
        .i_pal_vsync(__i_pal_vsync),
        .i_pal_r(__i_pal_r),
        .i_pal_g(__i_pal_g),
        .i_pal_b(__i_pal_b),
        // HD upsampled output
        .o_hd_r(w_60_r),
        .o_hd_g(w_60_g),
        .o_hd_b(w_60_b),
        .o_hd_vsync(w_60_vsync),
        //.o_vblank_width(w_vblank_width),
        .o_frame_end(w_60_frame_end),
        // HD sync pulse
        .i_hd_hsync(o_hsync),
        .i_hd_vsync(w_60_hd_vsync),
        .i_hd_clk(w_50_adv_clk),
        .i_hd_four_three(1'b0),
        // horizontal and vertical offsets
        .i_hd_hoffset(r_hoffset[0]),
        .i_hd_voffset(r_voffset[0])
    );

    // Generate the 720p Hsync and Vsync signals
    signal_generator #(
        .PAL_HZ_ACT_PIX(862),
        .PAL_HZ_FRONT_PORCH(74),
        .PAL_HZ_SYNC_WIDTH(27),
        .PAL_HZ_BACK_PORCH(148),
        .PAL_VT_ACT_LN(720),
        .PAL_VT_FRONT_PORCH(5),
        .PAL_VT_SYNC_WIDTH(5),
        .PAL_VT_BACK_PORCH(30)
    ) hd_60hz_gen(
        .clk(clk),
        .reset(reset),
        //.i_vblank_width(w_vblank_width),
        .i_frame_end(w_60_frame_end),
        .i_r(w_60_r),
        .i_g(w_60_g),
        .i_b(w_60_b),
        // Output signals
        .o_x(w_60_x),
        .o_y(w_60_y),
        .o_r(w_60_o_r),
        .o_g(w_60_o_g),
        .o_b(w_60_o_b),
        .o_adv_clk(w_60_adv_clk),
        .o_hsync(w_60_hd_hsync),
        .o_vsync(w_60_hd_vsync),
        .o_adv_de(w_60_adv_de)
    );

    // Use conditional operators for now
    assign w_hd_vsync = r_50hz ? w_50_hd_vsync : w_60_hd_vsync;
    assign w_hd_hsync = r_50hz ? w_50_hd_hsync : w_60_hd_hsync;
    // assign w_x        = r_50hz ? w_50_x : w_60_x;
    // assign w_y        = r_50hz ? w_50_y : w_60_y;
    assign w_adv_clk  = r_50hz ? w_50_adv_clk : w_60_adv_clk;
    // assign w_hsync    = r_50hz ? w_50_hsync : w_60_hsync;
    assign w_vsync    = r_50hz ? w_50_vsync : w_60_vsync;
    assign w_adv_de   = r_50hz ? w_50_adv_de : w_60_adv_de;
    assign w_o_r     = r_50hz ? w_50_o_r : w_60_o_r;
    assign w_o_g     = r_50hz ? w_50_o_g : w_60_o_g;
    assign w_o_b     = r_50hz ? w_50_o_b : w_60_o_b;
    
    // ADV DDR output
    adv_ddr myadr_ddr (
        // INPUT
        .clk_ddr(clk),            // DDR clock at 4xpixel clock
        .reset(reset),
        .clk_pixel(w_adv_clk),        // Pixel clock

        .de_in(w_adv_de),       // Used to generate DE
        .hsync(w_hd_hsync),
        .vsync(w_vsync),
        .data({w_o_r, w_o_g, w_o_b}), // Pixel data in 24-bpp

        // OUTPUT
        .clk_pixel_out(o_clk_pixel),    // Output pixel clock after synchronization to clk_ddr
        .de_out(o_de),            // Data enable signal
        .vsync_out(o_vsync),
        .hsync_out(o_hsync),
        .data_out(o_data)           // DDR data stream out
    );
endmodule
