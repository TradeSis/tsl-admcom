{admcab.i}
def input parameter p-data as date.

def shared temp-table tt-proprice 
    field data   as date
    field etbcod like plani.etbcod
    field procod like produ.procod
    field numero like plani.numero
    field serial like tbprice.serial
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    field valven as dec
    field ctoven as dec
    field ctocmp as dec
    field price  as dec
    index i1 etbcod data.

def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(14)" extent 5
            initial ["  DADOS VENDA","","","",""]
            .
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


form
        esqcom1
            with frame f-com1
                 row 7 no-box no-labels side-labels centered.
form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
esqregua  = yes.
esqpos1  = 1.
esqpos2  = 1.
def buffer bestab for estab.
def var vtmovqtm as dec.
def var vtvalven as dec.
def var vtctoven as dec.
def var vtctocmp as dec.
def var vtprice as dec.


assign
    vtmovqtm = 0 vtvalven = 0 vtctoven = 0 vtctocmp = 0 vtprice  = 0 .
for each tt-proprice where 
         tt-proprice.data = p-data:
    find first tbprice where
               tbprice.etb_venda = tt-proprice.etbcod and
               tbprice.data_venda = tt-proprice.data and
               tbprice.nota_venda = tt-proprice.numero
               no-lock no-error.
    if avail tbprice
    then tt-proprice.serial = tbprice.serial.
                
    assign
        vtmovqtm = vtmovqtm + tt-proprice.movqtm
        vtvalven = vtvalven + tt-proprice.valven
        vtctoven = vtctoven + tt-proprice.ctoven
        vtctocmp = vtctocmp + tt-proprice.ctocmp
        vtprice  = vtprice  + tt-proprice.price
        .
end.  
disp "  TOTAL DO DIA " p-data format "99/99/9999" space(7)
     vtmovqtm   format ">>9"
     vtvalven   format ">>,>>9.99"
     vtctoven   format ">>,>>9.99"
     vtctocmp   format ">>>,>>9.99"
     vtprice    format "->>>,>>9.99"
     with frame f-tot 1 down
        no-label no-box row 20 overlay.
bl-princ:
repeat:

    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then find first tt-proprice where
                    tt-proprice.data = p-data no-lock no-error.
    else find tt-proprice where recid(tt-proprice) = recatu1 no-lock no-error.

    if not available tt-proprice
    then do:
        message color red/with
            "Nenhum registro encontrado"
            view-as alert-box.
        leave bl-princ.    
    end.

    clear frame frame-a all no-pause.
    
    find bestab where bestab.etbcod = tt-proprice.etbcod no-lock.
    display tt-proprice.procod column-label "Produto"  format ">>>>>>>9"
            tt-proprice.serial column-label "Serial" format "x(22)"
            tt-proprice.movqtm column-label "Qtd" format ">9"
            tt-proprice.valven column-label "Val Venda" format ">>,>>9.99"
            tt-proprice.ctoven column-label "Cto Venda" format ">>,>>9.99"
            tt-proprice.ctocmp column-label "Cto Compra" 
                        format ">>>,>>9.99"
            tt-proprice.price  column-label "Price" format "->>>,>>9.99"    
            with frame frame-a  row 8 8 down centered overlay
            width 80.

    recatu1 = recid(tt-proprice).
    
    color display message esqcom1[esqpos1] with frame f-com1.

    repeat:
    
        find next tt-proprice where
                  tt-proprice.data = p-data no-lock no-error.
        
        if not available tt-proprice
        then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        down with frame frame-a.
        
        find bestab where bestab.etbcod = tt-proprice.etbcod no-lock.
        display 
            tt-proprice.procod
            tt-proprice.serial
            tt-proprice.movqtm
            tt-proprice.valven
            tt-proprice.ctoven
            tt-proprice.ctocmp
            tt-proprice.price
            with frame frame-a.

    end.
    
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-proprice where recid(tt-proprice) = recatu1 no-lock no-error.
        find produ where produ.procod = tt-proprice.procod no-lock.
        message pronom .
        choose field tt-proprice.procod go-on(cursor-down cursor-up 
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
                esqpos1 = if esqpos1 = 6
                          then 6
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
        
            find next tt-proprice where
                      tt-proprice.data = p-data no-lock no-error.
            
            if not avail tt-proprice
            then next.
            
            color display normal tt-proprice.procod.
            
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.

        end.

        if keyfunction(lastkey) = "cursor-up"
        then do:
        
            find prev tt-proprice where
                      tt-proprice.data = p-data no-lock no-error.
            if not avail tt-proprice
            then next.
            
            color display normal tt-proprice.procod.
            
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

            if esqcom1[esqpos1] = "Relatorio"
            then do:
                sresp = no.
                message "Confirma Imprimir ?" update sresp.
                if sresp 
                then do:
                    run relatorio-data.
                end.
                recatu1 = recid(tt-proprice).
                leave.
            end.
            
            if esqcom1[esqpos1] = "  DADOS VENDA"
            then do: 
                run dados-venda.
                 recatu1 = recid(tt-proprice).
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
        find bestab where bestab.etbcod = tt-proprice.etbcod no-lock.
        display 
            tt-proprice.procod
            tt-proprice.serial
            tt-proprice.movqtm
            tt-proprice.valven
            tt-proprice.ctoven
            tt-proprice.ctocmp
            tt-proprice.price
            with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-proprice).
   end.
end.
procedure dados-venda:

    display tt-proprice.procod column-label "Produto"  format ">>>>>>>9"
            tt-proprice.serial column-label "Serial" format "x(22)"
            tt-proprice.movqtm column-label "Qtd" format ">9"
            tt-proprice.valven column-label "Val Venda" format ">>,>>9.99"
            tt-proprice.ctoven column-label "Cto Venda" format ">>,>>9.99"
            tt-proprice.ctocmp column-label "Cto Compra" 
                        format ">>>,>>9.99"
            tt-proprice.price  column-label "Price" format "->>>,>>9.99"    
            with frame frame-n  row 8 1 down centered overlay
            width 80.

 
    def var vplano as char init "".
    def var vpromo as char init "".
    find first plani where  plani.movtdc = 5 and
                            plani.etbcod = tt-proprice.etbcod and
                            plani.emite  = tt-proprice.etbcod and
                            plani.serie = "V" and
                            plani.numero = tt-proprice.numero
                            no-lock no-error.
    if avail plani
    then do:
        vplano = acha("CODVIV" + string(tt-proprice.procod),plani.notobs[3]).
        vpromo = acha("TIPVIV"  + string(tt-proprice.procod),plani.notobs[3]).
             
        find estab where estab.etbcod = plani.emite no-lock no-error.
        find func where func.funcod = plani.vencod no-lock no-error.
        find clien where clien.clicod = plani.desti no-lock no-error.

        disp plani.numero at 1 format ">>>>>>>>9"
             plani.pladat at 1
             plani.emite  at 1
             estab.etbnom no-label when avail estab
             plani.desti  at 1 format ">>>>>>>>9"
             clien.clinom no-label when avail clien
             plani.vencod at 1
             func.funnom no-label when avail func
             vplano at 1 label "Plano"
             vpromo label "Promocao"
             with frame f-plani 1 down centered
                            overlay side-label.
        pause.
    end.
    else do:
        message color red/with
            "Venda nao localizada."
            view-as alert-box.
    end.   
    hide frame frame-n no-pause.
    hide frame f-plani no-pause.     
end procedure.

/***
procedure relatorio-data :
    
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/price"  + string(time).
    else varquivo = "l:\relat\price" + string(time).
                                    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""promtitl"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """PRICE CELULAR VIVO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}
    disp with frame f1.
    for each tt-price:
        find bestab where bestab.etbcod = tt-price.etbcod no-lock.
        disp tt-price.data column-label "Data"   format "99/99/9999"
             tt-price.movqtm (total) column-label "Qtd" format ">>>9"
             tt-price.valven (total) column-label "Valor Venda"
                                format ">>,>>>,>>9.99"
             tt-price.ctoven (total)
                        column-label "Custo Venda" format ">>,>>>,>>9.99"
             tt-price.ctocmp (total)
                        column-label "Custo Compra" format ">>,>>>,>>9.99"
             tt-price.price  (total)
                    column-label "Price" format "->>,>>>,>>9.99"
            with frame f-disp down width 100.
        down with frame f-disp.    
    end.
    
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.     

end procedure.

***/
