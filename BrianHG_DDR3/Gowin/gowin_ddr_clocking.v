`include "defines.v"

///////////////////////////////////////////////////////////////////////////////
// Phase control values
// --------------------
// 0000 0°          0001 22.5°          0010 45°            0011 67.5°
// 0100 90°         0101 112.5°         0110 135°           0111 157.5°
// 1000 180°        1001 202.5°         1010 225°           1011 247.5°
// 1100 270°        1101 292.5°         1110 315°           1111 337.5°
//
// Duty cycle values
// -----------------
// 0010 2/16        0011 3/16           0100 4/16           0101 5/16
// 0110 6/16        0111 7/16           1000 8/16           1001 9/16
// 1010 10/16       1011 11/16          1100 12/16          1101 13/16
// 1110 14/16
//
// Delay parameters
// ----------------
// 0111 0.875ns     1011 1.375ns        1101 1.625ns        1110 1.75ns
// 1111 1.875ns
//
///////////////////////////////////////////////////////////////////////////////

module gowin_ddr_clocking
    (
    input               clk,                // External clock
	input			    rst,				// External reset
    input               phase_step,         // step the phase control
    input               phase_updn,         // step phase up (1) or down (0)
    input       [3:0]   fdly,               // dynamic delay of CLKOUTP

    output              clk_ddrMain,        // Main DDR clock
    output              clk_ddrWrite,       // 270° phase-shifted clock
    output              clk_ddrRead,        // User-tuned clock
    output              clk_ddrClient,      // Client-interface clock
    output              clk_ddrMgmt,        // init/long-period timer

    output              locked              // Both PLLs are locked
	);

    reg     [3:0]       duty;               // Duty cycle, 50/50 = 8 + phase
    reg     [3:0]       phase;              // Phase to present to PLL
    reg                 lastPhaseStep;      // Look for the level-transition

    always @ (posedge clk)  
        begin
            if (rst) 
                begin
                    phase           <= 4'b0;
                    duty            <= 4'b0;
                    lastPhaseStep   <= 1'b0;
                end
            else    
                begin
                    if ((phase_step == 1'b1) && (lastPhaseStep == 1'b0))
                        if (phase_updn == 1'b0)
                            begin
                                phase   <= phase - 4'h2;
                                duty    <= phase + 4'h6;    // current phase + (8-2)
                            end
                        else
                            begin
                                phase   <= phase + 4'h2;
                                duty    <= phase + 4'hA;    // current phase + (8+2)

                            end

                    lastPhaseStep <= phase_step;
                end
        end
    
    wire lock_pll1;
    pll_ddr1 ddr1_inst
        (
        .clkin(clk),
        .reset(rst),

        .clkout(clk_ddrMain),
        .clkoutp(clk_ddrRead),
        .clkoutd(clk_ddrClient),
        
        .psda(phase),
        .dutyda(duty),
        .fdly(fdly),

		.lock(lock_pll1)
        );
    
    wire lock_pll2;
    wire dummyClock;
    pll_ddr2 ddr2_inst
        (
        .clkin(clk),
        .reset(rst),

        .clkout(dummyClock),
        .clkoutp(clk_ddrWrite),
        .clkoutd(clk_ddrMgmt),

        .lock(lock_pll2)
        );
    
    assign locked = lock_pll1 & lock_pll2;

endmodule