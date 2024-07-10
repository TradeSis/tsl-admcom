{admcab.i}

def var vdiver as log.
def var vtotnfqtd  as   int format ">>>>>>>>9".
def var vtotnfval  like plani.platot.
def var vtotbon    like plani.platot.
def var vtotdef    like plani.platot.
def var vtotbondef like plani.platot.
def var vtotdif    like plani.platot.

def var vpercdiver as dec format ">>9.99 %".


def var varquivo as char.
def temp-table tt-plani like plani.
def var vetbnom like estab.etbnom.
def buffer bprodu for produ.
def temp-table tt-brinde
    field procod like produ.procod.

def var vdata as date format "99/99/9999".
def var varq as char.
def temp-table tt-livre
    field procod like produ.procod
    field fincod like finan.fincod
    field preco  like estoq.estvenda.

def var vtot like plani.platot.
def temp-table tt-divpre
    field rec as recid
    field catcod like produ.catcod
    field pronom like produ.pronom
    index ind-1 catcod
                pronom.
                
                
def var vcatcod like produ.catcod.    
def var vdif like divpre.preven.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(13)" extent 4
            initial ["Observacao","Consulta","Listagem","Descontos"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bdivpre       for divpre.
def var vetbcod         like divpre.etbcod.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

    vdti = today - 2.
    vdtf = today - 1.

         
repeat:    
    clear frame f-com1 no-pause.
    recatu1 = ?.
    
    
    for each tt-livre:
    
        delete tt-livre.
        
    end.
    

    for each tt-brinde:
    
        delete tt-brinde.
        
    end.
    vetbnom = "".
        
    do on error undo:
    
        update vetbcod label "Filial......." 
               with frame fdata.
               
        if vetbcod <> 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Filial nao Cadastrada".
                undo.
            end.
            else disp estab.etbnom no-label with frame fdata.
        end.
        else disp "TODAS" @ estab.etbnom with frame fdata.
        
    end.           

    update skip
           vdti    label "Data Inicial."
           vdtf    label "Data Final" skip
           vcatcod label "Categoria...."
                with frame fdata side-label width 80 row 3.
    
    if vcatcod = 0
    then display "Geral" @ categoria.catnom no-label with frame fdata.
    else do:
        find categoria where categoria.catcod = vcatcod no-lock.
        display categoria.catnom no-label with frame fdata.
    end.

    update skip vpercdiver label "% Divergencia"
           with frame fdata.
    
    
    for each estab where estab.etbcod = (if vetbcod <> 0
                                         then vetbcod
                                         else estab.etbcod) no-lock:
        do vdata = vdti to vdtf:
            for each divpre where divpre.etbcod = estab.etbcod and
                                  divpre.divdat = vdata:

                if divpre.fincod = 73 and
                 ( divpre.preven - divpre.premat ) >= 0
                then do transaction:
                    delete divpre.
                end.
                
            end.
        end.
    end.

    if opsys = "UNIX"
    then input from ../progr/autoriza.txt.
    else input from ..\progr\autoriza.txt.

    repeat:
    
        import varq.

        find first tt-livre where tt-livre.procod = int(substring(varq,1,6))
                              and tt-livre.fincod = int(substring(varq,7,2))
                                  no-error. 
        if not avail tt-livre 
        then do:
        
            create tt-livre.
            assign tt-livre.procod = int(substring(varq,1,6))
                   tt-livre.fincod = int(substring(varq,7,2))
                   tt-livre.preco  = dec(substring(varq,9,9)).
               
        end.
    
    end.
    input close.

    for each tt-livre.
        find produ where produ.procod = tt-livre.procod no-lock no-error.
        if not avail produ
        then delete tt-livre.
    end.
    
    
    if opsys = "UNIX"
    then input from ../progr/brinde.txt.
    else input from ..\progr\brinde.txt.

    repeat:
        create tt-brinde.
        import tt-brinde.
    end.
    input close.

    for each tt-brinde.

        find produ where produ.procod = tt-brinde.procod no-lock no-error.
        if not avail produ
        then do:
            delete tt-brinde.
            next.
        end.
    
    end.    
    
    for each tt-divpre:
        delete tt-divpre.
    end.
    
    vtot = 0.
    
    def var vprecoliberado as log.
    def var vpromo as log.
    for each estab where estab.etbcod = (if vetbcod <> 0
                                         then vetbcod
                                         else estab.etbcod) no-lock:

        do vdata = vdti to vdtf:
            for each divpre where divpre.etbcod = estab.etbcod and
                                  divpre.divdat = vdata no-lock:
                              
                find first plani where plani.etbcod = divpre.etbcod 
                                   and plani.placod = divpre.placod 
                                   and plani.pladat >= vdti         
                                   and plani.pladat <= vdtf no-lock no-error.
                if avail plani 
                then do:

                    find first movim where movim.etbcod = plani.etbcod 
                                       and movim.placod = plani.placod 
                                       and movim.movtdc = plani.movtdc 
                                       and movim.procod = divpre.procod 
                                       no-lock no-error.
                    if avail movim 
                    then do: /*
                        if movim.ocnum[5] <> 0 and movim.ocnum[6] <> 0
                        then next.*/
                    end.

                end.
                
                find produ where produ.procod = divpre.procod no-lock no-error.
                if not avail produ
                then next.

                if produ.clacod = 100 or
                   produ.clacod = 101 or
                   produ.clacod = 102 or
                   produ.clacod = 107 or
                   produ.clacod = 190 or
                   produ.clacod = 191 or
                   produ.clacod = 201 or
                   produ.clacod = 202 or
                   produ.procod = 405248 or
                   produ.procod = 1383 or
                   produ.procod = 493563
                then next.          
                                    

                if vcatcod <> 0
                then if produ.catcod <> vcatcod
                     then next.

                vdiver = yes.
                run p-altpreco3per ( output vdiver ).
                
                if not vdiver
                then next.
                
                find first tt-brinde where 
                           tt-brinde.procod = divpre.procod no-error.
                if avail tt-brinde
                then do:
                    if divpre.preven <= 1
                    then next.
                end.
                
                find first tt-livre where tt-livre.procod = divpre.procod
                                      and tt-livre.fincod = divpre.fincod
                                      no-error.
                if avail tt-livre
                then do:
                    if divpre.preven = divpre.premat
                    then next.
            
                    if tt-livre.preco > 0
                    then do:
                        if tt-livre.preco >= divpre.preven
                        then next.
                    end.
                
                end.
                
                if avail plani 
                then do:
                    vprecoliberado = no.
                    vpromo = no.
                    run leplapromo.p(input recid(plani), 
                                     input divpre.procod,
                                     output vprecoliberado,
                                     output vpromo).
                    if vprecoliberado /*or vpromo*/            
                    then next.                 
                end.

                find first tt-divpre where
                           tt-divpre.rec = recid(divpre) no-error.
                if not avail tt-divpre
                then do:
                    create tt-divpre.
                    assign tt-divpre.rec = recid(divpre).
                end.

                assign tt-divpre.catcod = produ.catcod
                       tt-divpre.pronom = produ.pronom.
               
                if (divpre.preven - divpre.premat) < 0
                then vtot = vtot + ( (divpre.preven - divpre.premat) * -1).
                else assign tt-divpre.pronom = "Zzz" + produ.pronom
                            tt-divpre.catcod = produ.catcod + 100. 
    
            end.    
        end.
    end.
            
bl-princ:
repeat:


    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find first tt-divpre where true no-error.
    else find tt-divpre where recid(tt-divpre) = recatu1.
    if not available tt-divpre
    then do:
        message "Nao existe divergencia para este dia".
        pause.
        undo, retry.
    end.
    
    clear frame frame-a all no-pause.
    
    find divpre where recid(divpre) = tt-divpre.rec no-error.
    find produ where produ.procod = divpre.procod no-lock.
    
    find first plani where /*plani.etbcod = estab.etbcod  and*/
                           plani.etbcod = divpre.etbcod and
                           plani.placod = divpre.placod and
                           plani.pladat >= vdti         and
                           plani.pladat <= vdtf no-lock no-error.
    if avail plani
    then find first movim where movim.etbcod = plani.etbcod and
                                movim.placod = plani.placod and
                                movim.movtdc = plani.movtdc and
                                movim.procod = produ.procod no-lock no-error.
                                
    
    vdif =  (divpre.preven - divpre.premat). 

    
    display vtot label "Dif.Preco    " format "->,>>>,>>9.9"
                        with frame ftot  no-box row 19 centered 
                        color message  side-label width 65.      
     
    display divpre.divjus label "Justificativa" 
                        with frame f-jus no-box row 20 centered
                                    color message side-label.
    display divpre.divobs label "Observacao   " 
                        with frame f-obs no-box row 21 centered
                                    color message side-label.
    vetbnom = if avail estab
              then estab.etbnom
              else "Todos".
    display
        plani.numero  when avail plani format ">>>>>>9"
        /*plani.serie   column-label "Sr"  format "x(02)" when avail plani*/
        plani.etbcod column-label "Fl" format ">9" when avail plani
        divpre.procod column-label "Codigo"
        produ.pronom  format "x(24)"
        movim.movqtm  when avail movim column-label "Qtd" format ">>>9"
        divpre.premat column-label "Preco!Certo"   format ">,>>9.99" 
/*        divpre.prefil column-label "Preco!Filial"  format ">,>>9.9" */
        divpre.preven column-label "Preco!Vendido" format ">,>>9.99"
        vdif column-label "Difer.!Preco"  format "->,>>9.99"
        divpre.fincod column-label "Pl" format "99"
            with frame frame-a 10 down centered 
                title trim(vetbnom + " -  Dia: " + 
                           string(vdti,"99/99/9999") + " - " + 
                           string(vdtf,"99/99/9999")).
    
    recatu1 = recid(tt-divpre).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.

    repeat:
        find next tt-divpre where true no-error.
        if not available tt-divpre
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        find divpre where recid(divpre) = tt-divpre.rec no-error.
        find produ where produ.procod = divpre.procod no-lock no-error.

        find first plani where /*plani.etbcod = estab.etbcod  and*/
                               plani.etbcod = divpre.etbcod and
                               plani.placod = divpre.placod and
                               plani.pladat >= vdti         and
                               plani.pladat <= vdtf no-lock no-error.
        if avail plani
        then find first movim where movim.etbcod = plani.etbcod and
                                    movim.placod = plani.placod and
                                    movim.movtdc = plani.movtdc and
                                    movim.procod = produ.procod 
                                            no-lock no-error.
        
        
        vdif =  (divpre.preven - divpre.premat). 
        
        display divpre.divjus label "Justificativa" with frame f-jus.
        display divpre.divobs with frame f-obs.

        
        display
            plani.numero when avail plani 
/*            plani.serie  when avail plani*/
              plani.etbcod column-label "Fl" format ">9" when avail plani
            divpre.procod
            produ.pronom 
            movim.movqtm when avail movim
            divpre.premat
/*            divpre.prefil */
            divpre.preven
            vdif
            divpre.fincod
            with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-divpre where recid(tt-divpre) = recatu1.

        find divpre where recid(divpre) = tt-divpre.rec no-error.

        find first plani where /*plani.etbcod = estab.etbcod  and*/
                               plani.etbcod = divpre.etbcod and
                               plani.placod = divpre.placod and
                               plani.pladat >= vdti         and
                               plani.pladat <= vdtf no-lock no-error.

        display divpre.divjus with frame f-jus.
        display divpre.divobs with frame f-obs.

        choose field plani.numero
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  tab PF4 F4 ESC return).
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
                esqpos1 = if esqpos1 = 4
                          then 4
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
            
            find next tt-divpre where true no-error.
            if not avail tt-divpre
            then next.
            find divpre where recid(divpre) = tt-divpre.rec no-error.
 
            find first plani where /*plani.etbcod = estab.etbcod  and*/
                                   plani.etbcod = divpre.etbcod and
                                   plani.placod = divpre.placod and
                                   plani.pladat >= vdti         and
                                   plani.pladat <= vdtf
                                                no-lock no-error.
 
            color display normal plani.numero.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
            
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-divpre where true no-error.
            if not avail tt-divpre
            then next.
            find divpre where recid(divpre) = tt-divpre.rec no-error.
 
            find first plani where /*plani.etbcod = estab.etbcod  and*/
                                   plani.etbcod = divpre.etbcod and
                                   plani.placod = divpre.placod and
                                   plani.pladat >= vdti         and
                                   plani.pladat <= vdtf 
                                                no-lock no-error.
            color display normal plani.numero.
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

            if esqcom1[esqpos1] = "Observacao"
            then do with frame f-inclui overlay row 6 1 column centered.
                find divpre where recid(divpre) = tt-divpre.rec no-error.
                update divpre.divobs.
                recatu1 = recid(tt-divpre).
                leave.
            end.
            if esqcom1[esqpos1] = "Descontos"
            then do:
                if opsys = "UNIX"
                then varquivo = "../relat/r-desc." + string(time).
                else varquivo = "..\relat\r-desc." + string(time).
    
                {mdad.i &Saida     = "value(varquivo)"
                        &Page-Size = "64" 
                        &Cond-Var  = "120" 
                        &Page-Line = "66" 
                        &Nom-Rel   = ""divpre1""
                        &Nom-Sis   = """SISTEMA ESTOQUE FILIAL     versao 3.0"""
                        &Tit-Rel   = """LISTAGEM DE DESCONTOS DE "" +
                                 string(vdti,""99/99/9999"") + "" A "" +
                                 string(vdtf,""99/99/9999"")"
                        &Width     = "120"
                        &Form      = "frame f-cabcab2"}

                assign vtotnfqtd  = 0 
                       vtotnfval  = 0 
                       vtotbon    = 0 
                       vtotdef    = 0 
                       vtotbondef = 0 
                       vtotdif    = 0.
    
                for each estab where estab.etbcod = (if vetbcod <> 0
                                                     then vetbcod
                                                     else estab.etbcod)
                                                     no-lock:

                    do vdata = vdti to vdtf:
                        for each plani where plani.movtdc = 5
                                         and plani.etbcod = estab.etbcod
                                         and plani.pladat = vdata no-lock
                                         break by plani.pladat
                                               by plani.numero:
                            if plani.descprod = 0 and
                               plani.vlserv   = 0
                            then next.   
               
                            disp skip(1)
                                 plani.etbcod   column-label "LJ"  
                                 plani.numero   column-label "Numero"
                                 format ">>>>>>>9"
                                 plani.pladat   column-label "Emissao"
                                 plani.platot   column-label "Total NF"
                                 plani.descprod column-label "Desconto!Bonus"
                                 plani.vlserv
                                 column-label "Desconto!Defeito" skip.

                            assign vtotnfqtd  = vtotnfqtd + 1 
                                   vtotnfval  = vtotnfval + plani.platot
                                   vtotbon    = vtotbon   + plani.descprod
                                   vtotdef    = vtotdef   + plani.vlserv.

                            
                            for each movim where movim.etbcod = plani.etbcod
                                             and movim.placod = plani.placod
                                             and movim.movtdc = plani.movtdc
                                             and movim.movdat = plani.pladat
                                             no-lock:
                                find bprodu where bprodu.procod =
                                                  movim.procod no-lock
                                                  no-error.
                                                  
                                disp movim.procod at 5 column-label "Codigo"
                                     bprodu.pronom      column-label "Produto"
                                     when avail bprodu
                                     bprodu.catcod      column-label "Dep"
                                     when avail bprodu
                                     movim.movqtm 
                                     movim.movpc
                                     with width 120.
                            end.
                            
                            
                        end.
                    end.
                end.
                
                vtotbondef = (vtotbon + vtotdef).
                vtotdif    = (vtotnfval - vtotbondef).
                
                put skip(2).
                
                disp "TOTAL DE NF            ->    " vtotnfqtd 
                     skip 
                     "TOTAL VALOR NF         -> " vtotnfval 
                     skip(1) 
                     "TOTAL DESCONTO BONUS   -> " vtotbon 
                     skip 
                     "TOTAL DESCONTO DEFEITO -> " vtotdef 
                     skip(1) 
                     "TOTAL BONUS + DEFEITO  -> " vtotbondef 
                     skip(1)            
                     "DIFERENCA TOTAL        -> " vtotdif 
                     with frame f-totais centered side-labels no-labels 
                                         title " * TOTAIS * ".                
                
                
                
                output close.

                if opsys = "UNIX"
                then run visurel.p (input varquivo, input "").
                else {mrod.i}.
                
                leave.               
            end.            
            if esqcom1[esqpos1] = "Listagem"
            then do:
                run descast2.p(input /*estab.etbcod*/ divpre.etbcod /*vetbcod*/,
                             input vdti,
                             input vdtf,
                             input vpercdiver,
                             input vcatcod).
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.

                /*
                vdif =  (divpre.preven - divpre.premat). 
                display divpre.divjus label "Justificativa" with frame f-jus.
                display plani.pladat
                        plani.numero format ">>>>>>9"
                        plani.serie 
                        plani.vencod 
                        divpre.procod 
                        produ.pronom  
                        divpre.premat
                        divpre.prefil 
                        divpre.preven  
                        vdif label "Diferenca"
                        divpre.fincod with frame f-consulta.
                */

                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame f-consulta no-pause.
                    hide frame f-jus no-pause.
                    hide frame f-obs no-pause.
                    hide frame ftot no-pause.
                    run nfvenco_p.
                    view frame f-com1.
                    view frame f-com2.
                    
                    
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" divpre.procod update sresp.
                if not sresp
                then undo.
                find next tt-divpre where true no-error.
                if not available tt-divpre
                then do:
                    find tt-divpre where recid(tt-divpre) = recatu1.
                    find prev tt-divpre where true no-error.
                end.
                recatu2 = if available tt-divpre
                          then recid(tt-divpre)
                          else ?.
                find tt-divpre where recid(tt-divpre) = recatu1.
                find divpre where recid(divpre) = tt-divpre.rec no-error.
                if avail divpre
                then delete divpre.
                recatu1 = recatu2.
                leave.
            end.
          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        find divpre where recid(divpre) = tt-divpre.rec no-error.
        find produ where produ.procod = divpre.procod no-lock no-error.  
        find first plani where /*plani.etbcod = estab.etbcod  and*/
                               plani.etbcod = divpre.etbcod and
                               plani.placod = divpre.placod and
                               plani.pladat >= vdti         and
                               plani.pladat <= vdtf no-lock no-error.
                               
        if avail plani
        then find first movim where movim.etbcod = plani.etbcod and
                                    movim.placod = plani.placod and
                                    movim.movtdc = plani.movtdc and
                                    movim.procod = produ.procod
                                        no-lock no-error.
     
        
        
        vdif =  (divpre.preven - divpre.premat). 

        display divpre.divjus label "Justificativa" with frame f-jus.
        display divpre.divobs with frame f-obs.

    
        display plani.numero when avail plani
                plani.etbcod column-label "Fl" format ">9" when avail plani
/*              plani.serie  when avail plani*/
                divpre.procod
                produ.pronom 
                movim.movqtm when avail movim 
                divpre.premat
/*              divpre.prefil */
                divpre.preven 
                vdif
                divpre.fincod
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-divpre).
   end.
end.
end.

procedure nfvenco_p:

    disp plani.etbcod
         with frame f1 centered side-labels color white/red overlay.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    disp plani.numero
         plani.serie no-label
         with frame f1.

    find func where func.etbcod = plani.etbcod and
                        func.funcod = plani.vencod no-lock no-error.

    disp plani.pladat
         plani.vencod
         plani.cxacod
         func.funnom when avail func
         string(plani.horincl,"hh:mm") label "Hora" with frame f1.
    
    find clien where clien.clicod = plani.desti no-lock no-error.
    if avail clien
    then do: 
        disp clien.clicod 
             clien.clinom no-label 
             with frame f3 centered color black/cyan side-labels
                    overlay.
    end.

    find finan where finan.fincod = plani.pedcod no-lock.

    disp finan.fincod label "Plano"
         finan.finnom
         finan.finfat no-label 
         plani.vlserv label "Devolucao" 
         plani.biss   label "Total Contrato" with frame f1.

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movdat = plani.pladat and
                         movim.movtdc = plani.movtdc no-lock:
        find produ where produ.procod = movim.procod no-lock no-error.
        disp movim.procod
             produ.pronom format "x(25)" when avail produ
             movim.movqtm (total)
             movim.movpc
                (movim.movqtm * movim.movpc) (total)
                 with frame f2 centered color white/cyan down overlay.
    end.

end procedure.

procedure p-altpreco3per:

    def output parameter p-diver as log.
    def var percentual-altp as dec.
    
    percentual-altp = 0.
    percentual-altp = 
            (((divpre.preven - divpre.premat) / divpre.premat ) * 100).

    if percentual-altp < 0
    then percentual-altp = percentual-altp * -1.

    if percentual-altp <= vpercdiver
    then p-diver = no.
    else p-diver = yes.

/*    if produ.pronom begins "*"
    then p-diver = no.   Baseado no programa divpre1.p */

end procedure.