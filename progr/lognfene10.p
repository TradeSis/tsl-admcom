
def var vpropath as char format "x(150)".

input from ..\propath no-echo. 
   set vpropath with width 200 no-box frame ff.
input close.

propath = vpropath + ",\dlc".
{l:\progr\admcab.i new}
run nfene.p.
