{admcab.i}

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vesc as char format "x(15)" extent 2
    init ["Por Numero","Por NCM"].

form estab.etbcod
     estab.etbnom no-label
     forne.forcod at 1 format ">>>>>>>>>9"
     forne.fornom no-label
     vdti at 1 label "Periodo"
     vdtf no-label
     with frame f1 side-label width 80 no-validate
     .
     
prompt-for estab.etbcod with frame f1.
find estab where estab.etbcod = input frame f1 estab.etbcod
                no-lock.
disp estab.etbnom with frame f1.                
prompt-for forne.forcod with frame f1.
find forne where forne.forcod = input frame f1 forne.forcod
            no-lock .
disp forne.fornom with frame f1.   
update vdti vdtf with frame f1.
        
def var vindex as int.
disp vesc with frame f-esc 1 down centered no-label.
choose field vesc with frame f-esc.
vindex = frame-index.

def temp-table tt-nota
         field numero like plani.numero
         field codfis like produ.codfis
         field valor as dec
         field situacao as char
         index i1 numero codfis
         .

def temp-table tt-ncm
         field codfis like produ.codfis
         field valor as dec
         index i1 codfis
         .

/************    
for each plani where
         plani.etbcod = estab.etbcod and 
         plani.desti  = forne.forcod and
         plani.pladat >= vdti and
         plani.pladat <= vdtf
            no-lock.

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc
                         no-lock:
        if movim.movpc = 0 or movim.movqtm = 0
        then next.
        find produ where produ.procod = movim.procod no-lock no-error.
        if not avail produ then next.
        find first tt-ncm where tt-ncm.codfis = produ.codfis no-error.
        if not avail tt-ncm
        then do:
            create tt-ncm.
            tt-ncm.codfis = produ.codfis.
        end.
        tt-ncm.valor = tt-ncm.valor +
                (movim.movpc * movim.movqtm).

        find first  tt-nota where 
                    tt-nota.numero = plani.numero and
                    tt-nota.codfis = produ.codfis no-error.
        if not avail tt-nota
        then do:
            create tt-nota.
            tt-nota.numero = plani.numero.
            tt-nota.codfis = produ.codfis.
        end.
        tt-nota.valor = tt-nota.valor +
                (movim.movpc * movim.movqtm).

    end.
end.         
******************/

for each placon where
         placon.etbcod = estab.etbcod and 
         placon.desti  = forne.forcod and
         placon.pladat >= vdti and
         placon.pladat <= vdtf
         no-lock.

    find first a01_infnfe where
               a01_infnfe.etbcod = placon.etbcod and
               a01_infnfe.numero = placon.numero and
               a01_infnfe.serie  = placon.serie
                no-lock no-error.
    if not avail a01_infnfe or
        a01_infnfe.situacao = ""
    then next.
                
    find first movcon where movcon.etbcod = placon.etbcod and
                         movcon.placod = placon.placod and
                         movcon.movtdc = placon.movtdc 
                         no-lock no-error.
    if avail movcon
    then do:
    for each movcon where movcon.etbcod = placon.etbcod and
                         movcon.placod = placon.placod and
                         movcon.movtdc = placon.movtdc 
                         no-lock:
        if movcon.movpc = 0 or movcon.movqtm = 0
        then next.
        find produ where produ.procod = movcon.procod no-lock no-error.
        if not avail produ then next.
        find first tt-ncm where tt-ncm.codfis = produ.codfis no-error.
        if not avail tt-ncm
        then do:
            create tt-ncm.
            tt-ncm.codfis = produ.codfis.
        end.
        tt-ncm.valor = tt-ncm.valor +
                (movcon.movpc * movcon.movqtm).

        find first  tt-nota where 
                    tt-nota.numero = placon.numero and
                    tt-nota.codfis = produ.codfis no-error.
        if not avail tt-nota
        then do:
            create tt-nota.
            tt-nota.numero = placon.numero.
            tt-nota.codfis = produ.codfis.
            tt-nota.situacao = a01_infnfe.situacao.
        end.
        tt-nota.valor = tt-nota.valor +
                (movcon.movpc * movcon.movqtm).

    end.
    end.
    else do:
        find first tt-ncm where tt-ncm.codfis = 99999999 no-error.
        if not avail tt-ncm
        then do:
            create tt-ncm.
            tt-ncm.codfis = 99999999.
        end.
        tt-ncm.valor = tt-ncm.valor + placon.protot.

        find first  tt-nota where 
                    tt-nota.numero = placon.numero and
                    tt-nota.codfis = 99999999 no-error.
        if not avail tt-nota
        then do:
            create tt-nota.
            tt-nota.numero = placon.numero.
            tt-nota.codfis = 99999999.
            tt-nota.situacao = a01_infnfe.situacao.
        end.
        tt-nota.valor = tt-nota.valor + placon.protot.

    end.
end. 
   
def var varquivo as char.            
def var varq-csv as char.
varquivo = "/admcom/relat/ncm-valor-" + string(time) + ".txt".
varq-csv = "/admcom/relat/ncm-valor-" + string(time) + ".csv".

    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "100"
            &Page-Line = "66"
            &Nom-Rel   = ""relcob""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE""" 
            &Tit-Rel   = """ VALOR NCM - PERIODO "" +
                            string(vdti,""99/99/9999"") + ""  "" + 
                            string(vdtf,""99/99/9999"") "
            &Width     = "100"
            &Form      = "frame f-cabcab"}

disp with frame f1.

if vindex = 1
then
for each tt-nota:
    disp forne.forcgc
         forne.fornom
         tt-nota.numero format ">>>>>>>>9"
         tt-nota.codfis format ">>>>>>>>>9"
         tt-nota.valor (total)  format ">>,>>>,>>9.99"    
         tt-nota.situacao format "x(15)"
         with frame f-disp1 width 120 down.
         down with frame f-disp1.
end.             
else if vindex = 2
then
for each tt-ncm:

    disp forne.forcgc
         forne.fornom
         tt-ncm.codfis format ">>>>>>>>>9"
         tt-ncm.valor (total)  format ">>,>>>,>>9.99"    
         with frame f-disp2 width 100 down.
         down with frame f-disp2.
            
end.            

output close.

output to value(varq-csv).

if vindex = 1
then do:
    put "CNPJ;NUMERO;NCM;VALOR" SKIP.
for each tt-nota:
    put unformatted
         forne.forcgc ";"
         tt-nota.numero format ">>>>>>>>9" ";"
         tt-nota.codfis format ">>>>>>>>>9" ";"
         replace(string(tt-nota.valor,">>>>>>>>>>9.99"),".",",")  ";"
         tt-nota.situacao format "x(15)"
         skip.
end.  
end.
else if vindex = 2
then DO:
    PUT "CNPJ;NCM;VALOR" skip.
for each tt-ncm.
    put unformatted
        forne.forcgc ";"
        tt-ncm.codfis ";"
        replace(string(tt-ncm.valor,">>>>>>>>>>9.99"),".",",")
        skip.
end.
end.
output close.

message color red/with
    "Arquivo CSV gerado:" skip
    varq-csv
    view-as alert-box.
    
run visurel.p(varquivo, "").
        