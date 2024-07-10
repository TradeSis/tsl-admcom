{admcab.i}

def var varqsai as char.
def var esqcom  as char extent 2 init ["Produtos","NCMS"].

def temp-table tt-ncm
    field ncm      as char
    field alpis    as dec
    field alcofins as dec.

def temp-table tt-produ
    field procod as int
    field ncm    as char
    field sit    as char.

varqsai = "/admcom/relat/aud_ncm" + string(time).

disp esqcom with frame f-menu centered no-label.
choose field esqcom with frame f-menu.
if frame-index = 1
then run produtos.
else run ncms.

procedure ncms.

input from /admcom/audit/Relacao_NCM_pis_cofins.txt.
repeat.
    create tt-ncm.
    import delimiter ";" tt-ncm.
end.
input close.


{mdad.i
       &Saida     = "value(varqsai)"
       &Page-Size = "0"
       &Cond-Var  = "96"
       &Page-Line = "0"
       &Nom-Rel   = ""aud_ncm""
       &Nom-Sis   = """SISTEMA FISCAL"""
       &Tit-Rel   = """IMPORTACAO DE NCMS"""
       &Width     = "96"
       &Form      = "frame f-cabcab"}

for each tt-ncm where tt-ncm.ncm <> "" no-lock.
    tt-ncm.ncm = replace(tt-ncm.ncm, ".", "").
    find clafis where clafis.codfis = int(tt-ncm.ncm) no-lock no-error.
    if not avail clafis
    then next.
    if clafis.pisent    = tt-ncm.alpis and
       clafis.pissai    = tt-ncm.alpis and
       clafis.cofinsent = tt-ncm.alcofins and
       clafis.cofinssai = tt-ncm.alcofins
    then next.

    disp
        clafis.codfis
        clafis.pisent
        clafis.cofinsent
        clafis.pissai
        clafis.cofinssai
        "|"
        tt-ncm.alpis label "PIS Importar"
        tt-ncm.alcofins label "COFINS Importar"
        with frame f-lin-n down no-box width 136.
end.

output close.
run visurel.p (input varqsai, input "").

end procedure.


procedure produtos.

input from /admcom/audit/Relacao_codproduto_NCM.txt.
repeat.
    create tt-produ.
    import delimiter ";" tt-produ .
end.
input close.

{mdad.i
       &Saida     = "value(varqsai)"
       &Page-Size = "0"
       &Cond-Var  = "96"
       &Page-Line = "0"
       &Nom-Rel   = ""aud_ncm""
       &Nom-Sis   = """SISTEMA FISCAL"""
       &Tit-Rel   = """IMPORTACAO DE NCMS"""
       &Width     = "96"
       &Form      = "frame f-cabcab"}

for each tt-produ where tt-produ.procod > 0.
    find produ where produ.procod = tt-produ.procod no-lock.
    tt-produ.ncm = replace(tt-produ.ncm, ".", "").

    if produ.codfis = int(tt-produ.ncm)
    then assign
            tt-produ.sit = "Igual".

    else if produ.codfis > 0 and produ.codfis <> 99999999
    then assign
            tt-produ.sit = "Diferente".

    else if produ.codfis = 0 or produ.codfis = 99999999
    then assign
            tt-produ.sit = "Importar".
end.

for each tt-produ where tt-produ.procod > 0,
    produ where produ.procod = tt-produ.procod no-lock            
                break by tt-produ.sit
                      by produ.pronom.
    if first-of(tt-produ.sit)
    then put skip(1).
    disp
        tt-produ.sit
        produ.procod format ">>>>>>>9"
        produ.pronom
        produ.codfis format ">>,>>,>>,>>" (count by tt-produ.sit)
        int(tt-produ.ncm) label "Importar" format ">>,>>,>>,>>" 
        with frame f-lin down no-box width 106.
end.

output close.
run visurel.p (input varqsai, input "").

end procedure.