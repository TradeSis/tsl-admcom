/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : perfop01.p
******************************************************************************/
{admcab.i}.
{setbrw.i}
def var vdat-aux as date format "99/99/9999".
def var vheader as char format "x(20)".
def var aux-i as int.
def var aux-etbcod like estab.etbcod.
def buffer bestab for estab.
def var vacfprod like plani.acfprod.
def var v-percproj  as dec.
def var v-totcom    as dec.
def var v-ttmet     as dec /*like metven.vlmeta*/.
def var v-totalzao  as dec.
def var vhora       as char.
def var vok         as logical.
def var vquant      like movim.movqtm.
def var flgetb      as log.
def var vmovtdc     like tipmov.movtdc.
def var v-totaldia  as dec.
def var v-total     as dec.
def var v-totdia    as dec.
def var v-nome      like estab.etbnom.
def var d           as date.
def var i           as int.
def var v-qtd       as dec.
def var v-tot       as dec.
def var v-movtdc    like plani.movtdc.
def var v-dif       as dec.
def var v-valor     as dec decimals 2.
def var v-totger    as dec.
def shared      var vdti        as date format "99/99/9999" no-undo.
def shared      var vdtf        as date format "99/99/9999" no-undo.
def shared      var vdiasatu    as int.
def var vdt-aux as date.
def var p-vende     like func.funcod.
def input parameter par-etbcod      like estab.etbcod.
def input parameter par-vencod      like func.funcod.
def input parameter p-pedtdc        like pedid.pedtdc.
def input parameter p-forcod        like pedid.clfcod.
def var vetbcod like estab.etbcod.
if par-etbcod = 999
then vetbcod = 0. else vetbcod =  par-etbcod.
def var p-comcod    like func.funcod.
def var p-setor     like setor.setcod.
def var p-grupo     like clase.clacod.
def var p-clase     like clase.clacod.
def var p-sclase    like clase.clacod.
def var p-catcod    like categ.catcod.
def var p-procod as int.
def var v-titfab    as char.
def var v-titcom    as char.
def var v-titcat    as char.
def var v-titset    as char.
def var v-titgru    as char.
def var v-titcla    as char.
def var v-titscla   as char.
def var v-titvenpro as char.
def var v-titven    as char.
def var v-titpro    as char.
def var v-perdia    as dec label "% Dia".
def var v-perc      as dec label "% Acum".
def var v-perdev    as dec label "% Dev" format ">9.99".
def var vnomabr     like produ.pronom format "x(20)" /*like produ.nomabr. */.

def var vfapro as char extent 2  format "x(15)"
                init["  PRODUTO  "," FABRICANTE "].
def var vfapro-op as char extent 3  format "x(15)"
                init[" DESCER ", "  PRODUTO  "," FABRICANTE "].


def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer tsetor for clase.

def shared temp-table ttcomprador
    field comcod    like pedid.comcod
    field comnom    as char
    field etbcod    like estab.etbcod
    field nome    like estab.etbnom 
    field qtdmerca  as int  column-label "Total"
    field qtdmercaent   as int  column-label "Entregue"
    field qtdsaldo  as int  column-label "Saldo"
    field qtdatrasado   as int  column-label "Atrasado"
    field qtdposterior  as int  column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
    index loja     is unique etbcod asc comcod asc 
    index platot   is primary qtdsaldo desc.

def  temp-table ttcateg 
    field catcod    like categoria.catcod
    field etbcod    like estab.etbcod
    field comcod    like pedid.comcod
    field catnom    like categoria.catnom 
    field qtdmerca  as int column-label "Total"
    field qtdmercaent   as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
    index setor     etbcod comcod catcod 
    index valor     qtdsaldo desc.

def  temp-table ttsetor 
    field catcod    like categ.catcod
    field setcod    like setor.setcod
    field etbcod    like estab.etbcod
    field comcod    like pedid.comcod
    field nome      like estab.etbnom 
    field qtdmerca  as int column-label "Total"
    field qtdmercaent   as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
    index setor     etbcod comcod catcod setcod 
    index valor     qtdsaldo desc.

def  temp-table ttgrupo
    field catcod like categ.catcod
    field grupo-clacod    like clase.clacod
    field setcod    like setor.setcod
    field etbcod    like estab.etbcod
    field comcod    like pedid.comcod
    field nome    like estab.etbnom 
    field qtdmerca  as int column-label "Total"
    field qtdmercaent as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
    index grupo     etbcod comcod catcod setcod grupo-clacod 
    index valor     qtdsaldo desc.

def temp-table ttclase
    field catcod     like categ.catcod
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field grupo-clacod    like clase.clacod
    field clase-clacod    like clase.clasup    
    field comcod    like pedid.comcod
    field qtdmerca as int column-label "Total"
    field qtdmercaent as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
    field nome      like estab.etbnom 
    index loja     is unique etbcod asc
                             comcod asc
                             catcod asc
                             setcod asc
                             grupo-clacod asc
                             clase-clacod asc
    index platot  is primary qtdsaldo desc.    

def temp-table ttsclase
    field catcod like categ.catcod
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field comcod    like pedid.comcod
    field qtdmerca as int column-label "Total"
    field qtdmercaent as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
    field nome      like estab.etbnom 
    index loja     is unique  etbcod       asc
                              comcod       asc
                              catcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
    index platot  is primary qtdsaldo desc.    

def temp-table ttvenpro
    field catcod    like categ.catcod 
    field platot    like plani.platot
    field funcod    like func.funcod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field procod    like produ.procod
    field etbcod    like plani.etbcod
    index valor     platot desc.


def temp-table ttprodu
    field catcod like categ.catcod
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field procod           like produ.procod 
    field comcod    like pedid.comcod
    field qtdmerca as int column-label "Total"
    field qtdmercaent as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
    field nome     like estab.etbnom 
    index loja     is unique  etbcod       asc
                              comcod       asc
                              catcod       asc
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              procod       asc 
    index platot  is primary qtdsaldo desc.    

def temp-table ttproduaux like ttprodu.

def temp-table ttfabri
    field catcod like categ.catcod
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field fabcod           like produ.fabcod 
    field comcod    like pedid.comcod
    field nome      like estab.etbnom 
    field qtdmerca as int column-label "Total"
    field qtdmercaent  as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
    index loja     is unique  etbcod       asc
                              comcod       asc
                              catcod       asc  
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              fabcod       asc 
    index platot  is primary qtdsaldo desc.    

def temp-table ttfabriaux
    field catcod like categ.catcod
    field setcod    like setor.setcod
    field etbcod    like plani.etbcod
    field  grupo-clacod    like clase.clacod
    field  clase-clacod    like clase.clacod    
    field sclase-clacod    like clase.clacod    
    field fabcod           like produ.fabcod 
    field comcod    like pedid.comcod
    field nome      like estab.etbnom 
    field qtdmerca as int column-label "Total"
    field qtdmercaent  as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
    index loja     is unique  etbcod       asc
                              comcod       asc
                              catcod       asc  
                              setcod       asc
                              grupo-clacod asc
                              clase-clacod asc
                             sclase-clacod asc
                              fabcod       asc 
    index platot  is primary qtdsaldo desc.    


form
    clase.clacod
    clase.clanom
        help " ENTER = Seleciona" 
    "clase.setcod"
    setor.setnom
    with frame f-consulta
        color yellow/blue centered down overlay title " CLASSES " .

form
    ttvenpro.procod
       help "F8=Imprime"
    produ.pronom    format "x(18)" 
    ttvenpro.qtd     column-label "Qtd" format ">>>9" 
    ttvenpro.pladia  format "->,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttvenpro.platot  format "->,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-vendpro
        centered
        down   overlay
        title v-titvenpro.
/*
form header 
        "----<COMPRADOR>" + fill("-",73) format "x(80)"
     with frame f-comprador no-underline.
*/

form
    ttcomprador.comnom  column-label "Nome"  format "x(16)"
    ttcomprador.qtdmerca    column-label "QTotal"            format ">>>>>>>9" 
    ttcomprador.qtdmercaent column-label "QEntra"             format ">>>>>>>9"
    ttcomprador.qtdsaldo column-label "QSaldo"            format "->>>>>>>9" 
    ttcomprador.vlrsaldo column-label "VSaldo"        format "->>>>,>>9.99"
    ttcomprador.qtdatrasado column-label  "QAtraso"      format ">>>>>>>9"
    ttcomprador.vlratrasado column-label  "VAtraso" format ">>>>,>>9.99"
    with frame f-comprador
        width 80
        10 down 
        row 7 
        overlay title v-titcom + " ".
/*
form header 
        "----<CATEGORIAS>" + fill("-",73) format "x(80)"
     with frame f-categ no-underline.
*/ 
form
    ttcateg.catnom  column-label "Categorias"  format "x(16)"
    ttcateg.qtdmerca    column-label "QTotal"            format ">>>>>>>9" 
    ttcateg.qtdmercaent column-label "QEntra"             format ">>>>>>>9"
    ttcateg.qtdsaldo column-label     "QSaldo"            format "->>>>>>>9" 
    ttcateg.vlrsaldo column-label "VSaldo"       format "->>>>,>>9.99"
    ttcateg.qtdatrasado column-label  "Qatraso"      format ">>>>>>>9"
    ttcateg.vlratrasado column-label  "VAtraso" format ">>>>,>>9.99"
    with frame f-categ
        width 80
        10 down 
        row 7
        overlay title v-titcat + " ".
 
 /**
form header 
        "----<SETORES>" + fill("-",73) format "x(80)"
     with frame f-setor no-underline.
  **/
form
    ttsetor.nome  column-label "Setores"  format "x(16)"
    ttsetor.qtdmerca    column-label "QTotal"            format ">>>>>>>9" 
    ttsetor.qtdmercaent column-label "QEntra"             format ">>>>>>>9"
    ttsetor.qtdsaldo column-label     "QSaldo"            format "->>>>>>>9" 
    ttsetor.vlrsaldo column-label "VSaldo"       format "->>>>,>>9.99"
    ttsetor.qtdatrasado column-label  "QAtraso"      format ">>>>>>>9"
    ttsetor.vlratrasado column-label  "Vatraso" format ">>>>,>>9.99"
    with frame f-setor
        width 80
        10 down 
        row 7
        overlay  title v-titset + " ".
                
/*
form header 
        "----<GRUPOS>" + fill("-",74) format "x(80)"
     with frame f-grupo no-underline OVERLAY. 
*/
form
    ttgrupo.nome  column-label "Grupos"  format "x(16)"
    ttgrupo.qtdmerca    column-label "QTotal"            format ">>>>>>>9" 
    ttgrupo.qtdmercaent column-label "QEntra"             format ">>>>>>>9"
    ttgrupo.qtdsaldo column-label     "QSaldo"            format "->>>>>>>9" 
    ttgrupo.vlrsaldo column-label "VSaldo"       format "->>>>,>>9.99"
    ttgrupo.qtdatrasado column-label  "QAtraso"      format ">>>>>>>9"
    ttgrupo.vlratrasado column-label  "VAtraso" format ">>>>,>>9.99"
    with frame f-grupo
        width 80
        10 down 
        row 7
        overlay title v-titgru + " ".
/*
form header
        "----<CLASSES>" + fill("-",73) format "x(80)"
     with frame f-clase no-underline. 
*/
form
    ttclase.nome  column-label "Classes"  format "x(16)"
    ttclase.qtdmerca    column-label "QTotal"            format ">>>>>>>9" 
    ttclase.qtdmercaent column-label "QEntra"             format ">>>>>>>9"
    ttclase.qtdsaldo column-label     "QSaldo"            format "->>>>>>>9" 
    ttclase.vlrsaldo column-label "VSaldo"    format "->>>>,>>9.99"
    ttclase.qtdatrasado column-label  "QAtraso"      format ">>>>>>>9"
    ttclase.vlratrasado column-label  "VAtraso" format ">>>>,>>9.99"
    with frame f-clase
        width 80
        10 down 
        row  7
        overlay title v-titcla + " ".
/*
form header 
        "----<SUB-CLASSES>" + fill("-",69) format "x(80)"
     with frame f-sclase no-underline OVERLAY. 
*/
form
    ttsclase.nome  column-label "Sub-Classes"  format "x(16)"
    ttsclase.qtdmerca    column-label "QTotal"           format ">>>>>>>9" 
    ttsclase.qtdmercaent column-label "QEntra"            format ">>>>>>>9"
    ttsclase.qtdsaldo column-label     "QSaldo"           format "->>>>>>>9" 
    ttsclase.vlrsaldo column-label "VSaldo"      format "->>>>,>>9.99"
    ttsclase.qtdatrasado column-label  "QAtraso"     format ">>>>>>>9"
    ttsclase.vlratrasado column-label  "VAtraso" format ">>>>,>>9.99"
    with frame f-sclase
        width 80
        10 down 
        row 7
        overlay title v-titscla + " ".
/*
form header 
        "----<PRODUTOS>" + fill("-",69) format "x(80)"
     with frame f-produ no-underline OVERLAY. 
*/
form
    ttprodu.nome  column-label "Produtos"  format "x(16)"
    ttprodu.qtdmerca    column-label "QTotal"            format ">>>>>>>9" 
    ttprodu.qtdmercaent column-label "QEntra"             format ">>>>>>>9"
    ttprodu.qtdsaldo column-label     "QSaldo"            format "->>>>>>>9" 
    ttprodu.vlrsaldo column-label "VSaldo"         format "->>>>,>>9.99"
    ttprodu.qtdatrasado column-label  "QAtraso"      format ">>>>>>>9"
    ttprodu.vlratrasado column-label  "VAtraso" format ">>>>,>>9.99"
    with frame f-produ
        width 80
        10 down 
        row 7
        overlay title v-titpro + " ".

form
    ttproduaux.nome  column-label "Produtos"  format "x(16)"
    ttproduaux.qtdmerca    column-label "QTotal"            format ">>>>>>>9" 
    ttproduaux.qtdmercaent column-label "QEntra"             format ">>>>>>>9"
    ttproduaux.qtdsaldo column-label     "QSaldo"            format "->>>>>>>9" 
    ttproduaux.vlrsaldo column-label "VSaldo"         format "->>>>,>>9.99"
    ttproduaux.qtdatrasado column-label  "QAtraso"      format ">>>>>>>9"
    ttproduaux.vlratrasado column-label  "VAtraso" format ">>>>,>>9.99"
    with frame f-produaux
        width 80
        10 down 
        row 7
        overlay title v-titpro + " ".
/*
form header 
        "----<FABRICANTES>" + fill("-",69)  format "x(80)"
     with frame f-fabri no-underline OVERLAY. 
*/
form
    ttfabri.nome  column-label "Fabricantes"  format "x(16)"
    ttfabri.qtdmerca    column-label "QTotal"            format ">>>>>>>9" 
    ttfabri.qtdmercaent column-label "QEntra"             format ">>>>>>>9"
    ttfabri.qtdsaldo column-label     "QSaldo"            format "->>>>>>>9" 
    ttfabri.vlrsaldo column-label "VSaldo"         format "->>>>,>>9.99"
    ttfabri.qtdatrasado column-label  "QAtraso"      format ">>>>>>>9"
    ttfabri.vlratrasado column-label  "VAtraso"  format ">>>>,>>9.99"
    with frame f-fabri
        width 80
        10 down 
        row 7
        overlay title v-titfab + " ".

 form
    ttfabriaux.nome  column-label "Fabricantes"  format "x(16)"
    ttfabriaux.qtdmerca    column-label "QTotal"            format ">>>>>>>9" 
    ttfabriaux.qtdmercaent column-label "QEntra"             format ">>>>>>>9"
    ttfabriaux.qtdsaldo column-label     "QSaldo"            format "->>>>>>>9" 
    ttfabriaux.vlrsaldo column-label "VSaldo"         format "->>>>,>>9.99"
    ttfabriaux.qtdatrasado column-label  "QAtraso"      format ">>>>>>>9"
    ttfabriaux.vlratrasado column-label  "VAtraso"  format ">>>>,>>9.99"
    with frame f-fabriaux
        width 80
        10 down 
        row 7
        overlay title v-titfab + " ".

def var tqtdmerca like ttclase.qtdmerca       format ">>>>>>>9".
def var tqtdmercaent like ttclase.qtdmercaent format ">>>>>>>9".
def var tqtdsaldo like ttclase.qtdsaldo       format "->>>>>>>9".
def var tvlrsaldo like ttclase.vlrsaldo       format "->>>>,>>9.99".
def var tqdtatrasado like ttclase.qtdatrasado format ">>>>>>>9".
def var tvlratrasado like ttclase.vlratrasado format ">>>>,>>9.99".

form "Processando.....>>> " 
    bestab.etbcod vdt-aux format "99/99/9999" pedid.pednum
    with frame f-1 1 down centered row 10 no-label no-box
    overlay.

run propedid.
hide frame f-1 no-pause.
form with frame f-tot.
 
l0: repeat :
    if par-etbcod <> 999
    then find first estab where estab.etbcod = par-etbcod no-lock.
    if par-vencod = 1
    then     
    l1: repeat:
        assign
        tqtdmerca = 0 tqtdmercaent = 0 tqtdsaldo = 0
        tvlrsaldo = 0 tqdtatrasado = 0 tvlratrasado = 0
        .

        for each ttcomprador where ttcomprador.etbcod = par-etbcod: 
            assign
            tqtdmerca = tqtdmerca + ttcomprador.qtdmerca
            tqtdmercaent = tqtdmercaent + ttcomprador.qtdmercaent
            tqtdsaldo = tqtdsaldo + ttcomprador.qtdsaldo
            tvlrsaldo = tvlrsaldo + ttcomprador.vlrsaldo
            tqdtatrasado = tqdtatrasado + ttcomprador.qtdatrasado
            tvlratrasado = tvlratrasado + ttcomprador.vlratrasado.
        end.    

 
        disp "        TOTAIS   "
             tqtdmerca   tqtdmercaent   tqtdsaldo  
             tvlrsaldo   tqdtatrasado   tvlratrasado 
             with frame f-tot 1 down no-box no-label
             row 21 .
 
 
        assign 
            a-seeid = -1 a-recid = -1 a-seerec = ? 
            v-titcom  = " COMPRADORES " +  " DO ESTAB. " + 
                if par-etbcod <> 999
                then string(estab.etbnom) else "EMPRESA"
                .
    
        {sklcls.i 
            &help   = "ENTER=Seleciona F1=Sair F4=Retorna"
            &File   = ttcomprador 
            &CField = ttcomprador.comnom 
            &ofield = "
                    ttcomprador.qtdmerca 
                    ttcomprador.qtdmercaent
                    ttcomprador.qtdsaldo
                    ttcomprador.vlrsaldo
                    ttcomprador.qtdatrasado
                    ttcomprador.vlratrasado
                    "
            &Where = " ttcomprador.etbcod = par-etbcod "
            &AftSelect1 = " 
                       if keyfunction(lastkey) <> ""RETURN"" and
                          keyfunction(lastkey) <> ""GO""
                       then next keys-loop.
                       if keyfunction(lastkey) = ""GO""
                       then leave keys-loop.
                       p-comcod = ttcomprador.comcod. 
                       clear frame f-comprador all no-pause.
                        /*
                       display  
                             ttcomprador.comnom 
                             ttcomprador.qtdmerca
                             ttcomprador.qtdmercaent
                             ttcomprador.qtdsaldo
                             ttcomprador.vlrsaldo
                             ttcomprador.qtdatrasado
                             ttcomprador.vlratrasado
                             with frame f-comprador. */
                       pause 0.
                       leave l1. "
            &LockType = " use-index platot " 
            &Form = " frame f-comprador " 
            }
        
        if keyfunction(lastkey) = "END-ERROR" or
           keyfunction(lastkey) = "GO"
        then do: 
            hide frame f-comprador no-pause. 
            leave l0.
        end.
    end. 
    if par-vencod <= 1
    then do:

    assign
        tqtdmerca = 0 tqtdmercaent = 0 tqtdsaldo = 0
        tvlrsaldo = 0 tqdtatrasado = 0 tvlratrasado = 0
        .

    for each ttcateg where ttcateg.etbcod = par-etbcod and
                           ttcateg.comcod = p-comcod:
        assign
            tqtdmerca = tqtdmerca + ttcateg.qtdmerca
            tqtdmercaent = tqtdmercaent + ttcateg.qtdmercaent
            tqtdsaldo = tqtdsaldo + ttcateg.qtdsaldo
            tvlrsaldo = tvlrsaldo + ttcateg.vlrsaldo
            tqdtatrasado = tqdtatrasado + ttcateg.qtdatrasado
            tvlratrasado = tvlratrasado + ttcateg.vlratrasado.
    end.    

 
    disp "        TOTAIS   "
             tqtdmerca   tqtdmercaent   tqtdsaldo  
             tvlrsaldo   tqdtatrasado   tvlratrasado 
             with frame f-tot 1 down no-box no-label
             row 21 .
 
    assign 
            a-seeid = -1 a-recid = -1 a-seerec = ? 
            v-titcat  = " CATEGORIAS " +  " DO ESTAB. " + 
                if par-etbcod <> 999
                then string(estab.etbnom) else "EMPRESA"
                .
    
    {sklcls.i 
        &help   = "ENTER=Seleciona F1=Sair F4=Retorna"
        &File   = ttcateg 
        &CField = ttcateg.catnom 
        &ofield = "
                    ttcateg.qtdmerca 
                    ttcateg.qtdmercaent
                    ttcateg.qtdsaldo
                    ttcateg.vlrsaldo
                    ttcateg.qtdatrasado
                    ttcateg.vlratrasado
                    "
        &Where = " ttcateg.etbcod = par-etbcod and
                   ttcateg.comcod = p-comcod " 
        &AftSelect1 = " 
                       if keyfunction(lastkey) <> ""RETURN"" and
                          keyfunction(lastkey) <> ""GO""
                       then next keys-loop.
                       hide frame f-tot no-pause.              
                       p-catcod = ttcateg.catcod. 
                       clear frame f-categ all no-pause.
                       pause 0.
                       run pro-op ( ""p-catcod"" ) .
                       if keyfunction(lastkey) = ""END-ERROR""
                       then next l0. 
                       leave keys-loop. "
        &LockType = " use-index valor " 
        &Form = " frame f-categ " 
         }
        
    if keyfunction(lastkey) = "END-ERROR"
    then do: 
        hide frame f-categ no-pause.
        if par-vencod <> 0
        then next l0.
        else leave l0 .
    end.                   
    if keyfunction(lastkey) = "GO"
    then do:
        hide frame f-categ no-pause.
        leave l0.
    end.     
    l1: repeat: 
        hide frame f-categ no-pause.
        hide frame f-tot no-pause.
        assign
            tqtdmerca = 0 tqtdmercaent = 0 tqtdsaldo = 0
            tvlrsaldo = 0 tqdtatrasado = 0 tvlratrasado = 0
            .
        for each ttsetor where ttsetor.etbcod = par-etbcod and
                           ttsetor.comcod = p-comcod and
                           ttsetor.catcod = p-catcod
                           :
            assign
            tqtdmerca = tqtdmerca + ttsetor.qtdmerca
            tqtdmercaent = tqtdmercaent + ttsetor.qtdmercaent
            tqtdsaldo = tqtdsaldo + ttsetor.qtdsaldo
            tvlrsaldo = tvlrsaldo + ttsetor.vlrsaldo
            tqdtatrasado = tqdtatrasado + ttsetor.qtdatrasado
            tvlratrasado = tvlratrasado + ttsetor.vlratrasado.
        end.    

 
        disp "        TOTAIS   "
             tqtdmerca   tqtdmercaent   tqtdsaldo  
             tvlrsaldo   tqdtatrasado   tvlratrasado 
             with frame f-tot 1 down no-box no-label
             row 21 .
 
        assign 
            a-seeid = -1 a-recid = -1 a-seerec = ? 
            v-titset  = " SETORES DA CATEGORIA " + 
                               string(TTCATEG.catnom)  + " D0 ESTAB " + 
                if par-etbcod <> 999
                then string(estab.etbnom) else "EMPRESA"
                 .
 
    
    {sklcls.i 
        &help   = "ENTER=Seleciona F1=Sair F4=Retorna"
        &File   = ttsetor 
        &CField = ttsetor.nome 
        &ofield = "
                    ttsetor.nome 
                    ttsetor.qtdmerca 
                    ttsetor.qtdmercaent
                    ttsetor.qtdsaldo
                    ttsetor.vlrsaldo
                    ttsetor.qtdatrasado
                    ttsetor.vlratrasado
                    "
        &Where = " ttsetor.etbcod = par-etbcod and
                   ttsetor.comcod = p-comcod and
                   ttsetor.catcod = p-catcod " 
        &AftSelect1 = " 
                       if keyfunction(lastkey) <> ""RETURN"" and
                          keyfunction(lastkey) <> ""GO""
                       then next keys-loop.
                                     
                       hide frame f-tot no-pause.
                       p-setor = ttsetor.setcod. 
                       clear frame f-setor all no-pause.
                       display  
                             ttsetor.nome 
                             ttsetor.qtdmerca
                             ttsetor.qtdmercaent
                             ttsetor.qtdsaldo
                             ttsetor.vlrsaldo
                             ttsetor.qtdatrasado
                             ttsetor.vlratrasado
                             with frame f-setor.
                       pause 0.
                       run pro-op ( ""p-setor"" ) .
                       if keyfunction(lastkey) = ""END-ERROR""
                       then next l1. 
                       leave keys-loop. "
        &LockType = " use-index valor " 
        &Form = " frame f-setor " 
         }
        
    if keyfunction(lastkey) = "END-ERROR"
    then do: 
        hide frame f-setor no-pause.
        leave l1 .
    end.                   
    if keyfunction(lastkey) = "GO"
    then do:
        hide frame f-setor no-pause.
        leave l0.
    end.     
    l2: repeat :
        assign
            tqtdmerca = 0 tqtdmercaent = 0 tqtdsaldo = 0
            tvlrsaldo = 0 tqdtatrasado = 0 tvlratrasado = 0
            .
        for each ttgrupo where ttgrupo.etbcod = par-etbcod and
                           ttgrupo.comcod = p-comcod and
                           ttgrupo.catcod = p-catcod and
                           ttgrupo.setcod = p-setor
                           :
            assign
            tqtdmerca = tqtdmerca + ttgrupo.qtdmerca
            tqtdmercaent = tqtdmercaent + ttgrupo.qtdmercaent
            tqtdsaldo = tqtdsaldo + ttgrupo.qtdsaldo
            tvlrsaldo = tvlrsaldo + ttgrupo.vlrsaldo
            tqdtatrasado = tqdtatrasado + ttgrupo.qtdatrasado
            tvlratrasado = tvlratrasado + ttgrupo.vlratrasado.
        end.    

 
        disp "        TOTAIS   "
             tqtdmerca   tqtdmercaent   tqtdsaldo  
             tvlrsaldo   tqdtatrasado   tvlratrasado 
             with frame f-tot 1 down no-box no-label
             row 21 .
             
        assign 
            a-seeid = -1 a-recid = -1 a-seerec = ? 
            v-titgru  = " GRUPOS DO SETOR " + 
                               string(ttsetor.nome)  + " DO ESTAB. " + 
                if par-etbcod <> 999
                then string(estab.etbnom) else "EMPRESA"
                .
 
                    
        {sklcls.i 
            &help = "ENTER=Seleciona F1=Sair F4=Retorna"
            &File   = ttgrupo 
            &CField = ttgrupo.nome 
            &ofield = " 
                       ttgrupo.nome 
                       ttgrupo.qtdmerca 
                       ttgrupo.qtdmercaent
                       ttgrupo.qtdsaldo
                       ttgrupo.vlrsaldo
                       ttgrupo.qtdatrasado
                       ttgrupo.vlratrasado
                        "
            &Where = " ttgrupo.etbcod = par-etbcod and
                       ttgrupo.comcod = p-comcod and 
                       ttgrupo.catcod = p-catcod and
                       ttgrupo.setcod = p-setor " 
            &AftSelect1 = " 
                    if keyfunction(lastkey) <> ""RETURN"" and
                       keyfunction(lastkey) <> ""GO""
                    then next keys-loop.
                        hide frame f-tot no-pause.             
                        p-grupo = ttgrupo.grupo-clacod. 
                            clear frame f-grupo all no-pause.
                        display 
                           ttgrupo.nome 
                                ttgrupo.qtdmerca
                                ttgrupo.qtdmercaent
                                ttgrupo.qtdsaldo
                                ttgrupo.vlrsaldo
                                ttgrupo.qtdatrasado
                                ttgrupo.vlratrasado
                            with frame f-grupo.
                         pause 0.
                         run pro-op ( ""p-grupo"" ) .
                       if keyfunction(lastkey) = ""END-ERROR""
                       then next l2. 
                       leave keys-loop. "
            &LockType = " use-index valor " 
            &Form = " frame f-grupo " 
            }. 
                     
        if keyfunction(lastkey) = "END-ERROR"
        then do: 
            hide frame f-grupo no-pause. 
            leave l2.
        end.
        if keyfunction(lastkey) = "GO"
        then do:
            hide frame f-grupo no-pause.
            leave l0.
        end. 
        l3: repeat :
            assign
                tqtdmerca = 0 tqtdmercaent = 0 tqtdsaldo = 0
                tvlrsaldo = 0 tqdtatrasado = 0 tvlratrasado = 0
                .
            for each ttclase where ttclase.etbcod = par-etbcod and
                           ttclase.comcod = p-comcod and
                           ttclase.catcod = p-catcod and
                           ttclase.setcod = p-setor and
                           ttclase.grupo-clacod = p-grupo
                           :
                assign
                tqtdmerca = tqtdmerca + ttclase.qtdmerca
                tqtdmercaent = tqtdmercaent + ttclase.qtdmercaent
                tqtdsaldo = tqtdsaldo + ttclase.qtdsaldo
                tvlrsaldo = tvlrsaldo + ttclase.vlrsaldo
                tqdtatrasado = tqdtatrasado + ttclase.qtdatrasado
                tvlratrasado = tvlratrasado + ttclase.vlratrasado.
            end.    

 
            disp "        TOTAIS   "
             tqtdmerca   tqtdmercaent   tqtdsaldo  
             tvlrsaldo   tqdtatrasado   tvlratrasado 
             with frame f-tot 1 down no-box no-label
             row 21 .
        
            assign 
                a-seeid = -1 a-recid = -1 a-seerec = ?
                v-titcla  = " CLASSES DO GRUPO " + 
                               string(ttgrupo.nome)  + " DO ESTAB. " + 
                if par-etbcod <> 999
                then string(estab.etbnom) else "EMPRESA"
                 .
 
            {sklcls.i 
                &help = "ENTER=Seleciona F1=Sair F4=Retorna"
                &File   = ttclase 
                &CField = ttclase.nome 
                &ofield = " 
                                ttclase.nome 
                                ttclase.qtdmerca
                                ttclase.qtdmercaent
                                ttclase.qtdsaldo
                                ttclase.vlrsaldo
                                ttclase.qtdatrasado
                                ttclase.vlratrasado
                                 "
                &Where = "  ttclase.etbcod = par-etbcod and
                            ttclase.comcod = p-comcod and
                            ttclase.catcod = p-catcod and
                                        ttclase.setcod = p-setor   and
                                        ttclase.grupo-clacod = p-grupo " 
                &AftSelect1 = " 
                            if keyfunction(lastkey) <> ""RETURN"" and
                            keyfunction(lastkey) <> ""GO""
                            then next keys-loop.
                            hide frame f-tot no-pause.         
                            p-clase = ttclase.clase-clacod. 
                            clear frame f-clase all no-pause.
                            display     
                                ttclase.nome 
                                ttclase.qtdmerca 
                                ttclase.qtdmercaent
                                ttclase.qtdsaldo
                                ttclase.vlrsaldo
                                ttclase.qtdatrasado
                                ttclase.vlratrasado
                                with frame f-clase.
                            pause 0.

                            run pro-op ( ""p-clase"" ) .
                            if keyfunction(lastkey) = ""END-ERROR""
                            then next l3. 
                            leave keys-loop. "
                &LockType = "use-index platot " 
                &Form = " frame f-clase " 
                }                    
                        
            if keyfunction(lastkey) = "END-ERROR" 
            then do:  
                hide frame f-clase no-pause.  
                leave l3. 
            end.
            if keyfunction(lastkey) = "GO"
            then do:
                hide frame f-clase no-pause.
                leave l0.
            end. 
            l4: repeat :
                assign
                tqtdmerca = 0 tqtdmercaent = 0 tqtdsaldo = 0
                tvlrsaldo = 0 tqdtatrasado = 0 tvlratrasado = 0
                .
                for each ttsclase where ttsclase.etbcod = par-etbcod and
                           ttsclase.comcod = p-comcod and
                           ttsclase.catcod = p-catcod and
                           ttsclase.setcod = p-setor and
                           ttsclase.grupo-clacod = p-grupo  and
                           ttsclase.clase-clacod = p-clase
                           :
                    assign
                    tqtdmerca = tqtdmerca + ttsclase.qtdmerca
                    tqtdmercaent = tqtdmercaent + ttsclase.qtdmercaent
                    tqtdsaldo = tqtdsaldo + ttsclase.qtdsaldo
                    tvlrsaldo = tvlrsaldo + ttsclase.vlrsaldo
                    tqdtatrasado = tqdtatrasado + ttsclase.qtdatrasado
                    tvlratrasado = tvlratrasado + ttsclase.vlratrasado.
                end.    

 
                disp "        TOTAIS   "
                tqtdmerca   tqtdmercaent   tqtdsaldo  
                tvlrsaldo   tqdtatrasado   tvlratrasado 
                with frame f-tot 1 down no-box no-label
                row 21 .

                assign 
                    a-seeid = -1 a-recid = -1 a-seerec = ? 
                    v-titscla  = " SUB-CLASSES DA CLASSE " + 
                               string(ttclase.nome)  + " DO ESTAB. " + 
                if par-etbcod <> 999
                then string(estab.etbnom) else "EMPRESA"
                 .
 

                {sklcls.i 
                    &help = "ENTER=Seleciona F1=Sair F4=Retorna"
                    &File   = ttsclase 
                    &CField = ttsclase.nome 
                    &ofield = "
                                ttsclase.nome 
                                ttsclase.qtdmerca 
                                ttsclase.qtdmercaent
                                ttsclase.qtdsaldo
                                ttsclase.vlrsaldo
                                ttsclase.qtdatrasado
                                ttsclase.vlratrasado
                                "
                    &Where = "  ttsclase.etbcod = par-etbcod and
                                ttsclase.comcod = p-comcod and
                                ttsclase.catcod = p-catcod and
                                        ttsclase.setcod = p-setor   and
                                        ttsclase.grupo-clacod = p-grupo and
                                        ttsclase.clase-clacod = p-clase
                                        " 
                    &AftSelect1 = " 
                                    if keyfunction(lastkey) <> ""RETURN"" and
                                       keyfunction(lastkey) <> ""GO""
                                    then next keys-loop.
                                    hide frame f-tot no-pause.   
                                    p-sclase = ttsclase.sclase-clacod. 
                                    clear frame f-sclase all no-pause.
                                    disp
                                        ttsclase.nome 
                                        ttsclase.qtdmerca 
                                        ttsclase.qtdmercaent
                                        ttsclase.qtdsaldo
                                        ttsclase.vlrsaldo
                                        ttsclase.qtdatrasado
                                        ttsclase.vlratrasado
                                    with frame f-sclase.
                                    pause 0.
                                    run pro-op ( ""p-sclase"" ) .
                       if keyfunction(lastkey) = ""END-ERROR""
                       then next l4. 
                                    leave keys-loop. "
                    &LockType = " use-index platot " 
                    &Form = " frame f-sclase " 
                     }                    

                if keyfunction(lastkey) = "END-ERROR"
                then do: 
                    hide frame f-sclase no-pause. 
                    leave l4.
                end.
                if keyfunction(lastkey) = "GO"
                then do:
                    hide frame f-sclase no-pause.
                    leave l0.
                end. 

                l5: repeat:
                    disp vfapro with frame f-esc 1 down
                                 centered color with/black no-label 
                                 overlay row 11.
                    choose field vfapro with frame f-esc.
                            
                    hide frame f-esc no-pause.
                    if frame-index = 1
                    then do:
                         clear frame f-esc all.
                         hide frame f-esc no-pause.
                         assign
                tqtdmerca = 0 tqtdmercaent = 0 tqtdsaldo = 0
                tvlrsaldo = 0 tqdtatrasado = 0 tvlratrasado = 0
                .
                for each ttprodu where ttprodu.etbcod = par-etbcod and
                           ttprodu.comcod = p-comcod and
                           ttprodu.catcod = p-catcod and
                           ttprodu.setcod = p-setor and
                           ttprodu.grupo-clacod = p-grupo and
                           ttprodu.clase-clacod = p-clase and
                           ttprodu.sclase-clacod = p-sclase
                           :
                    assign
                    tqtdmerca = tqtdmerca + ttprodu.qtdmerca
                    tqtdmercaent = tqtdmercaent + ttprodu.qtdmercaent
                    tqtdsaldo = tqtdsaldo + ttprodu.qtdsaldo
                    tvlrsaldo = tvlrsaldo + ttprodu.vlrsaldo
                    tqdtatrasado = tqdtatrasado + ttprodu.qtdatrasado
                    tvlratrasado = tvlratrasado + ttprodu.vlratrasado.
                end.    

 
                disp "        TOTAIS   "
                tqtdmerca   tqtdmercaent   tqtdsaldo  
                tvlrsaldo   tqdtatrasado   tvlratrasado 
                with frame f-tot 1 down no-box no-label
                row 21 .


                         assign  
                            a-seeid = -1 a-recid = -1 a-seerec = ? 
                            v-titpro  = " PRODUTOS DA SUB-CLASSE" + 
                               strinG(ttsclase.nome) + " DO ESTAB. " + 
                        if par-etbcod <> 999
                        then string(estab.etbnom) else "EMPRESA"
                        .
                            
                        {sklcls.i 
                            &help = "F1=Sair F4=Retorna"
                            &File   = ttprodu 
                            &CField = ttprodu.nome 
                            &ofield = "
                                ttprodu.nome 
                                ttprodu.qtdmerca
                                ttprodu.qtdmercaent
                                ttprodu.qtdsaldo
                                ttprodu.vlrsaldo
                                ttprodu.qtdatrasado
                                ttprodu.vlratrasado
                                "
                            &Where = "  ttprodu.etbcod = par-etbcod and
                                        ttprodu.comcod = p-comcod and
                                        ttprodu.catcod = p-catcod and
                                        ttprodu.setcod = p-setor   and
                                        ttprodu.grupo-clacod = p-grupo and
                                        ttprodu.clase-clacod = p-clase and
                                        ttprodu.sclase-clacod = p-sclase
                                        " 
                            &AftSelect1 = " 
                                     if keyfunction(lastkey) <> ""RETURN"" and
                                     keyfunction(lastkey) <> ""GO""
                                     then next keys-loop.
                                     else leave keys-loop.
                                    "
                            &LockType = " use-index platot " 
                            &Form = " frame f-produ " 
                        }.                    

                        if keyfunction(lastkey) = "END-ERROR"
                        then do:
                            hide frame f-produ no-pause.
                            leave l5.
                        end.
                        if keyfunction(lastkey) = "GO"
                        then do:
                            hide frame f-produ no-pause.
                            leave l0.
                        end.
                    end.
                    else do:
                        clear frame f-esc all.
                        hide frame f-esc no-pause.

                        assign
                tqtdmerca = 0 tqtdmercaent = 0 tqtdsaldo = 0
                tvlrsaldo = 0 tqdtatrasado = 0 tvlratrasado = 0
                .
                for each ttfabri where ttfabri.etbcod = par-etbcod and
                           ttfabri.comcod = p-comcod and
                           ttfabri.catcod = p-catcod and
                           ttfabri.setcod = p-setor and
                           ttfabri.grupo-clacod = p-grupo and
                           ttfabri.clase-clacod = p-clase and
                           ttfabri.sclase-clacod = p-sclase
                           :
                    assign
                    tqtdmerca = tqtdmerca + ttfabri.qtdmerca
                    tqtdmercaent = tqtdmercaent + ttfabri.qtdmercaent
                    tqtdsaldo = tqtdsaldo + ttfabri.qtdsaldo
                    tvlrsaldo = tvlrsaldo + ttfabri.vlrsaldo
                    tqdtatrasado = tqdtatrasado + ttfabri.qtdatrasado
                    tvlratrasado = tvlratrasado + ttfabri.vlratrasado.
                end.    

 
                disp "        TOTAIS   "
                tqtdmerca   tqtdmercaent   tqtdsaldo  
                tvlrsaldo   tqdtatrasado   tvlratrasado 
                with frame f-tot 1 down no-box no-label
                row 21 .


                        assign
                            a-seeid = -1 a-recid = -1 a-seerec = ? 
                            v-titfab  = " FABRICABTES DA SUB-CLASSE " + 
                               string(ttsclase.nome)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .

                        {sklcls.i 
                            &help = "F1=Sair F4=Retorna"
                            &File   = ttfabri 
                            &CField = ttfabri.nome 
                            &ofield = "
                                ttfabri.nome 
                                ttfabri.qtdmerca 
                                ttfabri.qtdmercaent
                                ttfabri.qtdsaldo
                                ttfabri.vlrsaldo
                                ttfabri.qtdatrasado
                                ttfabri.vlratrasado
                                "
                            &Where = "  ttfabri.etbcod = par-etbcod and
                                        ttfabri.comcod = p-comcod and 
                                        ttfabri.catcod = p-catcod and      
                                        ttfabri.setcod = p-setor   and
                                        ttfabri.grupo-clacod = p-grupo and
                                        ttfabri.clase-clacod = p-clase and
                                        ttfabri.sclase-clacod = p-sclase
                                        " 
                            &aftselect1 = "  
                                   if keyfunction(lastkey) <> ""RETURN"" and
                                      keyfunction(lastkey) <> ""GO""
                                   then next keys-loop.
                                   else leave keys-loop.  
                                    "
                            &LockType = " use-index platot " 
                            &Form = " frame f-fabri " 
                        }.                    

                        if keyfunction(lastkey) = "END-ERROR"
                        then do:
                             hide frame f-fabri no-pause.
                             leave l5.
                        end.
                        if keyfunction(lastkey) = "GO"
                        then do:
                            hide frame f-fabri no-pause.
                            leave l0.
                        end.                  
                    end.
                end.        
            end. 
        end.
    end. 
    end.
    end.
    else do:
    end.     
    hide frame f-1 no-pause.  
end.
hide frame f-comprador no-pause.
hide frame f-setor no-pause.
hide frame f-grupo no-pause.
hide frame f-clase no-pause.
hide frame f-sclase no-pause.
hide frame f-produ no-pause.
hide frame f-fabri no-pause.

PROCEDURE propedid.

   for each bestab where
            (if vetbcod > 0
             then bestab.etbcod = vetbcod else true) no-lock:
   
        disp bestab.etbcod with frame f-1.
        pause 0.
        do vdt-aux = vdti to vdtf:
            disp vdt-aux with frame f-1.
            pause 0.
            for each pedid where pedid.pedtdc = p-pedtdc
                    and pedid.etbcod = bestab.etbcod 
                    and pedid.peddat = vdt-aux no-lock.
                if p-forcod > 0 and
                   pedid.clfcod <> p-forcod
                then next.   
                disp pedid.pednum with frame f-1.
                pause 0.
                find compr where compr.comcod = pedid.comcod no-lock no-error.
                if par-vencod = 0
                then p-comcod = 0.
                else p-comcod = compr.comcod.
                
                for each liped where liped.etbcod = pedid.etbcod and
                             liped.pedtdc = pedid.pedtdc  and
                             liped.pednum = pedid.pednum no-lock:

                    if vetbcod = 0
                    then aux-etbcod = 999. else aux-etbcod = vetbcod.

                    run criatt.
                    
                end.
            end.            
        end.
    end.

end  procedure.


procedure criatt.

    def buffer bliped for liped.
      

    find produ where produ.procod = liped.procod no-lock no-error.
    if not avail produ then next.   
    find sclase where sclase.clacod = produ.clacod no-lock no-error.
    if not avail sclase
    then next.
   
    find clase where clase.clacod = sclase.clasup  no-lock.
    find grupo where grupo.clacod = clase.clasup   no-lock.
    find tsetor where tsetor.clacod = grupo.clasup no-lock.
    find categoria where categoria.catcod = produ.catcod no-lock.
   
       
    find fabri of produ no-lock.
 
    find first ttcateg where 
                    ttcateg.etbcod = aux-etbcod and
                    ttcateg.comcod = p-comcod and
                    ttcateg.catcod = categoria.catcod
                no-error.
    if not avail ttcateg
    then do:
        create ttcateg.
        assign 
            ttcateg.etbcod = aux-etbcod
            ttcateg.comcod = p-comcod
            ttcateg.catcod = categoria.catcod 
            ttcateg.catnom = categoria.catnom 
            .
    end. 

    find first ttsetor where 
                    ttsetor.etbcod = aux-etbcod and
                    ttsetor.comcod = p-comcod and
                    ttsetor.catcod = categoria.catcod and
                    ttsetor.setcod = tsetor.clacod
                                  no-error.
    if not avail ttsetor
    then do:
        create ttsetor.
        assign 
            ttsetor.etbcod = aux-etbcod
            ttsetor.comcod = p-comcod
            ttsetor.setcod = tsetor.clacod 
            ttsetor.catcod = categoria.catcod
            ttsetor.nome   = tsetor.clanom 
            .
    end. 

    find first ttgrupo where 
                    ttgrupo.etbcod = aux-etbcod and
                    ttgrupo.comcod = p-comcod and
                    ttgrupo.catcod = categoria.catcod and
                    ttgrupo.setcod = tsetor.clacod and
                    ttgrupo.grupo-clacod = grupo.clacod
                no-error.
    if not avail ttgrupo
    then do:
        create ttgrupo.
        assign 
            ttgrupo.etbcod = aux-etbcod
            ttgrupo.comcod = p-comcod
            ttgrupo.catcod = categoria.catcod
            ttgrupo.setcod = tsetor.clacod
            ttgrupo.grupo-clacod = grupo.clacod
            ttgrupo.nome   = grupo.clanom.
    end. 

    find first ttclase where 
                    ttclase.etbcod       = aux-etbcod and
                    ttclase.comcod       = p-comcod and
                    ttclase.catcod       = categoria.catcod and  
                    ttclase.setcod       = tsetor.clacod and
                    ttclase.grupo-clacod = grupo.clacod and
                    ttclase.clase-clacod = clase.clacod
                no-error.
    if not avail ttclase
    then do:
          create ttclase.
          assign 
              ttclase.etbcod          = aux-etbcod
              ttclase.comcod     = p-comcod
              ttclase.catcod  = categoria.catcod
              ttclase.setcod          = tsetor.clacod 
              ttclase.grupo-clacod    = grupo.clacod
              ttclase.clase-clacod    = clase.clacod
              ttclase.nome            = clase.clanom.
    end. 

    find first ttsclase where 
                    ttsclase.etbcod        = aux-etbcod and
                    ttsclase.comcod        = p-comcod and
                    ttsclase.catcod   = categoria.catcod and
                    ttsclase.setcod        = tsetor.clacod and
                    ttsclase.grupo-clacod  = grupo.clacod and
                    ttsclase.clase-clacod  = clase.clacod and
                    ttsclase.sclase-clacod = sclase.clacod
                                    no-error.
    if not avail ttsclase
    then do:
        create ttsclase.
        assign 
            ttsclase.etbcod          = aux-etbcod
            ttsclase.comcod = p-comcod
            ttsclase.catcod = categoria.catcod
            ttsclase.setcod          = tsetor.clacod
            ttsclase.grupo-clacod    = grupo.clacod
            ttsclase.clase-clacod    = clase.clacod
            ttsclase.sclase-clacod   = sclase.clacod
            ttsclase.nome            = sclase.clanom.
    end. 

    find first ttprodu where 
                    ttprodu.etbcod        = aux-etbcod and
                    ttprodu.comcod        = p-comcod and 
                    ttprodu.catcod        = categoria.catcod and    
                    ttprodu.setcod        = tsetor.clacod and
                    ttprodu.grupo-clacod  = grupo.clacod and
                    ttprodu.clase-clacod  = clase.clacod and
                    ttprodu.sclase-clacod = sclase.clacod and
                    ttprodu.procod        = produ.procod  
                                    no-error.
    if not avail ttprodu
    then do:
        create ttprodu.
        assign 
            ttprodu.etbcod          = aux-etbcod
            ttprodu.comcod = p-comcod
            ttprodu.catcod = categoria.catcod
            ttprodu.setcod          = tsetor.clacod 
            ttprodu.grupo-clacod    = grupo.clacod
            ttprodu.clase-clacod    = clase.clacod
            ttprodu.sclase-clacod   = sclase.clacod
            ttprodu.procod          = produ.procod
            ttprodu.nome            = produ.pronom.
    end.  

    find first ttfabri where 
                    ttfabri.etbcod        = aux-etbcod and
                    ttfabri.comcod  = p-comcod and
                    ttfabri.catcod = categoria.catcod and
                    ttfabri.setcod        = tsetor.clacod  and
                    ttfabri.grupo-clacod  = grupo.clacod and
                    ttfabri.clase-clacod  = clase.clacod and
                    ttfabri.sclase-clacod = sclase.clacod and
                    ttfabri.fabcod        = produ.fabcod  
                                    no-error.
   if not avail ttfabri
   then do:
       create ttfabri.
       assign 
           ttfabri.etbcod          = aux-etbcod
           ttfabri.comcod = p-comcod
           ttfabri.catcod = categoria.catcod 
           ttfabri.setcod          = tsetor.clacod 
           ttfabri.grupo-clacod    = grupo.clacod
           ttfabri.clase-clacod    = clase.clacod
           ttfabri.sclase-clacod   = sclase.clacod
           ttfabri.fabcod          = produ.fabcod
           ttfabri.nome            = fabri.fabnom.
    end. 
    run totaliza.        
end.
PROCEDURE totaliza.
            assign 
            ttcateg.qtdatrasado   = ttcateg.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttcateg.vlratrasado      = ttcateg.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then ((liped.lipqtd - liped.lipent) *
                                 liped.lippreco           )
                            else 0
            ttcateg.qtdposterior  = ttcateg.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttcateg.qtdmerca      = ttcateg.qtdmerca + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd                            
                            else 0
            ttcateg.qtdmercaent   = ttcateg.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent
                            else 0
            ttcateg.qtdsaldo      = ttcateg.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd - liped.lipent
                            else 0
            ttcateg.vlrsaldo      = ttcateg.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  (liped.lipqtd - liped.lipent) *
                                            liped.lippreco
                            else 0.

 
        assign 
            ttsetor.qtdatrasado   = ttsetor.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttsetor.vlratrasado      = ttsetor.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then ((liped.lipqtd - liped.lipent) *
                                 liped.lippreco           )
                            else 0
            ttsetor.qtdposterior  = ttsetor.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttsetor.qtdmerca      = ttsetor.qtdmerca + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd                            
                            else 0
            ttsetor.qtdmercaent   = ttsetor.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent
                            else 0
            ttsetor.qtdsaldo      = ttsetor.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd - liped.lipent
                            else 0
            ttsetor.vlrsaldo      = ttsetor.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  (liped.lipqtd - liped.lipent) *
                                            liped.lippreco
                            else 0.

        assign 
            ttgrupo.qtdatrasado   = ttgrupo.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttgrupo.vlratrasado      = ttgrupo.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then ((liped.lipqtd - liped.lipent) *
                                 liped.lippreco           )
                            else 0
            ttgrupo.qtdposterior  = ttgrupo.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0.
            ttgrupo.qtdmerca      = ttgrupo.qtdmerca + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd
                            else 0.
            ttgrupo.qtdmercaent   = ttgrupo.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent
                            else 0.
            ttgrupo.qtdsaldo      = ttgrupo.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd - liped.lipent
                            else 0.
            ttgrupo.vlrsaldo      = ttgrupo.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  (liped.lipqtd - liped.lipent) *
                                            liped.lippreco
                            else 0.
                

        assign 
            ttclase.qtdatrasado   = ttclase.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttclase.vlratrasado      = ttclase.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent) *
                                 liped.lippreco           
                            else 0
            ttclase.qtdposterior  = ttclase.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttclase.qtdmerca      = ttclase.qtdmerca + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd
                            else 0
            ttclase.qtdmercaent   = ttclase.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent
                            else 0
            ttclase.qtdsaldo      = ttclase.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd - liped.lipent
                            else 0
            ttclase.vlrsaldo      = ttclase.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  (liped.lipqtd - liped.lipent) *
                                            liped.lippreco
                            else 0.
                
        assign 
            ttsclase.qtdatrasado   = ttsclase.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttsclase.vlratrasado      = ttsclase.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent) *
                                 liped.lippreco           
                            else 0
            ttsclase.qtdposterior  = ttsclase.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttsclase.qtdmerca      = ttsclase.qtdmerca + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd
                            else 0
            ttsclase.qtdmercaent   = ttsclase.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent
                            else 0
            ttsclase.qtdsaldo      = ttsclase.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd - liped.lipent
                            else 0
            ttsclase.vlrsaldo      = ttsclase.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  (liped.lipqtd - liped.lipent) *
                                            liped.lippreco
                            else 0.
                
        assign 
            ttprodu.qtdatrasado   = ttprodu.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttprodu.vlratrasado      = ttprodu.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent) *
                                 liped.lippreco           
                            else 0
            ttprodu.qtdposterior  = ttprodu.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttprodu.qtdmerca      = ttprodu.qtdmerca + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd
                            else 0
            ttprodu.qtdmercaent   = ttprodu.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent
                            else 0
            ttprodu.qtdsaldo      = ttprodu.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd - liped.lipent
                            else 0
            ttprodu.vlrsaldo      = ttprodu.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  (liped.lipqtd - liped.lipent) *
                                            liped.lippreco
                            else 0.
                
        assign 
            ttfabri.qtdatrasado   = ttfabri.qtdatrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttfabri.vlratrasado      = ttfabri.vlratrasado +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent) *
                                 liped.lippreco           
                            else 0
            ttfabri.qtdposterior  = ttfabri.qtdposterior +
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0
            ttfabri.qtdmerca      = ttfabri.qtdmerca + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd
                            else 0
            ttfabri.qtdmercaent   = ttfabri.qtdmercaent + 
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipent
                            else 0
            ttfabri.qtdsaldo      = ttfabri.qtdsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then liped.lipqtd - liped.lipent
                            else 0
            ttfabri.vlrsaldo      = ttfabri.vlrsaldo +
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then  (liped.lipqtd - liped.lipent) *
                                            liped.lippreco
                            else 0.
                
end procedure.

procedure pro-op.
    
    def input parameter p-var as char.

    disp vfapro-op
         with frame f-esc-op 1 down centered color with/black 
         no-label overlay row 11.
   
    choose field vfapro-op with frame f-esc-op.
    
    clear frame f-esc-op all. 
    hide frame f-esc-op no-pause.
    
    for each ttproduaux: delete ttproduaux. end.
    for each ttfabriaux: delete ttfabriaux. end.
    assign
        tqtdmerca = 0 tqtdmercaent = 0 tqtdsaldo = 0
        tvlrsaldo = 0 tqdtatrasado = 0 tvlratrasado = 0
        .

    if frame-index = 2
    then do:
        if p-var = "p-catcod"
        then do:
                for each ttprodu where  ttprodu.etbcod = par-etbcod and
                                        ttprodu.comcod = p-comcod and
                                        ttprodu.catcod = p-catcod
                                        : 
                    create ttproduaux.
                    buffer-copy ttprodu to ttproduaux.

                    assign
                        tqtdmerca = tqtdmerca + ttprodu.qtdmerca
                        tqtdmercaent = tqtdmercaent + ttprodu.qtdmercaent
                        tqtdsaldo = tqtdsaldo + ttprodu.qtdsaldo
                        tvlrsaldo = tvlrsaldo + ttprodu.vlrsaldo
                        tqdtatrasado = tqdtatrasado + ttprodu.qtdatrasado
                        tvlratrasado = tvlratrasado + ttprodu.vlratrasado.
                end.    
                v-titpro  = " PRODUTOS DA CATEGORIA " + 
                               string(ttcateg.catnom)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
                         
        end.

        if p-var = "p-setor"
        then do:
                for each ttprodu where  ttprodu.etbcod = par-etbcod and
                                        ttprodu.comcod = p-comcod and
                                        ttprodu.catcod = p-catcod and
                                        ttprodu.setcod = p-setor
                                        : 
                    create ttproduaux.
                    buffer-copy ttprodu to ttproduaux.
                    assign
                        tqtdmerca = tqtdmerca + ttprodu.qtdmerca
                        tqtdmercaent = tqtdmercaent + ttprodu.qtdmercaent
                        tqtdsaldo = tqtdsaldo + ttprodu.qtdsaldo
                        tvlrsaldo = tvlrsaldo + ttprodu.vlrsaldo
                        tqdtatrasado = tqdtatrasado + ttprodu.qtdatrasado
                        tvlratrasado = tvlratrasado + ttprodu.vlratrasado.

                end.     
                v-titpro  = " PRODUTOS DO SETOR " + 
                               string(ttSETOR.NOME)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
             
                         
        end.
        if p-var = "p-grupo"
        then do:
                for each ttprodu where  ttprodu.etbcod = par-etbcod and
                                        ttprodu.comcod = p-comcod and
                                        ttprodu.catcod = p-catcod and
                                        ttprodu.setcod = p-setor   and
                                        ttprodu.grupo-clacod = p-grupo 
                                        : 
                    create ttproduaux.
                    buffer-copy ttprodu to ttproduaux.
                    assign
                        tqtdmerca = tqtdmerca + ttprodu.qtdmerca
                        tqtdmercaent = tqtdmercaent + ttprodu.qtdmercaent
                        tqtdsaldo = tqtdsaldo + ttprodu.qtdsaldo
                        tvlrsaldo = tvlrsaldo + ttprodu.vlrsaldo
                        tqdtatrasado = tqdtatrasado + ttprodu.qtdatrasado
                        tvlratrasado = tvlratrasado + ttprodu.vlratrasado.

                end.                 
                v-titpro  = " PRODUTOS DO GRUPO " + 
                               string(ttGRUPO.NOME)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
          
        end.
        else
        if p-var = "p-clase"
        then do:
                for each ttprodu where  ttprodu.etbcod = par-etbcod and
                                        ttprodu.comcod = p-comcod and
                                        ttprodu.catcod = p-catcod and
                                        ttprodu.setcod = p-setor   and
                                        ttprodu.grupo-clacod = p-grupo and
                                        ttprodu.clase-clacod = p-clase 
                                        : 
                    create ttproduaux.
                    buffer-copy ttprodu to ttproduaux.
                    assign
                        tqtdmerca = tqtdmerca + ttprodu.qtdmerca
                        tqtdmercaent = tqtdmercaent + ttprodu.qtdmercaent
                        tqtdsaldo = tqtdsaldo + ttprodu.qtdsaldo
                        tvlrsaldo = tvlrsaldo + ttprodu.vlrsaldo
                        tqdtatrasado = tqdtatrasado + ttprodu.qtdatrasado
                        tvlratrasado = tvlratrasado + ttprodu.vlratrasado.

                end. 
                v-titpro  = " PRODUTOS DA CLASSE " + 
                               string(ttCLASE.NOME)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
         end.
        else
        if p-var = "p-sclase"
        then do:
                for each ttprodu where  ttprodu.etbcod = par-etbcod and
                                        ttprodu.comcod = p-comcod and
                                        ttprodu.catcod = p-catcod and
                                        ttprodu.setcod = p-setor   and
                                        ttprodu.grupo-clacod = p-grupo and
                                        ttprodu.clase-clacod = p-clase and
                                        ttprodu.sclase-clacod = p-sclase
                                        : 
                    create ttproduaux.
                    buffer-copy ttprodu to ttproduaux.
                    assign
                        tqtdmerca = tqtdmerca + ttprodu.qtdmerca
                        tqtdmercaent = tqtdmercaent + ttprodu.qtdmercaent
                        tqtdsaldo = tqtdsaldo + ttprodu.qtdsaldo
                        tvlrsaldo = tvlrsaldo + ttprodu.vlrsaldo
                        tqdtatrasado = tqdtatrasado + ttprodu.qtdatrasado
                        tvlratrasado = tvlratrasado + ttprodu.vlratrasado.

                end. 
                v-titpro  = " PRODUTOS DA SUB-CLASSE " + 
                               string(ttSCLASE.NOME)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
         end.    
            disp "        TOTAIS   "
             tqtdmerca   tqtdmercaent   tqtdsaldo  
             tvlrsaldo   tqdtatrasado   tvlratrasado 
             with frame f-tot 1 down no-box no-label
             row 21 .
 
                        assign  
                            a-seeid = -1 a-recid = -1 a-seerec = ? .
                            
                        {sklcls.i 
                            &help = "F1=Sair F4=Retorna F8=Imprime"
                            &File   = ttproduaux 
                            &CField = ttproduaux.nome 
                            &ofield = "
                                ttproduaux.nome 
                                ttproduaux.qtdmerca
                                ttproduaux.qtdmercaent
                                ttproduaux.qtdsaldo
                                ttproduaux.vlrsaldo
                                ttproduaux.qtdatrasado
                                ttproduaux.vlratrasado
                                "
                            &Where = " true use-index platot "
                            &Otherkeys1 = " 
                                     if keyfunction(lastkey) <> ""RETURN"" and
                                     keyfunction(lastkey) <> ""GO"" and
                                     keyfunction(lastkey) <> ""CLEAR"" 
                                     then next keys-loop.
                                     else do:
                                        if  keyfunction(lastkey) = ""CLEAR""
                                        then do:
                                            run imp-pro.
                                            next keys-loop.
                                        end.
                                        leave keys-loop.
                                     end.
                                    "
                            &Form = " frame f-produaux " 
                        }.                    

 
    end.
                        
    else if frame-index = 3
        then do:
            if p-var = "p-catcod"
            then do:
                for each ttfabri where  ttfabri.etbcod = par-etbcod and
                                        ttfabri.comcod = p-comcod and 
                                        ttfabri.catcod = p-catcod 
                                        :
                    create ttfabriaux.
                    buffer-copy ttfabri to ttfabriaux.
                    assign
                        tqtdmerca = tqtdmerca + ttfabri.qtdmerca
                        tqtdmercaent = tqtdmercaent + ttfabri.qtdmercaent
                        tqtdsaldo = tqtdsaldo + ttfabri.qtdsaldo
                        tvlrsaldo = tvlrsaldo + ttfabri.vlrsaldo
                        tqdtatrasado = tqdtatrasado + ttfabri.qtdatrasado
                        tvlratrasado = tvlratrasado + ttfabri.vlratrasado.

                end.
                v-titfab  = " FABRICABTES DA CATEGORIA " + 
                               string(ttcateg.catnom)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
                            
            end.
            if p-var = "p-setor"
            then do:
                for each ttfabri where  ttfabri.etbcod = par-etbcod and
                                        ttfabri.comcod = p-comcod and 
                                        ttfabri.catcod = p-catcod and      
                                        ttfabri.setcod = p-setor 
                                        :
                    create ttfabriaux.
                    buffer-copy ttfabri to ttfabriaux.
                    assign
                        tqtdmerca = tqtdmerca + ttfabri.qtdmerca
                        tqtdmercaent = tqtdmercaent + ttfabri.qtdmercaent
                        tqtdsaldo = tqtdsaldo + ttfabri.qtdsaldo
                        tvlrsaldo = tvlrsaldo + ttfabri.vlrsaldo
                        tqdtatrasado = tqdtatrasado + ttfabri.qtdatrasado
                        tvlratrasado = tvlratrasado + ttfabri.vlratrasado.

                end.
                v-titfab  = " FABRICABTES DO SETOR " + 
                               string(ttsetor.nome)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
                            
            end.
            if p-var = "p-grupo"
            then do:
                for each ttfabri where  ttfabri.etbcod = par-etbcod and
                                        ttfabri.comcod = p-comcod and 
                                        ttfabri.catcod = p-catcod and      
                                        ttfabri.setcod = p-setor   and
                                        ttfabri.grupo-clacod = p-grupo 
                                        :
                    create ttfabriaux.
                    buffer-copy ttfabri to ttfabriaux.
                    assign
                        tqtdmerca = tqtdmerca + ttfabri.qtdmerca
                        tqtdmercaent = tqtdmercaent + ttfabri.qtdmercaent
                        tqtdsaldo = tqtdsaldo + ttfabri.qtdsaldo
                        tvlrsaldo = tvlrsaldo + ttfabri.vlrsaldo
                        tqdtatrasado = tqdtatrasado + ttfabri.qtdatrasado
                        tvlratrasado = tvlratrasado + ttfabri.vlratrasado.

                end.
                v-titfab  = " FABRICABTES DO GRUPO" + 
                               string(ttgrupo.nome)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
                            
            end.
            if p-var = "p-clase"
            then do:
                for each ttfabri where  ttfabri.etbcod = par-etbcod and
                                        ttfabri.comcod = p-comcod and 
                                        ttfabri.catcod = p-catcod and      
                                        ttfabri.setcod = p-setor   and
                                        ttfabri.grupo-clacod = p-grupo and
                                        ttfabri.clase-clacod = p-clase 
                                        :
                    create ttfabriaux.
                    buffer-copy ttfabri to ttfabriaux.
                    assign
                        tqtdmerca = tqtdmerca + ttfabri.qtdmerca
                        tqtdmercaent = tqtdmercaent + ttfabri.qtdmercaent
                        tqtdsaldo = tqtdsaldo + ttfabri.qtdsaldo
                        tvlrsaldo = tvlrsaldo + ttfabri.vlrsaldo
                        tqdtatrasado = tqdtatrasado + ttfabri.qtdatrasado
                        tvlratrasado = tvlratrasado + ttfabri.vlratrasado.

                end.
                v-titfab  = " FABRICABTES DA CLASSE " + 
                               string(ttclase.nome)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
                            
            end.
            if p-var = "p-sclase"
            then do:
                for each ttfabri where  ttfabri.etbcod = par-etbcod and
                                        ttfabri.comcod = p-comcod and 
                                        ttfabri.catcod = p-catcod and      
                                        ttfabri.setcod = p-setor   and
                                        ttfabri.grupo-clacod = p-grupo and
                                        ttfabri.clase-clacod = p-clase and
                                        ttfabri.sclase-clacod = p-sclase
                                        :
                    create ttfabriaux.
                    buffer-copy ttfabri to ttfabriaux.
                    assign
                        tqtdmerca = tqtdmerca + ttfabri.qtdmerca
                        tqtdmercaent = tqtdmercaent + ttfabri.qtdmercaent
                        tqtdsaldo = tqtdsaldo + ttfabri.qtdsaldo
                        tvlrsaldo = tvlrsaldo + ttfabri.vlrsaldo
                        tqdtatrasado = tqdtatrasado + ttfabri.qtdatrasado
                        tvlratrasado = tvlratrasado + ttfabri.vlratrasado.

                end.
                v-titfab  = " FABRICABTES DA SUB-CLASSE " + 
                               string(ttsclase.nome)  + " DO ESTAB. " + 
                                if par-etbcod <> 999
                                then string(estab.etbnom) else "EMPRESA"
                                .
                            
            end.
                disp "        TOTAIS   "
             tqtdmerca   tqtdmercaent   tqtdsaldo  
             tvlrsaldo   tqdtatrasado   tvlratrasado 
             with frame f-tot 1 down no-box no-label
             row 21 .

                    assign
                            a-seeid = -1 a-recid = -1 a-seerec = ? 
                            .

                        {sklcls.i 
                            &help = "F1=Sair F4=Retorna F8=Imprime"
                            &File   = ttfabriaux 
                            &CField = ttfabriaux.nome 
                            &ofield = "
                                ttfabriaux.qtdmerca 
                                ttfabriaux.qtdmercaent
                                ttfabriaux.qtdsaldo
                                ttfabriaux.vlrsaldo
                                ttfabriaux.qtdatrasado
                                ttfabriaux.vlratrasado
                                "
                            &Where = " true use-index platot " 
                            &Otherkeys1 = "  
                                   if keyfunction(lastkey) <> ""RETURN"" and
                                      keyfunction(lastkey) <> ""GO"" and
                                      keyfunction(lastkey) <> ""CLEAR""
                                     then next keys-loop.
                                     else do:
                                        if  keyfunction(lastkey) = ""CLEAR""
                                        then do:
                                            run imp-fab.
                                            next keys-loop.
                                        end.
                                        leave keys-loop.
                                     end.
                                    "
                            &Form = " frame f-fabriaux " 
                        }. 

        end.
end procedure.    

procedure imp-pro:
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/perfop01" + string(time).
    else varquivo = "l:\relat\perfop01" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "100"
        &Page-Line = "0"
        &Nom-Rel   = ""perfop01""
        &Nom-Sis   = """SISTEMA DE COMPRAS"""
        &Tit-Rel   = """PERFORMANCE DE PEDIDOS - PRODUTOS"""
        &Width     = "100"
        &Form      = "frame f-cabcab"}

    put skip
        v-titpro format "x(80)"
        skip.
    for each ttproduaux,
        first produ where  produ.procod = ttproduaux.procod 
        no-lock break by produ.pronom:
                
        disp
            ttproduaux.nome  
            column-label "Produtos"  format "x(16)"
            ttproduaux.qtdmerca (total)   
            column-label "QTotal"            format ">>>>>>>9" 
            ttproduaux.qtdmercaent (total)
            column-label "QEntra"             format ">>>>>>>9"
            ttproduaux.qtdsaldo     (total)
            column-label     "QSaldo"            format "->>>>>>>9" 
            ttproduaux.vlrsaldo     (total)
            column-label "VSaldo"         format "->>>>,>>9.99"
            ttproduaux.qtdatrasado  (total)
            column-label  "QAtraso"      format ">>>>>>>9"
            ttproduaux.vlratrasado   (total)
            column-label  "VAtraso" format ">>>>,>>9.99"
            with frame f-produaux1 down width 100.
        down with frame f-produaux1.    
    end.         

    output close.
        
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
        
end procedure.

procedure imp-fab:
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/perfop01" + string(time).
    else varquivo = "l:\relat\perfop01" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "100"
        &Page-Line = "0"
        &Nom-Rel   = ""perfop01""
        &Nom-Sis   = """SISTEMA DE COMPRAS"""
        &Tit-Rel   = """PERFORMANCE DE PEDIDOS - FABRICANTES"""
        &Width     = "100"
        &Form      = "frame f-cabcab"}

    put skip
        v-titfab format "x(80)"
        skip.
    for each ttfabriaux,
        first fabri where  fabri.fabcod = ttfabriaux.fabcod 
        no-lock break by fabri.fabnom:
                
        disp
            ttfabriaux.nome  
            column-label "Fabricante"  format "x(16)"
            ttfabriaux.qtdmerca (total)   
            column-label "QTotal"            format ">>>>>>>9" 
            ttfabriaux.qtdmercaent (total)
            column-label "QEntra"             format ">>>>>>>9"
            ttfabriaux.qtdsaldo     (total)
            column-label     "QSaldo"            format "->>>>>>>9" 
            ttfabriaux.vlrsaldo     (total)
            column-label "VSaldo"         format "->>>>,>>9.99"
            ttfabriaux.qtdatrasado  (total)
            column-label  "QAtraso"      format ">>>>>>>9"
            ttfabriaux.vlratrasado   (total)
            column-label  "VAtraso" format ">>>>,>>9.99"
            with frame f-fabriaux1 down width 100.
        down with frame f-fabriaux1.    
    end.         

    output close.
        
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
        
end procedure.





