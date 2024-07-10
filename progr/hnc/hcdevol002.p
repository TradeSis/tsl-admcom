{admcab.i}


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



def input parameter p-etbcod like tp-plani.etbcod.
def input parameter p-placod like tp-plani.placod.
def input parameter p-movtdc like tp-plani.movtdc.
def input parameter p-movdat like tp-plani.pladat.

def var vdevolver  like movim.movqtm.
def var vutiliza   as log format "Sim/Nao".
def var vmovqtm    as int.
def var vsel       as char format "X".
def var vprocod-nf like movim.procod format ">>>>>>>>>9".
def buffer btp-movim for tp-movim.


find tp-plani where tp-plani.etbcod = p-etbcod
                and tp-plani.placod = p-placod
                and tp-plani.movtdc = p-movtdc
                and tp-plani.pladat = p-movdat no-lock.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend       as log initial yes.

def var esqcom1         as char format "x(12)" extent 5
    initial [" Selecionar "," Procura "," "," "," "].
    
form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

find first tt-devolver where tt-devolver.etbcod <> p-etbcod
                          or tt-devolver.placod <> p-placod
                       no-lock no-error.
if avail tt-devolver
then esqcom1[1] = "".

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.

    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tp-movim where recid(tp-movim) = recatu1 no-lock.
        
    if not available tp-movim
    then do:
        message color red/with "Nenhum produto para ser devolvido"
                view-as alert-box.
        leave bl-princ.
    end.

    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(tp-movim).
    color display message esqcom1[esqpos1] with frame f-com1.
    
    repeat:
        run leitura (input "seg").
        if not available tp-movim
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find tp-movim where recid(tp-movim) = recatu1 no-lock.

            status default "".

            run color-message.

            choose field vsel
                         tp-movim.procod
                         produ.pronom
                         tp-movim.movqtm
                         tp-movim.movpc
                         help "" go-on(cursor-down cursor-up
                                       cursor-left cursor-right
                                       page-down   page-up
                                       PF4 F4 ESC return).
            run color-normal.
            status default "".

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
                    if not avail tp-movim
                    then leave.
                    recatu1 = recid(tp-movim).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tp-movim
                    then leave.
                    recatu1 = recid(tp-movim).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tp-movim
                then next.
        
                find first tt-devolver where 
                                       tt-devolver.procod = tp-movim.procod
                                            no-lock no-error. 
                if avail tt-devolver  
                then vsel = "*". 
                else vsel = "".

                color display white/red vsel
                                        tp-movim.procod
                                        produ.pronom
                                        tp-movim.movqtm
                                        tp-movim.movpc
                                        with frame frame-a.
                                        
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tp-movim
                then next.

                find first tt-devolver where 
                    tt-devolver.procod = tp-movim.procod
                                            no-lock no-error. 
                if avail tt-devolver  
                then vsel = "*". 
                else vsel = "".

                color display white/red vsel
                                        tp-movim.procod
                                        produ.pronom
                                        tp-movim.movqtm
                                        tp-movim.movpc
                                        with frame frame-a.
                                        
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
            
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Procura "
                then do with frame f-procura centered overlay
                             side-labels row 8 on error undo.
                    update vprocod-nf label "Produto".

                    find first btp-movim where 
                               btp-movim.etbcod = p-etbcod
                           and btp-movim.placod = p-placod
                           and btp-movim.movtdc = p-movtdc
                           and btp-movim.movdat = p-movdat
                           and btp-movim.procod = vprocod-nf no-lock no-error.
                    if not avail btp-movim
                    then do: 
                        message "Nota Fiscal nao encontrada".
                        pause 1.
                        undo.
                    end.
                    hide frame f-procura.
                    recatu1 = recid(btp-movim).
                    leave.
                end.

                if esqcom1[esqpos1] = " Selecionar "
                then do with frame f-sel centered overlay
                             side-labels row 8 on error undo:

                    if tp-plani.serie = "V" and
                       int(entry(2,tp-plani.notped,"|")) = 0
                    then do.
                        message "CF esta sem o numero do COO"
                                view-as alert-box.
                        leave.
                    end.
                    
                    view frame frame-a.
                    pause 0.
                    for each tp-tbprice:
                        if int(acha("PRODUTO",tp-tbprice.char1)) =
                            tp-movim.procod
                        then run val-price.
                    end.
                    if keyfunction(lastkey) = "end-error"
                    then next bl-princ.
                    /**
                    find first devmovim where
                                   devmovim.notori = tp-plani.numero and
                                   devmovim.etbcod = tp-plani.etbcod and
                                   devmovim.procod = tp-movim.procod
                                   no-lock no-error.
                    if avail devmovim
                       and devmovim.movqtm >= tp-movim.movqtm
                    then do:
                        message "QUANTIDADE TOTAL DO ITEM JA DEVOLVIDA"
                            VIEW-AS ALERT-BOX. 
                        UNDO.
                    end.
                    **/
                    
                    do on error undo:
                        vmovqtm = tp-movim.movqtm. 
                        update vmovqtm label "Qtd a devolver" format ">>>>9".
                        if vmovqtm > tp-movim.movqtm or
                           vmovqtm = 0
                        then do:
                            message "Quantidade informada invalida".
                            undo.
                        end.
                    end.            
                    
                    if vmovqtm > 0
                    then do:
                        find first devmovim where
                                   devmovim.notori = tp-plani.numero and
                                   devmovim.etbcod = tp-plani.etbcod and
                                   devmovim.procod = tp-movim.procod
                                   no-lock no-error.
                        if avail devmovim
                        then do:
                            if devmovim.movqtm + vmovqtm > tp-movim.movqtm
                            then do:
                                vdevolver = tp-movim.movqtm - devmovim.movqtm.
                                if vdevolver < 0
                                then vdevolver = 0.
                                run mensagem.p(input-output vutiliza,
                                    input "   ***    ATENCAO   ***" +
                                    "!!QUANTIDADE " + string(vmovqtm) + 
                                    " NAO PODE SER DEVOLVIDA " +
                                    "!!QUANTIDADE DE VENDA    = " + 
                                    string(tp-movim.movqtm)
                                    + "!DEVOLVIDA ANTERIRMENTE = " +
                                      string(devmovim.movqtm)
                                    + "!TOTAL A DEVOLVER       = " +
                                      string(vdevolver),    
                                 input "",
                                 input "  OK ", 
                                 input "  OK  ").

                                UNDO.
                            end.
                        end.           
                        find first tt-devolver no-lock no-error.
                        if avail tt-devolver
                        then do:
                            if tt-devolver.numero <> tp-plani.numero
                            then do:
                                message "Nao e permitido devolver produtos de" 
                                      "mais de uma NF em uma unica transacao.".
                                pause 2 no-message.
                                leave bl-princ.
                            end.
                        end.
                        
                        find movim where movim.etbcod = tp-movim.etbcod and
                                         movim.placod = tp-movim.placod and
                                         movim.movseq = tp-movim.movseq and
                                         movim.procod = tp-movim.procod
                                         no-lock.
                        find first tt-devolver where 
                             tt-devolver.procod = tp-movim.procod no-error.
                        if not avail tt-devolver
                        then do:

                            create tt-devolver.
                            assign tt-devolver.procod = tp-movim.procod
                                   tt-devolver.etbcod = tp-movim.etbcod
                                   tt-devolver.placod = tp-plani.placod
                                   tt-devolver.movtdc = tp-plani.movtdc
                                   tt-devolver.pladat = tp-plani.pladat
                                   tt-devolver.movpc  = tp-movim.movpc
                                   tt-devolver.movqtm = vmovqtm
                                   tt-devolver.serie  = tp-plani.serie
                                   tt-devolver.numero = tp-plani.numero
                                   tt-devolver.movdev = (tp-movim.movdev / movim.movqtm * vmovqtm).
                            if tp-plani.serie = "V"
                            then tt-devolver.notped = tp-plani.notped.
                            else tt-devolver.notped = tp-plani.ufdes.

                            find last tpb-contnf where 
                                 tpb-contnf.etbcod = tp-plani.etbcod and
                                 tpb-contnf.placod = tp-plani.placod no-error.
                            if avail tpb-contnf
                            then tpb-contnf.marca = "x".
                        end.
                        else do:
                            assign tt-devolver.movqtm = vmovqtm.
                                   tt-devolver.movdev = (tp-movim.movdev / movim.movqtm * vmovqtm).
                            
                            find last tpb-contnf where 
                                 tpb-contnf.etbcod = tp-plani.etbcod and
                                 tpb-contnf.placod = tp-plani.placod no-error.
                            if avail tpb-contnf
                            then tpb-contnf.marca = "x".
                        end.                            
                    end.
                    else do:
                        find first tt-devolver where
                             tt-devolver.procod = tp-movim.procod no-error.
                        if avail tt-devolver
                        then delete tt-devolver.

                        find last tpb-contnf where
                             tpb-contnf.etbcod = tp-plani.etbcod and
                             tpb-contnf.placod = tp-plani.placod no-error.
                        if avail tpb-contnf
                        then tpb-contnf.marca = "".
                    end.
                end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tp-movim).
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

    find tt-devolver where tt-devolver.procod = tp-movim.procod
                     no-lock no-error.
    if avail tt-devolver 
    then vsel = "*".
    else vsel = "".
    
    find produ where produ.procod = tp-movim.procod no-lock no-error.
    
    display vsel            no-label
            tp-movim.procod column-label "Produto" format ">>>>>>>9"
            produ.pronom    column-label "Descricao" format "x(40)"
                            when avail produ
            tp-movim.movqtm column-label "Qtde"    format ">>>9.99"
            tp-movim.movpc  column-label "Pc.Unit" format ">>>>9.99"
            tt-devolver.movqtm when avail tt-devolver 
                            column-label "Qtd.Devol" format ">>>>>9.99"
            with frame frame-a 11 down centered color white/red row 5
            title " Numero=" + string(tp-plani.numero) + " / " +  
                  string(tp-plani.pladat).
            
end procedure.

procedure color-message.
    find tt-devolver where tt-devolver.procod = tp-movim.procod
                     no-lock no-error.
    if avail tt-devolver 
    then vsel = "*".
    else vsel = "".

    find produ where produ.procod = tp-movim.procod no-lock no-error.

    color display message
            vsel
            tp-movim.procod
            produ.pronom
            tp-movim.movqtm
            tp-movim.movpc
            with frame frame-a.
end procedure.

procedure color-normal.
    find tt-devolver where 
         tt-devolver.procod = tp-movim.procod no-lock no-error.
    if avail tt-devolver 
    then vsel = "*".
    else vsel = "".

    find produ where produ.procod = tp-movim.procod no-lock no-error.

    color display normal
            vsel
            tp-movim.procod
            produ.pronom
            tp-movim.movqtm
            tp-movim.movpc
            with frame frame-a.
            
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tp-movim 
             where tp-movim.etbcod = p-etbcod 
               and tp-movim.placod = p-placod 
               and tp-movim.movtdc = p-movtdc 
               and tp-movim.movdat = p-movdat no-lock no-error.
    else  
        find last tp-movim
             where tp-movim.etbcod = p-etbcod 
               and tp-movim.placod = p-placod 
               and tp-movim.movtdc = p-movtdc 
               and tp-movim.movdat = p-movdat no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tp-movim
             where tp-movim.etbcod = p-etbcod 
               and tp-movim.placod = p-placod 
               and tp-movim.movtdc = p-movtdc 
               and tp-movim.movdat = p-movdat no-lock no-error.

    else  
        find prev tp-movim
             where tp-movim.etbcod = p-etbcod 
               and tp-movim.placod = p-placod 
               and tp-movim.movtdc = p-movtdc 
               and tp-movim.movdat = p-movdat no-lock no-error.

             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tp-movim
             where tp-movim.etbcod = p-etbcod 
               and tp-movim.placod = p-placod 
               and tp-movim.movtdc = p-movtdc 
               and tp-movim.movdat = p-movdat no-lock no-error.

    else   
        find next tp-movim
             where tp-movim.etbcod = p-etbcod 
               and tp-movim.placod = p-placod 
               and tp-movim.movtdc = p-movtdc 
               and tp-movim.movdat = p-movdat no-lock no-error.
        
end procedure.

procedure val-price:
    def var vcor-15 as char.
    do on error undo, retry:
        update  vcor-15 label "Serial - ESN/IMEI/ICCID" format "x(20)"
            with frame f-cor3 side-label centered
            row 15 overlay
            title " Produto - " + string(tp-movim.procod).
        sresp = yes.
        if produ.pronom matches "*CHIP*"
        then do:
            run iccid.p (vcor-15, produ.clacod, output sresp).
        end.
        else do.
            run esn_imei.p(input vcor-15, output sresp).
            if sresp = no
            then do:
                message color red/with
                    "CAMPO OBRIGATORIO Serial - ESN/IMEI" skip
                    "Favor informar os dados corretamente"
                    view-as alert-box.
                undo.    
            end.
        end.
        if vcor-15 <> tp-tbprice.serial
        then do:
            message color red/with
                "Serial/ESN/IMEI/ICCID informado " vcor-15 skip
                "Diferente do informado na venda"
                       view-as alert-box.
            undo.
        end.
        tp-tbprice.char2 = "DEVOLVIDO".                       
    end.
    hide frame f-cor3 no-pause.            
    /**                            vparam = "".
                                vparam = "TIPO=" + trim(operadora.openom) 
                                        + "|SERIAL=" + vcor-15.
                                val-price = yes.
                                run agil-price.
                                if val-price = no 
                                then undo.
    ***/
end.
