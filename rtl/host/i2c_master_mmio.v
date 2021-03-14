/*

Copyright (c) 2021 Paul Honig

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`timescale 1ns / 10ps

/*
 * I2C master
 */
module i2c_master_mmio (
    input  wire        clk,
    input  wire        rst,

    input  [15:0]      d,
    output reg [15:0]  q = 0,

    output wire        interrupt,

    /*
     * MMIO interface
     */
    input  wire [31:2] addr,
    input  wire        i2c_select,
    input  wire        interrupt_select,
    input  wire        req,
    input  wire        wr,

    /*
     * I2C interface
     */
    input  wire        scl_i,
    output wire        scl_o,
    output wire        scl_t,
    input  wire        sda_i,
    output wire        sda_o,
    output wire        sda_t
);
    //////////////////////////////////////////////////////////////////////
    //
    // Read
    // ----
    //
    // Addr | Function
    // ===============================================
    // 0000 | Last read byte
    // 0100 | Status register
    // 1000 | I2C devider
    // 1100 | nothing
    //
    // Write
    // -----
    // Addr, 0000 - 1100 all connect to the same functionality
    //
    // bit  | function
    // ===============================================
    // 7:0  | Payload data
    // 11:8 | command
    // 12   | data_in_last (use with CMD_WRITE_MULTI)
    //
    // 0xNum |  command
    // ===============================================
    // 4'h0  |  CMD_NOP          | No operation
    // 4'h1  |  CMD_READ         | Read a byte
    // 4'h2  |  CMD_WRITE        | write one byte
    // 4'h3  |  CMD_WRITE_MULTI  | Write multiple bytes
    // 4'h4  |  CMD_START        | Send start command
    // 4'h5  |  CMD_STOP         | Send stop command
    // 4'hb  |  CMD_SET_ADDR     | Set the slave address
    // 4'hc  |  CMD_SET_SCL_L    | Set lower byte of I2C clock devider
    // 4'hd  |  CMD_SET_SCL_H    | Set high byte of I2C clock devider
    // 4'he  |  CMD_STOP_ON_IDLE | Send automatic stop on bus error
    // 4'hf  |  CMD_RESET        | Reset state machine
    //
    //////////////////////////////////////////////////////////////////////


    reg [6:0]  cmd_address;
    reg        cmd_start = 0;
    reg        cmd_read = 0;              
    reg        cmd_write = 0;
    reg        cmd_write_multiple = 0;
    reg        cmd_stop = 0;
    reg        cmd_valid = 0;
    wire       cmd_ready;
                                  
    reg  [7:0]data_in;
    reg        data_in_valid;
    wire       data_in_ready;
    reg        data_in_last;

    wire [7:0]data_out;
    wire       data_out_valid;
    reg        data_out_ready;
    wire       data_out_last;

    reg [15:0] i2c_prescale = 0;
    reg        stop_on_idle = 0;

    reg        r_interrupt = 0;
    //reg [15:0] r_q = 0;
    

    // Enumerations
    localparam [4:0]
        STATE_IDLE        = 4'd0,
        STATE_READ        = 4'd1,
        STATE_WRITE       = 4'd2,
        STATE_WRITE_MULTI = 4'd3,
        STATE_START       = 4'd4,
        STATE_STOP        = 4'd5,
        STATE_SET_ADDRESS = 4'hb,
        STATE_SET_SOI     = 4'hc,
        STATE_SET_SCL_L   = 4'hd,
        STATE_SET_SCL_H   = 4'he,
        STATE_RESET       = 4'hf;
    reg [4:0] state_reg = STATE_IDLE;

    localparam [3:0]
        CMD_NOP          = 4'h0,
        CMD_READ         = 4'h1,
        CMD_WRITE        = 4'h2,
        CMD_WRITE_MULTI  = 4'h3,
        CMD_START        = 4'h4,
        CMD_STOP         = 4'h5,
        // config
        CMD_SET_ADDR     = 4'hb,
        CMD_SET_SCL_L    = 4'hc,
        CMD_SET_SCL_H    = 4'hd,
        CMD_STOP_ON_IDLE = 4'he,
        CMD_RESET        = 4'hf;

    wire busy;
    wire bus_control;
    wire bus_active;
    wire missed_ack;

    // Command state machine
    reg [15:0] cmd_in = 0;
    reg [15:0] cmd_result = 0;

    // Flag registers
    reg flag_write_ready = 1'b0;
    reg flag_read_ready = 1'b0;
    reg r_write_ready = 1'b0;
    reg r_read_ready = 1'b0;
    reg r_cmd_done = 1'b0;

    // busy registers
    reg r_busy = 0;
    reg busy_strobe = 0;

    // Register to output wire
    assign interrupt = r_interrupt;
    //assign q = q;

    initial begin
        $monitor("r_cmd_done=%d\n",r_cmd_done);
    end

    reg req_;
    reg req_strobe;

    // handle reads combinational
    always @(r_cmd_done, r_read_ready, r_write_ready, i2c_select, interrupt_select, req, wr, busy) begin
    //always @(posedge clk) begin
        // Handle interrupt flag
        if (r_cmd_done == 1'b1 | busy_strobe == 1'b1) begin
            r_interrupt <= 1'b1;
        end

        // Latch status flags
        if (r_read_ready == 1'b1) begin
            flag_read_ready <= 1'b1;
        end

        if (r_write_ready == 1'b1) begin
            flag_write_ready <= 1'b1;
        end

        // Clear interrupt when the interrupt register is read
        if (interrupt_select == 1'b1 & wr == 1'b0) begin
            r_interrupt <= 1'b0;
            flag_read_ready <= 1'b0;
            flag_write_ready <= 1'b0;
        end

        // Handle data out asynchronous
        if(i2c_select == 1'b1 & req == 1'b1 & wr == 1'b0 ) begin
            case (addr[3:2])
                2'b00: begin
                    // Read answer from a read action
                    q <= cmd_result;
                end
                2'b01: begin
                    // Return status register
                    q <= {6'b0, missed_ack, stop_on_idle, {4{1'b0}}, interrupt, busy, flag_write_ready, flag_read_ready};
                end
                2'b10: begin
                    // Return IO prescale value
                    q <= i2c_prescale;
                end
                2'b11: begin
                    // do nothing
                    q <= 0;
                end
            endcase
        end
    end

    // Generate bus free pulse
    always @(posedge clk) begin
        r_busy <= busy;
        busy_strobe <= 1'b0;

        if (r_busy == 1'b1 && busy == 1'b0) begin
            busy_strobe <= 1'b1;
        end
    end

    // Handle write synchronous
    always @(posedge clk) begin
        r_cmd_done <= 1'b0;
        req_ <= req;

        // Generate strobe
        req_strobe <= 1'b0;
        if (req_ == 1'b0 & req == 1'b1) req_strobe <= 1'b1;

        // handle writes
        case(state_reg)
            // Idle wait for a command to come in
            STATE_IDLE: begin
                cmd_valid <= 0;
                data_in_valid <= 0;
                data_out_ready <= 0;
                cmd_read <= 0;
                cmd_write <= 0;
                cmd_write_multiple <= 0;
                cmd_stop <= 0;
                cmd_start <= 0;

                // Read register
                // Write command
                if(rst) begin
                    state_reg <= STATE_IDLE;
                end 
                else if(i2c_select == 1'b1 & req_strobe == 1'b1 & wr == 1'b1) begin
                    cmd_in <= d;
                    case(d[11:8])
                        CMD_NOP: begin
                            state_reg <= STATE_IDLE;
                        end
                        CMD_READ: begin
                            r_read_ready <= 1'b0;
                            state_reg <= STATE_READ;
                        end
                        CMD_WRITE: begin
                            r_write_ready <= 1'b0;
                            state_reg <= STATE_WRITE;
                        end
                        CMD_WRITE_MULTI: begin
                            r_write_ready <= 1'b0;
                            state_reg <= STATE_WRITE_MULTI;
                        end
                        CMD_START: begin
                            state_reg <= STATE_START;
                        end
                        CMD_STOP: begin
                            state_reg <= STATE_STOP;
                        end
                        // config
                        CMD_SET_ADDR: begin
                            state_reg <= STATE_SET_ADDRESS;
                        end
                        CMD_SET_SCL_L: begin
                            state_reg <= STATE_SET_SCL_L;
                        end
                        CMD_SET_SCL_H: begin
                            state_reg <= STATE_SET_SCL_H;
                        end
                        CMD_STOP_ON_IDLE: begin
                            state_reg <= STATE_SET_SOI;
                        end
                        CMD_RESET: begin
                            state_reg <= STATE_RESET; 
                        end
                    endcase
                end
            end

            // Read a byte
            STATE_READ: begin
                cmd_valid <= 1;
                cmd_read <= 1;
                data_out_ready <= 1;

                if (data_out_ready == 1) begin
                    r_cmd_done <= 1'b1;       

                    cmd_valid <= 0;
                    data_out_ready <= 0;
                    cmd_result <= {8'h00, data_out};
                    r_read_ready <= 1'b1;

                    state_reg <= STATE_IDLE;
                end
            end
            // Write a byte
            // Start is implicit when bus is Idle
            STATE_WRITE: begin
                cmd_valid <= 1;
                cmd_write <= 1;
                data_in_valid <= 1;
                data_in <= cmd_in[7:0];

                if (data_in_ready == 1) begin
                    r_cmd_done <= 1'b1;
                    cmd_valid <= 0;
                    cmd_result <= 0;
                    r_write_ready <= 1'b1;

                    state_reg <= STATE_IDLE;
                end
            end
            // Write mutiple bytes
            // When writing last byte set data_in_last(byte 12) high to end
            // transmission
            STATE_WRITE_MULTI: begin
                cmd_valid <= 1;
                cmd_write_multiple <= 1;
                data_in_valid <= 1;
                data_in <= cmd_in[7:0];
                data_in_last <= cmd_in[12];

                if (data_in_ready == 1) begin
                    r_cmd_done <= 1'b1;
                    cmd_valid <= 0;
                    cmd_result <= 0;
                    r_write_ready <= 1'b1;

                    state_reg <= STATE_IDLE;
                end
            end
            // Trigger start
            STATE_START: begin
                cmd_valid <= 1;
                cmd_start <= 1;
                if(cmd_ready == 1) begin
                    r_cmd_done <= 1'b1;
                    cmd_valid <= 0;
                    state_reg <= STATE_IDLE;
                end
            end
            // Trigger stop
            STATE_STOP: begin
                cmd_valid <= 1;
                cmd_stop <= 1;
                if (cmd_ready == 1) begin
                    r_cmd_done <= 1'b1;
                    cmd_valid <= 0;
                    state_reg <= STATE_IDLE;
                end
            end
            // Set the address of the slave device
            STATE_SET_ADDRESS: begin
                cmd_address <= cmd_in[7:1];
                state_reg <= STATE_IDLE;
            end
            // Set low byte of the devider
            STATE_SET_SCL_L: begin
                i2c_prescale[7:0] <= cmd_in[7:0];
                state_reg <= STATE_IDLE;
            end
            // Set the high byte of the devider
            STATE_SET_SCL_H: begin
                i2c_prescale[15:8] <= cmd_in[7:0];
                state_reg <= STATE_IDLE;
            end
            // Set the stop on idle bit, when set the transmission
            // ends on detection of a bus error.
            STATE_SET_SOI: begin
                stop_on_idle <= d[0];
                state_reg <= STATE_IDLE;
            end
            // Reset, what else to say
            default: begin
                // reset registes to I2C master
                cmd_address <= 0;
                cmd_start <= 0;
                cmd_read <= 0;
                cmd_write <= 0;
                cmd_write_multiple <= 0;
                cmd_stop <= 0;
                cmd_valid <= 0;
                // And return
                state_reg <= STATE_IDLE;
            end
        endcase
    end

	// I2C Master
	i2c_master my_i2c_master(
       .clk(clk),
       .rst(rst),

       // Host interface
       .cmd_address        ( cmd_address),
       .cmd_start          ( cmd_start),
       .cmd_read           ( cmd_read),
       .cmd_write          ( cmd_write),
       .cmd_write_multiple ( cmd_write_multiple),
       .cmd_stop           ( cmd_stop),
       .cmd_valid          ( cmd_valid),
       .cmd_ready          ( cmd_ready),

       .data_in            ( data_in),
       .data_in_valid      ( data_in_valid),
       .data_in_ready      ( data_in_ready),
       .data_in_last       ( data_in_last),

       .data_out           ( data_out),
       .data_out_valid     ( data_out_valid),
       .data_out_ready     ( data_out_ready),
       .data_out_last      ( data_out_last),

       // I2C interface
       .scl_i (scl_i),
       .scl_o (scl_o),
       .scl_t (scl_t),
       .sda_i (sda_i),
       .sda_o (sda_o),
       .sda_t (sda_t),

        // Status
       .busy (busy),
       .bus_control (bus_control),
       .bus_active (bus_active),
       .missed_ack (missed_ack),

       // Configuration
       .prescale (i2c_prescale),
       .stop_on_idle (stop_on_idle)
   );

endmodule
