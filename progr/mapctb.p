{admcab.i}

def var v-des as char.
def var ii as int.
def var v-sub as log.

def var vtipo as char format "x(10)"
    extent 3 initial ["Sintetico","Analitico","Aliquota"].
def var vtot01          like mapctb.t01.
def var vtot02          like mapctb.t01.
def var vtot03          like mapctb.t01.
def var vtot04          like mapctb.t01.
def var vtot05          like mapctb.t01.
def var vtot06          like mapctb.t01.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial ["Inclusao","Alteracao","Consulta","Exclusao","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Excluidos","","","",""].


def buffer bmapctb       for mapctb.
def var vetbcod         like mapctb.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.

def temp-table tt-map like mapctb.

def temp-table tt-mapctb
    field etbcod like mapctb.etbcod
    field cxacod like mapctb.cxacod
    field datmov like mapctb.datmov
    field nrored like mapctb.nrored
    field venbru like plani.platot
    field rec    as recid
        index ind-1 etbcod
                    cxacod
                    datmov.
      
      
      
    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

repeat:

    hide frame f-com2 no-pause.
    
    for each tt-mapctb:
        delete tt-mapctb.
    end.
            
    recatu1 = ?.
            
    vetbcod = 0.
    update vetbcod label "Filial" with frame f1 side-label width 80.
    if vetbcod = 0
    then display "TODAS" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Filial nao cadastrada".
            pause.
            undo, retry.
        end.
        display estab.etbnom no-label with frame f1.
            
    end.
 
    update vdti label "Periodo" 
           vdtf no-label with frame f1.
            

    assign vtot01 = 0
           vtot02 = 0
           vtot03 = 0
           vtot04 = 0
           vtot05 = 0
           vtot06 = 0.

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
                         
        
        for each mapctb where mapctb.etbcod = estab.etbcod and 
                              mapctb.datmov >= vdti        and 
                              mapctb.datmov <= vdtf no-lock:
                                  
                                  
            if mapctb.ch2 = "E"
            then next.
            
            create tt-mapctb. 
            assign tt-mapctb.etbcod = mapctb.etbcod 
                   tt-mapctb.cxacod = mapctb.cxacod 
                   tt-mapctb.datmov = mapctb.datmov
                   tt-mapctb.rec    = recid(mapctb)
                   tt-mapctb.venbru = mapctb.t01 + 
                                      mapctb.t02 + 
                                      mapctb.t03 + 
                                      mapctb.t04 + 
                                      mapctb.t05 + 
                                      mapctb.vlsub.
            /*if int(mapctb.nrofab) > 0
            then tt-mapctb.nrored = mapctb.nrored + 1.
            else*/ tt-mapctb.nrored = mapctb.nrored.
            
            assign vtot01 = vtot01 + mapctb.t01
                   vtot02 = vtot02 + mapctb.t02
                   vtot03 = vtot03 + mapctb.t03
                   vtot04 = vtot04 + mapctb.vlsub
                   vtot05 = vtot05 + mapctb.t05
                   vtot06 = vtot06 + mapctb.gtotal.
                   
                   
                       
        end.

    end.        

    display  vtot05  to 36 format ">>>>>,>>9.99"
             vtot01  to 47 format ">>>>,>>9.99"
             /*vtot02  to 44 format ".99"
             vtot03  to 53 format ".99"*/ 
             vtot04  to 64 format ">>>>>,>>9.99"
                with frame f-tot no-label no-box 
                    row 20 color message width 80.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first tt-mapctb where
            true no-error.
    else
        find tt-mapctb where recid(tt-mapctb) = recatu1.
    vinicio = yes.
    if not available tt-mapctb
    then do:
        message "Nenhum Registro Encontrado".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.
    find mapctb where recid(mapctb) = tt-mapctb.rec no-lock.
    display
        tt-mapctb.etbcod column-label "Fil" format ">>9"
        mapctb.cxacod column-label "Eq" format ">9"
        mapctb.de1    column-label "Cx" format ">9"
        mapctb.datmov    column-label "Data.Mov"  format "99/99/99"
        tt-mapctb.nrored    column-label "Red." format ">>99"
        mapctb.t05       column-label "Val.18" format ">>>>,>>9.99"
        mapctb.t01       column-label "Val.17" format ">>>,>>9.99"
        mapctb.t02       column-label "12" format "99"
        mapctb.t03       column-label "07" format "99"
        mapctb.vlsub     column-label "Val.Sub" format ">>>,>>9.99" 
        mapctb.gtotal    column-label "G.TOTAL" format ">>,>>>,>>9.99"
            with frame frame-a 12 down width 80 row 4 
                title "Periodo: " + string(vdti) + " - " + 
                      string(vdtf).

    recatu1 = recid(tt-mapctb).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-mapctb where
                true.
        if not available tt-mapctb
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        find mapctb where recid(mapctb) = tt-mapctb.rec no-lock.
        display
            tt-mapctb.etbcod
            mapctb.cxacod
            mapctb.de1
            mapctb.datmov
            tt-mapctb.nrored 
            mapctb.t05
            mapctb.t01    
            mapctb.t02    
            mapctb.t03    
            mapctb.vlsub   
            mapctb.gtotal
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-mapctb where recid(tt-mapctb) = recatu1.

        run color-message.
        choose field tt-mapctb.etbcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        run color-normal.
        
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-mapctb where true no-error.
                if not avail tt-mapctb
                then leave.
                recatu1 = recid(tt-mapctb).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-mapctb where true no-error.
                if not avail tt-mapctb
                then leave.
                recatu1 = recid(tt-mapctb).
            end.
            leave.
        end.


        if keyfunction(lastkey) = "cursor-left"
        then do:
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
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-mapctb where
                true no-error.
            if not avail tt-mapctb
            then next.
            color display normal
                tt-mapctb.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-mapctb where
                true no-error.
            if not avail tt-mapctb
            then next.
            color display normal
                tt-mapctb.etbcod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 2 column
                        centered no-validate.
                        
                for each tt-map:
                    delete tt-map.
                end.     
                            
        
                create tt-map.
                update tt-map.etbcod   label "Filial"
                       tt-map.de1 label "Caixa"   
                       tt-map.cxacod   label "Equipamento"
                       tt-map.de2      label "Versao"
                       tt-map.ch1 format "x(25)" label "No.Serie"
                       tt-map.datmov   label "Data Movimento"
                       tt-map.datred   label "Data Ultima Reducao"
                       tt-map.datatu   label "Data Atual"
                       tt-map.nrored   label "Ultima Reducao Z"
                       tt-map.t05      label "Val.18%"
                       tt-map.t01      label "Val.17%"
                       tt-map.t02      label "Val.12%" format ">,>>9.99"
                       tt-map.t03      label "Val.07%"
                       tt-map.vlsub    label "Val.Sub" 
                       tt-map.gtotal   label "Grande Total"
                       tt-map.cooini          label "Contador Inicial"
                       tt-map.coofin          label "Contador Final"
                       tt-map.t12      label "PIS"
                       tt-map.t13      label "COFINS"

                       .
                       
                v-des = "". 
                v-sub = yes. 
                do ii = 1 to 25: 
                    if substring(tt-map.ch1,ii,1) = " " 
                    then v-des = v-des + " ". 
                    else if substring(tt-map.ch1,ii,1) = "0" and v-sub 
                         then. 
                         else assign v-sub = no 
                                     v-des = v-des + substring(tt-map.ch1,ii,1).
                end.

                
                assign tt-map.ch2 = "I"
                       tt-map.ch1 = v-des.
                       
                find mapctb where mapctb.etbcod = tt-map.etbcod and
                                  mapctb.cxacod = tt-map.cxacod and
                                  mapctb.datmov = tt-map.datmov and
                                  mapctb.nrored = tt-map.nrored no-error.
                if not avail mapctb
                then do:
                    create mapctb.
                    assign mapctb.etbcod = tt-map.etbcod
                           mapctb.cxacod = tt-map.cxacod 
                           mapctb.datmov = tt-map.datmov
                           mapctb.nrored = tt-map.nrored.
                end.
                
                assign mapctb.etbcod   = tt-map.etbcod
                       mapctb.de1      = tt-map.de1
                       mapctb.cxacod   = tt-map.cxacod
                       mapctb.de2      = tt-map.de2
                       mapctb.ch1      = tt-map.ch1
                       mapctb.datmov   = tt-map.datmov
                       mapctb.datred   = tt-map.datred
                       mapctb.datatu   = tt-map.datatu
                       mapctb.nrored   = tt-map.nrored
                       mapctb.t05      = tt-map.t05
                       mapctb.t01      = tt-map.t01
                       mapctb.t02      = tt-map.t02
                       mapctb.t03      = tt-map.t03
                       mapctb.vlsub    = tt-map.vlsub
                       mapctb.gtotal   = tt-map.gtotal
                       mapctb.cooini   = tt-map.cooini
                       mapctb.coofin   = tt-map.coofin
                       mapctb.ch1      = tt-map.ch1
                       mapctb.ch2      = tt-map.ch2
                       mapctb.t12      = tt-map.t12
                       mapctb.t13      = tt-map.t13
                       .
                       
                                      
                create tt-mapctb. 
                assign tt-mapctb.etbcod = mapctb.etbcod 
                       tt-mapctb.cxacod = mapctb.cxacod 
                       tt-mapctb.datmov = mapctb.datmov
                       tt-mapctb.rec    = recid(mapctb)
                       tt-mapctb.venbru = mapctb.t01 + 
                                          mapctb.t02 + 
                                          mapctb.t03 + 
                                          mapctb.t04 + 
                                          mapctb.t05 + 
                                          mapctb.vlsub.
                /*if int(mapctb.nrofab) > 0
                then tt-mapctb.nrored = mapctb.nrored + 1.
                else*/ tt-mapctb.nrored = mapctb.nrored.
            
                
                assign vtot01 = 0
                       vtot02 = 0 
                       vtot03 = 0 
                       vtot04 = 0 
                       vtot05 = 0
                       vtot06 = 0.
            
                for each estab where if vetbcod = 0
                                     then true
                                     else estab.etbcod = vetbcod no-lock:
                         
        
                    for each bmapctb where bmapctb.etbcod = estab.etbcod and 
                                           bmapctb.datmov >= vdti        and 
                                           bmapctb.datmov <= vdtf no-lock:
                                  
                        if bmapctb.ch2 = "E"
                        then next.

                        assign vtot01 = vtot01 + bmapctb.t01
                               vtot02 = vtot02 + bmapctb.t02
                               vtot03 = vtot03 + bmapctb.t03
                               vtot04 = vtot04 + bmapctb.vlsub
                               vtot05 = vtot05 + bmapctb.t05
                               vtot06 = vtot06 + (bmapctb.t01 + 
                                                  bmapctb.t02 + 
                                                  bmapctb.t03 + 
                                                  bmapctb.t04 + 
                                                  bmapctb.t05 + 
                                                  bmapctb.vlsub).
                    end.
                    
                end. 

                recatu1 = recid(tt-mapctb).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 2 column centered.

                find mapctb where recid(mapctb) = tt-mapctb.rec.
               
                update mapctb.cxacod   label "Equipamento"
                       mapctb.de1      label "Caixa" 
                       mapctb.de2      label "Versao" 
                       mapctb.ch1 format "x(25)" label "No.Serie" 
                       mapctb.datmov   label "Data Movimento" 
                       mapctb.datred   label "Data Reducao" 
                       mapctb.datatu   label "Data Atual" 
                       tt-mapctb.nrored   label "Reducao Z" 
                       mapctb.t05      label "Val.18%"
                       mapctb.t01      label "Val.17%" 
                       mapctb.t02      label "Val.12%" format ">,>>9.99" 
                       mapctb.t03      label "Val.07%" 
                       mapctb.vlsan    label "Val.Sangria" 
                       mapctb.vlsub    label "Val.Subst" 
                       mapctb.vlsup    label "Val.Supri" 
                       mapctb.vlise    label "Val.Isento" 
                       mapctb.vlacr    label "Val.Acrescimo" 
                       mapctb.vldes    label "Val.Desconto" 
                       mapctb.vlcan    label "Val.Cancelados" 
                       mapctb.valliq    label "Val.Liquido"
                       mapctb.valbru    label "Val.Bruto"
                       mapctb.gtotal   label "Grande Total" 
                       mapctb.cooini   label "Contador Inicial" 
                       mapctb.coofin   label "Contador Final"
                       mapctb.t11      label "Cartao"
                       mapctb.t12      label "PIS"
                       mapctb.t13      label "COFINS"
                       .
                       
                       
                v-des = "". 
                v-sub = yes. 
                do ii = 1 to 25: 
                    if substring(mapctb.ch1,ii,1) = " " 
                    then v-des = v-des + " ". 
                    else if substring(mapctb.ch1,ii,1) = "0" and v-sub 
                         then. 
                         else assign v-sub = no 
                                     v-des = v-des + substring(mapctb.ch1,ii,1).
                end.

                
                assign mapctb.ch2 = "A"
                       mapctb.ch1 = v-des.
                /*
                tt-mapctb.nrored = mapctb.nrored.
                */
                /*if mapctb.nrofab <> 0
                then mapctb.nrored = tt-mapctb.nrored - 1.
                else*/ mapctb.nrored = tt-mapctb.nrored.
                 
                tt-mapctb.venbru = mapctb.t01 +  
                                   mapctb.t02 +  
                                   mapctb.t03 +  
                                   mapctb.t04 +  
                                   mapctb.t05 +  
                                   mapctb.vlsub.
                tt-mapctb.cxacod = mapctb.cxacod.                   
                mapctb.valliq    = tt-mapctb.venbru.
                mapctb.valbru    = tt-mapctb.venbru.
                assign vtot01 = 0
                       vtot02 = 0 
                       vtot03 = 0 
                       vtot04 = 0 
                       vtot05 = 0
                       vtot06 = 0.
            
                for each estab where if vetbcod = 0
                                     then true
                                     else estab.etbcod = vetbcod no-lock:
                         
        
                    for each bmapctb where bmapctb.etbcod = estab.etbcod and 
                                           bmapctb.datmov >= vdti        and 
                                           bmapctb.datmov <= vdtf no-lock:
                                  
                        if bmapctb.ch2 = "E"
                        then next.

                        assign vtot01 = vtot01 + bmapctb.t01
                               vtot02 = vtot02 + bmapctb.t02
                               vtot03 = vtot03 + bmapctb.t03
                               vtot04 = vtot04 + bmapctb.vlsub
                               vtot05 = vtot05 + bmapctb.t05
                               vtot06 = vtot06 + (bmapctb.t01 + 
                                                  bmapctb.t02 + 
                                                  bmapctb.t03 + 
                                                  bmapctb.t04 + 
                                                  bmapctb.t05 + 
                                                  bmapctb.vlsub).
                    end.
                    
                end. 
                       

            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 2 column centered.
                find mapctb where recid(mapctb) = tt-mapctb.rec no-lock.
                disp mapctb.etbcod   label "Filial"
                     int(mapctb.de1) label "Caixa"   
                     mapctb.cxacod   label "Equipamento"
                     mapctb.de2      label "Versao"
                     mapctb.ch1 format "x(25)" label "No.Serie"
                     mapctb.datmov   label "Data Movimento"
                     mapctb.datred   label "Data Reducao"
                     mapctb.datatu   label "Data Atual"
                     mapctb.nrored   label "Reducao Z"
                     mapctb.t05      label "Val.18%"
                     mapctb.t01      label "Val.17%"
                     mapctb.t02      label "Val.12%" format ">,>>9.99"
                     mapctb.t03      label "Val.07%"
                     mapctb.vlsub    label "Val.Sub" 
                     mapctb.gtotal   label "Grande Total"
                     mapctb.cooini          label "Contador Inicial"
                     mapctb.coofin          label "Contador Final"
                     mapctb.t11      label "Cartao"
                     mapctb.t12      label "PIS"
                     mapctb.t13      label "COFINS"
                     .
            
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tt-mapctb.nrored update sresp.
                if not sresp
                then leave.
                
                find next tt-mapctb where true no-error.
                if not available tt-mapctb
                then do:
                    find tt-mapctb where recid(tt-mapctb) = recatu1.
                    find prev tt-mapctb where true no-error.
                end.
                recatu2 = if available tt-mapctb
                          then recid(tt-mapctb)
                          else ?.
                find first tt-mapctb where recid(tt-mapctb) = recatu1.
                find mapctb where recid(mapctb) = tt-mapctb.rec.
                /*
                if int(mapctb.nrofab) > 0
                then do:
                    
                    find mapctb where mapctb.etbcod = tt-mapctb.etbcod and
                                      mapctb.cxacod = tt-mapctb.cxacod and
                                      mapctb.datmov = tt-mapctb.datmov and
                                      mapctb.nrored = tt-mapctb.nrored - 1
                                    no-error.

                end.
                else do:
                    
                    find mapctb where mapctb.etbcod = tt-mapctb.etbcod and
                                      mapctb.cxacod = tt-mapctb.cxacod and
                                      mapctb.datmov = tt-mapctb.datmov and
                                      mapctb.nrored = tt-mapctb.nrored
                                        no-error.

                
                end.
                */
                if avail mapctb
                then do:
                    
                    assign mapctb.ch2 = "E".


                    /* delete mapctb. */
                    
                end.
                
                delete tt-mapctb.
                assign vtot01 = 0
                       vtot02 = 0 
                       vtot03 = 0 
                       vtot04 = 0 
                       vtot05 = 0
                       vtot06 = 0.
            
                for each estab where if vetbcod = 0
                                     then true
                                     else estab.etbcod = vetbcod no-lock:
                         
        
                    for each bmapctb where bmapctb.etbcod = estab.etbcod and 
                                           bmapctb.datmov >= vdti        and 
                                           bmapctb.datmov <= vdtf no-lock:
                                  
                        if bmapctb.ch2 = "E"
                        then next.
                        
                        assign vtot01 = vtot01 + bmapctb.t01
                               vtot02 = vtot02 + bmapctb.t02
                               vtot03 = vtot03 + bmapctb.t03
                               vtot04 = vtot04 + bmapctb.vlsub
                               vtot05 = vtot05 + bmapctb.t05
                               vtot06 = vtot06 + (bmapctb.t01 + 
                                                  bmapctb.t02 + 
                                                  bmapctb.t03 + 
                                                  bmapctb.t04 + 
                                                  bmapctb.t05 + 
                                                  bmapctb.vlsub).
                    end.
                    
                end. 
                 
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                
                display vtipo no-label 
                        with frame flista no-label row 10 centered.

                choose field vtipo with frame flista.
                hide frame flista no-pause. 
                if frame-index = 1 
                then run lismap1.p (input vetbcod,
                                    input vdti,
                                    input vdtf).

                if frame-index = 2 
                then run lismap2.p (input tt-mapctb.etbcod,
                                    input vdti,
                                    input vdtf).

                if frame-index = 3 
                then run lismap4.p.


                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            if esqcom2[esqpos2] = "Excluidos"
            then do:
                pause 0.
                run mapctb-exc.p(vetbcod, vdti, vdtf).
                pause 0.
                next bl-princ.
            end.
          end.
          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.

        find mapctb where recid(mapctb) = tt-mapctb.rec no-lock.
  
        display tt-mapctb.etbcod
                mapctb.cxacod 
                mapctb.de1
                mapctb.datmov
                tt-mapctb.nrored  
                mapctb.t05
                mapctb.t01     
                mapctb.t02     
                mapctb.t03     
                mapctb.vlsub   
                mapctb.gtotal
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-mapctb).
   end.
end.
pause 0.
end.

procedure color-message.
color display message tt-mapctb.etbcod  
                      mapctb.cxacod
                      mapctb.de1  
                      mapctb.datmov
                      tt-mapctb.nrored   
                      mapctb.t05
                      mapctb.t01      
                      mapctb.t02      
                      mapctb.t03      
                      mapctb.vlsub     
                      mapctb.gtotal
                        with frame frame-a.
end procedure.
procedure color-normal.
color display normal tt-mapctb.etbcod 
                     mapctb.cxacod 
                     mapctb.de1
                     mapctb.datmov 
                     tt-mapctb.nrored  
                     mapctb.t05
                     mapctb.t01     
                     mapctb.t02     
                     mapctb.t03     
                     mapctb.vlsub     
                     mapctb.gtotal
                        with frame frame-a.
end procedure.


