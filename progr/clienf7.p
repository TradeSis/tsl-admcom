{admcab.i}
/*{dftempWG.i}*/

def new shared var sair-sem-gravar as log.
def new shared var tem-cpf-retornar as log. 
disable triggers for load of clien.
def var vcredito        as l format "Normal/Facil".
def var vfuncod         like func.funcod.
def var vok             as logical.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao"," ","Consulta","Procura"].
def var esqcom2         as char format "x(14)" extent 5
            initial ["Limite Credito","","","",""].

esqcom2[1] = "".

def var vopcao          as  char format "x(10)" extent 3
                 initial ["Por Codigo","Por Nome","Por CPF"] .
def buffer bclien       for clien.
def var vclicod         like clien.clicod.
def var vgera           like clien.clicod.
def var scli like clien.clicod.

form esqcom1
     with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
form esqcom2
     with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

def new shared var vciccgc like clien.ciccgc.

bl-princ:
repeat:
    form
        clien.clicod
        clien.clinom
        clien.tippes
        with frame frame-a 13 down centered color white/red.

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then do:
        if scli <> 0
        then find first clien where clien.clicod = scli no-error.
        else 
        find first clien where true use-index clien2 no-error.
    end.
    else find clien where recid(clien) = recatu1.

    vinicio = no.
    if not available clien
    then do on error undo:
        message "Cadastro de Clientes Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do on error undo with frame f-inclui1  row 4  centered 1 column overlay.
            do for geranum on error undo:
                    find geranum where geranum.etbcod = setbcod.
                    vgera = geranum.clicod.
                    assign geranum.clicod = geranum.clicod + 1.
                    find current geranum no-lock.
            end.
            do on error undo:
                create clien.
                /*
                if length(string(setbcod)) > 2
                then clien.clicod = int(string(setbcod,"999") + 
                                        string(vgera,"9999999")).
                else clien.clicod = int(string(vgera,"9999999") +
                                                 string(setbcod,"99")).
                */
                
                if setbcod >= 100
                then clien.clicod = int("1" + string(setbcod,"999") +
                                              string(vgera,"999999")).
                else clien.clicod = int(string(vgera,"9999999") +
                                               string(setbcod,"99")).
                
                display clien.clicod.
                update clien.clinom
                       clien.tippes.
            end.
            tem-cpf-retornar = no.
            sair-sem-gravar = no.
            run clioutb4.p (input recid(clien),
                            input "I",
                            input string(setbcod,"999")) .
            if sair-sem-gravar = yes
            then do:
                recatu1 = ? .
                next bl-princ.
            end.
            if tem-cpf-retornar = yes
            then do:
                delete clien.
                find first clien where clien.ciccgc = vciccgc no-lock .
                
            end.
            /*
            run clioutb4.p (input recid(clien), input "i", input setbcod) .
            */
            recatu1 = recid(clien).
            vinicio      = yes.
        end.
    end.
    clear frame frame-a all no-pause.
    display
        clien.clicod
        clien.clinom
        clien.tippes
            with frame frame-a.

    recatu1 = recid(clien).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next clien where
                true use-index clien2 .
        if not available clien
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio = no
        then
            down with frame frame-a.
        display
            clien.clicod
            clien.clinom
            clien.tippes
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find clien where recid(clien) = recatu1.

        choose field clien.clicod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
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
                esqpos2 = if esqpos2 = 4 then 4 else esqpos2 + 1.
                color display messages esqcom2[esqpos2] with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next clien where true use-index clien2 no-error.
                if not avail clien
                then leave.
                recatu1 = recid(clien).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev clien where true use-index clien2 no-error.
                if not avail clien
                then leave.
                recatu1 = recid(clien).
            end.
            leave.
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
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next clien where
                true use-index clien2 no-error.
            if not avail clien
            then next.
            color display white/red
                clien.clicod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev clien where
                true use-index clien2 no-error.
            if not avail clien
            then next.
            color display white/red
                clien.clicod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
        /*
            vvvcli = clien.clicod.
        */
            hide frame frame-a no-pause.
            scli = clien.clicod.
            frame-value = string(scli).
            /*
            disp clien.clicod
                 clien.clinom no-label with frame fffff side-labels centered
                                       row 10 overlay color white/red.
            */
            leave bl-princ.
        end.

        if keyfunction(lastkey) = "return"
        then do:
          if esqcom2[esqpos2] <> "Data SPC"
          then hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui
                        row 4  centered OVERLAY 2 COLUMNS SIDE-LABELS.
                
                run funsen.p (input ?,
                              output vok,
                              output vfuncod).

                if not vok then undo, leave.
                
                do for geranum on error undo transaction:
                        find geranum where geranum.etbcod = setbcod.
                        vgera = geranum.clicod.
                        assign geranum.clicod = geranum.clicod + 1.
                        find current geranum no-lock.
                end.

                do on error undo transaction:
                    create clien.
                    if length(string(setbcod)) > 2
                    then clien.clicod = int(string(setbcod,"999") + 
                                        string(vgera,"9999999")).
                    else clien.clicod = int(string(vgera,"9999999") +
                                                 string(setbcod,"99")).
                                                 
                    assign clien.vencod = vfuncod
                           clien.exportado = yes.
                    update clien.clicod
                           clien.clinom
                           clien.tippes with color white/cyan.

                    vcredito = yes.

                    update vcredito label "Credito".
                    if vcredito
                    then clien.classe = 0.
                    else clien.classe = 1.
                end.
                tem-cpf-retornar = no.
                sair-sem-gravar = no.
                run clioutb4.p (input recid(clien),
                                input "I",
                                input string(setbcod,"999")) .
                if sair-sem-gravar = yes
                then do:
                    recatu1 = ?  .
                    next bl-princ.
                end.
                if tem-cpf-retornar = yes
                then do transaction:
                    delete clien.
                    find first clien where clien.ciccgc = vciccgc no-lock.
                end.
                /*
                run clioutb4.p (input recid(clien), input "i", input setbcod).
                */
                recatu1 = recid(clien).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do on error undo with frame f-altera
                         row 5 centered OVERLAY 2 COLUMNS SIDE-LABELS.
                find first titulo where titulo.clifor = clien.clicod
                                    and titulo.titsit = "LIB" no-error.
                
                run funsen.p (input ?,
                              output vok,
                              output vfuncod).

                if not vok then undo,
                leave.
                
                vclicod = clien.clicod.

                if  vclicod > 1 and
                    search("/usr/admcom/progr/agil4_WG.p") <> ?
                then do:
                    conecta-ok = no.
                    run agil4_WG.p (input "clientes", 
                                    input (string(setbcod,"999") +
                                    string(vclicod,"9999999999"))
                                    ).
                    run p-grava-clien-matfil(input vclicod).
                    if conecta-ok = no
                    then next bl-princ.
                    find clien where clien.clicod = vclicod.
                    vclicod = 0.
                end.
                assign clien.vencod = vfuncod
                       clien.exportado = yes.

                display clien.clicod
                        clien.clinom
                        clien.tippes with color white/cyan. pause 0.
                update clien.tippes with color white/cyan.
                tem-cpf-retornar = no.
                sair-sem-gravar = no.
                run clioutb4.p (input recid(clien),
                                input "a",
                                input string(setbcod,"999")) .
                if sair-sem-gravar = yes
                then do:
                    recatu1 = ?  .
                    next bl-princ.
                end.
                if tem-cpf-retornar = yes
                then do:
                    delete clien.
                    find first clien where clien.ciccgc = vciccgc no-lock.
                end.
                /*
                run clioutb4.p (input recid(clien), input "a", input setbcod).
                */
                clien.exportado = no.
                recatu1 = recid(clien).
                leave bl-princ.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do on error undo with frame f-consulta
                        row 5  centered OVERLAY SIDE-LABELS.

                find func where funcod = clien.vencod no-lock no-error.
                if avail func
                then display clien.vencod label "Respons.Cadastro" colon 20
                             func.funnom no-label.

                display clien.clicod    colon 20
                        clien.clinom no-label
                        clien.tippes    colon 20 with color white/cyan.
                if clien.classe = 0
                then display "Credito: Normal".
                else display "Credito: Facil".
                pause.
                run clidis.p (input recid(clien)) .
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do on error undo with frame f-exclui
                        row 4  centered OVERLAY 2 COLUMNS SIDE-LABELS.
                message "Confirma Exclusao de" clien.clinom update sresp.
                if not sresp
                then leave.
                find next clien where true use-index clien2 no-error.
                if not available clien
                then do:
                    find clien where recid(clien) = recatu1.
                    find prev clien where true use-index clien2 no-error.
                end.
                recatu2 = if available clien
                          then recid(clien)
                          else ?.
                find clien where recid(clien) = recatu1.
                delete clien.
                recatu1 = recatu2.
                next bl-princ.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do on error undo:
                display vopcao
                         help "Escolha a Opcao"
                        with frame fescolha no-label
                        centered row 6 overlay color white/cyan.
                choose field vopcao with frame fescolha.
                if frame-index = 1
                then do with frame fprocura overlay row 9 1 column
                                color white/cyan:
                    prompt-for bclien.clicod.
                    find first bclien where bclien.clicod = input bclien.clicod
                                                    no-error.
                    if not avail bclien
                    then leave.
                    recatu1 = recid(bclien).
                    leave.
                end.
                else if frame-index = 2
                then do on error undo with frame fescolha1 side-label
                        column 30 row 9 overlay color white/cyan .
                   prompt-for bclien.clinom.
                   find first bclien where bclien.clinom >= input bclien.clinom
                                                     use-index clien2 no-error.
                   if not avail bclien
                   then leave.
                   recatu1 = recid(bclien).
                   leave.
                end.
                else do on error undo with frame f-procura1 side-label
                    column 30 row 9 overlay color white/cyan.
                    prompt-for bclien.ciccgc.
                    run procura-cpf(input frame f-procura1 bclien.ciccgc).
                    if avail bclien
                    then recatu1 = recid(bclien) .
                    leave.
                end.        
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            if esqcom2[esqpos2] = "Limite Credito"
            then do on error undo:
                update clien.limcrd
                       with frame flimite centered
                            row 10 overlay color white/cyan.
                if clien.limcrd = 0
                then clien.limcrd = 499.50.
            end.
            if esqcom2[esqpos2] = "Data SPC"
            then do on endkey undo:
                display clien.dtspc[1] label "Data 1" colon 10
                        clien.dtspc[2] label "Data 2" colon 10
                        clien.dtspc[3] Label "Data 3" colon 10
                        with frame fspc side-label
                            centered row 11 overlay color white/red.
                pause .
                leave.
            end.
          end.
          view frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        display
                clien.clicod
                clien.clinom
                clien.tippes
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(clien).
   end.
end.
procedure procura-cpf:
    def input parameter vciccgc like clien.ciccgc.
    find first bclien where 
               bclien.ciccgc = vciccgc no-lock no-error.
    if not avail bclien
    then do:
        run verimat0.p (vciccgc).
    end.
end procedure.
procedure  p-grava-clien-matfil:
    def input parameter p-clicod like clien.clicod.
    find first tp-clien where
               tp-clien.clicod = p-clicod no-lock no-error.
    if avail tp-clien
    then do transaction:
        find ger.clien where ger.clien.clicod = tp-clien.clicod no-error.
        if avail ger.clien
        then buffer-copy tp-clien to ger.clien.
    end. 
    find first tp-cpclien where
               tp-cpclien.clicod = p-clicod no-lock no-error.
    if avail tp-cpclien
    then do transaction:
        find ger.cpclien where ger.cpclien.clicod = tp-cpclien.clicod no-error.
        if avail ger.cpclien
        then buffer-copy tp-cpclien to ger.cpclien.
    end.    
    find first tp-carro where
               tp-carro.clicod = p-clicod no-lock no-error.
    if avail tp-carro
    then do transaction:
        find ger.carro where ger.carro.clicod = tp-carro.clicod no-error.
        if not avail ger.carro
        then create ger.carro.
        buffer-copy tp-carro to ger.carro.
    end.
    find ger.clien where ger.clien.clicod = p-clicod no-lock no-error.
    find ger.cpclien where ger.cpclien.clicod = p-clicod no-lock no-error.
    find ger.carro where ger.carro.clicod = p-clicod no-lock no-error.
end procedure.

