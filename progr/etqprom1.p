{/var/www/drebes/progress/admcab.i new}

def var vsequencia like ctpromoc.sequencia.
def var vdata as date.

/*
vdata = int(SESSION:PARAMETER).
*/

vdata = date(SESSION:PARAMETER).

message vdata.

/*
update vsequencia label "Codigo da Promocao"
    with frame f1 side-label 1 down.

if vsequencia > 0
then do:
    find first ctpromoc where ctpromoc.sequencia = vsequencia and
            ctpromoc.linha = 0 and
            ctpromoc.situacao = "L" 
               no-lock no-error.

    if not avail ctpromoc /*or
        ctpromoc.tipo <> "diaria"*/ 
    then return.
end.
*/
/* vdata = today. */

/* update vdata at 1 label "Data etiqueta" with frame f1 width 80
    side-label.
*/


if vdata = ?  /* or vdata < today */
then undo. 
run /var/www/drebes/progress/etqpromo.p(vsequencia, vdata).




