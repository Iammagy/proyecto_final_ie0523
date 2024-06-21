banco:
	iverilog -o tb.vvp testbench1.v 
	vvp tb.vvp
	gtkwave tb.vcd

clean:
	rm -rf tb.vcd tb.vvp
