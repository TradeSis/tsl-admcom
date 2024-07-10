{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vtmovqtm as dec.
def var vtvalven as dec.
def var vtctoven as dec.
def var vtctocmp as dec.
def var vtprice as dec.

def temp-table tt-price 
    field etbcod like estab.etbcod
    field data   as date
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    field valven as dec
    field ctoven as dec
    field ctocmp as dec
    field price  as dec
    index i1 etbcod data.

def new shared temp-table tt-proprice 
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


def temp-table tt-estab
    field etbcod like estab.etbcod
    index i1 etbcod
    .
    
def buffer bestab for estab.

update vetbcod label "Filial" with frame f1 
        width 80 side-label.
if vetbcod > 0
then do:        
    find bestab where bestab.etbcod = vetbcod no-lock.
    disp bestab.etbnom no-label with frame f1.
    create tt-estab.
    tt-estab.etbcod = bestab.etbcod.        
end.
else do:
    for each bestab no-lock:
        create tt-estab.
        tt-estab.etbcod = bestab.etbcod
         .
    end.     
end.
update vdti at 1 label "Periodo de" format "99/99/9999"
       vdtf label "Ate"             format "99/99/9999"
       with frame f1.
def buffer bmovim for movim.
def var vprice as dec.

def temp-table tt-classe like clase.
def var vesp as char extent 3 format "x(15)"
        init["VIVO","CLARO","TIM"].
disp vesp with frame f-esp 1 down no-label 1 column.
choose field vesp with frame f-esp.
if frame-index = 1
then do:
    create tt-classe.
    tt-classe.clacod = 101.
    create tt-classe.
    tt-classe.clacod = 102.
    create tt-classe.
    tt-classe.clacod = 107.
    create tt-classe.
    tt-classe.clacod = 109.
end.
if frame-index = 2 
then do:
    create tt-classe.
    tt-classe.clacod = 201.
end.
if frame-index = 3
then do:
    create tt-classe.
    tt-classe.clacod = 191.
end.    
disp  vesp[frame-index] at 60 no-label with frame f1.

hide frame f-esp no-pause.

for each tt-estab where tt-estab.etbcod = 0 :
    delete tt-estab.
end.    
for each tt-price:
    delete tt-price.
end.
for each tt-proprice:
    delete tt-proprice.
end.    
for each tt-classe:
for each produ where produ.clacod = tt-classe.clacod no-lock.
    disp "Processando... Aguarde! ..-->"
         produ.procod
         with frame f-tela 1 down centered row 10 no-label.
    pause 0.     
    for each movim where movim.procod = produ.procod and
                         movim.movtdc = 5 and
                         movim.movdat >= vdti and
                         movim.movdat <= vdtf
                         no-lock:
        find first tt-estab where tt-estab.etbcod = movim.etbcod no-error.
        if not avail tt-estab
        then next.
        find first plani where 
                   plani.etbcod = movim.etbcod and
                   plani.placod = movim.placod and
                   plani.movtdc = movim.movtdc and
                   plani.pladat = movim.movdat
                   no-lock no-error.
        if not avail plani
        then next.           
        disp movim.etbcod movim.movdat with frame f-tela.
        pause 0.
        find last bmovim where bmovim.procod = movim.procod and
                               bmovim.movtdc = 4   and
                               bmovim.movdat < movim.movdat
                               no-lock no-error
                               .
        if vetbcod = 0
        then do:
            find first tt-price where 
                       tt-price.etbcod = movim.etbcod no-error.
            if not avail tt-price
            then do:
                create tt-price.
                tt-price.etbcod = movim.etbcod .
            end.            
        end.
        else do:                               
            find first tt-price where
                       tt-price.etbcod = movim.etbcod and
                       tt-price.data   = movim.movdat
                       no-error.
             if not avail tt-price
             then do:
                 create tt-price.
                 assign
                     tt-price.etbcod = movim.etbcod 
                     tt-price.data   = movim.movdat
                      .
             end.           
        end. 
        assign
            tt-price.movqtm   = tt-price.movqtm + movim.movqtm
            tt-price.valven   = tt-price.valven + (movim.movpc * movim.movqtm)
            tt-price.ctoven = tt-price.ctoven + 
                            ((movim.movpc * movim.movqtm) * 0.7)
            tt-price.ctocmp = tt-price.ctocmp + 
                        ((bmovim.movpc - bmovim.movdes) * movim.movqtm)
            tt-price.price =  tt-price.price + 
                        (((bmovim.movpc - bmovim.movdes) * movim.movqtm) -
                        ((movim.movpc * movim.movqtm) * 0.7)).
        create tt-proprice.
        assign
            tt-proprice.etbcod = movim.etbcod 
            tt-proprice.numero = plani.numero
            tt-proprice.procod = movim.procod
            tt-proprice.data   = movim.movdat
            tt-proprice.movqtm   = movim.movqtm
            tt-proprice.valven   = (movim.movpc * movim.movqtm)
            tt-proprice.ctoven   = ((movim.movpc * movim.movqtm) * 0.7)
            tt-proprice.ctocmp   = ((bmovim.movpc - bmovim.movdes) *                                         movim.movqtm)
            tt-proprice.price =   
                        (((bmovim.movpc - bmovim.movdes) * movim.movqtm) -
                        ((movim.movpc * movim.movqtm) * 0.7)).
    end.
end.
end.
assign
    vtmovqtm = 0 vtvalven = 0 vtctoven = 0 vtctocmp = 0 vtprice  = 0 .
hide frame f-tela no-pause.
for each tt-price:
    assign
        vtmovqtm = vtmovqtm + tt-price.movqtm
        vtvalven = vtvalven + tt-price.valven
        vtctoven = vtctoven + tt-price.ctoven
        vtctocmp = vtctocmp + tt-price.ctocmp
        vtprice  = vtprice  + tt-price.price
        .
end.     

if vetbcod = 0
then run por-filial.
else run por-data.

procedure por-filial:
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Relatorio","","","",""]
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

disp "      TOTAL GERAL  "   space(5)
     vtmovqtm   format ">>>9"
     vtvalven   format ">>>>,>>9.99"
     vtctoven   format ">>>>,>>9.99"
     vtctocmp   format ">>>>>,>>9.99"
     vtprice    format "->>>>>,>>9.99"
     with frame f-tot 1 down
        no-label no-box row 20 overlay.
   
bl-princ:
repeat:

    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then find first tt-price no-lock no-error.
    else find tt-price where recid(tt-price) = recatu1 no-lock no-error.

    if not available tt-price
    then do:
        message color red/with
            "Nenhum registro encontrado"
            view-as alert-box.
        leave bl-princ.    
    end.

    clear frame frame-a all no-pause.
    
    find bestab where bestab.etbcod = tt-price.etbcod no-lock.
    display tt-price.etbcod column-label "Fil"  
            bestab.etbnom no-label   format "x(17)" 
            tt-price.movqtm column-label "Qtd" format ">>>9"
            tt-price.valven column-label "Valor Venda"  format ">>>>,>>9.99"
            tt-price.ctoven column-label "Custo Venda"  format ">>>>,>>9.99"
            tt-price.ctocmp column-label "Custo Compra" format ">>>>,>>9.99"
            tt-price.price  column-label "Price" format "->>>>>,>>9.99"    
            with frame frame-a  row 8 8 down centered overlay
            width 80.

    recatu1 = recid(tt-price).
    
    color display message esqcom1[esqpos1] with frame f-com1.

    repeat:
    
        find next tt-price no-lock no-error.
        
        if not available tt-price
        then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        down with frame frame-a.
        
        find bestab where bestab.etbcod = tt-price.etbcod no-lock.
        display 
            tt-price.etbcod
            bestab.etbnom
            tt-price.movqtm
            tt-price.valven
            tt-price.ctoven
            tt-price.ctocmp
            tt-price.price
            with frame frame-a.

    end.
    
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-price where recid(tt-price) = recatu1 no-lock no-error.

        choose field tt-price.etbcod go-on(cursor-down cursor-up 
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
        
            find next tt-price no-lock no-error.
            
            if not avail tt-price
            then next.
            
            color display normal tt-price.etbcod.
            
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.

        end.

        if keyfunction(lastkey) = "cursor-up"
        then do:
        
            find prev tt-price no-lock no-error.
            if not avail tt-price
            then next.
            
            color display normal tt-price.etbcod.
            
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
                    run relatorio-fil.
                end.
                recatu1 = recid(tt-price).
                leave.
            end.
            
            if esqcom1[esqpos1] = "Confirma"
            then do: 
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
        find bestab where bestab.etbcod = tt-price.etbcod no-lock.
        display 
            tt-price.etbcod
            bestab.etbnom
            tt-price.movqtm
            tt-price.valven
            tt-price.ctoven
            tt-price.ctocmp
            tt-price.price
            with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-price).
   end.
end.
end procedure.


procedure relatorio-fil :
    
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
        disp tt-price.etbcod column-label "Fil"
             bestab.etbnom
             tt-price.movqtm (total) column-label "Qtd" format ">>>9"
             tt-price.valven (total) column-label "Valor Venda"
                                    format ">>,>>>,>>9.99"
             tt-price.ctoven (total) column-label "Custo Venda" 
                                format ">>,>>>,>>9.99"
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

procedure por-data:
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Produto","Relatorio","","",""]
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

disp "   TOTAL GERAL  "   space(1)
     vtmovqtm   format ">>>9"
     vtvalven   format ">>,>>>,>>9.99"
     vtctoven   format ">>,>>>,>>9.99"
     vtctocmp   format ">>,>>>,>>9.99"
     vtprice    format ">>>,>>>,>>9.99"
     with frame f-tot 1 down
        no-label no-box row 20 overlay.
 
bl-princ:
repeat:

    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then find first tt-price no-lock no-error.
    else find tt-price where recid(tt-price) = recatu1 no-lock no-error.

    if not available tt-price
    then do:
        message color red/with
            "Nenhum registro encontrado"
            view-as alert-box.
        leave bl-princ.    
    end.

    clear frame frame-a all no-pause.
    
    find bestab where bestab.etbcod = tt-price.etbcod no-lock.
    display tt-price.data at 6 column-label "Data"  format "99/99/9999"
            tt-price.movqtm column-label "Qtd" format ">>>9"
            tt-price.valven column-label "Valor Venda" format ">>,>>>,>>9.99"
            tt-price.ctoven column-label "Custo Venda" format ">>,>>>,>>9.99"
            tt-price.ctocmp column-label "Custo Compra" format ">>,>>>,>>9.99"
            tt-price.price  column-label "Price" format "->>,>>>,>>9.99"    
            with frame frame-a  row 8 8 down centered overlay
            width 80.

    recatu1 = recid(tt-price).
    
    color display message esqcom1[esqpos1] with frame f-com1.

    repeat:
    
        find next tt-price no-lock no-error.
        
        if not available tt-price
        then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        down with frame frame-a.
        
        find bestab where bestab.etbcod = tt-price.etbcod no-lock.
        display 
            tt-price.data
            tt-price.movqtm
            tt-price.valven
            tt-price.ctoven
            tt-price.ctocmp
            tt-price.price
            with frame frame-a.

    end.
    
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-price where recid(tt-price) = recatu1 no-lock no-error.

        choose field tt-price.data go-on(cursor-down cursor-up 
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
        
            find next tt-price no-lock no-error.
            
            if not avail tt-price
            then next.
            
            color display normal tt-price.data.
            
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.

        end.

        if keyfunction(lastkey) = "cursor-up"
        then do:
        
            find prev tt-price no-lock no-error.
            if not avail tt-price
            then next.
            
            color display normal tt-price.data.
            
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

            if esqcom1[esqpos1] = "Produto"
            then do:
                run proprice.p(input tt-price.data).
                recatu1 = recid(tt-price).
                leave.
            end.
            if esqcom1[esqpos1] = "Relatorio"
            then do:
                sresp = no.
                message "Confirma Imprimir ?" update sresp.
                if sresp 
                then do:
                    run relatorio-data.
                end.
                recatu1 = recid(tt-price).
                leave.
            end.

            if esqcom1[esqpos1] = "Confirma"
            then do: 
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
        find bestab where bestab.etbcod = tt-price.etbcod no-lock.
        display 
            tt-price.data
            tt-price.movqtm
            tt-price.valven
            tt-price.ctoven
            tt-price.ctocmp
            tt-price.price
            with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-price).
   end.
end.
end procedure.

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


