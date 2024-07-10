{admcab.i}

def input parameter par-titulo as char.

def shared temp-table tt-aviso
    field tabela as char
    field campo  as char
    field codigo as int
    field descr  as char
    field qtde   as int
    field erro   as log
    index aviso tabela descr campo codigo.

def var varqsai as char.
def var vnome   as char.
varqsai = "/admcom/relat/aud_rlaviso" + string(time).

{mdad.i
       &Saida     = "value(varqsai)"
       &Page-Size = "0"
       &Cond-Var  = "80"
       &Page-Line = "0"
       &Nom-Rel   = ""aud_rlaviso""
       &Nom-Sis   = """SISTEMA DE ESTOQUE"""
       &Tit-Rel   = " par-titulo "
       &Width     = "136"
       &Form      = "frame f-cabcab"}

for each tt-aviso no-lock
        break by tt-aviso.descr
              by tt-aviso.tabela
              by tt-aviso.campo
              by tt-aviso.codigo.

    vnome = "".
    if tt-aviso.tabela = "clafis"
    then do.
        find first clafis where clafis.codfis = tt-aviso.codigo
                            no-lock no-error.
        if avail clafis
        then vnome = clafis.desfis.
    end.
    else if tt-aviso.tabela = "produ"
    then do.
        find produ where produ.procod = tt-aviso.codigo no-lock no-error.
        if avail produ
        then vnome = produ.pronom.
    end.
    if first-of (tt-aviso.descr)
    then put skip(1).

    disp
        tt-aviso.tabela
        tt-aviso.campo
        tt-aviso.codigo format ">>>>>>>>9"
        vnome no-label  format "x(30)"
        tt-aviso.descr  format "x(25)"
        tt-aviso.qtde   format ">>>>9"  (total by tt-aviso.descr)
        with frame f-lin down no-box width 136.
end.

output close.
run visurel.p (input varqsai, input "").
 
