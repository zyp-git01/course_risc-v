module e203_dma (

    output                          dma_icb_cmd_valid,
    input                           dma_icb_cmd_ready,
    output  [`E203_ADDR_SIZE-1:0]   dma_icb_cmd_addr,
    output                          dma_icb_cmd_read,
    output  [`E203_XLEN-1:0]        dma_icb_cmd_wdata,
    output  [`E203_XLEN/8-1:0]        dma_icb_cmd_wmask,
    //
    input                         dma_icb_rsp_valid,
    output                        dma_icb_rsp_ready,
    input                         dma_icb_rsp_err,
    input [`E203_XLEN-1:0]        dma_icb_rsp_rdata,
    output                        dma_irq,
  
    input                          dma_cfg_icb_cmd_valid,
    output                         dma_cfg_icb_cmd_ready,
    input  [`E203_ADDR_SIZE-1:0]   dma_cfg_icb_cmd_addr,
    input                          dma_cfg_icb_cmd_read,
    input  [`E203_XLEN-1:0]        dma_cfg_icb_cmd_wdata,
    input  [`E203_XLEN/8-1:0]        dma_cfg_icb_cmd_wmask,
    //
    output                         dma_cfg_icb_rsp_valid,
    input                          dma_cfg_icb_rsp_ready,
    output                         dma_cfg_icb_rsp_err,
    output [`E203_XLEN-1:0]        dma_cfg_icb_rsp_rdata,
   
    input 			  clk,
    input                         rst_n
);

/*
    本次采用的都是读写操作下一个周期返回结果
*/
parameter source_reg_addr = 32'h1000_0004;
parameter purpose_reg_addr = 32'h1000_0008;
parameter burst_length_addr = 32'h1000_0020;
parameter state_reg_addr = 32'h1000_0016;

reg dma_cfg_icb_rsp_err;
reg dma_cfg_icb_rsp_valid;

reg [`E203_XLEN-1:0] source_reg;
reg [`E203_XLEN-1:0] purpose_reg;
reg [2:0] state_reg;//各个位为1时表示空闲状态
reg [`E203_XLEN-1:0] burst_length;//操作几个数据


//ready应该是在需要写的寄存器中可以写以及Valid有效
assign dma_cfg_icb_cmd_ready =(dma_cfg_icb_cmd_valid && ((state_reg[0] == 1 &&dma_cfg_icb_cmd_addr == source_reg_addr) 
                                || (state_reg[1] == 1 && dma_cfg_icb_cmd_addr == purpose_reg_addr) 
                                || (state_reg[2] == 1 && dma_cfg_icb_cmd_addr == burst_length_addr)||(dma_cfg_icb_cmd_read && dma_cfg_icb_cmd_addr == state_reg_addr) ))?1'b1:1'b0;
//源地址寄存器的维护
//当valid信号和state_reg[0]信号都为高是才能接收信号
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        source_reg <= 0;
    else if ((state_reg[0] == 1) && (dma_cfg_icb_cmd_valid == 1) && (dma_cfg_icb_rsp_ready == 1) && dma_cfg_icb_cmd_addr == source_reg_addr)
        source_reg <= dma_cfg_icb_cmd_wdata;
    else if (dma_irq)//dma工作完成就将除了状态寄存器外的各个寄存器清0，包括源地址寄存器
        source_reg <= 0;
    else 
        source_reg <= source_reg;
end

assign dma_cfg_icb_rsp_rdata = state_reg;


//目的寄存器的维护
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        purpose_reg <= 0;
    else if ((state_reg[1] == 1) && (dma_cfg_icb_cmd_valid == 1) && dma_cfg_icb_rsp_ready == 1 && dma_cfg_icb_cmd_addr == purpose_reg_addr)
        purpose_reg <= dma_cfg_icb_cmd_wdata;
    else if (dma_irq)
        purpose_reg <= 0;
    else 
        purpose_reg <= purpose_reg;
end

//数据长度的维护
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        burst_length <= 0;
    else if ((state_reg[2] == 1) && (dma_cfg_icb_cmd_valid == 1) && dma_cfg_icb_rsp_ready == 1 && dma_cfg_icb_cmd_addr == burst_length_addr)
        burst_length <= dma_cfg_icb_cmd_wdata;
    else if (dma_irq)
        burst_length <= 0;
    else 
        burst_length <= burst_length;
end

//状态寄存器的维护
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        state_reg <= 3'b111;
    else if ((state_reg[0] == 1) && (dma_cfg_icb_cmd_valid == 1) && (dma_cfg_icb_rsp_ready == 1) && dma_cfg_icb_cmd_addr == source_reg_addr)
        state_reg[0] <= 0;
    else if ((state_reg[1] == 1) && (dma_cfg_icb_cmd_valid == 1) && (dma_cfg_icb_rsp_ready == 1) && dma_cfg_icb_cmd_addr == purpose_reg_addr)
        state_reg[1] <= 0;
    else if ((state_reg[2] == 1) && (dma_cfg_icb_cmd_valid == 1) && (dma_cfg_icb_rsp_ready == 1) && dma_cfg_icb_cmd_addr == burst_length_addr)
        state_reg[2] <= 0;
    
    else if (dma_irq)
        state_reg <= 3'b111;
    else 
        state_reg <= state_reg;
end

//rsp_valid寄存器
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        dma_cfg_icb_rsp_valid <= 0;
    else if ((state_reg[0] == 1) && (dma_cfg_icb_cmd_valid == 1) && (dma_cfg_icb_rsp_ready == 1) && dma_cfg_icb_cmd_addr == source_reg_addr)
        dma_cfg_icb_rsp_valid <= 1;
    else if ((state_reg[1] == 1) && (dma_cfg_icb_cmd_valid == 1) && (dma_cfg_icb_rsp_ready == 1) && dma_cfg_icb_cmd_addr == purpose_reg_addr)
        dma_cfg_icb_rsp_valid <= 1;
    else if ((state_reg[2] == 1) && (dma_cfg_icb_cmd_valid == 1) && (dma_cfg_icb_rsp_ready == 1) && dma_cfg_icb_cmd_addr == burst_length_addr)
        dma_cfg_icb_rsp_valid <= 1;
    else if (dma_cfg_icb_cmd_addr == state_reg_addr)
        dma_cfg_icb_rsp_valid <= 1;
    else 
        dma_cfg_icb_rsp_valid <= 0;
end



//错误反馈寄存器
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        dma_cfg_icb_rsp_err <= 1'b0;
    else if ((state_reg[0] == 0) && (dma_cfg_icb_cmd_valid == 1) && dma_cfg_icb_cmd_addr == source_reg_addr)
        dma_cfg_icb_rsp_err <= 1'b1;
    else if ((state_reg[1] == 0) && (dma_cfg_icb_cmd_valid == 1) && dma_cfg_icb_cmd_addr == purpose_reg_addr)
        dma_cfg_icb_rsp_err <= 1'b1;
    else if ((state_reg[2] == 0) && (dma_cfg_icb_cmd_valid == 1) && dma_cfg_icb_cmd_addr == burst_length_addr)
        dma_cfg_icb_rsp_err <= 1'b1;
    else 
        dma_cfg_icb_rsp_err <= 1'b0;
end
////********************************************************////
////以上都是寄存器的配置
////接下来的都是对SRAM的读写逻辑
////////////////////////////////////////////////////////////////

//     output                          dma_icb_cmd_valid,
//     input                           dma_icb_cmd_ready,
//     output  [`E203_ADDR_SIZE-1:0]   dma_icb_cmd_addr,
//     output                          dma_icb_cmd_read,
//     output  [`E203_XLEN-1:0]        dma_icb_cmd_wdata,
//     output  [`E203_XLEN/8-1:0]        dma_icb_cmd_wmask,
//     //
//     input                         dma_icb_rsp_valid,
//     output                        dma_icb_rsp_ready,
//     input                         dma_icb_rsp_err,
//     input [`E203_XLEN-1:0]        dma_icb_rsp_rdata,
//     output                        dma_irq,
write_or_read u_write_or_read(
    .clk(clk),
    .rst_n(rst_n),

    .read_source_addr(source_reg),
    .write_source_addr(purpose_reg),
    .data_length(burst_length),
    .state(state_reg),
    .dma_icb_cmd_valid(dma_icb_cmd_valid),
    .dma_icb_cmd_ready(dma_icb_cmd_ready),
    .dma_icb_cmd_addr(dma_icb_cmd_addr),
    .dma_icb_cmd_read(dma_icb_cmd_read),
    .dma_icb_cmd_wdata(dma_icb_cmd_wdata),
    .dma_icb_cmd_wmask(dma_icb_cmd_wmask),
    //
    .dma_icb_rsp_valid(dma_icb_rsp_valid),
    .dma_icb_rsp_ready(dma_icb_rsp_ready),
    .dma_icb_rsp_err(dma_icb_rsp_err),
    .dma_icb_rsp_rdata(dma_icb_rsp_rdata),
    .dma_irq(dma_irq)

);





endmodule

