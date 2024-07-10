/*
*/

def var vbusca          as   char label "SKU".
def var primeiro        as   log.
def var vhorarec as char format "x(6)".
def var vhoraInt as char format "x(6)" .

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," Precos ", " Hispre ",""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i }
def input parameter par-procod as char.
find prof226 where prof226.sku_id = par-procod no-lock.

def buffer bProf_1701       for Prof_1701.
def var vProf_1701         like Prof_1701.PRICE_TYPE.


form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
form    
    prof_1701.marca
    with frame frame-a.
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find Prof_1701 where recid(Prof_1701) = recatu1 no-lock.
    if not available Prof_1701
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end. else leave.

    recatu1 = recid(Prof_1701).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available Prof_1701
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find Prof_1701 where recid(Prof_1701) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(Prof_1701.PRICE_TYPE)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(Prof_1701.PRICE_TYPE)
                                        else "".
            run color-message.
            choose field Prof_1701.PRICE_TYPE help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      1 2 3 4 5 6 7 8 9 0 
                      page-down   page-up
                      tab PF4 F4 ESC return).
            if keyfunction(lastkey) = "0" or
               keyfunction(lastkey) = "1" or
               keyfunction(lastkey) = "2" or 
               keyfunction(lastkey) = "3" or 
               keyfunction(lastkey) = "4" or 
               keyfunction(lastkey) = "5" or 
               keyfunction(lastkey) = "6" or 
               keyfunction(lastkey) = "7" or 
               keyfunction(lastkey) = "8" or 
               keyfunction(lastkey) = "9"
            then do with frame fbusca
                        centered color normal side-labels row 10 overlay:
                vbusca = keyfunction(lastkey).
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
                /* update vbusca.*/
                recatu2 = recid(Prof_1701).
                find first Prof_1701 
                            where 
                            Prof_1701.PRODUCT_ID = vbusca
                            use-index PRODUCT_ID
                                no-lock no-error.                        
                if avail Prof_1701
                then recatu1 = recid(Prof_1701).
                else recatu1 = recatu2.
                leave.
            end.

             
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail Prof_1701
                    then leave.
                    recatu1 = recid(Prof_1701).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail Prof_1701
                    then leave.
                    recatu1 = recid(Prof_1701).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail Prof_1701
                then next.
                color display white/red Prof_1701.PRICE_TYPE with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail Prof_1701
                then next.
                color display white/red Prof_1701.PRICE_TYPE with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form 
              PRODUCT_ID          label   "PRODUCT_ID"             colon 20
              STORE_ID            label   "STORE_ID"               colon 20
              PRICE_KEY           label   "PRICE_KEY"              colon 20
              APPROVED_PRICE      label   "APPROVED_PRICE"         colon 20
              APPROVED_PRICE_PLAN label   "APPROVED_PRICE_PLAN"    colon 20              APPROVED_PRICE_INST label    "APPROVED_PRICE_INST"         colon 20
              PUBLISH_PRICE       label   "PUBLISH_PRICE"          colon 20
              BASE_PRICE          label   "BASE_PRICE"             colon 52
              BASE_PRICE_INST     label   "BASE_PRICE_INST"        colon 20
              BASE_PRICE_PLAN     label   "BASE_PRICE_PLAN"        colon 20
              APPROVED_DATE       label   "APPROVED_DATE"          colon 20
              EFFECTIVE_DATE      label   "EFFECTIVE_DATE"         colon 52
              DUE_DATE            label   "DUE_DATE"               colon 20
              OFFER_ID            label   "OFFER_ID"               colon 52
              PRICE_TYPE          label   "PRICE_TYPE"             colon 20
              CREATE_USER_ID      label   "CREATE_USER_ID"         colon 52
              CREATE_DATETIME     label   "CREATE_DATETIME"        colon 20               skip(1)
              dtreceb             label   "Data Recebimento"       colon 20
              vhorarec         no-label 
              dtintegracao        label   "Data Integracao"        colon 20 
              vhoraInt         no-label
              
                     with frame f-Prof_1701 color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " hispre "
                then do.
                    find Prof_1701 where recid(Prof_1701) = recatu1 no-lock.
                    find produ where produ.procod = int(Prof_1701.PRODUCT_ID)
                                                no-lock no-error.
                    if avail produ
                    then do.
                        run cons_hispre.p (produ.procod).
                    end.
                end.
                
                if esqcom1[esqpos1] = " Precos "
                then do.
                    find Prof_1701 where recid(Prof_1701) = recatu1 no-lock.
                    find produ where produ.procod = int(Prof_1701.PRODUCT_ID)
                                            no-lock no-error.
                    if avail produ
                    then do.
                        run precons.p (string(recid(produ))).
                    end.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-Prof_1701.
                    disp Prof_1701 except hrreceb hrintegracao.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(Prof_1701).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
def var vPRICE_TYPE as char .
vPRICE_TYPE =  if Prof_1701.PRICE_TYPE = "R" 
               then "Regular" 
               else  
               if true
               then "saldo"
               else
               if true
               then "Promocional"
               else "".
display
    prof_1701.marca no-label 
    Prof_1701.PRICE_TYPE no-label
    vPRICE_TYPE             column-label "TYPE"   format "x(4)"
    /*PRODUCT_ID              column-label "ProCod" format "x(7)"*/
    STORE_ID                column-label "Etb"    format "xxx"    
    dec(APPROVED_PRICE)           column-label "Preco"  format ">>>>9.99"
    APPROVED_PRICE_PLAN     column-label "Plano"  format "xxx"  
    dec(APPROVED_PRICE_INST)      column-label "Parcelado" format ">>>>9.99"
    dec(PUBLISH_PRICE)             column-label "Publicado" format ">>>>9.99"
    /*
    dec(BASE_PRICE)               column-label "Base!Preco" format ">>>>9.99"
    dec(BASE_PRICE_INST)          column-label "Base!Parcelado" format ">>>>9.99"
    BASE_PRICE_PLAN         column-label "Base!Plano"   format "xxx" 
     */
    dtreceb         column-label "Recebimento"
    dtintegracao    column-label "Integrado"
        with frame frame-a 09 down centered color white/red row 5
            title " Preco Recebidos Produto - " + string(prof226.sku_id) + " ".
end procedure.
procedure color-message.
color display message
        Prof_1701.PRICE_TYPE
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        Prof_1701.PRICE_TYPE
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first Prof_1701 where Prof_1701.PRODUCT_ID = prof226.sku_id
                                                no-lock no-error.
    else  
        find last Prof_1701  where Prof_1701.PRODUCT_ID = prof226.sku_id
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next Prof_1701  where Prof_1701.PRODUCT_ID = prof226.sku_id
                                                no-lock no-error.
    else  
        find prev Prof_1701   where Prof_1701.PRODUCT_ID = prof226.sku_id
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev Prof_1701 where Prof_1701.PRODUCT_ID = prof226.sku_id  
                                        no-lock no-error.
    else   
        find next Prof_1701 where Prof_1701.PRODUCT_ID = prof226.sku_id 
                                        no-lock no-error.
        
end procedure.
         
