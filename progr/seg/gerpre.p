{admcab.i}
def input  parameter par-cre    as recid.
def input  parameter par-clf    as recid.            /** recid do Ag.Com. **/
def output parameter rec-plani    as recid.

def var par-num    like plani.numero.    /** numero da nota **/

def new shared temp-table wf-plani    no-undo
        like plani.
def buffer xplani for plani.
def buffer zplani for plani.


/*

{dftempWG.i}

/*********** DEFINICAO DE PARAMETROS **************/

def input  parameter par-bon    like plani.platot.  /** recid opcom **/
def input  parameter vsubtot2   like titulo.titvlcob.
def input  parameter vdev       like titulo.titvlcob.
def input  parameter vdevval    like plani.vlserv.
def input  parameter par-ser    like plani.serie.   /** serie da nota **/

def input  parameter vnome      like clien.clinom.
def input  parameter p-entrada  as dec.
def input  parameter vmoecod    like moeda.moecod.
def input  parameter p-infoVIVO as char.

def new global shared var scartao as char.

def var pedidoespecial as log.
def var ped-esp as log.
def var pedataespecial as date format "99/99/9999".
def shared var etb-entrega like setbcod.
def shared var dat-entrega as date.
def shared var nome-retirada as char format "x(30)".
def shared var fone-retirada as char format "x(15)".
 
def var not-ass like plani.notass.

def shared temp-table tt-liped like liped.

/** Chamado 16177 - supervisor **/
def shared temp-table tt-senauto
    field procod     like produ.procod
    field preco-ori  like movim.movpc
    field desco      as   log init no
    field senauto    as   dec format ">>>>>>>>>>"
    index i-pro is primary unique procod.
/** **/

def shared temp-table tt-prodesc
    field procod like produ.procod
    field preco  like movim.movpc
    field preco-ven like movim.movpc
    field desco  as   log.

def shared temp-table Black_Friday
    field numero as int
    field valor as dec
    field desconto as log init no
    field pctdes as dec
    . 
    
def shared temp-table tt-cartpre
    field seq    as int
    field numero as int
    field valor  as dec.

def var vnumeracao-automatica as log.
def var vcriapedidoautomatico as log.

def shared var vnumero-chp like titulo.titnum.
def shared var vvalor-chp like titulo.titvlcob.

def shared var vnumero-chpu like titulo.titnum.
def shared var vvalor-chpu like titulo.titvlcob.

def shared temp-table tt-planos-vivo
    field procod like produ.procod
    field tipviv as   int
    field codviv as   int
    field pretab as   dec 
    field prepro as   dec.

def var par-valor as char.

{setbrw.i}.
*/


/*
def var rec-tit as recid.
sg1
def var vpednum     like pedid.pednum.
def var vreccont as recid.
def var vgera   like contrato.contnum.
def var vtroco  as dec format ">,>>9.99".
def var vvalor  like vtroco.
def var par-certo as log.
def var vtitvlpag as dec.
def var vtotpag as dec.
def var v-letra as char.
def var v-ult   as char format "x(4)".
def var vletra  as char.
def var vdata   as date.
def var a       as int.
def var vdia    as int.
def var v-impnf as log format "Sim/Nao".
def var vltabjur  as dec.
def var vldesc  as dec.
def var zzz as int format  "999999".
def var yyy as char format "999999999".
def var vche as log initial no.
def var vacre       like plani.platot.
def var valor       like plani.platot.
def var vparcela    as int.
def var vprotot     like plani.platot.
def var vplacod     like plani.placod.
def var vnumero     like plani.numero.
def var    vperc    as decimal.
def var    vmovseq  like movim.movseq.
def var ventrada    like titulo.titvlcob no-undo.
def var v           as int format "99" no-undo.
def var vi          as int format "99" no-undo.
def var v-i         as int.
def var vbon        like plani.numero.
def var vfunc                   like func.funcod.
def var vnome1                  like clien.clinom.

/************* DEFINICAO DE WORKFILES E TEMP-TABLES **************/

def workfile wtabjur
    field jrec as recid
    field tabjur like titulo.titvljur
    field wdesc like titulo.titvldes.

def workfile tt-cheque
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titdtven like titulo.titdtven
    field rec as recid
    field titvlcob like titulo.titvlcob
    field bancod   as i format "999" label "Banco".

def workfile wletra
    field letra like moeda.moecod
    field nome  like moeda.moenom.

def workfile wftit
    field rec as recid.

def shared workfile wbonus
    field bonus like plani.numero.

def shared workfile wfunc
    field procod like produ.procod
    field funcod like func.funcod.

def shared temp-table wf-movim no-undo
    field wrec      as   recid
    field movqtm    like movim.movqtm
    field lipcor    like liped.lipcor
    field movalicms like movim.movalicms
    field desconto  like movim.movdes
    field movpc     like movim.movpc
    field precoori  like movim.movpc
    field vencod    like func.funcod
    field KITproagr   like produ.procod.
 
def new shared workfile wf-titulo   like titulo.
def new shared workfile wf-contrato like contrato.
def new shared workfile wf-contnf   like contnf.

/************* DEFINICAO DE BUFFERS ***************/
def buffer bwf-titulo   for wf-titulo.
def buffer bplani       for plani.
def buffer ass-plani    for plani.
def buffer btitulo      for titulo.
def buffer ctitulo      for titulo.
def buffer cplani       for plani.
def buffer bliped       for liped.

/************* DEFINICAO DE FORMS ****************/

form
    titulo.titdtpag      colon 20 label "Data Pagamento"
    vtitvlpag            label "Total a Pagar"
    titulo.moecod        colon 20 label "Moeda"
    moeda.moenom         no-label
    vtroco               label "Troco"
    with frame fpag1 side-label row 14 color white/cyan
         overlay centered title " Pagamento " .

form
    wletra.letra
    wletra.nome   format "x(10)"
    with frame f-letra
        column 1 row 14  overlay
        5 down title  " TIPOS  "
        color white/cyan.

def var vqtdcart as int.

vnome1 = vnome.

def var vtotdesc like movim.movpc.

vtotdesc = 0.

for each tt-prodesc.
    
    vtotdesc = vtotdesc + (tt-prodesc.preco - tt-prodesc.preco-ven).
    
end.
*/

find finan where recid(finan) = par-cre no-lock.
find clien where recid(clien) = par-clf no-lock no-error.

if finan.fincod = 0
then find crepl where crepl.crecod = 1 no-lock.
else find crepl where crepl.crecod = 2 no-lock.


def var vvaltot as dec.
def var vperchpven as dec format ">>9.99".

vvaltot = 0.
vperchpven = 0.


for each wf-plani:
    delete wf-plani.
end.

    do on error undo:
        create wf-plani.
        assign
            wf-plani.placod   = int(string("211") + string(par-num,"9999999"))
            wf-plani.etbcod   = estab.etbcod
            wf-plani.numero   = par-num
            wf-plani.cxacod   = scxacod
            wf-plani.emite    = estab.etbcod
            wf-plani.serie    = "P"
            wf-plani.movtdc   = 30
            wf-plani.desti    = if avail clien then clien.clicod else 0
            wf-plani.pladat   = today
            wf-plani.horincl  = time
            wf-plani.crecod   = crepl.crecod
            wf-plani.notsit   = no
            wf-plani.datexp   = today
            wf-plani.opccod   = finan.fincod.
            
        if crepl.crecod = 2
        then wf-plani.modcod   = "CRE".
        else wf-plani.modcod   = "VVI".
        
        
    end.

/***** Criacao de titulo, plani, movim, contrato e contnf *******/

    do:
        /*do for xplani transaction:*/
        find last xplani where xplani.movtdc = 30 and
                               xplani.etbcod = setbcod and 
                               xplani.emite  = setbcod and 
                               xplani.serie  = "P"     and
                               xplani.numero <> ?
                               use-index nota no-lock no-error.
        par-num = if avail xplani
                  then xplani.numero + 1 
                  else 1.                                
        

        do transaction:
            wf-plani.placod   = int(string("211") + string(par-num,"9999999")).
        
            create plani.
            rec-plani = recid(plani). 
            {seg/tt-plani.i plani wf-plani}. 
            plani.numero = par-num.
            wf-plani.numero = plani.numero.
            wf-plani.notass = plani.notass.
        end.
    end.

    if plani.crecod = 2 
    then do:  
        do  transaction:
            assign plani.pedcod = finan.fincod.
        end.
    end.
   
    
    find plani where recid(plani) = rec-plani no-lock.

    
