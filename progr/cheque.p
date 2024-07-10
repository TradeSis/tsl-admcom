{admcab.i}
def var vsenha like func.senha.
def var vrec as recid.
def var valorpago like plani.platot.
def buffer bclien for clien.
def var vopcao          as  char format "x(10)" extent 2
                                    initial ["Por Codigo","Por Cheque"] .
def var vnum like cheque.chenum.
def var vban like cheque.cheban.
def var vage like cheque.cheage.
def var vcon like cheque.checon.

def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
  initial ["Inclusao","Alteracao","Exclusao","Consulta","Procura","Pagamento"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bcheque       for cheque.
def var vchenum         like cheque.chenum.

def var vinc as log.
def var vbanco like chq.banco init 0.
def var vagencia like chq.agencia.
def var vconta like chq.conta format "x(20)".
def var vnumero like chq.numero.

form cheque.cheetb colon 9
     estab.etbnom no-label format "x(25)"
     cheque.clicod colon 9 label "Cliente"
     cheque.nome   no-label
     cheque.cheemi colon 9
     cheque.cheven colon 29
     cheque.cheval colon 50
     cheque.cheban colon 9
     banco.bandesc no-label
     cheque.cheage colon 9
     cheque.chenum  colon 29
     cheque.checid  colon 50
     cheque.chealin colon 9
     cheque.chedti  colon 29
     cheque.chedtf colon 50
     cheque.codcob colon 9 label "Cobrador" format "999"
     cobrador.nome no-label
     cheque.chepag label "Pagam" colon 9
     cheque.chejur colon 29
     cheque.chesit colon 50
         with frame f-altera side-label
            overlay row 3 color white/cyan centered.

    form
        esqcom1 
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then
        find first cheque where cheque.cheetb < 900 and
                   {conv_difer.i cheque.cheetb} 
          use-index cheemi NO-LOCK no-error.
    else
        find cheque where recid(cheque) = recatu1 NO-LOCK.
        vinicio = no.
    
    if not available cheque
    then do:
        message "Cadastro de cheque Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-altera side-label
            overlay row 6  color white/cyan centered:
                create cheque.
                update cheque.cheetb format ">>9" colon 9.
                find estab where estab.etbcod = cheetb no-lock.
                display estab.etbnom no-label format "x(25)".
                do on error undo:
                    update cheque.clicod colon 9.
                    find clien where clien.clicod = cheque.clicod
                                                            no-lock no-error.
                    if not avail clien
                    then do:
                        message "Cliente nao Cadastrado".
                        undo, retry.
                    end.
                end.
                cheque.nome = clien.clinom.
                display cheque.nome.
                update cheque.cheemi colon 9
                       cheque.cheven
                       cheque.cheval.
                do on error undo:
                    update cheque.cheban colon 9 with no-validate.
                    find banco where banco.bancod = cheque.cheban
                                no-lock no-error.
                    if not avail banco
                    then find banco where banco.numban = cheque.cheban
                                no-lock no-error.
                    if not avail banco
                    then do:
                        message "Banco nao Cadastrado".
                        undo, retry.
                    end.
                    display banco.bandesc no-label.
                end.
                cheque.chesit = "LIB".
                update cheque.cheage colon 9
                       cheque.chenum
                       cheque.checid
                       cheque.chealin colon 9
                       cheque.chedti
                       cheque.chedtf.
                do on error undo:
                    update cheque.codcob.
                    find cobrador where cobrador.codcob = cheque.codcob
                            no-lock no-error.
                    if not avail cobrador
                    then do:
                        message "Cobrador nao Cadastrado".
                        undo, retry.
                    end.
                end.
                display cobrador.nome.
                vinicio = yes.
        end.
    end.
    clear frame frame-a all no-pause.
    display cheque.cheetb
            cheque.chenum
            cheque.cheban
            cheque.cheage
            cheque.nome
            cheque.chesit
            with frame frame-a 14 down centered color white/red.

    recatu1 = recid(cheque).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next cheque where cheque.cheetb < 900 and
                   {conv_difer.i cheque.cheetb}
         use-index cheemi NO-LOCK no-error.
        if not available cheque
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio = no
        then
        down with frame frame-a.
        display cheque.cheetb
                cheque.chenum
                cheque.cheban
                cheque.cheage
                cheque.nome
                cheque.chesit with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find cheque where recid(cheque) = recatu1 NO-LOCK.

        choose field cheque.chenum
            go-on(cursor-down cursor-up
                  page-down   page-up
                  cursor-left cursor-right
                  tab PF4 F4 ESC return).
        hide message no-pause.
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
                esqpos1 = if esqpos1 = 6
                          then 6
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
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next cheque where cheque.cheetb < 900 and
                     {conv_difer.i cheque.cheetb}
                                       use-index cheemi NO-LOCK no-error.
                if not avail cheque
                then leave.
                recatu2 = recid(cheque).
            end.
            if reccont = frame-down(frame-a)
            then recatu1 = recatu2.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev cheque where cheque.cheetb < 900 and
                          {conv_difer.i cheque.cheetb}
                                       use-index cheemi NO-LOCK no-error.
                if not avail cheque
                then leave.
                recatu1 = recid(cheque).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next cheque where cheque.cheetb < 900 and
                   {conv_difer.i cheque.cheetb}
             use-index cheemi NO-LOCK no-error.
            if not avail cheque
            then next.
            color display white/red
                cheque.chenum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev cheque where cheque.cheetb < 900 and
                   {conv_difer.i cheque.cheetb} 
             use-index cheemi NO-LOCK no-error.
            if not avail cheque
            then next.
            color display white/red
                cheque.chenum.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.
            hide frame f-altera no-pause.
            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-altera no-validate.
                vinc = no.
                run busca-chq.
                if keyfunction(lastkey) = "END-ERROR"
                then next bl-princ.
                
                if not vinc
                then create cheque.
                else do:
                    find current cheque exclusive.
                    find estab where estab.etbcod = cheque.cheetb
                            no-lock no-error.
                    find banco where banco.bancod = cheque.cheban
                            no-lock no-error.
                    disp 
                        cheque.cheetb 
                        estab.etbnom when avail estab
                        cheque.clicod 
                        cheque.nome   
                        cheque.cheemi
                        cheque.cheven 
                        cheque.cheval 
                        cheque.cheban 
                        banco.bandesc when avail banco
                        cheque.cheage 
                        cheque.checon
                        cheque.chenum 
                        cheque.checid .
                end.
                update cheque.cheetb format ">>9".
                find estab where estab.etbcod = cheetb no-lock.
                display estab.etbnom.

                cheque.chesit = "LIB".
                do on error undo:
                    update cheque.clicod colon 9.
                    find clien where clien.clicod = cheque.clicod
                                                            no-lock no-error.
                    if not avail clien
                    then do:
                        message "Cliente nao Cadastrado".
                        undo, retry.
                    end.
                end.
                cheque.nome = clien.clinom.
                display cheque.nome.
                update cheque.cheemi.
                cheque.cheven = cheque.cheemi.
                update cheque.cheven
                       cheque.cheval.

                do on error undo:
                    update cheque.cheban colon 9.
                    find banco where banco.bancod = cheque.cheban
                                no-lock no-error.
                    if not avail banco
                    then find banco where banco.numban = cheque.cheban
                            no-lock no-error.
                    if not avail banco
                    then do:
                        message "Banco nao Cadastrado".
                        undo, retry.
                    end.
                    display banco.bandesc no-label.
                end.
                {cheque.i}
                update cheque.cheage
                       cheque.checon 
                       cheque.chenum
                       cheque.checid
                       cheque.chealin
                       cheque.chedti
                       cheque.chedtf.
                do on error undo:
                    update cheque.codcob.
                    find cobrador where cobrador.codcob = cheque.codcob
                            no-lock no-error.
                    if not avail cobrador
                    then do:
                        message "Cobrador nao Cadastrado".
                        undo, retry.
                    end.
                end.
                display cobrador.nome.
                cheque.chesit = "LIB".
                find chedat where chedat.chenum = cheque.chenum and
                                  chedat.cheage = cheque.cheage and
                                  chedat.cheban = cheque.cheban no-error.
                if not avail chedat
                then do:
                    create chedat.
                    assign chedat.chenum = cheque.chenum
                           chedat.cheage = cheque.cheage
                           chedat.cheban = cheque.cheban
                           chedat.datexp = today
                           chedat.chedec = no.
                
                end.
                recatu1 = recid(cheque).
                leave.
            end.

            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "*Exclusao" or
               esqcom1[esqpos1] = "Listagem"
            then do with frame f-altera no-validate:
                display cheque.cheetb.
                find estab where estab.etbcod = cheetb no-lock.
                display estab.etbnom.

                display cheque.chesit
                        cheque.clicod
                        cheque.nome
                        cheque.cheemi
                        cheque.cheven
                        cheque.cheval
                        cheque.cheban.
                find banco where banco.bancod = cheque.cheban no-lock.
                find cobrador where cobrador.codcob = cheque.codcob no-lock.

                display banco.bandesc.
                display cheque.cheage
                        cheque.checon
                        cheque.chenum
                        cheque.checid
                        cheque.chealin
                        cheque.chedti
                        cheque.chedtf
                        cheque.codcob
                        cobrador.nome
                        cheque.chesit
                        cheque.chepag
                        cheque.chejur.
                find chedat where chedat.chenum = cheque.chenum and
                                  chedat.cheage = cheque.cheage and
                                  chedat.cheban = cheque.cheban
                            NO-LOCK no-error.
                if avail chedat
                then display chedat.datexp label "Data Inclusao"
                             chedat.chedec label "Declaracao".
                
                run choose.p (input cheque.clicod,
                              output vrec).
                
                if vrec <> ?
                then find cheque where recid(cheque) = vrec NO-LOCK.
                recatu1 = recid(cheque).
                color display white/red cheque.chenum with frame frame-a.
                leave. 
            end.

            if esqcom1[esqpos1] = "Alteracao"
            then do ON ERROR UNDO with frame f-altera no-validate:
                find current cheque EXCLUSIVE.
                update cheque.cheetb format ">>9".
                find estab where estab.etbcod = cheetb no-lock.
                display estab.etbnom.

                do on error undo:
                    update cheque.clicod colon 9.
                    find clien where clien.clicod = cheque.clicod
                                                            no-lock no-error.
                    if not avail clien
                    then do:
                        message "Cliente nao Cadastrado".
                        undo, retry.
                    end.
                end.
                cheque.nome = clien.clinom.
                display cheque.nome.
                update cheque.cheemi
                       cheque.cheven
                       cheque.cheval.

                do on error undo:
                    update cheque.cheban colon 9.
                    find banco where banco.bancod = cheque.cheban
                                no-lock no-error.
                    if not avail banco
                    then do:
                        message "Banco nao Cadastrado".
                        undo, retry.
                    end.
                    display banco.bandesc no-label.
                end.
                update cheque.cheage
                       cheque.checon 
                       cheque.chenum
                       cheque.checid
                       cheque.chealin
                       cheque.chedti
                       cheque.chedtf.
                do on error undo:
                    update cheque.codcob.
                    find cobrador where cobrador.codcob = cheque.codcob
                            no-lock no-error.
                    if not avail cobrador
                    then do:
                        message "Cobrador nao Cadastrado".
                        undo, retry.
                    end.
                end.
                display cobrador.nome.
                
                find chedat where chedat.chenum = cheque.chenum and
                                  chedat.cheage = cheque.cheage and
                                  chedat.cheban = cheque.cheban no-error.
                if not avail chedat
                then do:
                    create chedat.
                    assign chedat.chenum = cheque.chenum
                           chedat.cheage = cheque.cheage
                           chedat.cheban = cheque.cheban
                           chedat.datexp = ?
                           chedat.chedec = no.
                end.
                update chedat.chedec.

            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-altera4:
                message "Confirma Exclusao de" cheque.chenum update sresp.
                if not sresp
                then leave.
                find next cheque where cheque.cheetb < 900 and
                       {conv_difer.i cheque.cheetb}
                 NO-LOCK no-error.
                if not available cheque
                then do:
                    find cheque where recid(cheque) = recatu1 NO-LOCK.
                    find prev cheque where cheque.cheetb < 900 and
                           {conv_difer.i cheque.cheetb}
                                use-index cheemi NO-LOCK no-error.
                end.
                recatu2 = if available cheque
                          then recid(cheque)
                          else ?.
                find cheque where recid(cheque) = recatu1.
                find chedat where chedat.chenum = cheque.chenum and
                                  chedat.cheage = cheque.cheage and
                                  chedat.cheban = cheque.cheban no-error.
                if avail chedat
                then delete chedat.

                delete cheque.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do:
                hide frame fprocura no-pause.
                hide frame f-procura no-pause.
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
                                                    NO-LOCK no-error.
                    if not avail bclien
                    then leave.
                    else do:
                        find first cheque where cheque.clicod = bclien.clicod
                                                    NO-LOCK no-error.
                        if not avail cheque
                        then do:
                            message "Nenhum cheque para este cliente".
                            undo, retry.
                        end.
                        else recatu1 = recid(cheque).
                    end.
                    leave.
                end.
                else do:
                    update vnum label "Numero"
                           vban label "Banco"
                           vage label "Agencia" 
                           vcon label "Conta"
                           with frame f-procura
                                1 column centered color message overlay.
                    find first cheque where cheque.chenum = vnum and
                                      cheque.cheban = vban and
                                      cheque.cheage = vage and
                                      cheque.checon = vcon NO-LOCK no-error.
                    if not avail cheque
                    then do:
                        message "Cheque nao Cadastrado".
                        undo, retry.
                    end.
                    else recatu1 = recid(cheque).
                end.
                /* recatu1 = recatu2. */
                leave.
            end.
            if esqcom1[esqpos1] = "Pagamento"
            then do:
                
                update vsenha blank
                   with frame fsenha overlay centered row 10 color
                              black/red side-labels.
                              
                if vsenha <> "2505"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.    
                
                display cheque.clicod
                        cheque.nome no-label with frame f-cli side-label
                                    row 4 color withe/red no-box centered.
                display cheque.chenum colon 10
                        cheque.cheban colon 40
                        cheque.cheage colon 60
                        cheque.cheemi colon 10
                        cheque.cheven colon 40
                        cheque.cheval colon 60
                                      with frame f-pag1 color black/cyan
                                            width 80 side-label.

                if cheque.chesit = "PAG"
                then do:
                    message "Cheque ja esta pago, deseja liberar?" update sresp.
                    if sresp
                    then do on error undo.
                        find current cheque EXCLUSIVE.
                         cheque.chesit = "LIB".
                         cheque.chepag = ?.
                         cheque.chejur = 0.
                    end.
                end.
                else do:
                    find current cheque EXCLUSIVE.
                    cheque.chesit = "PAG".
                    cheque.chepag = today.
                    valorpago     = cheque.cheval.
                    
                    update cheque.chepag label "Data Pagamento"
                           valorpago label "Vl.Pago"
                                 with frame f-pag
                                    1 column color black/cyan overlay centered.
                    cheque.chejur = valorpago - cheque.cheval.
                    /*
                    display (cheque.cheval + cheque.chejur) label "Valor Pago"
                                with frame f-pag.
                    */
                    leave.
                end.
            end.
          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame frame-a .
        end.
        if keyfunction (lastkey) = "end-error"
         then view frame frame-a.
        hide frame f-cli no-pause.
        display cheque.cheetb
                cheque.chenum
                cheque.cheban
                cheque.cheage
                cheque.nome
                cheque.chesit with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        
        recatu1 = recid(cheque).
   end.

end.

procedure busca-chq:
    
    update vbanco
           with frame f-cheque.
    if vbanco > 0
    then do:       
        update       vagencia
           vconta
           vnumero
           with frame f-cheque 1 down centered.
    find chq where chq.banco = vbanco and
                   chq.agencia = vagencia and
                   chq.conta = vconta and
                   chq.numero = vnumero
                   no-lock no-error.
    if avail chq
    then do:
        find chqtit of chq no-lock no-error.
        if not avail chqtit
        then run gera-chqtit.
        find chqtit of chq no-lock no-error.
        
        if avail chqtit
        then do on error undo:
        find clien where clien.clicod = chqtit.clifor no-lock.
        create cheque.
        assign cheque.cheetb = chqtit.etbcod
               cheque.clicod = chqtit.clifor
               cheque.nome   = clien.clinom
               cheque.cheemi = chq.datemi
               cheque.cheven = chq.data
               cheque.cheval = chq.valor
               cheque.cheban = chq.banco
               cheque.cheage = chq.agencia
               cheque.checon = chq.conta
               cheque.chenum = int(chq.numero)
               cheque.checid = clien.cidade[1].
        vinc = yes.
        end.
    end.    
    end. 
    
    hide frame f-cheque no-pause.          
end.         
        
procedure gera-chqtit.
        
            find first pdvforma where
                         pdvforma.ctmcod   = "P7" and
                                      pdvforma.pdvtfcod = "2" and
                                                   pdvforma.contnum  = chq.numero
             no-lock no-error.
                 if not avail pdvforma
                     then find first pdvforma where
                                  pdvforma.ctmcod   = "P7" and
                                               pdvforma.pdvtfcod = "7" and
                                                            pdvforma.contnum  = chq.numero
             no-lock no-error.
     if avail pdvforma
                      then do:
                              find pdvmov of pdvforma no-lock no-error.
                                      if avail pdvmov
                                              then for each pdvdoc of pdvmov no-lock:
                find first titulo where titnat = no and
                                           titulo.clifor = pdvdoc.clifor and
                                                                      titulo.titnum = pdvdoc.contnum and
                           titulo.titpar = pdvdoc.titpar
                                                      no-lock no-error.
                                                                      if avail titulo and
                        titulo.titvlpag = pdvdoc.valor
                                        then do on error undo:
                                                            create chqtit.
                                                                                assign
                        chqtit.titnat = titulo.titnat
                                                chqtit.modcod = titulo.modcod
                                                                        chqtit.etbcod = titulo.etbcod
                        chqtit.clifor = titulo.clifor
                                                chqtit.titpar = titulo.titpar
                                                                        chqtit.titnum = titulo.titnum
                        chqtit.banco  = chq.banco
                                                chqtit.agencia = chq.agencia
                                                                        chqtit.conta = chq.conta
                        chqtit.numero = chq.numero
                                                .
                                                
                                                                end.
                                                                            end.
    end.
end procedure.    
             
