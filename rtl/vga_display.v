//****************************************Copyright (c)***********************************//
// Descriptions:        vga方块移动显示模块
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module vga_display(
    input             vga_clk,                  //VGA驱动时钟
    input             sys_rst_n,                //复位信号
    input             key_up   ,               //游戏选择
    input             key_down ,               //游戏选择
    input             key_ok   ,               //游戏选择 
    input       [ 9:0] pixel_xpos,               //像素点横坐标        
    input       [ 9:0] pixel_ypos,               //像素点纵坐标    
    output  reg [15:0] pixel_data,                //像素点数据
    output  reg [9:0] grade ,   
	 input [2:0]  direction,
	 output reg [2:0] dsign,
	 output reg pengzhuang,
	 output reg pengzhuang2
    );    

//parameter define    
parameter  H_DISP  = 10'd640;                   //分辨率——行
parameter  V_DISP  = 10'd480;                   //分辨率——列

localparam BLUE    = 16'b00000_000000_11111;    //边框颜色 蓝色
localparam WHITE   = 16'b11111_111111_11111;    //背景颜色 白色
localparam BLACK   = 16'b00000_000000_00000;    //方块颜色 黑色
localparam RED     = 16'b11111_000000_00000;    //红色
localparam GREEN   = 16'h1f00;    // 绿色
localparam YELLOW  = 16'h1f1f;    //黄色
localparam background = 16'b11111_111111_11111;     //白色

 parameter   CHAR_W_kaishi     =   'd160,   //字符宽度 
             CHAR_H_kaishi     =   'd64  ;   //字符高度    
 parameter   CHAR_W_SIMPLE     =   'd96,   //字符宽度 
             CHAR_H_SIMPLE     =   'd32  ;   //字符高度               
 parameter   CHAR_W_NORMAL     =   'd96,   //字符宽度 
             CHAR_H_NORMAL     =   'd32  ;   //字符高度               
 parameter   CHAR_W_DIFFICULT  =   'd144,   //字符宽度 
             CHAR_H_DIFFICULT  =   'd32  ;   //字符高度                 
 parameter   CHAR_W_AGAIN      =   'd96,   //字符宽度 
             CHAR_H_AGAIN      =   'd32  ;   //字符高度               
 parameter   CHAR_W_MAIN       =   'd144,   //字符宽度 
             CHAR_H_MAIN       =   'd32  ;   //字符高度   
  
 parameter   CHAR_W   =   'd32,    //成绩字符宽度 
             CHAR_H   =   'd64  ;   //成绩字符高度             
             
               
             
   
parameter   H_apple   =   10'd20    ,   // 苹果图片长度
            W_apple   =   10'd20      ,   //苹果图片宽度
            PIC_apple =    14'd400     ; //苹果图片像素个数
parameter   H_snack   =   10'd55    ,   // 苹果图片长度
            W_snack   =   10'd66      ,   //苹果图片宽度
            PIC_snack =     'd3630     ; //苹果图片像素个数       

parameter  idle =  6'b00_0000   ,/////开始界面
           s1   =  6'b00_0001   ,/////选择难度界面
           s2   =  6'b00_0010   ,/////游戏界面
           s3   =  6'b00_1000   ;/////结束界面
  
  parameter   CHAR_B_H_kaishi=   H_DISP/2-CHAR_W_kaishi/2 ,   //字符开始X轴坐标 
              CHAR_B_V_kaishi=   V_DISP/2-CHAR_H_kaishi/2 ;   //字符开始Y轴坐标  
  parameter   CHAR_B_H_SIMPLE    =   H_DISP/2-CHAR_W_kaishi/2+40 ,   //字符开始X轴坐标 
              CHAR_B_V_SIMPLE    =   V_DISP/2-CHAR_H_kaishi/2-40 ;   //字符开始Y轴坐标 
  parameter   CHAR_B_H_NORMAL    =   H_DISP/2-CHAR_W_kaishi/2+40 ,   //字符开始X轴坐标 
              CHAR_B_V_NORMAL    =   V_DISP/2-CHAR_H_kaishi/2 ;   //字符开始Y轴坐标 
  parameter   CHAR_B_H_DIFFICULT =   H_DISP/2-CHAR_W_kaishi/2+40 ,   //字符开始X轴坐标 
              CHAR_B_V_DIFFICULT =   V_DISP/2-CHAR_H_kaishi/2+40 ;   //字符开始Y轴坐标 
  parameter   CHAR_B_H_AGAIN     =   H_DISP/2-CHAR_W_kaishi/2+40 ,   //字符开始X轴坐标 
              CHAR_B_V_AGAIN     =   V_DISP/2-CHAR_H_kaishi/2 ;   //字符开始Y轴坐标 
  parameter   CHAR_B_H_MAIN      =   H_DISP/2-CHAR_W_kaishi/2+40 ,   //字符开始X轴坐标 
              CHAR_B_V_MAIN      =   V_DISP/2-CHAR_H_kaishi/2+40 ;   //字符开始Y轴坐标               
              
              
              
              
  parameter   PIC_B_H_snack=   H_DISP    /2-CHAR_W_kaishi/2 +30,   //字符开始X轴坐标 
              PIC_B_V_snack=   V_DISP   /2-CHAR_H_kaishi/2 + 100;   //字符开始Y轴坐标     
 parameter    CHAR_B_H     =  H_DISP/2-CHAR_W_kaishi/2+40  ,     //成绩开始X轴坐标 
              CHAR_B_V     =  V_DISP/2-CHAR_H_kaishi/2 -80;                //成绩开始Y轴坐标 
//wire define
wire  [15:0] snack_data  ;
wire  [15:0] apple_data  ;
wire  [15:0] apple_data_big  ;

wire    [9:0]   char_x_kaishi   ;   //字符显示X轴坐标 
wire    [9:0]   char_y_kaishi   ;   //字符显示Y轴坐标  
wire    [9:0]   char_x_SIMPLE     ;   //字符显示X轴坐标 
wire    [9:0]   char_y_SIMPLE     ;   //字符显示Y轴坐标 
wire    [9:0]   char_x_NORMAL     ;   //字符显示X轴坐标 
wire    [9:0]   char_y_NORMAL     ;   //字符显示Y轴坐标 
wire    [9:0]   char_x_DIFFICULT  ;   //字符显示X轴坐标 
wire    [9:0]   char_y_DIFFICULT  ;   //字符显示Y轴坐标 
wire    [9:0]   char_x_AGAIN      ;   //字符显示X轴坐标 
wire    [9:0]   char_y_AGAIN      ;   //字符显示Y轴坐标 
wire    [9:0]   char_x_MAIN       ;   //字符显示X轴坐标 
wire    [9:0]   char_y_MAIN       ;   //字符显示Y轴坐标 

wire             rd_applebig_en    ;///////苹果图片读取允许信号 
wire             rd_apple_en    ;///////苹果图片读取允许信号 
wire             rd_snack_en    ;///////蛇图片读取允许信号 
wire    [3:0]   grade_0  ;
wire    [3:0]   grade_1  ;
wire    [3:0]   grade_2  ;
wire    [3:0]   grade_3  ;
wire    [9:0]   char_x  ;   //字符显示X轴坐标 
wire    [9:0]   char_y  ;   //字符显示Y轴坐标 

//reg define
(* preserve *)reg [ 9:0] head_y;                             //方块左上角横坐标 1到32
reg [ 9:0] head_x;               //方块左上角纵坐标 1到24
reg [5:0 ] state  ;
reg [15:0] body_x [24:0]; 
reg [15:0] body_y [24:0]; 
reg [25:0] cnt_1s;
reg [9:0] apple_x;
reg [9:0] apple_y;
reg [9:0] snake_l;
reg [9:0] index;
reg [2:0] cnt_nan;/////难度选 择         
reg [3:0] cnt_apple;/////难度选择 
reg [9:0] grade_max ; 
reg [10:0] add_apple_big;////苹果的地址  
reg [2:0] cnt_xuan;/////难度选择 
reg [10:0] add_apple;////苹果的地址  
reg [25:0] max_cnt_1s; 
reg [11:0] add_snack;////苹果的地址  
reg     [199:0] char_kaishi      [63:0]  ;   //字符数据      
reg     [95:0]  char_SIMPLE      [31:0]  ;   //字符数据             
reg     [95:0]  char_NORMAL      [31:0]  ;   //字符数据             
reg     [143:0] char_DIFFICULT   [31:0]  ;   //字符数据  
reg     [95:0]  char_AGAIN       [31:0]  ;   //字符数据             
reg     [143:0] char_MAIN        [31:0]  ;   //字符数据 
 
reg     [256:0] char_0         [7:0]  ;   //字符数据 
reg     [256:0] char_1         [7:0]  ;   //字符数据 
reg     [256:0] char_2         [7:0]  ;   //字符数据
reg     [256:0] char_3         [7:0]  ;   //字符数据
reg     [256:0] char_4         [7:0]  ;   //字符数据
reg     [256:0] char_5         [7:0]  ;   //字符数据 
reg     [256:0] char_6         [7:0]  ;   //字符数据 
reg     [256:0] char_7         [7:0]  ;   //字符数据
reg     [256:0] char_8         [7:0]  ;   //字符数据
reg     [256:0] char_9         [7:0]  ;   //字符数据                                                             
                                                             
reg  [15:0] idle_data ;////各个状态的数据 开始界面           
reg  [15:0] s1_data   ;////各个状态的数据 选择难度界面       
reg  [15:0] s2_data   ;////各个状态的数据 游戏界面           
reg  [15:0] s3_data   ;////各个状态的数据 结束界面
 

 
parameter up=2'd1,down=2'd0,left=2'd2,right=2'd3; 
 
////状态转换，，，，
 always@(posedge vga_clk or  negedge  sys_rst_n)  
 if(!sys_rst_n )                                
 state <= idle   ;                                
 else case (state)
 idle : if ( key_ok  )   state <= s1   ;  else  state <= state ;
 s1   : if ( key_ok )  state <= s2   ;else state <= state     ; 
 s2   : if (((pengzhuang2)||(pengzhuang))  ==1'b1 )  state <= s3    ;else state <= state    ;
 s3   : if  (( key_ok   )&&(cnt_xuan== 2'd0))  state <= s2    ;else if   (( key_ok   )&&(cnt_xuan== 2'd1))  state <= s1    ;  else state <= state    ;  
 default   :state <= state ;
 endcase 
  

////输出数据，，，，
 always@(posedge vga_clk or  negedge  sys_rst_n)  
 if(!sys_rst_n )   
pixel_data<= BLACK ;
else case (state)
idle :pixel_data  <= idle_data  ;
s1   :pixel_data  <= s1_data    ;
s2   :pixel_data  <= s2_data    ;
s3   :pixel_data  <= s3_data    ;

 default   :  pixel_data<=pixel_data   ;
 endcase 

/////////////开始界面
//给不同的区域绘制不同的颜色
always @(posedge vga_clk or negedge sys_rst_n)           
    if (!sys_rst_n) 
        idle_data <= BLACK;
    else  if ((pixel_xpos >=PIC_B_H_snack  ) && (pixel_xpos <PIC_B_H_snack+ H_snack  )&& 
             (pixel_ypos >= PIC_B_V_snack ) && (pixel_ypos < PIC_B_V_snack +W_snack))  
            idle_data <= snack_data;                           
    else  if ((pixel_xpos >= CHAR_B_H_kaishi ) && (pixel_xpos < CHAR_B_H_kaishi+CHAR_W_kaishi )
          && (pixel_ypos  >= CHAR_B_V_kaishi  ) && (pixel_ypos < CHAR_B_V_kaishi+CHAR_H_kaishi )
             && (char_kaishi[char_y_kaishi ][ 'd159 -  char_x_kaishi] == 1'b1) )   
            idle_data <= RED;                          
        else
            idle_data <= WHITE;                //绘制背景为白色
 
assign   char_x_kaishi =   (pixel_xpos -  CHAR_B_H_kaishi )  ; ////开始的位置          
assign   char_y_kaishi =   (pixel_ypos -  CHAR_B_V_kaishi )  ; ////开始的位置///1023 
 
  
 
/////////////困难选择界面
 
always @(posedge vga_clk or negedge sys_rst_n)           
    if (!sys_rst_n)  
     cnt_nan <= 3'd0;
     else if ((cnt_nan== 3'd3)||((state!=s1)&&(state!=s2)))
     cnt_nan <= 3'd0;     
     else if ((state==s1)&&(key_down))
     cnt_nan <=  cnt_nan + 1'b1 ;     
     else if ((state==s1)&&(key_up))
     cnt_nan <=  cnt_nan - 1'b1 ;   
     else 
     cnt_nan <= cnt_nan ;  
  
always @(posedge vga_clk or negedge sys_rst_n)           
    if (!sys_rst_n) 
max_cnt_1s<= 25'd20000000;
    else if (cnt_nan== 3'd0)
    max_cnt_1s<= 25'd20000000;    
    else if (cnt_nan== 3'd1)
    max_cnt_1s<= 25'd10000000;      
    else if (cnt_nan== 3'd2)
    max_cnt_1s<= 25'd2000000;      
    else 
    max_cnt_1s<=  max_cnt_1s  ;
     
    
//给不同的区域绘制不同的颜色
always @(posedge vga_clk or negedge sys_rst_n)           
    if (!sys_rst_n) 
        s1_data <= BLACK; 
        
    else  if ((pixel_xpos >= CHAR_B_H_SIMPLE -20 ) && (pixel_xpos < CHAR_B_H_SIMPLE -10  )
          &&  (pixel_ypos  >= CHAR_B_V_SIMPLE  ) && (pixel_ypos < CHAR_B_V_SIMPLE+CHAR_H_SIMPLE )
             &&(cnt_nan==1'b0 )   )          
        s1_data <= RED;         
     else  if ((pixel_xpos >= CHAR_B_H_NORMAL-20  ) && (pixel_xpos < CHAR_B_H_NORMAL -10 )
          && (pixel_ypos  >= CHAR_B_V_NORMAL  ) && (pixel_ypos < CHAR_B_V_NORMAL+CHAR_H_NORMAL )
             &&(cnt_nan==3'd1 )   )          
        s1_data <= RED;    
     else  if ((pixel_xpos >= CHAR_B_H_DIFFICULT-20  ) && (pixel_xpos < CHAR_B_H_DIFFICULT -10  )
          && (pixel_ypos  >= CHAR_B_V_DIFFICULT  ) && (pixel_ypos < CHAR_B_V_DIFFICULT+CHAR_H_DIFFICULT )
             &&(cnt_nan==3'd2 )   )          
        s1_data <= RED;    
       
    else  if ((pixel_xpos >= CHAR_B_H_SIMPLE ) && (pixel_xpos < CHAR_B_H_SIMPLE+CHAR_W_SIMPLE )
          && (pixel_ypos  >= CHAR_B_V_SIMPLE  ) && (pixel_ypos < CHAR_B_V_SIMPLE+CHAR_H_SIMPLE )
             && (char_SIMPLE[char_y_SIMPLE ][ CHAR_W_SIMPLE -1-char_x_SIMPLE] == 1'b1) )           
        s1_data <= GREEN;         
    else  if ((pixel_xpos >= CHAR_B_H_NORMAL ) && (pixel_xpos < CHAR_B_H_NORMAL+CHAR_W_NORMAL )
          && (pixel_ypos  >= CHAR_B_V_NORMAL  ) && (pixel_ypos < CHAR_B_V_NORMAL+CHAR_H_NORMAL )
             && (char_NORMAL[char_y_NORMAL ][  CHAR_W_NORMAL - 1- char_x_NORMAL] == 1'b1) )   
        s1_data <= YELLOW;              
    else  if ((pixel_xpos >= CHAR_B_H_DIFFICULT ) && (pixel_xpos < CHAR_B_H_DIFFICULT+CHAR_W_DIFFICULT )
          && (pixel_ypos  >= CHAR_B_V_DIFFICULT  ) && (pixel_ypos < CHAR_B_V_DIFFICULT+CHAR_H_DIFFICULT )
             && (char_DIFFICULT[char_y_DIFFICULT  ][  CHAR_W_DIFFICULT -1 - char_x_DIFFICULT] == 1'b1) )     
        s1_data <= RED;              
  else 
        s1_data <= WHITE ;   
   
assign   char_x_SIMPLE     =  ((pixel_xpos >= CHAR_B_H_SIMPLE ) && (pixel_xpos < CHAR_B_H_SIMPLE+CHAR_W_SIMPLE )
                            && (pixel_ypos  >= CHAR_B_V_SIMPLE  ) && (pixel_ypos < CHAR_B_V_SIMPLE+CHAR_H_SIMPLE ))?
                                 (pixel_xpos -  CHAR_B_H_SIMPLE ):10'h3ff  ; ////开始的位置          
assign   char_y_SIMPLE     =  ((pixel_xpos >= CHAR_B_H_SIMPLE ) && (pixel_xpos < CHAR_B_H_SIMPLE+CHAR_W_SIMPLE )
                            && (pixel_ypos  >= CHAR_B_V_SIMPLE  ) && (pixel_ypos < CHAR_B_V_SIMPLE+CHAR_H_SIMPLE ))?
                                 (pixel_ypos -  CHAR_B_V_SIMPLE ):10'h3ff    ; ////开始的位置///1023 
assign   char_x_NORMAL     =  ((pixel_xpos >= CHAR_B_H_NORMAL ) && (pixel_xpos < CHAR_B_H_NORMAL+CHAR_W_NORMAL )
                           && (pixel_ypos  >= CHAR_B_V_NORMAL  ) && (pixel_ypos < CHAR_B_V_NORMAL+CHAR_H_NORMAL ))?
                              (pixel_xpos -  CHAR_B_H_NORMAL    ) :10'h3ff ; ////开始的位置          
assign   char_y_NORMAL     =  ((pixel_xpos >= CHAR_B_H_NORMAL ) && (pixel_xpos < CHAR_B_H_NORMAL+CHAR_W_NORMAL )
                           && (pixel_ypos  >= CHAR_B_V_NORMAL  ) && (pixel_ypos < CHAR_B_V_NORMAL+CHAR_H_NORMAL ))?
                              (pixel_ypos -  CHAR_B_V_NORMAL    ) :10'h3ff   ; ////开始的位置///1023 
assign   char_x_DIFFICULT  =((pixel_xpos >= CHAR_B_H_DIFFICULT ) && (pixel_xpos < CHAR_B_H_DIFFICULT+CHAR_W_DIFFICULT )
                          && (pixel_ypos  >= CHAR_B_V_DIFFICULT  ) && (pixel_ypos < CHAR_B_V_DIFFICULT+CHAR_H_DIFFICULT ) )?
                             (pixel_xpos -  CHAR_B_H_DIFFICULT ) :10'h3ff  ; ////开始的位置          
assign   char_y_DIFFICULT  =  ((pixel_xpos >= CHAR_B_H_DIFFICULT ) && (pixel_xpos < CHAR_B_H_DIFFICULT+CHAR_W_DIFFICULT )
                          && (pixel_ypos  >= CHAR_B_V_DIFFICULT  ) && (pixel_ypos < CHAR_B_V_DIFFICULT+CHAR_H_DIFFICULT ) )?
                              (pixel_ypos -  CHAR_B_V_DIFFICULT     ) :10'h3ff   ; ////开始的位置///1023        
   
//给不同的区域绘制不同的颜色

always @(posedge vga_clk or negedge sys_rst_n)           
    if (!sys_rst_n)  
     cnt_xuan <= 3'd0;
     else if ((cnt_xuan== 3'd2)||(state!=s3))
     cnt_xuan <= 3'd0;     
     else if ((state==s3)&&(key_down))
     cnt_xuan <=  cnt_xuan + 1'b1 ;     
     else if ((state==s3)&&(key_up))
     cnt_xuan <=  cnt_xuan - 1'b1 ;   
     else 
     cnt_xuan <= cnt_xuan ;  
 
always @(posedge vga_clk or negedge sys_rst_n)           
    if (!sys_rst_n) 
        s3_data <= BLACK;  
     else    if(((pixel_xpos>= (CHAR_B_H - 1'b1)) 
             && (pixel_xpos< (CHAR_B_H + CHAR_W -1'b1))) 
             && ((pixel_ypos >= CHAR_B_V) && (pixel_ypos < (CHAR_B_V + CHAR_H))))
   case (grade_3)
 0:if (char_0[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background;  
 1:if (char_1[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background;  
 2:if (char_2[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 3:if (char_3[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 4:if (char_4[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 5:if (char_5[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 6:if (char_6[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 7:if (char_7[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 8:if (char_8[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 9:if (char_9[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
default :s3_data    <=  background; 
   endcase           
               
   else    if(((pixel_xpos>= (CHAR_B_H - 1'b1+32))    
             && (pixel_xpos< (CHAR_B_H + CHAR_W -1'b1+32))) 
             && ((pixel_ypos >= CHAR_B_V) && (pixel_ypos < (CHAR_B_V + CHAR_H))))
   case (grade_2)
 0:if (char_0[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 1:if (char_1[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 2:if (char_2[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 3:if (char_3[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 4:if (char_4[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 5:if (char_5[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 6:if (char_6[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 7:if (char_7[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 8:if (char_8[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 9:if (char_9[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
default :s3_data    <=  background; 
   endcase      
   else    if(((pixel_xpos>= (CHAR_B_H - 1'b1+64)) 
             && (pixel_xpos< (CHAR_B_H + CHAR_W -1'b1+64))) 
             && ((pixel_ypos >= CHAR_B_V) && (pixel_ypos < (CHAR_B_V + CHAR_H))))
   case (grade_1)
 0:if (char_0[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 1:if (char_1[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 2:if (char_2[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 3:if (char_3[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 4:if (char_4[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 5:if (char_5[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 6:if (char_6[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 7:if (char_7[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 8:if (char_8[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 9:if (char_9[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
default :s3_data    <=  background; 
   endcase  
   else    if(((pixel_xpos>= (CHAR_B_H - 1'b1+96)) 
             && (pixel_xpos< (CHAR_B_H + CHAR_W -1'b1+96))) 
             && ((pixel_ypos >= CHAR_B_V) && (pixel_ypos < (CHAR_B_V + CHAR_H))))
   case (grade_0)
 0:if (char_0[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 1:if (char_1[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 2:if (char_2[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 3:if (char_3[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 4:if (char_4[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 5:if (char_5[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 6:if (char_6[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 7:if (char_7[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 8:if (char_8[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
 9:if (char_9[char_y/'d8][ 'd255 -'d32*char_y- char_x] == 1'b1)   s3_data    <=  RED ; else  s3_data    <=  background; 
default :s3_data    <=  background; 
   endcase    
     else  if ((pixel_xpos >= CHAR_B_H_AGAIN ) && (pixel_xpos < CHAR_B_H_AGAIN+CHAR_W_AGAIN )
          && (pixel_ypos  >= CHAR_B_V_AGAIN  ) && (pixel_ypos < CHAR_B_V_AGAIN+CHAR_H_AGAIN )
             && (char_AGAIN[char_y_AGAIN  ][  CHAR_W_AGAIN - 1- char_x_AGAIN] == 1'b1) )     
        s3_data <= BLACK; 
     else  if ((pixel_xpos >= CHAR_B_H_MAIN ) && (pixel_xpos < CHAR_B_H_MAIN+CHAR_W_MAIN )
          && (pixel_ypos  >= CHAR_B_V_MAIN  ) && (pixel_ypos < CHAR_B_V_MAIN+CHAR_H_MAIN )
             && (char_MAIN[char_y_MAIN  ][  CHAR_W_MAIN - 1- char_x_MAIN] == 1'b1) )     
        s3_data <= BLACK; 
     else  if ((pixel_xpos >= CHAR_B_H_AGAIN -20 ) && (pixel_xpos < CHAR_B_H_AGAIN -10  )
          &&  (pixel_ypos  >= CHAR_B_V_AGAIN ) && (pixel_ypos < CHAR_B_V_AGAIN+CHAR_H_AGAIN )
             &&(cnt_xuan==1'b0 )   )          
        s3_data <= RED;         
     else  if ((pixel_xpos >= CHAR_B_H_MAIN-20  ) && (pixel_xpos < CHAR_B_H_MAIN -10 )
          && (pixel_ypos  >= CHAR_B_V_MAIN  ) && (pixel_ypos < CHAR_B_V_MAIN+CHAR_H_MAIN )
             &&(cnt_xuan==3'd1 )   )          
        s3_data <= RED;       
  else 
         s3_data <= WHITE ;   
   
   
 assign  char_x =  (((pixel_xpos >= CHAR_B_H) && (pixel_xpos < (CHAR_B_H + CHAR_W - 1'b1+96))) 
                  &&((pixel_ypos >= CHAR_B_V)&&(pixel_ypos < (CHAR_B_V + CHAR_H)))) ?
                  (pixel_xpos- CHAR_B_H)  : 10'h3FF; 
                  
                  
 assign  char_y =    (((pixel_xpos >= CHAR_B_H- 1'b1) && (pixel_xpos < (CHAR_B_H + CHAR_W - 1'b1+96))) 
                  &&((pixel_ypos >= CHAR_B_V)&&(pixel_ypos < (CHAR_B_V + CHAR_H)))) ?
                  (pixel_ypos - CHAR_B_V)   : 10'h3FF ;///1023 
 
assign   char_x_AGAIN     =  ((pixel_xpos >= CHAR_B_H_AGAIN ) && (pixel_xpos < CHAR_B_H_AGAIN+CHAR_W_AGAIN )
                           && (pixel_ypos  >= CHAR_B_V_AGAIN  ) && (pixel_ypos < CHAR_B_V_AGAIN+CHAR_H_AGAIN ))?
                              (pixel_xpos -  CHAR_B_H_AGAIN    ) :10'h3ff ; ////开始的位置          
assign   char_y_AGAIN     =  ((pixel_xpos >= CHAR_B_H_AGAIN ) && (pixel_xpos < CHAR_B_H_AGAIN+CHAR_W_AGAIN )
                           && (pixel_ypos  >= CHAR_B_V_AGAIN  ) && (pixel_ypos < CHAR_B_V_AGAIN+CHAR_H_AGAIN ))?
                              (pixel_ypos -  CHAR_B_V_AGAIN    ) :10'h3ff   ; ////开始的位置///1023 
assign   char_x_MAIN  =((pixel_xpos >= CHAR_B_H_MAIN ) && (pixel_xpos < CHAR_B_H_MAIN+CHAR_W_MAIN )
                          && (pixel_ypos  >= CHAR_B_V_MAIN  ) && (pixel_ypos < CHAR_B_V_MAIN+CHAR_H_MAIN ) )?
                             (pixel_xpos -  CHAR_B_H_MAIN ) :10'h3ff  ; ////开始的位置          
assign   char_y_MAIN  =  ((pixel_xpos >= CHAR_B_H_MAIN ) && (pixel_xpos < CHAR_B_H_MAIN+CHAR_W_MAIN )
                          && (pixel_ypos  >= CHAR_B_V_MAIN  ) && (pixel_ypos < CHAR_B_V_MAIN+CHAR_H_MAIN ) )?
                             (pixel_ypos -   CHAR_B_V_MAIN ) :10'h3ff  ; ////开始的位置       

  
 
always @(posedge vga_clk or negedge sys_rst_n)          
    if (!sys_rst_n)    
 grade<= 8'd0 ;
else if ((state== idle)||(state==s3))
 grade<= 8'd0 ;
else if((cnt_apple== 3'd4)&& ( apple_x== head_x )&&( apple_y== head_y  ))
 grade<= grade+ 'd5 ; 
else if( ( apple_x== head_x )&&( apple_y== head_y  ))
 grade<= grade+ 1'b1 ;
else 
 grade<= grade  ;
  
always @(posedge vga_clk or negedge sys_rst_n)          
    if (!sys_rst_n)    
 grade_max<= 8'd0 ;
else if  (state== s2)  
 grade_max<= grade  ;
 else 
grade_max<=grade_max;

 
always @(posedge vga_clk or negedge sys_rst_n)          
    if (!sys_rst_n) 
	    cnt_1s<=0;      
  	 else if((state== s2)&&(cnt_1s<=max_cnt_1s))/////在游戏界面才动 移动速度
		 cnt_1s<=cnt_1s+1;  
    else
		 cnt_1s<=0;	 
always @(posedge vga_clk or negedge sys_rst_n)          
    if (!sys_rst_n)begin
		head_x <= 22'd6;                     //方块初始位置横坐标
        head_y <= 22'd3;
		body_x[0][15:0]<=7; 
	    body_y[0][15:0]<=3;
		body_x[1][15:0]<=7; 
	    body_y[1][15:0]<=4;
		body_x[2][15:0]<=7; 
	    body_y[2][15:0]<=5;
		body_x[3][15:0]<=7; 
	    body_y[3][15:0]<=6;
		body_x[4][15:0]<=7; 
	    body_y[4][15:0]<=7;        
		 index<=0;
	 end
	 else begin
	 if(head_x<=0||head_x>31||head_y<=0||head_y>23)begin  //pengzhuang
		pengzhuang<=1;  //撞墙
	end
	else
	   pengzhuang<=0;
	if(snake_l==3)begin   //撞身体
    if(head_x==body_x[3][15:0] && head_y==body_y[3][15:0])
      pengzhuang2<=1;
	   else
	   pengzhuang2<=0;
   end
   if(snake_l==4)begin
    if((head_x==body_x[3][15:0] && head_y==body_y[3][15:0])||(head_x==body_x[4][15:0] && head_y==body_y[4][15:0]))
      pengzhuang2<=1;
	   else
	   pengzhuang2<=0;
   end
  if(snake_l==5)begin
    if((head_x==body_x[3][15:0] && head_y==body_y[3][15:0])||(head_x==body_x[4][15:0] && head_y==body_y[4][15:0])||(head_x==body_x[5][15:0] && head_y==body_y[5][15:0]))
      pengzhuang2<=1;
	   else
	   pengzhuang2<=0;
   end
 if(snake_l==6)begin
    if((head_x==body_x[3][15:0] && head_y==body_y[3][15:0])||(head_x==body_x[4][15:0] && head_y==body_y[4][15:0])||(head_x==body_x[5][15:0] && head_y==body_y[5][15:0])|| (head_x==body_x[6][15:0]&& head_y==body_y[6][15:0]))
      pengzhuang2<=1;
	   else
	   pengzhuang2<=0;
   end
 if(snake_l==7)begin
    if((head_x==body_x[3][15:0] && head_y==body_y[3][15:0])||(head_x==body_x[4][15:0] && head_y==body_y[4][15:0])||(head_x==body_x[5][15:0] && head_y==body_y[5][15:0])|| (head_x==body_x[6][15:0]&& head_y==body_y[6][15:0])|| (head_x==body_x[7][15:0]&& head_y==body_y[7][15:0]))
      pengzhuang2<=1;
	   else
	   pengzhuang2<=0;
   end
 if(snake_l==8)begin
    if((head_x==body_x[3][15:0] && head_y==body_y[3][15:0])||(head_x==body_x[4][15:0] && head_y==body_y[4][15:0])||(head_x==body_x[5][15:0] && head_y==body_y[5][15:0])||( head_x==body_x[6][15:0]&& head_y==body_y[6][15:0])||( head_x==body_x[7][15:0]&& head_y==body_y[7][15:0])||( head_x==body_x[8][15:0]&& head_y==body_y[8][15:0]))
      pengzhuang2<=1;
	   else
	   pengzhuang2<=0;
   end
 if(snake_l==9)begin
    if((head_x==body_x[3][15:0] && head_y==body_y[3][15:0])||(head_x==body_x[4][15:0] && head_y==body_y[4][15:0])||(head_x==body_x[5][15:0] && head_y==body_y[5][15:0])||( head_x==body_x[6][15:0]&& head_y==body_y[6][15:0])|| (head_x==body_x[7][15:0]&& head_y==body_y[7][15:0])||( head_x==body_x[8][15:0]&& head_y==body_y[8][15:0])||(head_x==body_x[9][15:0]&& head_y==body_y[9][15:0]))
      pengzhuang2<=1;
	   else
	   pengzhuang2<=0;
   end
 if(snake_l==10)begin
    if((head_x==body_x[3][15:0] && head_y==body_y[3][15:0])||(head_x==body_x[4][15:0] && head_y==body_y[4][15:0])||(head_x==body_x[5][15:0] && head_y==body_y[5][15:0])||( head_x==body_x[6][15:0]&& head_y==body_y[6][15:0])|| (head_x==body_x[7][15:0]&& head_y==body_y[7][15:0])||( head_x==body_x[8][15:0]&& head_y==body_y[8][15:0])||(head_x==body_x[9][15:0]&& head_y==body_y[9][15:0])||(head_x==body_x[10][15:0]&& head_y==body_y[10][15:0]))
      pengzhuang2<=1;
	   else
	   pengzhuang2<=0;
   end	
	 if(pengzhuang==1)begin    //初始位置
	    head_x <= 22'd6;                     
        head_y <= 22'd3;
		 body_x[0][15:0]<=7; 
	     body_y[0][15:0]<=3;
		 body_x[1][15:0]<=7; 
	     body_y[1][15:0]<=4;
		 body_x[2][15:0]<=7; 
	     body_y[2][15:0]<=5;
		 body_x[3][15:0]<=7; 
	     body_y[3][15:0]<=6; 
		 body_x[4][15:0]<=7; 
	     body_y[4][15:0]<=7;           
	 end
	 if(pengzhuang2==1)begin
	    head_x <= 22'd6;                     //初始位置
        head_y <= 22'd3;
	    body_x[0][15:0]<=7; 
	    body_y[0][15:0]<=3;
	    body_x[1][15:0]<=7; 
	    body_y[1][15:0]<=4;
		body_x[2][15:0]<=7; 
	    body_y[2][15:0]<=5;
		body_x[3][15:0]<=7; 
	    body_y[3][15:0]<=6;
		body_x[4][15:0]<=7; 
	    body_y[4][15:0]<=7;   
	 end
	 if(cnt_1s==max_cnt_1s)begin
    body_x[0][15:0]<=head_x; 
	 body_y[0][15:0]<=head_y;
    case(direction)
    	down: begin head_y<=head_y+1;dsign=0; end    // 0      
    	up: begin head_y<=head_y-1;dsign=1; end  // 1          
    	left: begin head_x<=head_x-1;dsign=2; end  // 2        
    	right: begin head_x<=head_x+1;dsign=3; end // 3        
	endcase
	body_x[1][15:0]<=body_x[0][15:0];
	body_y[1][15:0]<=body_y[0][15:0];
	body_x[2][15:0]<=body_x[1][15:0];
	body_y[2][15:0]<=body_y[1][15:0];
	body_x[3][15:0]<=body_x[2][15:0];
	body_y[3][15:0]<=body_y[2][15:0];
    body_x[4][15:0]<=body_x[3][15:0];
	body_y[4][15:0]<=body_y[3][15:0];    
 
if(snake_l>=5)begin
	body_x[5][15:0]<=body_x[4][15:0];
	body_y[5][15:0]<=body_y[4][15:0];
	end
if(snake_l>=6)begin	
	body_x[6][15:0]<=body_x[5][15:0];
	body_y[6][15:0]<=body_y[5][15:0];
end
if(snake_l>=7)begin
   body_x[7][15:0]<=body_x[6][15:0];
	body_y[7][15:0]<=body_y[6][15:0];
end
if(snake_l>=8)begin
	body_x[8][15:0]<=body_x[7][15:0];
	body_y[8][15:0]<=body_y[7][15:0];
end
if(snake_l>=9)begin
	body_x[9][15:0]<=body_x[8][15:0];
	body_y[9][15:0]<=body_y[8][15:0];
	end
if(snake_l>=10)begin
	body_x[10][15:0]<=body_x[9][15:0];
	body_y[10][15:0]<=body_y[9][15:0];
	end
  end
end

always @(posedge vga_clk or negedge sys_rst_n) //苹果
    if (!sys_rst_n)begin
		apple_x<=28;
		apple_y<=20;
		snake_l<=4;
	 end
	 else begin
		if(head_x==apple_x&&head_y==apple_y)begin
			if(apple_x>=13)          //vga显示随机苹果位置
				apple_x<=apple_x-12;
			else if(apple_x<=27)
				apple_x<=apple_x+4;
			else
				apple_x<=10;
			if(apple_y>=15)
		   apple_y<=apple_y-5;
			else if(apple_y>=9)
				apple_y<=apple_y-4;
			else
			   apple_y<=apple_y+7;
         snake_l<=snake_l+1;			
		end
		if(pengzhuang==1||pengzhuang2==1)
			snake_l<=4;
	 end			
//给不同的区域绘制不同的颜色
always @(posedge vga_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) 
        s2_data <= BLACK;
    else begin
        if ((pixel_xpos >= head_x*20-10) && (pixel_xpos < head_x*20+10)
          && (pixel_ypos >= head_y*20-10) && (pixel_ypos < head_y*20+10)) 
            s2_data <= RED;                   
			else if  (((pixel_xpos >= body_x[0][15:0]*20-10) && (pixel_xpos < body_x[0][15:0]*20+10)
          && (pixel_ypos >= body_y[0][15:0]*20-10) && (pixel_ypos < body_y[0][15:0]*20+10))||
			 ((pixel_xpos >= body_x[1][15:0]*20-10) && (pixel_xpos < body_x[1][15:0]*20+10)
          && (pixel_ypos >= body_y[1][15:0]*20-10) && (pixel_ypos < body_y[1][15:0]*20+10))||
			 ((pixel_xpos >= body_x[2][15:0]*20-10) && (pixel_xpos <body_x[2][15:0]*20+10)
          && (pixel_ypos >= body_y[2][15:0]*20-10) && (pixel_ypos < body_y[2][15:0]*20+10))||
			 ((pixel_xpos >= body_x[3][15:0]*20-10) && (pixel_xpos <body_x[3][15:0]*20+10)
          && (pixel_ypos >= body_y[3][15:0]*20-10) && (pixel_ypos < body_y[3][15:0]*20+10))||
			 ((snake_l>=4)&&(pixel_xpos >= body_x[4][15:0]*20-10) && (pixel_xpos < body_x[4][15:0]*20+10)
          && (pixel_ypos >= body_y[4][15:0]*20-10) && (pixel_ypos < body_y[4][15:0]*20+10))||
			 ((snake_l>=5)&&(pixel_xpos >= body_x[5][15:0]*20-10) && (pixel_xpos < body_x[5][15:0]*20+10)
          && (pixel_ypos >= body_y[5][15:0]*20-10) && (pixel_ypos < body_y[5][15:0]*20+10))||
			 ((snake_l>=6)&&(pixel_xpos >= body_x[6][15:0]*20-10) && (pixel_xpos < body_x[6][15:0]*20+10)
          && (pixel_ypos >= body_y[6][15:0]*20-10) && (pixel_ypos < body_y[6][15:0]*20+10))||
			 ((snake_l>=7)&&(pixel_xpos >= body_x[7][15:0]*20-10) && (pixel_xpos < body_x[7][15:0]*20+10)
          && (pixel_ypos >= body_y[7][15:0]*20-10) && (pixel_ypos < body_y[7][15:0]*20+10))||
			 ((snake_l>=8)&&(pixel_xpos >= body_x[8][15:0]*20-10) && (pixel_xpos < body_x[8][15:0]*20+10)
          && (pixel_ypos >= body_y[8][15:0]*20-10) && (pixel_ypos < body_y[8][15:0]*20+10))||
			 ((snake_l>=9)&&(pixel_xpos >= body_x[9][15:0]*20-10) && (pixel_xpos < body_x[9][15:0]*20+10)
          && (pixel_ypos >= body_y[9][15:0]*20-10) && (pixel_ypos < body_y[9][15:0]*20+10))||
			 ((snake_l>=10)&&(pixel_xpos >= body_x[10][15:0]*20-10) && (pixel_xpos < body_x[10][15:0]*20+10)
          && (pixel_ypos >= body_y[10][15:0]*20-10) && (pixel_ypos < body_y[10][15:0]*20+10)))
            s2_data <= BLACK;                //绘制方块为黑色
		  else if(pixel_xpos<=10||pixel_xpos>=630||pixel_ypos<=10||pixel_ypos>=470)////墙的颜色
			   s2_data <= RED;
          else if((cnt_apple== 3'd4)&&(pixel_xpos >= apple_x*20-15) && (pixel_xpos < apple_x*20+15)
          &&      (pixel_ypos >= apple_y*20-15) && (pixel_ypos < apple_y*20+15))
				s2_data <= apple_data_big;  
		  else if((cnt_apple!= 3'd4)&&(pixel_xpos >= apple_x*20-10) && (pixel_xpos < apple_x*20+10)
          &&      (pixel_ypos >= apple_y*20-10) && (pixel_ypos < apple_y*20+10))
				s2_data <= apple_data;
                  
        else
            s2_data <= WHITE;                //绘制背景为白色
    end
end



always @(posedge vga_clk or negedge sys_rst_n)          
    if (!sys_rst_n)    
 cnt_apple<= 8'd0 ;
else if ((cnt_apple== 3'd5)&&((state== idle)||(state==s3)))
 cnt_apple<= 8'd0 ;
else if( ( apple_x== head_x )&&( apple_y== head_y  ))
 cnt_apple<= cnt_apple+ 1'b1 ;
else 
 cnt_apple<= cnt_apple  ;
  
 

//rd_en:ROM读使能
assign  rd_apple_en = (cnt_apple!= 3'd4)&&(pixel_xpos >= apple_x*20-10) && (pixel_xpos < apple_x*20+10)
                    &&  (pixel_ypos >= apple_y*20-10) && (pixel_ypos < apple_y*20+10);  
  
assign  rd_snack_en = (pixel_xpos >=PIC_B_H_snack  ) && (pixel_xpos <PIC_B_H_snack+ H_snack )&&
                      (pixel_ypos >= PIC_B_V_snack ) && (pixel_ypos < PIC_B_V_snack +W_snack);  
assign  rd_applebig_en =(cnt_apple== 3'd4)&& (pixel_xpos >= apple_x*20-15) && (pixel_xpos < apple_x*20+15)
                      &&  (pixel_ypos >= apple_y*20-15) && (pixel_ypos < apple_y*20+15);  
 
//  cnt_bird  小鸟的读取信号
always@(posedge vga_clk or negedge sys_rst_n)        
    if(!sys_rst_n )                                  
        add_snack    <=  14'd0;                     
    else    if(add_snack == (PIC_snack - 1'b1))        
        add_snack    <=  14'd0;                       
    else    if( rd_snack_en == 1'b1)                 
        add_snack    <=  add_snack + 1'b1;
 
  
      
//  cnt_bird  小鸟的读取信号
always@(posedge vga_clk or negedge sys_rst_n)
    if(!sys_rst_n )
        add_apple    <=  14'd0;    
    else    if(add_apple == (PIC_apple - 1'b1))
        add_apple    <=  14'd0;
    else    if(rd_apple_en == 1'b1)
        add_apple    <=  add_apple + 1'b1;
         
//  cnt_bird  小鸟的读取信号
always@(posedge vga_clk or negedge sys_rst_n)
    if(!sys_rst_n )
        add_apple_big    <=  14'd0;    
    else    if(add_apple_big == (900 - 1'b1))
        add_apple_big    <=  14'd0;
    else    if(rd_applebig_en == 1'b1)
        add_apple_big    <=  add_apple_big + 1'b1;        
        
      
rom_apple_big_30x30x16	rom_apple_big_30x30x16_inst (
	.address ( add_apple_big ),
	.clock   ( vga_clk   ),
	.rden    ( rd_applebig_en    ),
	.q       ( apple_data_big    )
	);
 

rom_apple_20x20x16	rom_apple_20x20x16_inst (
	.address ( add_apple ),
	.clock   ( vga_clk   ),
	.rden    ( rd_apple_en    ),
	.q       ( apple_data    )
	);



rom_snack_55x66x16	rom_snack_55x66x16inst (
	.address ( add_snack  ),
	.clock   ( vga_clk   ),
	.rden    ( rd_snack_en     ),
	.q       (  snack_data    )
	);

  bcd_8421  bcd_8421_inst
(
   .sys_clk   (vga_clk) ,   //系统时钟，频率50MHz
   .sys_rst_n ( 1'b1 ) ,   //复位信号，低电平有效
   .data      (grade_max) ,   //输入需要转换的数据
               
   .unit      (grade_0) ,   //个位BCD码
   .ten       (grade_1) ,   //十位BCD码
   .hun       (grade_2) ,   //百位BCD码
   .tho       (grade_3) ,   //千位BCD码
   .t_tho     () ,   //万位BCD码
   .h_hun     ()     //十万位BCD码
);




 always@(posedge vga_clk) ////0-8:1  然后8个加1 
    begin
            char_0[0]  <= 256'h0000000000000000000000000000000000000000000000000000000000000000;    /////0  
        char_0[1]      <= 256'h0000000000000000003FC00000FFF00001F8F80003E07C0007E03C0007C03E00;    /////0  
        char_0[2]      <= 256'h0FC01F000F801F001F801F001F801F801F000F801F000F803F000F803F000FC0;    /////0         
        char_0[3]      <= 256'h3F000FC03F000FC03F000FC03F000FC03F000FC03F000FC03F000FC03F000FC0;    /////0         
        char_0[4]      <= 256'h3F000FC03F000FC03F000FC03F000F801F000F801F000F801F801F801F801F00;    /////0         
        char_0[5]      <= 256'h0F801F000F803E0007C03E0007E03C0003E07C0001F8F80000FFF000003FC000;    /////0         
        char_0[6]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;    /////0       
        char_0[7]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;    /////0         
        char_1[0]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;    /////1          
        char_1[1]      <= 256'h00000000000000000003800000078000000F800003FF800003FF8200001F8000;    /////1          
        char_1[2]      <= 256'h000F8000000F8000000F8000000F8000000F8000000F8000000F8000000F8000;     /////1          
        char_1[3]      <= 256'h000F8000000F8000000F8000000F8000000F8000000F8000000F8000000F8000;     /////1          
        char_1[4]      <= 256'h000F8000000F8000000F8000000F8000000F8000000F8000000F8000000F8000;     /////1          
        char_1[5]      <= 256'h000F8000000F8000000F8000000F8000000F8000001FC00003FFFE0003FFFE00;     /////1          
        char_1[6]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;     /////1          
        char_1[7]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;     /////1   
        char_2[0]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;    /////2  
        char_2[1]      <= 256'h0000000000000000001FC000007FF00001E0F80003803C0007001E0007001E00;    /////2  
        char_2[2]      <= 256'h0E000F000F000F000F000F000F800F000F800F000F800F0007000F0000001E00;    /////2  
        char_2[3]      <= 256'h00001E0000001C0000003C0000007800000070000000E0000001C00000038000;    /////2  
        char_2[4]      <= 256'h00070000000E0000001C000000180000003000000060000000C0000001800100;    /////2  
        char_2[5]      <= 256'h0380030007000300060003000C0006001C000E001FFFFE001FFFFE001FFFFE00;    /////2  
        char_2[6]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;    /////2  
        char_2[7]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;    /////2  
        char_3[0]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////3 
        char_3[1]      <= 256'h0000000000000000003F000001FFC0000383E0000700F000060078000E007800;   /////3 
        char_3[2]      <= 256'h0E003C000F003C000F003C0007003C0000003C0000003C000000380000007800;   /////3 
        char_3[3]      <= 256'h0000F0000001E0000003C000003F0000003FC0000001F0000000780000003C00;   /////3 
        char_3[4]      <= 256'h00001C0000001E0000000E0000000F0000000F0000000F000E000F001F000F00;   /////3 
        char_3[5]      <= 256'h1F000F001F001E001E001E000E003C000F0078000780F00001FFE000007F0000;   /////3 
        char_3[6]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////3 
        char_3[7]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////3 
        char_4[0]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////4 
        char_4[1]      <= 256'h000000000000000000007000000070000000F0000001F0000001F0000003F000;   /////4 
        char_4[2]      <= 256'h0007F0000006F000000CF000000CF0000018F0000030F0000030F0000060F000;   /////4 
        char_4[3]      <= 256'h0060F00000C0F0000180F0000180F0000300F0000600F0000600F0000C00F000;   /////4 
        char_4[4]      <= 256'h0C00F0001800F0003000F0003FFFFFC03FFFFFC00000F0000000F0000000F000;   /////4 
        char_4[5]      <= 256'h0000F0000000F0000000F0000000F0000000F0000000F0000001F800003FFF80;   /////4 
        char_4[6]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////4 
        char_4[7]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////4 
        char_5[0]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////5 
        char_5[1]      <= 256'h000000000000000003FFFE0003FFFE0003FFFC00030000000200000002000000;   /////5 
        char_5[2]      <= 256'h02000000020000000200000002000000060000000600000006000000061FC000;   /////5 
        char_5[3]      <= 256'h067FF00006E0F80007803C0007003C0006001E0006001E0000000F0000000F00;   /////5 
        char_5[4]      <= 256'h00000F0000000F0000000F0000000F0000000F000E000F001F000F001F000F00;   /////5 
        char_5[5]      <= 256'h1F001E001E001E001E001C000E003C000700780003C0F00001FFE000007F8000;   /////5 
        char_5[6]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////5 
        char_5[7]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////5 
        char_6[0]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////6
        char_6[1]      <= 256'h00000000000000000007E000001FF80000781C0000E01E0001C01E0003801E00;   /////6
        char_6[2]      <= 256'h03801C000700000007000000070000000F0000000E0000000E0000000E000000;   /////6
        char_6[3]      <= 256'h1E0FE0001E3FF8001E707C001EC03E001F801E001F800F001F000F001F000780;   /////6
        char_6[4]      <= 256'h1E0007801E0007801E0007801E0007801E0007800E0007800F0007800F000780;   /////6
        char_6[5]      <= 256'h0F00070007800F0007800F0003C01E0001E01C0000F07800007FF000001FC000;   /////6
        char_6[6]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////6
        char_6[7]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////6
        char_7[0]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////7
        char_7[1]      <= 256'h000000000000000007FFFF8007FFFF8007FFFF00078003000600060006000600;   /////7
        char_7[2]      <= 256'h0C000C000C001C0008001800000038000000300000007000000060000000E000;   /////7
        char_7[3]      <= 256'h0000C0000001C000000180000003800000038000000300000007000000070000;   /////7
        char_7[4]      <= 256'h000F0000000E0000000E0000001E0000001E0000001E0000001E0000001E0000;   /////7
        char_7[5]      <= 256'h003E0000003E0000003E0000003E0000003E0000003E0000003E0000001C0000;   /////7
        char_7[6]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////7
        char_7[7]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////7
        char_8[0]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////8
        char_8[1]      <= 256'h0000000000000000003FC00000FFF00003E07C0007801E000F000F000F000F00;   /////8
        char_8[2]      <= 256'h1E0007801E0007801E0007801E0007801E0007801F0007800F800F000FC00E00;   /////8
        char_8[3]      <= 256'h07E01E0003F83C0001FE7000007FC00000FFE00001C7F0000381F8000700FC00;   /////8
        char_8[4]      <= 256'h0F003E001E001F001E000F003C000F803C0007803C0007803C0007803C000780;   /////8
        char_8[5]      <= 256'h3C0007801E0007001E000F000F000E0007801E0003E0780001FFF000003FC000;   /////8
        char_8[6]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////8
        char_8[7]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;   /////8
        char_9[0]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;  /////9
        char_9[1]      <= 256'h0000000000000000007F800001FFE00003E0F000078038000F001C000E001E00;  /////9
        char_9[2]      <= 256'h1E000E001E000F003C0007003C0007003C0007003C0007803C0007803C000780;  /////9
        char_9[3]      <= 256'h3C0007803C0007803C000F801E000F801E001F801F0037800F80678007C1C780;  /////9
        char_9[4]      <= 256'h03FF878000FE0F0000000F0000000F0000000F0000000E0000001E0000001E00;  /////9
        char_9[5]      <= 256'h00001C0006003C000F0078000F0070000F01E0000783C00003FF800000FE0000;  /////9
        char_9[6]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;  /////9
        char_9[7]      <= 256'h0000000000000000000000000000000000000000000000000000000000000000;  /////9
        char_kaishi[0]  <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[1]  <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[2]  <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[3]  <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[4]  <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[5]  <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[6]  <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[7]  <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[8]  <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[9]  <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[10] <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[11] <= 160'h001FE0000FFFFFF00003C0003FFFF8000FFFFFF0;
        char_kaishi[12] <= 160'h007FF8800FFFFFF00003C0003FFFFE000FFFFFF0;
        char_kaishi[13] <= 160'h00F03F800F03C0F80003C00007E01F800F03C0F8;
        char_kaishi[14] <= 160'h01C00F801E03C0380007E00003C007C01E03C038;
        char_kaishi[15] <= 160'h03C007801C03C0380007E00003C003E01C03C038;
        char_kaishi[16] <= 160'h078003C01803C0180006E00003C001E01803C018;
        char_kaishi[17] <= 160'h078001C01803C0180006E00003C001E01803C018;
        char_kaishi[18] <= 160'h070001C01003C00C000CF00003C000F01003C00C;
        char_kaishi[19] <= 160'h0F0000C03003C00C000CF00003C000F03003C00C;
        char_kaishi[20] <= 160'h0F0000C03003C004000C700003C000F03003C004;
        char_kaishi[21] <= 160'h0F0000000003C000000C700003C000F00003C000;
        char_kaishi[22] <= 160'h0F0000000003C0000018780003C000F00003C000;
        char_kaishi[23] <= 160'h0F0000000003C0000018780003C000F00003C000;
        char_kaishi[24] <= 160'h0F8000000003C0000018780003C000F00003C000;
        char_kaishi[25] <= 160'h07C000000003C0000018380003C000E00003C000;
        char_kaishi[26] <= 160'h07E000000003C00000303C0003C001E00003C000;
        char_kaishi[27] <= 160'h07F000000003C00000303C0003C001E00003C000;
        char_kaishi[28] <= 160'h03FC00000003C00000303C0003C003C00003C000;
        char_kaishi[29] <= 160'h01FF00000003C00000301C0003C007800003C000;
        char_kaishi[30] <= 160'h007FC0000003C00000601E0003C01F000003C000;
        char_kaishi[31] <= 160'h003FF0000003C00000601E0003FFFE000003C000;
        char_kaishi[32] <= 160'h000FFC000003C00000601E0003FFF0000003C000;
        char_kaishi[33] <= 160'h0003FE000003C00000600E0003C0F0000003C000;
        char_kaishi[34] <= 160'h0000FF000003C00000E00E0003C0F0000003C000;
        char_kaishi[35] <= 160'h00003F800003C00000C00F0003C070000003C000;
        char_kaishi[36] <= 160'h00000FC00003C00000C00F0003C078000003C000;
        char_kaishi[37] <= 160'h000007E00003C00000FFFF0003C078000003C000;
        char_kaishi[38] <= 160'h000003E00003C00001FFFF0003C03C000003C000;
        char_kaishi[39] <= 160'h000001E00003C0000180078003C03C000003C000;
        char_kaishi[40] <= 160'h000001F00003C0000180078003C03E000003C000;
        char_kaishi[41] <= 160'h000000F00003C0000180078003C01E000003C000;
        char_kaishi[42] <= 160'h080000F00003C0000380078003C01E000003C000;
        char_kaishi[43] <= 160'h180000F00003C000030003C003C00F000003C000;
        char_kaishi[44] <= 160'h180000F00003C000030003C003C00F000003C000;
        char_kaishi[45] <= 160'h1C0000F00003C000030003C003C00F800003C000;
        char_kaishi[46] <= 160'h0C0000F00003C000070003C003C007800003C000;
        char_kaishi[47] <= 160'h0E0000E00003C000060001E003C007800003C000;
        char_kaishi[48] <= 160'h0E0001E00003C000060001E003C003C00003C000;
        char_kaishi[49] <= 160'h0F0001C00003C000060001E003C003C00003C000;
        char_kaishi[50] <= 160'h0F8003C00003C0000E0001E003C003E00003C000;
        char_kaishi[51] <= 160'h0FC007800003C0000E0001F003C001E00003C000;
        char_kaishi[52] <= 160'h07F81F000007E0001F0001F807E001F00007E000;
        char_kaishi[53] <= 160'h061FFC00007FFE007FC00FFE3FFC01FE007FFE00;
        char_kaishi[54] <= 160'h0407F000007FFE007FC00FFE3FFC00FE007FFE00;
        char_kaishi[55] <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[56] <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[57] <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[58] <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[59] <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[60] <= 160'h0000000000000000000000000000000000000000;
        char_kaishi[61] <= 256'h0000000000000000000000000000000000000000;
        char_kaishi[62] <= 256'h0000000000000000000000000000000000000000;
        char_kaishi[63] <= 256'h0000000000000000000000000000000000000000; 
        char_SIMPLE[0]  <= 96'h000000000000000000000000;     char_NORMAL[0]  <= 96'h000000000000000000000000; 
        char_SIMPLE[1]  <= 96'h000000000000000000000000;     char_NORMAL[1]  <= 96'h000000000000000000000000; 
        char_SIMPLE[2]  <= 96'h000000000000000000000000;     char_NORMAL[2]  <= 96'h000000000000000000000000; 
        char_SIMPLE[3]  <= 96'h000000000000000000000000;     char_NORMAL[3]  <= 96'h000000000000000000000000; 
        char_SIMPLE[4]  <= 96'h000000000000000000000000;     char_NORMAL[4]  <= 96'h000000000000000000000000; 
        char_SIMPLE[5]  <= 96'h000000000000000000000000;     char_NORMAL[5]  <= 96'h000000000000000000000000; 
        char_SIMPLE[6]  <= 96'h0FFC1FF8F00F7FF07E007FFC;     char_NORMAL[6]  <= 96'hF83F03C07FE0F00F03807E00; 
        char_SIMPLE[7]  <= 96'h1CFC0180381C18181800180C;     char_NORMAL[7]  <= 96'h7C0E0C301838381C03801800; 
        char_SIMPLE[8]  <= 96'h383C0180381C180C18001804;     char_NORMAL[8]  <= 96'h3C0C18181818381C03801800; 
        char_SIMPLE[9]  <= 96'h701C0180381C180618001802;     char_NORMAL[9]  <= 96'h3E0C1008180C381C03801800; 
        char_SIMPLE[10] <= 96'h700C0180381C180618001802;     char_NORMAL[10] <= 96'h3E0C300C180C381C04C01800; 
        char_SIMPLE[11] <= 96'h700C0180382C180618001800;     char_NORMAL[11] <= 96'h3F0C300C180C382C04C01800; 
        char_SIMPLE[12] <= 96'h700001802C2C180618001800;     char_NORMAL[12] <= 96'h3F0C6004180C2C2C04C01800; 
        char_SIMPLE[13] <= 96'h780001802C2C180618001810;     char_NORMAL[13] <= 96'h378C6006180C2C2C04C01800; 
        char_SIMPLE[14] <= 96'h3E0001802C2C180618001810;     char_NORMAL[14] <= 96'h378C600618182C2C0C401800; 
        char_SIMPLE[15] <= 96'h1F8001802C4C180C18001830;     char_NORMAL[15] <= 96'h33CC600618302C4C08601800; 
        char_SIMPLE[16] <= 96'h0FE001802C4C181818001FF0;     char_NORMAL[16] <= 96'h33CC60061FE02C4C08601800; 
        char_SIMPLE[17] <= 96'h03F80180264C1FE018001830;     char_NORMAL[17] <= 96'h31EC600618C0264C08601800; 
        char_SIMPLE[18] <= 96'h007C0180264C180018001810;     char_NORMAL[18] <= 96'h31EC600618C0264C18201800; 
        char_SIMPLE[19] <= 96'h003C0180264C180018001810;     char_NORMAL[19] <= 96'h30FC60061860264C1FF01800; 
        char_SIMPLE[20] <= 96'h001E0180268C180018001800;     char_NORMAL[20] <= 96'h30FC60061860268C10301800; 
        char_SIMPLE[21] <= 96'h600E0180228C180018001800;     char_NORMAL[21] <= 96'h307C20061860228C10301800;   
        char_SIMPLE[22] <= 96'h600E0180238C180018001800;     char_NORMAL[22] <= 96'h307C300C1830238C10301800;   
        char_SIMPLE[23] <= 96'h700E0180238C180018021802;     char_NORMAL[23] <= 96'h303C300C1830238C20181802;   
        char_SIMPLE[24] <= 96'h701C0180230C180018021802;     char_NORMAL[24] <= 96'h303C10081830230C20181802;   
        char_SIMPLE[25] <= 96'h781C0180230C180018041804;     char_NORMAL[25] <= 96'h301C18181818230C20181804; 
        char_SIMPLE[26] <= 96'h7E780180210C1800180C180C;     char_NORMAL[26] <= 96'h701C0C301818210C601C180C; 
        char_SIMPLE[27] <= 96'h3FF01FF8F13F7E007FFC7FFC;     char_NORMAL[27] <= 96'hFC0C03C07E1EF13FF83E7FFC; 
        char_SIMPLE[28] <= 96'h000000000000000000000000;     char_NORMAL[28] <= 96'h000000000000000000000000; 
        char_SIMPLE[29] <= 96'h000000000000000000000000;     char_NORMAL[29] <= 96'h000000000000000000000000; 
        char_SIMPLE[30] <= 96'h000000000000000000000000;     char_NORMAL[30] <= 96'h000000000000000000000000; 
        char_SIMPLE[31] <= 96'h000000000000000000000000;     char_NORMAL[31] <= 96'h000000000000000000000000; 
        char_DIFFICULT[0]  <= 144'h000000000000000000000000000000000000;
        char_DIFFICULT[1]  <= 144'h000000000000000000000000000000000000;
        char_DIFFICULT[2]  <= 144'h000000000000000000000000000000000000;
        char_DIFFICULT[3]  <= 144'h000000000000000000000000000000000000;
        char_DIFFICULT[4]  <= 144'h000000000000000000000000000000000000;
        char_DIFFICULT[5]  <= 144'h000000000000000000000000000000000000;
        char_DIFFICULT[6]  <= 144'hFFE01FF87FFC7FFC1FF803E0FC3E7E003FFC;
        char_DIFFICULT[7]  <= 144'h3DF00180181C181C0180061C300818003184;
        char_DIFFICULT[8]  <= 144'h38780180180418040180080C300818002186;
        char_DIFFICULT[9]  <= 144'h383C01801802180201801806300818004182;
        char_DIFFICULT[10] <= 144'h381E01801802180201803002300818004182;
        char_DIFFICULT[11] <= 144'h381E01801800180001803002300818000180;
        char_DIFFICULT[12] <= 144'h381E01801800180001803000300818000180;
        char_DIFFICULT[13] <= 144'h380E01801810181001806000300818000180;
        char_DIFFICULT[14] <= 144'h380F01801810181001806000300818000180;
        char_DIFFICULT[15] <= 144'h380F01801830183001806000300818000180;
        char_DIFFICULT[16] <= 144'h380F01801FF01FF001806000300818000180;
        char_DIFFICULT[17] <= 144'h380F01801830183001806000300818000180;
        char_DIFFICULT[18] <= 144'h380F01801810181001806000300818000180;
        char_DIFFICULT[19] <= 144'h380E01801810181001806000300818000180;
        char_DIFFICULT[20] <= 144'h380E01801810181001806000300818000180;
        char_DIFFICULT[21] <= 144'h381E01801800180001806000300818000180;
        char_DIFFICULT[22] <= 144'h381E01801800180001803002300818000180;
        char_DIFFICULT[23] <= 144'h381C01801800180001803002300818020180;
        char_DIFFICULT[24] <= 144'h383C01801800180001801004300818020180;
        char_DIFFICULT[25] <= 144'h387801801800180001801808181018040180;
        char_DIFFICULT[26] <= 144'h3DF001801800180001800C101C20180C0180;
        char_DIFFICULT[27] <= 144'hFFE01FF87E007E001FF803E007C07FFC07E0;
        char_DIFFICULT[28] <= 144'h000000000000000000000000000000000000;
        char_DIFFICULT[29] <= 144'h000000000000000000000000000000000000;
        char_DIFFICULT[30] <= 144'h000000000000000000000000000000000000;
        char_DIFFICULT[31] <= 144'h000000000000000000000000000000000000;
    
 char_AGAIN[0]  <=  80'h00000000000000000000;              char_MAIN[0]  <= 144'h000000000000000000000000000000000000;
 char_AGAIN[1]  <=  80'h00000000000000000000;              char_MAIN[1]  <= 144'h000000000000000000000000000000000000;
 char_AGAIN[2]  <=  80'h00000000000000000000;              char_MAIN[2]  <= 144'h000000000000000000000000000000000000;
 char_AGAIN[3]  <=  80'h00000000000000000000;              char_MAIN[3]  <= 144'h000000000000000000000000000000000000;
 char_AGAIN[4]  <=  80'h00000000000000000000;              char_MAIN[4]  <= 144'h000000000000000000000000000000000000;
 char_AGAIN[5]  <=  80'h00000000000000000000;              char_MAIN[5]  <= 144'h000000000000000000000000000000000000;
 char_AGAIN[6]  <=  80'h03C003C003801FF8F01F;              char_MAIN[6]  <= 144'hF81F03801FF8F01F0000F00F7FFCF01FFC3E;
 char_AGAIN[7]  <=  80'h03C00C30038001803804;              char_MAIN[7]  <= 144'h781E0380018038040000381C180C38043008;
 char_AGAIN[8]  <=  80'h03C00810038001803804;              char_MAIN[8]  <= 144'h783E0380018038040000381C180438043008;
 char_AGAIN[9]  <=  80'h07C01818038001802C04;              char_MAIN[9]  <= 144'h783E038001802C040000381C18022C043008;
 char_AGAIN[10] <=  80'h07E0300804C001802C04;              char_MAIN[10] <= 144'h7C3E04C001802C040000381C18022C043008;
 char_AGAIN[11] <=  80'h06E0300804C001802604;              char_MAIN[11] <= 144'h7C3E04C0018026040000382C180026043008;
 char_AGAIN[12] <=  80'h06E0200004C001802604;              char_MAIN[12] <= 144'h7C7E04C00180260400002C2C180026043008;
 char_AGAIN[13] <=  80'h0EE0600004C001802304;              char_MAIN[13] <= 144'h7C7E04C00180230400002C2C181023043008;
 char_AGAIN[14] <=  80'h0EF060000C4001802304;              char_MAIN[14] <= 144'h7C7E0C400180230400002C2C181023043008;
 char_AGAIN[15] <=  80'h0CF06000086001802184;              char_MAIN[15] <= 144'h7E7E08600180218400002C4C183021843008;
 char_AGAIN[16] <=  80'h0C706000086001802184;              char_MAIN[16] <= 144'h7EFE08600180218400002C4C1FF021843008;
 char_AGAIN[17] <=  80'h1C7060000860018020C4;              char_MAIN[17] <= 144'h6EFE0860018020C40000264C183020C43008;
 char_AGAIN[18] <=  80'h1C78607E1820018020C4;              char_MAIN[18] <= 144'h6EFE1820018020C40000264C181020C43008;
 char_AGAIN[19] <=  80'h1FF860181FF001802064;              char_MAIN[19] <= 144'h6FDE1FF0018020640000264C181020643008;
 char_AGAIN[20] <=  80'h18786018103001802064;              char_MAIN[20] <= 144'h6FDE1030018020640000268C180020643008;
 char_AGAIN[21] <=  80'h38382018103001802034;              char_MAIN[21] <= 144'h67DE1030018020340000228C180020343008;
 char_AGAIN[22] <=  80'h38383018103001802034;              char_MAIN[22] <= 144'h67DE1030018020340000238C180020343008;
 char_AGAIN[23] <=  80'h303C301820180180201C;              char_MAIN[23] <= 144'h679E20180180201C0000238C1802201C3008;
 char_AGAIN[24] <=  80'h303C101820180180201C;              char_MAIN[24] <= 144'h679E20180180201C0000230C1802201C3008;
 char_AGAIN[25] <=  80'h701C181820180180200C;              char_MAIN[25] <= 144'h679E20180180200C0000230C1804200C1810;
 char_AGAIN[26] <=  80'h701E0C20601C0180200C;              char_MAIN[26] <= 144'h739E601C0180200C0000210C180C200C1C20;
 char_AGAIN[27] <=  80'hFC7F07C0F83E1FF8F804;              char_MAIN[27] <= 144'hFB7FF83E1FF8F8040000F13F7FFCF80407C0;
 char_AGAIN[28] <=  80'h00000000000000000000;              char_MAIN[28] <= 144'h000000000000000000000000000000000000;
 char_AGAIN[29] <=  80'h00000000000000000000;              char_MAIN[29] <= 144'h000000000000000000000000000000000000;
 char_AGAIN[30] <=  80'h00000000000000000000;              char_MAIN[30] <= 144'h000000000000000000000000000000000000;
 char_AGAIN[31] <=  80'h00000000000000000000;              char_MAIN[31] <= 144'h000000000000000000000000000000000000;



      
         
          
    end
 

endmodule 