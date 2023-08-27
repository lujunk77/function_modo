module Function_Gent_squire(
	clk,
	rst_n,
	data_out,
	squire_en,
	F_word,
	P_word
	);
input  clk;
input  rst_n;
input  [7:0]F_word;
input  [7:0]P_word; 
input squire_en;
output data_out;

//每个相位输出间隔时间
reg [4:0] cnt0;
wire add_cnt0;
wire end_cnt0;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cnt0<=0;		
	end
	else if (add_cnt0) begin
		if (end_cnt0) begin
			cnt0<=0;
		end
		else begin
			cnt0<=cnt0+1;
		end
	end
end
assign add_cnt0 = squire_en;
assign end_cnt0 = add_cnt0 && cnt0==19-1;
//频率控制字同步寄存器（步长）
reg [7:0] F_word_r;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin		
		F_word_r<=0;
	end
	else begin
		F_word_r<=F_word;
	end
end

//相位控制字同步寄存器
reg [7:0] P_word_r;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin		
		P_word_r<=0;
	end
	else begin
		P_word_r<=P_word;
	end
end


//相位累加器
reg [7:0] Freq_Acc;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		Freq_Acc<=0;
	end
	else if(end_cnt0) begin
		Freq_Acc<=F_word_r+Freq_Acc;
	end
end

reg [7:0]Freq_Acc_out;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		Freq_Acc_out<=0;
	end
	else if (end_cnt0)begin
		Freq_Acc_out<=Freq_Acc+P_word_r;
	end
end

//波形数据表地址
wire [7:0] Rom_addr;

assign Rom_addr =Freq_Acc_out;
 ROM_squire ROM_squire(
  .address(Rom_addr),
  .clock(clk),
  .q(data_out)
 	);

endmodule