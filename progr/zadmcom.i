/*----------------------------------------------------------------------------*/
/* /usr/admger/zadmcom.i                                     Zoom para Admcom */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/

    if frame-field matches "*cla-cod*"    
then run zoocla-cod.p.

else if frame-field matches "*codgrupo*"
then run zoomgrupo.p.

else if frame-field matches "*codtpgrupo*"
then run zootpgrupo.p.

else if frame-field matches "*corcod*"
then run zoocor.p.

else if frame-field matches "*fabcod*"
then run zoofabri.p.

else if frame-field matches "*gracod*"
then run zoograde.p.

else if frame-field matches "*grupo-clacod*"
then run zoogru-cod.p.

else if frame-field matches "*setor-clacod*"
then run zooset-cod.p.

else if frame-field matches "*itecod*"
then run zooitem.p.

else if frame-field matches "*modpcod*"
then run zoomodpack.p.

else if frame-field matches "*mtbcod*"
then run zmotblo.p.

else if frame-field matches "*temp-cod*"
then run zootempcod.p.

else if frame-field matches "*unicod*" or
        frame-field matches "*uncom*" or
        frame-field matches "*unven*"
then run zoounida.p.

if frame-field matches "*opccod*"
    then run zopcom.p.
    
if frame-field matches "*movtdc*"
    then run ztipmov.p.
if frame-field matches "*codigo*"
    then run zlfcad.p.


if frame-field matches "*cla2-cod*"
    then run zcla2-cod.p.

if frame-field matches "*classe*" or
   frame-field matches "*subcod*"
then run zooclasse.p.   
/*
if frame-field matches "*clacod*"
    then run zclase.p.
*/
if frame-field matches "*clacod*"
    then run zoosubcla.p.

if frame-field matches "*clasecom*"
    then run zclasecom.p.

if frame-field matches "*prodecom*"
    then run zprodecom.p.

if frame-field matches "*clasup*"
    then run zclasup.p.

if frame-field matches "*pednum*"
    then run zpedcli.p.

if frame-field matches "*proamx*"
    then run zproduam.p.

if frame-field matches "*proindice*"
then run zproind.p .
if frame-field matches "*proind*"
    then run zproind.p.
if frame-field matches "*procod*"
    then if program-name(2) matches "*pedpro*"
            then run zpedid.p.
            else run novozoom.p. /* zprodu.p */
if frame-field matches "*comcod*"
    then run zcompr.p.
if frame-field matches "*motcod*"
    then run zmotiv.p.
if frame-field matches "*tofcod*" or
   frame-field matches "*etbtof*"
    then run ztofis.p.
if frame-field matches "*tracod*"
    then run ztrans.p.
if frame-field matches "*vencod*"
    then run zvende.p.
if frame-field matches "*etccod*"
    then run zestac.p.
if frame-field matches "*ctrcod*"
    then run zctrib.p.
if frame-field matches "*catcod*"
    then run zcateg.p.
if frame-field matches "*cla-meta*"
    then run zcla-meta.p.
if frame-field matches "*atribcod*"
    then run zatrib-cod.p.
if frame-field matches "*estad-prod*"
    then run zestad-prod.p.
if frame-field matches "*tipoloja*"
    then run ztipo-loja.p.
             
