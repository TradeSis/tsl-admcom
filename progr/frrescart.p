/* 14042022 helio - 214140 . EXPORTAÇÃO DE RELATÓRIOS RETROATIVO */
/* #1 Helio 14.06.17 - Programa de Menu que chama versoes */ 
/* #2 Helio 04.04.18 - Versionamento com Regra definida 
    TITOBS[1] contem FEIRAO = YES - NAO PERTENCE A CARTEIRA 
    ou
    TPCONTRATO = "L" - NAO PERTENCE A CARTEIRA
*/
    
{admcab.i}

run frrescart_v1801.p. /* frsalcart.p chama versao anterior 1801*/
 
return.