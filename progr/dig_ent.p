def var a as i format ">>>9".
def var m as i format ">9".
def var i as i.
def var vetbcod like estab.etbcod.
def var vqtd    as i format ">>>9" extent 11.

{admcab.i}

repeat:
    VETBCOD = 999.
    update vetbcod with frame f1 side-labels centered color white/red.
    find estab where estab.etbcod = vetbcod.
    disp estab.etbnom no-label with frame f1.

    repeat with frame f2 down centered color white/cyan no-labels
    title
"Codigo Produto          JAN  DEZ  NOV  OUT  SET  AGO  JUL  JUN  MAI  ABR  MAR":


	assign vqtd[1] = 0
	       vqtd[2] = 0
	       vqtd[3] = 0
	       vqtd[4] = 0
	       vqtd[5] = 0
	       vqtd[6] = 0
	       vqtd[7] = 0
	       vqtd[8] = 0
	       vqtd[9] = 0
	       vqtd[10] = 0
	       vqtd[11] = 0.

	prompt-for produ.procod with no-validate.
	find produ using produ.procod.
	disp produ.pronom no-label format "x(16)".

	do i = 1 to 11:

	    if i = 1
	    then assign a = 1998
			m = 01.

	    if i = 2
	    then assign a = 1997
			m = 12.

	    if i = 3
	    then assign a = 1997
			m = 11.

	    if i = 4
	    then assign a = 1997
			m = 10.

	    if i = 5
	    then assign a = 1997
			m = 09.

	    if i = 6
	    then assign a = 1997
			m = 08.

	    if i = 7
	    then assign a = 1997
			m = 07.

	    if i = 8
	    then assign a = 1997
			m = 06.

	    if i = 9
	    then assign a = 1997
			m = 05.

	    if i = 10
	    then assign a = 1997
			m = 04.

	    if i = 11
	    then assign a = 1997
			m = 03.

	    find himov where himov.etbcod = estab.etbcod and
			     himov.procod = produ.procod and
			     himov.movtdc = 4            and
			     himov.himano = a            and
			     himov.himmes = m            no-error.
	    if avail himov
	    then vqtd[i] = himov.himqtm.
	end.

	update vqtd no-label.

	do i = 1 to 11:

	    if i = 1
	    then assign a = 1998
			m = 01.

	    if i = 2
	    then assign a = 1997
			m = 12.

	    if i = 3
	    then assign a = 1997
			m = 11.

	    if i = 4
	    then assign a = 1997
			m = 10.

	    if i = 5
	    then assign a = 1997
			m = 09.

	    if i = 6
	    then assign a = 1997
			m = 08.

	    if i = 7
	    then assign a = 1997
			m = 07.

	    if i = 8
	    then assign a = 1997
			m = 06.

	    if i = 9
	    then assign a = 1997
			m = 05.

	    if i = 10
	    then assign a = 1997
			m = 04.

	    if i = 11
	    then assign a = 1997
			m = 03.


	    find himov where himov.etbcod = estab.etbcod and
			     himov.procod = produ.procod and
			     himov.movtdc = 4            and
			     himov.himano = a            and
			     himov.himmes = m            no-error.
	    if not avail himov
	    then do:
		create himov.
		assign himov.etbcod = estab.etbcod
		       himov.procod = produ.procod
		       himov.movtdc = 4
		       himov.himano = a
		       himov.himmes = m.
	    end.
	    himov.himqtm = vqtd[i].

	end.
    end.
end.
