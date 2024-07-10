/*
*
*    <tabela>.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{cabec.i}

def input parameter par-etbcod like estab.etbcod.
def input parameter par-forcod like abascompra.forcod.
def input parameter par-abatipo like abascompra.abatipo.

def buffer babascompra for abascompra.

def temp-table tt-produ no-undo
    field procod    like produ.procod
    field Qtde      as dec format ">>,>>9.99"
    field altera    as log init yes
    
    field Motivo    as char format "x(60)"
    
    index produ is unique primary procod asc .

def var v-dtpreventrega LIKE abascompra.dtpreventrega.
form par-etbcod label "Estab"
     estab.etbnom no-label format "x(15)" 
     par-forcod  label "Forn"
     forne.fornom no-label format "x(15)" 
     v-dtpreventrega format "99/99/9999"
     with frame f-estab row  3 no-box color message side-label centered.


find estab where estab.etbcod = par-etbcod no-lock no-error.
if not avail estab
then do:
    update par-etbcod with frame f-estab.
    find estab where estab.etbcod = par-etbcod no-lock no-error.
    if not avail estab and par-etbcod <> 0
    then do:
        message "Estab invalido".
        return.
    end.
end.
disp par-etbcod
     estab.etbnom when avail estab
     with frame f-estab.
     
find forne where forne.forcod = par-forcod no-lock no-error.
if not avail forne
then do:
    update par-forcod with frame f-estab.
    find forne where forne.forcod = par-forcod no-lock no-error.
    if not avail forne and par-forcod <> 0
    then do:
        message "Forne invalido".
        return.
    end.
end.

disp par-etbcod 
     estab.etbnom when avail estab
     par-forcod 
     forne.fornom when avail forne
     with frame f-estab.



run abas/comprainclu.p (if par-abatipo = "" then "MAN" else par-abatipo,
                        par-etbcod,
                        par-forcod).

         
