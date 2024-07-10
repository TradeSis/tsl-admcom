/*----------------------------------------------------------------------------*/
/* /usr/admger/zadmctb.i                              Zoom para contabilidade */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
if frame-field = "concod" or
   frame-field = "wconsup"
    then run zconta.p.
if frame-field = "hiscod"
    then run zhisto.p.

