{admcab.i}
def var varquivo as char.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var i as int.
def var vfuncod like func.funcod.
def var vsenha like func.senha.

def var vemite  like autctb.emite. 
def var vdesti  like autctb.desti. 
def var vserie  like autctb.serie. 
def var vnumero like autctb.Numero. 
def var vdatemi like autctb.datemi. 
def var vmotivo like autctb.Motivo. 

def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 4
            initial ["Inclusao","Alteracao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bautctb       for autctb.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
    
    update vfuncod with frame f-senha centered row 4
                            side-label title " Seguranca ".
    find func where func.funcod = vfuncod and
                    func.etbcod = 999 no-lock no-error.
    if not avail func
    then do:
       message "Funcionario nao Cadastrado".
       undo, retry.
    end.
    disp func.funnom no-label with frame f-senha.
    if func.funfunc <> "CONTABILIDADE"
    then do:
        bell.
        message "Funcionario sem Permissao".
        undo, retry.
    end.
    update vsenha blank with frame f-senha.
    if vsenha = func.senha
    then.
    else do:
        message "Senha Invalida".
        pause.
        undo, retry.
    end.
    hide frame f-senha no-pause.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then find first autctb use-index ind-2 where 
                    autctb.movtdc = 4 no-error.
    else find autctb use-index ind-2 where recid(autctb) = recatu1.
    vinicio = yes.
    if not available autctb
    then do:
        message "Cadastro Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1 overlay row 6 centered side-label.
            assign vemite = 0 
                   vdesti = 0
                   vserie = "U"
                   vnumero  = 0
                   vdatemi  = today
                   vmotivo  = "".
            update vdesti label "Deposito    " format ">>9" at 1.
            find estab where estab.etbcod = vdesti no-lock.
            display estab.etbnom no-label.
                        
            update vemite label "Emitente    " at 1.
            find forne where forne.forcod = vemite no-lock no-error.
            if not avail forne
            then do:
                message "Fornecedor Invalido".
                pause.
                undo, retry.
            end.
            display forne.fornom no-label.
            update vdatemi label "Data Emissao" at 1
                   vserie  label "Serie       " at 1
                   vnumero label "Numero      " at 1
                   vmotivo label "Motivo      " at 1.
            message "Incluir Nova Liberacao" update sresp.
            if sresp = no
            then undo, retry.
            
            find autctb use-index ind-2 where autctb.movtdc = 4 and
                              autctb.emite  = vemite and
                              autctb.datemi = vdatemi and
                              autctb.serie  = vserie  and
                              autctb.numero = vnumero no-error.
            if avail autctb
            then do:
                message "Autorizacao ja cadastrada".
                pause.
                undo, retry.
            end.
            do transaction:
                create autctb.
                assign autctb.emite  = vemite 
                       autctb.desti  = vdesti 
                       autctb.movtdc = 4 
                       autctb.serie  = vserie 
                       autctb.Numero = vnumero 
                       autctb.datemi = vdatemi 
                       autctb.datexp = today
                       autctb.FunCod = func.funcod
                       autctb.Motivo = vmotivo 
                       autctb.hora   = time.
            end.
            vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    hide frame f-lista no-pause.
    find forne where forne.forcod = autctb.emite no-lock. 
    display autctb.emite column-label "Emite" format ">>>>>9"
            forne.fornom column-label "Nome"  format "x(25)"
            autctb.datemi column-label "Emissao" 
            autctb.serie  column-label "Sr"
            autctb.numero format ">>>>>9"
            autctb.motivo format "x(24)"
                with frame frame-a 13 down centered width 80.

    recatu1 = recid(autctb).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next autctb use-index ind-2 where
                autctb.movtdc = 4.
        if not available autctb
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
        find forne where forne.forcod = autctb.emite no-lock.
        display autctb.emite
                forne.fornom
                autctb.datemi
                autctb.serie 
                autctb.numero 
                autctb.motivo 
                    with frame frame-a.

    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find autctb use-index ind-2 where recid(autctb) = recatu1.

        choose field autctb.emite
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
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
                esqpos1 = if esqpos1 = 4
                          then 4
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
                find next autctb use-index ind-2 where 
                            autctb.movtdc = 4 no-error.
                if not avail autctb
                then leave.
                recatu1 = recid(autctb).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev autctb use-index ind-2 where 
                            autctb.movtdc = 4 no-error.
                if not avail autctb
                then leave.
                recatu1 = recid(autctb).
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
            find next autctb use-index ind-2 where
                    autctb.movtdc = 4  no-error.
            if not avail autctb
            then next.
            color display normal
                autctb.emite.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev autctb use-index ind-2 where
                    autctb.movtdc = 4 no-error.
            if not avail autctb
            then next.
            color display normal
                autctb.emite.
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

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 centered side-label.
                assign vemite = 0 
                       vdesti = 0 
                       vserie = "U" 
                       vnumero  = 0 
                       vdatemi  = today 
                       vmotivo  = "".
                update vdesti label "Deposito    " format ">>9" at 1.
                find estab where estab.etbcod = vdesti no-lock.
                display estab.etbnom no-label.
                        
                update vemite label "Emitente    " at 1.
                find forne where forne.forcod = vemite no-lock no-error.
                if not avail forne
                then do:
                    message "Fornecedor Invalido".
                    pause.
                    undo, retry.
                end.
                display forne.fornom no-label.
                update vdatemi label "Data Emissao" at 1
                       vserie  label "Serie       " at 1
                       vnumero label "Numero      " format ">>>>>>>9" at 1
                       vmotivo label "Motivo      " at 1.
                message "Incluir Nova Liberacao" update sresp.
                if sresp = no
                then undo, retry.
                
                find autctb use-index ind-2 where autctb.movtdc = 4 and
                                  autctb.emite  = vemite and
                                  autctb.datemi = vdatemi and
                                  autctb.serie  = vserie  and
                                  autctb.numero = vnumero no-error.
                if avail autctb
                then do:
                    message "Autorizacao ja cadastrada".
                    pause.
                    undo, retry.
                end.
                do transaction:
                    create autctb.
                    assign autctb.emite  = vemite 
                           autctb.desti  = vdesti 
                           autctb.movtdc = 4 
                           autctb.serie  = vserie 
                           autctb.Numero = vnumero 
                           autctb.datemi = vdatemi 
                           autctb.datexp = today
                           autctb.FunCod = func.funcod
                           autctb.Motivo = vmotivo 
                           autctb.hora   = time.
                end.
            
                recatu1 = recid(autctb).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do transaction
                    with frame f-altera overlay row 6 centered side-label.
                update autctb.desti label "Deposito    " format ">>9" at 1.
                find estab where estab.etbcod = desti no-lock.
                display estab.etbnom no-label.
                        
                update autctb.emite label "Emitente    " at 1.
                find forne where forne.forcod = autctb.emite no-lock no-error.
                if not avail forne
                then do:
                    message "Fornecedor Invalido".
                    pause.
                    undo, retry.
                end.
                display forne.fornom no-label.
                update autctb.datemi label "Data Emissao" at 1
                       autctb.serie  label "Serie       " at 1
                       autctb.numero label "Numero      " at 1
                       autctb.motivo label "Motivo      " at 1.

            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay 
                    row 6 centered side-label.
            
                find func where func.funcod = autctb.funcod and
                                func.etbcod = 999 no-lock.
                display autctb.desti  label "Deposito     " format ">>9"    at 1
                        autctb.emite  label "Emite        " format ">>>>>9" at 1
                        forne.fornom no-label 
                        autctb.datemi label "Emissao      "  at 1
                        autctb.serie  label "Serie        "  at 1
                        autctb.numero format ">>>>>9" label "Numero       " 
                                at 1    
                        autctb.motivo label "Motivo       "  at 1 
                        autctb.datexp label "Data Inclusao"  at 1
                        autctb.funcod label "Funcionario  "  at 1
                        func.funnom   no-label
                        string(autctb.hora,"HH:MM:SS") label "Hora         " 
                                at 1
                            with frame f-consulta no-validate.
            end.
            /*
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" autctb.numero update sresp.
                if not sresp
                then leave.
                find next autctb use-index ind-2 where
                        autctb.movtdc = 4 no-error.
                if not available autctb
                then do:
                    find autctb use-index ind-2 where recid(autctb) = recatu1.
                    find prev autctb use-index ind-2 where 
                            autctb.movtdc = 4 no-error.
                end.
                recatu2 = if available autctb
                          then recid(autctb)
                          else ?.
                find autctb use-index ind-2 where recid(autctb) = recatu1.
                delete autctb.
                recatu1 = recatu2.
                leave.
            end.
            */

            if esqcom1[esqpos1] = "Listagem"
            then do:

                update vdti label "Perido"
                       vdtf no-label with frame f-lis1 side-label row 10
                                    centered.
                recatu2 = recatu1.
                
                if opsys <> "UNIX"
                then varquivo = "..\relat\aut." + string(time).
                else varquivo = "/admcom/relat/aut." + string(time).

                {mdad.i
                    &Saida     = "value(varquivo)"  
                    &Page-Size = "64" 
                    &Cond-Var  = "130" 
                    &Page-Line = "66" 
                    &Nom-Rel   = ""autctb"" 
                    &Nom-Sis   = """SISTEMA CONTABILIDADE""" 
                    &Tit-Rel   = """ PERIODO "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
                    &Width     = "130"
                    &Form      = "frame f-cabcab"}


                for each autctb where autctb.datexp >= vdti and
                                      autctb.datexp <= vdtf 
                                                no-lock by autctb.datexp:
                    find forne where forne.forcod = autctb.emite no-lock.
                    
                    display autctb.datexp format "99/99/9999"
                                            column-label "Data" 
                            autctb.emite 
                                column-label "Emite" format ">>>>>9"
                            forne.fornom column-label "Nome"  format "x(25)"
                            autctb.datemi column-label "Emissao" 
                            autctb.serie  column-label "Sr"
                            autctb.numero format ">>>>>9"
                            autctb.motivo format "x(50)"
                                with frame f-lista down width 120.

                end.
                output close.
                
                if opsys = "UNIX"
                then do:
                    run visurel.p(varquivo,"").
                end.
                else do:
                    {mrod.i}.
                end.
            
                hide frame f-lista no-pause.
                recatu1 = recatu2.
                leave.
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
        if keyfunction(lastkey) = "end-error" 
        then view frame frame-a.
        find forne where forne.forcod = autctb.emite no-lock.
        display autctb.emite
                forne.fornom
                autctb.datemi
                autctb.serie 
                autctb.numero 
                autctb.motivo 
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(autctb).
   end.
end.
