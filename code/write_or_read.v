module write_or_read (
    input clk,
    input rst_n,

    input [`E203_ADDR_SIZE-1:0]   read_source_addr,
    input [`E203_ADDR_SIZE-1:0]   write_source_addr,
    input [`E203_ADDR_SIZE-1:0]   data_length,
    input [2:0]                   state,

    output         reg               dma_icb_cmd_valid,
    input                         dma_icb_cmd_ready,
    output [`E203_ADDR_SIZE-1:0]  dma_icb_cmd_addr,
    output                        dma_icb_cmd_read,
    output  reg [`E203_XLEN-1:0]      dma_icb_cmd_wdata,
    output  reg [`E203_XLEN/8-1:0]    dma_icb_cmd_wmask,
    
    input                         dma_icb_rsp_valid,
    output                         dma_icb_rsp_ready,
    input                         dma_icb_rsp_err,
    input [`E203_XLEN-1:0]        dma_icb_rsp_rdata,
    output                       dma_irq
);


reg [5:0] count;
reg [`E203_ADDR_SIZE-1:0] length_count;//表示记录搬移了几个数据
reg [`E203_ADDR_SIZE-1:0] read_addr;
reg [`E203_ADDR_SIZE-1:0] write_addr;


FIFO u_FIFO(
    .clk(clk),
    .rst(~rst_n),
    .buffer_write_en(buffer_write_en),//当从设备有反馈时接收数据，或者发出数据
    .buffer_read_en(buffer_read_en),
    .in_data(dma_icb_rsp_rdata),
    .out_data(dma_icb_cmd_wdata)
);

assign buffer_write_en = (dma_icb_rsp_valid && dma_icb_cmd_read) ?1'b1:1'b0;//buffer的写使能对应的时dma从sram读数据。
assign buffer_read_en = (dma_icb_cmd_ready && (~dma_icb_cmd_read)&&dma_icb_cmd_valid) ? 1'b1:1'b0;


assign dma_icb_cmd_wmask = 32'hFFFF_FFFF;
assign dma_icb_rsp_ready = dma_icb_rsp_valid;
assign dma_icb_cmd_addr = (dma_icb_cmd_read)? read_addr + read_source_addr:write_addr + write_source_addr;
assign dma_icb_cmd_read = ((count <= 15)&&(length_count != data_length)&&(state == 3'b000))?1'b1:1'b0;     //1代表读，0代表写
assign dma_icb_cmd_valid = (state == 3'b000 && dma_icb_rsp_valid != 1)?1'b1:1'b0;


assign dma_irq = ((length_count != 32'd0)&&(length_count == data_length) && empty)?1'b1:1'b0;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        count <= 0;
    else if (state == 3'b000 && count < 31 && dma_icb_rsp_valid)
        count <= count + 1'b1;
    else if (state == 3'b000 && count == 31 && dma_icb_rsp_valid)
        count <= 0;
    else if (state == 3'b111)
        count <= 0;
end


always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        read_addr <= 0;
    else if (state == 3'b000 && count <= 15 && dma_icb_cmd_ready && dma_icb_cmd_valid)
        read_addr <= read_addr + 1;
    else if (state == 3'b111)
        read_addr <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        write_addr <= 0;
    else if (state == 3'b000 && count > 15 && dma_icb_cmd_ready && dma_icb_cmd_valid)
        write_addr <= write_addr + 1;
    else if (state == 3'b111)
        write_addr <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        length_count <= 0;
    else if (dma_icb_cmd_ready && dma_icb_cmd_valid && state == 3'b000 && count <= 15 && length_count != data_length)
        length_count <= length_count + 1;
    else if (dma_icb_cmd_ready && dma_icb_cmd_valid && state == 3'b000 && count <= 15 && length_count == data_length)
        length_count <= length_count;
    else if (state == 3'b111)
        length_count <= 0;
end


endmodule

initial begin
    count <= 0;
    fd = $fopen("mem_r.txt","w");
end
always @(posedge clk) begin
    if (ren)
        count <= count + 1'd1;
    else if (count == 625) begin
        count <= 0;
        $fwrite(fd,mem_r);
    end
end