{admcab.i}

if not connected ( "bswms")
then connect bswms  -N tcp  -S  1922    -H server.dep93 -cache ../wms/bswms.csh.

if  connected ("bswms") 
then run convkit.p .

if connected ("bswms")
then disconnect bswms.


def buffer bprodu for produ.

def var vprocod like produ.procod.
def var vitecod like produ.procod.
def var viteqtd as int.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [/*" Inclusao ",*/" Exclusao "," Consulta "," Procura "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao de kit ",
             " Alteracao de kit ",
             " Exclusao de kit ",
             " Consulta de kit ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


def buffer bkit       for kit.
def var vkit         like kit.procod.


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

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find kit where recid(kit) = recatu1 no-lock.
    if not available kit
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(kit).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available kit
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
            find kit where recid(kit) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(kit.procod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(kit.procod)
                                        else "".
            run color-message.
            choose field kit.procod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).

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
                    if not avail kit
                    then leave.
                    recatu1 = recid(kit).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail kit
                    then leave.
                    recatu1 = recid(kit).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail kit
                then next.
                color display white/red kit.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail kit
                then next.
                color display white/red kit.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form kit
                 with frame f-kit color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-kit on error undo.

                    run p-inclusao.
                    
                    recatu1 = recid(kit).
                    leave.
                end.

                if esqcom1[esqpos1] = " Procura " 
                then do:
                    view frame frame-a. pause 0.
                    vprocod = 0. 
                    update vprocod label "Produto"  
                           with frame f-procura centered 
                                    row 9 side-label overlay.
                               
                    find first kit where kit.procod = vprocod no-lock no-error.
                    
                    if avail kit
                    then recatu1 = recid(kit).
                    else recatu1 = ?.
                                        
                    leave.
                
                end.
                
                
                if esqcom1[esqpos1] = " Consulta " 
                then do:

                    find produ where
                         produ.procod = kit.procod no-lock no-error.
                    
                    for each kit where kit.procod = produ.procod no-lock:
                    find bprodu where
                         bprodu.procod = kit.itecod no-lock no-error.

                     
                     display kit.procod                column-label "Produto"
                        produ.pronom  format "x(28)"  column-label "Descricao"
                            when avail produ
                        kit.itecod   format ">>>>>>>9"  column-label "Item"
                        bprodu.pronom format "x(26)"  column-label "Descricao"
                            when avail bprodu
                        kit.iteqtd    format ">>>9"   column-label "Qtd.!Item"
                        with frame f-consulta 6 down centered row 7.
                    end.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-kit on error undo.
                    /*
                     find kit where
                            recid(kit) = recatu1 
                        exclusive.
                    update kit.
                    */
                    run p-alteracao.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do:
                    find produ where
                         produ.procod = kit.procod no-lock no-error.
                    find bprodu where
                         bprodu.procod = kit.itecod no-lock no-error.
                    
                    display kit.procod                    column-label "Produto"
                        produ.pronom  format "x(28)"  column-label "Descricao"
                            when avail produ
                        kit.itecod   format ">>>>>>>9"   column-label "Item"
                        bprodu.pronom format "x(26)"  column-label "Descricao"
                            when avail bprodu
                        kit.iteqtd    format ">>>9"   column-label "Qtd.!Item"
                        with frame f-exclui 1 down centered row 8.
                               
                    message "Confirma Exclusao deste registro? "
                            update sresp.
                    hide frame f-exclui no-pause.
                    
                    if not sresp
                    then undo, leave.
                    find next kit where true no-error.
                    if not available kit
                    then do:
                        find kit where recid(kit) = recatu1.
                        find prev kit where true no-error.
                    end.
                    recatu2 = if available kit
                              then recid(kit)
                              else ?.
                    find kit where recid(kit) = recatu1
                            exclusive.

                    for each bkit where bkit.itecod = kit.procod:
                        delete bkit.
                    end.
                    
                    delete kit.
                    recatu1 = recatu2.
                    leave.
                end.
                /*if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lkit.p (input 0).
                    else run lkit.p (input kit.procod).
                    leave.
                end.*/
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
        recatu1 = recid(kit).
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
    find produ where produ.procod = kit.procod no-lock no-error.
    find bprodu where bprodu.procod = kit.itecod no-lock no-error.
    
    display kit.procod                       column-label "Produto"
            produ.pronom  format "x(28)"     column-label "Descricao"
                when avail produ
            kit.itecod    format ">>>>>>>>>9"  column-label "Item"
            bprodu.pronom format "x(24)"     column-label "Descricao"
                when avail bprodu
            kit.iteqtd    format ">>>9"      column-label "Qtd.!Item"
            with frame frame-a 11 down width 80 color white/red row 5.
end procedure.

procedure color-message.
    find produ where produ.procod = kit.procod no-lock no-error.
    find bprodu where bprodu.procod = kit.itecod no-lock no-error.
 
    color display message
            kit.procod
            produ.pronom
                when avail produ
            kit.itecod
            bprodu.pronom
                when avail bprodu
            kit.iteqtd
            with frame frame-a.
end procedure.

procedure color-normal.
    find produ where produ.procod = kit.procod no-lock no-error.
    find bprodu where bprodu.procod = kit.itecod no-lock no-error.
 
    color display normal
            kit.procod
            produ.pronom
                when avail produ
            kit.itecod
            bprodu.pronom
                when avail bprodu
            kit.iteqtd
            with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first kit where true
                                                no-lock no-error.
    else  
        find last kit  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next kit  where true
                                                no-lock no-error.
    else  
        find prev kit   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev kit where true  
                                        no-lock no-error.
    else   
        find next kit where true 
                                        no-lock no-error.
        
end procedure.

procedure p-inclusao:
    assign vprocod = 0 vitecod = 0 viteqtd = 0.
    
    do on error undo:         
        update vprocod label "Produto..."
               with frame f-inc side-labels centered row 6.
               
        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao cadastrado.".
            undo, retry.
        end.
        else disp produ.pronom no-label with frame f-inc.
    end.
    
    do on error undo:         
        update vitecod label "Item......" format ">>>>>>>>>>9"
               with frame f-inc side-labels centered row 6.
        if vitecod = 0
        then do:
            run p-cadastra-item(input produ.fabcod, 
                                input vprocod, 
                                output vitecod).
                                
            disp vitecod with frame f-inc.
            find bprodu where bprodu.procod = vitecod no-lock no-error.
            if not avail bprodu
            then do:
                message "Item nao cadastrado.".
                undo, retry.
            end.    
            else disp bprodu.pronom no-label with frame f-inc.
                                
        end.
        else do:
            find bprodu where bprodu.procod = kit.itecod no-lock no-error.
            if not avail bprodu
            then do:
                message "Item nao cadastrado.".
                undo, retry.
            end.    
            else disp bprodu.pronom no-label with frame f-inc.
        end.    
    end.
    
    find kit where kit.procod = vprocod 
               and kit.itecod = vitecod no-error. 
    if avail kit 
    then do: 
        message "Kit ja cadastrado". 
        undo, retry. 
    end.
 
    do on error undo:

        update viteqtd label "Quantidade"
               with frame f-inc.
        if viteqtd = 0
        then do:
            message "Quantidade Invalida.".
            undo, retry.
        end.
        
    end.
    
    if vprocod <> 0 and vitecod <> 0 and viteqtd <> 0
    then do:
        find kit where kit.procod = vprocod
                   and kit.itecod = vitecod no-error.
        if not avail kit
        then do:
            create kit.
            assign kit.procod = vprocod
                   kit.itecod = vitecod
                   kit.iteqtd = viteqtd.
        end.
        else do:
            message "Kit ja cadastrado".
            undo, retry.
        end.
    end.
end procedure.

procedure p-cadastra-item:

    def input parameter p-fabcod like fabri.fabcod.
    def input parameter p-produto-pai like produ.procod.
    def output parameter p-itecod like produ.procod.
    
    sresp = yes.
    message "Deseja cadastrar um novo item?" update sresp.
    if sresp
    then do:
    
        run caditem.p (input  50, 
                       input  p-fabcod,
                       input  p-produto-pai,
                       output p-itecod).

    end.

end procedure.
