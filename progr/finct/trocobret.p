/* helio 12042023 - ID 155992 Orquestra 465412 - Troca de carteira */
/* 09022023 helio ID 155965 */
/* 30112021 helio retorno carteira */
{admcab.i}
def var vcobcodori  as int.
def var vcobcoddes  as int.

def var copcoes as char format "x(70)" extent 12 init 
     ["ARQUIVO PARA RETORNO PARA CARTEIRA LEBES ->1  (contrato completo)",
      "ARQUIVO ENVIO PARA A FINANCEIRA          ->10 (contrato completo)",
      "ARQUIVO ENVIO PARA A FIDC 14             ->14 (contrato completo)",
      "ARQUIVO ENVIO PARA A FIDC 16             ->16 (contrato completo)",
      "ARQUIVO ENVIO PARA A OUTROS 2            ->2  (contrato completo)",
      "",
      "ARQUIVO PARA RETORNO PARA CARTEIRA LEBES ->1  (saldo aberto contrato)",
      "ARQUIVO ENVIO PARA A FINANCEIRA          ->10 (saldo aberto contrato)",
      "ARQUIVO ENVIO PARA A FIDC 14             ->14 (saldo aberto contrato)",
      "ARQUIVO ENVIO PARA A FIDC 16             ->16 (saldo aberto contrato)",
      "ARQUIVO ENVIO PARA A OUTROS 2            ->2  (saldo aberto contrato)",

      "ARQUIVO ENVIO DA 16 PARA 1             16->1  (saldo aberto contrato)"
      

     ].
def var cmodo as char format "x(60)" extent 3 init
    ["Filtro","Arquivo csv","Digitar"].
disp
        copcoes
        with frame fop
        row 3 centered title "Escolha a Opcao" no-labels
        width 79.
choose field copcoes
    with frame fop.        

if frame-index = 1 or frame-index = 7
then do:
    vcobcodori = ?.
    vcobcoddes = 1. /* Carteira Lebes */
end.    
if frame-index = 2 or frame-index = 8
then do:
    vcobcodori = ?.
    vcobcoddes = 10. /* Carteira Lebes */
end.    

if frame-index = 3 or frame-index = 9
then do:
    vcobcodori = ?.
    vcobcoddes = 14. /* Carteira Lebes */
end.    

if frame-index = 4 or frame-index = 10
then do:
    vcobcodori = ?.
    vcobcoddes = 16. /* Carteira Lebes */
end.    

if frame-index = 5 or frame-index = 11
then do:
    vcobcodori = ?.
    vcobcoddes = 2. /* Carteira Lebes */
end.    

if frame-index = 12
then do: 
    vcobcodori = 16. 
    vcobcoddes = 1. /* Carteira Lebes */
            
end.
if frame-index = 1 or
   frame-index = 2 or
   frame-index = 3 or
   frame-index = 4 or
   frame-index = 5
then do:
    run  finct/trocobdest.p (input vcobcodori, input vcobcoddes, input yes).
end.

if  frame-index = 12 or
   frame-index = 7 or
   frame-index = 8 or
   frame-index = 9 or
   frame-index = 10 or
   frame-index = 11
then do:
    run  finct/trocobdest.p (input vcobcodori, input vcobcoddes, input no).
end.


hide frame fop no-pause.
hide frame fmod no-pause.
  
