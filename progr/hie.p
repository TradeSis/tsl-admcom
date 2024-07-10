{admcab.i}
repeat:
def var vdata as date.
def buffer bhiest for hiest.
def var vest as dec.
def var i as i.
def var vprocod like produ.procod.
    update vprocod with frame f1 side-label width 80.

for each produ where produ.procod = vprocod no-lock:
    display produ.pronom no-label with frame f1.
    for each estab no-lock:
	i = 0.
	do i = 3 to 10:
	    find bhiest where bhiest.etbcod = estab.etbcod and
			      bhiest.procod = produ.procod and
			      bhiest.hiemes = i            and
			      bhiest.hieano = 1998 no-error.
	    if not avail bhiest
	    then do:
		create bhiest.
		assign bhiest.procod = produ.procod
		       bhiest.etbcod = estab.etbcod
		       bhiest.hiemes = i
		       bhiest.hieano = 1998.
	    end.
	    bhiest.hiestf = 0.
	end.
	do vdata = 03/01/98 to (04/01/98 - 1):
	    for each movim where movim.etbcod = estab.etbcod and
				 movim.procod = produ.procod and
				 movim.movdat = vdata no-lock:

		if movim.movtdc = 6
		then do:
		    find first plani where plani.etbcod = movim.etbcod and
			       plani.placod = movim.placod no-lock.

		    find hiest where hiest.etbcod = plani.emite         and
				     hiest.procod = movim.procod        and
				     hiest.hiemes = 3                   and
				     hiest.hieano =  1998.
		    hiest.hiestf = hiest.hiestf - movim.movqtm.

		    find bhiest where bhiest.etbcod = plani.desti         and
				      bhiest.procod = movim.procod        and
				      bhiest.hiemes = 3                   and
				      bhiest.hieano =  1998 no-error.
		    bhiest.hiestf = bhiest.hiestf + movim.movqtm.

		end.
		else do:
		    find hiest where hiest.etbcod = estab.etbcod and
				     hiest.procod = produ.procod and
				     hiest.hiemes = 3            and
				     hiest.hieano = 1998.

		    if movim.movtdc = 4 or
		       movim.movtdc = 1 or
		       movim.movtdc = 7 or
		       movim.movtdc = 12 or
		       movim.movtdc = 15 or
		       movim.movtdc = 17
		    then hiest.hiestf = hiest.hiestf + movim.movqtm.

		    if movim.movtdc = 5 or
		       movim.movtdc = 13 or
		       movim.movtdc = 14 or
		       movim.movtdc = 16 or
		       movim.movtdc = 8  or
		       movim.movtdc = 18
		    then hiest.hiestf = hiest.hiestf - movim.movqtm.
		end.
	    end.
	end.

	do vdata = 04/01/98 to (05/01/98 - 1):
	    for each movim where movim.etbcod = estab.etbcod and
				 movim.procod = produ.procod and
				 movim.movdat = vdata no-lock:
		if movim.movtdc = 6
		then do:
		    find first plani where plani.etbcod = movim.etbcod and
			       plani.placod = movim.placod no-lock.

		    find hiest where hiest.etbcod = plani.emite         and
				     hiest.procod = movim.procod        and
				     hiest.hiemes = 4                   and
				     hiest.hieano =  1998.
		    hiest.hiestf = hiest.hiestf - movim.movqtm.

		    find bhiest where bhiest.etbcod = plani.desti         and
				      bhiest.procod = movim.procod        and
				      bhiest.hiemes = 4                   and
				      bhiest.hieano =  1998 no-error.
		    bhiest.hiestf = bhiest.hiestf + movim.movqtm.

		end.
		else do:
		    find hiest where hiest.etbcod = estab.etbcod and
				     hiest.procod = produ.procod and
				     hiest.hiemes = 4            and
				     hiest.hieano = 1998.

		    if movim.movtdc = 4 or
		       movim.movtdc = 1 or
		       movim.movtdc = 7 or
		       movim.movtdc = 12 or
		       movim.movtdc = 15 or
		       movim.movtdc = 17
		    then hiest.hiestf = hiest.hiestf + movim.movqtm.

		    if movim.movtdc = 5 or
		       movim.movtdc = 13 or
		       movim.movtdc = 14 or
		       movim.movtdc = 16 or
		       movim.movtdc = 8  or
		       movim.movtdc = 18
		    then hiest.hiestf = hiest.hiestf - movim.movqtm.
		end.
	    end.
	end.

	do vdata = 05/01/98 to (06/01/98 - 1):
	    for each movim where movim.etbcod = estab.etbcod and
				 movim.procod = produ.procod and
				 movim.movdat = vdata no-lock:

		if movim.movtdc = 6
		then do:
		    find first plani where plani.etbcod = movim.etbcod and
			       plani.placod = movim.placod no-lock.

		    find hiest where hiest.etbcod = plani.emite         and
				     hiest.procod = movim.procod        and
				     hiest.hiemes = 5                   and
				     hiest.hieano =  1998.
		    hiest.hiestf = hiest.hiestf - movim.movqtm.

		    find bhiest where bhiest.etbcod = plani.desti         and
				      bhiest.procod = movim.procod        and
				      bhiest.hiemes = 5                   and
				      bhiest.hieano =  1998 no-error.
		    bhiest.hiestf = bhiest.hiestf + movim.movqtm.

		end.
		else do:
		    find hiest where hiest.etbcod = estab.etbcod and
				     hiest.procod = produ.procod and
				     hiest.hiemes = 5            and
				     hiest.hieano = 1998.

		    if movim.movtdc = 4 or
		       movim.movtdc = 1 or
		       movim.movtdc = 7 or
		       movim.movtdc = 12 or
		       movim.movtdc = 15 or
		       movim.movtdc = 17
		    then hiest.hiestf = hiest.hiestf + movim.movqtm.

		    if movim.movtdc = 5 or
		       movim.movtdc = 13 or
		       movim.movtdc = 14 or
		       movim.movtdc = 16 or
		       movim.movtdc = 8  or
		       movim.movtdc = 18
		    then hiest.hiestf = hiest.hiestf - movim.movqtm.
		end.


	    end.
	end.
	do vdata = 06/01/98 to (07/01/98 - 1):
	    for each movim where movim.etbcod = estab.etbcod and
				 movim.procod = produ.procod and
				 movim.movdat = vdata no-lock:

		if movim.movtdc = 6
		then do:
		    find first plani where plani.etbcod = movim.etbcod and
			       plani.placod = movim.placod no-lock.

		    find hiest where hiest.etbcod = plani.emite         and
				     hiest.procod = movim.procod        and
				     hiest.hiemes = 6                   and
				     hiest.hieano =  1998.
		    hiest.hiestf = hiest.hiestf - movim.movqtm.

		    find bhiest where bhiest.etbcod = plani.desti         and
				      bhiest.procod = movim.procod        and
				      bhiest.hiemes = 6                   and
				      bhiest.hieano =  1998 no-error.
		    bhiest.hiestf = bhiest.hiestf + movim.movqtm.

		end.
		else do:
		    find hiest where hiest.etbcod = estab.etbcod and
				     hiest.procod = produ.procod and
				     hiest.hiemes = 6            and
				     hiest.hieano = 1998.

		    if movim.movtdc = 4 or
		       movim.movtdc = 1 or
		       movim.movtdc = 7 or
		       movim.movtdc = 12 or
		       movim.movtdc = 15 or
		       movim.movtdc = 17
		    then hiest.hiestf = hiest.hiestf + movim.movqtm.

		    if movim.movtdc = 5 or
		       movim.movtdc = 13 or
		       movim.movtdc = 14 or
		       movim.movtdc = 16 or
		       movim.movtdc = 8  or
		       movim.movtdc = 18
		    then hiest.hiestf = hiest.hiestf - movim.movqtm.
		end.

	    end.
	end.

	do vdata = 07/01/98 to (08/01/98 - 1):
	    for each movim where movim.etbcod = estab.etbcod and
				 movim.procod = produ.procod and
				 movim.movdat = vdata no-lock:
		if movim.movtdc = 6
		then do:
		    find first plani where plani.etbcod = movim.etbcod and
			       plani.placod = movim.placod no-lock.

		    find hiest where hiest.etbcod = plani.emite         and
				     hiest.procod = movim.procod        and
				     hiest.hiemes = 7                   and
				     hiest.hieano =  1998.
		    hiest.hiestf = hiest.hiestf - movim.movqtm.

		    find bhiest where bhiest.etbcod = plani.desti         and
				      bhiest.procod = movim.procod        and
				      bhiest.hiemes = 7                   and
				      bhiest.hieano =  1998 no-error.
		    bhiest.hiestf = bhiest.hiestf + movim.movqtm.

		end.
		else do:
		    find hiest where hiest.etbcod = estab.etbcod and
				     hiest.procod = produ.procod and
				     hiest.hiemes = 7            and
				     hiest.hieano = 1998.

		    if movim.movtdc = 4 or
		       movim.movtdc = 1 or
		       movim.movtdc = 7 or
		       movim.movtdc = 12 or
		       movim.movtdc = 15 or
		       movim.movtdc = 17
		    then hiest.hiestf = hiest.hiestf + movim.movqtm.

		    if movim.movtdc = 5 or
		       movim.movtdc = 13 or
		       movim.movtdc = 14 or
		       movim.movtdc = 16 or
		       movim.movtdc = 8  or
		       movim.movtdc = 18
		    then hiest.hiestf = hiest.hiestf - movim.movqtm.
		end.


	    end.
	end.

	do vdata = 08/01/98 to (09/01/98 - 1):
	    for each movim where movim.etbcod = estab.etbcod and
				 movim.procod = produ.procod and
				 movim.movdat = vdata no-lock:
		if movim.movtdc = 6
		then do:
		    find first plani where plani.etbcod = movim.etbcod and
			       plani.placod = movim.placod no-lock.

		    find hiest where hiest.etbcod = plani.emite         and
				     hiest.procod = movim.procod        and
				     hiest.hiemes = 8                   and
				     hiest.hieano =  1998.
		    hiest.hiestf = hiest.hiestf - movim.movqtm.

		    find bhiest where bhiest.etbcod = plani.desti         and
				      bhiest.procod = movim.procod        and
				      bhiest.hiemes = 8                   and
				      bhiest.hieano =  1998 no-error.
		    bhiest.hiestf = bhiest.hiestf + movim.movqtm.

		end.
		else do:
		    find hiest where hiest.etbcod = estab.etbcod and
				     hiest.procod = produ.procod and
				     hiest.hiemes = 8            and
				     hiest.hieano = 1998.

		    if movim.movtdc = 4 or
		       movim.movtdc = 1 or
		       movim.movtdc = 7 or
		       movim.movtdc = 12 or
		       movim.movtdc = 15 or
		       movim.movtdc = 17
		    then hiest.hiestf = hiest.hiestf + movim.movqtm.

		    if movim.movtdc = 5 or
		       movim.movtdc = 13 or
		       movim.movtdc = 14 or
		       movim.movtdc = 16 or
		       movim.movtdc = 8  or
		       movim.movtdc = 18
		    then hiest.hiestf = hiest.hiestf - movim.movqtm.
		end.


	    end.
	end.

	do vdata = 09/01/98 to (10/01/98 - 1):
	    for each movim where movim.etbcod = estab.etbcod and
				 movim.procod = produ.procod and
				 movim.movdat = vdata no-lock:
		if movim.movtdc = 6
		then do:
		    find first plani where plani.etbcod = movim.etbcod and
			       plani.placod = movim.placod no-lock.

		    find hiest where hiest.etbcod = plani.emite         and
				     hiest.procod = movim.procod        and
				     hiest.hiemes = 9                   and
				     hiest.hieano =  1998.
		    hiest.hiestf = hiest.hiestf - movim.movqtm.

		    find bhiest where bhiest.etbcod = plani.desti         and
				      bhiest.procod = movim.procod        and
				      bhiest.hiemes = 9                   and
				      bhiest.hieano =  1998 no-error.
		    bhiest.hiestf = bhiest.hiestf + movim.movqtm.

		end.
		else do:
		    find hiest where hiest.etbcod = estab.etbcod and
				     hiest.procod = produ.procod and
				     hiest.hiemes = 9            and
				     hiest.hieano = 1998.

		    if movim.movtdc = 4 or
		       movim.movtdc = 1 or
		       movim.movtdc = 7 or
		       movim.movtdc = 12 or
		       movim.movtdc = 15 or
		       movim.movtdc = 17
		    then hiest.hiestf = hiest.hiestf + movim.movqtm.

		    if movim.movtdc = 5 or
		       movim.movtdc = 13 or
		       movim.movtdc = 14 or
		       movim.movtdc = 16 or
		       movim.movtdc = 8  or
		       movim.movtdc = 18
		    then hiest.hiestf = hiest.hiestf - movim.movqtm.
		end.


	    end.
	end.
	do vdata = 10/01/98 to today:
	    for each movim where movim.etbcod = estab.etbcod and
				 movim.procod = produ.procod and
				 movim.movdat = vdata no-lock:
		if movim.movtdc = 6
		then do:
		    find first plani where plani.etbcod = movim.etbcod and
			       plani.placod = movim.placod no-lock.

		    find hiest where hiest.etbcod = plani.emite         and
				     hiest.procod = movim.procod        and
				     hiest.hiemes = 10                  and
				     hiest.hieano =  1998.
		    hiest.hiestf = hiest.hiestf - movim.movqtm.

		    find bhiest where bhiest.etbcod = plani.desti         and
				      bhiest.procod = movim.procod        and
				      bhiest.hiemes = 10                  and
				      bhiest.hieano =  1998 no-error.
		    bhiest.hiestf = bhiest.hiestf + movim.movqtm.

		end.
		else do:
		    find hiest where hiest.etbcod = estab.etbcod and
				     hiest.procod = produ.procod and
				     hiest.hiemes = 10           and
				     hiest.hieano = 1998.

		    if movim.movtdc = 4 or
		       movim.movtdc = 1 or
		       movim.movtdc = 7 or
		       movim.movtdc = 12 or
		       movim.movtdc = 15 or
		       movim.movtdc = 17
		    then hiest.hiestf = hiest.hiestf + movim.movqtm.

		    if movim.movtdc = 5 or
		       movim.movtdc = 13 or
		       movim.movtdc = 14 or
		       movim.movtdc = 16 or
		       movim.movtdc = 8  or
		       movim.movtdc = 18
		    then hiest.hiestf = hiest.hiestf - movim.movqtm.
		end.
	    end.
	end.
	vest = 0.
	do i = 3 to 10:
	    find hiest where hiest.etbcod = estab.etbcod and
			     hiest.procod = produ.procod and
			     hiest.hiemes = i            and
			     hiest.hieano = 1998 no-error.
	    hiest.hiestf = hiest.hiestf + vest.
	    vest = hiest.hiestf.
	end.
    end.
end.
end.
