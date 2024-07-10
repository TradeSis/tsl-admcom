/*----------------------------------------------------------------------------*/
/* /usr/admger/graficp.i                        Rotina de geracao de Graficos */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
def var gi as i.
def var gj as i.
form " " with width 80 down row 4 title "{1}" frame graf.
view frame graf.
if mx = 0
    then do gi = 1 to nx:
	mx = max(mx,vx[gi]).
    end.
gi = 1.
do while integer(mx) > 999999999:
    gi = gi * 10.
    mx = mx / 10.
end.
if gi <> 1
    then do:
    put screen row 5 column 3 "{2}" + " X " + string(gi).
    do gj = 1 to nx:
	vx[gj] = vx[gj] / gi.
    end.
    end.
    else put screen row 5 column 3 "{2}".
put screen row 20 column 3 substr("{3}",1,10).
gj = 12.
do gi = 6 to 17:
    put screen row gi column 3 string(gj * (mx / 12),">>>,>>>,>>9").
    gj = gj - 1.
end.
do gi = 1 to nx:
    do gj = 1 to 3:
	put screen row 17 + gj column 15 - integer(60 / nx)
	    + gi * integer(60 / nx) substring(lx[gi],gj,1).
    end.
    do gj = 1 to vx[gi] / (mx / 12):
	put screen color message row 18 - gj  column 15 - integer(60 / nx)
	    + gi * integer(60 / nx) fill(" ",integer(60 / nx)).
    end.
end.
vx = 0.
mx = 0.
nx = 0.
pause.

