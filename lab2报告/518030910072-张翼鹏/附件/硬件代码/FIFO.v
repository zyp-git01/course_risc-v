
module FIFO(
     input clk,
     input rst,
     input [`E203_XLEN-1:0] in_data,
     input buffer_write_en,
 
     input buffer_read_en,
     output [`E203_XLEN-1:0]out_data
);  

parameter WIDTH=6'd32,DEPTH=5'd16;//假设位宽为8，深度为64,只考虑深度为2的幂次方的情况

reg [WIDTH-1 : 0] ram [DEPTH-1 : 0];//开辟存储区
reg [DEPTH-1 : 0] count;
reg [4:0] rp_addr;
reg [4:0] wp_addr;//定义读写指针

//写入数据din
always@(posedge clk) begin
if(buffer_write_en)begin
ram[wp_addr] <= in_data;
end
end

//读出数据dout
assign out_data = (buffer_read_en)?ram[rp_addr]:0;

//写指针wp
always@(posedge clk)begin
if(rst)begin
wp_addr <= 0;
end
else if(buffer_write_en & wp_addr < 15) begin
wp_addr <= wp_addr + 1;
end
else if(wp_addr == 15&&buffer_write_en)begin
wp_addr <= 0;
end
end
//读指针rp
always@(posedge clk) begin
if(rst) begin
rp_addr <= 0;
end
else if(buffer_read_en && rp_addr < 15) begin
rp_addr <= rp_addr + 1;
end
else if(buffer_read_en && rp_addr == 15) begin
rp_addr <= 0;
end
end


endmodule
