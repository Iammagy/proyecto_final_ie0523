all:
	iverilog -o tb.vvp tb_generador.v 
	vvp tb.vvp
	gtkwave signals.gtkw

clean:
	rm -rf tb.vcd tb.vvp
