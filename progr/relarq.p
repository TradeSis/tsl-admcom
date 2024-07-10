{admcab.i}
DEF VAR VARQUIVO AS CHAR.
def var vsubtot     like titulo.titvlcob.
def var vetbcod     like estab.etbcod.
def var vdtini      as date label "Data Inicial".
def var vdtfin      as date label "Data Final".

def buffer btitulo for titulo.
def buffer bestab for estab.
update vetbcod
/*prompt-for estab.etbcod*/ colon 20
       with frame f1 side-label width 80 color white/cyan row 4.
if vetbcod > 0
then do:
find bestab where bestab.etbcod = vetbcod no-lock.
display bestab.etbnom no-label with frame f1.
end.
update vdtini colon 20
       vdtfin colon 60 with frame f1.

if opsys = "UNIX"
then varquivo = "/admcom/relat/" + STRING(TIME) + ".arq".
else varquivo = "..~\relat~\" + STRING(TIME) + ".arq".

{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "97"
    &Page-Line = "66"
    &Nom-Rel   = """RELARQ"""
    &Nom-Sis   = """SISTEMA CREDIARIO"""
    &Tit-Rel   = """RELATORIO PARA ARQUIVAMENTO FILIAL "" /* +
                        string(bestab.etbcod) + "" - "" + bestab.etbnom +
                        ""  -  PERIODO DE "" + string(vdtini) + "" A "" +
                                               string(vdtfin)*/ "
    &Width     = "97"
    &Form      = "frame f-cab"}

VSUBTOT = 0.
FIND REGIAO OF ESTAB.

disp with frame f1.
for each estab where (if vetbcod > 0
                      then estab.etbcod = vetbcod else true) no-lock:
for each titulo use-index titdtpag where
         titulo.empcod   = wempre.empcod and
         titulo.titnat   = no            and
         titulo.modcod   = "CRE"         and
         titulo.titdtpag = ?             and
         titulo.etbcod   = estab.etbcod  and
         titulo.titdtemi >= vdtini and
         titulo.titdtemi <= vdtfin          no-lock
                                     break  by titulo.etbcod
                                            /*by titulo.titdtemi*/
                                           by int(titulo.titnum) .

    if last-of(int(titulo.titnum))
    then do:
        find contrato where contrato.contnum = int(titulo.titnum) no-lock
                                                                  no-error.
        if not avail contrato
        then do:
            for each btitulo where btitulo.empcod  = titulo.empcod  and
                                   btitulo.titnat  = titulo.titnat  and
                                   btitulo.modcod  = titulo.modcod  and
                                   btitulo.etbcod  = titulo.etbcod  and
                                   btitulo.clifor  = titulo.clifor  and
                                   btitulo.titnum  = titulo.titnum  no-lock.
                vsubtot = vsubtot + btitulo.titvlcob.
            end.
        end.
        find first contnf where contnf.etbcod = contrato.etbcod and
                                contnf.contnum = contrato.contnum
                                    no-lock no-error.
        if avail contnf
        then find first plani where plani.etbcod = contnf.etbcod and
                                    plani.placod = contnf.placod
                                        no-lock no-error.
        if avail contrato
        then vsubtot = contrato.vltotal .

        find clien where clien.clicod = titulo.clifor no-lock no-error.
        display
            titulo.etbcod   column-label "Fil"
            titulo.titdtemi    column-label "Dt.Venda"
            titulo.titnum      column-label "Contr."   format "x(10)"
            plani.numero    format ">>>>>>>9"   
            column-label "Nota" when avail plani
            titulo.clifor      column-label "Cod."                 (count)
            clien.clinom when avail clien column-label "Nome do Cliente"
            vsubtot(total)
            column-label "Valor Contrato"
            with width 180 .
        vsubtot = 0.
    end.
end.
end.
output close.

/**
message "Imprime o Arquivo" varquivo "?" update sresp.
if sresp
then dos silent value("type " + varquivo + " > prn").
**/

if opsys = "UNIX"
then do:
    run visurel.p(input varquivo, input "").
end.
else do:    
{mrod.i}
end.
