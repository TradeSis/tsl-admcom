def var vpropath as char format "x(300)".

input from /usr/admcom/propath no-echo. 
    set vpropath with width 300 no-box frame ff.
input close.
propath = vpropath + ",/usr/dlc".


run /admcom/progr/atudbrp-disp.p.

quit.
