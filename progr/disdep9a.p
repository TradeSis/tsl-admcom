def input parameter vprocod like produ.procod.
def input parameter vfabcod like fabri.fabcod.
def input parameter estoque-total like estoq.estatual.

def input parameter v-dtvenini as date format "99/99/9999".
def input parameter v-dtvenfin as date format "99/99/9999".

def shared var vlote as int.

def var fila as char.
def var recimp as recid.

def var varquivo as char.
def var vpednum like pedid.pednum.
def shared temp-table tt-produ
    field procod like produ.procod.

def shared temp-table tt-cla
    field clacod like clase.clacod
    field clanom like clase.clanom
        index iclase is primary unique clacod.

def shared var v-empty as int.
def shared var v-full as int.

def shared temp-table tt-estab
    field etbcod   like estab.etbcod
    field estatual like estoq.estatual
    field estatual-geral like estoq.estatual
    field qtd-cal  as dec 
    field saldo    as dec
    field per-ori  as dec
    field qtd-dis  as int
    field per-cal  as dec
    field crijaime as dec
    field per-vir  as dec
    index iestab crijaime desc
                 per-ori  desc
                 saldo    desc
                 estatual.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Imprimir "," "," "," "," "].
def var esqcom2         as char format "x(12)" extent 5
    initial [" "," "," "," "," "].
def var esqhel1         as char format "x(80)" extent 5
    initial [" "," "," "," "," "].
def var esqhel2         as char format "x(12)" extent 5
   initial [" "," "," "," "," "].

{admcab.i}

def buffer btt-estab for  tt-estab.
def var vtt-estab    like tt-estab.etbcod.

form
    esqcom1
    with frame f-com1
                 no-box no-labels side-labels column 1 centered.
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
        find tt-estab where recid(tt-estab) = recatu1 no-lock.
        
    if not available tt-estab
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-estab).
    
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-estab
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
            find tt-estab where recid(tt-estab) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-estab.etbcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-estab.etbcod)
                                        else "".
            run color-message.
            choose field tt-estab.etbcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) /*color white/black*/.
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
                    if not avail tt-estab
                    then leave.
                    recatu1 = recid(tt-estab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-estab
                    then leave.
                    recatu1 = recid(tt-estab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-estab
                then next.
                color display white/red 
                    tt-estab.etbcod 
                    tt-estab.estatual 
                    
                    tt-estab.qtd-cal
                    tt-estab.qtd-dis
                    /***tt-estab.saldo
                    tt-estab.per-ori
                    tt-estab.per-cal
                    tt-estab.crijaime***/
                    
                    with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-estab
                then next.
                color display white/red 
                    tt-estab.etbcod 
                    tt-estab.estatual 
                    tt-estab.qtd-cal
                    tt-estab.qtd-dis
                    /***tt-estab.saldo
                    tt-estab.per-ori
                    tt-estab.per-cal
                    tt-estab.crijaime***/ with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-estab
                 with frame f-tt-estab color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-estab on error undo.
                    create tt-estab.
                    update tt-estab.
                    recatu1 = recid(tt-estab).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-estab.
                    disp tt-estab.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-estab on error undo.
                    find tt-estab where
                            recid(tt-estab) = recatu1 
                        exclusive.
                    update tt-estab.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-estab.etbcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-estab where tt-estab.saldo > 0 no-error.
                    if not available tt-estab
                    then do:
                        find tt-estab where recid(tt-estab) = recatu1.
                        find prev tt-estab where tt-estab.saldo > 0 no-error.
                    end.
                    recatu2 = if available tt-estab
                              then recid(tt-estab)
                              else ?.
                    find tt-estab where recid(tt-estab) = recatu1
                            exclusive.
                    delete tt-estab.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Imprimir "
                then do with frame f-imprimir: 

                    varquivo = "/admcom/relat/disdep9" + string(time).
                    
                    /**
                    if setbcod = 995
                    then do:
        
        varquivo = "/admcom/relat/disdep9" + string(time).
                        
                        find first impress where 
                                   impress.codimp = setbcod no-lock no-error. 
                        if avail impress 
                        then do:  
                            run acha_imp.p (input recid(impress), 
                                            output recimp). 
                            find impress where 
                                 recid(impress) = recimp no-lock no-error.
                            assign fila = string(impress.dfimp).
                        end.    
                    
                    end.
                    else do:
                    if opsys = "UNIX"
                    then do:
                        varquivo = "/admcom/relat/disdep9" + string(time).
                        
                        find first impress where 
                                   impress.codimp = setbcod no-lock no-error. 
                        if avail impress 
                        then do:  
                            run acha_imp.p (input recid(impress), 
                                            output recimp). 
                            find impress where 
                                 recid(impress) = recimp no-lock no-error.
                            assign fila = string(impress.dfimp).
                        end.    
                    end.    
                    else varquivo = "l:\relat\disdep9" + string(time).
                    end.
                    ***/

                    find produ where produ.procod = vprocod no-lock.
 
                    {mdad.i
                        &Saida     = "value(varquivo)"
                        &Page-Size = "0"
                        &Cond-Var  = "90"
                        &Page-Line = "0"
                        &Nom-Rel   = ""disdep9a""
                        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
                        &Tit-Rel   = """PRODUTO: "" + 
                                      string(produ.procod,"">>>>>9"") + 
                                      "" - "" + produ.pronom"
                        &Width      = "90"
                        &Form       = "frame f-cabcab"}
                        
                    find fabri where fabri.fabcod = vfabcod no-lock no-error.
                    if not avail fabri
                    then 
                        put "Fabricante.....:" vfabcod " Geral".
                    else    
                        put "Fabricante.....:" vfabcod " " fabri.fabnom.
                    
                    put skip 
                            "Lote...........:" vlote format ">>>9". 
                    
                    if v-dtvenini <> ? and
                       v-dtvenfin <> ?
                    then
                    put skip(1)
                            "Periodo de Venda" skip
                            "Dt.Inicial.....:" v-dtvenini skip
                            "Dt.Final.......:" v-dtvenfin skip(1).

                    for each tt-cla:
                        disp tt-cla.clacod 
                             tt-cla.clanom no-label
                             estoque-total label "Estoque Calculado"
                                with frame f-cla centered side-label.
                    end.

                    for each tt-produ:

                        if tt-produ.procod = vprocod
                        then next.
                    
                        find produ where produ.procod = tt-produ.procod no-lock.
                        display produ.procod
                                produ.pronom 
                                    with frame f-title down centered.
                                    
                                    
                    end.

                    
                    for each tt-estab where tt-estab.etbcod <> 0 and
                                            tt-estab.qtd-dis > 0
                                      by tt-estab.etbcod 
                                      by tt-estab.crijaime desc
                                      by tt-estab.per-ori  desc 
                                      by tt-estab.saldo    desc
                                      by tt-estab.estatual:
                    
                        if tt-estab.estatual < tt-estab.qtd-cal and v-empty > 0
                        then do:

                            if v-empty < (tt-estab.qtd-cal - tt-estab.estatual)
                            then do:

                                tt-estab.qtd-dis = v-empty.
                                v-full = v-full + v-empty.
                                v-empty = 0.
                
                            end.
                            else do:
    
                                tt-estab.qtd-dis = tt-estab.qtd-cal - 
                                                   tt-estab.estatual.
                                v-empty = v-empty - tt-estab.qtd-dis.
                                v-full  = v-full + tt-estab.qtd-dis.

                            end.
        
                        end.
        
                        disp tt-estab.etbcod column-label "Filial" format ">>9"
                             tt-estab.qtd-dis(total)   
                                column-label "Enviado"    format ">>>9.99"
                             "   "   
                             tt-estab.estatual(total)  
                                column-label "Estoque"    format ">>>>9.99" 
                             tt-estab.qtd-cal(total)
                                column-label "Calculado"  format ">>>9.99"
                             /****
                             tt-estab.saldo(total)
                                 column-label "Dif"        format "->>9.99"
                             tt-estab.per-ori(total) 
                                 column-label "1o. Per" format ">>9.99"
                             tt-estab.per-cal(total) 
                                 column-label "2o. Per" format ">>9.99"
                             tt-estab.crijaime(total) 
                                 column-label "Crit" format "->>9.99"
                             ***/    
                                     with frame f-disp centered down.
              
                        /*
                        vpednum = 0.
                        find last pedid use-index ped 
                                  where pedid.etbcod = tt-estab.etbcod and 
                                        pedid.pedtdc = 5  no-lock no-error.
                        if not avail pedid
                        then vpednum = 1.
                        else vpednum = pedid.pednum + 1.
                                        
                        
                        find dispro where dispro.etbcod = tt-estab.etbcod and
                                          dispro.pednum = vpednum         and
                                          dispro.procod = vprocod no-error.
                        if not avail dispro
                        then do transaction:
                            create dispro.
                            assign dispro.etbcod = tt-estab.etbcod
                                   dispro.pednum = vpednum
                                   dispro.disdat = today
                                   dispro.procod = vprocod
                                   dispro.disqtd = tt-estab.qtd-dis * vlote
                                   dispro.disest = tt-estab.estatual 
                                   dispro.datexp = today.
                                   
                        end.
                        */
 
                    
                    
                    end.
    
                    
                    
                    output close.

                    /*if setbcod = 995
                    then os-command silent lpr value(fila + " " + varquivo).
                    else*/ do:
                    if opsys = "UNIX"
                    then do:
                         /*os-command silent lpr value(fila + " " + varquivo).
                         */
                        run visurel.p (input varquivo, input "").
                    end.    
                    else {mrod.i}.
                    end.
                    
                    leave.
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
        recatu1 = recid(tt-estab).
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
display tt-estab.etbcod   column-label "Filial"     format ">>9"
        tt-estab.estatual column-label "Estoque"    format ">>>>9.99"
        tt-estab.qtd-cal  column-label "Calculado"  format ">>>9.99"
        tt-estab.qtd-dis  column-label "Enviado"    format ">>>9.99"
        /***
        tt-estab.saldo    column-label "Dif"        format "->>9.99"
        tt-estab.per-ori  column-label "1§ Per"     format ">>9.99"
        tt-estab.per-cal  column-label "2§ Per"     format ">>9.99"
        tt-estab.crijaime column-label "Crit"       format "->>9.99"
        ***/
        with frame frame-a  width 80 color white/red 8 down overlay.
end procedure.

procedure color-message.
color display message
        tt-estab.etbcod   column-label "Filial"     format ">>9"
        tt-estab.estatual column-label "Estoque"    format ">>>>9.99"
        tt-estab.qtd-cal  column-label "Calculado"  format ">>>9.99"
        tt-estab.qtd-dis  column-label "Enviado"    format ">>>9.99"
        /***
        tt-estab.saldo    column-label "Dif"        format "->>9.99"
        tt-estab.per-ori  column-label "1§ Per"     format ">>9.99"
        tt-estab.per-cal  column-label "2§ Per"     format ">>9.99"
        tt-estab.crijaime column-label "Crit"       format "->>9.99"
        ***/
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        tt-estab.etbcod   column-label "Filial"     format ">>9"
        tt-estab.estatual column-label "Estoque"    format ">>>>9.99"
        tt-estab.qtd-cal  column-label "Calculado"  format ">>>9.99"
        tt-estab.qtd-dis  column-label "Enviado"    format ">>>9.99"
        /***
        tt-estab.saldo    column-label "Dif"        format "->>9.99"
        tt-estab.per-ori  column-label "1§ Per"     format ">>9.99"
        tt-estab.per-cal  column-label "2§ Per"     format ">>9.99"
        tt-estab.crijaime column-label "Crit"       format "->>9.99"
        ***/
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-estab where true /* tt-estab.saldo > 0 */
                                                no-lock no-error.
    else  
        find last tt-estab  where true /* tt-estab.saldo > 0 */
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-estab  where true /* tt-estab.saldo > 0 */
                                                no-lock no-error.
    else  
        find prev tt-estab  where true /* tt-estab.saldo > 0 */
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-estab where true /* tt-estab.saldo > 0 */
                                        no-lock no-error.
    else   
        find next tt-estab where true /* tt-estab.saldo > 0 */
                                        no-lock no-error.
        
end procedure.
         
