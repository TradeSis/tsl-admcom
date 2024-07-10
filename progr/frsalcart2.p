/* 14042022 helio - 214140 . EXPORTAÇÃO DE RELATÓRIOS RETROATIVO */
/*
   #1 Helio 14.06.17 - Programa de Menu que chama versoes
   #3 12.07.17 Ricardo - Adaptar para acesso remoto
   #4 31.08.2017 - Nova novacao - novo filtro de modaildades
/* #5 Helio 04.04.18 - Versionamento v1801 com Regra definida 
    TITOBS[1] contem FEIRAO = YES - NAO PERTENCE A CARTEIRA 
    ou
    TPCONTRATO = "L" - NAO PERTENCE A CARTEIRA
*/
   
*/

{admcab.i}

run frsalcart_v2201.p. /* era 2002 */
 
return.
