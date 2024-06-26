generador:
	iverilog -o tb.vvp tb_generador.v 
	vvp tb.vvp
	gtkwave generador.gtkw

receptor:
	iverilog -o tb.vvp tester_receptor.v 
	vvp tb.vvp
	gtkwave receptor.gtkw

clean:
	rm -rf tb.vcd tb.vvp
