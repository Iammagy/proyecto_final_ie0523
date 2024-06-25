generador:
	iverilog -o tb.vvp tb_generador.v 
	vvp tb.vvp
	gtkwave tb.vcd

receptor:
	iverilog -o tb.vvp tb_receptor.v 
	vvp tb.vvp
	gtkwave tb.vcd

clean:
	rm -rf tb.vcd tb.vvp
