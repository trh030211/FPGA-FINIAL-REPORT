//****************************************Copyright (c)***********************************//

// Descriptions:        按键控制LED
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module key_led(
    input               sys_clk  ,    //50Mhz系统时钟
    input               sys_rst_n,    //系统复位，低有效
    input        [3:0]  key,          //按键输入信号
	 output   reg    [2:0]  direction,
	 input        [2:0]  dsign,
	 input               pengzhuang,
	 input               pengzhuang2
    );

//reg define     
reg  [23:0] cnt;
reg  [1:0]  led_control;


//识别按键，切换显示模式
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        direction<=0;
    end 
    else begin 
	  if (key[0]==0)  //按键1按下时，从右向左的流水灯效果
	     if(dsign==2||dsign==3)
        direction<=0;
     if (key[1]==0)  //按键2按下时，从左向右的流水灯效果
	     if(dsign==2||dsign==3)
        direction<=1;
     if (key[2]==0)  //按键3按下时，LED闪烁
	     if(dsign==0||dsign==1)
        direction<=2;
     if (key[3]==0)  //按键4按下时，LED全亮
	     if(dsign==0||dsign==1)
        direction<=3;
	  if(pengzhuang==1)
		  direction<=0;
	  if(pengzhuang2==1)
		  direction<=0;
   end		  
end

endmodule 