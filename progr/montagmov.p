/* helio 15122021 - ID 86485 regra sempre pegar tabela de preco */
/* helio 15122021 - ID 87016 retirar pesquisas, mudar defaullt */
/* helio 15122021 - ID 87021 pesquisa montagem por nota e produto */


{admcab.i}
def input param par-etbcod like estab.etbcod.
def input param par-dtini  as date.
def var prec as recid.

def var aux-mondat  like monmov.mondat no-undo.
def var aux-moncod  like monmov.moncod no-undo.
def var aux-montcod like monmov.montcod no-undo.
def var aux-emite   like monmov.emite no-undo.
def var aux-monser  like monmov.monser no-undo.
def var aux-monnot  like monmov.monnot no-undo.
def var vmovqtm as int.

def var vqtd-promon like movim.movqtm.
def buffer cmonmov for monmov.
def buffer b-matriz-plani for plani.
def buffer b-matriz-movim for movim.

def buffer bestab      for estab.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Consulta "," Procura ","Montadores"].
def var esqcom2         as char format "x(12)" extent 5.
if setbcod = 999
then do:
    esqcom1[2] = " Exclusao".
    esqcom2[2] = " ExcMonArq".
end.

def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao     de Montagem ",
             " Alteracao    de Montagem ",
             " Cancelamento de Montagem ",
             " Consulta     de Montagem ",
             " "].
def var esqhel2         as char format "x(12)" extent 5.

def var vetbcod-nf like monmov.etbcod.
def var vnumero-nf as integer.
def var vprocod-nf like monmov.procod.
def var vcont as int.

def temp-table tt-monmov no-undo
    like monmov .
def buffer bmonmov       for monmov.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

    form monmov.etbcod    column-label "Fil" format ">>9"
            monmov.mondat    column-label "Data" format "999999"
            adm.montagem.monnom  column-label "Montagem" format "x(15)"
            adm.montador.montnom column-label "Montador" format "x(17)"
            monmov.monnot    column-label "Num. NF"
            monmov.monser    column-label "Ser" format "x(03)"
            monmov.procod    column-label "Produto"
            monmov.movpc     column-label "Valor" format ">>>>9.99"
            with frame frame-a 11 down centered row 6 no-box.


def temp-table tt-excmonarq like monmov.

def temp-table tt-ema
    field etbcod like plani.etbcod 
    field mondat like monmov.mondat
    field monnot like monmov.monnot
    field monser like monmov.monser
    field procod like monmov.procod
    field wrec as recid
    index i1 etbcod mondat
    .

def var varquivo as char format "x(65)".
def var varqaux  as char format "x(65)".
def var varqlog as char.
def var vexcmonarq as log format "Sim/Nao".
def var vqtdema as int.
def var vqexc as int.
def var varqinvalido as log.
def var vlinha as char extent 6.
def var vqlinha as int.
    
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find monmov where recid(monmov) = recatu1 no-lock.

    if not available monmov
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(monmov).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available monmov
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
            find monmov where recid(monmov) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(monmov.moncod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(monmov.moncod)
                                        else "".
            run color-message.
            choose field
                    monmov.etbcod 
                    adm.montagem.monnom 
                    adm.montador.montnom 
                    monmov.monnot 
                    monmov.monser
                    monmov.procod 
                    monmov.movpc help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) /*color white/black*/ .
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
                    if not avail monmov
                    then leave.
                    recatu1 = recid(monmov).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail monmov
                    then leave.
                    recatu1 = recid(monmov).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail monmov
                then next.
                color display white/red 
                         monmov.etbcod 
                         adm.montagem.monnom 
                         adm.montador.montnom 
                         monmov.monnot 
                         monmov.monser
                         monmov.procod 
                         monmov.movpc                
                         with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail monmov
                then next.
                color display white/red monmov.etbcod 
                    adm.montagem.monnom 
                    adm.montador.montnom 
                    monmov.monnot 
                    monmov.monser
                    monmov.procod 
                    monmov.movpc with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:                     
            form tt-monmov.etbcod label "Filial..."     colon 16       space(03)
                 estab.etbnom      no-label format "x(20)"
                 tt-monmov.mondat  label "Dt.Montagem" colon 65
                 tt-monmov.moncod label "Montagem."  format ">>>>>>>9" colon 16
                 adm.montagem.monnom no-label
                 tt-monmov.montcod label "Montador." format ">>>>>>>9" colon 16
                 adm.montador.montnom no-label
                 skip(1)
                 tt-monmov.emite   label "Loja NF.."  colon 16 space(03)
                 tt-monmov.monnot  label "Numero NF" 
                 tt-monmov.monser  label "Serie NF" format "x(03)" colon 65
                 movim.movqtm label "Quantidade NF"    colon 65
                 
                 skip(1)
                 tt-monmov.procod  label "Produto.." colon 16
                 produ.pronom      no-label  
                 tt-monmov.movpc   label "Valor..."  format ">>,>>9.99" colon 16
                 vmovqtm label "Qtd Montagens"    colon 65

                 with frame f-monmov-i color black/cyan
                      centered side-label row 5 .

            form monmov.etbcod label "Filial..."     colon 16       space(03)
                 estab.etbnom      no-label format "x(20)"
                 monmov.mondat  label "Dt.Montagem" colon 65
                 monmov.moncod label "Montagem."  format ">>>>>>>9" colon 16
                 adm.montagem.monnom no-label
                 monmov.montcod label "Montador." format ">>>>>>>9" colon 16
                 adm.montador.montnom no-label
                 skip(1)
                 monmov.emite   label "Loja NF.."  colon 16 space(03)
                 monmov.monnot  label "Numero NF" 
                 monmov.monser  label "Serie NF" format "x(03)" colon 65
                 movim.movqtm label "Quantidade NF"    colon 65
                 
                 skip(1)
                 monmov.procod  label "Produto.." colon 16
                 produ.pronom      no-label  
                 monmov.movpc   label "Valor..."  format ">>,>>9.99" colon 16
                 vmovqtm label "Qtd Montagens"    colon 65


                 with frame f-monmov color black/cyan
                      centered side-label row 5.

            hide frame frame-a no-pause.
            
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = "Montadores" 
                then do with frame f-cons-mont.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame frame-a no-pause.
                    
                    run cons-mont.p.
                    
                    view frame f-com1. pause 0.
                    view frame f-com2. pause 0.
                    view frame frame-a. pause 0. 
                end.
                
                if esqcom1[esqpos1] = " Procura " 
                then do with frame f-procura centered overlay
                            side-labels row 8 on error undo.
                    
                    view frame frame-a. pause 0.
                    /* helio 15122021 - ID 87021 pesquisa montagem por nota e produto */

                    update 
                           vetbcod-nf label "Loj Nf"    format ">>9" 
                           vnumero-nf label "Numero NF" format ">>>>>>9" 
                           vprocod-nf label "Produto..".

                    find first bmonmov where 
                               bmonmov.emite = vetbcod-nf and 
                               bmonmov.monnot = vnumero-nf and
                               bmonmov.procod = vprocod-nf 
                                                         no-lock no-error.
                    if not avail bmonmov 
                    then do:
                        message "Montagem nao encontrada.". pause 1.  
                        undo. 
                    end. 
                    hide frame f-procura.
                    recatu1 = recid(bmonmov). 
                    leave.
                end.
                
                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-monmov-i 
                    on error undo.
                    
                    assign aux-mondat  = ? 
                            aux-moncod  = 0 
                            aux-montcod = 0 
                            aux-emite   = 0 
                            aux-monser  = "V" 
                            aux-monnot  = 0.

                    repeat with frame f-monmov-i:
                        for each tt-monmov. delete tt-monmov. end.

                        create tt-monmov.
                        assign tt-monmov.mondat  = today
                               tt-monmov.moncod  = aux-moncod
                               tt-monmov.montcod = aux-montcod 
                               tt-monmov.emite   = aux-emite
                               tt-monmov.monser  = aux-monser
                               tt-monmov.monnot  = aux-monnot.

                        if par-etbcod = 0
                        then do:
                            update tt-monmov.etbcod go-on(tab).

                            if keyfunction(lastkey) = "TAB"  and setbcod = 999
                            then do:
                                esqregua = no.
                                esqpos2 = 2.
                                color display normal esqcom1[esqpos1] with frame f-com1.
                                color display message esqcom2[esqpos2] with 
frame f-com2.
                                choose field esqcom2[esqpos2] with
                                    frame f-com2.
                                leave.
                            end.    
                               
                        end. 
                        else  tt-monmov.etbcod  = par-etbcod.

                        vmovqtm = 1.
                        
                        find estab where estab.etbcod = tt-monmov.etbcod no-lock.

                        disp tt-monmov.mondat skip
                             tt-monmov.etbcod
                             estab.etbnom no-label skip.
                    
                        update tt-monmov.moncod go-on(TAB).
                        if keyfunction(lastkey) = "TAB"  and setbcod = 999
                        then do:
                            esqregua = no.
                            esqpos2 = 2.
                            
                            color display normal esqcom1[esqpos1] with
frame f-com1.
                            color display message esqcom2[esqpos2] with
frame f-com2.
                            choose field esqcom2[esqpos2] with frame f-com2.
                            leave.
                        end.
                        
                        aux-moncod = tt-monmov.moncod.

                        find adm.montagem where
                             montagem.moncod = tt-monmov.moncod 
                             no-lock no-error.
                        if not avail montagem
                        then do:
                            message color red/with
                                "Tipo de Montagem nao cadastrada"
                                view-as alert-box.
                            undo.
                        end.
                        else do:
                            if setbcod <> 999
                            then do:
                                if adm.montagem.situacao = no
                                then do:
                                    message color red/with
                                        "Tipo de Montagem desativada."
                                        view-as alert-box.
                                    undo.
                                end.
                            end.
                            disp montagem.monnom.
                        end.    
                    
                        if setbcod <> 999
                        then do:
                            find first monper  where
                                       monper.etbcod = par-etbcod and
                                       monper.moncod = tt-monmov.moncod and
                                       monper.situacao
                                   no-lock no-error.
                            if not avail monper
                            then do:
                                message color red/with
                                    "Tipo de Montagem indisponivel para filial"
                                    view-as alert-box.
                                undo.
                            end.           
                        end.
                    
                        update tt-monmov.montcod.
                        aux-montcod = tt-monmov.montcod.
                        
                        find adm.montador where 
                             montador.montcod  = tt-monmov.montcod and
                             montador.situacao
                             no-lock no-error.
                        if not avail montador
                        then do:
                            message "Montador nao cadastrado".
                            undo.
                        end.
                        else disp montador.montnom.
                        
                        if tt-monmov.moncod = 1 
                        then do:
                    
                            sresp = no.

                            /* helio 15122021 - ID 87016 retirar pesquisas, mudar defaullt
                            
                            *message "Pesquisar Nota?" update sresp.
                            *if sresp
                            *then do:
                            *    run selplani.p (input 5, output prec).
                            *    find plani where recid(plani) = prec no-lock no-error.
                            *    if avail plani
                            *    then do:
                            *        tt-monmov.monser = plani.serie.
                            *        tt-monmov.monnot = plani.numero.
                            *        tt-monmov.emite  = plani.emite.
                            *        aux-emite = tt-monmov.emite. 
                            *        aux-monnot = tt-monmov.monnot. 
                            *        aux-monser = tt-monmov.monser.
                            *        
                            *        disp   tt-monmov.monnot
                            *               tt-monmov.monser 
                            *               tt-monmov.emite.
                            *    
                            *    end.
                            *    else sresp = no.
                            *end.
                            */
                            
                            if sresp = no
                            then do:
                                update tt-monmov.emite.
                
                                find bestab where
                                     bestab.etbcod = tt-monmov.emite
                                     no-lock no-error.
                                if not avail bestab
                                then do:
                                    message "Filial nao cadastrada.".
                                    undo.
                                end.
                        
                                update tt-monmov.monnot
                                       tt-monmov.monser.
                                aux-emite = tt-monmov.emite. 
                                aux-monnot = tt-monmov.monnot. 
                                aux-monser = tt-monmov.monser.
            
                            end.
                            
                            /** helio 20072021*/
                            
                            if not avail plani
                            then do:
                                find last plani
                                where plani.movtdc = 5 
                                  and plani.etbcod = tt-monmov.emite
                                  and plani.emite  = tt-monmov.emite
                                  and plani.serie  = tt-monmov.monser
                                  and plani.numero = tt-monmov.monnot 
                                              no-lock no-error.
                                if not avail plani
                                then do:
                                    find last plani
                                    where plani.movtdc = 81 
                                      and plani.etbcod = tt-monmov.emite
                                      and plani.emite  = tt-monmov.emite
                                      and plani.serie  = tt-monmov.monser
                                      and plani.numero = tt-monmov.monnot 
                                                  no-lock no-error.
                                end.
                                               
                            end.

                            if not avail plani 
                            then do: 
                                message "Nota Fiscal nao encontrada.". 
                                pause 3 no-message. 
                                undo.
                            end.   
                            else do:
                                aux-emite = tt-monmov.emite. 
                                aux-monnot = tt-monmov.monnot. 
                                aux-monser = tt-monmov.monser.

                                if (today - plani.pladat) > 90
                                then do:
                                    sresp = yes.
                                    message "Nota Fiscal emitida a mais de 3 meses."
                                            "Continuar? "
                                            update sresp.
                                    if not sresp
                                    then undo.
                                end.
                                
                                update tt-monmov.procod.
                                find produ where produ.procod = tt-monmov.procod no-lock no-error.
                                if not avail produ
                                then do:
                                    message "Produto nao cadastrado".
                                    undo.
                                end.
                                disp produ.pronom.
                                
                                if produ.protam = "NAO" or
                                   produ.protam = ""
                                then do:
                                    message "Produto nao esta cadastrado p/ Montagem".
                                    undo.
                                end. 
                                
                                find first movim
                                   where movim.etbcod = plani.etbcod
                                     and movim.placod = plani.placod
                                     and movim.movtdc = plani.movtdc
                                     and movim.movdat = plani.pladat
                                     and movim.procod = tt-monmov.procod
                                                              no-lock no-error.
                                if not avail movim
                                then do:
                                    message "Produto nao cadastrado na nota " tt-monmov.monnot.
                                    undo.
                                end.                                  
                               
                                tt-monmov.movpc = movim.movpc.
                               
                               
                                disp tt-monmov.movpc.
                                disp movim.movqtm.
                               
                                vqtd-promon = 0.
                                for each cmonmov where 
                                         cmonmov.emite  = plani.emite and
                                         cmonmov.monnot = plani.numero and
                                         cmonmov.monser = plani.serie and
                                         cmonmov.procod = tt-monmov.procod
                                         no-lock.
                                    vqtd-promon = vqtd-promon + 1.
                                end.         
                                vmovqtm = movim.movqtm - vqtd-promon.
                                disp vmovqtm.                                
                                if vqtd-promon > 0
                                then do:
                                    message "Ja existem " vqtd-promon "montagens para o produto" tt-monmov.procod .
                                    message "Quantidade na nota " plani.numero " eh " movim.movqtm.
                                    if vqtd-promon >= movim.movqtm
                                    then do: 
                                        message "Todas as quantidades do produto na Nota ja incluidas na montagem."         
                                            view-as alert-box.
                                        undo.    
                                    end.   
                                end.
                                def var auxmovqtm as int.
                                auxmovqtm = vmovqtm.
                                update vmovqtm validate(vmovqtm > 0 and vmovqtm <= auxmovqtm,"Quantidade errada").
                                
                            end.        
                            /** helio 20072021*/
                        end.
                        else do:
                            aux-emite   = 0.
                            aux-monser  = "". 
                            aux-monnot  = 0.
                            tt-monmov.emite     = aux-emite.
                            tt-monmov.monser    = aux-monser.
                            tt-monmov.monnot    = aux-monnot.
                            
                            
                            update tt-monmov.procod.
                    
                            find produ where produ.procod = tt-monmov.procod
                                                  no-lock no-error.
                            if not avail produ
                            then do:
                                message "Produto nao cadastrado".
                                undo.
                            end.
                            if produ.protam = "NAO" or
                               produ.protam = ""
                            then do:
                                message "Produto nao esta cadastrado p/ Montagem".
                                undo.
                            end.
                            disp produ.pronom.
                    
                            if setbcod <> 999
                            then do:
                                if montagem.moncod = 2 and par-etbcod <> 65
                                then do:
                                    if produ.catcod = 31
                                    then
                                        find first produaux where
                                         produaux.nome_campo  = "Mix" and
                                         produaux.valor_campo = string(par-etbcod,"999") + ",Sim"
                                          no-lock no-error.
                                    if avail produaux
                                    then do:
                                        find first produaux where
                                        produaux.procod      = produ.procod and
                                        produaux.nome_campo  = "Mix" and
                                        produaux.valor_campo = 
                                                            string(par-etbcod,"999") + ",Sim"
                                        no-lock no-error.
                                
                                        if not avail produaux
                                        then do:
                                            message color red/with
                                            "Na„ foi possiÌvl incluir montagem para mostru·rio de produo fora do MIX." view-as alert-box.
                                            undo.
                                        end.
                                    end.
                                end.
                            end.

                            if tt-monmov.moncod >= 2
                            then do:
                                
                                if montagem.moncod = 2 /* Loja */
                                then do:
                                    find last movim where
                                              movim.procod = tt-monmov.procod   
                                          and movim.movdat >= (today - 45)
                                          no-lock no-error.
                                    if not avail movim
                                    then do: 
                                        message "Produto sem movimentacao (45 dias)". 
                                    end.
                                end.
                                
                                find first estoq where
                                               estoq.procod = tt-monmov.procod
                                            and estoq.etbcod = 1
                                            and estoq.estvenda > 0
                                                no-lock no-error.
                                if not avail estoq
                                then   find first estoq where
                                              estoq.procod = tt-monmov.procod
                                            and estoq.estvenda > 0
                                                no-lock no-error.
                                                
                                tt-monmov.movpc = if avail estoq
                                                  then estoq.estvenda
                                                  else 0.
                            end.
                            
                        end.
                                    
                        disp tt-monmov.movpc.
                        
                        if tt-monmov.movpc = 0
                        then update tt-monmov.movpc.
                        
                        sresp = yes.
                        message "Confirma a inclusao de montagem?" update sresp.
                        if not sresp 
                        then do:
                            recatu1 = ?.
                            leave.
                        end.
                        else do:
                            vcont = 0.
                            do vcont = 1 to vmovqtm:
                                create monmov.
                                buffer-copy tt-monmov to monmov.
                                recatu1 = recid(monmov).
                            end.
                        end.

                        sresp = no.
                        if tt-monmov.moncod = 1
                        then message "Mais algum produto para mesma Nota Fiscal?" update sresp.
                        else sresp = no.
                        
                        if not sresp
                        then do:
                            recatu1 = ?.
                            leave.
                        end.    
                        else
                            assign aux-mondat  = tt-monmov.mondat
                                   aux-moncod  = tt-monmov.moncod 
                                   aux-montcod = tt-monmov.montcod 
                                   aux-emite   = tt-monmov.emite
                                   aux-monser  = tt-monmov.monser 
                                   aux-monnot  = tt-monmov.monnot.
                    end. /*repeat */
                    leave.
                end. /* inclusao */
                
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-monmov.
                    find estab where estab.etbcod = monmov.etbcod
                                        no-lock no-error.
                    find adm.montagem where
                         montagem.moncod = monmov.moncod
                                                no-lock no-error.
                    find adm.montador where 
                         montador.montcod = monmov.montcod
                                                no-lock no-error.
                    if monmov.moncod = 1
                    then do:
                                find last plani
                                where plani.movtdc = 5 
                                  and plani.etbcod = monmov.emite
                                  and plani.emite  = monmov.emite
                                  and plani.serie  = monmov.monser
                                  and plani.numero = monmov.monnot 
                                              no-lock no-error.
                                if not avail plani
                                then do:
                                    find last plani
                                    where plani.movtdc = 81 
                                      and plani.etbcod = monmov.emite
                                      and plani.emite  = monmov.emite
                                      and plani.serie  = monmov.monser
                                      and plani.numero = monmov.monnot 
                                                  no-lock no-error.
                                end.

                        find first movim
                                   where movim.etbcod = plani.etbcod
                                     and movim.placod = plani.placod
                                     and movim.movtdc = plani.movtdc
                                     and movim.movdat = plani.pladat
                                     and movim.procod = monmov.procod
                                     no-lock.
                    end.
                    find produ of monmov no-lock.
                    disp produ.pronom.                                    
                    disp monmov.mondat.
                    disp estab.etbnom no-label.
                    disp montagem.monnom no-label.
                    disp montador.montnom no-label.
                    disp monmov except aux.
                    if avail movim
                    then disp movim.movqtm.
                    disp 1 @ vmovqtm.
                end.
                
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-monmov on error undo.
                    message "Exclua na Matriz, para poder incluir novamente.".
                    pause 3.
                    leave.
                end.
                if esqcom1[esqpos1] = " Exclusao " and setbcod = 999
                then do with frame f-exc on error undo.
                
                    message "Confirma Exclusao de" monmov.moncod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    
                    find next monmov where true no-error.
                    if not available monmov
                    then do:
                        find monmov where recid(monmov) = recatu1.
                        find prev monmov where true no-error.
                    end.
                    recatu2 = if available monmov
                              then recid(monmov)
                              else ?.
                    
                    find monmov where recid(monmov) = recatu1
                            exclusive.
                    
                    delete monmov.
                    
                    recatu1 = recatu2.
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
                
                if esqcom2[esqpos2] = " ExcMonArq" and setbcod = 999
                then leave bl-princ.
                    
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
        recatu1 = recid(monmov).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.

hide frame f-monmov-i no-pause.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.


if esqcom2[esqpos2] = " ExcMonArq"
then do with frame f-ema:
                    
    disp "Layout do arquivo = Filial NF;Data Montagem;Numero NF;Serie NF;produto" skip.
    disp "Exemplo Informar  = L:/relat/arquivo.csv  ou /admcom/
relat/arquivo.csv" skip.
    
    update 
        skip(1) 
            varqaux label "Arquivo"
            help "Informe o nome e o caminho do arquivo."
            with 1 down  side-label row 8 overlay
            title " Exclusao de MONTAGEM por arquivo "
            .
                
    varquivo = replace(varqaux,"L:","/admcom").
    varquivo = replace(varquivo,"~\","/").

    varqlog = "/admcom/relat/log-excmonarq." + string(time).
                    
    if varquivo <> "" and search(varquivo) <> ?
    then do:
        varqinvalido = no.
        vqlinha = 0.
        vlinha = "".
        input from value(varquivo).
        repeat:
            import delimiter ";" vlinha.
            vqlinha = vqlinha + 1.
            if vlinha[1] = "" or vlinha[2] = "" or 
               vlinha[3] = "" or vlinha[4] = "" or
               vlinha[5] = "" or vlinha[6] <> ""
            then do:
                varqinvalido = yes.
                leave.
            end.
            else do:
                create tt-ema.
                tt-ema.etbcod = int(vlinha[1]).
                tt-ema.mondat = date(vlinha[2]).
                tt-ema.monnot = int(vlinha[3]).
                tt-ema.monser = vlinha[4].
                tt-ema.procod = int(vlinha[5]).
             end.    
        end.    
        input close.

        if varqinvalido
        then do:
            message "Arquivo n√£o esta no layout corretoLinha " vqlinha.
            pause.
        end. 
        else do:    
            for each tt-ema where tt-ema.etbcod <> 0 no-lock:
                find first bmonmov where
                       bmonmov.emite = tt-ema.etbcod and
                       bmonmov.mondat = tt-ema.mondat and
                       bmonmov.monnot = tt-ema.monnot and
                       bmonmov.monser = tt-ema.monser and
                       bmonmov.procod = tt-ema.procod
                       no-lock no-error.
                if not avail bmonmov
                then.
                else do:
                    tt-ema.wrec = recid(bmonmov).
                    vqtdema = vqtdema + 1.
                    create tt-excmonarq.
                    buffer-copy bmonmov to tt-excmonarq.
                end.
            end.
            if vqtdema = 0
            then do:
                message "Nenhum registro de montagem para exclus√£".
                pause.
            end.
            else do:
                message  "confirma excluir " vqtdema " registros do arquivo?"
                update vexcmonarq.
                if vexcmonarq
                then do :
                    vqexc = 0.
                    for each tt-excmonarq no-lock.
                        vqexc = vqexc + 1.
                        message "Aguarde excluindo" vqexc.   
                        pause 1. 
                        find first bmonmov where  
                                         bmonmov.emite  = tt-excmonarq.emite
                                     and bmonmov.mondat = tt-excmonarq.mondat
                                     and bmonmov.monnot = tt-excmonarq.monnot
                                     and bmonmov.monser = tt-excmonarq.monser 
                                     and bmonmov.procod = tt-excmonarq.procod
                                          no-error.
                        if avail bmonmov 
                        then do:
                            output to value(varqlog) append.
                            export bmonmov.
                            output close.
                                                
                            do on error undo:
                                delete bmonmov.         
                            end.
                        end.      
                    end.
                end.
            end.
        end.
    end.        
end.
return.


procedure frame-a.

    find adm.montagem where
         montagem.moncod = monmov.moncod no-lock no-error.
    find adm.montador where
         montador.montcod = monmov.montcod no-lock no-error.
         
    display monmov.etbcod   
            monmov.mondat   
            montagem.monnom  when avail montagem
            montador.montnom  when avail montador 
            monmov.monnot    
            monmov.monser  
            monmov.procod  
            monmov.movpc 
            with frame frame-a.
            
end procedure.
procedure color-message.
    find adm.montagem where
         montagem.moncod = monmov.moncod no-lock no-error.
    find adm.montador where
         montador.montcod = monmov.montcod no-lock no-error.

    color display message
            monmov.etbcod  
            montagem.monnom 
            montador.montnom 
            monmov.monnot  
            monmov.monser 
            monmov.procod   
            monmov.movpc  

            with frame frame-a.
end procedure.

procedure color-normal.
    find adm.montagem where
         montagem.moncod = monmov.moncod no-lock no-error.
    find adm.montador where
         montador.montcod = monmov.montcod no-lock no-error.

    color display normal
            monmov.etbcod  
            montagem.monnom 
            montador.montnom 
            monmov.monnot  
            monmov.monser
            monmov.procod  
            monmov.movpc 
            with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-etbcod = 0
then do:

    if par-tipo = "pri" 
    then  
        if esqascend  
        then      
            find first monmov where
                       monmov.mondat >= par-dtini
                       no-lock no-error.
        else  
            find last monmov  where
                      monmov.mondat >= par-dtini
                      no-lock no-error.
    if par-tipo = "seg" or par-tipo = "down" 
    then      
        if esqascend  
        then  
            find next monmov  where
                      no-lock no-error.
        else  
            find prev monmov  where
                      no-lock no-error.
    if par-tipo = "up" 
    then                  
        if esqascend   
        then   
            find prev monmov  where
                      no-lock no-error.
        else   
            find next monmov  where 
                  no-lock no-error.
end.
else do:

    if par-tipo = "pri" 
    then  
        if esqascend  
        then      
            find first monmov use-index i-etb-dat where
                        monmov.etbcod = par-etbcod and 
                       monmov.mondat >= par-dtini
                       no-lock no-error.
        else  
            find last monmov use-index i-etb-dat  where
                       monmov.etbcod = par-etbcod and 
                      monmov.mondat >= par-dtini
                      no-lock no-error.
    if par-tipo = "seg" or par-tipo = "down" 
    then      
        if esqascend  
        then  
            find next monmov  use-index i-etb-dat where
                       monmov.etbcod = par-etbcod 
                      no-lock no-error.
        else  
            find prev monmov  use-index i-etb-dat where
                       monmov.etbcod = par-etbcod 
                      no-lock no-error.
    if par-tipo = "up" 
    then                  
        if esqascend   
        then   
            find prev monmov use-index i-etb-dat where
                       monmov.etbcod = par-etbcod 
                      no-lock no-error.
        else   
            find next monmov use-index i-etb-dat where 
                       monmov.etbcod = par-etbcod 
                  no-lock no-error.
end.
 
end procedure.
         

