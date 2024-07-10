/*
*
*    <tabela>.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{cabec.i}

def input parameter par-abatipo like abastransf.abatipo.
def var par-etbcod  like estab.etbcod.
def buffer babastransf for abastransf.

def temp-table tt-produ no-undo
    field procod    like produ.procod
    field Qtde      as dec format ">>,>>9.99"
    field altera    as log init yes
    
    field Motivo    as char format "x(60)"
    
    index produ is unique primary procod asc .

form 
    par-abatipo label "Tipo"
    abastipo.abatnom no-label
    par-etbcod label "Estab"
     estab.etbnom no-label format "x(15)" 
     with frame f-estab row  3 no-box color message side-label centered.



find abastipo where abastipo.abatipo = if par-abatipo = "" then "MAN" else par-abatipo no-lock.

disp par-abatipo abastipo.abatnom no-label 
    with frame f-estab.

if par-abatipo <> "MAN"
then do:
    update par-etbcod with frame f-estab.
end.
else par-etbcod = setbcod.

    disp par-etbcod with frame f-estab.
    find estab where estab.etbcod = par-etbcod no-lock no-error.
    if not avail estab and par-etbcod <> 0
    then do:
        message "Estab invalido".
        return.
    end.
    disp estab.etbnom when avail estab
        with frame f-estab.

if par-abatipo = "MAN"
then do:
    find first tbcntgen where
           tbcntgen.tipcon = 3 and 
           tbcntgen.etbcod = setbcod and
           (tbcntgen.validade = ? or
           tbcntgen.validade >= today)
           no-lock no-error.
    if not avail tbcntgen
    then do:
        message color red/with  skip
        "FILIAL SEM PERMISSAO PARA PEDIDO MANUAL NESTE MENU"
        view-as alert-box.
        return.
    end.
end.


disp par-etbcod
     estab.etbnom  when avail estab
     with frame f-estab.
     
run abas/transfinclu.p (abastipo.abatipo,
                        par-etbcod).

         
