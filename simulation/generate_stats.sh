#!/bin/bash
echo "synth csm"
cp topo_stats_csm.ys ./csm/
cd csm

yosys topo_stats_csm.ys > csm_stats.txt

cd ..
# done with CSM_SQRT

echo "synth lin"
cp topo_stats_lin.ys ./lin/
cd lin

yosys topo_stats_lin.ys  > ls_lin_stats.txt

cd ..
# done with LIN_SQRT

echo "synth square"

cp topo_stats_square.ys ./square/

cd square

yosys topo_stats_square.ys  > ls_square_stats.txt

cd ..
# done with SQUARE_SQRT

echo "synth quake"
cp topo_stats_quake.ys ./quake/
cd quake

yosys topo_stats_quake.ys  > quake_stats.txt

cd ..
# done with QUAKE_SQRT
