{admcab.i}
def var vdtref  as date format "99/99/9999" INITIAL TODAY.
def var vsubtot  like titulo.titvlcob.
def var vetbcod like estab.etbcod.
update vetbcod                          colon 20.
find estab where estab.etbcod = vetbcod no-error.
if not avail estab
then do:
    message "Estabelecimento Invalido" .
    undo.
end.
display estab.etbnom no-label.
update vdtref   label "Data Referencia" colon 20
       with row 4 side-label width 80 .

VSUBTOT = 0.

message "Gerando o relatorio".
def var varquivo as char.
if opsys = "LINUX"
then varquivo = "/admcom/relat/" + string(time) + ".rel".
else varquivo = "l:~\relat~\" + STRING(TIME) + ".REL".
{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "137"
    &Page-Line = "66"
    &Nom-Rel   = """POCLIET"""
    &Nom-Sis   = """SISTEMA CREDIARIO"""
    &Tit-Rel   = """POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"" +
                    ""DATA REFERENCIA"" + string(VDTREF) "
    &Width     = "137"
    &Form      = "frame f-cab"}

FIND REGIAO OF ESTAB no-lock.
for each titulo use-index titdtpag where
         titulo.empcod = wempre.empcod and
         titulo.titnat = no and
         titulo.modcod = "CRE" and
         titulo.titdtpag = ? and
         titulo.etbcod = estab.etbcod and
         can-find(clien where clien.clicod = titulo.clifor) no-lock,
    clien where clien.clicod = titulo.clifor no-lock
                              break by clien.clinom
                                by titulo.titdtven .


/*    form header skip(1)
                fill("-",137) format "x(137)"  skip
               "SUBTOTAL"
                vsubtot - titulo.titvlcob format "->,>>>,>>>,>>9.99"
                            at 95 skip
               fill("-",137)  format "x(137)"
          with frame frodape width 137 no-box no-label page-bottom.
    view frame frodape. */


    vsubtot = vsubtot + titulo.titvlcob.
    display
        titulo.etbcod    column-label "Fil."         space(3)
        clien.clinom     column-label "Nome do Cliente" space(1)
        clien.clicod     column-label "Cod."            space(3)
        titulo.titnum      column-label "Contr."
        titulo.titpar      column-label "Pr." format ">>9" space(4)
        titulo.titdtemi    column-label "Dt.Venda"   space(4)
        titulo.titdtven    column-label "Vencim."    space(3)
        titulo.titvlcob    column-label "Valor Prestacao" space(3)
        titulo.titdtven - vdtref    column-label "Dias"
        with width 180 .
    IF LAST(CLIEN.CLINOM)
    THEN PAGE.
end.
display skip(2) "TOTAL GERAL :" vsubtot with frame ff no-labels no-box.
output close.
dos silent value("type " + varquivo + " > prn").
