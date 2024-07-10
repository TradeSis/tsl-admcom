/*
10.06.19 - Agenda financeiro
*/
{admcab.i}

{filtro-estab.def}

def var voperacao as char init "P45".
def var vdtini   as date.
def var vdtfim   as date.
def var vtiporel as log format "Analitico/Sintetico" init yes.
def var vtitrel  as char.
def var varquivo as char.

def temp-table tt-resumo no-undo
    field etbcod like estab.etbcod
    field Valor  as dec format ">>>,>>>,>>9.99"    
    index estab is primary unique etbcod.

form
    vEstab   colon 31 label "Todos Estabelecimentos"
             help "Relatorio com Todos os Estabelecimentos ?"
    cestab   no-label format "x(30)"
    vdtini   colon 31 label "Data do Lancamento"
    vdtfim   label "ate"
    vtiporel colon 31    label "Analitico / Sintetico"
    with frame fopcoes row 3 side-label width 80 title pdvtmov.ctmnom.

find pdvtmov where pdvtmov.ctmcod = voperacao no-lock.

do on error undo with frame fopcoes.
    {filtro-estab.i}
    update
        vdtini validate (vdtini <> ?, "")
        vdtfim validate (vdtfim <> ?, "").
    if vDtFim < vDtIni
    then do:
        message "Data invalida" view-as alert-box.
        undo.
    end.
    update vtiporel.
end.

varquivo = "/admcom/relat/rlp2koper." + string(mtime).
vtitrel = pdvtmov.ctmnom + " De: " + string(vdtini) + " Ate " + string(vdtfim).
{mdadmcab.i &Saida     = "value(varquivo)"   
            &Page-Size = "64"  
            &Cond-Var  = "80"
            &Page-Line = "66" 
            &Nom-Rel   = ""rlp2koper"" 
            &Nom-Sis   = """ """ 
            &Tit-Rel   = " vtitrel "
            &Width     = "80"
            &Form      = "frame f-cabcab"}

for each cmon where no-lock.
        if not vEstab
        then do:
            find wfEstab where wfEstab.Etbcod = Estab.Etbcod no-lock no-error.
            if not avail wfEstab
            then next.
        end.
  
    for each pdvmov where pdvmov.etbcod = cmon.etbcod
                      and pdvmov.cmocod = cmon.cmocod
                      and pdvmov.datamov >= vdtini
                      and pdvmov.datamov <= vdtfim
                      and pdvmov.ctmcod = voperacao
                      and pdvmov.statusoper = "FEC"
                      no-lock
                      break by pdvmov.etbcod.
        if not vtiporel
        then do.
            find tt-resumo where tt-resumo.etbcod = pdvmov.etbcod no-error.
            if not avail tt-resumo
            then do.
                create tt-resumo.
                tt-resumo.etbcod = pdvmov.etbcod.
            end.
            tt-resumo.valor = tt-resumo.valor + pdvmov.valortot.
        end.
        else
            disp
                pdvmov.etbcod
                cmon.cxacod
                pdvmov.datamov
                string(int(pdvmov.datamov), "hh:mm:ss")
                pdvmov.sequencia
                pdvmov.valortot (total by pdvmov.etbcod)
                with frame f_analitico down.

    end.
end.

if not vtiporel
then
    for each tt-resumo no-lock break by tt-resumo.etbcod.
        disp
            tt-resumo.etbcod
            tt-resumo.valor (total)
            with frame f_resumo down.
    end.

output close.

run visurel.p(varquivo,"").

