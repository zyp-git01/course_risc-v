#                                  									LAB-1 I2C实验报告

​																								张翼鹏 518030910072

## 一、例程如何编译

​		1、首先使用$cd \ ../hbird-e-sdk-master$命令进入文件夹，执行命令$make\ dasm \ PROGRAM=demo\_i2c$，通过查看$Makefile$文件：

```makefile
dasm: software 
	$(RISCV_OBJDUMP) -D $(PROGRAM_ELF) >& $(PROGRAM_ELF).dump
	$(RISCV_OBJCOPY) $(PROGRAM_ELF) -O verilog $(PROGRAM_ELF).verilog
	sed -i 's/@800/@000/g' $(PROGRAM_ELF).verilog
```

​		从上边所示文件的一部分可以看出，$dasm$是将多个命令集成在一起，第一行是执行$dump$文件，$dump$文件对C文件进行编译，$dump$文件的名称已经在$Makefile$文件的开头给出：

```makefile
PROGRAM_ELF = software/$(PROGRAM)/$(PROGRAM)
```

​		第二行是执行$verilog$文件。

​		其中$PROGRAM=demo\_i2c$文件指定了编译文件的文件名。

## 二、程序如何加载

​		进入到$vsim$文件夹后，可以看到$install$文件夹，其中的文件夹可以通过$make\ install$命令，通过$Makefile$中的指定位置，将其中的文件夹复制进$install$文件夹中，打开$install$文件夹中的$tb_top.v$文件。

​		$tb\_top.v$文件部分内容如下所示：

```verilog
reg [7:0] itcm_mem [0:(`E203_ITCM_RAM_DP*8)-1];
     initial begin
       $readmemh({testcase, ".verilog"}, itcm_mem);
 
       for (i=0;i<(`E203_ITCM_RAM_DP);i=i+1) begin
           `ITCM.mem_r[i][00+7:00] = itcm_mem[i*8+0];
           `ITCM.mem_r[i][08+7:08] = itcm_mem[i*8+1];
           `ITCM.mem_r[i][16+7:16] = itcm_mem[i*8+2];
           `ITCM.mem_r[i][24+7:24] = itcm_mem[i*8+3];
           `ITCM.mem_r[i][32+7:32] = itcm_mem[i*8+4];
           `ITCM.mem_r[i][40+7:40] = itcm_mem[i*8+5];
           `ITCM.mem_r[i][48+7:48] = itcm_mem[i*8+6];
           `ITCM.mem_r[i][56+7:56] = itcm_mem[i*8+7];
       end
 
         $display("ITCM 0x00: %h", `ITCM.mem_r[8'h00]);
         $display("ITCM 0x01: %h", `ITCM.mem_r[8'h01]);
         $display("ITCM 0x02: %h", `ITCM.mem_r[8'h02]);
         $display("ITCM 0x03: %h", `ITCM.mem_r[8'h03]);
         $display("ITCM 0x04: %h", `ITCM.mem_r[8'h04]);
         $display("ITCM 0x05: %h", `ITCM.mem_r[8'h05]);
         $display("ITCM 0x06: %h", `ITCM.mem_r[8'h06]);
         $display("ITCM 0x07: %h", `ITCM.mem_r[8'h07]);
         $display("ITCM 0x16: %h", `ITCM.mem_r[8'h16]);
         $display("ITCM 0x20: %h", `ITCM.mem_r[8'h20]);
```

​		其中，将指令读入$itcm\_mem$寄存器中，再将其中的指令转入$`ITCM.mem\_r$中，其中的$ITCM$在文件开头通过$define$定义：

```verilog
`define ITCM `CPU_TOP.u_e203_srams.u_e203_itcm_ram.u_e203_itcm_gnrl_ram.u_sirv_sim_ram
```

​		我对此的理解是，将已经实例化的指令存储器与$ITCM$变量进行关联。从而可以在顶层文件中使用更加底层的实例化模块。

​		接着阅读$vsim$文件夹下的$rtl$文件夹下的$core/e203\_cpu\_top.v$文件，可以看到如下图所示的部分代码：

​												![](D:\Desktop\risc-v\LAB1-报告\图片\cpu部分代码.PNG)

​		再看$demo\_i2c$文件夹下，可以看到$demo\_i2c.dump$文件，部分内容如下图所示：

​		![](D:\Desktop\risc-v\LAB1-报告\图片\dump文件.PNG)

​		可以看到每一行的开头都为此行代码对应的地址，从$8000\_0000$起步，32位指令，地址每次递增4(如8000_0004)；16位指令，地址每次递增2(如8000_0064-8000_0066)。结合波形。

​		可以看到，代码中$inspect\_pc$即为指令计数器。可以从$verdi$中看到波形，部分波形如下图所示：![](D:\Desktop\risc-v\LAB1-报告\图片\pc值.PNG)

​		通过波形，可以看到PC值刚开始为依次递增的变化，即每次都从指令存储器中取出指令。

## 三、I2C的基本工作原理

​		通过查找网上的资料，我了解到$I2C$的工作原理如图所示：

​		                  ![](D:\Desktop\risc-v\LAB1-报告\图片\写时序.gif)

​																			                                 写时序

![读时序](D:\Desktop\risc-v\LAB1-报告\图片\读时序.gif)

​																			                                 读时序

​		写入数据：发送一个起始信号（$master$设备会将$SCL$置为高电平「当总线空闲时，$SDA$和$SCL$都处于高电平状态」，然后将$SDA$拉低，这样，所有$slave$设备就会知道传输即将开始。）接着是主设备会发送从设备的地址加一个读写标志位，其中写标志是$0$，如果有某个从设备的地址与之匹配，从设备会返回一个应答信号$ACK$，那么接下来的通信就在主设备和此从设备之间进行。主设备会继续发送一个要写入数据的寄存器地址，加一个从设备的应答信号，再紧接着发送8位数据，从设备再进行一次应答，如果数据通信就此结束，那么终止信号是在$SDA$置于低电平时，将$SCL$拉高并保持高电平，然后将$SDA$拉高。

​		读出数据：与写入数据相同，发送一个起始信号。接着主设备发送从设备地址加一个读写标志位，其中读标志是$1$。主设备发送一个寄存器地址，接下来从设备向主设备发送$8$位数据。

​		读写数据过程中，都是$SCL$为跳跃的高电平时有效，如下图所示：

​											![](D:\Desktop\risc-v\LAB1-报告\图片\数据有效.PNG)

​		

​		结合本次项目中所用到的蜂鸟CPU以及I2C模块，在$e203\_subsys\_perips$模块下看到对i2c_master和对i2c_slave模块的例化，打开文件，可以看到如下图所示的信号连接:

![](D:\Desktop\risc-v\LAB1-报告\图片\例化.PNG)

​		上图所示的代码片段中，只有i2c_req信号是向CPU发送的，i2c的从设备中的scl信号和sda信号是如下图所示产生的：

​							![](D:\Desktop\risc-v\LAB1-报告\图片\i2c_scl_sda.PNG)

​		可以看到，$i2c\_scl\_pad\_i$和$i2c\_sda\_pad\_i$信号会分别根据$i2c\_scl\_padoen\_o$$i2c\_sda\_padoen\_o$信号进行选择，如果为高阻态，那么会有$pullup$进行拉高。这一点可以根据代码结合网上查找到的$I2C$协议分析得出。为了分析整个I2C信号是如何从CPU到I2C主从设备之间如何变化的。波形如下图所示：

​		![](D:\Desktop\risc-v\LAB1-报告\图片\CPU-I2C.PNG)

​		可以看到，当I2C传递完从设备地址信号之后，会将i2c_irq信号拉高，做i2c的中断请求。

​		放大之后，可以看到代码中在$i2c\_irq$信号拉高后，PC值如下图所示为$8000\_015e$：

​																										![](D:\Desktop\risc-v\LAB1-报告\图片\8000-015e.PNG)

​		再结合之前所说的demo_i2c,dump文件，找到PC值为$8000\_015e$对应的那一行如下图所示：

​		![](D:\Desktop\risc-v\LAB1-报告\图片\i2c——dump.PNG)

​		从上图中的红色部分可以看出，这些部分对应的是进入了C文件中的$OV\_WriteReg$函数，向I2C发送寄存器地址和数据。

## 四、波形截图验证输出

​		整体波形如下图所示：![](D:\Desktop\risc-v\LAB1-报告\图片\捕获.PNG)

​		起始信号加从设备地址加读写标志加应答信号：

​																			![](D:\Desktop\risc-v\LAB1-报告\图片\起始地址.PNG)

​																						（从设备地址<<1+写标志）

​		寄存器地址：

​																				![](D:\Desktop\risc-v\LAB1-报告\图片\寄存器地址.PNG)

​																							（首地址0x12​加应答信号）

​		我的学号为518030910072，第一个数据为0x51：

​																					![](D:\Desktop\risc-v\LAB1-报告\图片\第一个数据.PNG)

​																					（01010001）对应0x51

​		第二个数据为0x80：

​																						![](D:\Desktop\risc-v\LAB1-报告\图片\第二个数据.PNG)

​																						（10000000）对应0x80

​		以此类推。

## 五、C文件需要更改的地方

​		如果不修改C文件中的写函数，那么每次写数据都要重新发送一遍从设备地址和寄存器地址。

​		修改后的函数为(注释有乱码)：

```c
uint8_t OV_WriteReg(uint8_t regID, uint8_t *regDat,int length)
{
        printf("write addr : %x ,write data :%x \n",regID,regDat);
        //phase 1
        I2C_REG(I2C_REG_TXR)= SLAVE_ADDR<<1 +0 ;// 0 = write
        I2C_REG(I2C_REG_CR) = 0x90;     //1001 0000   // start bit and WR bit
        while ((I2C_REG(I2C_REG_SR)&0x02)!=0x00)
        {

        }//纭畾鍛戒护宸茬粡鍙戝嚭
        printf("phase 1 cmd sent\n");

        //phase 2
        I2C_REG(I2C_REG_TXR)= regID ;//灏嗚鍙戦€佺殑ID瑁呰繘瀵勫瓨鍣?        
        I2C_REG(I2C_REG_CR) = 0x10;//鍙戦€佷粠璁惧瀛愬湴鍧€  // WR bit
        while ((I2C_REG(I2C_REG_SR)&0x02)!=0x00)
        { }//纭畾鍛戒护宸茬粡鍙戝嚭
        printf("phase 2 cmd sent\n");


        for (int i = 1;i <= length;i++){
                I2C_REG(I2C_REG_TXR)=regDat[i-1]; //灏嗚鍙戦€佺殑鏁版嵁鍐欒繘瀵勫瓨鍣?                I2C_REG(I2C_REG_CR) = 0x10;// WR bit 
                while ((I2C_REG(I2C_REG_SR)&0x02)!=0x00)
                { }//纭畾鍛戒护宸茬粡鍙戝嚭
        }
        //phase 3
        // I2C_REG(I2C_REG_TXR)=regDat; //灏嗚鍙戦€佺殑鏁版嵁鍐欒繘瀵勫瓨鍣?        // I2C_REG(I2C_REG_CR) = 0x10;// WR bit 
        // while ((I2C_REG(I2C_REG_SR)&0x02)!=0x00)
        // { }//纭畾鍛戒护宸茬粡鍙戝嚭

        // phase 4
        I2C_REG(I2C_REG_CR)=0x40; // Stop bit
        printf("stop \n");

        return 0;
}
```

​		相比之前函数修改的地方在于，第三部分发送数据用for循环重复发送数据，而函数的参数列表之前为一个数据，现在用指针接收一个数组，再多一个数组长度参数$length$。

## 六、SOC结构

​		引用附件中的一张图片：

​		![](D:\Desktop\risc-v\LAB1-报告\图片\SOC.PNG)

​		具体的从处理器到I2C的通路在I2C工作原理中已经说明。

