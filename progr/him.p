{admcab.i}
def var i as i.
def var vprocod like produ.procod.
def var vmes    as int format "99".
def var vano    as int format "9999".
def var vdata  as date.
def var vdata1  as date.
def var vdata2  as date.
repeat:

    update vprocod colon 15 with frame f1 side-label width 80.
    find produ where produ.procod = vprocod no-lock no-error.
    display produ.pronom no-label with frame f1.
    find last estab no-lock.
    i = 0.
    do i = 1 to int(estab.etbcod):
	for each himov where himov.etbcod = i and
			     himov.movtdc = 4 and
			     himov.procod = produ.procod:
	    delete himov.
	end.
	for each himov where himov.etbcod = i and
			     himov.movtdc = 5 and
			     himov.procod = produ.procod:
	    delete himov.
	end.
    end.

    do vdata = 03/01/98 to today:
	for each movim where movim.procod = produ.procod and
			     movim.movtdc = 4            and
			     movim.movdat = vdata no-lock:
	    do transaction:
		find himov where himov.etbcod = movim.etbcod and
				 himov.movtdc = 4            and
				 himov.procod = movim.procod and
				 himov.himmes = month(movim.movdat) and
				 himov.himano = year(movim.movdat) no-error.
		if not avail himov
		then do:
		    create himov.
		    assign himov.etbcod = movim.etbcod
			   himov.procod = movim.procod
			   himov.movtdc = 4
			   himov.himmes = month(movim.movdat)
			   himov.himano = year(movim.movdat).
		end.
		assign himov.himqtm = himov.himqtm + movim.movqtm.
	    end.
	end.
	for each movim where movim.procod = produ.procod and
			     movim.movtdc = 5            and
			     movim.movdat = vdata no-lock:
	    do transaction:
		find himov where himov.etbcod = movim.etbcod and
				 himov.movtdc = 5            and
				 himov.procod = movim.procod and
				 himov.himmes = month(movim.movdat) and
				 himov.himano = year(movim.movdat) no-error.
		if not avail himov
		then do:
		    create himov.
		    assign himov.etbcod = movim.etbcod
			   himov.procod = movim.procod
			   himov.movtdc = 5
			   himov.himmes = month(movim.movdat)
			   himov.himano = year(movim.movdat).
		end.
		assign himov.himqtm = himov.himqtm + movim.movqtm.
	    end.
	end.
    end.
end.
