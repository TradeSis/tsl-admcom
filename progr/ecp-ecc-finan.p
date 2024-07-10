/* helio - 12012023 - ajuste em performance */

{admcab.i}

/* helio - 12012023 - ajuste em performance */
run gerarqpgfin_v23.p.

/* helio - 12012023 - ajuste em performance 
    retirado
    
    /*Versão atual com opção para gerar financeira ou FIDC */
    /*run gerarqpgfin-v03.p.*/
    
****/

/***
Versão anterior gerava apenas para financeira  
run gerarqpgfin-v02.p.
***/

/*************
def var vescolha as char FORMAT "X(20)" extent 3
init["     CONTRATO ","  CONTRATO PARCELA","   ULTIMA PARCELA"]
.

DISP VESCOLHA WITH FRAME F-ESCOLHA no-label centered title " Tipo de arquivo ".
choose field vescolha with frame f-escolha.

if frame-index = 1 then run ecc-financeira.p.
else if frame-index = 2 then run ecp-financeira.p.
else if frame-index = 3 then run ecpu-financeira.p.
************/
