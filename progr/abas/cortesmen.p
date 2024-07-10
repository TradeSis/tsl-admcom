/*
*
*    <tabela>.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{cabec.i}

def input param par-wms as char.
def var par-etbcorte    like estab.etbcod.
def var par-etbcod      like estab.etbcod.
def var par-pendentes   as log.


find first abaswms where abaswms.wms = par-wms no-lock.

disp par-wms label "WMS" format "x(12)"
             with frame f1 side-label 1 down width 80
                 overlay  row 3 no-box color message.


par-etbcorte = abaswms.etbcd.

disp
    par-etbcorte label "Dep"
    with frame f1.
    
update
    par-etbcod label "Filial"
    with frame f1.
find estab where estab.etbcod = par-etbcod no-lock no-error.
if not avail estab and par-etbcod <> 0
then undo.
if avail estab
then disp estab.etbnom no-label format "x(10)"
    with frame f1.

update par-pendentes format "Pendentes/Todos" label "Selecao [P/T]"
    with frame f1.



run abas/cortescons.p (par-wms,
                       par-etbcorte,
                        par-etbcod,
                        par-pendentes).

         
