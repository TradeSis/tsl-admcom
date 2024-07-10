/* helio 082023 - CESSÃO BARU - ORQUESTRA 536437 */
{admcab.i new}
/*
def var vcobcodori  as int.
def var vcobcoddes  as int.
*/

def var copcoes as char format "x(60)" extent 5 init 
    ["Cessao Baru       - Enviar Contratos",
     "",
     "Cessao Baru       - Receber Arquivo Confirmacao",
     "",
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
    disp
        cmodo
        with frame fmod
        row 9 centered title "Escolha a forma de entrada de dados" no-labels
                width 70
                overlay.
    choose field cmodo
        with frame fmod.
    hide frame fmod no-pause.
    run finct/trocbaructr.p ( trim(cmodo[frame-index])).

end.

if  frame-index = 3
then do:
    run finct/trocbaruconf.p /*(vcobcodori,vcobcoddes)*/ .
end.

/**if frame-index = 4
then do:
    run fin/opesicpagfidc.p ("PAGAMENTO","ENVIAR").
end.**/
hide frame fop no-pause.
hide frame fmod no-pause.
  