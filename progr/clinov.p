{admcab.i}
def var vdti   like clien.dtcad label "Data Inicial".
def var vdtf   like clien.dtcad label "Data Final  ".

update vdti skip
       vdtf with frame fdat centered side-labels color white/red ROW 10.

    {mdadmcab.i
	&Saida     = "printer"
	&Page-Size = "60"
	&Page-Line = "66"
	&Cond-Var  = "110"
	&Width     = "110"
	&Nom-Rel   = """CLIENTES NOVOS"""
	&Nom-Sis   = """SISTEMA CREDIARIO"""
	&Tit-Rel   = """LISTA DE CLIENTES NOVOS"""
	&Form      = "frame f-cabcab"}

for each clien where clien.dtcad >= vdti and
		     clien.dtcad <= vdtf:

    display skip(1)
	    clien.clicod
	    clien.clinom
	    with frame f1 centered no-box side-label width 100.


end.
