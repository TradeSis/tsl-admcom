/* helio 17092024 - processa pagamento boletos boletagem */
/* programa inicio do processo */
def var vretorno as char.
pause 0 before-hide.

message "      -> " string(today,"99/99/9999") string(time,"HH:MM:SS") "Processos de pagamento de boletosBoletagem".

/* Pesquisa  boletos marcados como P, mas sem dtpagamento */
for each boletagbol where boletagbol.situacao = "P" and dtpagamento = ? no-lock.

    message "    PAGAMENTO " boletagbol.bancod boletagbol.nossonumero .
    vretorno = "".
    run api/boletopagar.p (recid(boletagbol), output vretorno).

    run pbolet.


end.      
      
      
pause before-hide.

procedure pbolet.
      
    find current boletagbol no-lock.
    message "      " boletagbol.nossonumero " Pago = " string(boletagbol.dtpagamento = ?,"Nao/Sim") vretorno .          
      
end procedure.      
