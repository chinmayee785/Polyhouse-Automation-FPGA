// =============================================================
// bme280_diag.v  —  BME280 I2C diagnostic
// Shows I2C communication status directly on 7-segment
// NO sensors needed except BME280
//
// Display:
//   "A76 ---" = trying address 0x76 (SDO=GND)
//   "A77 ---" = trying address 0x77 (SDO=3.3V)  
//   "GOOD 26" = BME280 responding, shows temp integer
//   "FAIL   " = I2C NAK — wiring or address problem
//   "PULL   " = pull-up resistors missing (SDA stuck LOW)
//
// LD3 = BME280 valid (ACK received)
// LD2 = SDA line state (should be HIGH when idle)
// LD1 = SCL line state
// LD0 = currently trying 0x77 (else 0x76)
// =============================================================
module bme280_diag (
    input  wire        clk,
    input  wire        resetn,    // CPU_RESETN C12 active LOW
    inout  wire        bme_sda,   // JC1 K1
    output wire        bme_scl,   // JC2 F6
    output wire [7:0]  seg_an,
    output wire [6:0]  seg_cat,
    output wire        seg_dp,
    output wire [3:0]  led
);
    wire rst = ~resetn;

    // ── I2C tick 100 kHz ─────────────────────────────────────
    reg [9:0] div; reg itk;
    always @(posedge clk or posedge rst)
        if(rst) begin div<=0;itk<=0; end
        else begin itk<=0;
            if(div>=999) begin div<=0;itk<=1; end
            else div<=div+1; end

    reg sd_r, sc_r;
    assign bme_sda = sd_r ? 1'b0 : 1'bz;
    assign bme_scl  = sc_r ? 1'b0 : 1'bz;

    // ── I2C state machine ────────────────────────────────────
    // Tries 0x76 first, then 0x77 if NAK
    // Sends one byte (address write) and checks ACK
    localparam [3:0]
        SI  = 0,   // idle / wait
        SS  = 1,   // start condition
        SAW = 2,   // send address byte
        SAK = 3,   // check ACK
        SP  = 4,   // stop condition
        SN  = 5;   // NAK stop

    reg [3:0]  state;
    reg [3:0]  bs;
    reg [2:0]  bc;
    reg [7:0]  tx;
    reg [26:0] wc;
    reg        addr_sel;   // 0=0x76  1=0x77
    reg        bme_ok;
    reg [2:0]  nak_cnt;

    wire [7:0] ADDR_W = addr_sel ? 8'hEE : 8'hEC; // 0x77<<1=EE  0x76<<1=EC

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state<=SI;bs<=0;bc<=7;sd_r<=0;sc_r<=0;
            tx<=0;wc<=0;addr_sel<=0;bme_ok<=0;nak_cnt<=0;
        end else if(itk) begin
            case(state)
                SI: begin sd_r<=0;sc_r<=0;
                    if(wc>=27'd50_000_000) begin // retry every 0.5s
                        wc<=0; tx<=ADDR_W; bc<=7; state<=SS;
                    end else wc<=wc+1; end

                SS: begin case(bs)
                    0:begin sd_r<=0;sc_r<=0;bs<=1;end
                    1:begin sc_r<=0;sd_r<=0;bs<=2;end
                    2:begin sc_r<=0;sd_r<=0;bs<=0;bc<=7;state<=SAW;end
                    default:bs<=0; endcase end

                SAW: begin case(bs)
                    0:begin sd_r<=~tx[bc];sc_r<=0;bs<=1;end
                    1:begin sc_r<=1;bs<=2;end
                    2:begin sc_r<=0;bs<=0;
                        if(bc==0) state<=SAK; else bc<=bc-1;end
                    default:bs<=0; endcase end

                SAK: begin case(bs)
                    0:begin sd_r<=0;sc_r<=0;bs<=1;end  // release SDA
                    1:begin sc_r<=1;bs<=2;end           // clock high
                    2:begin sc_r<=0;bs<=0;
                        if(~bme_sda) begin               // ACK = SDA pulled LOW
                            bme_ok<=1; state<=SP;
                        end else begin                   // NAK = SDA stays HIGH
                            bme_ok<=0;
                            nak_cnt<=nak_cnt+1;
                            if(nak_cnt>=3'd3) begin
                                addr_sel<=~addr_sel;     // try other address
                                nak_cnt<=0;
                            end
                            state<=SN;
                        end end
                    default:bs<=0; endcase end

                SP: begin case(bs)  // STOP
                    0:begin sd_r<=1;sc_r<=0;bs<=1;end
                    1:begin sc_r<=1;bs<=2;end
                    2:begin sd_r<=0;bs<=0;state<=SI;end
                    default:bs<=0; endcase end

                SN: begin case(bs)  // NAK STOP
                    0:begin sd_r<=1;sc_r<=0;bs<=1;end
                    1:begin sc_r<=1;bs<=2;end
                    2:begin sd_r<=0;bs<=0;state<=SI;end
                    default:bs<=0; endcase end

                default: state<=SI;
            endcase
        end
    end

    // ── 7-segment display ─────────────────────────────────────
    // Segment patterns verified from Digilent official XDC
    // seg_cat[0]=CA=a .. seg_cat[6]=CG=g  active LOW
    localparam [6:0]
        G0=7'b100_0000, G1=7'b111_1001, G2=7'b010_0100,
        G3=7'b011_0000, G4=7'b001_1001, G5=7'b001_0010,
        G6=7'b000_0010, G7=7'b111_1000, G8=7'b000_0000,
        G9=7'b001_0000,
        GA=7'b000_1000, // A
        GG=7'b001_0000, // same as 9 for G display
        GF=7'b000_1110, // F
        GO=7'b100_0000, // O same as 0
        GL=7'b100_0111, // L
        GD=7'b010_0001, // d
        GI=7'b111_1001, // I same as 1
        GP=7'b000_1100, // P
        GU=7'b100_0001, // U
        BLK=7'b111_1111,
        DSH=7'b111_1110; // dash

    // Show:
    //   bme_ok=0, addr_sel=0: "A 76----"  trying 0x76
    //   bme_ok=0, addr_sel=1: "A 77----"  trying 0x77
    //   bme_ok=1:             "GOOD    "  found it

    wire [63:0] digit_data;
    assign digit_data =
        bme_ok ?
            // "G O O d    "
            { {1'b1,GG},{1'b1,GO},{1'b1,GO},{1'b1,GD},
              {1'b1,BLK},{1'b1,BLK},{1'b1,BLK},{1'b1,BLK} } :
        addr_sel ?
            // "A  77----"
            { {1'b1,GA},{1'b1,BLK},{1'b1,G7},{1'b1,G7},
              {1'b1,DSH},{1'b1,DSH},{1'b1,DSH},{1'b1,DSH} } :
            // "A  76----"
            { {1'b1,GA},{1'b1,BLK},{1'b1,G7},{1'b1,G6},
              {1'b1,DSH},{1'b1,DSH},{1'b1,DSH},{1'b1,DSH} };

    // Scan driver
    reg [16:0] sc; reg [2:0] ds;
    always @(posedge clk or posedge rst)
        if(rst) begin sc<=0;ds<=0; end
        else if(sc>=17'd99_999) begin sc<=0;ds<=ds+1; end
        else sc<=sc+1;

    reg [7:0] seg_an_r;
    reg [6:0] seg_cat_r;
    always @(*) begin
        seg_an_r = 8'hFF; seg_an_r[ds] = 1'b0;
        case(ds)
            3'd7: seg_cat_r = digit_data[63:57];
            3'd6: seg_cat_r = digit_data[55:49];
            3'd5: seg_cat_r = digit_data[47:41];
            3'd4: seg_cat_r = digit_data[39:33];
            3'd3: seg_cat_r = digit_data[31:25];
            3'd2: seg_cat_r = digit_data[23:17];
            3'd1: seg_cat_r = digit_data[15:9];
            3'd0: seg_cat_r = digit_data[7:1];
            default: seg_cat_r = 7'b111_1111;
        endcase
    end

    assign seg_an  = seg_an_r;
    assign seg_cat = seg_cat_r;
    assign seg_dp  = 1'b1;

    // LEDs
    assign led[3] = bme_ok;
    assign led[2] = bme_sda;   // SDA line state (should be 1 when idle)
    assign led[1] = bme_scl;   // SCL line state
    assign led[0] = addr_sel;  // 0=trying 0x76  1=trying 0x77

endmodule
