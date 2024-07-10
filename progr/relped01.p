{admcab.i}
def var vdti as date.
def var vdtf as date.
def var vclacod like clase.clacod.
def var vprocod like produ.procod.
def var vfabcod like fabri.fabcod.
def buffer bprodu for produ.

update vdti label "Periodo de"
      vdtf label "Ate"
      with frame f-data.
      
update vclacod at 5 label "Classe"
        with frame f-data.
if vclacod > 0
then do:        
find clase where clase.clacod = vclacod no-lock.
disp clase.clanom no-label with frame f-data.        
end.
update vprocod at 4 label "Produto"
      with frame f-data 1 down width 80
      side-label.
if vprocod > 0
then do:
find bprodu where bprodu.procod = vprocod no-lock.
disp bprodu.pronom no-label with frame f-data.
end.
def temp-table tt-pedid
    field etbcod like estab.etbcod
    field procod like produ.procod
    field pednum like pedid.pednum
    field peddat like pedid.peddat
    field lipqtd like liped.lipqtd
    .
for each produ where (if vclacod > 0
                      then produ.clacod = vclacod else true) and
                     (if vprocod > 0
                      then produ.procod = vprocod else true)
                      no-lock:
    for each liped where liped.procod = produ.procod and
                         liped.pedtdc = 3 no-lock,
        first pedid of liped where  pedid.pednum < 100000 and
                pedid.peddat >= vdti and
                pedid.peddat <= vdtf
                no-lock:
        disp "Processando .... -->> " 
            pedid.pednum no-label with frame f-1 1 down.
        pause 0.
        find first tt-pedid where
                   tt-pedid.etbcod = pedid.etbcod and
                   tt-pedid.pednum = pedid.pednum and
                   tt-pedid.procod = liped.procod
                   no-error.
        if not avail tt-pedid
        then do:
            create tt-pedid.
            assign
                tt-pedid.etbcod = pedid.etbcod 
                tt-pedid.pednum = pedid.pednum
                tt-pedid.procod = liped.procod
                tt-pedid.peddat = pedid.peddat
                .
        end. 
        tt-pedid.lipqtd = tt-pedid.lipqtd + liped.lipqtd.
    end.
end.
form tt-pedid.etbcod column-label "Fil"
     tt-pedid.procod column-label "Produto"
     produ.pronom no-label format "x(35)"
     tt-pedid.pednum column-label "Pedido"
     tt-pedid.peddat column-label "DataPed." format "99/99/99"
     tt-pedid.lipqtd column-label "Qtd.Ped." format ">>>9"
     with frame f-disp down.

def var varquivo as char.
 
    if opsys = "UNIX"
    then varquivo = "../relat/ped" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999")
                                       + "." + string(time).
    else varquivo = "..\relat\ped" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999")
                                       + "." + string(time).
                                  
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""ctpromoc"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """LISTAGEM DE PEDIDOS""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

DISP WITH FRAME F-DATA. 
for each tt-pedid break by tt-pedid.etbcod 
                        by tt-pedid.procod
                        by tt-pedid.peddat with frame f-disp:
    find produ where produ.procod = tt-pedid.procod no-lock.
    if first-of(tt-pedid.etbcod)
    then disp tt-pedid.etbcod.
    if first-of(tt-pedid.procod)
    then do:
        disp tt-pedid.procod
             produ.pronom.
    end.
    
    disp tt-pedid.pednum
         tt-pedid.peddat
         tt-pedid.lipqtd .
    DOWN.
    if last-of(tt-pedid.etbcod)
    then do:
        put fill("-",80) format "x(80)".
    end.     
end.             
output close.
    
    IF opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"") .
    end.
    else do:
        {mrod.i}
    end.

