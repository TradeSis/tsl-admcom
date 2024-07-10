/*----------------------------------------------------------------------------*/
/* /usr/admger/hadmger.i                              Dispara Inclusao com F6 */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 28/10/92 Eduardo Criacao                                                   */
/*----------------------------------------------------------------------------*/
WBK = WAREASIS.

if frame-field matches "*lancod*"
    then do:
    wareasis = wareasis + "LANCAMENTOS".
    run tablan.p.
    end.

if frame-field matches "*forcod*"
    then do:
    wareasis = wareasis + "FORNECEDOR".
    run forne.p.
    end.

if frame-field matches "*frecod*"
    then do:
    wareasis = wareasis + "TRANSPORTADORA".
    run frete.p.
    end.
if frame-field matches "*empcod*"
    then do:
    wareasis = wareasis + "EMPRESA".
    run empre.p.
    end.
if frame-field matches "*ufecod*"
    then do:
    wareasis = wareasis + "UN.FEDERATIVA".
    run unfed.p.
    end.
if frame-field matches "*etbcod*"
    then do:
    wareasis = wareasis + "ESTABELECIMENTO".
    run estab.p.
    end.
if frame-field matches "*setcod*"
    then do:
    wareasis = wareasis + "SETOR".
    run setor.p.
    end.
/* HELiO 07032024 - ID 72273 - Bloqueio de menu. - DESATIVAR
if frame-field matches "*clicod*"
    then do:
    wareasis = wareasis + "CLIENTE".
    run clien.p.
    end.
*/    
if frame-field matches "*unocod*"
    then do:
    wareasis = wareasis + "UN.ORGANIZACIONAL".
    run unoin.p.
    end.
if frame-field matches "*indcod*"
    then do:
    wareasis = wareasis + "INDIC.ECONOMICO".
    run indin.p.
    end.
if frame-field matches "*bancod*"
    then do:
    wareasis = wareasis + "BANCO".
    run banco.p.
    end.
if frame-field matches "*agecod*"
    then do:
    wareasis = wareasis + "AGENCIA".
    run agenc.p.
    end.
/*
if frame-field = "codimp"
    then do:
    wareasis = wareasis + "SETOR".
    then run impin.p.
if frame-field = "codti"
    then do:
    wareasis = wareasis + "SETOR".
    then run tipin.p.
*/
WAREASIS = WBK.
