{admcab.i}
def var vlvist      like plani.platot.
def var vlpraz      like plani.platot.
def var vlentr      like plani.platot.
def var vlpres      like plani.platot.
def var vljuro      like plani.platot.
def var vldesc      like plani.platot.
def var vlpred      like plani.platot.
def var vljurpre    like plani.platot.
def var vlsubtot    like plani.platot.
def var vtot        like plani.platot.
def var ct-vist     as   int.
def var ct-praz     as   int.
def var ct-entr     as   int.
def var ct-pres     as   int.
def var ct-juro     as   int.
def var ct-desc     as   int.
def var vetbcod     like estab.etbcod.

def var vcxa        like plani.cxacod.
def var vdt like plani.pladat.
update vdt
	vetbcod label "Estabelecimento"
	with frame f1 side-label centered width 55 1 column.
find estab where estab.etbcod = vetbcod no-lock.
assign  vlpraz  = 0
	vlvist  = 0
	vlentr  = 0
	vlpres  = 0
	vljuro  = 0
	vldesc  = 0
	ct-pres = 0
	ct-juro = 0
	ct-desc = 0
	ct-vist = 0
	ct-praz = 0.
for each plani where plani.movtdc = 5
		     plani.etbcod = vetbcod and
		     plani.pladat = vdt.
    if plani.crecod = 1
    then
	assign
	    ct-vist = ct-vist + 1
	    vlvist = vlvist + plani.platot.
    else
	assign
	    ct-praz = ct-praz + 1
	    vlpraz = vlpraz + plani.platot.
end.

for each titulo where titulo.empcod = wempre.empcod and
		      titulo.titnat = no and
		      titulo.modcod = "CRE" and
		      titulo.etbcod = vetbcod and
		      titulo.titdtemi = vdt and
		      titulo.titpar = 0.
	ct-entr = ct-entr + 1.
	vlentr = vlentr + titulo.titvlcob.
end.
for each titulo where titulo.empcod = wempre.empcod and
		      titulo.titnat = no and
		      titulo.modcod = "CRE" and
		      titulo.titdtpag = vdt and
		      titulo.titpar > 0
		      use-index titdtpag:
    if titulo.clifor = 1 then next.

    vlpres = vlpres + titulo.titvlcob.
    vljuro = vljuro + titulo.titjuro.
    vldesc = vldesc + titulo.titdesc.
    ct-pres = ct-pres + if titulo.titvlcob > 0
			then 1
			else 0.
    ct-juro = ct-juro + if titulo.titjuro > 0
			then 1
			else 0.
    ct-desc = ct-desc + if titulo.titdesc > 0
			then 1
			else 0.
end.

display "Valor" at 25 space(3)
	"Qdt" skip(1)
	vlpraz label "1.Venda a Prazo"  space(5) ct-praz   no-label  skip
	vlvist label "2.Venda a Vista"  space(5) ct-vist   no-label  skip
	vlentr label "3.Entrada      "  space(5) ct-entr   no-label  skip
	vlpres label "4.Prestacoes   "  space(5) ct-pres   no-label  skip
	vljuro label "5.Juros        "  space(5) ct-juro   no-label  skip
	vldesc label "6.Descontos    "  space(5) ct-desc   no-label  skip(1)
	vlvist + vlentr + vlpres + vljuro - vldesc format "z,zzz,zz9.99"
	       label "  TOTAL   "
	with side-label frame f2 centered.

message "Imprimir o Relatorio ?" update sresp.

if not sresp
then
    leave.


{mdadmcab.i &Saida     = "printer"
	    &Page-Size = "64"
	    &Cond-Var  = "80"
	    &Page-Line = "66"
	    &Nom-Rel   = ""CONCXA1""
	    &Nom-Sis   = """SISTEMA FINANCEIRO"""
	    &Tit-Rel   = """CONFERENCIA DE DOCUMENTOS - GERAL "" +
			    string(vdt) "
	    &Width     = "80"
	    &Form      = "frame f-cabcab"}

display "Valor" at 25 space(3)
	"Qdt" skip(1)
	vlpraz label "1.Venda a Prazo"  space(5) ct-praz   no-label  skip
	vlvist label "2.Venda a Vista"  space(5) ct-vist   no-label  skip
	vlentr label "3.Entrada      "  space(5) ct-entr   no-label  skip
	vlpres label "4.Prestacoes   "  space(5) ct-pres   no-label  skip
	vljuro label "5.Juros        "  space(5) ct-juro   no-label  skip
	vldesc label "6.Descontos    "  space(5) ct-desc   no-label  skip(1)
	vlvist + vlentr + vlpres + vljuro - vldesc format "z,zzz,zz9.99"
	       label "  TOTAL  CAIXA " skip(3)
	"_______________" @ vlpred   label "Pre-datados    " skip(2)
	"_______________" @ vljurpre label "Juros Pre      " skip(2)
	/*vlpred + vljurpre*/
	"_______________" @ vlsubtot label "Sub-total      " skip(2)
	"_______________" label "Pagamentos    " skip(2)
	"_______________" @ vtot     label "TOTAL          "
	with side-label frame f3 column 25.

output close.
