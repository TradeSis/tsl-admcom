{ADMCAB.I}
def var vdtref  as date format "99/99/9999" INITIAL TODAY.
def var vsubtot  like titulo.titvlcob.
def var vetbcod like estab.etbcod.

varquivo = "..\relat\" + STRING(TIME) + ".REL".
{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "160"
    &Page-Line = "66"
    &Nom-Rel   = """BACA1"""
    &Nom-Sis   = """SISTEMA CREDIARIO"""
    &Tit-Rel   = """PARCELAS SEM CLIENTES CADASTRADOS POR LOJAS"""
    &Width     = "160"
    &Form      = "frame f-cab"}

VSUBTOT = 0.
FOR EACH REGIAO.
FOR EACH ESTAB OF REGIAO,
    each titulo use-index titdtpag where
	titulo.empcod = wempre.empcod and
	titulo.titnat = no and
	titulo.modcod = "CRE" and
	titulo.titdtpag = ? and
	titulo.etbcod = estab.etbcod no-lock.

    find clien where clien.clicod = titulo.clifor no-lock no-error.

    if not avail clien
    then do:
	display titulo.etbcod
		titulo.clifor
		titulo.titnum
		titulo.titpar
		titulo.titdtven
		titulo.titvlcob
		titsit
		titulo.titdtpag
		with frame flin width 160 no-box.
	down with frame flin.
    end.
end.
END.
