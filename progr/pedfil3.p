/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i }
def var varquivo as char.
def var fila as char.
def buffer bliped for liped.
def buffer cpedid for pedid.
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

def var wsep like liped.lipqtd.
def var wped like liped.lipqtd.
def var west like estoq.estatual format "->>>,>>9".
def buffer bfunc        for func.
def var recatu1         as recid.
def var reccont         as int.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Impressao"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bpedid            for pedid.
def buffer bestab            for estab.
def var vetbcod              like estab.etbcod.
def var vpednum              like pedid.pednum.
def var vpedtdc              like pedid.pedtdc.
def var vrecped              as recid.

    form forne.forcod      colon 18 label "Fornecedor"
         forne.fornom      no-label format "x(30)"
         forne.forcgc      colon 18
         forne.forinest    colon 50 label "I.E" format "x(17)"
         forne.forrua      colon 18 label "Endereco"
         forne.fornum
         forne.forcomp no-label
         forne.formunic   colon 18 label "Cidade"
         forne.ufecod   label "UF"
         forne.forcep      label "Cep"
         forne.forfone        colon 18 label "Fone"
         pedid.regcod    colon 18 label "Local Entrega"
         bestab.etbnom   no-label
         pedid.vencod    colon 18
         bfunc.funnom    no-label
         pedid.condat    colon 18
         pedid.peddti    colon 18 label "Prazo de Entrega"
         pedid.peddtf    label "A"
         pedid.crecod    colon 18 label "Prazo de Pagto"
         /* crepl.crenom    no-label */
         pedid.comcod    colon 18 label "Comprador"
         func.funnom                 no-label
         pedid.frecod    label "Transport." colon 18
         pedid.fobcif
         pedid.nfdes        colon 18 label "Desc.Nota"
         pedid.dupdes       label "Desc.Duplicata"
         pedid.acrfin       label "Acres. Financ."
          with frame f-dialogo color white/cyan overlay row 6
                                                     side-labels centered.
    form
        pedid.pedobs[1] at 1
        pedid.pedobs[2] at 1
        pedid.pedobs[3] at 1
        pedid.pedobs[4] at 1
        pedid.pedobs[5] at 1 with frame fobs color white/cyan overlay row 9
                                no-labels centered title "Observacoes".
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

    vpedtdc = 3 .

    find first pedid where pedid.pedtdc = vpedtdc 
                       and pedid.sitped <> "R" no-lock no-error.
    if not avail pedid then return.
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find first pedid where pedid.pedtdc = vpedtdc
                            and pedid.sitped <> "R" no-lock no-error.
    else
        find pedid where recid(pedid) = recatu1 no-lock no-error.
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
               run pedcomin.p ( input estab.etbcod,
                                output vrecped ).
        end.
    end.
    clear frame frame-a all no-pause.
    display pedid.etbcod
            pedid.pednum
            pedid.peddat
            pedid.sitped column-label "Sit"
            with frame frame-a 10 down centered color white/red.

    recatu1 = recid(pedid).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next pedid  where pedid.pedtdc = vpedtdc
                           and pedid.sitped <> "R" no-lock no-error. 
        if not available pedid
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.

        display pedid.etbcod
                pedid.pednum
                pedid.peddat
                pedid.sitped
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find pedid where recid(pedid) = recatu1 no-lock.

        on f7 recall.
        choose field pedid.pednum
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-up page-down  F7 PF7
                  tab PF4 F4 ESC return).

        color display white/red pedid.pednum.

        if keyfunction(lastkey) = "RECALL"
        then do WITH FRAME fproc centered row 7 color message overlay.
        pause 0.
            prompt-for pedid.pednum.
            find last pedid where pedid.pedtdc = vpedtdc and
                                  pedid.pednum = input pedid.pednum
                              and pedid.sitped <> "R" no-lock no-error.
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
            find next pedid where pedid.pedtdc = vpedtdc 
                              and pedid.sitped <> "R"  no-lock no-error.
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
            find prev pedid where pedid.pedtdc = vpedtdc
                              and pedid.sitped <> "R" no-lock no-error.
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
                find next pedid where pedid.pedtdc = vpedtdc 
                                  and pedid.sitped <> "R" no-lock no-error.
                if not avail pedid
                then leave.
                recatu1 = recid(pedid).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev pedid where pedid.pedtdc = vpedtdc 
                                  and pedid.sitped <> "R" no-lock no-error.
                if not avail pedid
                then leave.
                recatu1 = recid(pedid).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do .
        hide frame  frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "*Inclusao*"
            then do with frame f-inclui overlay row 9 1 column centered
                color black/cyan.
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.

                run pedcomin.p ( input estab.etbcod,
                              output vrecped ).
                recatu1 = vrecped.

                leave.
            end.
            if esqcom1[esqpos1] = "*Alteracao*"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run pedcomal.p ( input recid(pedid),
                                 output vrecped ).
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.

                display pedid.etbcod
                        pedid.pednum with frame f-tit
                                    centered side-label 
                                        color black/cyan row 4.

                for each liped of pedid no-lock.
                    find produ where produ.procod = liped.procod no-lock.
                    disp liped.procod
                         produ.pronom format "x(25)"
                         liped.lipcor format "x(15)"
                         liped.lippreco
                         liped.lipqtd column-label "Qtd.P" format ">>>9"
                         liped.lipent column-label "Qtd.E" format ">>>9"
                                with frame f-con 10 down row 7 centered
                                        color black/cyan title " Produtos ".
                end.
                pause.
                leave.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do on error undo 
                with frame f-exclui overlay row 9 1 column centered.
                    message "Confirma Exclusao de" pedid.pednum update sresp.
                    if not sresp
                    then undo.
                    find next pedid where pedid.pedtdc = vpedtdc no-error.
                    if not available pedid
                    then do:
                        find pedid where recid(pedid) = recatu1.
                        find prev pedid where pedid.pedtdc = vpedtdc no-error.
                    end.
                    recatu2 = if available pedid
                            then recid(pedid)
                            else ?.
                    find pedid where recid(pedid) = recatu1.
                    
                    for each liped of pedid.
                        liped.lipsit = "R".
                        if pedid.pednum >= 500000
                        then do :
                            find estoq where estoq.etbcod = 95
                                     and estoq.procod = liped.procod.
                            estoq.estpedcom = estoq.estpedcom - liped.lipqtd.
                        end.
                    end.
                    
                    pedid.pedobs[3] = pedid.pedobs[3]
                               + "|DATA_EXCLUSAO=" + string(today,"99/99/9999")
                               + "|HORA_EXCLUSAO=" + string(time,"HH:MM:SS")
                               + "|ETB_EXCLUSAO="  + string(setbcod)
                               + "|USUARIO_EXCLUSAO=" + string(sfuncod)
                               + "|PROG_EXCLUSAO=" + program-name(1)
                               + "|".
                    
                    pedid.sitped = "R".
                    recatu1 = recatu2.
                    leave.
            end.
            if esqcom1[esqpos1] = "Impressao"
            then do with frame f-Lista overlay row 9 1 column centered.
                message "Confirma Impressao do Pedido" update sresp.
                if not sresp
                then undo.
                for each wroma:
                    delete wroma.
                end.
                if opsys = "unix" 
                then varquivo = "/admcom/relat/pedfil" + string(time). 
                else varquivo = "l:\relat\pedfil" + string(time).
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

                find estab where estab.etbcod = pedid.etbcod no-lock.
                disp estab.etbcod
                     estab.etbnom no-label skip(1) with frame f-est side-label.
                
                do for cpedid transaction:
                    find first cpedid where recid(cpedid) = recid(pedid).
                    cpedid.sitped = "L". 
                end.
                
                for each liped where liped.pedtdc = pedid.pedtdc and
                                     liped.etbcod = pedid.etbcod and
                                     liped.pednum = pedid.pednum no-lock.

                    find produ of liped no-lock.
                    west = 0.
                    for each estoq where estoq.etbcod = setbcod and
                                         estoq.procod = produ.procod no-lock.
                        west = west + estoq.estatual.
                    end. 
                    
   /******* Colocar aqui a criacao do novo pedido caso nao tenha estoque ***/
   
                    if west < liped.lipqtd then do:
                    
                        find first xpedid where 
                                   xpedid.pedtdc = 3 and
                                   xpedid.sitped = "E" and
                                   xpedid.etbcod = pedid.etbcod and
                                   xpedid.pednum >= 100000
                                   no-lock no-error.
                                   
                        if not avail xpedid
                        then do:
                                   
                            find last ypedid where
                                      ypedid.pedtdc = 3 and
                                      ypedid.etbcod = pedid.etbcod and
                                      ypedid.pednum >= 100000
                                      no-error.
                            if avail ypedid
                            then vpednum = ypedid.pednum + 1.
                            else vpednum = 100000.
                                       
                            create xpedid.
                            assign xpedid.etbcod = pedid.etbcod
                                   xpedid.pedtdc = 3
                                   xpedid.peddat = today
                                   xpedid.pednum = vpednum
                                   xpedid.sitped = "E"
                                   xpedid.pedsit = yes.
                        end.               
                        else vpednum = xpedid.pednum.
                        find first xliped where
                                   xliped.etbcod = xpedid.etbcod and
                                   xliped.pedtdc = 3 and
                                   xliped.pednum = vpednum and
                                   xliped.procod = liped.procod and
                                   xliped.predt  = xpedid.peddat no-error.
                        if not avail xliped
                        then do:
                            create xliped.
                            assign xliped.pedtdc = liped.pedtdc
                                   xliped.pednum = vpednum
                                   xliped.procod = liped.procod
                                   xliped.lippreco = liped.lippreco
                                   xliped.lipsit = liped.lipsit
                                   xliped.predtf = xpedid.peddat
                                   xliped.predt  = xpedid.peddat
                                   xliped.lipcor = liped.lipcor and
                                   xliped.etbcod = liped.etbcod
                                   xliped.lipqtd = .
                                   
                                   
                    end.
                    
   /************************************************************************/                 
                    
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
                    
                    find produ where produ.procod = wroma.procod 
                                    no-lock no-error.
                    find unida where unida.unicod = produ.prouncom no-lock
                                                    no-error.
                    
                    disp wroma.setnom column-label "PAV" format "x(12)"
                         wroma.procod      
                         wroma.pronom      
                         unida.uninom column-label "Unidade!Compra"
                                format "x(15)" when avail unida
                         wroma.lipcor      
                         wroma.west column-label "Estoque" format "->>>,>>9"
                                           
                         wroma.wped column-label "Qtd.Pedida" format ">>>>>9"
                                           
                         "........." column-label "Qtd!Separada" skip(1)
                                with frame f-rom width 140 down.
                end.
                output close.

                if opsys = "unix"
                then do:
                find first impress where impress.codimp = setbcod 
                     no-lock no-error.
                if avail impress
                  then assign fila = string(impress.dfimp). 
                end.                    
                else assign fila = "". 

                if opsys = "unix" 
                then os-command silent lpr value(fila + " " + varquivo). 
                else os-command silent type value(varquivo) > prn.
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
        display pedid.etbcod
                pedid.pednum
                pedid.peddat
                pedid.sitped
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(pedid).
   end.
end.
 