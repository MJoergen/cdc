# Library for Clock Domain Crossing

This repository contains several small CDC modules:

* pulse\_conv.vhd
* cdc\_vector.vhd
* cdc.vhd

## pulse\_conv.vhd
This block is a simple pulse converter.
It accepts a pulse of a single clock cycle on the input,
and presents a pulse of a single clock cycle on the output.

It works by converting the input pulse to a level toggle,
and back again.

Note: The pulses on the input side may not be too close.

## cdc\_vector.vhd
This block is a simple one-deep asynchronous FIFO, which can be used
as a Clock Domain Crossing of a vector signal.

The handshaking protocol ensures that data is only transferred when
both valid and ready are asserted.

## cdc.vhd
This block is a simple synchronizer, used for Clock Domain Crossing.

Note: There is no parallel synchronization, so the individual bits in the
input may not be synchronized at the same time. If you require the input
vector to be synchronized in parallel, i.e. simultaneously, you should use
cdc\_vector.

## Documentation
A very good introduction to Clock Domain Crossings is
[this link](http://www.sunburst-design.com/papers/CummingsSNUG2008Boston_CDC.pdf).

