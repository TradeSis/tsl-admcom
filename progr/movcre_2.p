{admcab.i}
def var ii as i.
def var vt like movcre.titvlcob.
def var vtot like movcre.titvlcob.
def var vforcod like forne.forcod.
def var i as i.
def var vtotal  like movcre.titvlcob.
def var vsenha  like func.senha.
def var vfunc   like func.funcod.
def var vtitnum like movcre.titnum.
def var vtitpar like movcre.titpar.
def var vtitdtemi like movcre.titdtemi.
def var vtitdtven like movcre.titdtven.
def var vtitvljur like movcre.titvlcob.
def var vtitvldes like movcre.titvlcob.
def buffer xmovcre for movcre.
def var vvenc  like movcre.titdtven.
def var vdia   as int.
def var vpar   like movcre.titpar.
def var vlog   as log.
def var vok as log.
def var vinicio         as  log initial no.
def var reccont         as  int.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log initial yes.
def var esqcom1         as char format "x(14)" extent 4
            initial ["Inclusao","Alteracao","Exclusao","Consulta"].
def var esqcom2         as char format "x(25)" extent 2
            initial ["Pagamento/Cancelamento    ", "Fechamento"].
def buffer bmovcre      for movcre.
def buffer cmovcre      for movcre.
def buffer b-titu       for movcre.
def var vetbcod         like movcre.etbcod.
def var vcliforlab      as char format "x(12)".
def var vclifornom      as char format "x(30)".
def var vclifor         like movcre.clifor.
def var wperdes         as dec format ">9.99 %" label "Perc. Desc.".
def var wperjur         as dec format ">9.99 %" label "Perc. Juros".
def var vtitvlpag       like movcre.titvlpag.
def var vtitvlcob       like movcre.titvlcob.
def var vdtpag          like movcre.titdtpag.
def var vdate           as   date.
def var vcontrola       as   log initial no.
form esqcom1
    with frame f-com1
    row 5 no-box no-labels side-labels centered.
form esqcom2
    with frame f-com2
        row screen-lines - 2 title " OPERACOES " no-labels side-labels column 1
        centered.

FORM movcre.clifor    colon 15 label "Fornec."
     movcre.titnum     colon 15
     movcre.titpar     colon 15
     movcre.titdtemi   colon 15
     movcre.titdtven   colon 15
     movcre.titvlcob   colon 15
    with frame fmovcre
        overlay row 7 color
        white/cyan side-label width 39.

FORM vforcod     colon 15
     forne.fornom no-label
     vtitnum     colon 15
     vtitpar     colon 15
     vtitdtemi   colon 15
     vtitdtven   colon 15
     vtitvlcob   colon 15
        with frame ftit2 overlay row 7 color white/cyan side-label width 80.


form
    movcre.titdtpag colon 15 label "Dt.Pagam"
    movcre.titvlpag  colon 15
    with frame fpag1 side-label
         row 10 color white/cyan
         overlay column 42 width 39 title " Pagamento " .


def var vmes as int format "99".
def var vano as int format "9999".
def var vdt like plani.pladat.
def var vv as int.
esqpos1  = 1. esqpos2  = 1.
repeat:
    clear frame ff1 all.
    assign recatu1  = ?.
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.

    update vmes label "Mes"
           vano label "Ano" with frame f1 side-label width 80.
    /*
    find first movcre where movcre.titano = vano and
                            movcre.titmes = vmes no-lock no-error.
    if avail movcre and movcre.fechado
    then do:
        message "Mes ja foi fechado".
        undo, retry.
    end.
    */
    find salcre where salcre.salano = vano and
                      salcre.salmes = vmes no-error.
    display salcre.salano
            salcre.salmes 
            salcre.salini 
            salcre.salfin with frame f-salcre side-label 
                        no-box row 4 centered color black/cyan.
    
    hide frame ff1 no-pause.
bl-princ:
repeat :
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ? 
    then find first movcre where movcre.titano = vano      and
                                 movcre.titmes = vmes no-error.
    else find movcre where recid(movcre) = recatu1.
    vinicio = no.
    if not available movcre 
    then do:
        message "Nao existem movimento gerado para este mes".
        undo, retry.
    end.
    clear frame frame-a all no-pause.
    view frame ff.
    
    find salcre where salcre.salano = vano and
                      salcre.salmes = vmes no-error.
    display salcre.salano
            salcre.salmes 
            salcre.salini 
            salcre.salfin with frame f-salcre side-label 
                        no-box row 4 centered color black/cyan.

    find forne where forne.forcod = movcre.clifor no-lock.
    display movcre.clifor   column-label "Fornec" format ">>>>>9"
            movcre.titnum   format "x(7)"
            movcre.titpar   format ">>>>9" 
            movcre.titvlcob format ">>>,>>9.99" column-label "Vl.Cobrado"
            movcre.titdtemi format "99/99/9999" column-label "Dt.Emissao"
            movcre.titdtven format "99/99/9999" column-label "Dt.Vecto"
            movcre.titdtpag format "99/99/9999" column-label "Dt.Pagto"
            movcre.titsit   column-label "S" format "X(03)"
            movcre.titman   column-label "Manuten." format "x(09)"
              with frame frame-a 10 down centered color white/red.
    recatu1 = recid(movcre).
    if esqregua then do:
       display esqcom1[esqpos1] with frame f-com1.
       color  display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
        display esqcom2[esqpos2] with frame f-com2.
        color display message esqcom2[esqpos2] with frame f-com2.
    end.
    repeat:
        find next movcre where movcre.titano = vano and  
                               movcre.titmes = vmes no-lock no-error.
        if not available movcre
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if not vinicio
        then down with frame frame-a.
        view frame ff.
        
        find salcre where salcre.salano = vano and
                          salcre.salmes = vmes no-error.
        display salcre.salano
                salcre.salmes 
                salcre.salini 
                salcre.salfin with frame f-salcre side-label 
                        no-box row 4 centered color black/cyan.

        display movcre.clifor 
                movcre.titnum 
                movcre.titpar   
                movcre.titvlcob  
                movcre.titdtemi  
                movcre.titdtven  
                movcre.titdtpag  
                movcre.titsit 
                movcre.titman
                    with frame frame-a. 
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    repeat with frame frame-a:
        find movcre where recid(movcre) = recatu1.
        color display messages movcre.titnum movcre.titpar.
        on f7 recall.
        choose field movcre.titnum movcre.titpar
            go-on(cursor-down cursor-up cursor-left cursor-right F7 PF7
                  page-up page-down tab PF4 F4 ESC return v V ).
        if  keyfunction(lastkey) = "RECALL"
        then do with frame fproc centered row 5 overlay 
                                          color message side-label:
            prompt-for movcre.titnum colon 10
                       movcre.clifor colon 10.
            find first movcre where movcre.titano   = vano and
                                    movcre.titmes   = vmes and
                                    movcre.titnum   = input movcre.titnum and
                                    movcre.clifor   = input movcre.clifor
                                                    no-error.
            recatu1 = if avail movcre
                      then recid(movcre) 
                      else ?. 
            leave.
       end. 
       on f7 help.
       if  keyfunction(lastkey) = "V" or
           keyfunction(lastkey) = "v"
       then do with frame fdt centered row 5 overlay color message side-label:
            vdt = today.
            update vdt label "Vencimento".
            find first movcre where movcre.titano   = vano and
                                    movcre.titmes   = vmes and
                                    movcre.titdtven >= vdt no-error.
            recatu1 = if avail movcre
                      then recid(movcre) else ?. leave.
        end. 
        
        if  keyfunction(lastkey) = "TAB" then do:
            if  esqregua then do:
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
        if keyfunction(lastkey) = "cursor-right" then do:
            if  esqregua then do:
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
                esqpos2 = if esqpos2 = 2
                          then 2
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left" then do:
            if esqregua then do:
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
        if keyfunction(lastkey) = "cursor-down" then do:
            find next movcre where movcre.titano = vano and
                                   movcre.titmes = vmes no-lock no-error.
            if  not avail movcre
            then next.
            color display white/red movcre.titnum movcre.titpar.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if  keyfunction(lastkey) = "cursor-up" then do:
            find prev movcre where movcre.titano = vano and
                                   movcre.titmes = vmes no-lock no-error.
            if not avail movcre
            then next.
            color display white/red movcre.titnum movcre.titpar.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
          
          if esqcom2[esqpos2] <> "Pagamento/Cancelamento" or
             esqcom2[esqpos2] <> "Bloqueio/Liberacao"
          then hide frame frame-a no-pause.
          if  esqregua 
          then do:
            if esqcom1[esqpos1] = "Inclusao" 
            then do transaction with frame ftit2:
                if movcre.fechado
                then do:
                    message "Movimento Fechado".
                    pause.
                    hide message.
                    undo, retry.
                end.
                    
                vtitpar = 1.
                update vforcod.
                find forne where forne.forcod = vforcod no-lock.
                display forne.fornom.
                update vtitnum 
                       vtitpar.
                find first movcre where movcre.titano   = vano    and
                                        movcre.titmes   = vmes    and
                                        movcre.etbcod   = vetbcod and
                                        movcre.clifor   = vclifor and
                                        movcre.titnum   = vtitnum and
                                        movcre.titpar   = vtitpar no-error.
                if avail movcre
                then do:
                    message "movimento ja Existe".
                    undo, retry.
                end.
                update vtitdtemi
                       vtitdtven
                       vtitvlcob.
                       
                create movcre.
                assign movcre.titano   = vano
                       movcre.titmes   = vmes
                       movcre.titsit   = "LIB" 
                       movcre.etbcod   = 999 
                       movcre.titdtinc = today 
                       movcre.titman   = "INCLUIDO"
                       movcre.clifor   = vforcod 
                       movcre.titnum   = vtitnum 
                       movcre.titpar   = vtitpar
                       movcre.titdtemi = vtitdtemi 
                       movcre.titdtven = vtitdtven
                       movcre.titvlcob = vtitvlcob.
                salcre.salfin = salcre.salfin + movcre.titvlcob.
                recatu1 = recid(movcre).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do transaction with frame fmovcre:
                if movcre.fechado
                then do:
                    message "Movimento Fechado".
                    pause.
                    hide message.
                    undo, retry.
                end.
                 
                vtitvlcob = movcre.titvlcob.
                update movcre.clifor column-label "Fornecedor"
                       movcre.titnum
                       movcre.titpar
                       movcre.titdtemi
                       movcre.titdtven
                       movcre.titvlcob with no-validate.

                if movcre.titman = "EXCLUIDO"
                then salcre.salfin = salcre.salfin + movcre.titvlcob.
                else salcre.salfin = salcre.salfin - vtitvlcob +                                      movcre.titvlcob.
                assign movcre.titman = "ALTERADO".       

            end.
            if esqcom1[esqpos1] = "Consulta" or esqcom1[esqpos1] = "Exclusao"
            then do:
                disp movcre.titnum   colon 15
                     movcre.titpar   colon 15
                     movcre.titdtemi colon 15
                     movcre.titdtven colon 15
                     movcre.titvlcob colon 15
                     movcre.titdtpag colon 15
                        with frame fjurdes side-label width 80 
                                color white/cyan.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do transaction
                    with frame f-exclui overlay row 6 1 column centered.
                if movcre.fechado
                then do:
                    message "Movimento Fechado".
                    pause.
                    hide message.
                    undo, retry.
                end.
                 
                message "Confirma Exclusao de movcre"
                            movcre.titnum ",Parcela" movcre.titpar
                update sresp.
                if not sresp
                then leave.
                if movcre.titman = "EXCLUIDO"
                then do:    
                    message "Movimento ja Excluido".
                    undo, retry.
                end.
                
                /*
                find next movcre where movcre.titano = vano and
                                       movcre.titmes = vmes no-lock no-error.
                if not available movcre
                then do:
                    find movcre where recid(movcre) = recatu1.
                    find prev movcre where movcre.titano = vano and
                                           movcre.titmes = vmes 
                                                no-lock no-error.

                end.
                recatu2 = if available movcre
                          then recid(movcre)
                          else ?.
                find movcre where recid(movcre) = recatu1.
                delete movcre.
                recatu1 = recatu2.
                */
                movcre.titman = "EXCLUIDO".
                salcre.salfin = salcre.salfin - movcre.titvlcob.

                leave.
            end.
          end.
          else do:
            if  esqcom2[esqpos2] = "Fechamento"
            then do:
                if movcre.fechado
                then do:
                    message "Deseja Abrir o Movimento" update sresp.
                    if sresp
                    then do:
                        for each movcre where movcre.titano = vano and
                                              movcre.titmes = vmes:
                            do transaction:
                                movcre.fechado = no.
                            end.
                            display movcre.titnum with frame f-fec
                                    side-label centered row 10. 
                            pause 0.
                        end.
                    
                        find salcre where salcre.salano = vano and
                                          salcre.salmes = vmes no-error.
                        do transaction:
                            salcre.fechado = no.
                        end.
                        leave.

                    end.
                end.
                else do: 
                    message "Confirma Fechamento de saldo" update sresp.
                    if sresp
                    then do:
                        for each movcre where movcre.titano = vano and
                                              movcre.titmes = vmes:
                            do transaction:
                                movcre.fechado = yes.
                            end.
                            display movcre.titnum with frame f-fec1
                                    side-label centered row 10. 
                            pause 0.
                        end.
                    
                        find salcre where salcre.salano = vano and
                                          salcre.salmes = vmes no-error.
                        do transaction:
                            salcre.fechado = yes.
                        end.
                        
                        leave.
                    end.
                end.    
            end.

            hide frame f-com2 no-pause.
            if  esqcom2[esqpos2] = "Pagamento/Cancelamento"
            then if  movcre.titsit = "LIB" or movcre.titsit = "IMP" or
                     movcre.titsit = "CON"
              then do transaction
                        with frame f-Paga overlay row 6 1 column centered.
                if movcre.fechado
                then do:
                    message "Movimento Fechado".
                    pause.
                    hide message.
                    undo, retry.
                end.
                 
                display movcre.titnum    colon 13
                        movcre.titpar    colon 33 label "Pr"
                        movcre.titdtemi  colon 13
                        movcre.titdtven  colon 13
                        movcre.titvlcob  colon 13 label "Vl.Cobr."
                            with frame fdadpg side-label
                                overlay row 6 color white/cyan width 40.
                 assign movcre.titdtpag = today.
                 update movcre.titdtpag with frame fpag1.
                 movcre.titvlpag = movcre.titvlcob.
                 update movcre.titvlpag with frame fpag1.
                 assign movcre.titsit = "PAG"
                        movcre.titman = "ALTERADO".
                 salcre.salfin = salcre.salfin - movcre.titvlcob.
                 recatu1 = recid(movcre).
                 leave.
              end.
              else if movcre.titsit = "PAG" 
              then do:
                
                display movcre.titnum
                        movcre.titpar
                        movcre.titdtemi
                        movcre.titdtven
                        movcre.titvlcob.
                if movcre.fechado
                then do:
                    message "Movimento Fechado".
                    pause.
                    hide message.
                    undo, retry.
                end.
                 
                message "Confirma o Cancelamento do Pagamento ?" update sresp.
                if sresp  
                then do transaction: 
                    assign movcre.titsit    = "LIB" 
                           movcre.titdtpag  = ? 
                           movcre.titvlpag  = 0
                           movcre.titman    = "ALTERADO"
                    salcre.salfin = salcre.salfin + movcre.titvlcob.
                    
                end.
                recatu1 = recid(movcre).
                next bl-princ.
              end.
          end.
          view frame frame-a.
          view frame f-com2 .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        
        find salcre where salcre.salano = vano and
                          salcre.salmes = vmes no-error.
        display salcre.salano
                salcre.salmes 
                salcre.salini 
                salcre.salfin with frame f-salcre side-label 
                            no-box row 4 centered color black/cyan.
    
        display movcre.clifor 
                movcre.titnum 
                movcre.titpar    
                movcre.titvlcob  
                movcre.titdtemi  
                movcre.titdtven  
                movcre.titdtpag  
                movcre.titsit 
                movcre.titman
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(movcre).
   end.
end.
end.

