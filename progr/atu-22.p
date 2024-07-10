DEF BUFFER BESTOQ FOR ESTOQ.
DEF BUFFER xESTOQ FOR ESTOQ.
def input parameter vrecmov as recid.
def input parameter vtipo   as char.
def input parameter vqtd    as i.

find movim where recid(movim) = vrecmov.

if movim.movtdc = 6
then do:

    find first plani where plani.etbcod = movim.etbcod and
			   plani.placod = movim.placod no-lock.

    /**************  TRANSFERENCIA - SAIDA ******************/
    find estoq where estoq.etbcod = plani.emite and
		     estoq.procod = movim.procod no-error.
    if not avail estoq
    then do:
	find first xestoq where xestoq.procod = movim.procod no-lock.
	create estoq.
	assign estoq.etbcod = plani.emite
	       estoq.procod = movim.procod
	       estoq.estcusto = xestoq.estcusto
	       estoq.estvenda = xestoq.estvenda.
    end.

    if vtipo = "I"
    then estoq.estatual = estoq.estatual - movim.movqtm.
    if vtipo = "E"
    then estoq.estatual = estoq.estatual + movim.movqtm.
    if vtipo = "A"
    then estoq.estatual = estoq.estatual + vqtd - movim.movqtm.

    find hiest where hiest.etbcod = plani.emite         and
		     hiest.procod = movim.procod        and
		     hiest.hiemes = month(plani.pladat) and
		     hiest.hieano =  year(plani.pladat) no-error.
    if not avail hiest
    then do:
	create hiest.
	assign hiest.etbcod = plani.emite
	       hiest.procod = movim.procod
	       hiest.hiemes = month(plani.pladat)
	       hiest.hieano =  year(plani.pladat).
    end.
    hiest.hiestf = estoq.estatual.

    /******************** FIM TRANSFERENCIA - SAIDA ***************/


    /******************** TRANSFERENCIA - ENTRADA *****************/

    find bestoq where bestoq.etbcod = plani.desti and
		      bestoq.procod = movim.procod no-error.
    if not avail bestoq
    then do:
	find first xestoq where xestoq.procod = movim.procod no-lock.
	create bestoq.
	assign bestoq.etbcod = plani.desti
	       bestoq.procod = movim.procod
	       bestoq.estcusto = xestoq.estcusto
	       bestoq.estvenda = xestoq.estvenda.
    end.
    if vtipo = "I"
    then bestoq.estatual = bestoq.estatual + movim.movqtm.
    if vtipo = "E"
    then bestoq.estatual = bestoq.estatual - movim.movqtm.
    if vtipo = "A"
    then  bestoq.estatual = bestoq.estatual - vqtd + movim.movqtm.

    find hiest where hiest.etbcod = plani.desti         and
		     hiest.procod = movim.procod        and
		     hiest.hiemes = month(plani.pladat) and
		     hiest.hieano =  year(plani.pladat) no-error.
    if not avail hiest
    then do:
	create hiest.
	assign hiest.etbcod = plani.desti
	       hiest.procod = movim.procod
	       hiest.hiemes = month(plani.pladat)
	       hiest.hieano =  year(plani.pladat).
    end.
    hiest.hiestf = bestoq.estatual.

    /****************** FIM TRANSFERENCIA - ENTRADA *****************/

end.
    /********************** INICIO ENTRADA **********************/
if movim.movtdc = 4 or
   movim.movtdc = 1 or
   movim.movtdc = 7 or
   movim.movtdc = 12 or
   movim.movtdc = 15 or
   movim.movtdc = 17
then do:
    find estoq where estoq.etbcod = movim.etbcod and
		     estoq.procod = movim.procod no-error.
    if not avail estoq
    then do:
	find first xestoq where xestoq.procod = movim.procod no-lock.
	create estoq.
	assign estoq.etbcod = movim.etbcod
	       estoq.procod = movim.procod
	       estoq.estcusto = xestoq.estcusto
	       estoq.estvenda = xestoq.estvenda.
    end.
    if vtipo = "I"
    then estoq.estatual = estoq.estatual + movim.movqtm.
    if vtipo = "E"
    then estoq.estatual = estoq.estatual - movim.movqtm.
    if vtipo = "A"
    then  estoq.estatual = estoq.estatual - vqtd + movim.movqtm.

    /*
    if movim.movtdc = 4
    then estoq.estcusto = movim.movpc.
    */

    find hiest where hiest.etbcod = movim.etbcod        and
		     hiest.procod = movim.procod        and
		     hiest.hiemes = month(movim.movdat) and
		     hiest.hieano =  year(movim.movdat) no-error.
    if not avail hiest
    then do:
	create hiest.
	assign hiest.etbcod = movim.etbcod
	       hiest.procod = movim.procod
	       hiest.hiemes = month(movim.movdat)
	       hiest.hieano =  year(movim.movdat).
    end.
    hiest.hiestf = estoq.estatual.
    if movim.movtdc = 4 or
       movim.movtdc = 1
    then do:
	find himov where himov.etbcod = movim.etbcod        and
			 himov.movtdc = 4                   and
			 himov.procod = movim.procod        and
			 himov.himmes = month(movim.movdat) and
			 himov.himano =  year(movim.movdat) no-error.
	if not avail himov
	then do:
	    create himov.
	    assign himov.etbcod = movim.etbcod
		   himov.movtdc = 4
		   himov.procod = movim.procod
		   himov.himmes = month(movim.movdat)
		   himov.himano =  year(movim.movdat).
	end.
	if vtipo = "I"
	then himov.himqtm = himov.himqtm + movim.movqtm.
	if vtipo = "E"
	then himov.himqtm = himov.himqtm - movim.movqtm.
	if vtipo = "A"
	then  himov.himqtm = himov.himqtm - vqtd + movim.movqtm.
    end.
end.
    /**************************  FIM ENTRADA ************************/


    /*********************** INICIO SAIDA ***********************/
if movim.movtdc = 5 or
   movim.movtdc = 13 or
   movim.movtdc = 14 or
   movim.movtdc = 16 or
   movim.movtdc = 8  or
   movim.movtdc = 18
then do:

    find estoq where estoq.etbcod = movim.etbcod and
		     estoq.procod = movim.procod no-error.
    if not avail estoq
    then do:
	find first xestoq where xestoq.procod = movim.procod no-lock.
	create estoq.
	assign estoq.etbcod = movim.etbcod
	       estoq.procod = movim.procod
	       estoq.estcusto = xestoq.estcusto
	       estoq.estvenda = xestoq.estvenda.
    end.
    if vtipo = "I"
    then estoq.estatual = estoq.estatual - movim.movqtm.
    if vtipo = "E"
    then estoq.estatual = estoq.estatual + movim.movqtm.
    if vtipo = "A"
    then  estoq.estatual = estoq.estatual + vqtd - movim.movqtm.

    find hiest where hiest.etbcod = movim.etbcod        and
		     hiest.procod = movim.procod        and
		     hiest.hiemes = month(movim.movdat) and
		     hiest.hieano =  year(movim.movdat) no-error.
    if not avail hiest
    then do:
	create hiest.
	assign hiest.etbcod = movim.etbcod
	       hiest.procod = movim.procod
	       hiest.hiemes = month(movim.movdat)
	       hiest.hieano =  year(movim.movdat).
    end.
    hiest.hiestf = estoq.estatual.

    if movim.movtdc = 5
    then do:
	find himov where himov.etbcod = movim.etbcod        and
			 himov.movtdc = movim.movtdc        and
			 himov.procod = movim.procod        and
			 himov.himmes = month(movim.movdat) and
			 himov.himano =  year(movim.movdat) no-error.
	if not avail himov
	then do:
	    create himov.
	    assign himov.etbcod = movim.etbcod
		   himov.movtdc = 5
		   himov.procod = movim.procod
		   himov.himmes = month(movim.movdat)
		   himov.himano =  year(movim.movdat).
	end.
	if vtipo = "I"
	then himov.himqtm = himov.himqtm + movim.movqtm.
	if vtipo = "E"
	then himov.himqtm = himov.himqtm - movim.movqtm.
	if vtipo = "A"
	then  himov.himqtm = himov.himqtm - vqtd + movim.movqtm.
    end.
end.

    /**************************** FIM SAIDA *************************/
