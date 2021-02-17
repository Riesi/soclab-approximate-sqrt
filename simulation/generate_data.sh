#!/bin/bash
cp ../vhdl-src/sqrt/* ./

echo "testing csm"
mkdir csm
cp testbench.vhd ./csm/
cp approx_root_engine.vhd ./csm/
cp CSM* ./csm/
cd csm

grep -v 'library ieee_proposed;' CSM.vhd > CSM2.vhd
grep -v 'library ieee_proposed;' CSM_beh.vhd > CSM_beh2.vhd

ghdl -a testbench.vhd approx_root_engine.vhd CSM2.vhd CSM_beh2.vhd
ghdl -r testbench

cd ..
# done with CSM_SQRT

echo "testing lin"
mkdir lin
cp testbench.vhd ./lin/
cp approx_root_engine.vhd ./lin/
cp LS_beh.vhd ./lin/
cd lin

grep -v 'library ieee_proposed;' LS_beh.vhd > LS_beh2.vhd
head -n +70 LS_beh2.vhd > LS_beh2.vhd

ghdl -a testbench.vhd approx_root_engine.vhd LS_beh2.vhd
ghdl -r testbench

cd ..
# done with LIN_SQRT
head -n +7 LS_beh.vhd > LS_beh_square.vhd
tail -n +71 LS_beh.vhd >> LS_beh_square.vhd

echo "testing square"
mkdir square
cp testbench.vhd ./square/
cp approx_root_engine.vhd ./square/
cp LS_beh_square.vhd ./square/
cd square

ghdl -a testbench.vhd approx_root_engine.vhd LS_beh_square.vhd
ghdl -r testbench

cd ..
# done with SQUARE_SQRT

echo "testing quake"
mkdir quake
cp testbench.vhd ./quake/
cp approx_root_engine.vhd ./quake/
cp QUAKE_beh.vhd ./quake/
cd quake

grep -v 'library ieee_proposed;' QUAKE_beh.vhd > QUAKE_beh2.vhd

ghdl -a testbench.vhd approx_root_engine.vhd QUAKE_beh2.vhd
ghdl -r testbench

cd ..
# done with QUAKE_SQRT
