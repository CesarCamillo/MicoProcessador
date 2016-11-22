#!/bin/bash

## ------------------------------------------------------------------------
## UFPR, BCC, ci210 2016-2 trabalho semestral, autor: Roberto Hexsel, 07out
## ------------------------------------------------------------------------

## ESTE ARQUIVO NAO PODE SER ALTERADO


# set -x

trab=mico

src="packageWires mem aux $trab tb_${trab}"
sim=$trab
simulator=tb_${sim}
visual=v_${sim}.vcd
save=v.sav

length=65
unit=n

usage() {
cat << EOF
usage:  $0 [options] 
        re-create simulator/model and run simulation

OPTIONS:
   -h    Show this message
   -t T  number of time-units to run (default ${length})
   -u U  unit of time scale {m,u,n,p} (default ${unit}s)
   -n    send simulator output do /dev/null, else to $visual
   -w    invoke GTKWAVE -- do not use with -n
EOF
}

while true ; do

    case "$1" in
        -h | "-?") usage ; exit 1
            ;;
        -t) length=$2
            shift
            ;;
        -u) unit=$2
            shift
            ;;
        -n) visual=/dev/null
            ;;
        -w) WAVE=true
            ;;
        -x) set -x
            ;;
        *) break
            ;;
    esac
    shift
done


# compila simulador
ghdl --clean

ghdl -a --ieee=standard -fexplicit packageWires.vhd || exit 1

for F in ${src} ; do
    if [ ! -s ${F}.o  -o  ${F}.vhd -nt ${F}.o ] ; then
        ghdl -a --ieee=standard ${F}.vhd  ||  exit 1
    fi
done

ghdl -c packageWires.vhd {aux,mem}.vhd ${sim}.vhd tb_${sim}.vhd \
     -e ${simulator} || exit 1

./$simulator --ieee-asserts=disable --stop-time=${length}${unit}s \
           --vcd=${visual}

test -v $WAVE  ||  gtkwave -O /dev/null ${visual} ${save}

