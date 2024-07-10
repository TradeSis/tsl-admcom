/* helio 26092022 - melhorias - ordenacao por vencimento */

{/admcom/progr/admcab.i.ssh}
/* helio 092022*/
def var vtitdtven as date.
def var vvlraberto as dec.
def var vbusca  as char format "x(10)" label "Contrato".
def var primeiro as log.

def var vsit as char format "x(06)".
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(18)" extent 4
    initial [" Parcelas ",""," Contrato",""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bcontrato     for contrato.
def var vcontnum         like contrato.contnum.

def temp-table ttcon   no-undo
    field ttrec as recid
    field dtinicial like contrato.dtinicial
    field titdtven  like titulo.titdtven
    field vlraberto as dec
    field vsit      as char format "x(3)"
    field pago      as log
    index ind1 pago asc titdtven asc dtinicial desc.



    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
repeat:
    clear frame frame-a all.
    for each ttcon.
        delete ttcon.
    end.
    
    prompt-for clien.clicod label "Cliente"
               with frame fclien centered
                color white/cyan row 3 side-label
                width 80 .
    find clien using clicod no-lock no-error .
    if not avail clien
    then do:
        message "Cliente Nao cadastrado".
        undo.
    end.
    display clien.clinom no-label
            with frame fclien.

    assign
        esqregua = yes
        esqpos1  = 1
        esqpos2  = 1
        recatu1  = ?.
    pause 0.
    
    for each contrato where contrato.clicod = clien.clicod no-lock.
        vtitdtven = ?.
        vsit = "PAG".
        vvlraberto = 0.
        for each titulo where titulo.empcod = 19 and titulo.titnat = no and
                titulo.clifor = contrato.clicod and titulo.modcod = contrato.modcod and
                titulo.etbcod = contrato.etbcod and titulo.titnum = string(contrato.contnum)
                no-lock by titulo.titpar.
            if titulo.titsit = "LIB"
            then do:
                vSIT = "ABE".
                vvlraberto = vvlraberto + titulo.titvlcob.
                vtitdtven = titulo.titdtven.
                if  titulo.titdtven < today
                then vsit = "ATR".
                leave.
            end.
        end.                 
        create ttcon. 
        assign ttcon.ttrec     = recid(contrato) 
        ttcon.dtinicial = contrato.dtinicial. 
        ttcon.titdtven  = vtitdtven.
        ttcon.vlraberto = vvlraberto.
        ttcon.vsit      = vsit.
        ttcon.pago      =  vsit = "PAG".
        
   
   end.
   hide frame fclien no-pause.

bl-princ:
repeat:
    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    
    if recatu1 = ?
    then find first ttcon no-error.
    else find ttcon where recid(ttcon) = recatu1 no-error.
    vinicio = yes.
    if not available ttcon
    then do:
        message "Nenhum Contrato Para o Cliente".
        leave bl-princ.
    end. 
    clear frame frame-a all no-pause.

    find contrato    where recid(contrato) = ttcon.ttrec no-lock.
    display
        contrato.contnum     FORMAT ">>>>>>>>>>>9"        LABEL "Contrato"
        contrato.etbcod       format ">>>9" column-label "Fil"
        contrato.dtinicial   FORMAT "99/99/9999"     column-LABEL "Data Emis"
        ttcon.titdtven       FORMAT "99/99/9999"     column-LABEL "Dt Vencim"
        contrato.vltotal     FORMAT ">>,>>9.99" LABEL "Valor total"
        contrato.vlentra     FORMAT ">>,>>9.99" LABEL "Vl Entrada"
        ttcon.vlraberto      FORMAT ">>,>>9.99" LABEL "Vl Aberto"
        ttcon.vsit           no-label    
        with frame frame-a 13 down centered 
            title " Cod. " + string(clien.clicod) + " " + clien.clinom + " ".

    recatu1 = recid(ttcon).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next ttcon no-error.
        if not available ttcon
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
        find contrato    where recid(contrato) = ttcon.ttrec no-lock.
    
        display
            contrato.contnum   
            contrato.etbcod   
            contrato.dtinicial  
            ttcon.titdtven  
            contrato.vltotal   
            contrato.vlentra  
            ttcon.vlraberto    
            ttcon.vsit    
        
                 with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttcon where recid(ttcon) = recatu1.
        find contrato where recid(contrato) = ttcon.ttrec no-lock.
        esqcom1[2] = " ".
        
                 find first contnf where 
                        contnf.etbcod = contrato.etbcod and
                        contnf.contnum = contrato.contnum
                        no-lock no-error.
                if avail contnf
                then do:
                    find first plani where  
                            plani.etbcod = contnf.etbcod and
                            plani.placod = contnf.placod
                            no-lock no-error.
                    
                    if avail plani 
                    then esqcom1[2] = " Produtos".
                end. 
                
                                   
        disp esqcom1 with frame f-com1.
        
        color display messages
            contrato.contnum   
            contrato.etbcod   
            contrato.dtinicial  
            ttcon.titdtven  
            contrato.vltotal   
            contrato.vlentra  
            ttcon.vlraberto    
            ttcon.vsit    
        
                 with frame frame-a.

        choose field contrato.contnum
                          help "Digite o codigo do contrato para pesquisa"
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up 1 2 3 4 5 6 7 8 9 0 
                  PF4 F4 ESC return).
                  
            if keyfunction(lastkey) = "0" or keyfunction(lastkey) = "1" or
               keyfunction(lastkey) = "2" or keyfunction(lastkey) = "3" or
               keyfunction(lastkey) = "4" or keyfunction(lastkey) = "5" or
               keyfunction(lastkey) = "6" or keyfunction(lastkey) = "7" or
               keyfunction(lastkey) = "8" or keyfunction(lastkey) = "9" 
            then do with centered row 8 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                primeiro = yes.
                update vbusca
                    editing:
                        if primeiro
                        then do:
                            apply keycode("cursor-right").
                            primeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end. 
                recatu2 = recatu1. 
                    find contrato where contrato.contnum = int(vbusca)
                      no-lock no-error.
                    if avail contrato
                    then do.
                        find first ttcon where ttcon.ttrec = recid(contrato) no-error.
                        if avail ttcon
                        then recatu1 = recid(ttcon).
                    end.
                    if recatu2 = recatu1
                    then do:
                        hide message no-pause.
                        message "Contrato" vbusca "nao existe ou nao eh deste cliente.".
                        pause 2 no-message.
                    end.
                leave. 
            end.                           
        color display normal
            contrato.contnum   
            contrato.etbcod   
            contrato.dtinicial  
            ttcon.titdtven  
            contrato.vltotal   
            contrato.vlentra  
            ttcon.vlraberto    
            ttcon.vsit    
        
                 with frame frame-a.
                  
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

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next ttcon no-error.
                if not avail ttcon
                then leave.
                recatu1 = recid(ttcon).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev ttcon no-error.
                if not avail ttcon
                then leave.
                recatu1 = recid(ttcon).
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
            find next ttcon no-error.
            find contrato where recid(contrato) = ttcon.ttrec no-lock.

            if not avail ttcon
            then next.
            color display normal
                contrato.contnum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev ttcon no-error.
            find contrato where recid(contrato) = ttcon.ttrec no-lock no-error.

            if not avail contrato
            then next.
            color display normal
                contrato.contnum.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo,leave.
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "    Nota Fiscal"
            then do:

                for each contnf where contnf.etbcod  = contrato.etbcod and
                                      contnf.contnum = contrato.contnum 
                                                    no-lock:
                    for each plani where plani.etbcod = contrato.etbcod and
                                         plani.placod = contnf.placod no-lock.
                        display plani.numero label "Numero" format ">>>>>>9"
                                             colon 20
                                plani.serie  label "Serie"
                                plani.pladat label "Data"
                                plani.platot label "Valor da Nota"   colon 20
                                plani.vlserv label "Valor Devolucao" colon 20
                                plani.biss   label "Valor C/ Acrescimo"
                                                        colon 20
                                    with frame fnota side-label centered
                                            color message.
                        find finan where finan.fincod = plani.pedcod no-lock
                                                        no-error.
                        display plani.pedcod label "Plano" colon 20
                                finan.finnom no-label when avail finan
                                        with frame fnota.
                        find func where func.etbcod = plani.etbcod and
                                        func.funcod = plani.vencod 
                                                no-lock no-error.
                        display plani.vencod label "Vendedor"colon 20
                                func.funnom no-label when avail func 
                                        with frame fnota side-label.
                        for each movim where movim.etbcod = plani.etbcod and
                                             movim.placod = plani.placod and
                                             movim.movtdc = plani.movtdc and
                                             movim.movdat = plani.pladat
                                                        no-lock:
                            find produ where produ.procod = movim.procod 
                                                        no-lock no-error.
                            display movim.procod
                                    produ.pronom when avail produ 
                                            format "x(21)"
                                    movim.movqtm column-label "Qtd" 
                                            format ">>>>9"
                                    movim.movpc format ">>,>>9.99" 
                                            column-label "Preco" 
                                    (movim.movqtm * movim.movpc)
                                            column-label "Total"
                                        with frame fmov down centered
                                                        color blue/message.
                        
                        end.                                
                    end.                     
                end.                                
            end.     
            
            if esqcom1[esqpos1] = " Parcelas "
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run hiscli02.p (input recid(contrato)).
                view frame f-com1.
                view frame f-com2.
            end.

            /* helio 26092022 */
            if esqcom1[esqpos1] = " Contrato "
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                hide frame frame-a no-pause.
                run conco_v1701.p (input string(contrato.contnum)).
                view frame f-com1.
                view frame f-com2.
            end.
            /* helio 26092022 */
            if esqcom1[esqpos1] = " produtos "
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                hide frame frame-a no-pause.
                find first contnf where 
                        contnf.etbcod = contrato.etbcod and
                        contnf.contnum = contrato.contnum
                        no-lock no-error.
                if avail contnf
                then do:
                    find first plani where  
                            plani.etbcod = contnf.etbcod and
                            plani.placod = contnf.placod
                            no-lock no-error.
                    
                    if avail plani 
                    then run not_consnotarap.p (input recid(plani)).
                end.                    
                view frame f-com1.
                view frame f-com2.
            end.
            
            

            if esqcom1[esqpos1] = " Extrato "
            then do:
                message "Confirma a emissao do extrato do cliente"
                        clien.clinom "?" update sresp.
                if not sresp
                then leave.
                if opsys = "UNIX" then
                 run extrato1.p (input recid(clien)).
                else 
                run extrato.p (input recid(clien)).
                leave.
             end.
             
             if esqcom1[esqpos1] = "Consulta/Extrato"
             then run extrato3.p (input recid(clien)).

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame frame-a.
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        
        find contrato where recid(contrato) = ttcon.ttrec no-lock.
        disp
            contrato.contnum   
            contrato.etbcod   
            contrato.dtinicial  
            ttcon.titdtven  
            contrato.vltotal   
            contrato.vlentra  
            ttcon.vlraberto    
            ttcon.vsit    

             with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(ttcon).
   end.
end.
hide frame f-com1 no-pause.
 hide frame f-com2 no-pause.
 hide frame frame-a no-pause.
 
end.