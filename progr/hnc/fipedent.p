{admcab.i}

def var nome-retirada as char format "x(30)".
def var fone-retirada as char format "x(15)".
def var vmi as int.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Produtos "," ",""].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

def var v-arquivo as char.
def var vclicod as int.

def var varquivo as char.
def temp-table tpb-pedid no-undo like pedid .
def temp-table tpb-liped no-undo like liped .

for each tpb-pedid. 
    delete tpb-pedid.
end.
for each tpb-liped.
    delete tpb-liped.
end.
    
for each pedid 
    where
        pedid.etbcod = setbcod and
        pedid.pedtdc = 3 and
        pedid.peddat >= today - 120 and
        /**
        (pedid.peddtf >= today - 7  or
         pedid.peddtf = ?) and
        **/ 
        pedid.sitped <> "C" and
        pedid.modcod = "PEDO" 
        no-lock
        by peddat desc.
    create tpb-pedid.
    buffer-copy pedid to tpb-pedid.
    
    for each liped of pedid 
                no-lock.
        create tpb-liped.
        buffer-copy liped to tpb-liped.
    end.
end.
                           
find first tpb-pedid no-lock no-error.
if not avail tpb-pedid
then do:
    message "Nenhum registro encontrado...".
    pause 2 no-message. leave.
end.

        
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
recatu1 = ?.

def var numero-cupom as int.
def var data-entrega as date.
def var vmarca as char.

form    
    /*vmarca no-label format "x"*/
        tpb-pedid.pednum  column-label "Pedido"   format ">>>>>>9"
        tpb-pedid.peddat  column-label "Data"
        tpb-pedid.etbcod  column-label "Filial"      format ">>9"
        tpb-pedid.vencod  column-label "Origem" format ">>9"
        tpb-pedid.clfcod  column-label "Cliente"  format ">>>>>>>>>9"
        tpb-pedid.condat  column-label "Venda"
/*        tpb-pedid.peddtf  column-label "Entrega" format "99/99/9999"
*/
        with frame frame-a 11 down centered row 5 overlay.


for each tpb-pedid where tpb-pedid.pednum = 104274.
 tpb-pedid.pedobs[1] = "NOME-RETIRADA=Claudir Santolin|FONE-RETIRADA=(51)81793721|"
    + tpb-pedid.pedobs[1].
end.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find first tpb-pedid where recid(tpb-pedid) = recatu1 no-lock.


    if not available tpb-pedid
    then do:
        bell.
        message color red/with
            "Nenhum registro encontrado"
            view-as alert-box.
        leave bl-princ.
    end.
    
    esqvazio = no.
    
    clear frame frame-a all no-pause.

    run frame-a.

    recatu1 = recid(tpb-pedid).
    
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tpb-pedid
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        /****
        find produ where produ.procod = tpb-liped.procod no-lock.
        find first tpb-pedid where 
               tpb-pedid.pedtdc = tpb-liped.pedtdc and
               tpb-pedid.etbcod = tpb-liped.etbcod and
               tpb-pedid.pednum = tpb-liped.pednum
               no-lock.
        ***/
         run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tpb-pedid where recid(tpb-pedid) = recatu1 no-lock.
            /****
            find produ where produ.procod = tpb-liped.procod no-lock.
            find first tpb-pedid where 
               tpb-pedid.pedtdc = tpb-liped.pedtdc and
               tpb-pedid.etbcod = tpb-liped.etbcod and
               tpb-pedid.pednum = tpb-liped.pednum
               no-lock.
           ***/    
             status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tpb-pedid.pednum)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tpb-pedid.pednum)
                                        else "".
            /***
            find produ where produ.procod = tpb-liped.procod no-lock.
            find first tpb-pedid where 
               tpb-pedid.pedtdc = tpb-liped.pedtdc and
               tpb-pedid.etbcod = tpb-liped.etbcod and
               tpb-pedid.pednum = tpb-liped.pednum
               no-lock.
            ***/
            run color-message.
            hide message no-pause.
            if tpb-pedid.pedobs[2] <> "" or
               tpb-pedid.pedobs[1] <> ""
            then do:
                nome-retirada = "".
                fone-retirada = "".
                if tpb-pedid.pedobs[1] <> ""
                then do:
                    nome-retirada = acha("NOME-RETIRADA",tpb-pedid.pedobs[1]).
                    fone-retirada = acha("FONE-RETIRADA",tpb-pedid.pedobs[1]).
                end.
                if nome-retirada <> "" or
                   fone-retirada <> ""
                then do:     
                    message 
                        "Contato: " Nome-retirada " - " fone-retirada.
                end.
                if tpb-pedid.pedobs[2] <> ""
                then message color normal tpb-pedid.pedobs[2].
                    
            end.
            choose field tpb-pedid.pednum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            /***
            find produ where produ.procod = tpb-liped.procod no-lock.
            find first tpb-pedid where 
               tpb-pedid.pedtdc = tpb-liped.pedtdc and
               tpb-pedid.etbcod = tpb-liped.etbcod and
               tpb-pedid.pednum = tpb-liped.pednum
               no-lock.
           ***/
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
                    if not avail tpb-pedid
                    then leave.
                    recatu1 = recid(tpb-pedid).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tpb-pedid
                    then leave.
                    recatu1 = recid(tpb-pedid).
                end.
                leave.
            end.
            
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tpb-pedid
                then next.

                color display white/red tpb-pedid.pednum with frame frame-a.
                
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tpb-pedid
                then next.

                color display white/red tpb-pedid.pednum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            pause 0.
            find first tpb-pedid where
                    recid(tpb-pedid) = recatu1.
            /**
            form tpb-pedid
                 with frame f-tpb-pedid color black/cyan
                      centered side-label row 5 .
            **/
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Produtos "
            then do:
                for each tpb-liped where
                         tpb-liped.etbcod = tpb-pedid.etbcod and
                         tpb-liped.pedtdc = tpb-pedid.pedtdc and
                         tpb-liped.pednum = tpb-pedid.pednum
                         no-lock:
                    find produ where produ.procod = tpb-liped.procod
                                no-lock no-error.
                                
                    disp tpb-liped.procod   column-label "Codigo"
                         produ.pronom when avail produ column-label "Descricao"
                         tpb-liped.lipqtd  column-label "Quantidade"
                         with frame f-produ
                        color message centered  row 5 
                                        overlay down
                        title " Pedido: " + string(tpb-pedid.pednum) +
                              " Origem: " + string(tpb-pedid.vencod) + 
                              " Cliente: " + string(tpb-pedid.clfco) +
                              " ".

                end.
                repeat on endkey undo:
                pause.
                leave.
                end.
                
                leave.
            end.
            /**
            if esqcom1[esqpos1] = " Marca/Desmarca"
            then do:
                

                find first  tt-marca no-error.
                if not avail tt-marca or
                    (tt-marca.etbcod = tpb-pedid.etbcod and
                    tt-marca.vencod = tpb-pedid.vencod and
                    tt-marca.clfcod = tpb-pedid.clfcod)
                then.
                else do:
                    bell.
                    message color red/with
                    "Entrega multipla somete permitido para pedidos " skip
                    "da mesma origem e do mesmo cliente"
                    view-as alert-box.
                    next.
                end.    


                find first  tt-marca where 
                            tt-marca.etbcod = tpb-pedid.etbcod and
                            tt-marca.pedtdc = tpb-pedid.pedtdc and
                            tt-marca.pednum = tpb-pedid.pednum
                            no-error.
                            
                if tpb-pedid.peddtf <> ? and
                    not avail tt-marca
                then do:
                    bell.
                    message color red/with
                    "Pedido " tpb-pedid.pednum
                    "ja foi entregue em " tpb-pedid.peddtf
                    view-as alert-box.
                    leave. 
                end.

                if avail tt-marca
                then delete tt-marca.
                else do:
                    create tt-marca.
                    assign
                        tt-marca.etbcod = tpb-pedid.etbcod
                        tt-marca.pedtdc = tpb-pedid.pedtdc
                        tt-marca.pednum = tpb-pedid.pednum
                        tt-marca.vencod = tpb-pedid.vencod
                        tt-marca.clfcod = tpb-pedid.clfcod.
                end.
            end.
            **/
            if esqcom1[esqpos1] = " Contato "
            then do:
                nome-retirada = acha("NOME-RETIRADA",tpb-pedid.pedobs[1]).
                fone-retirada = acha("FONE-RETIRADA",tpb-pedid.pedobs[1]).
                if nome-retirada <> ?
                then do:
                    disp nome-retirada label "Contato"
                           fone-retirada label "Telefone"
                           with frame f-contato 1 down centered
                           row 10 color message overlay
                           title " Pedido " + string(tpb-pedid.pednum) + " ".
                    pause.
                    hide frame f-contato.
                end.
                else do:
                    bell.
                    message color red/with
                           "Pedido sem registro de contato."
                           view-as alert-box.
                    leave.
                end.          
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
            /***
            find produ where produ.procod = tpb-liped.procod no-lock.
            find first tpb-pedid where 
               tpb-pedid.pedtdc = tpb-liped.pedtdc and
               tpb-pedid.etbcod = tpb-liped.etbcod and
               tpb-pedid.pednum = tpb-liped.pednum
               no-lock.
            ***/
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tpb-pedid).
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

/**
find first  tt-marca where 
                            tt-marca.etbcod = tpb-pedid.etbcod and
                            tt-marca.pedtdc = tpb-pedid.pedtdc and
                            tt-marca.pednum = tpb-pedid.pednum
                            no-error.
if avail tt-marca
then vmarca = "*".
else vmarca = "".
**/
display /**vmarca**/
        tpb-pedid.pednum  column-label "Pedido"   format ">>>>>>9"
        tpb-pedid.etbcod  column-label "Filial"      format ">>9"
        tpb-pedid.peddat  column-label "Data"
        tpb-pedid.vencod  column-label "Origem" format ">>9"
        tpb-pedid.clfcod  column-label "Cliente"  format ">>>>>>>>>9"
        tpb-pedid.condat  column-label "Venda"
/*        tpb-pedid.peddtf  column-label "Entrega"*/
        with frame frame-a 11 down centered row 5 overlay.
end procedure.
procedure color-message.
color display message
        tpb-pedid.pednum
        tpb-pedid.etbcod
        tpb-pedid.peddat
        tpb-pedid.vencod
        tpb-pedid.clfcod
        tpb-pedid.condat
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tpb-pedid.pednum
        tpb-pedid.etbcod
        tpb-pedid.peddat
        tpb-pedid.vencod
        tpb-pedid.clfcod
        tpb-pedid.condat
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tpb-pedid where true
                                                no-lock no-error.
    else  
        find last tpb-pedid  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tpb-pedid  where true
                                                no-lock no-error.
    else  
        find prev tpb-pedid   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tpb-pedid where true  
                                        no-lock no-error.
    else   
        find next tpb-pedid where true 
                                        no-lock no-error.
        
end procedure.
         
