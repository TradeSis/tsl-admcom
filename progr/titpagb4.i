def var vmoecod like fin.moeda.moecod.
def var i-senx           as int.
def var vsenhax          as char format "x(6)".
def var vsenha1x         like vsenhax.
def var vpag             as   log.
        vpag = no.
        if vpag then leave.
        display with frame flado column 42 side-label
                title " Pagamento " color white/cyan width 38 row 6.
        assign titulo.titdtpag = vdtpag
               titulo.titdtpag = vdate
               titulo.datexp   = today
               titulo.cxacod   = 99
               titulo.cxmdat   = today.
        update titulo.titdtpag colon 15 with frame flado.
        i-senx = 0.
        repeat on endkey undo, leave bl-princ.

            UPDATE vetbcobra       colon 15 label "Est.Cobrador"
                   with frame flado.
            /** HELIO 09052024 ENCHENTE 
            if /*vetbcobra <> 990 and
               vetbcobra <> 991 and*/ 
               vetbcobra <> 992 and 
               /*vetbcobra <> 995 and
               vetbcobra <> 996 and*/
               vetbcobra <> 997 and
               /*vetbcobra <> 998 and
               vetbcobra <> 999 and*/
               vetbcobra <> 901 and
               vetbcobra <> 902 and
               vetbcobra <> 903 /*and
               vetbcobra <> 904*/
            then do:
                message "Filial Invalida".
                undo, retry.
            end.

            /* vsenha1x = "". */
            update vsenha1x BLANK
                       with frame fsenhax overlay centered row 10 color
                                black/red no-label.

            if vetbcobra = 904 and vsenha1x <> "102414"
            then do:
                message "Senha Invalida".
                undo, retry.
            end.

            if vetbcobra = 901
            then do:
                if vsenha1x <> "54678"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.
            if vetbcobra = 902 
            then do:
                if vsenha1x <> "29024"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.
            if vetbcobra = 903 
            then do:
                if vsenha1x <> "76561"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.

            if vetbcobra = 990
            then do:
                if vsenha1x <> "7412"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.
            if vetbcobra = 991 
            then do:
                if vsenha1x <> "79787"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.
            if vetbcobra = 9992
            then do:
                find first func where func.funcod = sfuncod and
                        func.etbcod = setbcod no-lock no-error.
                if not avail func or func.senha <> vsenha1x
                then do:
                    message "Senha Invalida" vsenha1x func.senha.  pause.
                    undo, retry.
                end.
            end.

            if vetbcobra = 992
            then do:
                if vsenha1x <> "76674"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.                                

            if vetbcobra = 995 
            then do:
                if vsenha1x <> "5563"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.

             
            if vetbcobra = 996
            then do:
                if vsenha1x <> "2469"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.
 
            if vetbcobra = 997
            then do:
                if vsenha1x <> "34521"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.
 
            if vetbcobra = 998
            then do:
                if vsenha1x <> "1210"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.
            
            if vetbcobra = 999
            then do:
                if vsenha1x <> "1001"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
            end.
            HELIO **/
  
            
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                bell.
                message "Estabelecimento nao Cadastrado !!".
                undo, retry.
            end.
            leave.
        end.
        /*** seleciona moeda ****/
            /* HELIO 09052025 ENCHENTE
            run sel-moeda.
            if keyfunction(lastkey) = "END-ERROR"
            then undo.
            */
            vmoecod = "PPR". /* helio 09052024 */
            disp vmoecod colon 15 with frame flado.
            find fin.moeda where fin.moeda.moecod = vmoecod no-lock no-error.
            if not avail fin.moeda
            then do:
                message "Moeda n�o cadastrada.".
                pause.
                undo.
            end. 
            disp fin.moeda.moenom no-label with frame flado.   
        /**********************/    

        assign vdtpag    = titulo.titdtpag
               vdate     = titulo.titdtpag
               /* helio 09052024 vtitvlpag = 0 */
               vtitvlpag = titulo.titvlcob. /* helio 09052024 */
        hide frame flado no-pause. 
        do on error undo, retry:
            /* helio 09052024
            update vtitvlpag validate
                  (vtitvlpag > 0 /*or vtitvlpag = titulo.titvlpag*/,
                                        "Valor Invalido") colon 15
                    with frame flado.

            if vtitvlpag > titulo.titvlcob
            then do:
                bell.
                message "Valor pagamento maior do que o Cobrado !!".
                undo, retry.
            end.
            */
        end.
        /** HELIO 09052024 ENCHENTE
        titulo.cobcod = 2.
        if vtitvlpag >= titulo.titvlcob
        then titulo.titjuro = vtitvlpag - titulo.titvlcob.
        else do:
            assign sresp = yes.
            display "  Confirma PAGAMENTO PARCIAL ?"
                                with frame fpag color messages
                                width 40 overlay row 10 centered.
            update sresp no-label with frame fpag.
            hide frame fpag no-pause.
            if sresp
            then do:
                find last btitulo use-index titnum where
                          btitulo.empcod   = wempre.empcod and
                          btitulo.titnat   = titulo.titnat and
                          btitulo.modcod   = titulo.modcod and
                          btitulo.etbcod   = titulo.etbcod and
                          btitulo.clifor   = titulo.clifor and
                          btitulo.titnum   = titulo.titnum.
                create ctitulo.
                assign ctitulo.empcod = btitulo.empcod
                       ctitulo.modcod = btitulo.modcod
                       ctitulo.clifor = btitulo.clifor
                       ctitulo.titnat = btitulo.titnat
                       ctitulo.etbcod = btitulo.etbcod
                       ctitulo.titnum = btitulo.titnum
                       ctitulo.cobcod = titulo.cobcod
                       ctitulo.titpar   = btitulo.titpar + 1
                       ctitulo.titdtemi = titulo.titdtemi
                       ctitulo.titdtven = titulo.titdtven
                       ctitulo.titvlcob = titulo.titvlcob - vtitvlpag
                       ctitulo.titnumger = titulo.titnum
                       ctitulo.titparger = titulo.titpar
                       ctitulo.titsit    = "LIB"
                       ctitulo.titobs[1] = "IMP"
                       ctitulo.datexp    = today.
                display ctitulo.titnum
                        ctitulo.titpar
                        ctitulo.titdtemi
                        ctitulo.titdtven
                        ctitulo.titvlcob
                        with frame fmos width 40 1 column
                             title " Titulo Gerado " overlay
                                              column 41 row 10.
            end.
            else titulo.titdesc = titulo.titvlcob - vtitvlpag.
        end.
        update titulo.titjuro colon 15
               with frame flado.
        l-desc:
        do on endkey undo.
            update titulo.titdesc colon 15
                   with frame flado.
            if titulo.titdesc >= titulo.titvlcob
            then do:
                message "Desconto maior que o valor principal".
                undo l-desc.
            end.
        end.
        **/
        
        assign titulo.titvlpag = vtitvlpag + titulo.titjuro
               titulo.titvlpag = titulo.titvlpag - titulo.titdesc
               titulo.titsit   = "PAG"
               titulo.etbcobra = vetbcobra
               titulo.cxacod   = 99
               titulo.moecod   = vmoecod.
               
        if avail func
        then titulo.titparger = func.funcod.       
        
        sresp = no.
        /* HELIO 09052024 ENCHENTE        
        message "Deseja quitar todo contrato" update sresp.
        if sresp 
        then do: 
            
            for each btitulo where btitulo.empcod   = titulo.empcod and
                                   btitulo.titnat   = titulo.titnat and
                                   btitulo.modcod   = titulo.modcod and
                                   btitulo.etbcod   = titulo.etbcod and
                                   btitulo.clifor   = titulo.clifor and
                                   btitulo.titnum   = titulo.titnum and
                                   btitulo.titpar   > titulo.titpar:

                if btitulo.titdtpag <> ? 
                then next.

                assign btitulo.titvlpag = titulo.titvlpag
                       btitulo.titdtpag = titulo.titdtpag
                       btitulo.titsit   = "PAG"
                       btitulo.etbcobra = vetbcobra
                       btitulo.cxacod   = 99
                       btitulo.cxmdat   = if btitulo.cxmdat = ?
                                          then today
                                          else btitulo.cxmdat
                       btitulo.datexp = today
                       btitulo.exportado = no
                       btitulo.moecod = vmoecod.

                        
            end.            

        end.
        */
procedure sel-moeda:
    def var vmoeda as char extent 4 format "x(25)".
    def var smoeda as log format "Sim/Nao".
    def var vindex as int.
    repeat on endkey undo:
    if vetbcobra = 901
    then assign
        vmoeda[1] = "DEV-Devolucao"
        vmoeda[2] = "DVT-Dev Vale Troca"
        vmoeda[3] = "EXC-Exclusao"
        vmoeda[4] = "JUD-Ordem Judicial".
    else if vetbcobra = 902 or vetbcobra = 903
    then vmoeda[1] = "NOV-Novacao".
    else if vetbcobra = 992
    then vmoeda[1] = "SEG-Seguros".
    else if vetbcobra = 997
    then vmoeda[1] = "DFO-Desconto folha".
    disp vmoeda with frame f-moeda 1 down no-label 1 column
        title " finalidade ".
    choose field vmoeda with frame f-moeda.
    vindex = frame-index.
    if vmoeda[vindex] = "" then undo.
    if vmoeda[1] <> "" and vmoeda[2] <> ""
    then do:
        smoeda = no.
        message "Confirma finalidade selecionada?" update smoeda.
        if not smoeda
        then undo.
    end.
    vmoecod = substr(vmoeda[vindex],1,3).
    clear frame f-moeda all.
    hide frame f-moeda no-pause.
    leave.
    end.                   
end procedure.
