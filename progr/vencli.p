{admcab.i}

def input parameter par-mov     as   char.
def var vdti                    as   date label "Data Inicial".
def var vdtf                    as   date label "Data Final".
def var vdata                   as   date format "99/99/9999".
def var vvalor                  like titulo.titvlcob.
def var vtotcli                 like plani.platot.
def var vconcli                 as   int.

find tipmov where tipmov.movtdc = int(par-mov) no-lock.

update vdti colon 20 label "Periodo" "a"
       vdtf          no-label
       vvalor colon 20 label "Valor Minimo"
       with frame fclien.

for each plani where plani.movtdc  = tipmov.movtdc  and
		     plani.pladat >= vdti           and
		     plani.pladat <= vdtf
			break
			    by plani.clifor.
    vtotcli = vtotcli + plani.platot.
    vconcli = vconcli + 1.
    if last-of(plani.clifor)
    then do:
	if vtotcli >= vvalor
	then do:
	    find clien where clien.clicod = plani.clifor no-lock.
	    display clien.clicod
		    clien.clinom
		    plani.pladat    column-label "Ultima Compra"
		    vtotcli         column-label "Total Comprado"
		    vconcli         column-label "Numero Compras"
		    with frame flin down width 120 no-box.
	end.
	vtotcli = 0.
	vconcli = 0.
	vdata = ?.
    end.
end
