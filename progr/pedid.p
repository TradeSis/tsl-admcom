{admcab.i}

def var varquivo as char.
def var fila as char.
def var recimp as recid.
def var wsep like liped.lipqtd.
def var wped like liped.lipqtd.
def var west like estoq.estatual format "->>>,>>9".

def temp-table wroma
    field pednum like liped.pednum
    field procod like produ.procod
    field pronom like produ.pronom
    field lipcor like liped.lipcor
    field west   like estoq.estatual format "->>>,>>9"
    field wped   like estoq.estatual
    field setcod like setdep.setcod
    field setnom like setdep.setnom
    field ordimp like setdep.ordimp.
    


def var recatu1         as recid.
def var reccont         as int.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Fecha Pedido"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

def input parameter par-pedtdc as char.

def buffer bpedid            for pedid.
def var vetbcod              like estab.etbcod.
def var vpednum              like pedid.pednum.
def var vpedtdc              like pedid.pedtdc.
def var vrecped              as recid.

    form
        esqcom1
            with frame f-com1 centered
                 row 4 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2 centered
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    status default "Situacao  [E]mitido [L]istado [F]echado [C]ancelado".
    pause 0.
    
    vpedtdc = integer(par-pedtdc).
    disp esqcom1 with frame f-com1.

    update vetbcod
    with frame fest centered color white/cyan side-labels no-box width 66 row 6.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame fest.

    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find last pedid  where pedid.etbcod = estab.etbcod and
                                pedid.pedtdc = vpedtdc no-error.
    else
        find pedid where recid(pedid) = recatu1.
    if not available pedid
    then do:
        message "Cadastro de pedidos Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 9 1 column centered
            color black/cyan.
               hide frame f-com1 no-pause.
               hide frame f-com2 no-pause.
               run pedin.p ( input estab.etbcod,
                             input  vpedtdc,
                             output vrecped).
        end.
    end.
    clear frame frame-a all no-pause.
    display pedid.pednum
            estab.etbcod
            estab.etbnom format "x(35)"
            pedid.peddat
            pedid.sitped column-label "Sit"
            with frame frame-a 10 down centered color white/red.

    recatu1 = recid(pedid).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find prev pedid  where pedid.etbcod = estab.etbcod and
                               pedid.pedtdc = vpedtdc.
        if not available pedid
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        display pedid.pednum
                help ""    
                estab.etbcod
                estab.etbnom
                pedid.peddat
                pedid.sitped
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find pedid where recid(pedid) = recatu1 no-lock.

        status default "Situacao  [E]mitido [L]istado [F]echado [C]ancelado".
        pause 0.

        on f7 recall.
        choose field pedid.pednum
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-up page-down F7 PF7
                  tab PF4 F4 ESC return).

        color display white/red pedid.pednum.

        if keyfunction(lastkey) = "RECALL"
        then do WITH FRAME fproc centered row 7 color message overlay.
        pause 0.
            prompt-for pedid.pednum.
            find last pedid where pedid.etbcod = estab.etbcod and
                                   pedid.pedtdc = vpedtdc and
                                   pedid.pednum = input pedid.pednum
                                                            no-lock no-error.
            if avail pedid
            then recatu1 = recid(pedid).
            leave.
        end.
        on f7 help.
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
                esqpos1 = if esqpos1 = 5
                          then 5
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
            find prev pedid where pedid.etbcod = estab.etbcod and
                                  pedid.pedtdc = vpedtdc no-lock no-error.
            if not avail pedid
            then next.
            color display white/red
                pedid.pednum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find next pedid  where pedid.etbcod = estab.etbcod and
                                   pedid.pedtdc = vpedtdc no-lock no-error.
            if not avail pedid
            then next.
            color display white/red
                pedid.pednum.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev pedid where pedid.etbcod = estab.etbcod and
                                      pedid.pedtdc = vpedtdc no-lock no-error.
                if not avail pedid
                then leave.
                recatu1 = recid(pedid).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next pedid where pedid.etbcod = estab.etbcod and
                                      pedid.pedtdc = vpedtdc no-lock no-error.
                if not avail pedid
                then leave.
                recatu1 = recid(pedid).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame  frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 9 1 column centered
                color black/cyan.
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run pedin.p ( input estab.etbcod,
                              input  vpedtdc,
                              output vrecped).

                recatu1 = vrecped.

                /*
                recatu1 = recid(pedid).
                */
                leave.
            end.

            if esqcom1[esqpos1] = "Alteracao"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run pedal.p ( input recid(pedid),
                              output vrecped ).
            end. 
            if esqcom1[esqpos1] = "Fecha Pedido"
            then do:
                find pedid where recid(pedid) = recatu1.
                message "Confirma Fechamento do Pedido: " pedid.pednum
                update sresp.
                if not sresp
                then undo, leave.
                for each liped of pedid:
                    liped.lipsit = "F".
                end. 
                pedid.sitped = "F".
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                leave.
            end.

            if esqcom1[esqpos1] = "Consulta"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                for each liped of pedid no-lock.
                    find produ where produ.procod = liped.procod no-lock.
                    disp liped.procod
                         produ.pronom format "x(30)"
                         liped.lipcor
                         liped.lipqtd column-label "Qtd.Ped" format ">>>9"
                         liped.lipent column-label "Qtd.Ent" format ">>>9"
                                with frame f-con 10 down row 7 centered
                                        color black/cyan title " Produtos ".
                end.
                pause.
                leave.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 9 1 column centered.
            
                if pedid.sitped = "xx"
                then do:
                    bell.
                    message "Pedido ja Entregue nao pode ser Excluido".
                    pause. leave.
                end.
                else do:
                    message "Confirma Exclusao de" pedid.pednum update sresp.
                    if not sresp
                    then undo.
                    find prev pedid where pedid.etbcod = estab.etbcod and
                                          pedid.pedtdc = vpedtdc no-error.
                    if not available pedid
                    then do:
                        find pedid where recid(pedid) = recatu1.
                        find next pedid where true no-error.
                    end.
                    recatu2 = if available pedid
                            then recid(pedid)
                            else ?.
                    find pedid where recid(pedid) = recatu1.
                    for each liped of pedid.
                        delete liped.
                    end.
                    delete pedid.
                    recatu1 = recatu2.
                    leave.
                end.
            end.
            if esqcom1[esqpos1] = "Impressao"
            then do with frame f-Lista overlay row 9 1 column centered.
                message "Confirma Impressao do Pedido" update sresp.
                if not sresp
                then undo.
                
                for each wroma:
                    delete wroma.
                end.
                
                if opsys = "UNIX"
                then do:
                    varquivo = "../relat/pedid." + string(time).

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
                else varquivo = "..\relat\pedid." + string(time).
                
                {mdadmcab.i
                &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "110"
                &Page-Line = "66"
                &Nom-Rel   = ""PEDID""
                &Nom-Sis   = """SISTEMA DE PEDIDOS"""
                &Tit-Rel   = """PEDIDO N. "" + string(pedid.pednum) "
                &Width     = "110"
                &Form      = "frame f-cabcab"}

                disp estab.etbcod
                     estab.etbnom no-label skip(1) with frame f-est side-label.

                for each liped where liped.pedtdc = pedid.pedtdc and
                                     liped.etbcod = pedid.etbcod and
                                     liped.pednum = pedid.pednum no-lock:
                               
                    find produ of liped no-lock.
                    west = 0.
                    for each estoq where estoq.etbcod = setbcod and
                                         estoq.procod = produ.procod no-lock.
                        west = west + estoq.estatual.
                    end. 
                    create wroma.
                    assign wroma.procod = produ.procod
                           wroma.pronom = produ.pronom
                           wroma.lipcor = liped.lipcor
                           wroma.wped   = liped.lipqtd
                           wroma.west   = west.
                    find first setdep use-index ind-2
                                where setdep.etbcod = setbcod and
                                      setdep.clacod = produ.clacod 
                                            no-lock no-error.
                    if avail setdep
                    then assign wroma.setcod = setdep.setcod
                                wroma.setnom = setdep.setnom
                                wroma.ordimp = setdep.ordimp.
                end.
                for each wroma by wroma.setcod
                               by wroma.ordimp
                               by wroma.pronom:

                    disp wroma.setnom column-label "PAV" format "x(12)"
                         wroma.procod      
                         wroma.pronom      space(3)
                         wroma.lipcor      
                         wroma.west column-label "Estoque" format "->>>,>>9"
                                           space(3)
                         wroma.wped column-label "Qtd.Pedida" format ">>>,>>9"
                                           space(3)
                         "........." column-label "Qtd.Separada" skip(1)
                                with frame f-rom width 140 down.
                end.

                if opsys = "UNIX"
                then os-command silent lpr value(fila + " " + varquivo).
                else {mrod.i}.
                
                output close.
                leave.
            end.

          end.
          else do:
            if esqcom2[esqpos2] = "Extrato"
            then do:
                message "Confirma Impressao do Extrato" update sresp.
                if not sresp
                then undo.
                run lextped5.p (input recid(pedid)).
                leave.
            end.
            if  esqcom2[esqpos2] = "Duplicacao"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run peddup.p (input recatu1).
                disp esqcom1 with frame f-com1.
            end.
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
          end.
          view frame frame-a.
          view frame fest.
        end.
          if keyfunction(lastkey) = "end-error"
          then do:
            view frame frame-a.
            view frame fest.
        end.
        display pedid.pednum
                estab.etbcod
                estab.etbnom
                pedid.peddat
                pedid.sitped
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(pedid).
   end.
end.
