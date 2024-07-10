{admcab.i}
if not connected("ITIM") 
then connect itim -N tcp -S sitim -H 10.2.0.54 .

run itim/concilia.p .

if connected("ITIM")
then disconnect itim
