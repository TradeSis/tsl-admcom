/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : convgenw.p
***** Diretorio                    : movim
***** Autor                        : Andre Baldini
***** Descri‡ao Abreviada da Funcao: Performance de Vendas
***** Data de Criacao              : ????????

                                ALTERACOES
***** 1) Autor     :  Claudir Santolin
***** 1) Descricao :  Adaptacoes ao Sale2000
***** 1) Data      :  ????2001

***** 2) Autor     :
***** 2) Descricao : 
***** 2) Data      :

***** 3) Autor     :
***** 3) Descricao : 
***** 3) Data      :
*******************************************************************************/

{admcab.i}.
{anset.i}.

{ajusta-rateio-venda-def.i new}

def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var val_fin like plani.platot.


def var vrodameta   as   log init yes.
def var vdtim       as   date.
def var vdtfm       as   date.
def var v-totcom    as   dec.
def var v-totalzao  as   dec.
def var vpago       as   dec.
def var vhora       as   char.
def var vok         as   logical.
def var vquant      like movim.movqtm.
def var flgetb      as   log.
def var vmovtdc     like tipmov.movtdc.
def var v-totaldia  as   dec.
def var v-total     as   dec.
def var v-totdia    as   dec.
def var v-nome      like estab.etbnom.
def var d           as   date.
def var i           as   int.
def var v-qtd       as   dec.
def var v-tot       as   dec.
def var v-movtdc    like plani.movtdc.
def var v-dif       as dec.
def var v-valor     as dec decimals 2.
def var varquivo as char.
def var fila as char.
def var recimp as recid.
def var vetbcod     like plani.etbcod no-undo.
def var v-totger    as dec.
def new shared      var vdti        as date format "99/99/9999" no-undo.
def new shared      var vdtf        as date format "99/99/9999" no-undo.
def var p-vende     like func.funcod.
def new shared var p-loja      like estab.etbcod.
def var p-setor     like setor.setcod.
def var p-grupo     like clase.clacod.
def var p-clase     like clase.clacod.
def var p-sclase    like clase.clacod.
def var varqsai     as char.
def var v-totperc   as dec.
def var v-titset    as char.
def var v-titgru    as char.
def var v-titcla    as char.
def var v-titscla   as char.
def var v-titvenpro as char.
def var v-titven    as char.
def var v-titpro    as char.
def var v-perdia    as dec label "% Dia".
def var v-perdia2   like v-perdia .
def var v-perc      as dec label "% Acum".
def var v-perdev    as dec label "% Dev" format ">9.99".
def var v-totcom0   as dec.
def var v-totsem0   as dec.
def new shared var v-etccod    like estac.etccod.
def new shared var v-carcod    like caract.carcod.
def new shared var v-subcod    like subcaract.subcod.
def new shared var v-subcar    like subcaract.subcar.
def new shared var vcomcod     like compr.comcod.
def buffer sclase   for clase.
def buffer grupo    for clase.

def buffer nivel1 for clase.
def buffer nivel2 for clase.

def new shared temp-table ttloja
    field medven    like plani.platot
    field medqtd    like movim.movqtm
    field metlj     like plani.platot
    field platot    like plani.platot
    field etbnom    like estab.etbnom
    field etbcod    like plani.etbcod
    field pladia    like plani.platot
    index loja      etbcod 
    index ranking platot desc.

def buffer bttloja for ttloja.

def var v-meta as log format "Sim/Nao".

def new shared temp-table ttsetor 
    field platot    like plani.platot
    field setcod    like setor.setcod
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field etbcod    like plani.etbcod
    index setor     etbcod setcod 
    index valor     platot desc.
    
def new shared temp-table ttgrupo
    field platot    like plani.platot
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field etbcod    like plani.etbcod
    field setcod    like produ.catcod
    index grupo     etbcod setcod clacod 
    index valor     platot desc.
    
def new shared temp-table ttvend
    field platot    like plani.platot
    field funcod    like plani.vencod
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field numseq    like movim.movseq
    field etbcod    like plani.etbcod
    index valor     platot desc.
    
def new shared temp-table ttvenpro
    field platot    like plani.platot
    field funcod    like plani.vencod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field procod    like produ.procod
    field etbcod    like plani.etbcod
    index valor     platot desc.

def new shared temp-table ttprodu
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field pladia    like plani.platot
    field procod    like produ.procod
    field clacod    like plani.placod 
    index produ     procod etbcod clacod
    index valor     platot desc.
    
def new shared temp-table ttclase 
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index clase     etbcod clacod.
    
/***/

def new shared temp-table ttnivel1
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index clase     etbcod clacod.

def new shared temp-table ttnivel2 
    field platot    like plani.platot
    field etbcod    like plani.etbcod
    field qtd       like movim.movqtm
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index clase     etbcod clacod.

/***/    

def new shared temp-table ttsclase 
    field platot    like plani.platot
    field qtd       like movim.movqtm
    field etbcod    like plani.etbcod
    field clacod    like clase.clacod
    field pladia    like plani.platot
    field clasup    like clase.clasup
    index sclase    etbcod clacod.

form
    clase.clacod
    clase.clanom
        help " ENTER = Seleciona" 
    produ.catcod 
    categoria.catnom
    with frame f-consulta
        color yellow/blue centered down overlay title " CLASSES " .

form
    ttvend.numseq   column-label "Rk" format ">>9" 
    help " F8 = Imprime "
    ttvend.funcod   column-label "Cod" format ">>>>9"
    func.funnom    format "x(18)" 
    ttvend.qtd     column-label "Qtd" format ">>>9" 
    ttvend.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttvend.platot  format "->>,>>>,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-vend
        centered
        down 
        title v-titven.
        
form
    ttvenpro.procod
       help "F8=Imprime"
    produ.pronom    format "x(18)" 
    ttvenpro.qtd     column-label "Qtd" format ">>>9" 
    ttvenpro.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttvenpro.platot  format "->>,>>>,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-vendpro
        centered
        down 
        title v-titvenpro.
 
form
    ttloja.etbcod
        help "ENTER=Seleciona F4=Encerra F8=Imprime" 
    ttloja.metlj  column-label "Meta Loja" format "->>,>>>,>>9.99" 
    ttloja.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum"
    v-perdia      column-label "% V/M C0"
    v-perdia2     column-label "% V/M S0" format "->>9.99"
    ttloja.pladia     column-label "Prest.Paga" format  ">>,>>>,>>9.99"
    with frame f-lojas
        width 80
        centered
        color white/red
        down 
        title " VENDAS POR LOJA ".
        
form
    ttloja.etbcod
    estab.etbnom  format "x(14)" column-label "Estabel."  
    ttloja.metlj  column-label "Meta Loja" format "->>,>>>,>>9.99" 
    ttloja.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum"
    v-perdia      column-label "% V/M C0"
    v-perdia2     column-label "% V/M S0" format "->>9.99"
    ttloja.pladia column-label "Prest.Paga" format ">>,>>>,>>9.99" 
    with frame f-lojaimp
        width 180 
        centered
        down
        no-box.

form
    ttsetor.setcod
    setor.setnom    format "x(15)" 
    ttsetor.qtd     format ">>>9"  column-label "Qtd"
    ttsetor.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia"
    v-perdia        format "->.99" column-label "% Dia" 
    ttsetor.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum" 
    v-perc          format "-9.99" column-label "% Acum" 
    with frame f-setor 
        centered
        width 80
        color white/green
        down  overlay
        title v-titset.
        
form
    ttgrupo.clacod
    clase.clanom    format "x(17)" 
    ttgrupo.qtd     format ">>>9" column-label "Qtd"
    ttgrupo.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia"
    v-perdia        column-label "% Dia"    format "->>9.99"
    ttgrupo.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum" 
    v-perc          column-label "% Acum" format "->>9.99" 
    with frame f-grupo
        centered
        down 
        title v-titgru.
        
form
    ttprodu.procod  column-label "Cod" 
    produ.pronom    format "x(13)" 
    ttprodu.qtd     format ">>9" column-label "Qtd" 
    v-perdev  format ">9.99" column-label "% Dev"  
    ttprodu.pladia  format "->>,>>>,>>9.99"   column-label "V.Dia" 
    v-perdia        column-label "% Dia"  format "->>9.99" 
    ttprodu.platot  format "->>,>>>,>>9.99"    column-label "V.Acum" 
    v-perc          column-label "%Acum"  format "->>9.99" 
    with frame f-produ
        centered
        down 
        title v-titpro.
        
form
    ttclase.clacod
    clase.clanom    format "x(18)" 
    ttclase.qtd     column-label "Qtd" format ">>>9" 
    ttclase.pladia  format "->>,>>>,>>9.99" column-label "Vnd.Dia" 
    v-perdia        column-label "% Dia" format "->>9.99" 
    ttclase.platot  format "->>,>>>,>>9.99"  column-label "Vnd.Acum" 
    v-perc          column-label "%Acum"    format "->>9.99"
    with frame f-clase
        centered
        down 
        title v-titcla.
       
form
    ttsclase.clacod
    sclase.clanom    format "x(18)" 
    ttsclase.qtd        column-label "Qtd"   format ">>>9"    
    ttsclase.pladia  column-label "Vnd.Dia" format "->>,>>>,>>9.99"
    v-perdia         column-label "% Dia"
    ttsclase.platot  format "->>,>>>,>>9.99" column-label "Vnd.Acum"
    v-perc           column-label "% Acum" 
    with frame f-sclase
        centered down title v-titscla.

def var vfabcod like fabri.fabcod.
def var vforcod like forne.forcod.
        
form
    vetbcod  label  "Lj"
    /*estab.etbnom no-label format "x(15)" */
    /*vfabcod label "Fab"*/
    vforcod label "For"
    fabri.fabnom no-label format "x(10)"
    vdti     label "Dt.In"
    vdtf     label "Dt.Fi"
    vhora    label "H"
    v-etccod label "Estacao"
    v-carcod label "Caracteristica"
    v-subcod label "Sub-Caracteristica"
    vcomcod         format ">>>>>9" at 1
    compr.comnom    no-label     format "x(25)"
    with frame f-etb
        centered
        1 down side-labels title "Dados Iniciais"
        color white/bronw row 3 width 80.

def var v-opcao as char format "x(12)" extent 2 initial
    ["POR VENDEDOR","POR PRODUTOS"].
    
form
    v-opcao[1]  format "x(12)"
    v-opcao[2]  format "x(12)"
    with frame f-opcao
        centered 1 down no-labels overlay row 10 color white/green. 

/*
{selestab.i vetbcod f-etb} */


repeat:
    clear frame f-mat all.
    hide frame f-mat.
    for each ttvenpro : delete ttvenpro. end.
    for each ttvend : delete ttvend. end.
    for each ttprodu :  delete ttprodu. end.
    for each ttloja :  delete ttloja. end.
    for each ttsetor : delete ttsetor. end.
    for each ttgrupo : delete ttgrupo. end.
    for each ttclase : delete ttclase. end. 
    for each ttsclase : delete ttsclase. end.

    assign vdti = today  vdtf = today.

    update vetbcod with frame f-etb.
    update /*vfabcod label "Fab"*/
           vforcod label "For"
           with frame f-etb.
    
    vfabcod = vforcod.
    
    if vfabcod <> 0
    then do:
        find fabri where fabri.fabcod = vfabcod no-lock no-error.
        if not avail fabri
        then do:
            message "Fabricante nao Cadastrado".
            undo.
        end.    
        display fabri.fabnom format "x(10)" no-label with frame f-etb.
    end.
    else disp "Geral" @ fabri.fabnom format "x(10)" with frame f-etb.

    /* funcod = 63. */

    update  vdti  vdtf   with frame f-etb.
        hide frame f-mostr.
        
    update v-etccod with frame f-etb.
    if v-etccod > 0
    then do:
        find estac where estac.etccod = v-etccod no-lock. 
    end.
    update v-carcod with frame f-etb.
    if v-carcod > 0
    then  find caract where caract.carcod = v-carcod no-lock.
    if v-carcod > 0
    then do on error undo: 
        scopias = caract.carcod.    
        update v-subcod with frame f-etb.
        if v-subcod = 0
        then next.
        find first subcaract where 
                    subcaract.carcod = v-carcod and
                    subcaract.subcar = v-subcod no-lock.
        disp subdes format "x(20)" no-label with frame f-etb.
    end.   
    
    update vcomcod  
           with frame f-etb.
            
    find first compr where compr.comcod = vcomcod
                       and vcomcod > 0  no-lock no-error.
                               
    if avail compr then display compr.comnom  no-label
                              with frame f-etb.
    else if vcomcod = 0 then display "TODOS" @ compr.comnom no-label
                              with frame f-etb.
    else do:
                           
        message "Comprador não encontrado!" view-as alert-box.
        undo, retry.
     
    end.
    
    scopias = 0.     
    for each ttvenpro : delete ttvenpro. end.
    for each ttvend : delete ttvend. end.
    for each ttprodu :  delete ttprodu. end.
    for each ttloja :  delete ttloja. end.
    for each ttnivel1: delete ttnivel1. end.
    for each ttnivel2: delete ttnivel2. end.
    for each ttsetor : delete ttsetor. end.
    for each ttgrupo : delete ttgrupo. end.
    for each ttclase : delete ttclase. end. 
    for each ttsclase : delete ttsclase. end.

    vrodameta = yes.
    
    message "Processa Meta?" update v-meta.
    
    run calc.
    
    hide frame f-fab0 no-pause.
    hide frame f-fab1 no-pause.
    
    assign v-totcom0 = 0 v-totsem0 = 0  v-qtd = 0 vpago = 0.
    
    for each ttloja where ttloja.etbcod <> 0 :                            
        v-qtd = 0.
        vpago = vpago + ttloja.pladia.
        for each ttsetor where ttsetor.etbcod = ttloja.etbcod :
            v-qtd = v-qtd + ttsetor.qtd.
        end.    
        ttloja.medqtd = v-qtd / ttloja.medven.
        ttloja.medven = ttloja.platot / ttloja.medven.
        v-totcom0 = v-totcom0 + ttloja.metlj.
        v-totsem0 = v-totsem0 + (if ttloja.metlj = 0
                                 then ttloja.platot
                                 else ttloja.metlj).
    end.  
    
    find first ttloja where ttloja.etbcod = 0 no-error.
    if avail ttloja
    then ttloja.pladia = vpago.
    else do:
        find first ttloja no-error.
        if avail ttloja
        then assign ttloja.pladia = vpago.
    end.
        
     
    repeat:
        assign  an-seeid  = -1 
                an-recid  = -1
                an-seerec = ? 
                v-totdia  = 0 
                v-totger  = 0.
        

        for each ttloja where ttloja.etbcod <> 0 : 
            assign  v-totdia = v-totdia + ttloja.pladia
                    v-totger = v-totger + ttloja.platot.
        end.

        hide frame f-mostr2.
        hide frame f-mostr.
        hide frame f-mostr2.
        
        vhora = string(time,"hh:mm:ss").
        
        disp vhora with frame f-etb.
          if vdtf - vdti >= 1
          then do:
          
          {anbrowse.i
            &File   = ttloja 
            &CField = ttloja.etbcod
            &color  = write/cyan
            &Ofield = " ttloja.platot ttloja.metlj
                        ttloja.pladia  v-perdia v-perdia2"
            &Where = "ttloja.etbcod  = (if vetbcod = 0
                                        then ttloja.etbcod
                                        else vetbcod) and
                      ttloja.platot > 0
                      "
            &NonCharacter = /*
            &Aftfnd = "
                assign v-perc = ttloja.platot * 100 / v-totger
                       v-perdia = (if ttloja.platot <> 0
                                    then (ttloja.platot / ttloja.metlj) * 100  
                                    else 0)
                       v-perdia2 =  (if ttloja.etbcod = 0 then
                                     (if ttloja.platot <> 0
                                     then (ttloja.platot / v-totsem0) * 100  
                                     else 0)
                                     else (if ttloja.platot <> 0
                                     then (ttloja.platot / (if ttloja.metlj = 0 
                                                            then ttloja.platot
                                                            else ttloja.metlj)) * 100 
                                     else 0))."
            &AftSelect1 = "p-loja = ttloja.etbcod. 
                       leave keys-loop. "
            &LockType = "use-index loja" 
            &Otherkeys = "if lastkey = -1 then leave keys-loop".
            &Otherkeys1 = "convloj.new"
            &Form = " frame f-lojas" 
        }.
        end.
        else do:
        
          {anbrowse.i
            &File   = ttloja
            &CField = ttloja.etbcod
            &color  = write/cyan
            &tempo = "pause 60"
            &Ofield = " ttloja.platot ttloja.metlj
                        ttloja.pladia  v-perdia v-perdia2"
            &Where = "ttloja.etbcod  = (if vetbcod = 0
                                        then ttloja.etbcod
                                        else vetbcod) and
                      ttloja.platot > 0"
            &NonCharacter = /*
            &Aftfnd = "
                assign v-perc = ttloja.platot * 100 / v-totger
                       v-perdia = (if ttloja.platot <> 0

                                    then (ttloja.platot / ttloja.metlj) * 100  ~                                   else 0)
                       v-perdia2 =  (if ttloja.etbcod = 0 then
                                     (if ttloja.platot <> 0
                                     then (ttloja.platot / v-totsem0) * 100   
                                     else 0)
                                     else (if ttloja.platot <> 0
                                     then (ttloja.platot / (if ttloja.metlj = 0 
                                                            then ttloja.platot ~                                                            else ttloja.metlj))~                                                             * 100             ~                                                               else 0))

                                  . "
            &AftSelect1 = "p-loja = ttloja.etbcod.
                       leave keys-loop. "
            &LockType = "use-index loja" 
            &Otherkeys = "if lastkey = -1 then leave keys-loop".
            &Otherkeys1 = "convloj.new"
            &Form = " frame f-lojas" 
        }.

         end.
        if lastkey = -1 
        then do:
            for each ttvenpro : delete ttvenpro. end.
            for each ttvend : delete ttvend. end.
            for each ttprodu :  delete ttprodu. end.
            /***for each ttloja :  delete ttloja. end.***/
            for each ttsetor : delete ttsetor. end.
            for each ttgrupo : delete ttgrupo. end.
            for each ttclase : delete ttclase. end. 
            for each ttsclase : delete ttsclase. end.

            /*** teste ***/
            for each ttloja:
                assign 
                    ttloja.medven = 0
                    ttloja.medqtd = 0
                    ttloja.platot = 0
                    ttloja.pladia = 0.
            end.        
            /***       ***/

            vrodameta = no.        
            run calc.
            
            hide frame f-fab0 no-pause.
            hide frame f-fab1 no-pause.
            
            assign v-totcom0 = 0 v-totsem0 = 0  v-qtd = 0 vpago = 0.
    
            for each ttloja where ttloja.etbcod <> 0 : 
                v-qtd = 0.
                vpago = vpago + ttloja.pladia.
                for each ttsetor where ttsetor.etbcod = ttloja.etbcod :
                    v-qtd = v-qtd + ttsetor.qtd.
                end.    
                ttloja.medqtd = v-qtd / ttloja.medven.
                ttloja.medven = ttloja.platot / ttloja.medven.
                v-totcom0 = v-totcom0 + ttloja.metlj.
                v-totsem0 = v-totsem0 + (if ttloja.metlj = 0
                                 then ttloja.platot
                                 else ttloja.metlj).
            end.  
            find first ttloja where ttloja.etbcod = 0 no-error.
            if avail ttloja
            then ttloja.pladia = vpago.
                 next.
        end.
        
        if keyfunction(lastkey) = "END-ERROR"
        then leave.
        if not can-find( first ttloja)
        then leave.

        disp v-opcao with frame f-opcao.
        choose field v-opcao with frame f-opcao.
        hide frame f-opcao no-pause.
        if frame-index = 2 
        then do:
            run convgen_.p (input vfabcod).
        end.
        else do:
            run convge_0.p (input vfabcod).
        end.        
    end.        
 end. 

PROCEDURE calc.

IF VFABCOD = 0
THEN DO:

  v-totalzao = 0.
  if v-carcod = 0 and
     v-etccod = 0 and
     vcomcod = 0
  then do:   
  do d = vdti to vdtf:
    for each estab where estab.etbcod = (if vetbcod <> 0 
                                         then vetbcod
                                         else estab.etbcod)  no-lock :
        disp d format "99/99/9999" 
            estab.etbnom with frame f-fab0 1 down row 10 centered no-labels
            color white/black . pause 0.
            
        for each plani where plani.movtdc = 5
                     and  plani.etbcod = estab.etbcod
                     and plani.pladat = d 
                     use-index pladat
                     no-lock :
                     
            if not can-find (first movim
                             where movim.etbcod = plani.etbcod
                               and movim.placod = plani.placod
                               and movim.movtdc = plani.movtdc
                               and movim.movdat = plani.pladat)
            then next.
                  
            /***find first tipmov where tipmov.movtdc = 5 no-lock.***/
            
            
            /****** gerando historico de lojas ***********/
            
            find first ttloja where ttloja.etbcod = plani.etbcod no-error.
            if not avail ttloja
            then do:
                create ttloja.
                assign ttloja.etbcod = plani.etbcod
                       ttloja.etbnom = estab.etbnom
                       ttloja.metlj  = v-total.
            end.
        
            if plani.movtdc /***tipmov.movtdc***/ = 5
            then do :
                ttloja.medven = ttloja.medven + 1.
                if plani.biss > 0  
                then ttloja.platot = ttloja.platot + plani.biss.
                else ttloja.platot = ttloja.platot + 
                        (plani.platot - plani.vlserv ).
                if plani.pladat = vdtf
                then do :
                    if plani.biss > 0 
                    then ttloja.pladia = ttloja.pladia + plani.biss.
                    else ttloja.pladia = ttloja.pladia + 
                        (plani.platot - plani.vlserv).
                end.                             
            end.    
            
            if vetbcod = 0 
            then do :
                find first ttloja where ttloja.etbcod = 0 no-error.
                if not avail ttloja
                then do:
                    create ttloja.
                    assign ttloja.etbcod = 0
                           ttloja.etbnom = "G E R A L"
                           ttloja.metlj = v-total.
                end.
            
                if /***tipmov.movtdc***/ plani.movtdc = 5
                then do :
                    ttloja.metlj = ttloja.metlj + v-totalzao.
                    ttloja.medven = ttloja.medven + 1.
                end.  

                if plani.biss > 0 
                then ttloja.platot = ttloja.platot + plani.biss.
                else ttloja.platot = ttloja.platot + 
                                    (plani.platot - plani.vlserv).
                
                if plani.pladat = vdtf
                then do :
                    if plani.biss > 0 
                    then ttloja.pladia = ttloja.pladia + plani.biss.
                    else ttloja.pladia = ttloja.pladia + (plani.platot -
                                         plani.vlserv).
                end.                            
            end.
        end.
    end.
  end.
    

  /****************** Calculo da Meta ************************/
  if v-meta
  then
  if vrodameta 
  then do:

    v-totalzao = 0.

    vdtim = date(month(vdti), day(vdti), year(vdti) - 1).
    vdtfm = date(month(vdtf), day(vdtf), year(vdtf) - 1).


    do d = vdtim to vdtfm : 
 
      disp "Processando Meta .." d
        with frame f-mostr2 1 down
                        row 10 centered no-labels color white/black.
      pause 0.
                        
      for each estab where estab.etbcod = (if vetbcod <> 0 
                                           then vetbcod
                                           else estab.etbcod) no-lock:

        disp estab.etbcod
             with frame f-mostr2 .
        pause 0.
        
        for each tt-plani: delete tt-plani. end.
        for each tt-movim: delete tt-movim. end.
        
        for each plani where plani.movtdc = 5
                     and  plani.etbcod = estab.etbcod
                     and plani.pladat = d 
                     no-lock :
        
            if not can-find (first movim
                             where movim.etbcod = plani.etbcod
                               and movim.placod = plani.placod
                               and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat)
            then next.

            create tt-plani.
            buffer-copy plani to tt-plani.
            for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat
                             no-lock:
                find produ where produ.procod = movim.procod 
                        no-lock no-error.
                if not avail produ then next.
                create tt-movim.
                buffer-copy movim to tt-movim.
            end.                   
        end.          
        
        run ajusta-rateio-venda-pro.p.
        
        for each tt-movim no-lock:
            
            find first ttloja where ttloja.etbcod = estab.etbcod no-error.
            if not avail ttloja
            then do:
                create ttloja.
                assign ttloja.etbcod = estab.etbcod
                       ttloja.etbnom = estab.etbnom.
            end.
        
            if tt-movim.movtdc = 5
            then ttloja.metlj = ttloja.metlj + tt-movim.movtot.
            
            if vetbcod = 0 
            then do :
                find first ttloja where ttloja.etbcod = 0 no-error.
                if not avail ttloja
                then do:
                    create ttloja.
                    assign ttloja.etbcod = 0
                           ttloja.etbnom = "G E R A L".
                end.
            
                if tt-movim.movtdc = 5
                then do:
                    ttloja.metlj = ttloja.metlj + v-totalzao.
                end.  
                ttloja.metlj = ttloja.metlj + tt-movim.movtot.
                
            end.
        end.
      end.
    end.
  end.
  end.
  else do:  
  do d = vdti to vdtf:
    for each estab where estab.etbcod = (if vetbcod <> 0 
                                         then vetbcod
                                         else estab.etbcod)  no-lock :
        disp d format "99/99/9999" 
            estab.etbnom with frame f-fab0 1 down row 10 centered no-labels
            color white/black . pause 0.
            
        for each tt-plani: delete tt-plani. end.
        for each tt-movim: delete tt-movim. end.
            
        for each plani where plani.movtdc = 5
                     and  plani.etbcod = estab.etbcod
                     and plani.pladat = d 
                     use-index pladat
                     no-lock :

            if not can-find (first movim
                             where movim.etbcod = plani.etbcod
                               and movim.placod = plani.placod
                               and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat)
            then next.
            create tt-plani.
            buffer-copy plani to tt-plani.
            
            for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat
                             no-lock:
                create tt-movim.
                buffer-copy movim to tt-movim.
            end.
        end.
        
        run ajusta-rateio-venda-pro.p.

        for each tt-movim no-lock:
        
            find produ where produ.procod = tt-movim.procod 
                no-lock.
                                     
            if v-etccod > 0 and
                produ.etccod <> v-etccod
            then next.
            if v-carcod > 0
            then do.
                           sresp = no. 
                           run valprocaract.p (produ.procod, 
                                               v-carcod,
                                               v-subcod,
                                               output sresp).
                           if not sresp then next. 
            end.
            if vcomcod > 0
            then do:
        
                release liped.
                release pedid.
                find last liped where liped.procod = produ.procod
                              and liped.pedtdc = 1
                                no-lock use-index liped2 no-error.

                find first pedid of liped no-lock no-error.
            
                if (avail pedid and pedid.comcod <> vcomcod)
                    or not avail pedid
                then next.
                    
            end.
         
            find first ttloja where ttloja.etbcod = tt-movim.etbcod no-error.
            if not avail ttloja
            then do:
                create ttloja.
                assign ttloja.etbcod = tt-movim.etbcod
                       ttloja.etbnom = estab.etbnom
                       ttloja.metlj  = v-total.
            end.
        
            if tt-movim.movtdc = 5
            then do:

                
                val_fin = 0.                   
                val_des = 0.  
                val_dev = 0.  
                val_acr = 0. 
                         
                val_acr =  tt-movim.acr-fin.
                if val_acr = ? then val_acr = 0.
                val_des =  tt-movim.movdes.
                if val_des = ? then val_des = 0.
                val_dev = tt-movim.movdev.
                if val_dev = ? then val_dev = 0.
                val_fin = tt-movim.movtot.
                if val_fin = ? then val_fin = 0.
                val_com = tt-movim.movtot. 
                if val_com = ? then val_com = 0.
                 
                        
                ttloja.platot = ttloja.platot + val_com.
                if plani.pladat = vdtf
                then ttloja.pladia = ttloja.pladia + val_com.

            end.    
            
            if vetbcod = 0 
            then do :
                find bttloja where bttloja.etbcod = 0 no-error.
                if not avail bttloja
                then do:
                    create bttloja.
                    assign bttloja.etbcod = 0
                           bttloja.etbnom = "G E R A L"
                           bttloja.metlj = v-total.
                end.
            
                if movim.movtdc = 5
                then do:
                    assign bttloja.metlj = bttloja.metlj + v-totalzao
                           bttloja.medven = bttloja.medven + 1.
                end.  

                bttloja.platot = bttloja.platot + val_com.

                if plani.pladat = vdtf
                then assign
                        bttloja.pladia = bttloja.pladia + val_com.
                               
            end.
            
            ttloja.medven = ttloja.medven + 1.

        end.
     
    end.
   /*         
    end.
     */
   end.
  end.
    
END. 
ELSE DO:

  v-totalzao = 0.
  
  for each produ use-index iprofab where produ.fabcod = vfabcod no-lock:  
    if v-etccod > 0 and
       produ.etccod <> v-etccod
    then next.
    if v-carcod > 0
    then do.
                           sresp = no. 
                           run valprocaract.p (produ.procod, 
                                               v-carcod,
                                               v-subcod,
                                               output sresp).
                           if not sresp then next. 
    end.
      
        if vcomcod > 0
        then do:
        
            release liped.
            release pedid.
            find last liped where liped.procod = produ.procod
                              and liped.pedtdc = 1
                                no-lock use-index liped2 no-error.

            find first pedid of liped no-lock no-error.
            
            if (avail pedid and pedid.comcod <> vcomcod)
               or not avail pedid
            then next.
                    
        end.
         
   do d = vdti to vdtf : 

    disp  d format "99/99/9999"
          /*produ.procod produ.pronom*/
          with frame f-fab1 1 down row 10 centered no-labels
                     color white/black . pause 0.


    if vetbcod <> 0
    then do:
        for each tt-plani: delete tt-plani. end.
        for each tt-movim: delete tt-movim. end.
        for each movim use-index icurva
                       where movim.etbcod = vetbcod and
                             movim.movtdc = 5 and   
                             movim.procod = produ.procod and
                             movim.movdat = d no-lock:

            find plani where plani.etbcod = movim.etbcod
                         and plani.placod = movim.placod 
                         and plani.pladat = movim.movdat
                         and plani.movtdc = movim.movtdc 
                         no-lock no-error.
            if not avail plani then next.             
            find first tt-plani where tt-plani.etbcod = plani.etbcod and
                                      tt-plani.placod = plani.placod and
                                      tt-plani.movtdc = plani.movtdc and
                                      tt-plani.pladat = plani.pladat
                                      no-lock no-error.
            if not avail tt-plani
            then do:
                create tt-plani.
                buffer-copy plani to tt-plani.
            end.
            create tt-movim.
            buffer-copy movim to tt-movim.
        end.                                                  
        
        run ajusta-rateio-venda-pro.p.
        
        for each tt-movim no-lock:
        
            find estab where estab.etbcod = tt-movim.etbcod no-lock.

            disp estab.etbnom
                with frame f-fab1. pause 0.
        
            find first ttloja where ttloja.etbcod = tt-movim.etbcod no-error.
            if not avail ttloja
            then do:
                create ttloja.
                assign ttloja.etbcod = tt-movim.etbcod
                       ttloja.etbnom = estab.etbnom
                       ttloja.metlj  = v-total.
            end.
        
            if tt-movim.movtdc = 5
            then do:

                
                val_fin = 0.                   
                val_des = 0.  
                val_dev = 0.  
                val_acr = 0. 
                         
                val_acr = tt-movim.acr-fin.
                if val_acr = ? then val_acr = 0.
                val_des = tt-movim.movdes.
                if val_des = ? then val_des = 0.
                val_dev = tt-movim.movdev.
                if val_dev = ? then val_dev = 0.
                val_fin = tt-movim.movtot.
                if val_fin = ? then val_fin = 0.
                val_com = tt-movim.movtot.
                if val_com = ? then val_com = 0.
                 
                ttloja.platot = ttloja.platot + val_com.
                if plani.pladat = vdtf
                then ttloja.pladia = ttloja.pladia + val_com.

            end.    
            
            if vetbcod = 0 
            then do :
                find bttloja where bttloja.etbcod = 0 no-error.
                if not avail bttloja
                then do:
                    create bttloja.
                    assign bttloja.etbcod = 0
                           bttloja.etbnom = "G E R A L"
                           bttloja.metlj = v-total.
                end.
            
                if movim.movtdc = 5
                then do:
                    assign bttloja.metlj = bttloja.metlj + v-totalzao.
                           bttloja.medven = bttloja.medven + 1.
                end.  

                val_fin = 0.                   
                val_des = 0.  
                val_dev = 0.  
                val_acr = 0. 
                         
                val_acr = tt-movim.acr-fin.
                if val_acr = ? then val_acr = 0.
                val_des = tt-movim.movdes.
                if val_des = ? then val_des = 0.
                val_dev = tt-movim.movdev.
                if val_dev = ? then val_dev = 0.
                val_fin = tt-movim.movtot.
                if val_fin = ? then val_fin = 0.
                val_com = tt-movim.movtot.
                if val_com = ? then val_com = 0.

                bttloja.platot = bttloja.platot + val_com.

                if plani.pladat = vdtf
                then assign
                        bttloja.pladia = bttloja.pladia + val_com.
                               
            end.
            
            ttloja.medven = ttloja.medven + 1.

        end.
     
    end.
    else do:
    
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    for each movim use-index datsai where movim.procod = produ.procod
                                       and movim.movtdc = 5
                                       and movim.movdat = d no-lock:
    
        find plani where plani.etbcod = movim.etbcod
                     and plani.placod = movim.placod 
                     and plani.pladat = movim.movdat
                     and plani.movtdc = movim.movtdc 
                     no-lock no-error.
        if not avail plani then next.             

        find first tt-plani where tt-plani.etbcod = plani.etbcod and
                                      tt-plani.placod = plani.placod and
                                      tt-plani.movtdc = plani.movtdc and
                                      tt-plani.pladat = plani.pladat
                                      no-lock no-error.
            if not avail tt-plani
            then do:
                create tt-plani.
                buffer-copy plani to tt-plani.
            end.
            create tt-movim.
            buffer-copy movim to tt-movim.

    end.
    
    run ajusta-rateio-venda-pro.p.
        
    for each tt-movim no-lock:    
        find estab where estab.etbcod = tt-movim.etbcod no-lock.
        
                     disp estab.etbnom
                with frame f-fab1. pause 0.
                
        find first ttloja where ttloja.etbcod = tt-movim.etbcod no-error.
        if not avail ttloja
        then do:
            create ttloja.
            assign ttloja.etbcod = tt-movim.etbcod
                   ttloja.etbnom = estab.etbnom
                   ttloja.metlj  = v-total.
        end.
        
        if tt-movim.movtdc = 5
        then do:
            
            val_fin = 0.                    
            val_des = 0.   
            val_dev = 0.   
            val_acr = 0. 
                         
            val_acr = tt-movim.acr-fin.
            if val_acr = ? then val_acr = 0.
            val_des = tt-movim.movdes.
            if val_des = ? then val_des = 0.
            val_dev = tt-movim.movdev.
            if val_dev = ? then val_dev = 0.
            val_fin = tt-movim.movtot.
            if val_fin = ? then val_fin = 0.
            val_com = tt-movim.movtot.
            if val_com = ? then val_com = 0.
                        
            ttloja.platot = ttloja.platot + val_com.

            if plani.pladat = vdtf
            then ttloja.pladia = ttloja.pladia + val_com.

        end.    
            
        if vetbcod = 0 
        then do :
            find bttloja where bttloja.etbcod = 0 no-error.
            if not avail bttloja
            then do:
                create bttloja.
                assign bttloja.etbcod = 0
                       bttloja.etbnom = "G E R A L"
                       bttloja.metlj = v-total.
            end.
            
            if movim.movtdc = 5
            then do:
                assign bttloja.metlj = bttloja.metlj + v-totalzao.
                       bttloja.medven = bttloja.medven + 1.
            end.  

           
            bttloja.platot = bttloja.platot + val_com.

            if plani.pladat = vdtf
            then assign
                    bttloja.pladia = bttloja.pladia + val_com.
                               
        end.
            
        ttloja.medven = ttloja.medven + 1.

     end.
    end.
    
   end.
  end.
    

 /****************** Calculo da Meta ************************/
 if v-meta
 then
 if vrodameta 
 then do:
            
    v-totalzao = 0.

    vdtim = date(month(vdti), day(vdti), year(vdti) - 1).
    vdtfm = date(month(vdtf), day(vdtf), year(vdtf) - 1).
  
    do d = vdtim to vdtfm : 
 
        disp "Processando Meta .." d format "99/99/9999"
                     with frame f-mostr2 1 down 
                    row 10 centered no-labels color white/black.
                pause 0.
  
  
        for each produ use-index iprofab 
           where produ.fabcod = vfabcod no-lock:  

            if vetbcod <> 0
            then do:
                for each tt-plani: delete tt-plani. end.
                for each tt-movim: delete tt-movim. end.
                
                for each movim use-index icurva
                           where movim.etbcod = vetbcod
                             and movim.movtdc = 5  
                             and movim.procod = produ.procod
                             and movim.movdat = d no-lock:

                    find plani where plani.etbcod = movim.etbcod
                             and plani.placod = movim.placod 
                             and plani.pladat = movim.movdat
                             and plani.movtdc = movim.movtdc 
                             no-lock no-error.
                    if not avail plani then next.     
                    
                    find first tt-plani where tt-plani.etbcod = plani.etbcod and
                                      tt-plani.placod = plani.placod and
                                      tt-plani.movtdc = plani.movtdc and
                                      tt-plani.pladat = plani.pladat
                                      no-lock no-error.
                    if not avail tt-plani
                    then do:
                        create tt-plani.
                        buffer-copy plani to tt-plani.
                    end.
                    create tt-movim.
                    buffer-copy movim to tt-movim.

                end.
    
                run ajusta-rateio-venda-pro.p.
        
                for each tt-movim no-lock:
                
                    find estab where estab.etbcod = tt-movim.etbcod no-lock.
     
                    find first ttloja where 
                               ttloja.etbcod = tt-movim.etbcod no-error.
                    if not avail ttloja
                    then do:
                        create ttloja.
                        assign ttloja.etbcod = tt-movim.etbcod
                               ttloja.etbnom = estab.etbnom.
                    end.
        
                    
                    val_fin = 0.                    
                    val_des = 0.   
                    val_dev = 0.   
                    val_acr = 0. 
                         
                    val_acr = tt-movim.acr-fin.
                    if val_acr = ? then val_acr = 0.
                    val_des = tt-movim.movdes.
                    if val_des = ? then val_des = 0.
                    val_dev = tt-movim.movdev.
                    if val_dev = ? then val_dev = 0.
                    val_fin = tt-movim.movtot.
                    if val_fin = ? then val_fin = 0.
                    val_com = tt-movim.movtot.
                    if val_com = ? then val_com = 0.
                    
                    ttloja.metlj = ttloja.metlj + val_com.
            
                    if vetbcod = 0 
                    then do:
                        find first ttloja where ttloja.etbcod = 0 no-error.
                        if not avail ttloja
                        then do:
                            create ttloja.
                            assign ttloja.etbcod = 0
                                   ttloja.etbnom = "G E R A L".
                        end.
            
                        ttloja.metlj = ttloja.metlj + v-totalzao.

                        ttloja.metlj = ttloja.metlj + val_com.
                
                    end.
                end.  
            end.
            else do:
                for each tt-plani: delete tt-plani. end.
                for each tt-movim: delete tt-movim. end.
                
                for each movim use-index datsai where 
                         movim.procod = produ.procod 
                     and movim.movtdc = 5
                     and movim.movdat = d no-lock:
    
                    find plani where plani.etbcod = movim.etbcod
                         and plani.placod = movim.placod 
                         and plani.pladat = movim.movdat
                         and plani.movtdc = movim.movtdc 
                         no-lock no-error.
                    if not avail plani then next.     
        
                    find first tt-plani where tt-plani.etbcod = plani.etbcod and
                                      tt-plani.placod = plani.placod and
                                      tt-plani.movtdc = plani.movtdc and
                                      tt-plani.pladat = plani.pladat
                                      no-lock no-error.
                    if not avail tt-plani
                    then do:
                        create tt-plani.
                        buffer-copy plani to tt-plani.
                    end.
                    create tt-movim.
                    buffer-copy movim to tt-movim.

                end.
    
                run ajusta-rateio-venda-pro.p.
 
                for each tt-movim no-lock:     
                     find estab where estab.etbcod = tt-movim.etbcod no-lock.
      
                    find first ttloja where 
                               ttloja.etbcod = tt-movim.etbcod no-error.
                    if not avail ttloja
                    then do:
                        create ttloja.
                        assign ttloja.etbcod = tt-movim.etbcod
                               ttloja.etbnom = estab.etbnom.
                    end.
                    
                    val_fin = 0.                   
                    val_des = 0.  
                    val_dev = 0.  
                    val_acr = 0. 
                         
                    val_acr = tt-movim.acr-fin.
                    if val_acr = ? then val_acr = 0.
                    val_des = tt-movim.movdes.
                    if val_des = ? then val_des = 0.
                    val_dev = tt-movim.movdev.
                    if val_dev = ? then val_dev = 0.
                    val_fin = tt-movim.movtot.
                    if val_fin = ? then val_fin = 0.
                    val_com = tt-movim.movtot.
                    if val_com = ? then val_com = 0.
                    
                    ttloja.metlj = ttloja.metlj + val_com.
            
                    if vetbcod = 0 
                    then do:
                        find first ttloja where ttloja.etbcod = 0 no-error.
                        if not avail ttloja
                        then do:
                            create ttloja.
                            assign ttloja.etbcod = 0
                                   ttloja.etbnom = "G E R A L".
                        end.
            
                        ttloja.metlj = ttloja.metlj + v-totalzao.
            
                        ttloja.metlj = ttloja.metlj + val_com.
                
                    end.
                end.
            end.
        end.      
    end.   
 end.
 
END.
end procedure.

hide frame f-etb no-pause.
hide frame f-lojas no-pause.
