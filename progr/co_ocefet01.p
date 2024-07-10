{admcab.i}

def input parameter par-recid-pedid as recid.

find pedid where recid(pedid) = par-recid-pedid .
find forne where forne.forcod = pedid.clfcod no-lock.
find compr of pedid no-lock.

do on error undo.
    find current pedid exclusive.
    assign
        pedid.pedsit = yes
        pedid.pedtot = 0.

    for each liped of pedid no-lock:
        pedid.pedtot = pedid.pedtot + (liped.lippreco * liped.lipqtd)
                      - liped.lipdes + liped.lipipi.
    end.

    find current pedid no-lock.
end.

                if forne.forcod = 5027
                then run exp_new.p (input pedid.etbcod,
                                    input pedid.pedtdc,
                                    input compr.comnom).
            
 
/***


def buffer bliped for liped.
def buffer bprodu for produ.

def var vufori      like unfed.ufecod.
def var vvolta      as log.
def buffer cprodu   for produ.
def buffer bclifor  for clifor.
def var jj          as int.
def var vlimite     as log.
def var v-ctoicm    as dec.
def var v-ctoipi    as dec.

def new shared temp-table tt-meses
    field mes   as int
    field ano   as int 
    field dia   as int
    field nome  as char
    field perc  as dec.

def temp-table ttc
    field clacod    like clase.clacod
    field etbcod    like estab.etbcod
    field qtdmerca  as int
    field valor     as dec.

def temp-table ttpag 
    field ano       as int
    field mes       as int
    field perc      as dec.

def var vprazos     as int.
def var vdatpag     as date.
def var vvalor      as dec.
def buffer ccprodu  for produ.
def buffer pp       for produ.
def var v-incide    as log.
def var v-preco     like bliped.lippreco.
def var i           as int.

def new shared var v-preunitario as dec format ">>>,>>>,>>9.99999".
def new shared var v-incideipi   as log.
def new shared var v-valipi      like tbipi.valipi.
def var v-qtdmerca    like proenoc.qtdmerca.
def var v-validate    as   logical no-undo.

def var v-parc      as int.
def var vsugere     as log init no.

form
    pedid.pedobs[1] label "Obs." colon 11
    pedid.pedobs[2] no-label colon 11 skip
    pedid.tipfrete colon 11
    pedid.frecod format ">>>>>>>9"
    clifor.clfnom format "x(30)" no-label
    with frame condicoes
        centered
        width 70
        row 5
        title "Condicoes da Ordem de Compra"
        side-labels.


do transaction:

for each bliped where bliped.etbped = pedid.etbped
                      and bliped.pedtdc = pedid.pedtdc
                      and bliped.pednum = pedid.pednum :
    vlipqtd = 0.
    for each proenoc of bliped no-lock.
        vlipqtd = vlipqtd + proenoc.qtdmerca.
    end.    
    if vlipqtd = 0 
    then do:
        for each proenoc of bliped exclusive.
            delete proenoc.
        end.    
        delete bliped.
    end.
end.

for each proenoc where proenoc.etbped = pedid.etbped
                 and   proenoc.pednum = pedid.pednum
                 and   proenoc.pedtdc = pedid.pedtdc 
                 and   proenoc.procod <> 0 :
    if proenoc.qtdmerca = 0 
    then
        delete proenoc.
end.

lbl-ordem-ef:
for each bliped of pedid no-lock.
   find bprodu of bliped no-lock.
    
/***
    find first tbipi where tbipi.procod = bprodu.itecod no-lock no-error.
    if avail tbipi
    then v-incideipi = yes.
    else v-incideipi = no.

    {ocprunit.i} 
***/

    do:
        assign  v-qtdmerca  = 0 .

        for each proenoc where proenoc.etbped = pedid.etbped
                         and   proenoc.pedtdc = pedid.pedtdc 
                         and   proenoc.pednum = bliped.pednum
                         and   proenoc.procod = bliped.procod 
                         no-lock : 
            assign
                v-qtdmerca = v-qtdmerca + proenoc.qtdmerca.
        end.
        
        /*
        
        if v-qtdmerca <> bliped.lipqtd
        then do:
            v-validate = false.
            bell.
            sresp = yes.
            find first cprodu where cprodu.procod = bliped.procod
                no-lock.
            message color red/withe
          " Divergencia entre Produtos " cprodu.procod
                " "  cprodu.pronom  skip
                " Quer corrigir divergencia? " 
                view-as alert-box buttons yes-no title "" update sresp.
            if sresp
            then do:
                hide frame f-ordem1.
                run co/ocppro.p (par-recid-pedid).
                view frame f-ordem1.
                next.
            end.
            else do:
                v-validate = false.
                leave lbl-ordem-ef.
            end.
        end.
        else*/ do:  
            v-validate = true.
         /*   leave. */
       end.
       
       
    end.
end.

for each liped of pedid
               no-lock :
    if liped.lippreco = 0 
    then do :
        find first ccprodu where ccprodu.procod = liped.procod no-error.
        if avail ccprodu
        then do :
            if ccprodu.ctonota <> 0 
            then liped.lippreco = ccprodu.ctonota.
            else do :
                find first pp where pp.procod = ccprodu.itecod no-error.
                if avail pp
                then do :
                    if pp.ctonota <> 0 
                    then liped.lippreco = pp.ctonota.
                end.
            end.        
        end.
    end. 
    if liped.lippreco = 0 
    then do :
        v-validate = no.
        leave.
    end.
end.

if not v-validate
then do:
    message color red/withe
        " Impossivel Efetivar a Ordem de Compra "
        view-as alert-box title " Mensagem ".
    return.
end.


/* o que restou de co/przordem.i */
repeat on error undo /*, retry*/ :
    clear frame condicoes no-pause.
    
    
    pedid.tipfrete = bclifor.tipfrete.

    update pedid.pedobs[1] 
           pedid.pedobs[2]
           pedid.tipfrete
           with frame condicoes overlay color withe/red .

    if pedid.tipfrete then do.  /* Cif */
        pedid.frecod = 0.
        disp pedid.frecod with frame condicoes.
    end.
    else do. /* Fob */
        update pedid.frecod validate (pedid.frecod > 0, "") 
               with frame condicoes.
        find bclifor where bclifor.clfcod = pedid.frecod no-lock no-error.
        if not avail bclifor then do.
            message "Transportador nao cadastrado" view-as alert-box.
            undo.
        end.
        disp bclifor.clfnom @ clifor.clfnom with frame condicoes.
    end.

        message color red/withe
            "Confirma os dados digitados ?"
             view-as alert-box buttons yes-no 
             title " Confirmacao " set sresp.

        if sresp = no
        then undo.

    hide frame condicoes.
    leave.
end.
/*

*/
   if keyfunction(lastkey) = "end-error" then
      return.
   
   run co/prevoc.p (input par-recid-pedid, output vvolta).
   if not vvolta then
      return.

/*
   FECHAMENTO DA ORDEM DE COMPRA
*/
run message.p (input-output vsugere,
               input " O que deseja fazer com a sugestao de precos?" + chr(10)
               + " Sugerir AGORA, ESPERAR NF ENTRADA",
               input " !! FECHAMENTO DA ORDEM DE COMPRA !! ",
               input "AGORA",
               input "ESPERA NF").

   find tipped of pedid no-lock.

assign
    pedid.sitped = "P"
    pedid.peddat = today.

for each liped of pedid:
    liped.lipsit = "P".
    for each proenoc of liped.
        proenoc.sitproenoc = "P".
    end.

    /* Ajusta CTOs, Sugere Precos */
    
            find produ of liped
                    no-lock no-error.
            
            /* Sugere Preco para Todas as Regioes */
            if vsugere then do: 
                /* ReCalcula Preco Reposicao */
                find clifor where clifor.clfcod = pedid.clfcod no-lock.
                find first etb-desti where etb-desti.clfcod = westab.clfcod
                                                    no-lock.
                run bas/procto.p  (input clifor.ufecod,  
                                   input etb-desti.ufecod,  
                                   recid(produ), 
                                   liped.lippreco, 
                                   (liped.lipout + liped.lipsubst
                                    + liped.lipfrete ) / liped.lipqtd
                                    , 
                                   output v-ctoicm, 
                                   output v-ctoipi).  
            
              for each rgpreco no-lock : 
                run bas/prsugere.p ( input produ.procod , 
                                     input "OC",
                                     input produ.ctorepos,
                                     input produ.ctorepos ,
                                     input today ,
                                     input produ.ctorepos,
                                     input rgpreco.rgcod).
              end.
            end.     
end.
              
if tipped.pedtlim
then do :
    run perc01.p (output vlimite ,
                  output vvolta ).  /*  Colocar os percentuais de Entrega */
    if vvolta = yes
    then do:
        pedid.sitped = "A". 
        v-validate = false.
        return.
    end.
    if vlimite = yes
    then do : 
        pedid.sitped = "L".
        v-validate = true.
    end.
    else do :
        pedid.sitped = "P".
        v-validate = true.
        find first forne where forne.clfcod = pedid.clfcod
                         no-lock no-error.
        find first etb-emite where etb-emite.clfcod = forne.clfcod no-lock. 
        find first unfed where unfed.ufecod = etb-emite.ufecod no-lock.
        find first etb-desti where etb-desti.clfcod = westab.clfcod no-lock.    

        vufori = unfed.ufecod.
        if vufori = ""
        then vufori = etb-emite.ufecod.
    
        for each liped where liped.pednum = pedid.pednum
                         and liped.pedtdc = pedid.pedtdc
                         and liped.etbped = pedid.etbped
                       no-lock :
            
            find first produ where produ.procod = liped.procod 
                    no-lock no-error.

            find first forne where forne.clfcod = pedid.clfcod
                         no-lock no-error.
            find first etb-emite where etb-emite.clfcod = forne.clfcod 
                                 no-lock. 
            find first unfed where unfed.ufecod = etb-emite.ufecod no-lock.
            find first etb-desti where etb-desti.clfcod = westab.clfcod 
                                 no-lock.    

            for each proenoc where proenoc.etbped = pedid.etbped 
                               and proenoc.pedtdc = pedid.pedtdc 
                               and proenoc.pednum = pedid.pednum
                               and proenoc.procod = liped.procod
                             /*  and proenoc.procod <> 0 */
                             no-lock :
                find first ttc where ttc.clacod = produ.clacod 
                                 and ttc.etbcod = proenoc.etbped
                no-error.
                       
                if not avail ttc
                then do :
                    create ttc.
                    ttc.etbcod = proenoc.etbped.
                    ttc.clacod = produ.clacod.
                end.
                ttc.qtdmerca = ttc.qtdmerca + 
                    (proenoc.qtdmerca - proenoc.qtdmercaent).
                ttc.valor = ttc.valor + 
                   ((proenoc.qtdmerca - proenoc.qtdmercaent ) * liped.lippreco).
            end.            
        end.

        vprazos = 0.
        do i = 1 to 5 :
            if pedid.przpagto[i] > 0 
            then  vprazos = vprazos + 1.
        end.    
 
        for each tt-meses where tt-meses.perc > 0 :
            do i = 1 to 5 :
                if pedid.przpagto[i] > 0 
                then do :
                    vdatpag = date(tt-meses.mes,tt-meses.dia,tt-meses.ano) + 
                              pedid.przpagto[i].
                    find first ttpag where ttpag.ano = year(vdatpag)
                                       and ttpag.mes = month(vdatpag) 
                                     no-error.
                    if not avail ttpag
                    then do :
                        create ttpag.
                        ttpag.ano = year(vdatpag).
                        ttpag.mes = month(vdatpag).
                    end.
                    ttpag.perc = ttpag.perc + (tt-meses.perc / vprazos).
                end.
            end.
        end.
        for each ttc. 
            for each ttpag :
                find first metcmp where metcmp.clacod = ttc.clacod
                                    and metcmp.etbcod = ttc.etbcod
                                and metcmp.dtcomp = date(ttpag.mes,1,ttpag.ano) 
                                  no-error.
                if not avail metcmp
                then do :
                    create metcmp.
                    metcmp.clacod = ttc.clacod.
                    metcmp.etbcod = ttc.etbcod.
                    metcmp.dtcomp = date(ttpag.mes,1,ttpag.ano) .
                end.       
                assign 
                    vvalor = ttc.valor * (ttpag.perc / 100)
                    metcmp.vlreal = metcmp.vlreal + vvalor.

                run atualsal.p (input ttc.etbcod , 
                                input ttc.clacod ,
                                input metcmp.dtcomp ). 
            end.
        end.
    end.
end.
else do:
    vlimite = no.
    v-validate = true.
end.

if vlimite = no
then do :
    sresp = yes.
    message color red/withe
            "Quer imprimir a Ordem de Compra ?" 
            view-as alert-box buttons yes-no title "" update sresp .
    if sresp
    then run co/ocimpoc.p (input(par-recid-pedid)).
end.

end.
***/
