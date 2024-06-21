`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// 实验平台: 野火FPGA系列开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  hdmi_colorbar
(
    input   wire            sys_clk     ,   //输入工作时钟,频率50MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效

    output  wire            hdmi_out_clk,
    output  wire            hdmi_out_rst_n      ,
    output  wire            hdmi_out_hsync      ,   //输出行同步信号
    output  wire            hdmi_out_vsync      ,   //输出场同步信号
    output  wire    [23:0]  hdmi_out_rgb        ,   //输出像素信息
    output  wire            hdmi_out_de,
        //SD卡
    input   wire            sd_miso     ,  //主输入从输出信号
    output  wire            sd_clk      ,  //SD卡时钟信号
    output  wire            sd_cs_n     ,  //片选信号
    output  wire            sd_mosi ,       //主输出从输入信号
    output  wire    led
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire define
wire            locked  ;   //PLL locked信号
wire            rst_n   ;   //VGA模块复位信号
wire    [11:0]  pix_x   ;   //VGA有效显示区域X轴坐标
wire    [11:0]  pix_y   ;   //VGA有效显示区域Y轴坐标
wire    [15:0]  pix_data;   //VGA像素点色彩信息
wire    [15:0]  rgb     ;   //输出像素信息
wire    sd_init_end;

//rst_n:VGA模块复位信号
assign  rst_n   = (sys_rst_n & locked);
assign  hdmi_out_rst_n=rst_n;
//assign  rst_n   = sys_rst_n;
assign  hdmi_out_rgb   ={{rgb[15:11],3'b0},{rgb[10:5],2'b0},{rgb[4:0],3'b0}};
assign led = ~sd_init_end;
//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

pll_clk U_pll_clk(
    .refclk (sys_clk        ),
    .reset  (~sys_rst_n     ),
    .extlock(locked         ),
    .clk0_out(hdmi_out_clk   ),
    .clk1_out(clk_50m),
    .clk2_out(clk_50m_shift)
);

//------------- vga_ctrl_inst -------------
vga_ctrl  vga_ctrl_inst
(
    .vga_clk    (hdmi_out_clk   ),  //输入工作时钟,频率25MHz,1bit
    .sys_rst_n  (rst_n          ),  //输入复位信号,低电平有效,1bit
    .pix_data   (pix_data       ),  //输入像素点色彩信息,16bit

    .pix_x      (pix_x          ),  //输出VGA有效显示区域像素点X轴坐标,10bit
    .pix_y      (pix_y          ),  //输出VGA有效显示区域像素点Y轴坐标,10bit
    .hsync      (hdmi_out_hsync ),  //输出行同步信号,1bit
    .vsync      (hdmi_out_vsync ),  //输出场同步信号,1bit
    .rgb_valid  (hdmi_out_de    ),
    .rgb        (rgb            )   //输出像素点色彩信息,16bit
);

//------------- vga_pic_inst -------------
vga_pic vga_pic_inst
(
    .vga_clk    (hdmi_out_clk   ),  //输入工作时钟,频率25MHz,1bit
    .sys_rst_n  (rst_n          ),  //输入复位信号,低电平有效,1bit
    .pix_x      (pix_x          ),  //输入VGA有效显示区域像素点X轴坐标,10bit
    .pix_y      (pix_y          ),  //输入VGA有效显示区域像素点Y轴坐标,10bit

    .pix_data   (pix_data       )   //输出像素点色彩信息,16bit

);

//------------- sd_ctrl_inst -------------
sd_ctrl sd_ctrl_inst
(
    .sys_clk         (clk_50m       ),  //输入工作时钟,频率50MHz
    .sys_clk_shift   (clk_50m_shift ),  //输入工作时钟,频率50MHz
                                        //相位偏移180度
    .sys_rst_n       (rst_n         ),  //输入复位信号,低电平有效

    .sd_miso         (sd_miso       ),  //主输入从输出信号
    .sd_clk          (sd_clk        ),  //SD卡时钟信号
    .sd_cs_n         (sd_cs_n       ),  //片选信号
    .sd_mosi         (sd_mosi       ),  //主输出从输入信号

    .wr_en           (1'b0          ),  //数据写使能信号
    .wr_addr         (32'b0         ),  //写数据扇区地址
    .wr_data         (16'b0         ),  //写数据
    .wr_busy         (              ),  //写操作忙信号
    .wr_req          (              ),  //写数据请求信号

    .rd_en           (      ),  //数据读使能信号
    .rd_addr         (    ),  //读数据扇区地址
    .rd_busy         (    ),  //读操作忙信号
    .rd_data_en      ( ),  //读数据标志信号
    .rd_data         (    ),  //读数据

    .init_end        (sd_init_end   )   //SD卡初始化完成信号
);

endmodule
