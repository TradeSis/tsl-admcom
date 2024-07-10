/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def shared temp-table tt-contrato   like fin.contrato.
def shared temp-table tt-titulo     like fin.titulo
use-index cxmdat
use-index datexp
use-index etbcod
use-index exportado
use-index iclicod
use-index titdtpag
use-index titdtven
use-index titnum
use-index titsit
.
def shared temp-table tt-contnf     like fin.contnf.
def shared temp-table tt-movim      like movim.

def var vtotjuro as dec format ">>,>>9.99".
def var vtot1    as dec format ">>,>>9.99".
def var vtot2    as dec format ">>,>>9.99".

def shared temp-table tt-tit
    field rec     as recid 
    field dias    as int
    field etbcod  like tt-titulo.etbcod
    field juro    like tt-titulo.titvlcob
    field vtot    like tt-titulo.titvlcob
    field vacu    like tt-titulo.titvlcob
    field vord    as int
        index ind-1 vord.
 

def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(16)" extent 2
            initial ["Nota Fiscal",""].


def buffer btt-tit    for tt-tit.
def var vetbcod       like tt-tit.etbcod.


    form
        esqcom1
            with frame f-com1
                 row 5
                  no-box no-labels side-labels column 1 centered.
                 
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
    
    assign vtotjuro = 0
           vtot1    = 0
           vtot2    = 0.
           
for each tt-tit:
    find tt-titulo where recid(tt-titulo) = tt-tit.rec no-lock.
    assign vtotjuro = vtotjuro + tt-tit.juro
           vtot1    = vtot1    + tt-titulo.titvlcob
           vtot2    = vtot2    + tt-tit.vtot.
end.
bl-princ:
repeat:
    
    pause 0.
    display "TOTAIS........................"
            vtot1    no-label to 44 format "zz,zz9.99"
            vtotjuro no-label to 54 format "zz,zz9.99"
            vtot2    no-label to 64 format "zz,zz9.99"
                with frame f-tot side-label 
                            color message row 20 no-box width 80.

    pause 0.
    /*
    disp esqcom1 with frame f-com1.
    */
    if recatu1 = ?
    then
        find first tt-tit where
            true no-error.
    else
        find tt-tit where recid(tt-tit) = recatu1.
    vinicio = yes.
    if not available tt-tit
    then do:
        message "Nenhuma prestacao em aberto".
        return.
    end.

    clear frame frame-a all no-pause.
    
    find tt-titulo where recid(tt-titulo) = tt-tit.rec no-lock.
    
    display tt-tit.etbcod column-label "Fl." format ">>9"
            tt-titulo.titnum format "x(10)"
            tt-titulo.titpar column-label "Pr" format ">99" 
            tt-titulo.titdtven format "99/99/9999"
            tt-tit.dias  when tt-tit.dias > 0 column-label "Atr" format ">>>9"
            tt-titulo.titvlcob column-label "Principal" format ">>,>>9.99"
            tt-tit.juro column-label "Juro" format ">>,>>9.99"
            tt-tit.vtot column-label "Total" format ">>,>>9.99"
            tt-tit.vacu column-label "Acum" format ">>,>>9.99"
                with frame frame-a 10 down width 80
                row 6 overlay.
    pause 0.
    recatu1 = recid(tt-tit).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-tit where
                true.
        if not available tt-tit
        then do:
        recatu1 = ?.
        leave.
        end.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        
    
        find tt-titulo where recid(tt-titulo) = tt-tit.rec no-lock.
    
        display tt-tit.etbcod 
                tt-titulo.titnum 
                tt-titulo.titpar 
                tt-titulo.titdtven 
                tt-tit.dias  when tt-tit.dias > 0 
                tt-titulo.titvlcob 
                tt-tit.juro  
                tt-tit.vtot 
                tt-tit.vacu 
                    with frame frame-a.

    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-tit where recid(tt-tit) = recatu1.
        
        /***/
        choose field tt-tit.etbcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        /***/
        
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
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
                esqpos1 = if esqpos1 = 2
                          then 2
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-tit where true no-error.
                if not avail tt-tit
                then leave.
                recatu1 = recid(tt-tit).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-tit where true no-error.
                if not avail tt-tit
                then leave.
                recatu1 = recid(tt-tit).
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
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-tit where
                true no-error.
            if not avail tt-tit
            then next.
            color display normal
                tt-tit.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-tit where
                true no-error.
            if not avail tt-tit
            then next.
            color display normal
                tt-tit.etbcod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame f-tot no-pause.
            leave bl-princ.
        end.    
        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
            end.

            hide frame f-consulta.
            if esqcom1[esqpos1] = "Nota Fiscal"
            then do with frame f-consulta overlay row 6 down centered.
                find tt-titulo where recid(tt-titulo) = tt-tit.rec no-lock.

                find contrato where contrato.contnum = int(tt-titulo.titnum)
                                                no-lock no-error.
                if not avail contrato
                then do:
                    message "Contrato nao encontratdo".
                    undo, retry.
                end.
                
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
                hide frame f-nota .
                hide frame fmov.
                hide frame f-consulta.                
                                                
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
            end.
            if esqcom1[esqpos1] = "     Listagem"
            then do:
            end.

          end.
          else do:
          end.
          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
    
        find tt-titulo where recid(tt-titulo) = tt-tit.rec no-lock.
    
        display tt-tit.etbcod 
                tt-titulo.titnum  
                tt-titulo.titpar  
                tt-titulo.titdtven 
                tt-tit.dias when tt-tit.dias > 0  
                tt-titulo.titvlcob  
                tt-tit.juro   
                tt-tit.vtot  
                tt-tit.vacu with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-tit).
   end.
end.
