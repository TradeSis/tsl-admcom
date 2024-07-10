{admcab.i new}

def var vetbcod like estab.etbcod.
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".

def var vtt-venda as dec.
def var vqtd-cup as int format ">>>>>9".
def var vbis as log.
def var vqt-tot as int.

update vetbcod label "Filial"
    with frame f1 side-label width 80.

if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
end.
    
update vdti at 1 label "Data inicial"
       vdtf label "Data final"
        with frame f1.

def temp-table tt-cupom
    field etbcod like estab.etbcod
    field catcod like produ.catcod
    field qtdcup as int
    index i1 etbcod catcod
     .

def var vdata as date.
def var vcatcod like produ.catcod.   
def var vpromocupfa as char.

for each estab where
     (if vetbcod > 0 then estab.etbcod = vetbcod else true) and
     estab.etbcod < 200
     no-lock.
     disp "Processando... " estab.etbcod
        with frame fdd 1 down centered row 10 no-box
        color message no-label.
     pause 0.   
     do vdata = vdti to vdtf:
        disp vdata with frame fdd.
        pause 0.
        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 5 and
                             plani.pladat = vdata
                             no-lock:

            vtt-venda = plani.protot.
			vqtd-cup = 0.
            
			if vtt-venda >= 200 
	    		then do:
	    			vbis = no.
					if plani.pedcod = 	110	or plani.pedcod = 	112	or
					plani.pedcod = 	113	or plani.pedcod = 	115	or
					plani.pedcod = 	116	or plani.pedcod = 	120	or
					plani.pedcod = 	121	or plani.pedcod = 	125	or
					plani.pedcod = 	126	or plani.pedcod = 	310	or
					plani.pedcod = 	312	or plani.pedcod = 	313	or
					plani.pedcod = 	314	or plani.pedcod = 	315	or
					plani.pedcod = 	316	or plani.pedcod = 	317	or
					plani.pedcod = 	318	or plani.pedcod = 	320	or
					plani.pedcod = 	321	or plani.pedcod = 	323	or
					plani.pedcod = 	324	or plani.pedcod = 	325	or
					plani.pedcod = 	326	or plani.pedcod = 	410	or
					plani.pedcod = 	418	or plani.pedcod = 	421	or
					plani.pedcod = 	422	or plani.pedcod = 	613	or
					plani.pedcod = 	614	or plani.pedcod = 	617	or
					plani.pedcod = 	716	or plani.pedcod = 	718	or
					plani.pedcod = 	721	or plani.pedcod = 	722	or
					plani.pedcod = 	723	or plani.pedcod = 	724	or
					plani.pedcod = 	15	or plani.pedcod = 	17	or
					plani.pedcod = 	21	or plani.pedcod = 	24	or
					plani.pedcod = 	42	or plani.pedcod = 	43	or
					plani.pedcod = 	66	or plani.pedcod = 	67	or
					plani.pedcod = 	68	or plani.pedcod = 	69	or
					plani.pedcod = 	76	or plani.pedcod = 	77	or
					plani.pedcod = 	80	or plani.pedcod = 	89	or
					plani.pedcod = 	90	or plani.pedcod = 	91	or
					plani.pedcod = 	98	or plani.pedcod = 	100	or
					plani.pedcod = 	122	or plani.pedcod = 	123	or
					plani.pedcod = 	124	or plani.pedcod = 	200	or
					plani.pedcod = 	201	or plani.pedcod = 	202	or
					plani.pedcod = 	322	or plani.pedcod = 	414	or
					plani.pedcod = 	419	or plani.pedcod = 	424	or
					plani.pedcod = 	426	or plani.pedcod = 	514	or
					plani.pedcod = 	517	or plani.pedcod = 	519	or
					plani.pedcod = 	523	or plani.pedcod = 	524	or
					plani.pedcod = 	525	or plani.pedcod = 	530	or
					plani.pedcod = 	531	or plani.pedcod = 	610	or
					plani.pedcod = 	612	or plani.pedcod = 	717 or
					plani.pedcod = 	610	or plani.pedcod = 	111	or
					plani.pedcod = 	311	or plani.pedcod = 	710	or
					plani.pedcod = 	510	or plani.pedcod = 	612	or
					plani.pedcod = 	714	or plani.pedcod = 	414	or
					plani.pedcod = 	615	or plani.pedcod = 	515	or
					plani.pedcod = 	717	or plani.pedcod = 	417	or
					plani.pedcod = 	720	or plani.pedcod = 	420	or
					plani.pedcod = 	620	or plani.pedcod = 	520	or
					plani.pedcod = 	622	or plani.pedcod = 	522	or
					plani.pedcod = 	626	or plani.pedcod = 	526	or
					plani.pedcod = 	725	or plani.pedcod = 	525
					then vbis = yes.
				end.

            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ then next.
                if vcatcod = 0
                then vcatcod = produ.catcod.
                if  vcatcod = 41 and
                    produ.catcod = 31
                then vcatcod = produ.catcod.
            end.

            vqt-tot = int(substr(string(vtt-venda / 200,">>>9.999"),1,4)).
			if vbis = no 
				then vqtd-cup = vqt-tot.
			else vqtd-cup = vqt-tot * 3. 

            find first tt-cupom where tt-cupom.etbcod = estab.etbcod and
                                      tt-cupom.catcod = vcatcod 
                                      no-error.
            if not avail tt-cupom
            then do:
                create tt-cupom.
                assign
                    tt-cupom.etbcod = estab.etbcod 
                    tt-cupom.catcod = vcatcod
                    .
            end.

            tt-cupom.qtdcup = vqtd-cup.
                    
        end.
    end.
end.                        

def var varquivo as char.

if opsys = "UNIX"
then varquivo = "/admcom/relat/relcupfa." + string(time).
else varquivo = "l:~\relat~\relcupfa." + string(time).

{mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "63" 
        &Cond-Var  = "120"  
        &Page-Line = "66"
        &Nom-Rel   = ""relmont""  
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """ CUPONS EMITIDOS PROMOCAO FINAL DE ANO 2010 """
        &Width     = "80"
        &Form      = "frame f-cabcab"}

disp with frame f1.
pause 0.

for each tt-cupom break by tt-cupom.etbcod:
    if first-of(tt-cupom.etbcod)
    then do:
        find estab where estab.etbcod = tt-cupom.etbcod no-lock.
        disp tt-cupom.etbcod column-label "Fil"
                 estab.etbnom no-label
                 with frame f-rel.
    end.
    disp tt-cupom.catcod column-label "Setor"
         tt-cupom.qtdcup column-label "Quantidade"
            (total by tt-cupom.etbcod)
         with frame f-rel down.
end.
output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
   {mrod.i}
end.
