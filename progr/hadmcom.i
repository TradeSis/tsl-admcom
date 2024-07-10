/*----------------------------------------------------------------------------*/
/* /usr/admger/hadmcom.i                              Dispara Inclusao com F6 */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 28/10/92 Eduardo Criacao                                                   */
/*----------------------------------------------------------------------------*/
WBK = WAREASIS.
if frame-field matches "*clacod*"
    then do:
    wareasis = wareasis + "CLASSE".
    run clase.p.
    end.
if frame-field matches "*repcod*"
    then do:
    wareasis = wareasis + "REPRESENTANTES".
    run repre.p.
    end.
if frame-field matches "*catcod*"
    then do:
    wareasis = wareasis + " Categorias".
    run categ.p.
    end.
if frame-field matches "*fabcod*"
    then do:
    wareasis = wareasis + "FABRICANTE".
    run fabri.p.
    end.
if frame-field matches "*procod*"
    then do:
    wareasis = wareasis + "PRODUTO".
    run produ.p.
    end.
if frame-field matches "*proind*"
    then do:
    wareasis = wareasis + "PRODUTO".
    run produ.p.
    end.
if frame-field matches "*unicod*" or
   frame-field matches "*uncom*" or
   frame-field matches "*unven*"
    then do:
    wareasis = wareasis + "UNIDADE".
    run unida.p.
    end.
if frame-field matches "*comcod*"
    then do:
    wareasis = wareasis + "COMPRADOR".
    run comin.p.
    end.
if frame-field matches "*tofcod*"
    then do:
    wareasis = wareasis + "T.O.F.".
    run tofis.p.
    end.
if frame-field matches "*vencod*"
    then do:
    wareasis = wareasis + "VENDEDOR".
    run /*venin.p*/ vende.p .
    end.
if frame-field matches "*tracod*"
    then do:
    wareasis = wareasis + "FORN.-TRANSP.".
    run forne.p.
    end.
/*
if frame-field matches "*frecod*"
    then do:
    wareasis = wareasis + "TRANSPORTADORA".
    run frein.p.
    end.  */
if frame-field matches "*corcod*"
    then do:
    wareasis = wareasis + "CORES".
    run cor.p.
    end.
if frame-field matches "*etccod*"
    then do:
    wareasis = wareasis + "ESTACAO".
    run estac.p.
    end.
if frame-field matches "*ctrcod*"
    then do:
    wareasis = wareasis + " Tributacao".
    run tribu.p.
    end.
WAREASIS = WBK.
