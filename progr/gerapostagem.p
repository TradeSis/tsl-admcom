define input parameter ipcha-tipo-frete  as character no-undo.
define output parameter ipcha-novo-codigo as character no-undo.


define variable vint-faixa-sedex-ini  as integer   no-undo.
define variable vint-faixa-sedex-fim  as integer   no-undo.
define variable vint-faixa-pac-ini    as integer   no-undo.
define variable vint-faixa-pac-fim    as integer   no-undo.
define variable vcha-cod-postagem-aux as character no-undo.
define variable vint-cod-postagem-aux2 as integer   no-undo.


define variable vint-digito-1         as integer   no-undo.
define variable vint-digito-2         as integer   no-undo.
define variable vint-digito-3         as integer   no-undo.
define variable vint-digito-4         as integer   no-undo.
define variable vint-digito-5         as integer   no-undo.
define variable vint-digito-6         as integer   no-undo.
define variable vint-digito-7         as integer   no-undo.
define variable vint-digito-8         as integer   no-undo.
define variable vint-digito-9-verific as integer   no-undo.
define variable vint-digito-aux       as integer   no-undo.

/*******
assign vint-faixa-sedex-ini = 67529193
       vint-faixa-sedex-fim = 67534192. /* 5.000 etiquetas para o SEDEX. */
                                     
assign vint-faixa-pac-ini = 40465886
       vint-faixa-pac-fim = 40470885.   /* 5.000 etiquetas para o PAC. */
********/

assign vint-faixa-sedex-ini = 67529193
       vint-faixa-sedex-fim = 67534192. /* 5.000 etiquetas para o SEDEX. */
                                     
assign vint-faixa-pac-ini = 124239668
       vint-faixa-pac-fim = 124389659.   /* 5.000 etiquetas para o PAC. */

/* Nova numeracao - 01/06/2012
FAIXA INICIAL: PH124239668BR
FAIXA FINAL:   PH124389659BR
*/


find first seqetiqueta where seqetiqueta.tipofrete = ipcha-tipo-frete exclusive-lock no-error.

if available seqetiqueta then do:
    
    if vint-faixa-pac-fim - seqetiqueta.sequencia = 50
    then message "Solicite nova numeracao aos Correios." view-as alert-box.
    
    if vint-faixa-pac-fim = seqetiqueta.sequencia
    then do:    
    
        message "A Faixa de numeracao esgotou, solicite uma nova faixa." view-as alert-box.

        assign vint-cod-postagem-aux2 = 0.

    end.
    else do:
    
        assign seqetiqueta.sequencia = seqetiqueta.sequencia + 1.

        assign vint-cod-postagem-aux2 = seqetiqueta.sequencia.

    end.

end.

if vint-cod-postagem-aux2 = 0 then do:

    message "Erro ao gerar novo codigo de postagem. Entre em contato com o Suporte de TI.".
    pause.
    return "end-error".

end.

assign vcha-cod-postagem-aux = string(vint-cod-postagem-aux2).

assign vint-digito-1 = integer(substring(vcha-cod-postagem-aux,1,1)).
       vint-digito-2 = integer(substring(vcha-cod-postagem-aux,2,1)).
       vint-digito-3 = integer(substring(vcha-cod-postagem-aux,3,1)).
       vint-digito-4 = integer(substring(vcha-cod-postagem-aux,4,1)).
       vint-digito-5 = integer(substring(vcha-cod-postagem-aux,5,1)).
       vint-digito-6 = integer(substring(vcha-cod-postagem-aux,6,1)).
       vint-digito-7 = integer(substring(vcha-cod-postagem-aux,7,1)).
       vint-digito-8 = integer(substring(vcha-cod-postagem-aux,8,1)).

assign vint-digito-aux = (vint-digito-1 * 8) +
                         (vint-digito-2 * 6) +
                         (vint-digito-3 * 4) +
                         (vint-digito-4 * 2) +
                         (vint-digito-5 * 3) +
                         (vint-digito-6 * 5) +
                         (vint-digito-7 * 9) +
                         (vint-digito-8 * 7). 

if (vint-digito-aux mod 11) = 0 
then do:

    assign vint-digito-9-verific = 5.

end.
else if (vint-digito-aux mod 11) = 1
then do:

    assign vint-digito-9-verific = 0.

end.
else do:

    assign vint-digito-9-verific = (vint-digito-aux mod 11).
    assign vint-digito-9-verific = 11 - vint-digito-9-verific.

end.

case ipcha-tipo-frete:
    when "SEDEX"  then assign ipcha-novo-codigo = "SL" + string(vint-cod-postagem-aux2) + string(vint-digito-9-verific) + "BR".
    when "PAC"    then assign ipcha-novo-codigo = "PH" + string(vint-cod-postagem-aux2) + string(vint-digito-9-verific) + "BR".
    when "TRANSP" then assign ipcha-novo-codigo = "DR" + string(vint-cod-postagem-aux2) + string(vint-digito-9-verific) + "DR".

end case.

return ipcha-novo-codigo.



