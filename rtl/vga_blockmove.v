//****************************************Copyright (c)***********************************//
// Descriptions:        vga方块移动
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module vga_blockmove(
    input           sys_clk,        //系统时钟
    input           sys_rst_n,      //复位信号
	 input   [3:0]   key,
    
    //数码管
    output  wire            stcp        , //数据存储器时钟
    output  wire            shcp        , //移位寄存器时钟
    output  wire            ds          , //串行数据输入
    output  wire            oe          ,   //使能信号       
    //VGA接口                          
    output          vga_hs,         //行同步信号
    output          vga_vs,         //场同步信号
    output  [15:0]  vga_rgb         //红绿蓝三原色输出
    ); 

parameter   CNT_MAX     =   20'd999_999     ;   //计数器计数最大值



//wire define
wire         vga_clk_w;             //PLL分频得到25Mhz时钟
wire         locked_w;              //PLL输出稳定信号
wire         rst_n_w;               //内部复位信号
wire [15:0]  pixel_data_w;          //像素点数据
wire [ 9:0]  pixel_xpos_w;          //像素点横坐标
wire [ 9:0]  pixel_ypos_w;          //像素点纵坐标
wire [2:0]   direction; 
wire [2:0]   dsign; 
wire         pengzhuang;
wire         pengzhuang2; 
wire [2:0]   key_flag; 
wire [9:0]  grade;  

//*****************************************************
//**                    main code
//***************************************************** 
//待PLL输出稳定之后，停止复位
assign rst_n_w = sys_rst_n && locked_w;
   
vga_pll	u_vga_pll(                  //时钟分频模块
	.inclk0         (sys_clk),    
	.areset         (~sys_rst_n),
    
	.c0             (vga_clk_w),    //VGA时钟 25M
	.locked         (locked_w)
	); 

vga_driver u_vga_driver(
    .vga_clk        (vga_clk_w),    
    .sys_rst_n      (rst_n_w),    

    .vga_hs         (vga_hs),       
    .vga_vs         (vga_vs),       
    .vga_rgb        (vga_rgb),      
    
    .pixel_data     (pixel_data_w), 
    .pixel_xpos     (pixel_xpos_w), 
    .pixel_ypos     (pixel_ypos_w)
    ); 
    
vga_display u_vga_display(
    .vga_clk        (vga_clk_w),
    .sys_rst_n      (rst_n_w),
    .key_up         (key_flag[0]) ,
    .key_down       (key_flag[1]) ,
    .key_ok         (key_flag[2]) ,
    .pixel_xpos     (pixel_xpos_w),
    .pixel_ypos     (pixel_ypos_w),
    .pixel_data     (pixel_data_w),
    .grade          (grade),
	 .direction      (direction),
	 .dsign          (dsign),
	 .pengzhuang     (pengzhuang),
	 .pengzhuang2     (pengzhuang2)
   
 

   );  
 
    
key_led key_led(
    .sys_clk   (sys_clk),    //50Mhz系统时钟
    .sys_rst_n (sys_rst_n),    //系统复位，低有效
    .key       (key),	       //按键输入信号
	 .direction (direction),
	 .dsign     (dsign),
	 .pengzhuang (pengzhuang),
	 .pengzhuang2 (pengzhuang2)
    );   
	
    
    
    
 key_filter//////高电平
#(
    .CNT_MAX    (CNT_MAX    )   //计数器计数最大值
)
key_filter_inst
(
    .sys_clk    ( vga_clk_w    ),  //系统时钟，频率50MHz
    .sys_rst_n  (sys_rst_n  ),  //复位信号,低电平有效
    .key_in     (key[0]      ),  //按键输入信号

    .key_flag   (key_flag[0]      )   //消抖后信号
);
    
 key_filter
#(
    .CNT_MAX    (CNT_MAX    )   //计数器计数最大值
)
key_filter_inst1
(
    .sys_clk    (vga_clk_w     ),  //系统时钟，频率50MHz
    .sys_rst_n  (sys_rst_n  ),  //复位信号,低电平有效
    .key_in     (key[1]        ),  //按键输入信号
                 
    .key_flag   (key_flag[1]   )   //消抖后信号
);   
       
    
  key_filter
#(
    .CNT_MAX    (CNT_MAX    )   //计数器计数最大值
)
key_filter_inst2
(
    .sys_clk    ( vga_clk_w    ),  //系统时钟，频率50MHz
    .sys_rst_n  (sys_rst_n  ),  //复位信号,低电平有效
    .key_in     (key[2]        ),  //按键输入信号
                 
    .key_flag   (key_flag[2]   )   //消抖后信号
);  
    
 
    
seg_595_dynamic   seg_595_dynamic_inst
(
   .sys_clk   (sys_clk   ) , //系统时钟，频率50MHz
   .sys_rst_n (sys_rst_n ) , //复位信号，低有效
   .data      ( grade      ) , //数码管要显示的值[19:0] 
   .point     ( 0    ) , //小数点显示,高电平有效[5:0]           
   .seg_en    ( 1'b1    ) , //数码管使能信号，高电平有效
   .sign      ( 0      ) , //符号位，高电平显示负号           
                                                                
   .stcp      (stcp      ) , //数据存储器时钟
   .shcp      (shcp      ) , //移位寄存器时钟
   .ds        (ds        ) , //串行数据输入
   .oe        (oe        )   //使能信号

);    
    
    
    
    
    
endmodule 