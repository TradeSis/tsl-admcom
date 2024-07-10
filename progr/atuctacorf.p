{admcab.i}
def input parameter rec-tit as recid.
def var vfuncod as int.

def var vetbcod like estab.etbcod.
def var valor-cre as dec.
def var valor-deb as dec.
 

find titluc where recid(titluc) = rec-tit .
vetbcod = titluc.etbcod.
vfuncod = titluc.vencod.
valor-cre = titluc.titvlcob * .30.
valor-deb = 0.

def buffer bcontacor for contacor.
def buffer dcontacor for contacor.

for each contacor where contacor.natcor = no and
                        contacor.etbcod = vetbcod and
                        contacor.clifor = ? and
                        contacor.funcod = vfuncod and
                        contacor.sitcor = "LIB" 
                        :

    if contacor.valcob - contacor.valpag >= valor-cre
    then do:
        contacor.valpag = contacor.valpag + valor-cre.
        valor-deb = valor-deb + valor-cre.
        create dcontacor.
        find last bcontacor  use-index ndx-7 where 
                  bcontacor.etbcod = vetbcod
                  no-lock no-error.
        if not avail bcontacor
        then dcontacor.numcor = vetbcod * 10000000.
        else dcontacor.numcor = bcontacor.numcor + 1.
         assign
            dcontacor.natcor = yes
            dcontacor.etbcod = vetbcod
            dcontacor.funcod = vfuncod
            dcontacor.datemi = today
            dcontacor.datven = today
            dcontacor.valcob = valor-cre
            dcontacor.rec-titluc = recid(titluc)
            dcontacor.rec-conta = recid(contacor)
            .
        valor-cre = 0.    
        if contacor.valcob = contacor.valpag
        then contacor.sitcor = "PAG".
        leave.
    end.
    else do:
        create dcontacor.
        find last bcontacor  use-index ndx-7 where 
                  bcontacor.etbcod = vetbcod
                  no-lock no-error.
        if not avail bcontacor
        then dcontacor.numcor = vetbcod * 10000000.
        else dcontacor.numcor = bcontacor.numcor + 1.
        assign
            dcontacor.natcor = yes
            dcontacor.etbcod = vetbcod
            dcontacor.funcod = vfuncod
            dcontacor.datemi = today
            dcontacor.datven = today
            dcontacor.valcob = (contacor.valcob - contacor.valpag)
            dcontacor.rec-titluc = recid(titluc)
            dcontacor.rec-conta = recid(contacor)
             .

        valor-cre = valor-cre - (contacor.valcob - contacor.valpag).
        valor-deb = valor-deb + (contacor.valcob - contacor.valpag).
        contacor.valpag = contacor.valpag +
                                   (contacor.valcob - contacor.valpag).
        if contacor.valcob = contacor.valpag
        then contacor.sitcor = "PAG".                           
    end.    
    if valor-cre = 0
    then leave.
end.

do transaction:
    titluc.titvlcob = titluc.titvlcob - valor-deb.
end.
