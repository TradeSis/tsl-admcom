{admcab.i}
def var varquivo as char.
def stream stela.
def var vprocod like produ.procod.
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vetbcod like estab.etbcod.
def workfile wf-produ
    field procod like produ.procod
    field clicod like clien.clicod
    field clinom like clien.clinom
    field fone   like clien.fone
    field qtd    like movim.movqtm
    field numero like plani.numero
    field etbcod like plani.etbcod.

form vprocod
     vdtini label "Data Inicial"
     vdtfin label "Data Final"
     with frame f-produ
     side-label row 4 col 6 color blue/white.

repeat:
    for each wf-produ:
        delete wf-produ.
    end.
    update vprocod
           vdtini
           vdtfin with frame f-produ.
    update vetbcod label "Filial" with frame f-produ.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f-produ.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom no-label with frame f-produ.
    end.
           
    find produ where produ.procod = vprocod no-lock no-error.
    if not avail produ
    then do:
       message "Produto nao cadastrado!".
       leave.
    end.
 
    disp produ.pronom 
         with frame f-prod side-label width 78 .
 
    for each movim use-index datsai where 
                         movim.movtdc = 5 and
                         movim.procod = vprocod and
                         movim.movdat >= vdtini and
                         movim.movdat <= vdtfin and
                         ( if vetbcod = 0
                           then true
                           else movim.etbcod = vetbcod) no-lock.

        find first plani where plani.etbcod = movim.etbcod and
                               plani.pladat = movim.movdat and
                               plani.placod = movim.placod and
                               plani.pladat = movim.movdat no-lock no-error.
        if not avail plani
        then next.
        else do:
            find clien where clien.clicod = plani.desti no-lock no-error.
            if not avail clien
            then next.
        end.
        find first wf-produ where wf-produ.clicod = clien.clicod no-error.
        if not avail wf-produ
        then do:
            create wf-produ.
            assign
                wf-produ.clicod = clien.clicod
                wf-produ.clinom = clien.clinom
                wf-produ.fone   = clien.fone
                wf-produ.procod = produ.procod
                wf-produ.numero = plani.numero
                wf-produ.etbcod = plani.etbcod.
        end.
        wf-produ.qtd = wf-produ.qtd + movim.movqtm.
    end.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/con-4" + string(day(today)).
    else varquivo = "l:\relat\con-4" + string(day(today)).
                
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""consulta""
        &Nom-Sis   = """SISTEMA DE VENDA"""
        &Tit-Rel   = """PRODUTO: "" + string(produ.procod,""999999"")
                        + "" - "" + string(produ.pronom,""x(30)"") + "" Fil. ""
                        + string(vetbcod) + "" PERIODO DE: "" +
                        string(vdtini,""99/99/9999"") + 
                      "" ATE "" + string(vdtfin,""99/99/9999"") " 
        &Width     = "130"
        &Form      = "frame f-cabcab"}
    output stream stela to terminal.
    for each wf-produ by wf-produ.clinom.
        /*
        disp stream stela 
             wf-produ.etbcod column-label "Fl" format ">>9"
             wf-produ.clicod column-label "Cliente"
             wf-produ.clinom format "x(30)"
             wf-produ.fone format "X(10)"
             wf-produ.numero column-label "Numero" format ">9999999"
             wf-produ.qtd(total) column-label "Qtd" format ">>>9"
                    with frame f1 down. 
        */
        disp 
             wf-produ.etbcod column-label "Fl" format ">>9"
             wf-produ.clicod 
             wf-produ.clinom format "x(50)"
             wf-produ.fone format "X(10)"
             wf-produ.numero column-label "Numero" format ">9999999"
             wf-produ.qtd(total) column-label "Qtd" 
                with frame f2 down width 200. 
     
             
    end.
    output stream stela close.
    output close.
    /*
    message "Deseja Imprimir" update sresp.
    if sresp
    then dos silent value("type " + varquivo + "  > prn").
    */
    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else do:
         {mrod.i}.
    end.

end.
