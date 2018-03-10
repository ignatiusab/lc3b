import lc3b_types::*;

module mp3_ewb_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;
logic pmem_resp, ewb_mem_resp;
logic pmem_read, ewb_mem_read;
logic pmem_write, ewb_mem_write;
logic [15:0] pmem_address, ewb_mem_address;
logic [255:0] pmem_rdata, ewb_mem_rdata;
logic [255:0] pmem_wdata, ewb_mem_wdata;

/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;

eviction_write_buffer dut
(
	.clk,
	
	//L2 -> EWB
	.ewb_mem_read,
	.ewb_mem_write,
	.ewb_mem_address,
	.ewb_mem_wdata,
	
	//EWB -> L2
	.ewb_mem_rdata,
	.ewb_mem_resp,
	
	// Memory -> EWB
	.pmem_resp,
	.pmem_rdata,
	
	// EWB -> Memory
	.pmem_read,
	.pmem_write,
	.pmem_address,
	.pmem_wdata
);

physical_memory memory
(
    .clk,
    .read(pmem_read),
    .write(pmem_write),
    .address(pmem_address),
    .wdata(pmem_wdata),
    .resp(pmem_resp),
    .rdata(pmem_rdata)
);

initial begin: TEST_VECTORS

//INITIALIZE INPUT SIGNALS TO 0
//This is representative of the empty_buffer state for the EWB
//No reading or writing signals from L2
ewb_mem_write = 0;
ewb_mem_address = 16'd0;
ewb_mem_wdata = 256'd0;
ewb_mem_read = 0;

#15
//EWB now has to service a writeback from L2
ewb_mem_write = 1;
ewb_mem_address = 16'h0001;
ewb_mem_wdata = 256'h600d600d600d600d600d600d600d600d600d600d600d600d600d600d600d600d;
//Things that should be seen:
//	ewb_mem_resp should go high with no cycle delay indicating response to writeback
// In the next cycle, the address/data/valid bits of EWB should be updated
// Meanwhile, we should transition to hold_data stage

#10
//Simulate the immediate read that happens after the writeback has completed to get new data for L2
ewb_mem_read = 1;
ewb_mem_write = 0;
#1 ewb_mem_address = 16'h0002; //Presumably L2 supplies different address



//Should stay in hold_data state and allow pmem to respond to this read...
#49 
ewb_mem_read = 0;

#100
//Now, we should be in midst of write-back of EWB data, attempt to read data in EWB - a "hit"!
#20
ewb_mem_write = 0;
ewb_mem_read = 1;
ewb_mem_address = 16'h0001;
//should see immediate response to the read and ewb_mem_rdata should contain that x600d... signal

//Turn read signal low
#10
ewb_mem_read = 0;

//Place another write from L2 to memory; should be stalled until first write finishes!
#40
ewb_mem_write = 1;
ewb_mem_address = 16'h0002;
ewb_mem_wdata = 256'hbaadbaadbaadbaadbaadbaadbaadbaadbaadbaadbaadbaadbaadbaadbaadbaad;
#100
//At this point, the first write-back has finished, and the EWB has initiated the second write-back
//Now, we initiate a read to address not in EWB, so under our implementation:
//We cancel write to pmem and service the read, then go back to the write
ewb_mem_write = 0;
ewb_mem_read = 1;
ewb_mem_address = 16'hffff;
#100
ewb_mem_read = 0;


end
endmodule : mp3_ewb_tb
