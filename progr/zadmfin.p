/*----------------------------------------------------------------------------*/
/* /usr/admger/zadmfin.i                                     Zoom para Admfin */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
if frame-field matches "*bancod*" or
   frame-field matches "*titbanpag*" or
   frame-field matches "*cheban*"
    then run zbanco.p.
if frame-field matches "*modcod*"
    then run zmodal.p.
if frame-field matches "*codcob*"
    then run zcobrador.p.
if frame-field matches "*cobcod*"
    then run zcobra.p.
if frame-field matches "*crecod*"
    then run zcrepl.p.
if frame-field matches "*cxacod*"
    then run zcaixa.p.
if frame-field matches "*moecod*"
    then run zmoeda.p.
if frame-field matches "*evecod*"
    then run zevent.p.
if frame-field matches "*opecod*"
    then run zopera.p.
if frame-field matches "*agecod*" or
   frame-field matches "*titagepag*"
    then run zagenc.p .
if frame-field matches "*bandeira*"
    then run zcartao.p .
