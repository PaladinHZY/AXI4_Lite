`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2019 12:33:05 PM
// Design Name: 
// Module Name: AXI4_lite_simu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AXI4_lite_simu 
#(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4
	)
	();
	
// Ports of Axi Slave Bus Interface S00_AXI
reg  s00_axi_aclk;
reg  s00_axi_aresetn;
reg [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr;
reg [2 : 0] s00_axi_awprot;
reg  s00_axi_awvalid;
wire  s00_axi_awready;
reg [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata;
reg [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb;
reg  s00_axi_wvalid;
wire  s00_axi_wready;
wire [1 : 0] s00_axi_bresp;
wire  s00_axi_bvalid;
reg  s00_axi_bready;
reg [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr;
reg [2 : 0] s00_axi_arprot;
reg  s00_axi_arvalid;
wire  s00_axi_arready;
wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata;
wire [1 : 0] s00_axi_rresp;
wire  s00_axi_rvalid;
reg  s00_axi_rready;


AXI_Lite_GPIO_v1_0  #( 
    .C_S00_AXI_DATA_WIDTH(32),
    .C_S00_AXI_ADDR_WIDTH(4)

)U0( 
    .s00_axi_aclk(s00_axi_aclk),
    .s00_axi_aresetn(s00_axi_aresetn),
    .s00_axi_awaddr(s00_axi_awaddr),
    .s00_axi_awprot(s00_axi_awprot),
    .s00_axi_awvalid(s00_axi_awvalid),
    .s00_axi_awready(s00_axi_awready),  // output   
    .s00_axi_wdata(s00_axi_wdata),
    .s00_axi_wstrb(s00_axi_wstrb),
    .s00_axi_wvalid(s00_axi_wvalid),
    .s00_axi_wready(s00_axi_wready),    // output
    .s00_axi_bresp(s00_axi_bresp),      // output
    .s00_axi_bvalid(s00_axi_bvalid),    // output
    .s00_axi_bready(s00_axi_bready),
    .s00_axi_araddr(s00_axi_araddr),
    .s00_axi_arprot(s00_axi_arprot),
    .s00_axi_arvalid(s00_axi_arvalid),
    .s00_axi_arready(s00_axi_arready),  // output
    .s00_axi_rdata(s00_axi_rdata),      // output
    .s00_axi_rresp(s00_axi_rresp),      // output
    .s00_axi_rvalid(s00_axi_rvalid),    // output
    .s00_axi_rready(s00_axi_rready)
);

integer i;

initial    
begin
    s00_axi_aclk = 0;
    s00_axi_aresetn = 0;
    
    s00_axi_awprot = 0;
    
    i = 0;
    #20 
    s00_axi_aresetn = 1;
    for(i=0;i<=32'hF;i=i+1)	
        #20 axi_write(32'd15,i);	//write i to slv_reg0
    $finish;     
end


always  begin
    #5  s00_axi_aclk = !s00_axi_aclk;
end

task    axi_write;
input   [31:0]    addr;
input   [31:0]    data;
begin
    #3  
    s00_axi_awaddr <= addr;
    s00_axi_wdata <= data;
    s00_axi_awvalid <= 1;
    s00_axi_wvalid <= 1;
    s00_axi_bready <= 1;
    s00_axi_wstrb <= 4'hF;  // Write all 4 Bytes (32 bits)
    
    wait(s00_axi_awready || s00_axi_wready);
    
    @(posedge s00_axi_aclk)   
    if (s00_axi_awready && s00_axi_wready)    begin
        s00_axi_awvalid <= 0;
        s00_axi_wvalid <= 0;
    end
    else    begin
        if(s00_axi_wready)    //case data handshake completed
        begin
            s00_axi_wvalid<=0;
            wait(s00_axi_awready); //wait for address address ready
        end
        else if(s00_axi_awready)   //case address handshake completed
        begin
            s00_axi_wvalid<=0;
            wait(s00_axi_wready); //wait for data ready
        end 
        @ (posedge s00_axi_aclk);// complete the second handshake
        s00_axi_awvalid<=0; //make sure both valid signals are deasserted
        s00_axi_wvalid<=0;            
    end
    
    //both handshakes have occured
    //deassert strobe
    s00_axi_wstrb<=0;

    //wait for valid response
    wait(s00_axi_bvalid);
    
    //both handshake signals and rising edge
    @(posedge s00_axi_aclk);

    //deassert ready for response
    s00_axi_bready<=0;    
    
    
end
endtask



endmodule
