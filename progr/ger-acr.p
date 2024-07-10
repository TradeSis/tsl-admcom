{admcab.i}

def var tmes as dec format ">>>,>>>,>>9" extent 12.
def var tfil as dec format ">>>,>>>,>>9".
def var tval as dec format ">,>>>,>>9" extent 34.
def var vval as dec format ">,>>>,>>9.99" extent 12.
def var vdev as dec format ">,>>>,>>9.99" extent 12.
def var vacr as dec format ">,>>>,>>9.99" extent 12.
def var vano as i.
def var vmes as i.
def var varquivo as char format "x(20)".
def var vcusto   like estoq.estcusto.
def var vestven  like estoq.estvenda.
def var totcusto like estoq.estcusto.
def var totvenda like estoq.estvenda.
def buffer bestoq for estoq.
def var v-ac like plani.platot.
def var v-de like plani.platot.
def buffer bcurfab for curfab.
def buffer bmovim for movim.
def var i as i.
def var tot-c like plani.platot.
def var tot-v like plani.platot format "->>9.99".
def var tot-m like plani.platot.
def var vacum like plani.platot format "->>9.99".
def var wnp as i.
def var vvltotal as dec.
def var vvlcont  as dec.
def var wacr     as dec.
def var wper     as dec.
def var valortot as dec.
def var vval1    as dec.
def var vsal     as dec.
def var vlfinan  as dec.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vvlcusto    like plani.platot column-label "Vl.Custo".
def var vvlvenda    like plani.platot column-label "Vl.Venda".
def var vvlmarg     like plani.platot column-label "Margem".
def var vvlperc     as dec format ">>9.99 %" column-label "Perc".
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vacrepre    like plani.acfprod column-label "Acr.Previsto".
def var vcatcod     like produ.catcod.
def var vcatcod2    like produ.catcod.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.

repeat:

    message "Confirma emissao de relatorio" update sresp.
    if sresp = no
    then leave.

    {mdadmcab.i
	    &Saida     = "printer"
	    &Page-Size = "64"
	    &Cond-Var  = "160"
	    &Page-Line = "66"
	    &Nom-Rel   = ""ger-acr""
	    &Nom-Sis   = """SISTEMA DE VENDAS"""
	    &Tit-Rel   = """ACRESCIMO EM GERAL DE 1998"""
	    &Width     = "160"
	    &Form      = "frame f-cabcab"}
    put skip space(10)
    "JAN" space(09)
    "FEV" space(09)
    "MAR" space(09)
    "ABR" space(09)
    "MAI" space(09)
    "JUN" space(09)
    "JUL" space(09)
    "AGO" space(09)
    "SET" space(09)
    "OUT" space(09)
    "NOV"  space(09)
    "DEZ"  space(09)
    "TOTAL"
     skip fill("-",160) format "x(160)" skip.
     for each estab where estab.etbcod <= 34 no-lock:
	put estab.etbcod.
	i = 0.
	do i = 1 to 12:
	    find first orcli where orcli.etbcod = estab.etbcod and
				   orcli.orcnum = i no-lock no-error.
		if not avail orcli
		then assign vval[i] = 0
			    vdev[i] = 0
			    vacr[i] = 0.
		else assign vval[i] = orcli.orlpreco
			    vdev[i] = orcli.orlqtd
			    vacr[i] = orcli.procod
			    tval[estab.etbcod] = tval[estab.etbcod] +
						orcli.procod
			    tfil = tfil + orcli.procod.
	end.
	i = 0.
	do i = 1 to 12:
	    put vacr[i].
	    tmes[i] = tmes[i] + vacr[i].
	    if i = 12
	    then put space(2) tval[estab.etbcod].
	end.
	put skip.
     end.
     put skip fill("-",160) format "x(160)" skip.

	put tmes[01] to 16
	    tmes[02] to 28
	    tmes[03] to 40
	    tmes[04] to 52
	    tmes[05] to 64
	    tmes[06] to 76
	    tmes[07] to 88
	    tmes[08] to 100
	    tmes[09] to 112
	    tmes[10] to 124
	    tmes[11] to 136
	    tmes[12] to 148
	    tfil     to 160 skip
     fill("-",160) format "x(160)" skip.


    output close.
end.
