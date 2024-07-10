{admcab.i}

def var vdatref as date.
vdatref = today. 
def var vetbcod like estab.etbcod.
update vetbcod label "Filial" with frame f1.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if avail estab
    then disp estab.etbnom no-label with frame f1.
    else return.
end.    
else disp "Todas as filiais" @ estab.etbnom with frame f1.
       
update vdatref at 1 label "Data Referencia" with frame f1 width 80 side-label 1 down.

def var varquivo as char.

varquivo = "/admcom/relat/relredzfaltantes" + "." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""relredzfaltantes"" 
                &Nom-Sis   = """SISTEMA FISCAL""" 
                &Tit-Rel   = """ RELATORIO RED Z """ 
                &Width     = "100"
                &Form      = "frame f-cabcab"}

    disp with frame f1.
 
for each estab where (if vetbcod > 0
                    then estab.etbcod = vetbcod else true) no-lock:
    for each mapcxa where mapcxa.etbcod = estab.etbcod and
                          mapcxa.datmov = vdatref no-lock by int(de3).
        disp mapcxa.etbcod column-label "Fil"
             mapcxa.cxacod column-label "Cxa"
             int(mapcxa.de1)    column-label "Equip" format ">>9"
             mapcxa.ch1 column-label "Serie"  format "x(25)"
             int(mapcxa.de3) column-label "Red!Restantes"
             mapcxa.nrored
             mapcxa.nroseq
            /*mapcxa.cooini
            mapcxa.coofin*/ 
            .
    end.
end.
 
output close.
run visurel.p(varquivo,"").
