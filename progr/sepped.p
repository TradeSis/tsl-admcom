{admcab.i}

def var vsresp as log format "Sim/Nao".

def var total_sep like liped.lipsep. 
def var total_qtd like liped.lipqtd.
                        
def buffer xestab for estab.
def var vhiccod   like  plani.hiccod label "Op.Fiscal" initial 522.

def var recpla as recid.
def new shared temp-table tt-pedid
    field pedrec as recid.

def temp-table tt-liped 
    field pedtdc   like liped.pedtdc
    field pednum   like liped.pednum
    field procod   like liped.procod
    field lipqtd   like liped.lipqtd
    field lippreco like liped.lippreco
    field lipsit   like liped.lipsit
    field lipent   like liped.lipent
    field predtf   like liped.predtf
    field predt    like liped.predt
    field lipcor   like liped.lipcor
    field etbcod   like liped.etbcod
    field lipsep   like liped.lipsep
    field protip   like liped.protip
    field pronom   like produ.pronom
    field rua      like ender.rua
        index ind-1 rua
                    pronom.

def buffer btt-liped for liped. 

def var vetbcod like estab.etbcod.
def var vpath as char format "x(30)".
def var vcol as i.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var wdif            like liped.lipent format ">>>9".
def var wsep            like liped.lipent format ">>>9".
def var west            like liped.lipent format "->>>9".
def var vpronom         like produ.pronom.
def var vpednum like pedid.pednum.
def buffer bpedid for pedid.
def buffer cliped for liped.
def buffer xpedid for pedid.
def buffer xliped for liped.
def buffer cplani for plani.
def var vlei            as char format "x(26)".
def var vetb            as i    format ">>9".
def var vcod            as i    format "9999999".
def var vcod2           as i    format "999999".
def var vqtd            as i    format "999999".
def var vnumero         like plani.numero.
def var vserie          like plani.serie.
def var vplacod         like plani.placod.
def var vprotot         like plani.protot.
def var vmovseq         as i.
def var esqcom1         as char format "x(12)" extent 5
    initial ["","","","",""].

def var esqcom2         as char format "x(14)" extent 3
    initial [" Separacao ", " Separa Geral ", " Emissao NF "].

def buffer bliped           for  liped.
def buffer vliped           for  liped.
def buffer bplani           for  plani.
def buffer xestoq           for estoq.
def buffer dplani           for plani.
def var vok                 as log.

form tt-liped.rua  column-label "PAV"
     liped.procod  
     produ.pronom  format "x(35)"
     west          column-label "Est."
     liped.lipqtd  column-label "Ped." format ">>>>9"
     liped.lipsep column-label "Sep." format ">>>9"
            with frame frame-a 10 down centered width 80 row 5.
    
    form
        esqcom1
            with frame f-com1 centered
                 row 4 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2 centered
                 row screen-lines no-box no-labels side-labels column 1.
    
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
    
    
    vetbcod = 0.
    
    update vetbcod with frame f-est width 80 side-label row 4.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        bell.
        message "Estabelecimento nao Cadastrado".
        undo, retry.
    end.
    disp estab.etbnom no-label with frame f-est.
    
    for each tt-liped.
        delete tt-liped.
    end.

    for each tt-pedid:
        delete tt-pedid.
    end.
    
    hide frame f-est no-pause. 
  
    run selped.p(input estab.etbcod).
    
    
    for each tt-pedid:
        find pedid where recid(pedid) = tt-pedid.pedrec no-lock.
        for each liped of pedid where liped.lipent > 0 no-lock:
            if liped.lipsit <> "L" then  next.

            create tt-liped.
            {liped.i tt-liped liped}.

            tt-liped.lipqtd = liped.lipent.
            
            find produ where produ.procod = liped.procod no-lock no-error.
            if avail produ
            then do:
                tt-liped.pronom = produ.pronom.
                                        
                find first ender where ender.procod = produ.procod no-error.
                if avail ender
                then tt-liped.rua = string(ender.pavilhao) + " " +
                                    string(ender.rua) + " " +
                                    string(ender.numero) + " " +
                                    string(ender.andar).
            
            
            
            end.    
            
        end.
    
    end.


bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    
    if recatu1 = ?
    then find first tt-liped where true no-error.
    else find tt-liped where recid(tt-liped) = recatu1 no-lock.
    if not available tt-liped
    then do:
        message "Pedido nao cadsatrado".
        pause.
        undo, retry.
    end.
    if recatu1 = ?
    then find first tt-liped where true no-error.
    else find tt-liped where recid(tt-liped) = recatu1 no-lock.
    clear frame frame-a all no-pause.
    vpronom = "".
    
    find liped where liped.etbcod = tt-liped.etbcod and
                     liped.pednum = tt-liped.pednum and
                     liped.pedtdc = tt-liped.pedtdc and
                     liped.procod = tt-liped.procod and
                     liped.lipcor = tt-liped.lipcor and
                     liped.predt  = tt-liped.predt no-lock.
    
    find produ where produ.procod = liped.procod no-lock no-error.
    
    west = 0.
    for each estoq where estoq.etbcod = 995 and
                         estoq.procod = liped.procod no-lock.
        west = west + estoq.estatual.
    end.
    display tt-liped.rua 
            liped.procod
            produ.pronom when avail produ
            west
            liped.lipqtd
            liped.lipsep 
                with frame frame-a 10 down centered color white/red.
    recatu1 = recid(tt-liped).
    color display message esqcom2[esqpos2] with frame f-com2.
    repeat:
        find next tt-liped where true no-error.
        if not available tt-liped
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.


    
        find liped where liped.etbcod = tt-liped.etbcod and
                         liped.pednum = tt-liped.pednum and
                         liped.pedtdc = tt-liped.pedtdc and
                         liped.procod = tt-liped.procod and
                         liped.lipcor = tt-liped.lipcor and
                         liped.predt  = tt-liped.predt no-lock.
    
         
        
        find produ where produ.procod = liped.procod no-lock no-error.
        west = 0.
        for each estoq where estoq.etbcod = 995 and
                             estoq.procod = liped.procod no-lock.
            west = west + estoq.estatual.
        end.
        display tt-liped.rua  
                liped.procod
                produ.pronom when avail produ
                west
                liped.lipqtd
                liped.lipsep with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    repeat with frame frame-a:
        find tt-liped where recid(tt-liped) = recatu1 no-lock.
 
        find liped where liped.etbcod = tt-liped.etbcod and
                         liped.pednum = tt-liped.pednum and
                         liped.pedtdc = tt-liped.pedtdc and
                         liped.procod = tt-liped.procod and
                         liped.lipcor = tt-liped.lipcor and
                         liped.predt  = tt-liped.predt no-lock.
    
 
 
        status default.
        run color-message.

        
        choose field tt-liped.rua 
                     liped.procod 
                     produ.pronom  
                     west 
                     liped.lipqtd 
                     liped.lipsep 
            help "[C] Consulta Estoque"
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down   page-up
                  tab PF4 F4 ESC return C c).

        run color-normal.

        status default "".
        color display white/red tt-liped.rua liped.procod.
        if keyfunction(lastkey) = "C" or keyfunction(lastkey) = "c"
        then do:
            pause 0.
            color disp message liped.procod with frame frame-a.
            pause 0.
            for each estoq where estoq.etbcod <= 10 and
                                 estoq.procod = liped.procod no-lock.
                 disp estoq.etbcod column-label "FL"
                      estoq.estatual column-label "Estoque"
                                        format "->>>>,>>9"
                                with frame f-estoq1  overlay 10 down column 21
                                color white/gray.
            end.
            for each estoq where estoq.etbcod > 10 and
                                 estoq.etbcod <= 20 and
                                 estoq.procod = liped.procod no-lock.
                disp estoq.etbcod column-label "FL"
                     estoq.estatual column-label "Estoque" format "->>>>,>>9"
                                with frame f-estoq overlay 10 down column 36
                                color white/gray.
            end.
            for each estoq where estoq.etbcod > 20 and
                                 estoq.etbcod <= 30 and
                                 estoq.procod = liped.procod no-lock.
                 disp estoq.etbcod column-label "FL"
                      estoq.estatual column-label "Estoque"
                                        format "->>>>,>>9"
                                with frame f-estoq2  overlay 10 down column 51
                                color white/gray.
            end.
            for each estoq where estoq.etbcod > 30 and
                                 estoq.procod = liped.procod no-lock.
                disp estoq.etbcod column-label "FL"
                     estoq.estatual column-label "Estoque"
                                        format "->>>>,>>9"
                                with frame f-estoq3  overlay 10 down column 66
                                color white/gray.
            end.
            color display white/red liped.procod with frame frame-a.
        end.
        if keyfunction(lastkey) = "TAB"
        then do:
            esqregua = no.
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2] with frame f-com2.
            end.
            else do:
                color display message
                    esqcom2[esqpos2] with frame f-com2.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            esqregua = no.
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 3
                          then 3
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2] with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            esqregua = no.
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.


        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-liped where true no-error.
                if not avail tt-liped
                then leave.
                recatu1 = recid(tt-liped).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-liped where true no-error.
                if not avail tt-liped
                then leave.
                recatu1 = recid(tt-liped).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-liped where true no-error.
            if not avail tt-liped
            then next.
            find liped where liped.etbcod = tt-liped.etbcod and
                             liped.pednum = tt-liped.pednum and
                             liped.pedtdc = tt-liped.pedtdc and
                             liped.procod = tt-liped.procod and
                             liped.lipcor = tt-liped.lipcor and
                             liped.predt  = tt-liped.predt no-lock.
    
 
            color display white/red tt-liped.rua liped.procod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-liped where true no-error.
            if not avail tt-liped
            then next.
            find liped where liped.etbcod = tt-liped.etbcod and
                             liped.pednum = tt-liped.pednum and
                             liped.pedtdc = tt-liped.pedtdc and
                             liped.procod = tt-liped.procod and
                             liped.lipcor = tt-liped.lipcor and
                             liped.predt  = tt-liped.predt no-lock.
    
    
            color display white/red tt-liped.rua liped.procod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
        
        if keyfunction(lastkey) = "return"
        then do on error undo:
            find tt-liped where recid(tt-liped) = recatu1.
            hide frame frame-a no-pause.
            esqregua = no.
            if esqregua = no
            then do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                    with frame f-com2.
                
                if esqcom2[esqpos2] = " Separacao "
                then do transaction:
                    
                    find liped where liped.etbcod = tt-liped.etbcod and
                                     liped.pednum = tt-liped.pednum and
                                     liped.pedtdc = tt-liped.pedtdc and
                                     liped.procod = tt-liped.procod and
                                     liped.lipcor = tt-liped.lipcor and
                                     liped.predt  = tt-liped.predt no-error.
                    if not avail liped
                    then next.
 
                                                
                    update liped.lipsep with frame frame-a.
                                                           
                    
                    find estoq where estoq.etbcod = 995 and
                                     estoq.procod = liped.procod no-lock.
                    
 
                    
                    
                    if estab.etbcod <> 22 
                    then do: 
                        if ((estoq.estatual - estoq.estpedcom) >= 0 and 
                           ((estoq.estatual - estoq.estpedcom) 
                             - liped.lipsep) < 0) or
                           (estoq.estatual - estoq.estpedcom) < 0 
                        then do:
                            display "Qtd Estoque :" at 5 
                                    (estoq.estatual - estoq.estpedcom) 
                                                no-label format "->>,>>9.99"
                                    "Qtd Desejada:" at 5 liped.lipsep 
                                                no-label format "->>,>>9.99"
                                        with frame f-aviso overlay row 10
                                                    side-label centered 
                                    title "Estoque nao possui esta Quantidade".
                            pause.
                            undo, retry.
                        end.
                    end.
        

                    assign liped.lippreco = estoq.estcusto
                           tt-liped.lipsep = liped.lipsep
                           tt-liped.lippreco = estoq.estcusto
                           liped.lipent = estoq.estatual.
                    
                    
                    find next tt-liped where true no-error.
                    if not avail liped
                    then next.

                    find liped where liped.etbcod = tt-liped.etbcod and
                                     liped.pednum = tt-liped.pednum and
                                     liped.pedtdc = tt-liped.pedtdc and
                                     liped.procod = tt-liped.procod and
                                     liped.lipcor = tt-liped.lipcor and
                                     liped.predt  = tt-liped.predt no-error.
    
                    if not avail liped
                    then next.
                    color display white/red tt-liped.rua liped.procod.
                    
                    if frame-line(frame-a) = frame-down(frame-a)
                    then scroll with frame frame-a.
                    else down with frame frame-a.
                     
                    
                    
                end.
                                 
                if esqcom2[esqpos2] = " Separa Geral "
                then do transaction:
                  
                    for each tt-liped:
                        find liped where liped.etbcod = tt-liped.etbcod and
                                         liped.pednum = tt-liped.pednum and
                                         liped.pedtdc = tt-liped.pedtdc and
                                         liped.procod = tt-liped.procod and
                                         liped.lipcor = tt-liped.lipcor and
                                         liped.predt  = tt-liped.predt
                                         no-error.
                        if not avail liped
                        then next.
 
                        assign liped.lipsep = liped.lipqtd.
                    
                        find estoq where 
                             estoq.etbcod = 995 and 
                             estoq.procod = liped.procod no-lock no-error.
                    
                        assign liped.lippreco = estoq.estcusto
                               tt-liped.lipsep = liped.lipsep
                               tt-liped.lippreco = estoq.estcusto
                               liped.lipent = estoq.estatual.

                    end.

                    recatu1 = ?.
                    leave. 
                end.

                if esqcom2[esqpos2] = " Emissao NF "
                then do transaction:
                    
                    vsresp = no.
                    message "Confirma emissao da NF ?" update vsresp.
                    if vsresp = no
                    then leave.
                    
                    hide message no-pause.
                    
                    message "Aguarde... Gerando NF.".
                    
                    find first tt-liped where tt-liped.lipsep > 0 no-error.
                    if not avail tt-liped
                    then do:
                        message "Nenhum produto separado".
                        pause.
                        undo, retry.
                    end.
                    
                    vserie = "U".
                    
                    find last bplani where bplani.etbcod = 995 and
                                           bplani.placod <= 500000 and
                                           bplani.placod <> ? no-lock no-error.
                    if not avail bplani
                    then vplacod = 1.
                    else vplacod = bplani.placod + 1.
                    
                    
                    find last plani use-index numero 
                                    where plani.etbcod = 995 and
                                          plani.emite  = 995 and
                                          plani.serie  = vserie       and
                                          plani.movtdc <> 4           and
                                          plani.movtdc <> 5 no-lock no-error. 
                    if not avail plani
                    then vnumero = 1.
                    else vnumero = plani.numero + 1.
                    /*
                    if estab.etbcod = 998 or
                       estab.etbcod = 995
                    then do: */
                        vnumero = 0.
                        for each xestab where xestab.etbcod = 998 or
                                              xestab.etbcod = 995 no-lock.
                                     
                            find last plani use-index numero 
                                where plani.etbcod = xestab.etbcod and
                                      plani.emite  = xestab.etbcod and
                                      plani.serie  = vserie       and
                                      plani.movtdc <> 4           and
                                      plani.movtdc <> 5 no-lock no-error. 
                      
                            if not avail plani
                            then vnumero = 1.
                            else do:
                                if vnumero < plani.numero
                                then vnumero = plani.numero.
                            end.    
                        end.
                        if vnumero = 1
                        then.
                        else vnumero = vnumero + 1.
                    /* end.   */
                    
                    display vnumero
                            vserie with frame f-num centered row 10 overlay
                                            side-label title " Nota Fiscal "
                                                color blue/cyan.
                    
                    pause 2 no-message.
                    
                    create plani.
                    assign plani.etbcod   = 995
                           plani.placod   = vplacod
                           plani.emite    = 995
                           plani.serie    = vserie
                           plani.numero   = vnumero
                           plani.movtdc   = 6
                           plani.desti    = liped.etbcod
                           plani.pladat   = today
                           plani.notfat   = liped.etbcod
                           plani.dtinclu  = today
                           plani.horincl  = time
                           plani.notsit   = no
                           plani.hiccod   = 5152
                           plani.opccod   = 5152
                           plani.datexp   = today.
    
                    recpla = recid(plani).
                    release plani.
                
                    find plani where recid(plani) = recpla.

                    vprotot = 0.
                    vmovseq = 0.
                    total_sep = 0.
                    total_qtd = 0.
                                         
                    for each tt-liped where tt-liped.lipsep > 0
                                      break by tt-liped.procod
                                            by tt-liped.lipsep:
                        
                        /*find first ender where 
                                   ender.procod = tt-liped.procod 
                                    no-lock no-error.
                        if not avail ender then next.
                                    
                        if ender.pavilhao <> 1
                        then next.*/
                        
                                                
                        total_sep = total_sep + tt-liped.lipsep.
                        total_qtd = total_qtd + tt-liped.lipqtd.
                        
                        if last-of(tt-liped.procod)
                        then do:
                                            
                                         
                            find liped where liped.etbcod = tt-liped.etbcod and
                                             liped.pednum = tt-liped.pednum and
                                             liped.pedtdc = tt-liped.pedtdc and
                                             liped.procod = tt-liped.procod and
                                             liped.lipcor = tt-liped.lipcor and
                                             liped.predt  = tt-liped.predt 
                                                            no-error.
    
                         
                            find estoq where estoq.etbcod = 995 and
                                             estoq.procod = liped.procod 
                                                no-lock.
                                         
                            vmovseq = vmovseq + 1.
                        
                            create movim.

                            assign movim.movtdc = plani.movtdc
                                   movim.PlaCod = plani.placod
                                   movim.etbcod = plani.etbcod
                                   movim.movseq = vmovseq
                                   movim.procod = liped.procod
                                   movim.movqtm = total_sep
                                   movim.movpc  = estoq.estcusto
                                   movim.movdat = plani.pladat
                                   movim.MovHr  = int(time)
                                   movim.emite  = plani.emite
                                   movim.desti  = plani.desti
                                   movim.datexp = plani.datexp.    
                                   
                            if estoq.estcusto = 0
                            then movim.movpc = 1.
                            
                                             
                            plani.platot = plani.platot + 
                                           (movim.movpc * movim.movqtm).
                            plani.protot = plani.protot + 
                                           (movim.movpc * movim.movqtm).
                        
                            vprotot = vprotot + (liped.lippreco * 
                                                 total_sep).

                            if total_sep >= total_qtd
                            then liped.lipsit = "F".
                         
                            
                            total_sep = 0.
                            total_qtd = 0.
                        
                        end.
                        
                    end.
                    
                    if plani.protot = 0 or
                       plani.platot = 0
                    then do:
                       
                        message "Total da nota zerado".
                        pause.
                        undo, retry.
                        
                    end.
                    
                    message "Prepare a Impressora".
                    pause.
                    run imptra_l.p (input recid(plani)).
                    
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc and
                                         movim.movdat = plani.pladat no-lock:
                
                        run atuest.p (input recid(movim),
                                      input "I",
                                      input 0).

                    end.
                    
                    for each tt-liped:
                                      /*
                        find first ender where 
                                   ender.procod = tt-liped.procod 
                                    no-lock no-error.
                        if not avail ender then next.
                                    
                        if ender.pavilhao <> 1
                        then next.  */
                                     
                        find liped where liped.etbcod = tt-liped.etbcod and
                                         liped.pednum = tt-liped.pednum and
                                         liped.pedtdc = tt-liped.pedtdc and
                                         liped.procod = tt-liped.procod and
                                         liped.lipcor = tt-liped.lipcor and
                                         liped.predt  = tt-liped.predt 
                                                            no-error.
    
                     
                        
                        find pedid where pedid.etbcod = tt-liped.etbcod and
                                         pedid.pedtdc = tt-liped.pedtdc and
                                         pedid.pednum = tt-liped.pednum
                                            no-error.
                                            
                            
                             
                        pedid.pedobs[3] = pedid.pedobs[3]
                              + "|DATA_EXCLUSAO=" + string(today,"99/99/9999")
                              + "|HORA_EXCLUSAO=" + string(time,"HH:MM:SS")
                              + "|ETB_EXCLUSAO="  + string(setbcod)
                              + "|USUARIO_EXCLUSAO=" + string(sfuncod)
                              + "|PROG_EXCLUSAO=" + program-name(1)
                              + "|".
 
                        pedid.sitped = "R".
                        liped.lipsit = "R".
                    
                        
                        find nffped where nffped.forcod = plani.placod and
                                          nffped.movndc = plani.movtdc and
                                          nffped.movsdc = plani.serie  and
                                          nffped.pednum = liped.pednum 
                                                no-error.
                    
                        if not avail nffped
                        then do: 
                    
                            create nffped.
                            assign nffped.forcod = plani.placod
                                   nffped.movndc = plani.movtdc
                                   nffped.movsdc = plani.serie
                                   nffped.pednum = liped.pednum.
                    
                        end.
                    
                    end.
                    
                    /***************************
                    

                    find last bplani where bplani.etbcod = 995 and
                                           bplani.placod <= 500000 and
                                           bplani.placod <> ? no-lock no-error.
                    if not avail bplani
                    then vplacod = 1.
                    else vplacod = bplani.placod + 1.
                    
                    
                    find last plani use-index numero 
                                    where plani.etbcod = 995 and
                                          plani.emite  = 995 and
                                          plani.serie  = vserie       and
                                          plani.movtdc <> 4           and
                                          plani.movtdc <> 5 no-lock no-error. 
                    if not avail plani
                    then vnumero = 1.
                    else vnumero = plani.numero + 1.
                    /*
                    if estab.etbcod = 998 or
                       estab.etbcod = 995
                    then do: */
                        vnumero = 0.
                        for each xestab where xestab.etbcod = 998 or
                                              xestab.etbcod = 995 no-lock.
                                     
                            find last plani use-index numero 
                                where plani.etbcod = xestab.etbcod and
                                      plani.emite  = xestab.etbcod and
                                      plani.serie  = vserie       and
                                      plani.movtdc <> 4           and
                                      plani.movtdc <> 5 no-lock no-error. 
                      
                            if not avail plani
                            then vnumero = 1.
                            else do:
                                if vnumero < plani.numero
                                then vnumero = plani.numero.
                            end.    
                        end.
                        if vnumero = 1
                        then.
                        else vnumero = vnumero + 1.
                    /* end.   */
                    
                    display vnumero
                            vserie with frame f-num centered row 10 overlay
                                            side-label title " Nota Fiscal "
                                                color blue/cyan.
                    
                    create plani.
                    assign plani.etbcod   = 995
                           plani.placod   = vplacod
                           plani.emite    = 995
                           plani.serie    = vserie
                           plani.numero   = vnumero
                           plani.movtdc   = 6
                           plani.desti    = liped.etbcod
                           plani.pladat   = today
                           plani.notfat   = liped.etbcod
                           plani.dtinclu  = today
                           plani.horincl  = time
                           plani.notsit   = no
                           plani.hiccod   = 5152
                           plani.opccod   = 5152
                           plani.datexp   = today.
    
                    recpla = recid(plani).
                    release plani.
                
                    find plani where recid(plani) = recpla.

                     
                    
                    
                    
                    vprotot = 0.
                    vmovseq = 0.
                    total_sep = 0.
                    total_qtd = 0.
                                         
                    for each tt-liped where tt-liped.lipsep > 0
                                      break by tt-liped.procod
                                            by tt-liped.lipsep:
                        
                        find first ender where 
                                   ender.procod = tt-liped.procod 
                                    no-lock no-error.
                        if avail ender 
                        then do:
                                    
                            if ender.pavilhao = 1
                            then next.
                            
                        end.
                        
                        total_sep = total_sep + tt-liped.lipsep.
                        total_qtd = total_qtd + tt-liped.lipqtd.
                        
                        if last-of(tt-liped.procod)
                        then do:
                                            
                                         
                            find liped where liped.etbcod = tt-liped.etbcod and
                                             liped.pednum = tt-liped.pednum and
                                             liped.pedtdc = tt-liped.pedtdc and
                                             liped.procod = tt-liped.procod and
                                             liped.lipcor = tt-liped.lipcor and
                                             liped.predt  = tt-liped.predt 
                                                            no-error.
    
                         
                            find estoq where estoq.etbcod = 995 and
                                             estoq.procod = liped.procod 
                                                no-lock.
                                         
                            vmovseq = vmovseq + 1.
                        
                            create movim.

                            assign movim.movtdc = plani.movtdc
                                   movim.PlaCod = plani.placod
                                   movim.etbcod = plani.etbcod
                                   movim.movseq = vmovseq
                                   movim.procod = liped.procod
                                   movim.movqtm = total_sep
                                   movim.movpc  = estoq.estcusto
                                   movim.movdat = plani.pladat
                                   movim.MovHr  = int(time)
                                   movim.emite  = plani.emite
                                   movim.desti  = plani.desti
                                   movim.datexp = plani.datexp.    
                                   
                            if estoq.estcusto = 0
                            then movim.movpc = 1.
                            
                                             
                            plani.platot = plani.platot + 
                                           (movim.movpc * movim.movqtm).
                            plani.protot = plani.protot + 
                                           (movim.movpc * movim.movqtm).
                        
                            vprotot = vprotot + (liped.lippreco * 
                                                 total_sep).

                            if total_sep >= total_qtd
                            then liped.lipsit = "F".
                         
                            
                            total_sep = 0.
                            total_qtd = 0.
                        
                        end.
                        
                    end.
                    
                    if plani.protot = 0 or
                       plani.platot = 0
                    then do:
                       
                        message "Total da nota zerado".
                        pause.
                        undo, retry.
                        
                    end.
                    
                    message "Prepare a Impressora".
                    pause.
                    run imptra_l.p (input recid(plani)).
                    
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc and
                                         movim.movdat = plani.pladat no-lock:
                
                        run atuest.p (input recid(movim),
                                      input "I",
                                      input 0).

                    end.
                    
                    
                    for each tt-liped:
                                     

                        find liped where liped.etbcod = tt-liped.etbcod and
                                         liped.pednum = tt-liped.pednum and
                                         liped.pedtdc = tt-liped.pedtdc and
                                         liped.procod = tt-liped.procod and
                                         liped.lipcor = tt-liped.lipcor and
                                         liped.predt  = tt-liped.predt 
                                                            no-error.
    
                     
                        
                        find pedid where pedid.etbcod = tt-liped.etbcod and
                                         pedid.pedtdc = tt-liped.pedtdc and
                                         pedid.pednum = tt-liped.pednum
                                            no-error.
                                            
                        pedid.pedobs[3] = pedid.pedobs[3]
                              + "|DATA_EXCLUSAO=" + string(today,"99/99/9999")
                              + "|HORA_EXCLUSAO=" + string(time,"HH:MM:SS")
                              + "|ETB_EXCLUSAO="  + string(setbcod)
                              + "|USUARIO_EXCLUSAO=" + string(sfuncod)
                              + "|PROG_EXCLUSAO=" + program-name(1)
                              + "|".
 
                     
                        pedid.sitped = "R".
                        liped.lipsit = "R".
                    
                        
                        find nffped where nffped.forcod = plani.placod and
                                          nffped.movndc = plani.movtdc and
                                          nffped.movsdc = plani.serie  and
                                          nffped.pednum = liped.pednum 
                                                no-error.
                    
                        if not avail nffped
                        then do: 
                    
                            create nffped.
                            assign nffped.forcod = plani.placod
                                   nffped.movndc = plani.movtdc
                                   nffped.movsdc = plani.serie
                                   nffped.pednum = liped.pednum.
                    
                        end.
                    
                    end.
                    
                    
                    ************************/                    
                    
                    vpednum = 0.
                    find last pedid where pedid.pedtdc = 3 
                                      and pedid.sitped = "E" 
                                      and pedid.etbcod = plani.etbcod 
                                      and pedid.pednum >= 100000
                                   no-lock no-error.
                    if not avail pedid  
                    then do:  
                    
                        find last pedid where pedid.pedtdc = 3
                                          and pedid.etbcod = plani.etbcod
                                          and pedid.pednum >= 100000 
                                          no-lock no-error.
                        if avail pedid  
                        then vpednum = pedid.pednum + 1. 
                        else vpednum = 100000.

                        create pedid. 
                        assign pedid.etbcod = plani.etbcod
                               pedid.pedtdc = 3 
                               pedid.peddat = today 
                               pedid.pednum = vpednum 
                               pedid.sitped = "E" 
                               pedid.pedsit = yes.
                    end.
                    
                    leave.
                
                end.
                
            end.
            
            else do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
            end.
        end.
    
        display esqcom2[esqpos2] with frame f-com2.
        
        find liped where liped.etbcod = tt-liped.etbcod and
                         liped.pednum = tt-liped.pednum and
                         liped.pedtdc = tt-liped.pedtdc and
                         liped.procod = tt-liped.procod and
                         liped.lipcor = tt-liped.lipcor and
                         liped.predt  = tt-liped.predt no-lock.
    
 
        find produ where produ.procod = liped.procod no-lock no-error.
        west = 0.
        for each estoq where estoq.etbcod = 995 and
                             estoq.procod = liped.procod no-lock.
             west = west + estoq.estatual.
        end.
        display tt-liped.rua 
                liped.procod 
                produ.pronom when avail produ 
                west 
                liped.lipqtd
                liped.lipsep with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-liped).
        
    end.
    
end.

procedure color-message.
color display message
        tt-liped.rua  
        liped.procod  
        produ.pronom when avail produ  
        west  
        liped.lipqtd 
        liped.lipsep with frame frame-a.
end procedure.
procedure color-normal.
color display normal

        tt-liped.rua  
        liped.procod  
        produ.pronom when avail produ  
        west  
        liped.lipqtd 
        liped.lipsep with frame frame-a.
  


end procedure.


