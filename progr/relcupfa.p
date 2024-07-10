{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".

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
            
            if acha("PROMOCUPFA",plani.notobs[1]) = ?
            then next.    
            vpromocupfa = acha("PROMOCUPFA",plani.notobs[1]).
            if vpromocupfa = ""
            then next.
            vcatcod = 0.
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

            tt-cupom.qtdcup = tt-cupom.qtdcup +
                    int(entry(1,vpromocupfa,";")).
                    
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
