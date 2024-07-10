/*----------------------------------------------------------------------------*/
/* /usr/admger/hadmfin.i                              Dispara Inclusao com F6 */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 28/10/92 Eduardo Criacao                                                   */
/*----------------------------------------------------------------------------*/
if frame-field matches "*cheban*"
    then do:
    wareasis = wareasis + "BANCOS".
    run banco.p.
    end.
if frame-field matches "*bancod*"
    then do:
    wareasis = wareasis + "BANCOS".
    run banco.p.
    end.
if frame-field matches "*modcod*"
    then do:
    wareasis = wareasis + "MODALIDADE".
    run modal.p.
    end.
if frame-field matches "*cobcod*"
    then do:
    wareasis = wareasis + "COBRANCA".
    run cobra.p.
    end.
if frame-field matches "*codcob*"
    then do:
    wareasis = wareasis + "COBRADOR".
    run cobrador.p.
    end.
if frame-field matches "*cxacod*"
    then do:
    wareasis = wareasis + "CAIXA".
    run caixa.p.
    end.
if frame-field matches "*moecod*"
    then do:
    wareasis = wareasis + "MOEDA".
    run moeda.p.
    end.
if frame-field matches "*evecod*"
    then do:
    wareasis = wareasis + "EVENTO".
    run event.p.
    end.
if frame-field matches "*opecod*"
    then do:
    wareasis = wareasis + "OPERADOR".
    run opera.p.
    end.
if frame-field matches "*crecod*"
    then do:
    wareasis = wareasis + "CONDICOES".
    run crepl.p.
    end.
