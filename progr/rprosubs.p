{admcab.i}

def var vdesc like produ.pronom.
def var valiq like produ.proipiper.

update vdesc label "Descricao"
       valiq label "Aliquota"
              with frame f1 1 down side-label width 80.
              
sresp = no.
message "Confirma gerar relatorio? " update sresp.
if not sresp 
then undo.
else do:              
    def var varquivo as char.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/rprosubs.txt".
    else varquivo = "l:\relat\rprosubs.txt".

    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "80"
            &Page-Line = "64"
            &Nom-Rel   = ""rprosubs""
            &Nom-Sis   = """ """
            &Tit-Rel   = """ """
            &Width     = "80"
            &Form      = "frame f-cabcab"}
     
     disp with frame f1.
     
    
    if vdesc <> ""
    then do:
        vdesc = "*" + vdesc + "*".
        for each produ where
             produ.pronom  matches vdesc
             no-lock:
            if valiq <> 0 and produ.proipiper <> valiq
            then next.
            disp    produ.procod format ">>>>>>>9"
                    produ.pronom format "x(40)"
                    produ.proipiper  column-label "Aliquota"
                    produ.prodtcad   column-label "Cadastro"
                    with frame f2 down width 80.
        end.
    end.
    else do:
        for each produ
             no-lock:
            if valiq <> 0 and produ.proipiper <> valiq
            then next.
            disp    produ.procod format ">>>>>>>9"
                    produ.pronom format "x(40)"
                    produ.proipiper    column-label "Aliquota"
                    produ.prodtcad     column-label "Cadastro"
                    with frame f3 down width 80.
        end.
    end.

    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end.
return.






