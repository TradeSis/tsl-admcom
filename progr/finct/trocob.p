/* 26112021 helio venda carteira */
{admcab.i}
def var vcobcodori  as int.
def var vcobcoddes  as int.

def var copcoes as char format "x(60)" extent 5 init 
    ["1-CARTEIRA LEBES -> 16-FIDC LEBES - Enviar Contratos",
     "", /* helio 21122021 retirado do projeto
         *   "FIDC - RECEBER ARQUIVO DE CONFIRMACAO - FIDC (14)", 
         */
     "FIDC - RECEBER ARQUIVO DE CONFIRMACAO - FIDC LEBES (16)", 
     "FIDC - ENVIAR PAGAMENTOS",
     ""].
def var cmodo as char format "x(60)" extent 3 init
    ["Filtro","Arquivo csv","Digitar"].
disp
        copcoes
        with frame fop
        row 3 centered title "Escolha a Opcao" no-labels
        width 70.
choose field copcoes
    with frame fop.        

if frame-index = 1
then do:         
    vcobcodori = 1.     /* Carteira - Lebes */
    vcobcoddes = 16.    /* FIDC Lebes */
end.

/* helio 21122021 retirado do projeto
*if frame-index = 2
*then do:         
*    vcobcodori = 10.    /* Financeira */
*    vcobcoddes = 14.    /* FIDC  */
*end.
*/

if frame-index = 3
then do:         
    vcobcodori = 1.     /* Carteira - Lebes */
    vcobcoddes = 16.    /* FIDC Lebes */
end.



if frame-index = 1
then do: 
    disp
        cmodo
        with frame fmod
        row 9 centered title "Escolha a forma de entrada de dados" no-labels
                width 70
                overlay.
    choose field cmodo
        with frame fmod.
    hide frame fmod no-pause.
    run finct/trocobctr.p (input vcobcodori, input vcobcoddes, trim(cmodo[frame-index])).

end.

if  frame-index = 3
then do:
    run finct/trocobfidcconf.p (vcobcodori,vcobcoddes).
end.

if frame-index = 4
then do:
    run fin/opesicpagfidc.p ("PAGAMENTO","ENVIAR").
end.
hide frame fop no-pause.
hide frame fmod no-pause.
  