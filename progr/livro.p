/*----------------------------------------------------------------------------*/
/* /usr/admcom/cp/livro.p                                         Livro Preco */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 26/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
do with 1 column width 80 title " Confirmacao de Emissao " frame f1:
    display skip "Prepare a Impressora, formulario 80 colunas." skip.
end.
{confir.i 1 "Impressao de Livro de Precos" ", leave"}
message "Emitindo Livro de Precos.".
run cp/livpr.p.
message "Emissao do Livro de Precos encerrada.".
