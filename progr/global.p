{admcab.i}
def var vdata   like globa.glodat.
def var vvalor  like globa.gloval format ">>>,>>9.99".
def var vcota   like globa.glocot.
def var vgrupo  like globa.glogr.
def var vpar    like globa.glopar.
repeat:
    find estab where estab.etbcod = setbcod no-lock.
    display estab.etbcod
	    estab.etbnom no-label
		with frame f-estab width 80 color message side-label.

    assign vpar    = ""
	   vvalor  = 0
	   vgrupo  = ""
	   vcota   = "".

    update vpar  column-label "Parcela" format "999/999"
	   vvalor label "Valor Documento"
	   vgrupo label "Grupo"
	   vcota  column-label "Cota" format "999.9"
		with frame f1 centered color white/cyan.
    find globa where globa.etbcod = setbcod and
		     globa.glodat = today   and
		     globa.glogr  = vgrupo  and
		     globa.glocot = vcota   and
		     globa.glopar = vpar no-error.
    if not avail globa
    then do:
	create globa.
	assign globa.etbcod = setbcod
	       globa.glodat = today
	       globa.gloval = vvalor
	       globa.glopar = vpar
	       globa.glogr  = vgrupo
	       globa.glocot = vcota.
    end.
    else message "Documento ja digitado".
end.
