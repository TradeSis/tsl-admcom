def var vtot as i format ">>>>>>>>>9".
def var vtit1 as i format ">>>>>>>>>9".
def var vtit2 as i format ">>>>>>>>>9".
def stream stela to terminal.

vtot = 0.

output to titulo01.d .

for each titulo no-lock:

    vtot = vtot + 1.

    if vtot <= 10000000
    then export titulo.
    
    disp stream stela vtot with 1 down. pause 0. 

end.

output close. 
	

