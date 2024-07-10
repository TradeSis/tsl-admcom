/*** KPMG ****/
{admcab.i}

def buffer btitulo for titulo.

{setbrw.i}

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def NEW SHARED temp-table tt-modalidade-selec /* #1 */
    field modcod as char.

def var vval-carteira as dec.
def var wvlpri      like titulo.titvlpag.
def var wvlpag      like titulo.titvlpag.
def var vdata       like titulo.titdtemi.
def var vparc       like titulo.titvlcob.
DEF VAR vpago       like titulo.titvlpag.
def var vdesc       like titulo.titvldes.
def var vjuro       like titulo.titjuro.
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var vetbcod like estab.etbcod.
def buffer bestab for estab.
def var varquivo as char.
def var vparcial as dec.
def var par-origem as char.
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def temp-table tt-moeda
    field moecod as char
    field valor as dec.

def temp-table acum-moeda
    field etbcod like estab.etbcod
    field moecod like moeda.moecod
    field moenom like moeda.moenom format "x(20)"
    field valor as dec             format ">>>,>>>,>>9.99"
    index i1 etbcod moecod.
 
def temp-table tt-titmoe
    field etbcod like estab.etbcod
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field moecod like moeda.moecod
    field moenom like moeda.moenom  format "x(20)"
    field valor as dec              format ">>>,>>>,>>9.99"
    index m1 etbcod titnum titpar
    .
    
def temp-table tt-titulo like titulo
    field pc-origem like par-origem      column-label "Ori"  format "xx"
    field lc-origem as char
    field no-tit as log init no
    .

def temp-table pag-titulo no-undo
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titvlcob like titulo.titvlcob
    field titvlpag like titulo.titvlpag
    index i1 clifor titnum titpar
    .
def temp-table pag-titmoe no-undo
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field moecod like titulo.moecod
    field moenom like moeda.moenom
    field titvlpag like titulo.titvlpag
    index i1 clifor titnum titpar
    .

def temp-table tt-resumo 
    field etbcod like estab.etbcod
    field parc as dec
    field paga as dec
    field juro as dec
    field des as dec
    index i1 etbcod
    .

def var vs-paga as char.
def var vclinom like clien.clinom.
form tt-titulo.etbcod   column-label "Fil."
                 tt-titulo.etbcobra column-label "Cob."
                 vs-paga column-label "Rec" format "x(3)"
                 tt-titulo.titnum   column-label "Contr."
                 tt-titulo.titpar   column-label "Pr."
                 tt-titulo.pc-origem column-label "Ori"  format "xx"
                 tt-titulo.clifor   column-label "Cliente"
                 vclinom   column-label "Nome" format "x(30)"
                 tt-titulo.titdtven
                 tt-titulo.titdtpag
                 tt-titulo.titvlcob(total) 
                 tt-titulo.titvlpag(total)
                         column-label "Valor Pago" format ">>>,>>9.99" 
                 tt-titulo.titjuro(total)     format ">>>,>>9.99"  
                 tt-titulo.titvldes(total)    format "->>,>>9.99"  
                 tt-titulo.cxacod column-label "CXA" format ">>9"
                 tt-titmoe.moecod no-label
                         tt-titmoe.moenom no-label
                         tt-titmoe.valor    no-label format ">>>,>>9.99"
 
                 with no-box width 200 frame flin2 down.
             
def var vlin as int.
def var vmoenom like moeda.moenom.

def var tipo-sel as char format "x(15)" extent 4
    init["Resumo","Resumo moeda","Geral","Geral moeda"].
def var vindex as int.    

repeat with 1 down side-label width 80 row 3 :
    
    hide frame fff.
    for each tt-modalidade-selec: delete tt-modalidade-selec. end.
    
    update vetbcod colon 25 /*validate(vetbcod <> 0,"")*/.
    if vetbcod > 0
    then do:
        find bestab where bestab.etbcod = vetbcod no-lock.
        display bestab.etbnom no-label.
    end.
    else disp "Todas as filiais" @ bestab.etbnom.
      
    vdata = today - 1.
    /*
    update vdata colon 25 label "Recebimento".
    */
    vdti = vdata.
    vdtf = vdata.
    
    update vdti colon 25 label "Recebimento"
           vdtf label "a".
    
    assign sresp = false.
           
    update sresp label "Seleciona Modalidades" colon 25
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with side-label
           width 80.
    /*
    if sresp
    then run selec-modal.p ("REC"). /* #1 */
    else undo.
    assign vmod-sel = "  ".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
    end.
      
    display vmod-sel format "x(40)" no-label.
    */
    assign
        vpago = 0
        vdesc = 0
        vjuro = 0
        vparcial = 0.

    for each acum-moeda: delete acum-moeda. end.
    for each tt-titulo: delete tt-titulo. end.
    for each tt-titmoe: delete tt-titmoe. end.
    do vdata = vdti to vdtf:
        disp vdata label "Processando data"
            with frame f-disp 1 down side-label
            no-box color message centered.
        pause 0.

        for each estab where (if vetbcod > 0
                             then estab.etbcod = vetbcod else true)
                             no-lock:
            disp estab.etbcod label "Filial"  with frame f-disp.
            pause 0.
        
            for each nissei.titmoeda where
                                titmoeda.titnat = no and
                                titmoeda.etbcobra = estab.etbcod and
                                titmoeda.titdtpag = vdata 
                              no-lock:
            
                /****                       
                create nissei.titmoeda.
                assign
                    titmoeda.empcod = tt-titmoe.empcod
                    titmoeda.titnat = tt-titmoe.titnat
                    titmoeda.modcod = tt-titmoe.modcod
                    titmoeda.etbcod = tt-titmoe.etbcod
                    titmoeda.clifor = tt-titmoe.clifor
                    titmoeda.titnum = tt-titmoe.titnum
                    titmoeda.titpar = tt-titmoe.titpar
                    titmoeda.titdtemi = tt-titmoe.titdtemi
                    titmoeda.moecod = tt-titmoe.moecod
                    titmoeda.titvlpag = tt-titmoe.titvlpag
                    titmoeda.titdtven = tt-titmoe.titdtven
                    titmoeda.titdtpag = tt-titmoe.titdtpag
                    titmoeda.etbcobra = tt-titmoe.etbcobra
                            . 
                ****/ 

                find first tt-titulo where
                           tt-titulo.empcod = titmoeda.empcod and
                           tt-titulo.titnat = titmoeda.titnat and
                           tt-titulo.modcod = titmoeda.modcod and
                           tt-titulo.etbcod = titmoeda.etbcod and
                           tt-titulo.clifor = titmoeda.clifor and
                           tt-titulo.titnum = titmoeda.titnum and
                           tt-titulo.titpar = titmoeda.titpar and
                           tt-titulo.titdtemi = titmoeda.titdtemi
                           no-lock no-error.
                if not avail tt-titulo
                then do:
                    create tt-titulo.
                    find titulo where 
                            titulo.empcod = titmoeda.empcod and
                            titulo.titnat = titmoeda.titnat and
                            titulo.modcod = titmoeda.modcod and
                            titulo.etbcod = titmoeda.etbcod and
                            titulo.clifor = titmoeda.clifor and
                            titulo.titnum = titmoeda.titnum and
                            titulo.titpar = titmoeda.titpar and
                            titulo.titdtemi = titmoeda.titdtemi
                            no-lock no-error.
                    if avail titulo
                    then do:
                        buffer-copy titulo to tt-titulo.
                        assign
                            vparc = vparc + tt-titulo.titvlcob
                            vjuro = vjuro + tt-titulo.titjuro
                            vdesc = vdesc + tt-titulo.titvldes
                            .
                                 
                        if acha("PAGAMENTO-PARCIAL",tt-titulo.titobs[1]) <> ?
                        then vparcial = vparcial + tt-titulo.titvlpag.
                        vpago = vpago + tt-titulo.titvlpag.

                        tt-titulo.pc-origem = 
                                if acha("PARCIAL",tt-titulo.titobs[1]) <> ?
                                    then string(tt-titulo.titparger) else "" .
                        tt-titulo.lc-origem = 
                                if tt-titulo.cxacod < 30 or 
                                   tt-titulo.cxacod > 98
                                then "ADM" else "P2K".

                        find first tt-resumo where 
                             tt-resumo.etbcod = tt-titulo.etbcobra no-error.
                        if not avail tt-resumo
                        then do:
                            create tt-resumo.
                            tt-resumo.etbcod = tt-titulo.etbcobra.
                        end.
                        assign
                        tt-resumo.parc = tt-resumo.parc + tt-titulo.titvlcob
                        tt-resumo.paga = tt-resumo.paga + tt-titulo.titvlpag
                        tt-resumo.juro = tt-resumo.juro + tt-titulo.titjuro
                        tt-resumo.des = tt-resumo.des + tt-titulo.titvldes
                        .
                    end.
                    else assign
                           tt-titulo.empcod = titmoeda.empcod 
                           tt-titulo.titnat = titmoeda.titnat 
                           tt-titulo.modcod = titmoeda.modcod 
                           tt-titulo.etbcod = titmoeda.etbcod 
                           tt-titulo.clifor = titmoeda.clifor 
                           tt-titulo.titnum = titmoeda.titnum 
                           tt-titulo.titpar = titmoeda.titpar 
                           tt-titulo.titdtemi = titmoeda.titdtemi
                           tt-titulo.titdtven = titmoeda.titdtven
                           tt-titulo.titdtpag = titmoeda.titdtpag
                           tt-titulo.etbcobra = titmoeda.etbcobra
                           tt-titulo.cxacod   = titmoeda.cxacod
                           tt-titulo.no-tit    = yes.
                           .

                end.
                if tt-titulo.no-tit
                then do:
                    assign
                        tt-titulo.titvlcob =                             tt-titulo.titvlcob + titmoeda.titvlpag 
                        tt-titulo.titvlpag =                                 tt-titulo.titvlpag + titmoeda.titvlpag
                        vparc = vparc + titmoeda.titvlpag
                        vpago = vpago + titmoeda.titvlpag.

                    tt-titulo.lc-origem = 
                                if tt-titulo.cxacod < 30 or 
                                   tt-titulo.cxacod > 98
                                then "ADM" else "P2K".

                    find first tt-resumo where 
                         tt-resumo.etbcod = tt-titulo.etbcobra no-error.
                    if not avail tt-resumo
                    then do:
                        create tt-resumo.
                        tt-resumo.etbcod = tt-titulo.etbcobra.
                    end.
                    assign
                        tt-resumo.parc = tt-resumo.parc + titmoeda.titvlpag
                        tt-resumo.paga = tt-resumo.paga + titmoeda.titvlpag
                        .
                end.
                
                find moeda where 
                     moeda.moecod = titmoeda.moecod no-lock no-error.
                if avail moeda
                then vmoenom = moeda.moenom.
                else do:
                    vmoenom = "Moeda nao cadastrada".
                    if titmoeda.moecod = "NOV"
                    then vmoenom = "NOVACAO".
                end.    

                create tt-titmoe.
                assign
                    tt-titmoe.etbcod = titmoeda.etbcod
                    tt-titmoe.titnum = titmoeda.titnum
                    tt-titmoe.titpar = titmoeda.titpar
                    tt-titmoe.moecod = titmoeda.moecod
                    tt-titmoe.moenom = vmoenom
                    tt-titmoe.valor  = titmoeda.titvlpag
                    .

                find first acum-moeda where
                           acum-moeda.etbcod = titmoeda.etbcobra and
                           acum-moeda.moecod = titmoeda.moecod
                           no-error.
                if not avail acum-moeda   
                then do:
                    create acum-moeda.
                    assign
                        acum-moeda.etbcod = titmoeda.etbcobra
                        acum-moeda.moecod = titmoeda.moecod
                        acum-moeda.moenom = vmoenom
                        .

                end.        
                acum-moeda.valor = acum-moeda.valor + titmoeda.titvlpag.
                
                find first acum-moeda where
                           acum-moeda.etbcod = ? and
                           acum-moeda.moecod = titmoeda.moecod
                           no-error.
                if not avail acum-moeda   
                then do:
                    create acum-moeda.
                    assign
                        acum-moeda.etbcod = ?
                        acum-moeda.moecod = titmoeda.moecod
                        acum-moeda.moenom = vmoenom
                        .
                end.        
                acum-moeda.valor = acum-moeda.valor + titmoeda.titvlpag.
    
            end.
            def var vtotal as dec format ">>>,>>>9.99".     
               /*
            for each tt-titulo no-lock:
                vtotal = 0.
                for each tt-titmoe where
                         tt-titmoe.etbcod = tt-titulo.etbcod and
                         tt-titmoe.titnum = tt-titulo.titnum and
                         tt-titmoe.titpar = tt-titulo.titpar
                         no-lock:
                    
                    vtotal = vtotal + tt-titmoe.valor.
                end.
                if vtotal <> tt-titulo.titvlpag
                then do:
                    message tt-titulo.titnum tt-titulo.clifor
                    tt-titulo.titpar vtotal tt-titulo.titvlpag.
                    pause.
                end.    
            end. */                                           /******************************************
        
            run pdv-moeda(input estab.etbcod, input vdata).
          
            for each tt-modalidade-selec:
                for each titulo use-index titdtpag
                        where titulo.empcod = wempre.empcod and
                              titulo.titnat = no and
                              titulo.modcod = tt-modalidade-selec.modcod and
                              titulo.titdtpag = vdata and
                              titulo.etbcobra = estab.etbcod
                              no-lock:

                    if titulo.titpar = 0
                    then next.
                    if titulo.clifor = 1
                    then next.
            assign
                vparc = vparc + titulo.titvlcob
                vjuro = vjuro + /*if titulo.titjuro = titulo.titdesc or
                                   (titulo.modcod begins "CP" and
                                    titulo.cxacod < 30)
                                then 0
                                else*/ titulo.titjuro
                vdesc = vdesc + /*if titulo.titjuro = titulo.titdesc
                                then 0
                                else titulo.titdesc*/
                                 titulo.titvldes.
                                 
            if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
            then vparcial = vparcial + titulo.titvlpag
                            /*- titulo.titjuro + titulo.titvldes*/.
            vpago = vpago + titulo.titvlpag
                                 /*- titulo.titjuro + titulo.titvldes*/.

            for each tt-moeda. delete tt-moeda. end.
            run titulo-moeda.
        
            find clien where clien.clicod = titulo.clifor no-lock no-error.
            create tt-titulo.
            assign
                tt-titulo.etbcod = titulo.etbcod
                tt-titulo.etbcobra = titulo.etbcobra
                tt-titulo.titnum = titulo.titnum
                tt-titulo.titpar = titulo.titpar
                tt-titulo.pc-origem = if acha("PARCIAL",titulo.titobs[1]) <> ?
                                    then string(titulo.titparger) else ""
                tt-titulo.clifor = titulo.clifor
                tt-titulo.clinom = if avail clien then clien.clinom else ""
                tt-titulo.titdtven = titulo.titdtven
                tt-titulo.titdtpag = titulo.titdtpag
                tt-titulo.titvlcob = titulo.titvlcob 
                tt-titulo.titvlpag = titulo.titvlpag
                tt-titulo.titjuro = titulo.titjuro
                tt-titulo.titvldes  = titulo.titvldes
                tt-titulo.p2k = if titulo.cxacod < 30 or titulo.cxacod > 98
                                then no else yes
                .
                
            find tt-resumo where tt-resumo.etbcod = titulo.etbcobra no-error.
            if not avail tt-resumo
            then do:
                create tt-resumo.
                tt-resumo.etbcod = titulo.etbcobra.
            end.
            assign
                tt-resumo.parc = tt-resumo.parc + titulo.titvlcob
                tt-resumo.paga = tt-resumo.paga + titulo.titvlpag
                    /*
                    (titulo.titvlpag - titulo.titjuro + titulo.titdesc)
                    */
                tt-resumo.juro = tt-resumo.juro + titulo.titjuro
                            /*
                            (if titulo.titjuro = titulo.titdesc or
                                (titulo.modcod begins "CP" and
                                titulo.cxacod < 30)
                                then 0 else titulo.titjuro)
                            */
                tt-resumo.des = tt-resumo.des + titulo.titvldes
                            /*
                             (if titulo.titjuro = titulo.titdesc
                                then 0 else titulo.titvldes)
                            */
                .

            for each tt-moeda where tt-moeda.valor <> 0:
                find moeda where 
                     moeda.moecod = tt-moeda.moecod no-lock no-error.
                if avail moeda
                then vmoenom = moeda.moenom.
                else do:
                    vmoenom = "Moeda nao cadastrada".
                    if tt-moeda.moecod = "NOV"
                    then vmoenom = "NOVACAO".
                end.    

                create tt-titmoe.
                assign
                    tt-titmoe.etbcod = titulo.etbcod
                    tt-titmoe.titnum = titulo.titnum
                    tt-titmoe.titpar = titulo.titpar
                    tt-titmoe.moecod = tt-moeda.moecod
                    tt-titmoe.moenom = vmoenom
                    tt-titmoe.valor  = tt-moeda.valor
                    .
                find first acum-moeda where
                           acum-moeda.etbcod = titulo.etbcobra and
                           acum-moeda.moecod = tt-moeda.moecod
                           no-error.
                if not avail acum-moeda   
                then do:
                    create acum-moeda.
                    assign
                        acum-moeda.etbcod = titulo.etbcobra
                        acum-moeda.moecod = tt-moeda.moecod
                        acum-moeda.moenom = vmoenom
                        .

                end.        
                acum-moeda.valor = acum-moeda.valor + tt-moeda.valor.
                
                find first acum-moeda where
                           acum-moeda.etbcod = ? and
                           acum-moeda.moecod = tt-moeda.moecod
                           no-error.
                if not avail acum-moeda   
                then do:
                    create acum-moeda.
                    assign
                        acum-moeda.etbcod = ?
                        acum-moeda.moecod = tt-moeda.moecod
                        acum-moeda.moenom = vmoenom
                        .
                end.        
                acum-moeda.valor = acum-moeda.valor + tt-moeda.valor.
    
            end.
            end.
        end.
        ********************************/
        
        end.

    end.
    hide frame f-disp.
    
    /*if vpago = 0 and
       vdesc = 0 and
       vjuro = 0 and
       bestab.etbcod <> 999
    then do:
        message "Nenhum Pagamento  efetuado".
        undo.
    end.
    if bestab.etbcod <> 999
    then*/ do:
    
        display vparc label "Valor Parcela"  format ">>>,>>>,>>9.99"
                vpago label "Valor Pago"     format ">>>,>>>,>>9.99"
                vjuro label "Valor Juro"     format ">>>,>>>,>>9.99"
                vdesc label "Valor Desconto" format ">>>,>>>,>>9.99"   
                vparcial label "Valor Pago Parcial" format ">>>,>>>,>>9.99"
                with frame ff width 80 no-box 1 column.
        pause 0.
        
        form with frame fff column 40 overlay
                         row 8 9 down.
                         
        /*
        for each acum-moeda where
                 acum-moeda.etbcod = ? no-lock:
            find moeda where moeda.moecod = acum-moeda.moecod
                    no-lock no-error.
            disp acum-moeda.moecod
                 moeda.moenom when avail moeda
                 acum-moeda.valor format ">>,>>>,>>9.99" (total)
                 with frame fff no-box down column 35 overlay
                 row 8.
            down with frame fff.     
        end. 
        */

        assign
            a-seeid = -1
            a-recid = -1
            a-seerec = ?.
            
        def var vazio as log.
        vazio = no.

        vtotal = 0.
        for each acum-moeda where acum-moeda.etbcod = ? no-lock:
            vtotal = vtotal + acum-moeda.valor.
        end.
        disp vtotal label "Total" format ">>>,>>>,>>9.99"
                with frame f-tot
            row 21 column 60 no-box overlay side-label.
        
        {sklcls2.i
            &file = acum-moeda
            &help = "                                       F1-Relatorios F4-Sair"
            &cfield = acum-moeda.moenom
            &noncharacter = /* 
            &ofield = " acum-moeda.moecod
                        acum-moeda.valor
                      "  
            &aftfnd1 = " "
            &where  = " acum-moeda.etbcod = ? "
            &aftselect1 = " 
                        next keys-loop.
                        "
            &go-on = TAB 
            &naoexiste1 = " message color red/with
                            ""Nenhum registro encontrado.""
                            view-as alert-box.
                            vazio = yes.
                            leave keys-loop.
                            " 
            &otherkeys1 = " 
                            if keyfunction(lastkey) = ""GO""
                            then leave keys-loop.
                            
                        "
            &form   = " frame fff "
        }
        
        if keyfunction(lastkey) <> "GO"
        then vazio = yes.         
    end.

    if vazio then undo.

    form header
            wempre.emprazsoc
                    space(6) "PAGRE"   at 60
                    "Pag.: " at 71 page-number format ">>9" skip
                    "RESUMO RECEBIMENTO PARCELAS "   at 1
                    today format "99/99/9999" at 60
                    string(time,"hh:mm:ss") at 73
                    skip fill("-",80) format "x(80)" skip
                    with frame fcab no-label page-top no-box width 137.

    form header
            wempre.emprazsoc
                    space(6) "PAGRE"   at 60
                    "Pag.: " at 71 page-number format ">>9" skip
                    "GERAL RECEBIMENTO PARCELAS "   at 1
                    today format "99/99/9999" at 60
                    string(time,"hh:mm:ss") at 73
                    skip fill("-",80) format "x(80)" skip
                    with frame fcab1 no-label page-top no-box width 137.

    repeat on endkey undo:
    pause 0.
    vindex = 0.

    disp tipo-sel help "F4 - Retorna" with frame f-tsel 1 down 
    no-label row 16 overlay 1 column title "relatorio".
    choose field tipo-sel go-on(F4 PF4) with frame f-tsel .
    if keyfunction(lastkey) = "END-ERROR"
    THEN LEAVE.
    vindex = frame-index.
    if vindex = 1 or vindex = 2
    then sresumo = yes.
    else sresumo = no.
   
    sresp = yes.
    message "Confirma relatorio " tipo-sel[vindex] update sresp.
    if not sresp then undo.

    if sresumo
    then varquivo = "/admcom/relat/resumo-recebimento-parcelas." +
                    string(time).
    else varquivo = "/admcom/relat/geral-recebimento-parcelas." +
                string(time).
    output to value(varquivo). 
    
    if sresumo 
    then do:
        view frame fcab.
        for each tt-resumo where
                 tt-resumo.etbcod > 0 no-lock:
            disp          
                tt-resumo.etbcod column-label "Fil"
                tt-resumo.parc   column-label "Valor Parcela"
                tt-resumo.paga    column-label "Valor Pago"
                tt-resumo.juro   column-label "Valor Juro"
                tt-resumo.des    column-label "Valor Desconto"
                with frame f-resumo down width 120.
            if vindex = 2
            then
            for each acum-moeda where
                     acum-moeda.etbcod = tt-resumo.etbcod no-lock:
                disp acum-moeda.moecod no-label
                     acum-moeda.moenom no-label
                     acum-moeda.valor  no-label format ">>>,>>9.99"
                     with frame f-resumo.      
                down with frame f-resumo.              
            end.
            else down with frame f-resumo.
        end.
    end.
    else do:
        view frame fcab.

        for each tt-titulo where tt-titulo.titvlcob > 0 no-lock:
            
            find clien where clien.clicod = tt-titulo.clifor no-lock no-error.
            if avail clien
            then vclinom = clien.clinom.
            else vclinom = "".
            vs-paga = tt-titulo.lc-origem.

            disp tt-titulo.etbcod   column-label "Fil."
                 tt-titulo.etbcobra column-label "Cob."
                 vs-paga      
                 tt-titulo.titnum   column-label "Contr."
                 tt-titulo.titpar   column-label "Pr."
                 tt-titulo.pc-origem column-label "Ori"  format "xx"
                 tt-titulo.clifor   column-label "Cliente"
                 vclinom    column-label "Nome" format "x(30)"
                 tt-titulo.titdtven
                 tt-titulo.titdtpag
                 tt-titulo.titvlcob 
                 tt-titulo.titvlpag
                         column-label "Valor Pago" format ">>>,>>9.99" 
                 tt-titulo.titjuro     format ">>>,>>9.99"  
                 tt-titulo.titvldes   format "->>,>>9.99"  
                 tt-titulo.cxacod
                 with frame flin2.
            
            vlin = 0. 
            if vindex = 4
            then for each tt-titmoe where
                          tt-titmoe.etbcod = tt-titulo.etbcod and
                          tt-titmoe.titnum = tt-titulo.titnum and
                          tt-titmoe.titpar = tt-titulo.titpar
                          no-lock:
                    vlin = vlin + 1.
                    if vlin = 1
                    then do: 
                        disp tt-titmoe.moecod no-label
                         tt-titmoe.moenom no-label
                         tt-titmoe.valor    no-label format ">>>,>>9.99"
                         with frame flin2
                         .
                        down with frame flin2.   
                        
                    end. 
                    else if vlin > 1
                    then do:        
                        disp 
                            tt-titulo.etbcod   column-label "Fil."
                            tt-titulo.etbcobra column-label "Cob."
                            vs-paga
                            tt-titulo.titnum   column-label "Contr."
                            tt-titulo.titpar   column-label "Pr."
                            tt-titulo.pc-origem column-label "Ori"  format "xx"
                            tt-titulo.clifor   column-label "Cliente"
                            vclinom    column-label "Nome" format "x(30)"
                            tt-titulo.titdtven
                            tt-titulo.titdtpag
                            tt-titulo.cxacod
                            tt-titmoe.moecod no-label
                            tt-titmoe.moenom no-label
                            tt-titmoe.valor    no-label format ">>>,>>9.99"
                            with frame flin2
                            .

                         down with frame flin2.
                    end.
  
                end.                 
            else down with frame flin2.
        end.
    end.
        
        output close.
        
        run visurel.p (input varquivo, input "").

        leave.
    end.
end.

procedure titulo-moeda:
    def var pag-p2k as log.
    pag-p2k = no.
    def var vpaga as dec init 0.
    def var vt-paga like titulo.titvlcob.
    def var val-juro as dec.
    vt-paga = 0.
    if titulo.cxacod >= 30 and titulo.cxacod < 99 
        and titulo.modcod <> "VVI" 
        and titulo.moecod = "PDM"
    then do:
        vpaga = 0.
        for each   pag-titmoe where 
                    pag-titmoe.clifor = titulo.clifor and
                    pag-titmoe.titnum = titulo.titnum and
                    pag-titmoe.titpar = titulo.titpar
                    no-lock:
            pag-p2k = yes.
                
            find first moeda where moeda.moecod = pag-titmoe.moecod
                               no-lock no-error.

            find first tt-moeda where tt-moeda.moecod = pag-titmoe.moecod
                    no-error.
            if not avail tt-moeda
            then do:
                create tt-moeda.
                tt-moeda.moecod = pag-titmoe.moecod.
            end.        
            if vpaga + pag-titmoe.titvlpag <= titulo.titvlpag
            then assign
                     tt-moeda.valor = tt-moeda.valor + pag-titmoe.titvlpag
                     vpaga = vpaga + pag-titmoe.titvlpag
                        .
            else assign
                     tt-moeda.valor = tt-moeda.valor +
                                        (titulo.titvlpag - vpaga)
                     vpaga = vpaga + (titulo.titvlpag - vpaga)
                        .
        end.
    end.
    else if titulo.moecod = "PDM"
    then do:
        vpaga = 0.
        for each titpag where
                      titpag.empcod = titulo.empcod and
                      titpag.titnat = titulo.titnat and
                      titpag.modcod = titulo.modcod and
                      titpag.etbcod = titulo.etbcod and
                       titpag.clifor = titulo.clifor and
                      titpag.titnum = titulo.titnum and
                      titpag.titpar = titulo.titpar
                      no-lock:
                 
                find first moeda where  moeda.moecod = titpag.moecod
                               no-lock no-error.

                find first tt-moeda where tt-moeda.moecod = titpag.moecod
                    no-error.
            if not avail tt-moeda
            then do:
                create tt-moeda.
                tt-moeda.moecod = titpag.moecod.
            end.        
            tt-moeda.valor = tt-moeda.valor + titpag.titvlpag.
        end.
    end.
    else do:
        find first moeda where  moeda.moecod = titulo.moecod
                               no-lock no-error.

        find first tt-moeda where tt-moeda.moecod = titulo.moecod
                    no-error.
        if not avail tt-moeda
        then do:
                create tt-moeda.
                tt-moeda.moecod = titulo.moecod.
        end.        
        tt-moeda.valor = tt-moeda.valor + titulo.titvlpag.
    end.
    
end procedure.

procedure pdv-moeda:
    def input parameter p-etbcod like estab.etbcod.
    def input parameter p-data as date.
    def var vtroco as dec.
    for each pag-titulo. delete pag-titulo. end.
    for each pag-titmoe. delete pag-titmoe. end.
    for each pdvmov where
                 pdvmov.etbcod  = p-etbcod and
                 pdvmov.datamov = p-data no-lock:
        find first pdvmoeda of pdvmov
            where pdvmoeda.moecod = "CRE"
            no-lock no-error.
        if avail pdvmoeda then next.    
        for each pdvdoc of pdvmov where
            pdvdoc.clifor <> 1 and
            pdvdoc.titpar >= 0 
            no-lock:
            create pag-titulo.
            assign
                pag-titulo.clifor = pdvdoc.clifor
                pag-titulo.titnum = pdvdoc.contnum
                pag-titulo.titpar  = pdvdoc.titpar
                pag-titulo.titvlcob = pdvdoc.titvlcob
                pag-titulo.titvlpag = pdvdoc.valor
                .
             vtroco = 0.
             for each pdvmoeda of pdvmov no-lock:
                create pag-titmoe.
                assign
                    pag-titmoe.clifor = pdvdoc.clifor
                    pag-titmoe.titnum = pdvdoc.contnum
                    pag-titmoe.titpar  = pdvdoc.titpar
                    vtroco = pdvmov.valortroco *
                             (pdvmoe.valor / 
                             (pdvmov.valortot + pdvmov.valortroco))
                    pag-titmoe.moecod = pdvmoe.moecod
                    pag-titmoe.titvlpag = (pdvmoe.valor - vtroco) *
                            (pdvdoc.valor  / pdvmov.valortot)
                    .
                message vtroco. pause.
                /*if pdvmoe.moecod = "REA"
                then pag-titmoe.titvlpag = pdvmoe.valor - pdvmov.valortroco.
                else pag-titmoe.titvlpag = pdvmoe.valor.    
                */
            end.
        end.
    end.
end procedure.

