/* *****************************************************************
*  Programa.......: mtsmet1a.p
*  Funcao.........: Carrega banco metas
*  Data...........: 17/04/2007
***************************************************************** */
{admcab.i}


def var vsenha as char format "x(11)".

/*
update vsenha blank label "Senha"
       with frame f-senha centered side-labels. 
*/       

vsenha = "meta-drebes".   
hide frame f-senha no-pause.

if vsenha = "meta-drebes"
then do:
    run mtspar1a.p.
end.
