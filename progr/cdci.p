{admcab.i}
def var vplatot like plani.platot.
def var vfincod like finan.fincod extent 40.
def var vlmin   like titulo.titvlcob.
def var vlmax   like titulo.titvlcob.
def var i as    i.
def var v as    i.
def var vdt     as date format "99/99/9999".
def var vdtven  as date format "99/99/9999".
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vlcont  like titulo.titvlcob.
def var vvlent   like titulo.titvlcob format ">,>>9.99".
def var vok     as l.
def var vok1    as l.
def stream      stela.
def buffer bcontnf for contnf.
def var vtotal like titulo.titvlcob.
repeat:
    update vdti label "Periodo"
	   "a"
	   vdtf no-label
	   vlmax label "Valor Maximo"
	   vlmin label "Valor Min.NF"
		with frame f-dat centered color blue/cyan row 8
				    title " Periodo ".
	update vfincod
	       no-label with frame f-planos title "PLANOS".

	{mdadmcab.i
	    &Saida     = "printer"
	    &Page-Size = "64"
	    &Cond-Var  = "160"
	    &Page-Line = "66"
	    &Nom-Rel   = ""CDCI""
	    &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
	    &Tit-Rel   = """PLANILHA DE FECHAMENTO FILIAL - "" +
			  "" VENDAS ATE  "" +
			  string(vdtf,""99/99/9999"")"
	    &Width     = "160"
	    &Form      = "frame f-cabcab"}

	vok1 = yes.
	do vdt = vdti to vdtf:
	    do i = 1 to 32:
		for each plani where plani.movtdc = 5             and
				     plani.etbcod = i             and
				     plani.pladat = vdt no-lock:

		    if plani.crecod = 1
		    then next.
		    if plani.vlserv > 0
		    then next.
		    if plani.outras > 0
		    then do:
			if plani.outras < vlmin
			then next.
		    end.
		    else do:
			if plani.platot < vlmin
			then next.
		    end.
		    find clien where clien.clicod = plani.desti
							no-lock no-error.
		    if not avail clien
		    then next.
		    if clien.ciccgc = ?
		    then next.
		    if clien.ciccgc = ""
		    then next.
		    if substring(string(clien.ciccgc),1,1) = "0"
		    then next.
		    if substring(string(clien.ciccgc),1,1) = "*"
		    then next.
		    if substring(string(clien.ciccgc),1,1) = ""
		    then next.
		    vok = yes.
		    vlcont = 0.
		    vvlent  = 0.
		    for each contnf where contnf.etbcod  = plani.etbcod and
					  contnf.placod  = plani.placod no-lock:
			find contrato where contrato.contnum = contnf.contnum
							     no-lock no-error.
			if not avail contrato
			then do:
			    vok = no.
			    leave.
			end.
			else do:
			    find finan where finan.fincod = contrato.crecod
							no-lock no-error.
			    if avail finan
			    then do:
				do v = 1 to 40:
				    if vfincod[v] = finan.fincod
				    then do:
					vok = yes.
					leave.
				    end.
				    else vok = no.
				end.
			    end.
			    if vok = no
			    then leave.
			    assign vlcont = contrato.vltotal
				   vvlent  = contrato.vlentra.
			    find first titulo where
				       titulo.empcod = 19           and
				       titulo.titnat = no           and
				       titulo.modcod = "CRE"        and
				       titulo.etbcod = plani.etbcod and
				       titulo.clifor = plani.desti  and
				       titulo.titnum =
						string(contrato.contnum) and
				       titulo.titpar = 1 no-lock no-error.
			    if not avail titulo
			    then vok = no.
			    else vdtven = titulo.titdtven.
			end.
		    end.
		    if vok = no
		    then next.

		    output stream stela to terminal.
		    disp stream stela plani.etbcod
				      plani.pladat with frame fffpla
						    centered color white/red.
		    pause 0.
		    output stream stela close.

		    vtotal = vtotal + (if plani.outras > 0
				       then plani.outras
				       else plani.platot).
		    if plani.outras > 0
		    then vplatot = plani.outras.
		    else vplatot = plani.platot.
		    display clien.clinom format "x(30)"
			    trim(clien.endereco[1] + ", " +
				 string(clien.numero[1])   + " " +
				 clien.cidade[1])
				    column-label "Endereco" format "x(40)"
			    clien.ciccgc
			    plani.numero column-label "Num.NF"
			    vplatot column-label "Valor!NF"
			    vvlent column-label "Valor!Entrada"
			    (vlcont - vvlent) column-label "Valor!Financ"
			    plani.pladat format "99/99/99"
			    vdtven column-label "1o Venc." format "99/99/99"
				    with frame f-a down width 160.
		    if vtotal > vlmax
		    then do:
			vok1 = no.
			leave.
		    end.
		    if vok1 = no
		    then leave.
		end.
		    if vok1 = no
		    then leave.
	    end.
	    if vok1 = no
	    then leave.
	end.
	/*
	display vlmax label "Total Geral" at 90
		with frame f-b width 160 side-label. */
    output close.
end.
