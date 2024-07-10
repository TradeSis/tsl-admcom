/* helio 27062022 pacote de melhorias cobanca */

/*** Remoto ***/
/* #1 Helio 04.04.18 - Regra definida 
    TITOBS[1] contem FEIRAO = YES - NAO PERTENCE A CARTEIRA 
    ou
    TPCONTRATO = "L" - NAO PERTENCE A CARTEIRA
*/

{admcab.i}
def var vmodalidade as char format "x(15)" extent 2 initial [" Crediario "," Emprestimos "].
def var imodalidade as int.

def var vtip as char format "x(10)" extent 2 initial ["Posicao I","Posicao II"].
def var itip as int.

repeat:
    disp vmodalidade with frame f0 no-label centered row 6.
    choose field vmodalidade with frame f0.
    imodalidade = frame-index.

    disp vtip with frame f1 no-label centered row 10.
    choose field vtip with frame f1.
    itip = frame-index.
    
    hide frame f1 no-pause.

    if itip = 1
    then run loj/cre02_lp.p (input trim(vmodalidade[imodalidade])).
    
    if itip = 2
    then run loj/cre03_lp.p (input trim(vmodalidade[imodalidade])).
    
    hide message no-pause.
end.

