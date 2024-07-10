/*----------------------------------------------------------------------------*/
/* /usr/admger/zadmcrm.i                                     Zoom para Admfin */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
if frame-field matches "*segmentacao*"
    then run zsegmentacao.p.
if frame-field matches "*publico*"
    then run zpublico.p.
if frame-field matches "*perfil*"
    then run zperfil.p.
if frame-field matches "*departamento*"
    then run zdepartamento.p.
if frame-field matches "*produto*"
    then run zproduto.p.
if frame-field matches "*apelo*"
    then run zapelo.p.
if frame-field matches "*canal*"
    then run zcanal.p.
