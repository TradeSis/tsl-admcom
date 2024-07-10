def var vsub like movim.movpc.
def buffer bestab for estab.
def var vfre as dec format ">>,>>9.99".
def var vacr as dec format ">,>>9.99".
def var voutras like plani.outras.
def buffer btitulo for titulo.
def var vfrecod like frete.frecod.
def var totped like pedid.pedtot.
def var totpen like pedid.pedtot.
def var vok as l.
def var vcusto like estoq.estcusto.
def var vpreco like estoq.estcusto.
def var vcria as log initial no.
def new shared workfile wfped field rec  as rec.
def var vped as recid.
def buffer xestoq for estoq.
def workfile wprodu
    field wpro like produ.procod
    field wqtd as int.
def  workfile w-movim
               field wrec    as   recid
               field codfis    like clafis.codfis
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc format ">>>,>>9.99"
                                column-label "Subtot"
               field movpc     as decimal format ">,>>9.99"
               field movalicms like movim.movalicms initial 17
               field movalipi  like movim.movalipi
               field movfre    like movim.movpc
               field movdes    like movim.movpc
               field valdes    like movim.movpc.
def workfile wetique
    field wrec as recid
    field wqtd like estoq.estatual.
def var vopcao as char format "x(10)" extent 2 initial [" Moveis ","Confeccao"].
def var vestcusto  like estoq.estcusto.
def var vestmgoper like estoq.estmgoper.
def var vestmgluc  like estoq.estmgluc.
def var vtabcod    like estoq.tabcod.
def var vestvenda  like estoq.estvenda.
def buffer cprodu for produ.
def var wetccod like produ.etccod.
def var wfabcod like produ.fabcod.
def var wprorefter like produ.prorefter.
def buffer witem for item.
def var witecod like produ.itecod.
def var vitecod like produ.itecod.
def var vresp    as log format "Sim/Nao".
def var wrsp    as log format "Sim/Nao".
def var vdesc    like plani.descprod format ">9.99 %".
def var i as i.
def var Vezes as int format ">9".
def var Prazo as int format ">>9".
def var v-ok as log.
def buffer bclien for clien.
def var vforcod like forne.forcod.
def var vsaldo    as dec.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like plani.vencod.
def var vsubtotal like  movim.movqtm.
def var valicota  like  plani.alicms format ">9,99" initial 17.
def var vpladat   like  plani.pladat.
def var vrecdat   like  plani.pladat label "Recebimento".
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms .
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete format ">>,>>9.99".
def var vseguro   like  plani.seguro.
def var vdesacess like  plani.desacess.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vtotal    like plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(02)".
def var vopccod   like  plani.opccod.
def var vhiccod   like  plani.hiccod initial 112.
def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotpag      like plani.platot.
def buffer bplani for plani.


