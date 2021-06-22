 /*                                                                      
 Copyright 2018 Nuclei System Technology, Inc.                
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
  Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */                                                                      
                                                                         
                                                                         
                                                                         
//=====================================================================
//
// Designer   : Bob Hu
//
// Description:
//  The system memory bus and the ROM instance 
//
// ====================================================================


`include "e203_defines.v"


module e203_subsys_mems(
  input                          mem_icb_cmd_valid,
  output                         mem_icb_cmd_ready,
  input  [`E203_ADDR_SIZE-1:0]   mem_icb_cmd_addr, 
  input                          mem_icb_cmd_read, 
  input  [`E203_XLEN-1:0]        mem_icb_cmd_wdata,
  input  [`E203_XLEN/8-1:0]      mem_icb_cmd_wmask,
  //
  output                         mem_icb_rsp_valid,
  input                          mem_icb_rsp_ready,
  output                         mem_icb_rsp_err,
  output [`E203_XLEN-1:0]        mem_icb_rsp_rdata,
  

  input                          dma_icb_cmd_valid,
  output                         dma_icb_cmd_ready,
  input  [`E203_ADDR_SIZE-1:0]   dma_icb_cmd_addr, 
  input                          dma_icb_cmd_read, 
  input  [`E203_XLEN-1:0]        dma_icb_cmd_wdata,
  input  [`E203_XLEN/8-1:0]      dma_icb_cmd_wmask,
  //
  output                         dma_icb_rsp_valid,
  input                          dma_icb_rsp_ready,
  output                         dma_icb_rsp_err,
  output [`E203_XLEN-1:0]        dma_icb_rsp_rdata,
  input  clk,
  input  bus_rst_n,
  input  rst_n
  );
////////////////////////////////////////////////
////////  arbt        ///////////////////////////

//arb in signals
  wire [2*1-1:0]                    arbt_bus_icb_cmd_valid;
  wire [2*1-1:0]                    arbt_bus_icb_cmd_ready;
  wire [2*`E203_ADDR_SIZE-1:0]      arbt_bus_icb_cmd_addr; 
  wire [2*1-1:0]                    arbt_bus_icb_cmd_read; 
  wire [2*`E203_XLEN-1:0]           arbt_bus_icb_cmd_wdata;
  wire [2*`E203_XLEN/8-1:0]         arbt_bus_icb_cmd_wmask;

  wire [2*1-1:0]                    arbt_bus_icb_cmd_lock;
  wire [2*1-1:0]                    arbt_bus_icb_cmd_excl;
  wire [2*2-1:0]                    arbt_bus_icb_cmd_size;
  wire [2*1-1:0]                    arbt_bus_icb_cmd_usr;
  wire [2*2-1:0]                    arbt_bus_icb_cmd_burst;
  wire [2*2-1:0]                    arbt_bus_icb_cmd_beat;

  wire [2*1-1:0]                    arbt_bus_icb_rsp_valid;
  wire [2*1-1:0]                    arbt_bus_icb_rsp_ready;
  wire [2*1-1:0]                    arbt_bus_icb_rsp_err;
  wire [2*`E203_XLEN-1:0]           arbt_bus_icb_rsp_rdata;
  
  wire [2*1-1:0]                    arbt_bus_icb_rsp_excl_ok;
  wire [2*1-1:0]                    arbt_bus_icb_rsp_usr;

//arb out signals

  wire [1-1:0]                    arbt_icb_cmd_valid;
  wire [1-1:0]                    arbt_icb_cmd_ready;
  wire [`E203_ADDR_SIZE-1:0]      arbt_icb_cmd_addr; 
  wire [1-1:0]                    arbt_icb_cmd_read; 
  wire [`E203_XLEN-1:0]           arbt_icb_cmd_wdata;
  wire [`E203_XLEN/8-1:0]         arbt_icb_cmd_wmask;


  wire                            arbt_icb_rsp_valid;
  wire                            arbt_icb_rsp_ready;
  wire                            arbt_icb_rsp_err;
  wire [`E203_XLEN-1:0]           arbt_icb_rsp_rdata;


//in signal logic
  assign arbt_bus_icb_cmd_valid=
//the cpu icb has higner priority
				{dma_icb_cmd_valid,
				 mem_icb_cmd_valid
				};
  assign arbt_bus_icb_cmd_addr=
//the cpu icb has higner priority
				{dma_icb_cmd_addr,
				 mem_icb_cmd_addr
				};
      
  assign arbt_bus_icb_cmd_read=
//the cpu icb has higner priority
				{dma_icb_cmd_read,
				 mem_icb_cmd_read
				};
  
  assign arbt_bus_icb_cmd_wdata=
//the cpu icb has higner priority
				{dma_icb_cmd_wdata,
				 mem_icb_cmd_wdata
				};

  assign arbt_bus_icb_cmd_wmask=
//the cpu icb has higner priority
				{dma_icb_cmd_wmask,
				 mem_icb_cmd_wmask
				};

  assign arbt_bus_icb_cmd_lock=
//the cpu icb has higner priority
				{1'b0,
				 1'b0
				};

  assign arbt_bus_icb_cmd_burst=
//the cpu icb has higner priority
				{2'b0,
				 2'b0
				};

  assign arbt_bus_icb_cmd_beat=
//the cpu icb has higner priority
				{2'b0,
				 2'b0
				};

  assign arbt_bus_icb_cmd_excl=
//the cpu icb has higner priority
				{1'b0,
				 1'b0
				};

  assign arbt_bus_icb_cmd_size=//?????????????
//the cpu icb has higner priority
				{2'b0,
				 2'b0
				};

  assign arbt_bus_icb_rsp_ready=//
//the cpu icb has higner priority
				{dma_icb_rsp_ready,
				 mem_icb_rsp_ready
				};

  assign arbt_bus_icb_cmd_usr=
//the cpu icb has higner priority
				{1'b1,
				 1'b0
				};

  assign {dma_icb_cmd_ready,
	  mem_icb_cmd_ready
	 } = arbt_bus_icb_cmd_ready;

  assign {dma_icb_rsp_valid,
	  mem_icb_rsp_valid
	 } = arbt_bus_icb_rsp_valid;

  assign {dma_icb_rsp_err,
	  mem_icb_rsp_err
	 } = arbt_bus_icb_rsp_err;

  assign {dma_icb_rsp_rdata,
	  mem_icb_rsp_rdata
	 } = arbt_bus_icb_rsp_rdata;

//the arbt module
  sirv_gnrl_icb_arbt # (
  .ARBT_SCHEME (0),// Priority based
  .ALLOW_0CYCL_RSP (0),// Dont allow the 0 cycle response because in BIU we always have CMD_DP larger than 0
                       //   when the response come back from the external bus, it is at least 1 cycle later
                       //   for ITCM and DTCM, Dcache, .etc, definitely they cannot reponse as 0 cycle
  .FIFO_OUTS_NUM   (1),
  .FIFO_CUT_READY  (0),
  .ARBT_NUM   (2),
  .ARBT_PTR_W (1),
  .USR_W      (1),
  .AW         (`E203_ADDR_SIZE),
  .DW         (`E203_XLEN) 
  ) u_mem_icb_arbt(
  .o_icb_cmd_valid        (arbt_icb_cmd_valid )     ,
  .o_icb_cmd_ready        (arbt_icb_cmd_ready )     ,
  .o_icb_cmd_read         (arbt_icb_cmd_read )      ,
  .o_icb_cmd_addr         (arbt_icb_cmd_addr )      ,
  .o_icb_cmd_wdata        (arbt_icb_cmd_wdata )     ,
  .o_icb_cmd_wmask        (arbt_icb_cmd_wmask)      ,
  .o_icb_cmd_burst        (                  )     ,
  .o_icb_cmd_beat         (                  )     ,
  .o_icb_cmd_excl         (                  )     ,
  .o_icb_cmd_lock         (                  )     ,
  .o_icb_cmd_size         (                  )     ,
  .o_icb_cmd_usr          (                  )     ,
                                
  .o_icb_rsp_valid        (arbt_icb_rsp_valid )     ,
  .o_icb_rsp_ready        (arbt_icb_rsp_ready )     ,
  .o_icb_rsp_err          (arbt_icb_rsp_err)        ,
  .o_icb_rsp_excl_ok      (                   )    ,
  .o_icb_rsp_rdata        (arbt_icb_rsp_rdata )     ,
  .o_icb_rsp_usr          (                   )     ,
                               
  .i_bus_icb_cmd_ready    (arbt_bus_icb_cmd_ready ) ,
  .i_bus_icb_cmd_valid    (arbt_bus_icb_cmd_valid ) ,
  .i_bus_icb_cmd_read     (arbt_bus_icb_cmd_read )  ,
  .i_bus_icb_cmd_addr     (arbt_bus_icb_cmd_addr )  ,
  .i_bus_icb_cmd_wdata    (arbt_bus_icb_cmd_wdata ) ,
  .i_bus_icb_cmd_wmask    (arbt_bus_icb_cmd_wmask)  ,
  .i_bus_icb_cmd_burst    (arbt_bus_icb_cmd_burst)  ,
  .i_bus_icb_cmd_beat     (arbt_bus_icb_cmd_beat )  ,
  .i_bus_icb_cmd_excl     (arbt_bus_icb_cmd_excl )  ,
  .i_bus_icb_cmd_lock     (arbt_bus_icb_cmd_lock )  ,
  .i_bus_icb_cmd_size     (arbt_bus_icb_cmd_size )  ,
  .i_bus_icb_cmd_usr      (arbt_bus_icb_cmd_usr  )  ,
                                
  .i_bus_icb_rsp_valid    (arbt_bus_icb_rsp_valid ) ,
  .i_bus_icb_rsp_ready    (arbt_bus_icb_rsp_ready ) ,
  .i_bus_icb_rsp_err      (arbt_bus_icb_rsp_err)    ,
  .i_bus_icb_rsp_excl_ok  (arbt_bus_icb_rsp_excl_ok),
  .i_bus_icb_rsp_rdata    (arbt_bus_icb_rsp_rdata ) ,
  .i_bus_icb_rsp_usr      (arbt_bus_icb_rsp_usr) ,
                             
  .clk                    (clk  ),
  .rst_n                  (rst_n)
  );


//rom part
  wire                         mrom_icb_cmd_valid;
  wire                         mrom_icb_cmd_ready;
  wire [`E203_ADDR_SIZE-1:0]   mrom_icb_cmd_addr;
  wire                         mrom_icb_cmd_read;

  wire                         mrom_icb_rsp_valid;
  wire                         mrom_icb_rsp_ready;
  wire                         mrom_icb_rsp_err  ;
  wire [`E203_XLEN-1:0]        mrom_icb_rsp_rdata;
//sram1 part
  wire [1-1:0]                    sram1_icb_cmd_valid;
  wire [1-1:0]                    sram1_icb_cmd_ready;
  wire [`E203_ADDR_SIZE-1:0]      sram1_icb_cmd_addr; 
  wire [1-1:0]                    sram1_icb_cmd_read; 
  wire [`E203_XLEN-1:0]           sram1_icb_cmd_wdata;
  wire [`E203_XLEN/8-1:0]         sram1_icb_cmd_wmask;


  wire                            sram1_icb_rsp_valid;
  wire                            sram1_icb_rsp_ready;
  wire [`E203_XLEN-1:0]           sram1_icb_rsp_rdata;
  wire                            sram1_icb_rsp_err  ;

  wire                            ram1_cs;
  wire                            ram1_we;
  wire [3:0]                      ram1_wem;
  wire [31:0]                     ram1_addr;
  wire [31:0]                     ram1_din;
  wire [31:0]                     ram1_dout;
  wire                            clk_ram1;                           

//sram2 part
  wire [1-1:0]                    sram2_icb_cmd_valid;
  wire [1-1:0]                    sram2_icb_cmd_ready;
  wire [`E203_ADDR_SIZE-1:0]      sram2_icb_cmd_addr; 
  wire [1-1:0]                    sram2_icb_cmd_read; 
  wire [`E203_XLEN-1:0]           sram2_icb_cmd_wdata;
  wire [`E203_XLEN/8-1:0]         sram2_icb_cmd_wmask;


  wire                            sram2_icb_rsp_valid;
  wire                            sram2_icb_rsp_ready;
  wire [`E203_XLEN-1:0]           sram2_icb_rsp_rdata;
  wire                            sram2_icb_rsp_err  ;

  wire                            ram2_cs;
  wire                            ram2_we;
  wire [3:0]                      ram2_wem;
  wire [31:0]                     ram2_addr;
  wire [31:0]                     ram2_din;
  wire [31:0]                     ram2_dout;
  wire                            clk_ram2;                           

  // There are several slaves for Mem bus, including:
  //  * rom        : 0x0000 1000 -- 0x0000 1FFF
  //  * sram1      : 0x2000 0000 -- 0x2000 FFFF
  //  * sram2      : 0x3000 0000 -- 0x3000 FFFF
  sirv_icb1to8_bus # (
  .ICB_FIFO_DP        (2),// We add a ping-pong buffer here to cut down the timing path
  .ICB_FIFO_CUT_READY (1),// We configure it to cut down the back-pressure ready signal
  .AW                   (32),
  .DW                   (`E203_XLEN),
  .SPLT_FIFO_OUTS_NUM   (1),// The Mem only allow 1 oustanding
  .SPLT_FIFO_CUT_READY  (1),// The Mem always cut ready
  //  * rom      : 0x0000 1000 -- 0x0000 1FFF
  .O0_BASE_ADDR       (`ROM_BASE_ADDR),       
  .O0_BASE_REGION_LSB (12),
  //  * sram1    : 0x2000_0000 -- 0x2000 FFFF
  .O1_BASE_ADDR       (`SRAM1_BASE_ADDR),       
  .O1_BASE_REGION_LSB (16),
     // sram2      : 0x3000 0000 -- 0x3000 FFFF
  .O2_BASE_ADDR       (`SRAM2_BASE_ADDR),       
  .O2_BASE_REGION_LSB (16),
  // not used 
  .O3_BASE_ADDR       (32'h0000_0000),       
  .O3_BASE_REGION_LSB (0),
      // Not used
  .O4_BASE_ADDR       (32'h8000_0000),       
  .O4_BASE_REGION_LSB (0),

      // Not used
  .O5_BASE_ADDR       (32'h4000_0000),       
  .O5_BASE_REGION_LSB (0),
  
      // Not used
  .O6_BASE_ADDR       (32'h0000_0000),       
  .O6_BASE_REGION_LSB (0),
  
      // Not used
  .O7_BASE_ADDR       (32'h0000_0000),       
  .O7_BASE_REGION_LSB (0)

  )u_sirv_mem_fab(

    .i_icb_cmd_valid  (arbt_icb_cmd_valid),
    .i_icb_cmd_ready  (arbt_icb_cmd_ready),
    .i_icb_cmd_addr   (arbt_icb_cmd_addr ),
    .i_icb_cmd_read   (arbt_icb_cmd_read ),
    .i_icb_cmd_wdata  (arbt_icb_cmd_wdata),
    .i_icb_cmd_wmask  (arbt_icb_cmd_wmask),
    .i_icb_cmd_lock   (1'b0 ),
    .i_icb_cmd_excl   (1'b0 ),
    .i_icb_cmd_size   (2'b0 ),
    .i_icb_cmd_burst  (2'b0),
    .i_icb_cmd_beat   (2'b0 ),
    
    .i_icb_rsp_valid  (arbt_icb_rsp_valid),
    .i_icb_rsp_ready  (arbt_icb_rsp_ready),
    .i_icb_rsp_err    (arbt_icb_rsp_err  ),
    .i_icb_rsp_excl_ok(),
    .i_icb_rsp_rdata  (arbt_icb_rsp_rdata),
    

//  * MROM      
    .o0_icb_enable     (1'b1),

    .o0_icb_cmd_valid  (mrom_icb_cmd_valid),
    .o0_icb_cmd_ready  (mrom_icb_cmd_ready),
    .o0_icb_cmd_addr   (mrom_icb_cmd_addr ),
    .o0_icb_cmd_read   (mrom_icb_cmd_read ),
    .o0_icb_cmd_wdata  (),
    .o0_icb_cmd_wmask  (),
    .o0_icb_cmd_lock   (),
    .o0_icb_cmd_excl   (),
    .o0_icb_cmd_size   (),
    .o0_icb_cmd_burst  (),
    .o0_icb_cmd_beat   (),

    .o0_icb_rsp_valid  (mrom_icb_rsp_valid),
    .o0_icb_rsp_ready  (mrom_icb_rsp_ready),
    .o0_icb_rsp_err    (mrom_icb_rsp_err),
    .o0_icb_rsp_excl_ok(1'b0  ),
    .o0_icb_rsp_rdata  (mrom_icb_rsp_rdata),

  //  * sram1      
    .o1_icb_enable     (1'b1),

    .o1_icb_cmd_valid  (sram1_icb_cmd_valid),
    .o1_icb_cmd_ready  (sram1_icb_cmd_ready),
    .o1_icb_cmd_addr   (sram1_icb_cmd_addr ),
    .o1_icb_cmd_read   (sram1_icb_cmd_read ),
    .o1_icb_cmd_wdata  (sram1_icb_cmd_wdata),
    .o1_icb_cmd_wmask  (sram1_icb_cmd_wmask),
    .o1_icb_cmd_lock   (),
    .o1_icb_cmd_excl   (),
    .o1_icb_cmd_size   (),
    .o1_icb_cmd_burst  (),
    .o1_icb_cmd_beat   (),
    
    .o1_icb_rsp_valid  (sram1_icb_rsp_valid),
    .o1_icb_rsp_ready  (sram1_icb_rsp_ready),
    .o1_icb_rsp_err    (sram1_icb_rsp_err),
    .o1_icb_rsp_excl_ok(1'b0  ),
    .o1_icb_rsp_rdata  (sram1_icb_rsp_rdata),

  //  * sram2    
    .o2_icb_enable     (1'b1),

    .o2_icb_cmd_valid  (sram2_icb_cmd_valid),
    .o2_icb_cmd_ready  (sram2_icb_cmd_ready),
    .o2_icb_cmd_addr   (sram2_icb_cmd_addr ),
    .o2_icb_cmd_read   (sram2_icb_cmd_read ),
    .o2_icb_cmd_wdata  (sram2_icb_cmd_wdata),
    .o2_icb_cmd_wmask  (sram2_icb_cmd_wmask),
    .o2_icb_cmd_lock   (),
    .o2_icb_cmd_excl   (),
    .o2_icb_cmd_size   (),
    .o2_icb_cmd_burst  (),
    .o2_icb_cmd_beat   (),
    
    .o2_icb_rsp_valid  (sram2_icb_rsp_valid),
    .o2_icb_rsp_ready  (sram2_icb_rsp_ready),
    .o2_icb_rsp_err    (sram2_icb_rsp_err),
    .o2_icb_rsp_excl_ok(1'b0  ),
    .o2_icb_rsp_rdata  (sram2_icb_rsp_rdata),


        //  * Not used
    .o3_icb_enable     (1'b0),

    .o3_icb_cmd_valid  (),
    .o3_icb_cmd_ready  (1'b0),
    .o3_icb_cmd_addr   (),
    .o3_icb_cmd_read   (),
    .o3_icb_cmd_wdata  (),
    .o3_icb_cmd_wmask  (),
    .o3_icb_cmd_lock   (),
    .o3_icb_cmd_excl   (),
    .o3_icb_cmd_size   (),
    .o3_icb_cmd_burst  (),
    .o3_icb_cmd_beat   (),
    
    .o3_icb_rsp_valid  (1'b0),
    .o3_icb_rsp_ready  (),
    .o3_icb_rsp_err    (1'b0  ),
    .o3_icb_rsp_excl_ok(1'b0  ),
    .o3_icb_rsp_rdata  (`E203_XLEN'b0),
      
  //  * Not used
    .o4_icb_enable     (1'b0),

    .o4_icb_cmd_valid  (),
    .o4_icb_cmd_ready  (1'b0),
    .o4_icb_cmd_addr   (),
    .o4_icb_cmd_read   (),
    .o4_icb_cmd_wdata  (),
    .o4_icb_cmd_wmask  (),
    .o4_icb_cmd_lock   (),
    .o4_icb_cmd_excl   (),
    .o4_icb_cmd_size   (),
    .o4_icb_cmd_burst  (),
    .o4_icb_cmd_beat   (),
    
    .o4_icb_rsp_valid  (1'b0),
    .o4_icb_rsp_ready  (),
    .o4_icb_rsp_err    (1'b0  ),
    .o4_icb_rsp_excl_ok(1'b0  ),
    .o4_icb_rsp_rdata  (`E203_XLEN'b0),


        //  * Not used
    .o5_icb_enable     (1'b0),

    .o5_icb_cmd_valid  (),
    .o5_icb_cmd_ready  (1'b0),
    .o5_icb_cmd_addr   (),
    .o5_icb_cmd_read   (),
    .o5_icb_cmd_wdata  (),
    .o5_icb_cmd_wmask  (),
    .o5_icb_cmd_lock   (),
    .o5_icb_cmd_excl   (),
    .o5_icb_cmd_size   (),
    .o5_icb_cmd_burst  (),
    .o5_icb_cmd_beat   (),
    
    .o5_icb_rsp_valid  (1'b0),
    .o5_icb_rsp_ready  (),
    .o5_icb_rsp_err    (1'b0  ),
    .o5_icb_rsp_excl_ok(1'b0  ),
    .o5_icb_rsp_rdata  (`E203_XLEN'b0),

        //  * Not used
    .o6_icb_enable     (1'b0),

    .o6_icb_cmd_valid  (),
    .o6_icb_cmd_ready  (1'b0),
    .o6_icb_cmd_addr   (),
    .o6_icb_cmd_read   (),
    .o6_icb_cmd_wdata  (),
    .o6_icb_cmd_wmask  (),
    .o6_icb_cmd_lock   (),
    .o6_icb_cmd_excl   (),
    .o6_icb_cmd_size   (),
    .o6_icb_cmd_burst  (),
    .o6_icb_cmd_beat   (),
    
    .o6_icb_rsp_valid  (1'b0),
    .o6_icb_rsp_ready  (),
    .o6_icb_rsp_err    (1'b0  ),
    .o6_icb_rsp_excl_ok(1'b0  ),
    .o6_icb_rsp_rdata  (`E203_XLEN'b0),

        //  * Not used
    .o7_icb_enable     (1'b0),

    .o7_icb_cmd_valid  (),
    .o7_icb_cmd_ready  (1'b0),
    .o7_icb_cmd_addr   (),
    .o7_icb_cmd_read   (),
    .o7_icb_cmd_wdata  (),
    .o7_icb_cmd_wmask  (),
    .o7_icb_cmd_lock   (),
    .o7_icb_cmd_excl   (),
    .o7_icb_cmd_size   (),
    .o7_icb_cmd_burst  (),
    .o7_icb_cmd_beat   (),
    
    .o7_icb_rsp_valid  (1'b0),
    .o7_icb_rsp_ready  (),
    .o7_icb_rsp_err    (1'b0  ),
    .o7_icb_rsp_excl_ok(1'b0  ),
    .o7_icb_rsp_rdata  (`E203_XLEN'b0),

    .clk           (clk  ),
    .rst_n         (bus_rst_n) 
  );



  sirv_mrom_top #(
    .AW(12),
    .DW(32),
    .DP(1024)
  )u_sirv_mrom_top(

    .rom_icb_cmd_valid  (mrom_icb_cmd_valid),
    .rom_icb_cmd_ready  (mrom_icb_cmd_ready),
    .rom_icb_cmd_addr   (mrom_icb_cmd_addr [11:0]),
    .rom_icb_cmd_read   (mrom_icb_cmd_read ),

    .rom_icb_rsp_valid  (mrom_icb_rsp_valid),
    .rom_icb_rsp_ready  (mrom_icb_rsp_ready),
    .rom_icb_rsp_err    (mrom_icb_rsp_err  ),
    .rom_icb_rsp_rdata  (mrom_icb_rsp_rdata),

    .clk           (clk  ),
    .rst_n         (rst_n)
  );


//icb to sram
  sirv_sram_icb_ctrl #(
  .DW(32),
  .MW(4),
  .AW(32),
  .AW_LSB(0),
  .USR_W(1)
  ) i_sram_icn_ctrl_1(
    .sram_ctrl_active(),
    .tcm_cgstop(1'b0),
    
    .i_icb_cmd_valid(sram1_icb_cmd_valid),
    .i_icb_cmd_ready(sram1_icb_cmd_ready),
    .i_icb_cmd_read (sram1_icb_cmd_read),
    .i_icb_cmd_addr (sram1_icb_cmd_addr),
    .i_icb_cmd_wdata(sram1_icb_cmd_wdata),
    .i_icb_cmd_wmask(sram1_icb_cmd_wmask),
    .i_icb_cmd_usr  (1'b0),
    
    .i_icb_rsp_valid(sram1_icb_rsp_valid),
    .i_icb_rsp_ready(sram1_icb_rsp_ready),
    .i_icb_rsp_rdata(sram1_icb_rsp_rdata),
    .i_icb_rsp_usr  (sram1_icb_rsp_err),
    
    .ram_cs  (ram1_cs),
    .ram_we  (ram1_we),
    .ram_addr(ram1_addr),
    .ram_wem (ram1_wem),
    .ram_din (ram1_din),
    .ram_dout(ram1_dout),
    .clk_ram (clk_ram1),
    
    .test_mode(1'b0),
    .clk(clk),
    .rst_n(bus_rst_n)
  );

//icb to sram
  sirv_sram_icb_ctrl #(
  .DW(32),
  .MW(4),
  .AW(32),
  .AW_LSB(0),
  .USR_W(1)
  ) i_sram_icn_ctrl_2(
    .sram_ctrl_active(),
    .tcm_cgstop(1'b0),
    
    .i_icb_cmd_valid(sram2_icb_cmd_valid),
    .i_icb_cmd_ready(sram2_icb_cmd_ready),
    .i_icb_cmd_read (sram2_icb_cmd_read),
    .i_icb_cmd_addr (sram2_icb_cmd_addr),
    .i_icb_cmd_wdata(sram2_icb_cmd_wdata),
    .i_icb_cmd_wmask(sram2_icb_cmd_wmask),
    .i_icb_cmd_usr  (1'b0),
    
    .i_icb_rsp_valid(sram2_icb_rsp_valid),
    .i_icb_rsp_ready(sram2_icb_rsp_ready),
    .i_icb_rsp_rdata(sram2_icb_rsp_rdata),
    .i_icb_rsp_usr  (sram2_icb_rsp_err),
    
    .ram_cs  (ram2_cs),
    .ram_we  (ram2_we),
    .ram_addr(ram2_addr),
    .ram_wem (ram2_wem),
    .ram_din (ram2_din),
    .ram_dout(ram2_dout),
    .clk_ram (clk_ram2),
    
    .test_mode(1'b0),
    .clk(clk),
    .rst_n(bus_rst_n)
  );


  sirv_sim1_ram #(
      .FORCE_X2ZERO (1'b0),
      .DP (1024),
      .AW (32),
      .MW (4),
      .DW (32) 
  )u_sirv_sim_ram1 (
      .clk   (clk_ram1),
      .din   (ram1_din),
      .addr  (ram1_addr),
      .cs    (ram1_cs),
      .we    (ram1_we),
      .wem   (ram1_wem),
      .dout  (ram1_dout)
  );

  sirv_sim_ram #(
      .FORCE_X2ZERO (1'b0),
      .DP (4096),
      .AW (32),
      .MW (4),
      .DW (32) 
  )u_sirv_sim_ram2 (
      .clk   (clk_ram2),
      .din   (ram2_din),
      .addr  (ram2_addr),
      .cs    (ram2_cs),
      .we    (ram2_we),
      .wem   (ram2_wem),
      .dout  (ram2_dout)
  );

endmodule
