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

SRC_CLK_PERIOD ?= 10
DST_CLK_PERIOD ?= 11
RATE_GEN       ?= 14
RATE_VERIFY    ?= 13

GENERICS += -gG_SRC_CLK_PERIOD=$(SRC_CLK_PERIOD)
GENERICS += -gG_DST_CLK_PERIOD=$(DST_CLK_PERIOD)
GENERICS += -gG_RATE_GEN=$(RATE_GEN)
GENERICS += -gG_RATE_VERIFY=$(RATE_VERIFY)


##################################################################
# Simulation
##################################################################

test_all:
	rm cdc_vector.ghw; make SRC_CLK_PERIOD=10 DST_CLK_PERIOD=91 cdc_vector.ghw
	rm cdc_vector.ghw; make SRC_CLK_PERIOD=10 DST_CLK_PERIOD=81 cdc_vector.ghw
	rm cdc_vector.ghw; make SRC_CLK_PERIOD=10 DST_CLK_PERIOD=71 cdc_vector.ghw
	rm cdc_vector.ghw; make SRC_CLK_PERIOD=10 DST_CLK_PERIOD=61 cdc_vector.ghw
	rm cdc_vector.ghw; make SRC_CLK_PERIOD=10 DST_CLK_PERIOD=51 cdc_vector.ghw
	rm cdc_vector.ghw; make SRC_CLK_PERIOD=10 DST_CLK_PERIOD=41 cdc_vector.ghw
	rm cdc_vector.ghw; make SRC_CLK_PERIOD=10 DST_CLK_PERIOD=31 cdc_vector.ghw
	rm cdc_vector.ghw; make SRC_CLK_PERIOD=10 DST_CLK_PERIOD=21 cdc_vector.ghw
	rm cdc_vector.ghw; make SRC_CLK_PERIOD=10 DST_CLK_PERIOD=11 cdc_vector.ghw
	rm cdc_vector.ghw; make SRC_CLK_PERIOD=10 DST_CLK_PERIOD=9  cdc_vector.ghw
	rm cdc_vector.ghw; make SRC_CLK_PERIOD=20 DST_CLK_PERIOD=9  cdc_vector.ghw
	rm cdc_vector.ghw; make SRC_CLK_PERIOD=30 DST_CLK_PERIOD=9  cdc_vector.ghw
	rm cdc_vector.ghw; make SRC_CLK_PERIOD=40 DST_CLK_PERIOD=9  cdc_vector.ghw
	rm cdc_vector.ghw; make RATE_GEN=15 RATE_VERIFY=1  cdc_vector.ghw
	rm cdc_vector.ghw; make RATE_GEN=1  RATE_VERIFY=15 cdc_vector.ghw
	rm cdc_vector.ghw; make RATE_GEN=15 RATE_VERIFY=14 cdc_vector.ghw
	rm cdc_vector.ghw; make RATE_GEN=14 RATE_VERIFY=15 cdc_vector.ghw

show: cdc_vector.ghw
	gtkwave cdc_vector.ghw cdc_vector_tb.gtkw

cdc_vector.ghw: cdc_vector_tb
	ghdl -r $< --wave=$@ $(GENERICS) --stop-time=100us

cdc_vector_tb: $(SOURCES) $(TB_SOURCES) cdc_vector_tb.vhd
	ghdl -i --std=08 $(SOURCES)
	ghdl -i --std=08 $(TB_SOURCES)
	ghdl -i --std=08 $@.vhd
	ghdl -m --std=08 $@

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


