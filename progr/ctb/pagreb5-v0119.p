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
    
def temp-table tt-titulo
    field etbcod like titulo.etbcod column-label "Fil."
    field etbcobra like titulo.etbcobra column-label "Cob."
    field titnum like titulo.titnum   column-label "Contr."
    field titpar like titulo.titpar   column-label "Pr."
    field pc-origem like par-origem      column-label "Ori"  format "xx"
    field clifor like titulo.clifor   column-label "Cliente"
    field clinom like clien.clinom    column-label "Nome" format "x(30)"
    field titdtven like titulo.titdtven
    field titdtpag like titulo.titdtpag
    field titvlcob like titulo.titvlcob 
    field titvlpag like titulo.titvlpag
                         column-label "Valor Pago" format ">>>,>>9.99" 
    field titjuro like titulo.titjuro  format ">>>,>>9.99"  
    field titvldes  like titulo.titvldes  format "->>,>>9.99"
    field p2k as log format "Sim/Nao"
    field cxacod like titulo.cxacod 
    field cobcod like titulo.cobcod
    field modcod like titulo.modcod
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
def var vl-paga as char.
def var vclinom like clien.clinom.
form tt-titulo.etbcod   column-label "Fil."
     tt-titulo.modcod   column-label "Mod."
                 vl-paga column-label "Loc" format "x(3)"
                 vs-paga column-label "Rec" format "x(3)"
                 tt-titulo.titnum   column-label "Contr."
                 tt-titulo.titpar   column-label "Pr."
                 tt-titulo.pc-origem column-label "Ori"  format "xx"
                 tt-titulo.clifor   column-label "Cliente"
                 tt-titulo.clinom   column-label "Nome" format "x(30)"
                 tt-titulo.titdtven
                 tt-titulo.titdtpag
                 tt-titulo.titvlcob(total) 
                 tt-titulo.titvlpag(total)
                         column-label "Valor Pago" format ">>>,>>9.99" 
                 tt-titulo.titjuro(total)     format ">>>,>>9.99"  
                 tt-titulo.titvldes(total)    format "->>,>>9.99"  
                 tt-titulo.cxacod column-label "Cxa" format ">>9"
                 tt-titmoe.moecod no-label
                         tt-titmoe.moenom no-label
                         tt-titmoe.valor    no-label format ">>>,>>9.99"
                 with no-box width 200 frame flin2 down.
             
def var vlin as int.
def var vmoenom like moeda.moenom.

def var tipo-sel as char format "x(15)" extent 5
    init["Resumo","Resumo moeda","Geral","Geral moeda","Geral moeda csv"].
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
    
    /*******       
    update sresp label "Seleciona Modalidades" colon 25
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with side-label
           width 80.

    if sresp
    then run selec-modal.p ("REC"). /* #1 */
    else undo.
    assign vmod-sel = "  ".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
    end.
      
    display vmod-sel format "x(40)" no-label.
    ***********/
    
    def var sel-recebe as char format "x(20)" extent 3
        init["   PARCELA","   ENTRADA","   VENDA VISTA"].
    disp sel-recebe with frame f-sel 1 down centered
        title " recebimentos " no-label.
    choose field sel-recebe with frame f-sel.    
    vindex = frame-index.    

    assign
        vparc = 0
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
            if vindex = 1 or vindex = 2
            then do:
                /*run pdv-moeda(input estab.etbcod, input vdata).
                */
                
                for each titulo  where 
                              titulo.titnat = no and
                              titulo.titdtpag = vdata and
                              titulo.etbcobra = estab.etbcod
                              no-lock:

                    if modcod = "VVI" then next.
                     
                    if titulo.titpar = 0 and vindex = 1
                    then next.
                    if titulo.titpar > 0 and vindex = 2
                    then next.
                    
                    if titulo.clifor = 1
                    then next.
                    assign
                        vparc = vparc + titulo.titvlcob
                        vjuro = vjuro + titulo.titjuro
                        vdesc = vdesc + titulo.titvldes.
                                 
                    if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
                    then vparcial = vparcial + titulo.titvlpag.
                    vpago = vpago + titulo.titvlpag.

                    for each tt-moeda. delete tt-moeda. end.
                    run titulo-moeda.
        
                    find clien where 
                        clien.clicod = titulo.clifor no-lock no-error.
                    create tt-titulo.
                    assign
                        tt-titulo.etbcod = titulo.etbcod
                        tt-titulo.etbcobra = titulo.etbcobra
                        tt-titulo.titnum = titulo.titnum
                        tt-titulo.titpar = titulo.titpar
                        tt-titulo.pc-origem = 
                            if acha("PARCIAL",titulo.titobs[1]) <> ?
                                    then string(titulo.titparger) else ""
                        tt-titulo.clifor = titulo.clifor
                        tt-titulo.clinom = 
                            if avail clien then clien.clinom else ""
                            tt-titulo.titdtven = titulo.titdtven
                        tt-titulo.titdtpag = titulo.titdtpag
                        tt-titulo.titvlcob = titulo.titvlcob 
                        tt-titulo.titvlpag = titulo.titvlpag
                        tt-titulo.titjuro = titulo.titjuro
                        tt-titulo.titvldes  = titulo.titvldes
                        tt-titulo.p2k = 
                            if titulo.cxacod < 30 or titulo.cxacod > 98
                                then no else yes
                        tt-titulo.cxacod = titulo.cxacod
                        tt-titulo.cobcod = titulo.cobcod
                        tt-titulo.modcod = titulo.modcod
                        .
                
                    find tt-resumo where 
                            tt-resumo.etbcod = titulo.etbcobra no-error.
                    if not avail tt-resumo
                    then do:
                        create tt-resumo.
                        tt-resumo.etbcod = titulo.etbcobra.
                    end.
                    assign
                        tt-resumo.parc = tt-resumo.parc + titulo.titvlcob
                        tt-resumo.paga = tt-resumo.paga + titulo.titvlpag
                        tt-resumo.juro = tt-resumo.juro + titulo.titjuro
                        tt-resumo.des = tt-resumo.des + titulo.titvldes
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
            else if vindex = 3
            then do:
                for each titulo  where 
                              titulo.titnat = no and
                              titulo.titdtpag = vdata and
                              titulo.etbcobra = estab.etbcod
                              and modcod = "VVI"
                              no-lock:
                    /*
                    if modcod = "VVI" then next.
                     
                    if titulo.titpar = 0 and vindex = 1
                    then next.
                    if titulo.titpar > 0 and vindex = 2
                    then next.
                    
                    if titulo.clifor = 1
                    then next.
                    */
                    assign
                        vparc = vparc + titulo.titvlcob
                        vjuro = vjuro + titulo.titjuro
                        vdesc = vdesc + titulo.titvldes.
                                 
                    if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
                    then vparcial = vparcial + titulo.titvlpag.
                    vpago = vpago + titulo.titvlpag.

                    for each tt-moeda. delete tt-moeda. end.
                    run titulo-moeda.
        
                    find clien where 
                        clien.clicod = titulo.clifor no-lock no-error.
                    create tt-titulo.
                    assign
                        tt-titulo.etbcod = titulo.etbcod
                        tt-titulo.etbcobra = titulo.etbcobra
                        tt-titulo.titnum = titulo.titnum
                        tt-titulo.titpar = titulo.titpar
                        tt-titulo.pc-origem = 
                            if acha("PARCIAL",titulo.titobs[1]) <> ?
                                    then string(titulo.titparger) else ""
                        tt-titulo.clifor = titulo.clifor
                        tt-titulo.clinom = 
                            if avail clien then clien.clinom else ""
                            tt-titulo.titdtven = titulo.titdtven
                        tt-titulo.titdtpag = titulo.titdtpag
                        tt-titulo.titvlcob = titulo.titvlcob 
                        tt-titulo.titvlpag = titulo.titvlpag
                        tt-titulo.titjuro = titulo.titjuro
                        tt-titulo.titvldes  = titulo.titvldes
                        tt-titulo.p2k = 
                            if titulo.cxacod < 30 or titulo.cxacod > 98
                                then no else yes
                        tt-titulo.cxacod = titulo.cxacod
                        tt-titulo.cobcod = titulo.cobcod
                        tt-titulo.modcod = titulo.modcod
                        .
                
                    find tt-resumo where 
                            tt-resumo.etbcod = titulo.etbcobra no-error.
                    if not avail tt-resumo
                    then do:
                        create tt-resumo.
                        tt-resumo.etbcod = titulo.etbcobra.
                    end.
                    assign
                        tt-resumo.parc = tt-resumo.parc + titulo.titvlcob
                        tt-resumo.paga = tt-resumo.paga + titulo.titvlpag
                        tt-resumo.juro = tt-resumo.juro + titulo.titjuro
                        tt-resumo.des = tt-resumo.des + titulo.titvldes
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
                /*******************
                for each plani where plani.movtdc = 5 and
                     plani.pladat = vdata and
                     plani.etbcod = estab.etbcod and
                     plani.crecod = 1 no-lock.

                    find clien where 
                        clien.clicod = plani.desti no-lock no-error.
                    create tt-titulo.
                    assign
                        tt-titulo.etbcod = plani.etbcod
                        tt-titulo.etbcobra = plani.etbcod 
                        tt-titulo.titnum = string(plani.numero)
                        tt-titulo.titpar = 1
                        tt-titulo.clifor = plani.desti
                        tt-titulo.clinom = 
                            if avail clien then clien.clinom else ""
                        tt-titulo.titdtven = plani.pladat
                        tt-titulo.titdtpag = plani.pladat
                        tt-titulo.titvlcob = plani.platot 
                        tt-titulo.titvlpag = plani.platot
                        tt-titulo.p2k = 
                            if plani.cxacod < 30 or plani.cxacod > 98
                                then no else yes
                        tt-titulo.cxacod = plani.cxacod
                        tt-titulo.cobcod = 2
                        tt-titulo.modcod = plani.modcod
                        .
                    
                    assign
                        vparc = vparc + tt-titulo.titvlcob
                        vjuro = vjuro + tt-titulo.titjuro
                    vdesc = vdesc + tt-titulo.titvldes
                    vpago = vpago + tt-titulo.titvlpag.
 
                    find tt-resumo where 
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

                    for each tt-moeda. delete tt-moeda. end.
    
                    run paga-venda-vista(input recid(plani)).
 
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
                            tt-titmoe.etbcod = tt-titulo.etbcod
                            tt-titmoe.titnum = tt-titulo.titnum
                            tt-titmoe.titpar = tt-titulo.titpar
                            tt-titmoe.moecod = tt-moeda.moecod
                            tt-titmoe.moenom = vmoenom
                            tt-titmoe.valor  = tt-moeda.valor
                            .
                        find first acum-moeda where
                           acum-moeda.etbcod = tt-titulo.etbcobra and
                           acum-moeda.moecod = tt-moeda.moecod
                           no-error.
                        if not avail acum-moeda   
                        then do:
                            create acum-moeda.
                            assign
                                acum-moeda.etbcod = tt-titulo.etbcobra
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
                ***************/
            end.
        end.
    end.
    hide frame f-disp.
    hide frame f-sel.

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
        
        form with frame fff column 36 overlay
                         row 7 10 down title sel-recebe[vindex].
                         
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

        def var vtotal as dec.
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
    no-label row 15 overlay 1 column title "relatorio"
    width 20.
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

    if vindex < 5
    then do:
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
            if tt-titulo.p2k 
            then vs-paga = "P2K".
            else vs-paga = "ADM".
            if tt-titulo.cobcod < 10
            then vl-paga = "LEB".
            else if tt-titulo.cobcod < 20 
                then vl-paga = "FIN".  
                else vl-paga = "".
            disp tt-titulo.etbcod   column-label "Fil."
                 tt-titulo.modcod
                 vl-paga
                 vs-paga      
                 tt-titulo.titnum   column-label "Documento"
                 tt-titulo.titpar   column-label "Par"
                 tt-titulo.pc-origem column-label "Ori"  format "xx"
                 tt-titulo.clifor   column-label "Cliente"
                 tt-titulo.clinom    column-label "Nome" format "x(25)"
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
                            tt-titulo.modcod
                            vl-paga
                            vs-paga
                            tt-titulo.titnum   column-label "Documento"
                            tt-titulo.titpar   column-label "Pr."
                            tt-titulo.pc-origem column-label "Ori"  format "xx"
                            tt-titulo.clifor   column-label "Cliente"
                            tt-titulo.clinom    
                                    column-label "Nome" format "x(25)"
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

    end.
    else if vindex = 5
    then do:
        def var vlinhas as int.
        def var varquivo1 as char.
        varquivo = "/admcom/Contabilidade/relat/resumo-recebimento-parcelas-0-"
                    + string(time) + ".csv".
        /*varquivo1 = "/admcom/Contabilidade/relat/resumo-recebimento-parcelas-1-"
                    + string(time) + ".csv".
        */
        varquivo1 = "".            
        output to value(varquivo).
        put "Filial;Pagamento;Modalidade;Origem;Local;Documento;Parcela;Origem;Cliente;Nome;Vencimen to;P agamento;Valor Parcela;Va lor Pago;Juro Atraso;Desconto;Caixa;Mo~eda;D~escr icao;V alor" skip. 
        for each tt-titulo where tt-titulo.titvlcob > 0 no-lock:
            if tt-titulo.p2k 
            then vs-paga = "P2K".
            else vs-paga = "ADM".
            if tt-titulo.cobcod < 10
            then vl-paga = "LEB".
            else if tt-titulo.cobcod < 20 
                then vl-paga = "FIN".  
                else vl-paga = "".
            
            put unformatted
                 tt-titulo.etbcod  ";"
                 tt-titulo.etbcobra ";"
                 tt-titulo.modcod ";"
                 vl-paga           ";"
                 vs-paga           ";"
                 tt-titulo.titnum  ";"
                 tt-titulo.titpar  ";"
                 tt-titulo.pc-origem ";"
                 tt-titulo.clifor  ";"
                 tt-titulo.clinom  ";"
                 tt-titulo.titdtven ";"
                 tt-titulo.titdtpag ";"
                 replace(string(tt-titulo.titvlcob,"->>>>>>>>9.99"),".",",") ";"
                 replace(string(tt-titulo.titvlpag,"->>>>>>>>9.99"),".",",") ";"
                 replace(string(tt-titulo.titjuro,"->>>>>>>>9.99"),".",",")  ";"
                 replace(string(tt-titulo.titvldes,"->>>>>>>>9.99"),".",",") ";"
                 tt-titulo.cxacod ";".

            vlin = 0. 
            if vindex = 5
            then for each tt-titmoe where
                          tt-titmoe.etbcod = tt-titulo.etbcod and
                          tt-titmoe.titnum = tt-titulo.titnum and
                          tt-titmoe.titpar = tt-titulo.titpar
                          no-lock:
                    vlin = vlin + 1.
                    if vlin = 1
                    then put unformatted
                            tt-titmoe.moecod ";"
                            tt-titmoe.moenom ";"
                replace(string(tt-titmoe.valor,"->>>>>>>>9.99"),".",",")
                            skip.    
                        
                    else if vlin > 1
                    then put unformatted
                 tt-titulo.etbcod  ";"
                 tt-titulo.etbcobra ";"
                 vl-paga           ";"
                 vs-paga           ";"
                 tt-titulo.titnum  ";"
                 tt-titulo.titpar  ";"
                 tt-titulo.pc-origem ";"
                 tt-titulo.clifor  ";"
                 tt-titulo.clinom  ";"
                 tt-titulo.titdtven ";"
                 tt-titulo.titdtpag ";"
                  ";"
                  ";"
                  ";"
                  ";"
                 tt-titulo.cxacod ";"
                 tt-titmoe.moecod ";"
                 tt-titmoe.moenom ";"
                 replace(string(tt-titmoe.valor,"->>>>>>>>9.99"),".",",")
                 skip.
                 vlinhas = vlinhas + 1.
                end.      
            
            if vlin = 0 then put skip.
            
            if vlinhas > 1000000
            then do:
                output close.
                vlinhas = 0.
                varquivo1 = 
                "/admcom/Contabilidade/relat/resumo-recebimento-parcelas-1-"
                    + string(time) + ".csv".
 
                output to value(varquivo1).
                put "Filial;Pagamento;Cobranca;Documento;Parcela;Origem;Cliente;Nome;Ve~ncimento;Pagamento;Valor Parcela;Va lor Pago;Juro Atraso;Desconto;Caixa;Moeda;D~escricao;Valor" skip. 
            end.                   
        end.
        output close.
        message color red/with
        "Arquivo gerado " skip
        varquivo skip
        varquivo1
        view-as alert-box.

    end.
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
    /*if titulo.cxacod >= 30 and titulo.cxacod < 99 
        and titulo.modcod <> "VVI" 
        and titulo.moecod = "PDM"
        and titulo.titpar > 0
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
    else*/ if titulo.moecod = "PDM"
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
                /*if pdvmoe.moecod = "REA"
                then pag-titmoe.titvlpag = pdvmoe.valor - pdvmov.valortroco.
                else pag-titmoe.titvlpag = pdvmoe.valor.    
                */
            end.
        end.
    end.
end procedure.
procedure paga-venda-vista:
    def input parameter rec-plani as recid.
    def var vtroco as dec.
    def buffer bplani for plani.
    def var vv as dec.
    find bplani where recid(bplani) = rec-plani no-lock.
    
    for each pdvdoc where pdvdoc.etbcod = bplani.etbcod and
                      pdvdoc.placod = bplani.placod and
                      pdvdoc.datamov = bplani.pladat
                      no-lock:
        find pdvmov of pdvdoc no-lock.
        for each pdvmoeda of pdvmov no-lock.
            vtroco = pdvmov.valortroco *
                             (pdvmoe.valor / 
                             (pdvmov.valortot + pdvmov.valortroco)).
    
            vv = (pdvmoe.valor - vtroco) *
                            (pdvdoc.valor  / pdvmov.valortot).
 
            if vv = ? then vv = 0.
            
            find first tt-moeda where
                       tt-moeda.moecod = pdvmoe.moecod
                       no-error.
            if not avail tt-moeda
            then do:
                create tt-moeda.
                tt-moeda.moecod = pdvmoe.moecod.
            end.
            if pdvmoe.moecod = "REA"
            then tt-moeda.valor = tt-moeda.valor + 
                        (pdvmoe.valor - pdvmov.valortroco).
            else tt-moeda.valor = tt-moeda.valor + pdvmoe.valor.
                       
         end.
    end.
end procedure.  

