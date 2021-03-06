/**
 reg fsm_reset_done;
reg fsm_powerdown_quad;
reg fsm_config_done;
reg fsm_cable_detect;
reg fsm_cdr_lock;
reg fsm_test_mode_en;
reg fsm_defective_lane;
reg fsm_deskewed_qci0i1;
reg fsm_qc_timeout;
reg fsm_caps_drained;
reg fsm_f_below_max;
reg fsm_saw_i1;
reg fsm_idle_done;
reg fsm_i1_gone;
reg fsm_reset_quad;

wire fsm_wait_phy;
wire fsm_config_phy;
wire fsm_send_i0;
wire fsm_send_i1;
wire fsm_cfg_link_width;
wire fsm_adjust_caps;
wire fsm_qc;
wire fsm_L0;
wire fsm_L1;
wire fsm_test_mode;
wire fsm_tx_idle;
wire fsm_wait_cable;

QUAD_FSM QUAD_FSM_I (

	//-- Inputs
	.reset_done(fsm_reset_done), 
	.powerdown_quad(fsm_powerdown_quad), 
	.config_done(fsm_config_done), 
	.cable_detect(fsm_cable_detect), 
	.cdr_lock(fsm_cdr_lock), 
	.test_mode_en(fsm_test_mode_en), 
	.defective_lane(fsm_defective_lane), 
	.deskewed_qci0i1(fsm_deskewed_qci0i1), 
	.qc_timeout(fsm_qc_timeout), 
	.caps_drained(fsm_caps_drained), 
	.f_below_max(fsm_f_below_max), 
	.saw_i1(fsm_saw_i1), 
	.idle_done(fsm_idle_done), 
	.i1_gone(fsm_i1_gone), 
	.reset_quad(fsm_reset_quad), 

	//-- Outputs
	.wait_phy(fsm_wait_phy), 
	.config_phy(fsm_config_phy), 
	.send_i0(fsm_send_i0), 
	.send_i1(fsm_send_i1), 
	.cfg_link_width(fsm_cfg_link_width), 
	.adjust_caps(fsm_adjust_caps), 
	.qc(fsm_qc), 
	.L0(fsm_L0), 
	.L1(fsm_L1), 
	.test_mode(fsm_test_mode), 
	.tx_idle(fsm_tx_idle), 
	.wait_cable(fsm_wait_cable)
);

 */
module QUAD_FSM ( 
    input wire clk, 
    input wire res_n, 

    // Inputs
    //------------ 
    input wire reset_done, 
    input wire powerdown_quad, 
    input wire config_done, 
    input wire cable_detect, 
    input wire cdr_lock, 
    input wire test_mode_en, 
    input wire defective_lane, 
    input wire deskewed_qci0i1, 
    input wire qc_timeout, 
    input wire caps_drained, 
    input wire f_below_max, 
    input wire saw_i1, 
    input wire idle_done, 
    input wire i1_gone, 
    input wire reset_quad, 

    // Outputs
    //------------ 
    output wire wait_phy, 
    output wire config_phy, 
    output wire send_i0, 
    output wire send_i1, 
    output wire cfg_link_width, 
    output wire adjust_caps, 
    output wire qc, 
    output wire L0, 
    output wire L1, 
    output wire test_mode, 
    output wire tx_idle, 
    output wire wait_cable
 );

localparam wait_ready = 12'b100000000000;
localparam config_phy = 12'b010000000000;
localparam qc = 12'b001000100000;
localparam L0 = 12'b000000010000;
localparam L1 = 12'b000000001000;
localparam test_mode = 12'b000000000100;
localparam wait_cable = 12'b000000000001;
localparam wait_CDR = 12'b001000000000;
localparam link_width = 12'b001010000000;
localparam wait_i1_local_caps = 12'b000100000000;
localparam adjust_caps = 12'b000001000000;
localparam TX_idle = 12'b000000000010;
localparam stop_i1 = 12'b000000000000;

reg [11:0] current_state, next_state;
assign {wait_phy, config_phy, send_i0, send_i1, cfg_link_width, adjust_caps, qc, L0, L1, test_mode, tx_idle, wait_cable} = current_state;

wire [14:0] inputvector;
assign inputvector = {reset_done, powerdown_quad, config_done, cable_detect, cdr_lock, test_mode_en, defective_lane, deskewed_qci0i1, qc_timeout, caps_drained, f_below_max, saw_i1, idle_done, i1_gone, reset_quad};


always @(*) begin
  casex({inputvector, current_state})
    {15'bnone    0      , wait_ready}:   next_state = wait_ready;
    {15'b10xxxxxxxxxxxx0, wait_ready}:   next_state = config_phy;
    {15'bnone    0      , config_phy}:   next_state = config_phy;
    {15'bx01xxxxxx0xxxx0, config_phy}:   next_state = wait_cable;
    {15'bx010xxxxx1xxxx0, config_phy}:   next_state = L1;
    {15'bnone    0      , qc}:   next_state = qc;
    {15'bx0111xx10xxxxx0, qc}:   next_state = wait_i1_local_caps;
    {15'bx0111xxx1xxxxx0, qc}:   next_state = adjust_caps;
    {15'bx0x0xxxxxxxxxx0, qc}:   next_state = TX_idle;
    {15'bx0xx0xxxxxxxxx0, qc}:   next_state = TX_idle;
    {15'bnone    0      , L0}:   next_state = L0;
    {15'bx00xxxxxxxxxxx0, L0}:   next_state = TX_idle;
    {15'bx0x0xxxxxxxxxx0, L0}:   next_state = TX_idle;
    {15'bx0xx0xxxxxxxxx0, L0}:   next_state = TX_idle;
    {15'bnone    0      , L1}:   next_state = L1;
    {15'bx0x0xxxxxxxxxx0, L1}:   next_state = wait_ready;
    {15'bnone    0      , test_mode}:   next_state = test_mode;
    {15'bnone    0      , wait_cable}:   next_state = wait_cable;
    {15'bx0x1xxxxxxxxxx0, wait_cable}:   next_state = wait_CDR;
    {15'bnone  + 0      , wait_CDR}:   next_state = wait_CDR;
    {15'bx0xx1xxxxxxxxx0, wait_CDR}:   next_state = link_width;
    {15'bnone xxx0      , link_width}:   next_state = link_width;
    {15'bx0xxx01xxxxxxx0, link_width}:   next_state = L1;
    {15'bx0xxx1xxxxxxxx0, link_width}:   next_state = test_mode;
    {15'bx0xxx00xxxxxxx0, link_width}:   next_state = qc;
    {15'bnone xxx0      , wait_i1_local_caps}:   next_state = wait_i1_local_caps;
    {15'bx0111xxxxx11xx0, wait_i1_local_caps}:   next_state = config_phy;
    {15'bx0111xxxxx01xx0, wait_i1_local_caps}:   next_state = stop_i1;
    {15'bx0x0xxxxxxxxxx0, wait_i1_local_caps}:   next_state = TX_idle;
    {15'bx0xx0xxxxxxxxx0, wait_i1_local_caps}:   next_state = TX_idle;
    {15'bnone    0      , adjust_caps}:   next_state = config_phy;
    {15'bnone    0      , TX_idle}:   next_state = TX_idle;
    {15'bx0xxxxxxxxxx1x0, TX_idle}:   next_state = wait_ready;
    {15'bnone    0      , stop_i1}:   next_state = stop_i1;
    {15'bx0111xxxxxxxx10, stop_i1}:   next_state = L0;
    {15'bx0x0xxxxxxxxxx0, stop_i1}:   next_state = TX_idle;
    {15'bx0xx0xxxxxxxxx0, stop_i1}:   next_state = TX_idle;
    {15'b01xxxxxxxxxxxx0, 12'bxxxxxxxxxxxx}:   next_state = L1;
    {15'bxxxxxxxxxxxxxxx, 12'bxxxxxxxxxxxx}:   next_state = L1;
    {15'bxxxxxxxxxxxxxx1, 12'bxxxxxxxxxxxx}:   next_state = wait_ready;
    default:  next_state = wait_ready;
  endcase
end

`ifdef ASYNC_RES
 always @(posedge clk or negedge res_n ) begin
`else
 always @(posedge clk) begin
`endif
    if (!res_n)
    begin
        current_state <= wait_ready;
    end
    else begin
        current_state <= next_state;
    end
end

`ifdef CAG_COVERAGE
// synopsys translate_off

	// State coverage
	//--------

	//-- Coverage group declaration
	covergroup cg_states @(posedge clk);
		states : coverpoint current_state {
			bins wait_ready = {wait_ready};
			bins config_phy = {config_phy};
			bins qc = {qc};
			bins L0 = {L0};
			bins L1 = {L1};
			bins test_mode = {test_mode};
			bins wait_cable = {wait_cable};
			bins wait_CDR = {wait_CDR};
			bins link_width = {link_width};
			bins wait_i1_local_caps = {wait_i1_local_caps};
			bins adjust_caps = {adjust_caps};
			bins TX_idle = {TX_idle};
			bins stop_i1 = {stop_i1};
		}
	endgroup : cg_states

	//-- Coverage group instanciation
	cg_states state_cov_I;
	initial begin
		state_cov_I = new();
		state_cov_I.set_inst_name("state_cov_I");
	end

	// Transitions coverage
	//--------

	tc_reset_done: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'b10xxxxxxxxxxxx0) &&(current_state == wait_ready)|=> (current_state == config_phy));

	tc_config_done: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx01xxxxxx0xxxx0) &&(current_state == config_phy)|=> (current_state == wait_cable));

	tc_qc_deskew_ok: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0111xx10xxxxx0) &&(current_state == qc)|=> (current_state == wait_i1_local_caps));

	tc_defective_lanes: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0xxx01xxxxxxx0) &&(current_state == link_width)|=> (current_state == L1));

	tc_test_en: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0xxx1xxxxxxxx0) &&(current_state == link_width)|=> (current_state == test_mode));

	tc_wait_ready_to_wait_ready_default: cover property( @(posedge clk) disable iff (!res_n)if (current_state == wait_ready))|=> (current_state == wait_ready) );

	tc_config_phy_to_config_phy_default: cover property( @(posedge clk) disable iff (!res_n)if (current_state == config_phy))|=> (current_state == config_phy) );

	tc_cable_detect: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0x1xxxxxxxxxx0) &&(current_state == wait_cable)|=> (current_state == wait_CDR));

	tc_cdr_done: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0xx1xxxxxxxxx0) &&(current_state == wait_CDR)|=> (current_state == link_width));

	tc_wait_CDR_to_wait_CDR_default: cover property( @(posedge clk) disable iff (!res_n)if (current_state == wait_CDR))|=> (current_state == wait_CDR) );

	tc_wait_cable_to_wait_cable_default: cover property( @(posedge clk) disable iff (!res_n)if (current_state == wait_cable))|=> (current_state == wait_cable) );

	tc_link_width_to_link_width_default: cover property( @(posedge clk) disable iff (!res_n)if (current_state == link_width))|=> (current_state == link_width) );

	tc_quad_ok: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0xxx00xxxxxxx0) &&(current_state == link_width)|=> (current_state == qc));

	tc_L1_to_L1_default: cover property( @(posedge clk) disable iff (!res_n)if (current_state == L1))|=> (current_state == L1) );

	tc_test_mode_to_test_mode_default: cover property( @(posedge clk) disable iff (!res_n)if (current_state == test_mode))|=> (current_state == test_mode) );

	tc_qc_to_qc_default: cover property( @(posedge clk) disable iff (!res_n)if (current_state == qc))|=> (current_state == qc) );

	tc_timeout: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0111xxx1xxxxx0) &&(current_state == qc)|=> (current_state == adjust_caps));

	tc_adjust_caps_to_config_phy_default: cover property( @(posedge clk) disable iff (!res_n)if (current_state == adjust_caps))|=> (current_state == config_phy) );

	tc_caps_drained: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx010xxxxx1xxxx0) &&(current_state == config_phy)|=> (current_state == L1));

	tc_current_f_below_max_current_f_below_caps: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0111xxxxx11xx0) &&(current_state == wait_i1_local_caps)|=> (current_state == config_phy));

	tc_saw_i1: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0111xxxxx01xx0) &&(current_state == wait_i1_local_caps)|=> (current_state == stop_i1));

	tc_wait_i1_local_caps_to_wait_i1_local_caps_default: cover property( @(posedge clk) disable iff (!res_n)if (current_state == wait_i1_local_caps))|=> (current_state == wait_i1_local_caps) );

	tc_lost_data_c0_lost_cable: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0x0xxxxxxxxxx0) &&(current_state == qc)|=> (current_state == TX_idle));

	tc_lost_data_c1_lost_cdr: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0xx0xxxxxxxxx0) &&(current_state == qc)|=> (current_state == TX_idle));

	tc_trans_25_c0_lost_cable: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0x0xxxxxxxxxx0) &&(current_state == wait_i1_local_caps)|=> (current_state == TX_idle));

	tc_trans_25_c1_lost_cdr: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0xx0xxxxxxxxx0) &&(current_state == wait_i1_local_caps)|=> (current_state == TX_idle));

	tc_L0_to_L0_default: cover property( @(posedge clk) disable iff (!res_n)if (current_state == L0))|=> (current_state == L0) );

	tc_TX_idle_to_TX_idle_default: cover property( @(posedge clk) disable iff (!res_n)if (current_state == TX_idle))|=> (current_state == TX_idle) );

	tc_trans_28_c0_lost_phy: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx00xxxxxxxxxxx0) &&(current_state == L0)|=> (current_state == TX_idle));

	tc_trans_28_c1_lost_cable: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0x0xxxxxxxxxx0) &&(current_state == L0)|=> (current_state == TX_idle));

	tc_trans_28_c2_lost_cdr: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0xx0xxxxxxxxx0) &&(current_state == L0)|=> (current_state == TX_idle));

	tc_idle_done: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0xxxxxxxxxx1x0) &&(current_state == TX_idle)|=> (current_state == wait_ready));

	tc_stop_i1_to_stop_i1_default: cover property( @(posedge clk) disable iff (!res_n)if (current_state == stop_i1))|=> (current_state == stop_i1) );

	tc_i1_gone: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0111xxxxxxxx10) &&(current_state == stop_i1)|=> (current_state == L0));

	tc_trans_31_c0_lost_cable: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0x0xxxxxxxxxx0) &&(current_state == stop_i1)|=> (current_state == TX_idle));

	tc_trans_31_c1_lost_cdr: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0xx0xxxxxxxxx0) &&(current_state == stop_i1)|=> (current_state == TX_idle));

	tc_cable_unplugged: cover property( @(posedge clk) disable iff (!res_n)(inputvector ==? 15'bx0x0xxxxxxxxxx0) &&(current_state == L1)|=> (current_state == wait_ready));

// synopsys translate_on
`endif


endmodule
