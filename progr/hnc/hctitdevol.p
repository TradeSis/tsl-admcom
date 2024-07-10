{admcab.i}

def input  parameter p-clicod like clien.clicod.
def input  parameter p-emite  as log.

def var p-bloq-din as log init no.

def var p-devval as dec.

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
def  shared temp-table tp-vndseguro like com.vndseguro.

def  shared temp-table tp-titulo like fin.titulo
    index dt-ven titdtven
        index titnum /*is primary unique*/ empcod
                                           titnat
                                                                              modcod
                                   etbcod
                                                                      clifor
                                                                                                         titnum
                                                            titpar.
                                                            





def var vparam-dev as char.
def var recpla as recid.
def var recpla-pro1 as recid.

def var vevecod like titulo.evecod.
def var vvencod like plani.vencod.
def var vval-aberto as dec.
def var vval-pago   as dec.
def var vval-pago-ori as dec.
def var vok as log.



def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.

def var esqcom1         as char format "x(21)" extent 3 
    initial [" Marcar/Desmarcar ", " Efetuar Troca " ,"Devolucao em Dinheiro"].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

find first tt-titdev no-lock no-error.
if not avail tt-titdev
then leave.

p-devval = 0.
for each tt-titdev:
    if tt-titdev.titsit = "EXC"
    then delete tt-titdev.
end.
find first tt-titdev no-lock no-error.
if not avail tt-titdev
then leave.

for each tt-titdev:
    tt-titdev.marca = "*".
end.

for each tt-titdev where tt-titdev.marca = "*":
    p-devval = p-devval + (tt-titdev.titvlcob - tt-titdev.titvlpag).    
end.


if p-emite
then do:
    esqcom1[3] = "Devolucao".
end.


def buffer btt-titdev for tt-titdev.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-titdev where recid(tt-titdev) = recatu1 no-lock.

    if not available tt-titdev
    then esqvazio = yes.
    else esqvazio = no.

    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-titdev).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-titdev
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
            find tt-titdev where recid(tt-titdev) = recatu1 no-lock.

            status default "".
            run color-message.

            choose field tt-titdev.marca
                         tt-titdev.titpar 
                         tt-titdev.titnum
                         tt-titdev.modcod
                         tt-titdev.titdtemi
                         tt-titdev.titvlcob
                         tt-titdev.titvlpag
                         help "" go-on(cursor-down cursor-up
                                       cursor-left cursor-right
                                       page-down   page-up
                                       PF4 F4 ESC return) color white/black.
            run color-normal.
            status default "".
        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 3 then 3 else esqpos1 + 1.
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
                    if not avail tt-titdev
                    then leave.
                    recatu1 = recid(tt-titdev).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-titdev
                    then leave.
                    recatu1 = recid(tt-titdev).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-titdev
                then next.
                color display white/red tt-titdev.marca
                                        tt-titdev.titpar 
                                        tt-titdev.titnum
                                        tt-titdev.modcod
                                        tt-titdev.titdtemi
                                        tt-titdev.titvlcob
                                        tt-titdev.titvlpag
                                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-titdev
                then next.
                color display white/red tt-titdev.marca
                                        tt-titdev.titpar 
                                        tt-titdev.titnum
                                        tt-titdev.modcod
                                        tt-titdev.titdtemi
                                        tt-titdev.titvlcob 
                                        tt-titdev.titvlpag
                                        with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            sresp = no.
            message "Deseja desistir da devolucao?" update sresp.
            if sresp = no
            then next bl-princ.
            else leave bl-princ.
        end.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                    with frame f-com1.
                                       
            if esqcom1[esqpos1] = " Efetuar Troca "
            then do:
                
                find first btt-titdev where btt-titdev.marca = "*"
                        no-lock no-error.
                if avail btt-titdev
                then do:        
                    if p-emite = no
                    then run hnc/hcintegaos.p ("TROCA").
                    else run hnc/hcintegemi.p ("TROCA").
                    leave bl-princ.
                end.
                else do:
                    bell.
                    message color red/with
                      "Nenhum registro marcado."
                       view-as alert-box.
                    next bl-princ.   
                end.
                
            end.

            if esqcom1[esqpos1] = "Devolucao em Dinheiro" 
            then do:
                find first btt-titdev where btt-titdev.marca = "*"
                        no-lock no-error.
                if not avail btt-titdev
                then do:        
                    bell.
                    message color red/with
                      "Nenhum registro marcado."
                       view-as alert-box.
                    next bl-princ.   
                end.
                if tt-titdev.clifor = 1
                then do:
                    message "Devolução não permitida para cliente 1"
                            view-as alert-box.
                    leave.
                end.
                find first tt-devolver.
                find tp-plani where tp-plani.etbcod = tt-devolver.etbcod and
                            tp-plani.placod = tt-devolver.placod.
                            
                if p-bloq-din = no
                then do:
                    find first tt-pro-recibo no-error.
                    if not avail tt-pro-recibo
                    then p-bloq-din = yes.
                        
                    for each tt-pro-recibo:
                        find produ where produ.procod = tt-pro-recibo.procod 
                                 no-lock no-error.
                        if avail produ
                        then if produ.catcod = 41
                             then p-bloq-din = yes.
                    end.
                end.
                if p-bloq-din
                then do:
                    message "Operacao nao permitida: categoria 41"
                            view-as alert-box.
                    leave.
                end.
                p-bloq-din = no.
                for each tp-movim where tp-movim.etbcod = tp-plani.etbcod and
                                        tp-movim.placod = tp-plani.placod:
                    find first tt-pro-recibo where
                                   tt-pro-recibo.procod = tp-movim.procod
                                   no-error.
                    if not avail tt-pro-recibo or
                       tt-pro-recibo.movqtm <> tp-movim.movqtm
                    then do:
                        p-bloq-din = yes.
                        leave.
                    end.   
                end.
                if p-bloq-din
                then do:
                    message "DEVOLUCAO EM DINHEIRO so podera ser feita"
                            "com devolucao total da venda." skip
                            "Esta operacao sera cancelada."
                            view-as alert-box.
                    leave bl-princ.
                end.      
                if p-emite = no
                then run hnc/hcintegaos.p ("DEVOLUCAO").
                else run hnc/hcintegemi.p ("DEVOLUCAO").
                
                return.
            end.
            if esqcom1[esqpos1] = "Devolucao"
            then do:
                find first btt-titdev where btt-titdev.marca = "*"
                        no-lock no-error.
                if not avail btt-titdev
                then do:        
                    bell.
                    message color red/with
                      "Nenhum registro marcado."
                       view-as alert-box.
                    next bl-princ.   
                end.
                if tt-titdev.clifor = 1
                then do:
                    message "Devolução não permitida para cliente 1"
                            view-as alert-box.
                    leave.
                end.
                find first tt-devolver.
                find tp-plani where tp-plani.etbcod = tt-devolver.etbcod and
                            tp-plani.placod = tt-devolver.placod.
                            
                if p-emite = no
                then run hnc/hcintegaos.p ("DEVOLUCAO").
                else run hnc/hcintegemi.p ("DEVOLUCAO").
                
                return.
            end.
                 
            if esqcom1[esqpos1] = " Marcar/Desmarcar "
            then do with frame f-marca centered overlay
                             side-labels row 8 on error undo.
                    
                if tt-titdev.marca = ""
                then assign
                        tt-titdev.marca = "*" 
                        p-devval = p-devval + 
                                     (tt-titdev.titvlcob - tt-titdev.titvlpag).
                else assign 
                        tt-titdev.marca = ""
                        p-devval = p-devval -
                                     (tt-titdev.titvlcob - tt-titdev.titvlpag).
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-titdev).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
        next.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.

    display tt-titdev.marca    no-label                 format "x(1)"
            tt-titdev.titpar   column-label "Pr"        format ">>>9"
            tt-titdev.titnum   column-label "Numero"    format "x(10)"
            tt-titdev.modcod   column-label "Mod"       format "x(3)"
            tt-titdev.titdtemi column-label "Emissao"   format "99/99/9999"
            tt-titdev.titvlcob column-label "Credito"   format ">>,>>9.99"
            tt-titdev.titvlpag column-label "Utilizado" format ">>,>>9.99"
            with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message
            tt-titdev.marca
            tt-titdev.titpar 
            tt-titdev.titnum
            tt-titdev.modcod
            tt-titdev.titdtemi
            tt-titdev.titvlcob
            tt-titdev.titvlpag
            with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
            tt-titdev.marca
            tt-titdev.titpar 
            tt-titdev.titnum
            tt-titdev.modcod
            tt-titdev.titdtemi
            tt-titdev.titvlcob
            tt-titdev.titvlpag
            with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-titdev where true no-lock no-error.
    else  
        find last tt-titdev where true no-lock no-error.

if par-tipo = "seg" or par-tipo = "down" 
then
    if esqascend
    then
        find next tt-titdev where true no-lock no-error.
    else  
        find prev tt-titdev where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-titdev where true no-lock no-error.
    else   
        find next tt-titdev where true no-lock no-error.
        
end procedure.

