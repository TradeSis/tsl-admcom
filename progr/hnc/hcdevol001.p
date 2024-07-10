{admcab.i}

def input parameter p-clicod like clien.clicod.
def input parameter p-tipdev as char.
def output parameter p-resp as log init no.

def var vvista as log.
def  shared temp-table tt-devolver
    field procod like movim.procod
    field etbcod like movim.etbcod    
    field movtdc like plani.movtdc
    field placod like plani.placod
    field pladat like plani.pladat
    field movpc  like movim.movpc
    field movqtm like movim.movqtm
    field serie  like plani.serie
    field numero like plani.numero
    field notped like plani.notped
    field movdev like movim.movdev.

def  shared temp-table tt-titdev
    field marca as char format "x(1)"
    field empcod like titulo.empcod
    field titnat like titulo.titnat
    field modcod like titulo.modcod
    field etbcod like titulo.etbcod
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titvlcob like titulo.titvlcob
    field titvlpag like titulo.titvlpag
    field titsit   like titulo.titsit
    field titdtemi like titulo.titdtemi
    field tipdev     as   char
    index i-tit is primary unique empcod 
                                  titnat 
                                  modcod 
                                  etbcod 
                                  clifor 
                                  titnum 
                                  titpar.


def  shared temp-table tt-pro-recibo
    field pronom like produ.pronom
    field procod like produ.procod
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    index iprocod is primary unique procod.
def var d-vista as log format "Sim/Nao".
def var vclicod     like clien.clicod format ">>>>>>>>>>9".

def  shared temp-table tp-plani like com.plani
    field devolver like plani.platot label "Devolver" column-label "Devolver"
    index ipladat-d pladat desc.
def   shared temp-table tp-movim like com.movim.    
def  shared temp-table tp-pro like com.produ.
def  shared temp-table tpb-contnf
        field etbcod  like contnf.etbcod
        field placod  like contnf.placod
        field contnum like contnf.contnum
        field marca   as   char format "x".
def  shared temp-table tpb-contrato like contrato.
def  shared temp-table tp-tbprice like adm.tbprice.
def  shared temp-table tp-contnf like fin.contnf.
def  shared temp-table tp-contrato like fin.contrato.



def var vparam-dev  as char.
def var vtotal      like tp-plani.platot.
def var vnumero     like tp-plani.numero format ">>>>>>>>>9".


for each tt-devolver. delete tt-devolver. end.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.

def var esqcom1         as char format "x(14)" extent 5
    initial [" Produtos "," Confirma "," Procura "," Selecionados "," Nota "].
    
form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

def temp-table tt-plani-bloq
    field etbcod like tp-plani.etbcod
    field placod like tp-plani.placod
    field serie  like tp-plani.serie
    field movtdc like tp-plani.movtdc
    field pladat like tp-plani.pladat.

def var varquivo-bloq as char.

varquivo-bloq = "/usr/admcom/progr/bloqdevol.txt".

if search(varquivo-bloq) <> ? 
then do:  
    input from value(varquivo-bloq).  
    repeat:
        create tt-plani-bloq.
        import tt-plani-bloq.etbcod
               tt-plani-bloq.placod
               tt-plani-bloq.serie
               tt-plani-bloq.movtdc
               tt-plani-bloq.pladat.
    end.    
end.

def var vq as int.
/**
for each tp-plani : 
            for each tp-movim where tp-movim.etbcod = tp-plani.etbcod
                                and tp-movim.placod = tp-plani.placod
                                and tp-movim.movtdc = tp-plani.movtdc
                                and tp-movim.movdat = tp-plani.pladat:
                /***
                find first devmovim where
                           devmovim.procod = tp-movim.procod and
                           devmovim.emite  = tp-plani.etbcod and
                           devmovim.notori = tp-plani.numero 
                           no-lock no-error.
                if avail devmovim
                then do:
                    if devmovim.movqtm >= tp-movim.movqtm
                    then delete tp-movim.
                end.
                ****/
                
                vq = 0.
                for each devmovim where
                         devmovim.procod = tp-movim.procod and
                         devmovim.emite  = tp-plani.etbcod and
                         devmovim.notori = tp-plani.numero
                         no-lock:
                    vq = vq + devmovim.movqtm.
                end.   
                if vq > 0 and
                   vq >= tp-movim.movqtm
                then delete tp-movim.      
            end.
            find first tp-movim where tp-movim.etbcod = tp-plani.etbcod
                                and tp-movim.placod = tp-plani.placod
                                and tp-movim.movtdc = tp-plani.movtdc
                                and tp-movim.movdat = tp-plani.plada
                                no-lock no-error.
            if not avail tp-movim
            then delete tp-plani.
end.
**/

find first tp-plani no-error.
if not avail tp-plani
then do:
    message "Nota ja devolvida ou nao existe" view-as alert-box.
    return.
end.

def var v-message as log init no.
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tp-plani where recid(tp-plani) = recatu1 no-lock.

    if not available tp-plani
    then esqvazio = yes.
    else esqvazio = no.

    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.

        recatu1 = recid(tp-plani).
    end.
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tp-plani
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
            find tp-plani where recid(tp-plani) = recatu1 no-lock.

            status default "".
            run color-message.

            choose field tp-plani.etbcod
                         tp-plani.numero
                         tp-plani.serie
                         tp-plani.pladat
                         vtotal
                         help "" go-on(cursor-down cursor-up
                                       cursor-left cursor-right
                                       page-down   page-up
                                       tab PF4 F4 ESC return) color white/black.
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tp-plani
                    then leave.
                    recatu1 = recid(tp-plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tp-plani
                    then leave.
                    recatu1 = recid(tp-plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tp-plani
                then next.
                color display white/red tp-plani.etbcod 
                                        tp-plani.numero 
                                        tp-plani.serie 
                                        tp-plani.pladat 
                                        vtotal 
                                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tp-plani
                then next.
                color display white/red tp-plani.etbcod 
                                        tp-plani.numero 
                                        tp-plani.serie 
                                        tp-plani.pladat 
                                        vtotal 
                                        with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            for each tt-devolver:
                delete tt-devolver.
            end.
            leave bl-princ.
        end.
        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tp-plani.etbcod 
                 tp-plani.numero 
                 tp-plani.serie 
                 tp-plani.pladat 
                 vtotal
                 with frame f-tp-plani color black/cyan
                      centered side-label row 5 .
                      
            hide frame frame-a no-pause.
            
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Confirma "
                then do with frame f-confirma centered overlay
                             side-labels row 8 on error undo.

                    find first tt-devolver no-lock no-error.
                    if not avail tt-devolver
                    then do:
                        message "Nenhum produto selecionado".    
                        recatu1 = ?.
                        leave.
                    end.
                    for each tp-movim :
                        find produ where produ.procod = tp-movim.procod
                                    no-lock no-error.
                        if not avail produ or
                            produ.catcod = 41
                        then next.

                        find first tt-devolver where
                                   tt-devolver.procod = tp-movim.procod
                                   no-error.
                        if not avail tt-devolver or
                           tt-devolver.movqtm <> tp-movim.movqtm
                        then do:
                            /*
                            message color red/with
                             "Para DEVOLUCAO EM DINHEIRO sera necessario"
                             "fazer devolucao total da venda.".
                           */  
                            leave.
                        end.    
                    end.    
                    sresp = yes.
                    /*
                    message "Confirma Troca/Devolucao?" update sresp.
                    */
                    if sresp
                    then do:
                        run p-cria-titdev.

                        for each tt-devolver:
                            find produ where produ.procod = tt-devolver.procod 
                                 no-lock no-error.
                            v-message = no.
                            if produ.catcod = 31
                            then v-message = yes.     
                            find tt-pro-recibo where 
                                 tt-pro-recibo.procod = tt-devolver.procod
                                                        no-error.
                            if not avail tt-pro-recibo
                            then do:
                                create tt-pro-recibo.
                                assign
                                    tt-pro-recibo.pronom = produ.pronom
                                                    when avail produ
                                    tt-pro-recibo.procod = tt-devolver.procod
                                    tt-pro-recibo.movpc  = tt-devolver.movpc
                                    tt-pro-recibo.movqtm = tt-devolver.movqtm.
                            end.
                        end.
                        for each tp-tbprice where 
                                 tp-tbprice.char2 = "DEVOLVIDO":
                            find first tbprice where 
                                       tbprice.tipo = tp-tbprice.tipo and
                                       tbprice.serial = tp-tbprice.serial
                                       no-error.
                            if avail tbprice
                            then do transaction:
                                tbprice.char2 = "DEVOLVIDO".
                                tbprice.datexp = today.
                                delete tp-tbprice.
                            END.
                            else do transaction:
                                create tbprice.
                                buffer-copy tp-tbprice to tbprice.
                                tbprice.char2 = "DEVOLVIDO".
                                tbprice.datexp = today.
                                delete tp-tbprice.
                            end.
                        end. 
                        
                        /*
                        if v-message = yes
                        then do:
                            message color red/with
                            "Lembrar gerencia de que o pedido dos produtos "
                            skip
                            "referentes a esta venda deve ser cancelado no CD."
                            view-as alert-box.
                        end.           
                        */
                        
                    end.
                    else do:
                        message color red/with
                        "Troca/Devolução não foi confirmada." skip
                        "A operação sera cancelada."
                        view-as alert-box.
                        for each tt-devolver:
                            delete tt-devolver.
                        end.
                    end.
                    p-resp = yes.
                    leave bl-princ.
                end.
                if esqcom1[esqpos1] = " Selecionados "
                then do:
                    find first tt-devolver no-lock no-error.
                    if not avail tt-devolver
                    then do:
                        message "Nenhum produto selecionado".    
                        recatu1 = ?.
                        leave.
                    end.
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.                    
                    run hnc/hcdevol003.p.
                    view frame frame-a. pause 0.
                    view frame f-com1.  pause 0.
                end.
                if esqcom1[esqpos1] = " Nota "
                then do:
                    find first plani where
                            plani.etbcod = tp-plani.etbcod and
                            plani.placod = tp-plani.placod and
                            plani.serie  = tp-plani.serie and
                            plani.pladat = tp-plani.pladat
                            no-lock.
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.                    
                    run not_consnota.p (recid(plani)).
                    view frame frame-a. pause 0.
                    view frame f-com1.  pause 0.
                end.
                
                if esqcom1[esqpos1] = " Procura "
                then do with frame f-procura centered overlay
                             side-labels row 8 on error undo.
                    view frame frame-a. pause 0.

                    update vnumero label "Numero NF".  

                    find first tp-plani where 
                               tp-plani.numero = vnumero no-lock no-error.
                    if not avail tp-plani
                    then do: 
                        message "Nota Fiscal Nao Encontrada.". pause 1.  
                        undo. 
                    end. 
                    
                    hide frame f-procura.
                    recatu1 = recid(tp-plani).
                    leave.
                end.

                if esqcom1[esqpos1] = " Produtos "
                then do:
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    run hnc/hcdevol002.p (input tp-plani.etbcod,
                                    input tp-plani.placod,
                                    input tp-plani.movtdc,
                                    input tp-plani.pladat).
                    view frame frame-a. pause 0.
                    view frame f-com1.  pause 0.
                end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tp-plani).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    if tp-plani.biss > 0 
    then assign vtotal = 0
                vtotal = tp-plani.biss.
    else assign vtotal = 0
                vtotal = tp-plani.platot.

    vvista = tp-plani.crecod = 1.

    find clien where clien.clicod = tp-plani.desti no-lock.
    display 
            tp-plani.etbcod column-label "Filial"      format ">>9"
            tp-plani.numero column-label "Numero NF"   format ">>>>>>>>>9"
            tp-plani.serie  column-label "Serie"       
            tp-plani.pladat column-label "Dt. Emissao" format "99/99/9999"
            vvista          column-label "VP" format "Vis/Cre"
            vtotal          column-label "Total"       
            tp-plani.devolver column-label "Valor Devolver"
            
            with frame frame-a 11 down centered 
                title string(clien.clicod) + " " + clien.clinom row 5.
end procedure.

procedure color-message.
    if tp-plani.biss > 0 
    then assign vtotal = 0 vtotal = tp-plani.biss.
    else assign vtotal = 0 vtotal = tp-plani.platot.

    color display message
            tp-plani.etbcod
            tp-plani.numero
            tp-plani.serie
            tp-plani.pladat
            vtotal
            with frame frame-a.
end procedure.

procedure color-normal.
    if tp-plani.biss > 0 
    then assign vtotal = 0 vtotal = tp-plani.biss.
    else assign vtotal = 0 vtotal = tp-plani.platot.

    color display normal
            tp-plani.etbcod
            tp-plani.numero
            tp-plani.serie
            tp-plani.pladat
            vtotal
            with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tp-plani use-index ipladat-d where true no-lock no-error.
    else  
        find last tp-plani use-index ipladat-d where true no-lock no-error.

if par-tipo = "seg" or par-tipo = "down" 
then
    if esqascend
    then
        find next tp-plani use-index ipladat-d where true no-lock no-error.
    else  
        find prev tp-plani use-index ipladat-d where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tp-plani use-index ipladat-d where true no-lock no-error.
    else   
        find next tp-plani use-index ipladat-d where true no-lock no-error.
        
end procedure.


procedure p-cria-titdev:

    def var vnumero   as   int.
    def var vplatot   like plani.platot.
        
    for each tt-devolver:
        assign vplatot = vplatot + (tt-devolver.movpc * tt-devolver.movqtm)
                    + tt-devolver.movdev.
    end.
        
        /** Titulo **/
        find first tt-devolver no-error.
        if avail tt-devolver
        then vnumero = tt-devolver.numero.
        else vnumero = p-clicod.

                        create tt-titdev.
                        assign tt-titdev.empcod     = wempre.empcod
                               tt-titdev.titnat     = yes
                               tt-titdev.modcod     = "DEV"
                               tt-titdev.etbcod     = estab.etbcod 
                               tt-titdev.clifor     = p-clicod
                               tt-titdev.titnum     = string(vnumero)
                               tt-titdev.titpar     = 1
                               tt-titdev.titvlcob   = vplatot
                               tt-titdev.titsit     = "LIB"
                               tt-titdev.titdtemi   = today
                               tt-titdev.marca      = ""
                               tt-titdev.tipdev     = p-tipdev.
end procedure.

