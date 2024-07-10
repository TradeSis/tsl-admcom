def var vdias       as int label "Dias".
def var vtar        as char.
def var vast        as char format "x".
def var vprog       as char format "x(60)".
def var vcomando    as char.
def var vdir        as char format "x(30)" initial "/usr/custom".
def var vtrunc      as int.
def var i           as int.

def workfile wfprog
    field programa      as char format "x(60)".

def workfile wfrec
    field rec as recid.
update vdir colon 20 label "Diretorio".
update vdias colon 20 with centered row 10 side-label.
if vdias > 0
then
    vcomando = "find " + vdir + " -mtime -" + string(vdias) + " -print > le.d".
else
    vcomando = "find " + vdir + " -mtime " + string(vdias) + " -print > le.d".
message vcomando.
vtrunc = length(vdir).
unix silent value(vcomando).

input from ./le.d no-echo.
repeat.
    set vprog.
    create wfprog.
    assign wfprog.programa = ".".
    do i = 1 to 60:
	if i <= vtrunc
	then next.
	if substr(vprog,i,60 - i) = "" then leave.
	wfprog.programa = wfprog.programa + substr(vprog,i,1).
    end.
end.

for each wfprog.
    if wfprog.programa matches "*work*" or
       wfprog.programa matches "*.db"   or
       wfprog.programa matches "*.lg"   or
       wfprog.programa matches "*.bi"   or
       wfprog.programa matches "*.sh"   or
       wfprog.programa matches "*.pf"   or
       wfprog.programa matches "*.ds"   or
       wfprog.programa matches "*.lk"   or
       wfprog.programa matches "*.r"   or
       wfprog.programa matches "*.txt"   or
       wfprog.programa matches "*.d"   or
       wfprog.programa matches "*.df"   or
       wfprog.programa matches "*bkp*"   or
       wfprog.programa matches "*bases*"   or
       wfprog.programa matches "*impress*"   or
       wfprog.programa matches "*ref-work*"   or
       wfprog.programa =       "./ofici" or
       wfprog.programa =       "./dados" or
       wfprog.programa =       "./adm" or
       wfprog.programa =       "./admfin" or
       wfprog.programa =       "./convert" or
       wfprog.programa =       "./fin" or
       wfprog.programa =       "./bancos" or
       wfprog.programa =       "./cga-conv" or
       wfprog.programa =       "./fin" or
       wfprog.programa =       "./livro" or
       wfprog.programa =       "./veicu" or
       wfprog.programa =       "./cga" or
       wfprog.programa =       "./helio" or
       wfprog.programa =       "./cga-hp" or
       wfprog.programa =       "./lll" or
       wfprog.programa =       "./cga-franco" or
       wfprog.programa =       "./lib" or
       wfprog.programa =       "./geren" or
       wfprog.programa =       "./lib" or
       wfprog.programa =       "./backup-mes" or
       wfprog.programa =       "./savepe" or
       wfprog.programa =       "./k" or
       wfprog.programa =       "./cga-franco" or
       wfprog.programa =       "./producao" or
       wfprog.programa =       "./backup" or
       wfprog.programa =       "./luciano" or
       wfprog.programa =       "./sistema.log" or
       wfprog.programa =       "./pneus" or
       wfprog.programa =       "./autoc" or
       wfprog.programa =       "./ofici" or
       wfprog.programa =       "./cadas" or
       wfprog.programa =       "./gener" or
       wfprog.programa =       "./movim" or
       wfprog.programa =       "./bases" or
       wfprog.programa =       "./estoq" or
       wfprog.programa =       "./pedid" or
       wfprog.programa =       "./compr" or
       wfprog.programa =       "./caixa" or
       wfprog.programa =       "./conta" or
       wfprog.programa =       "./credi" or
       wfprog.programa =       "./cuspr" or
       wfprog.programa =       "./relat" or
       wfprog.programa =       "." or
       wfprog.programa =       "./refer" or
       wfprog.programa =     "./impress" or
       wfprog.programa =       "./finan"
    then do:
	delete wfprog.
	next.
    end.
    create wfrec.
    wfrec.rec = recid(wfprog).
end.


/*
*
*    wfprog.p    -    Esqueleto de Programacao    com esqvazio


	    substituir    wfprog
			  <tab>
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Seleciona "," Copia "," Todos "," Transfere ",""].

def var esqcom2         as char format "x(12)" extent 5
	    initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
	    " ",
	    " ",
	    " ",
	    " "].

def buffer bwfprog       for wfprog.
def var vwfprog         like wfprog.programa.

recatu1 = ?.

form
    esqcom1
    with frame f-com1
		 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
		 row screen-lines no-box no-labels side-labels column 1
		 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
	if esqascend
	then
	    find first wfprog where
				    true
					no-lock no-error.
	else
	    find last wfprog where
				    true
					no-lock no-error.
    else
	find wfprog where recid(wfprog) = recatu1 no-lock.
    if not available wfprog
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
	find first wfrec where wfrec.rec = recid(wfprog) no-error.
	display
	    if avail wfrec
	    then "*"
	    else ""    @ vast no-label
	    wfprog.programa
	    with frame frame-a 12 down centered color white/red row 4.
    end.
    else leave.

    recatu1 = recid(wfprog).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
	if esqascend
	then
	    find next wfprog where
				    true
					no-lock.
	else
	    find prev wfprog where
				    true
					no-lock.
	if not available wfprog
	then leave.
	if frame-line(frame-a) = frame-down(frame-a)
	then leave.
	down
	    with frame frame-a.
	find first wfrec where wfrec.rec = recid(wfprog) no-error.
	display
	    if avail wfrec
	    then "*"
	    else ""    @ vast
	    wfprog.programa
		with frame frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

	if not esqvazio
	then do:
	    find wfprog where recid(wfprog) = recatu1 no-lock.

	    status default
		if esqregua
		then esqhel1[esqpos1] + if esqpos1 > 1 and
					   esqhel1[esqpos1] <> ""
					then  string(wfprog.programa)
					else ""
		else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
					then string(wfprog.programa)
					else "".

	    choose field wfprog.programa help ""
		go-on(cursor-down cursor-up
		      cursor-left cursor-right
		      page-down   page-up
		      tab PF4 F4 ESC return) color white/black.

	    status default "".

	end.
	{esquema.i &tabela = "wfprog"
		   &campo  = "wfprog.programa"
		   &where  = "true"
		   &frame  = "frame-a"}

	if keyfunction(lastkey) = "end-error"
	then leave bl-princ.

	if keyfunction(lastkey) = "return" or esqvazio
	then do on error undo, retry on endkey undo, leave:
	    form wfprog
		 with frame f-wfprog color black/cyan
		      centered side-label row 4 .
	    if esqregua
	    then do:
		display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
			with frame f-com1.

		if esqcom1[esqpos1] = " Seleciona "
		then do with frame f-wfprog on error undo.
		    find first wfrec where wfrec.rec = recid(wfprog) no-error.
		    if not avail wfrec
		    then do:
			create wfrec.
			assign wfrec.rec = recid(wfprog).
			display if avail wfrec
				then "*"
				else ""    @ vast
				with frame frame-a.
		    end.
		    else do:
			delete wfrec.
			display if avail wfrec
				then "*"
				else ""    @ vast
				with frame frame-a.
		    end.
		    recatu1 = recid(wfprog).
		end.              /*
		if esqcom1[esqpos1] = " Transfere "
		then do.
		    for each wfrec.
			find bwfprog where recid(bwfprog) = wfrec.rec.
			substr(bwfprog.programa,1,2) = "".
			display bwfprog.programa with no-box no-label.
		    end.
		end.                */
		if esqcom1[esqpos1] = " Copia "
		then do.
			output to /usr/cpd/transf.tar .
			output close.
			/*
		    unix silent value(
    "find /tmp -exec rm {} \;") .
    */
		    vtar = "tar cvf /usr/trade/tar ".
		    def stream prodos.
		    output stream prodos to prodos.sh.
		    for each wfrec.
			find first bwfprog where recid(bwfprog) = wfrec.rec.
			vtar = vtar + " " + bwfprog.programa.
			put stream prodos unformatted
			    "prodos -p "
			    bwfprog.programa " "
			    bwfprog.programa skip.

			/*
			unix silent value("cp ." +
			    bwfprog.programa + " /tmp" +
				substr(bwfprog.programa,2,50)).

			output to /usr/cpd/transf.tar append.
			put unformatted
			    "echo '~>':/tmp" + substr(bwfprog.programa,2,50)
								    skip
			    "cat /tmp" + substr(bwfprog.programa,2,50)  skip
			    "echo '~>'"              skip.
			output close.
			*/
		    end.
		    output stream prodos close.
		    pause 0.
		    output to ../tar.sh.
		    put unformatted vtar.
		    output close.
						    /*
		    unix silent value("sh ../tar.sh") . /*value(vtar).*/
						      */
		    pause 0.
		    recatu1 = ?.
		end.
	    end.
	    else do:
		display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
			with frame f-com2.
		leave.
	    end.
	end.
	if not esqvazio
	then do:
	    find first wfrec where wfrec.rec = recid(wfprog) no-error.
	    display
		if avail wfrec
		then "*"
		else ""    @ vast
		wfprog.programa
		    with frame frame-a.
	end.
	if esqregua
	then display esqcom1[esqpos1] with frame f-com1.
	else display esqcom2[esqpos2] with frame f-com2.
	recatu1 = recid(wfprog).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
	view frame fc1.
	view frame fc2.
    end.
end.

