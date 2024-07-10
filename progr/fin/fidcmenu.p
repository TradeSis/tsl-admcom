/* 18022022 helio carteira FIDC FINANCEIRA */
{admcab.i }
def var vcobcodori  as int init 10.
def var vcobcoddes  as int init 14.

def var copcoes as char format "x(76)" extent 5 init 
    ["FIDC - RECEBER ARQUIVO DE TROCA CARTEIRA - FINANCEIRA (10) para FIDC (14)", 
     "FIDC - ENVIAR PAGAMENTOS FIDC 14",
     "FIDC - CONSULTAS ",
     ""].
def var cmodo as char format "x(60)" extent 3 init
    ["Filtro","Arquivo csv","Digitar"].
disp
        copcoes
        with frame fop
        row 3 centered title "Escolha a Opcao" no-labels
        width 80.
choose field copcoes
    with frame fop.        


if frame-index = 1
then do: 
    hide frame fop no-pause.
    run fidc-importa.p (copcoes[1],vcobcodori, vcobcoddes).
end.

if  frame-index = 2
then do:
    hide frame fop no-pause.
    run fin/fidcpagenvia.p (copcoes[2], vcobcoddes).
end.
if frame-index = 3
then do:
    hide frame fop no-pause.
    run cdlotefidc.p (copcoes[3], vcobcoddes).
end.    

hide frame fop no-pause.
hide frame fmod no-pause.
  