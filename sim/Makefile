# This Makefile is used for simulation testing.
# Simulation is done using the program ghdl. It may be available
# in your OS repository, otherwise it may be downloaded from here:
# https://github.com/ghdl/ghdl

SRC = ../src
SOURCES  = $(SRC)/cdc.vhd
SOURCES += $(SRC)/pulse_conv.vhd
SOURCES += $(SRC)/cdc_vector.vhd

TB_SOURCES  = sim_gen_data.vhd
TB_SOURCES += sim_verify_data.vhd


##################################################################
# Simulation
##################################################################

cdc_vector: $(SOURCES) $(TB_SOURCES) cdc_vector_tb.vhd
	ghdl -i --std=08 $(SOURCES)
	ghdl -i --std=08 $(TB_SOURCES)
	ghdl -i --std=08 cdc_vector_tb.vhd
	ghdl -m --std=08 $@_tb
	ghdl -r $@_tb --wave=$@.ghw --stop-time=100us
	gtkwave $@.ghw $@_tb.gtkw

gen_verify_data: $(SOURCES) $(TB_SOURCES) gen_verify_data_tb.vhd
	ghdl -i --std=08 $(SOURCES)
	ghdl -i --std=08 $(TB_SOURCES)
	ghdl -i --std=08 gen_verify_data_tb.vhd
	ghdl -m --std=08 $@_tb
	ghdl -r $@_tb --wave=$@.ghw --stop-time=100us
	gtkwave $@.ghw $@_tb.gtkw


##################################################################
# Cleanup
##################################################################

clean:
	rm -rf *.o
	rm -rf work-obj08.cf
	rm -rf cdc_vector.ghw
	rm -rf cdc_vector_tb
	rm -rf gen_verify_data.ghw
	rm -rf gen_verify_data_tb


