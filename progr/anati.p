/*----------------------------------------------------------------------------*/
/* /usr/admfin/anati.p                         Analise de Titulos - Grafica   */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 15/12/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
{graficd2.i}
def var wmd as l format "Meses/Dias" label "Periodo".
def var wmesi as i format   "99" label "Mes Inic".
def var wanoi as i format "9999" label "Ano Inic".
def var wmesf as i format   "99" label "Mes Fin".
def var wanof as i format "9999" label "Ano Fin".
def var wini as da label "Data Inicial".
def var wfim as da label "Data Final".
def var wmeses as c format "!!!" extent 60
	initial ["J","F","M","A","M","J","J","A","S","O","N","D",
		 "J","F","M","A","M","J","J","A","S","O","N","D",
		 "J","F","M","A","M","J","J","A","S","O","N","D",
		 "J","F","M","A","M","J","J","A","S","O","N","D",
		 "J","F","M","A","M","J","J","A","S","O","N","D"].
def var i as i.
def var c as i.
repeat with row 4 side-labels 1 down width 80 title " Analise de Titulos "
	    frame f1:
    clear frame f1 all.
    do on error undo:
	disp "" @ estab.etbcod colon 18.
	prompt-for estab.etbcod with frame f1.
	if  input estab.etbcod <> ""
	    then do:
	    find estab using  input estab.etbcod.
	    display etbnom no-label colon 30 with frame f1.
	    end.
	    else disp "TODOS" @ etbnom.
    end.
    do on error undo:
	prompt-for modal.modcod colon 18 with frame f1.
	if input modal.modcod <> ""
	    then do:
	    find modal using modal.modcod.
	    display modal.modnom no-label  with frame f1 .
	    end.
	    else disp "TODAS" @ modnom.
    end.
    update  wmd help "Informe [D] p/ Periodo em dias ou [M] p/ Meses"
		colon 18 with frame f1.
    if wmd
	then do:
	form "Periodo Inicial :" wmesi space(0) "/" space(0) wanoi
	     skip "Periodo Final   :" wmesf space(0) "/" space(0) wanof
	     with frame fmeses width 80 no-labels.
	update wmesi
	       wanoi
	       wmesf
	       wanof with frame fmeses.
	nx = ((wanof * 12) + wmesf) - ((wanoi * 12) + wmesi) + 1.
	if nx = 0 or nx > 60
	    then do:
	    message "Numero de dias para analise nao deve exceder 60.".
	    undo.
	    end.
	c = 0.
	do i = 0 to nx - 1:
	    if lookup(string((i + wmesi - 1) / 12,"9.99"),
			      "1.00,2.00,3.00,4.00,5.00") <> 0
		then c = c + 1.
	    lx[i + 1] = substr(wmeses[wmesi + i],1,1) +
			substr(string(wanoi + c,"9999"),3,2).
	end.
	end.
	else do:
	if wini = ?
	    then wini = date(month(today),01,year(today)).
	update wini colon 18
	       wfim colon 18 with frame fdias width 80 side-labels.
	if wfim = ?
	    then wfim = today.
	nx = wfim - wini + 1.
	if nx > 60
	    then do:
	    message "Numero de dias para analise nao deve exceder 60.".
	    undo.
	    end.
	do i = 0 to nx - 1:
	    lx[i + 1] = string(day(wini + i),">9") +
			substr(wmeses[month(wini + i)],1,1).
	end.
	end.
    {anati.i}
    {graficp2.i " Fluxo de Caixa " "Titulos" "Periodo" "Pagar" "Receber"}
end.
