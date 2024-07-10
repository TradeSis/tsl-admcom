{admcab.i}
/* Busca o pagamento da primeira parcela do contrato renegociado */
def input parameter par-clifor    as int.  /*like fin.titulo.clifor.*/
def input parameter par-titdtpag  as date.  /*like fin.titulo.titdtpag.*/
def output parameter ventradaren  as dec.  /*like fin.titulo.titvlcob.*/

message "entrou". pause.
run conecta_d.p.

if connected ("d")
then do:

        
    find first  d.titulo where
                d.titulo.clifor     =  par-clifor and 
                d.titulo.titdtpag  >= par-titdtpag /*and
                d.titulo.titpar     = 51 */
                no-lock no-error.
    if avail d.titulo
    then do:

        assign ventradaren = d.titulo.titvlpag.

    end.
end.
disconnect d.

hide message no-pause.


