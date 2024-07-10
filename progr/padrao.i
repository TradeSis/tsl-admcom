/*----------------------------------------------------------------------------*/
/* /usr/admger/cab.i                           Cabecalho Geral das Aplicacoes */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
define {1} shared variable wdata as date format "99/99/99"
       label "Data de Processamento".
define {1} shared variable wtittela as char format "x(30)".
define {1} shared buffer wempre for empre.
define {1} shared variable wmodulo as c.
define {1} shared variable wareasis as char format "x(38)".
def var b1 as char format "x".
def var b2 as char format "x".
def var b3 as char format "x".
def var b4 as char format "x".
b1 = "|".
b2 = "|".
b3 = "|".
b4 = "|".
define variable titulo like wtittela.
if "{1}" <> ""
then do:
    find first wempre.
    wareasis = " TESTE ".
    titulo = "teste".
end.
titulo = fill(" ",integer((30 - length(wtittela)) / 2)) + wtittela.
/*
display  wareasis

	titulo at 45

    with column 1 page-top no-labels row 1 width 80 no-hide frame fc1
    title color normal "   " + wempre.emprazsoc + " - " + string(wdata) + "   ".
display titulo with frame fc1.
color display message titulo with frame fc1.
status input "Digite os dados ou pressione [F4] para encerrar.".
status default "ADMCOM - Informatizacao Comercial Ltda.".
*/
