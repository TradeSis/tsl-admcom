/* helio 26072023 Otimização de Cadastro de Crédito V6 - restricoes admcom e ie */
{admcab.i}

def var  vpcarro  like carro.carsit.
def var  vpclicod like clien.clicod.

def var vdtcad-aux as date format "99/99/9999".

def var vgera like clien.clicod.
def var vcredito        as l format "Normal/Facil".
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 2
            initial ["Consulta","Procura"].

def var esqcom2         as char format "x(13)" extent 5
            initial [" Extrato "," Lista Novos","Consulta Vivo","",""].

def var vopcao          as  char format "x(11)" extent 3
                                    initial [" Por Codigo"," Por Nome ","Por Celular"] .
def buffer bclien       for clien.
def var vclicod         like clien.clicod.

def temp-table ttclien like clien.

def var cText0         like ttclien.clinom.

form esqcom1
     with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
form esqcom2
     with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.

assign esqregua  = yes
       esqpos1   = 1
       esqpos2   = 1.

bl-princ:
repeat:

    form
        clien.clicod
        clien.clinom 
        clien.datexp format "99/99/9999"
        with frame frame-a 13 down centered color white/red.

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.

    if recatu1 = ?
    then
        find first clien where true use-index clien2 no-lock no-error.
    else
        find clien where recid(clien) = recatu1 no-lock no-error.

    vinicio = no.
    
    if not available clien
    then do transaction:
        message "Cadastro de Clientes Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  row 4  centered 1 column overlay.
            
            create ttclien.
            update ttclien.clicod
                   ttclien.clinom
                   ttclien.tippes.

            find numcli where numcli.clicod = ttclien.clicod no-error.
            if avail numcli
            then assign numcli.numsit = yes
                        numcli.datexp = today.

            run p-cria.
            
            run cliout9.p (input recid(clien)).

            vinicio = yes.
        end.
    end.

    clear frame frame-a all no-pause.
    display
        clien.clicod
        clien.clinom
        clien.datexp
            with frame frame-a.

    recatu1 = recid(clien).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next clien where
                true use-index clien2 no-lock no-error.
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
            clien.datexp
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find clien where recid(clien) = recatu1 no-lock no-error.

        choose field clien.clicod 
                     clien.clinom
                     clien.datexp
                     go-on(cursor-down cursor-up 
                           cursor-left cursor-right 
                           page-down   page-up 
                           tab PF4 F4 ESC return).

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
                esqpos2 = if esqpos2 = 4
                          then 4
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next clien where true use-index clien2 no-lock no-error.
                if not avail clien
                then leave.
                recatu1 = recid(clien).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev clien where true use-index clien2 no-lock no-error.
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
            find next clien where true use-index clien2 no-lock no-error.
            if not avail clien
            then next.
            color display white/red clien.clicod clien.clinom clien.datexp.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev clien where
                true use-index clien2 no-lock no-error.
            if not avail clien
            then next.
            color display white/red
                clien.clicod.
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
            /*
            if esqcom1[esqpos1] = "Inclusao"
            then do transaction with frame f-inclui
                        row 4  centered OVERLAY 2 COLUMNS SIDE-LABELS.
                
                
                create ttclien.
                
                find last cpfis no-error.
                assign cpfis.clifor = cpfis.clifor + 1   
                       vgera = cpfis.clifor.

                find last cpfis no-lock no-error.
       
                ttclien.clicod = int(string(string(vgera,"999999") + "99")).
                
                update ttclien.clicod
                       ttclien.clinom
                       ttclien.tippes with color white/cyan.
                
                
                assign cText0 = input ttclien.clinom.
                      
                run p-carac.
                       
                find numcli where numcli.clicod = ttclien.clicod no-error.
                if avail numcli
                then
                    assign numcli.numsit = yes
                           numcli.datexp = today.
                
                run p-cria.
                
                run cliout9.p (input recid(clien)).
                
                recatu1 = recid(clien).
                leave.
            end.
            
            if esqcom1[esqpos1] = "Alteracao"
            then do transaction with frame f-altera
                         row 5 centered OVERLAY 2 COLUMNS SIDE-LABELS.
                
                
                /*
                for each ttclien. delete ttclien. end.
                find clien where recid(clien) = recatu1 NO-LOCK.
                
                find first titulo where titulo.clifor = clien.clicod and
                                       (titulo.titsit = "LIB" or
                                        titulo.titsit = "IMP") no-lock no-error.
                if clien.classe = 1
                then vcredito = no.
                else vcredito = yes.
                
                create ttclien.
                buffer-copy clien to ttclien.
                
                display ttclien.clinom
                        ttclien.tippes 
                        vcredito label "Credito" with color white/cyan. pause 0.

                update ttclien.clinom when not avail titulo
                       ttclien.tippes 
                       vcredito label "Credito" with color white/cyan.

                if vcredito = no
                then ttclien.classe = 1.
                else ttclien.classe = 0.
                       
                find clien where recid(clien) = recatu1.
                assign clien.clinom = ttclien.clinom
                       clien.tippes = ttclien.tippes
                       clien.classe = ttclien.classe.
                */
                
                find clien where recid(clien) = recatu1 NO-LOCK.
                
                find first tipo_clien
                     where tipo_clien.tipocod = clien.tipocod
                                       no-lock no-error.

                display clien.clinom at 10 format "x(60)"
                        clien.nomeSocial at 10
                        clien.tippes at 3  clien.ultimaAtualizacaoCadastral label "Ult Atualizacao Cadastral"
                        
                        clien.tipocod  format ">9"  at 10
                        tipo_clien.tipodes
                             when avail tipo_clien no-label format "x(15)"
                         with color white/cyan
                         title "Cliente " + string(clien.clicod).
                        
                run cliout9.p (input recid(clien)) .
              
                recatu1 = recid(clien).
                find clien where recid(clien) = recatu1 no-lock.
                leave.
            end.
            */
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta
                        row 4  centered OVERLAY SIDE-LABELS .

                find first tipo_clien
                     where tipo_clien.tipocod = clien.tipocod
                                       no-lock no-error.

                display clien.clinom colon 15 format "x(60)"
                        clien.nomeSocial colon 15 label "Nome Social"

                        clien.tippes colon 15  clien.ultimaAtualizacaoCadastral label "Ult Atualizacao Cadastral"
                        
                        clien.tipocod  format ">9"  colon 15
                        tipo_clien.tipodes
                             when avail tipo_clien no-label format "x(15)"
                         with color white/cyan 
                         title "Cliente " + string(clien.clicod). 
                pause 0.

                pause 0.
                run clidis.p (input recid(clien)).         

            end.
            /*
            if esqcom1[esqpos1] = "Exclusao"
            then do transaction with frame f-exclui
                        row 4  centered OVERLAY 2 COLUMNS SIDE-LABELS.
                find first titulo where titulo.clifor = clien.clicod 
                                no-lock no-error.
                if avail titulo
                then do:
                    bell.
                    message
                       "Cliente com contratos . Exclusao nao permitida".
                    leave.
                end.

                {segur.i 1}
                message "Confirma Exclusao de" clien.clinom update sresp.
                if not sresp
                then leave.
                find next clien where true use-index clien2 
                                no-lock no-error.
                if not available clien
                then do:
                    find clien where recid(clien) = recatu1 no-lock.
                    find prev clien where true use-index clien2 
                                no-lock no-error.
                end.
                recatu2 = if available clien
                          then recid(clien)
                          else ?.
                find clien where recid(clien) = recatu1.
                find numcli where numcli.clicod = clien.clicod no-error.
                if avail numcli
                then
                    assign numcli.numsit = no
                           numcli.datexp = today.
                delete clien.
                recatu1 = recatu2.
                next bl-princ.
            end.
            */
            if esqcom1[esqpos1] = "Procura"
            then do:
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
                                                    no-lock no-error.
                    if not avail bclien
                    then leave.
                    recatu1 = recid(bclien).
                    leave.
                end.
                if frame-index = 2 then do with frame fescolha1 side-label
                        column 30 row 9 overlay color white/cyan .
                   prompt-for bclien.clinom.
                   find first bclien where 
                        bclien.clinom >= input bclien.clinom
                            use-index clien2 no-lock no-error.
                   if not avail bclien
                   then leave.
                   recatu1 = recid(bclien).
                   leave.
                end.
                if frame-index = 3 then do with frame fescolha2 side-label
                        column 20 row 9 overlay color white/cyan .
                   /* Celular */
                   prompt-for bclien.fax format "(xx) xxxxxxxxx".
                   find first bclien 
                     where bclien.fax = input bclien.fax
                       /* use-index clien2 - nao tem indice */
                       no-lock no-error.
                   if not avail bclien
                   then leave.
                   recatu1 = recid(bclien).
                   leave.
                end.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.


            if esqcom2[esqpos2] = "Consulta Vivo"
            then do with frame f-consulta-vivo
                        row 5  centered OVERLAY 2 COLUMNS SIDE-LABELS.


                update vdtcad-aux label "Data de Cadastro"
                       with frame f-data centered side-labels 
                            color white/red overlay row 10.
                hide frame f-data no-pause.
                
                display clien.clinom
                        clien.tippes with color white/cyan.
                pause.
                
                run clidisv.p (input recid(clien), input vdtcad-aux) .

            end.
            
            if esqcom2[esqpos2] = " Extrato "
            then do:
                message "Confirma a emissao do extrato do cliente"
                        clien.clinom "?" update sresp.
                if not sresp
                then leave.
                run extrato.p (input recid(clien)).
                leave.
            end.
            if esqcom2[esqpos2] = " Lista Novos"
            then do:
                message "Confirma a emissao da Lista dos Clientes Novos ?"
                        update sresp.
                if not sresp
                then leave.
                run dreb020.p .
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
                clien.datexp
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(clien).
   end.
end.



procedure p-cria:

    create clien.
    assign clien.clicod = ttclien.clicod
           clien.clinom = ttclien.clinom
           clien.tippes = ttclien.tippes.

    find clien where clien.clicod = ttclien.clicod no-lock no-error.
    
end procedure.


procedure p-carac:

def var cText1     as char form "x(70)"  init "".
def var cCara1     as char form "x(01)"  init "".
def var iCont1     as inte               init 0.
def var lErro1     as logi               init no.

assign cText1 = cText0.

  do iCont1 = 1 to length(cText1):
   
     if substring(cText1,iCont1,1) >= chr(001) and
        substring(cText1,iCont1,1) <= chr(031) or
        substring(cText1,iCont1,1) >= chr(033) and
        substring(cText1,iCont1,1) <= chr(064) or
        substring(cText1,iCont1,1) >= chr(091) and
        substring(cText1,iCont1,1) <= chr(096) or
        substring(cText1,iCont1,1) >= chr(123) 
     then do:
   
             assign lErro1 = yes
                    cCara1 = substring(cText1,iCont1,1).
             leave.       

     end.        
                  
  end.

  if lErro1 = yes 
  then do:
          message "CARACTER INVALIDO NO CAMPO NOME" skip
                  "( " + cCara1 + " ) " view-as alert-box.
          undo, retry.
  end.

end procedure.

