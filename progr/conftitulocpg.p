{admcab.i}

def var vcobcod like titulo2.cobcod.
def var vformpag like titulo2.formpag.
def var vtipdoc like titulo2.tipdoc.
def var vtippag like titulo2.tippag.
def var vmodpag like titulo2.modpag.
def var vfinpag like titulo2.finpag.

def var vdtven-i as date format "99/99/9999".
def var vdtven-f as date format "99/99/9999".
def var vmodcod as char.

def new global shared var sforconpg as int.
def var p-retorna as log init no.

def var vtotal as dec init 0.
def var vjuro  as dec init 0.
def var vdesc  as dec init 0.
def var t-total as dec.
 
def var c-cobcod  as char.
def var c-formpag as char.
def var c-tipdoc  as char.
def var c-tippag  as char.
def var c-modpag  as char.
def var c-finpag  as char.
def var c-formpg  as char.

def new shared temp-table tt-titulo
    field marca    as char format "x"
    field empcod   like titulo.empcod
    field titnat   like titulo.titnat
    field titnum   like titulo.titnum format "x(10)"
    field titpar   like titulo.titpar format "99"
    field modcod   like titulo.modcod
    field cobcod   like titulo.cobcod
    field titdtemi like titulo.titdtemi format "99/99/99"
    field titdtven like titulo.titdtven format "99/99/99"
    field titvlcob like titulo.titvlcob column-label "Vl.Cobrado"
                       format ">>>,>>9.99"
    field titvlpag like titulo.titvlpag format ">>>,>>9.99"
    field titdtpag like titulo.titdtpag format "99/99/99"
    field titvljur like titulo.titvljur 
    field titvldes like titulo.titvldes
    field titsit   like titulo.titsit
    field etbcod   like titulo.etbcod column-label "FL" format ">>9"
    field clifor   like titulo.clifor
    field titbanpag like titulo.titbanpag
    index ind-1 titdtemi desc
    index ind-2 titdtven modcod
    index ind-3 modcod titdtven.

def new shared temp-table tt-titulo2 like titulo2.
def temp-table tt-marca like tt-titulo.

def buffer btt-titulo for tt-titulo.
def var i as i.
def var vcob like titulo.titvlcob.
def var vpag like titulo.titvlcob.
def var vforcod like forne.forcod.
repeat:

    for each tt-titulo:
        delete tt-titulo.
    end.
    vcob = 0.
    vpag = 0.
    update vforcod with frame f1 side-label width 80 no-box centered.
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao cadastrato".
        undo, retry.
    end.
    disp forne.fornom no-label with frame f1 width 80 no-box.
    update vdtven-i label "Vencimento inicial"
        with frame f1-1.
    vdtven-f = vdtven-i.    
    update vdtven-f label "Vencimento final"
           vmodcod  label "Modalidade"
           with frame f1-1 side-label no-box.
    for each titulo where titulo.clifor = forne.forcod and
                          titulo.titnat = yes and
                          titulo.titsit <> "PAG" no-lock 
                            use-index iclicod:
        if vdtven-i <> ? and (titulo.titdtven < vdtven-i or
                              titulo.titdtven = ?) then next.
        if vdtven-f <> ? and (titulo.titdtven > vdtven-f or
                              titulo.titdtven = ?) then next.
        if vmodcod <> "" and titulo.modcod <> vmodcod then next.
        if titulo.modcod = "BON" or
           titulo.modcod = "DEV" or
           titulo.modcod = "CHP" then next.
        create tt-titulo.
        assign tt-titulo.empcod   = titulo.empcod
               tt-titulo.titnat   = titulo.titnat
               tt-titulo.modcod   = titulo.modcod
               tt-titulo.titnum   =  titulo.titnum 
               tt-titulo.titpar   =  titulo.titpar 
               tt-titulo.modcod   = titulo.modcod
               tt-titulo.cobcod   = titulo.cobcod
               tt-titulo.titdtemi = titulo.titdtemi 
               tt-titulo.titdtven = titulo.titdtven 
               tt-titulo.titvlcob = titulo.titvlcob 
               tt-titulo.titvlpag = titulo.titvlpag 
               tt-titulo.titdtpag = titulo.titdtpag 
               tt-titulo.titsit   = titulo.titsit
               tt-titulo.etbcod   = titulo.etbcod
               tt-titulo.clifor   = titulo.clifor
               tt-titulo.titbanpag = titulo.titbanpag
               .
        
        if titulo.titsit <> "pag"       
        then tt-titulo.titvlcob = (titulo.titvlcob + 
                                   titulo.titvljur -
                                   titulo.titvldes).
                        
        vcob = vcob + tt-titulo.titvlcob.
        vpag = vpag + titulo.titvlpag.
    end.
    
    /*
    display vcob label "Total Cobrado"
            vpag label "Total Pago" with frame f-tot side-label row 22
                                            color white/red no-box
                                                overlay centered.
    */
    
    run titulos-for.

end.

procedure titulos-for:

def var vdt like plani.pladat.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.

def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Marca/desmarca","  Confirma","  Deposito","  Estorna",""].
def var esqcom2         as char format "x(12)" extent 5.

def var vmodcod         like tt-titulo.modcod.
    
    form
        esqcom1
            with frame f-com1 row 5 no-box no-labels side-labels column 1.
    
    esqpos1  = 1.

vdtven-i = ?.
    vdtven-f = ?.
        vmodcod  = "".
        
bl-princ:
repeat:
            
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        /*
        find first tt-titulo where true no-error.*/
        find first tt-titulo where true.
           /*
            (if vdtven-i <> ? then (tt-titulo.titdtven >= vdtven-i and
                                   tt-titulo.titdtven <= vdtven-f)
                              else true) and
            /*(if vdtven-f <> ? then tt-titulo.titdtven <= vdtven-f
                              else true) and*/
            (if vmodcod <> "" then tt-titulo.modcod = vmodcod
                              else true)
            no-error.        */
    else
        find tt-titulo where recid(tt-titulo) = recatu1.
    vinicio = yes.
    if not available tt-titulo
    then do:
        message color red/with
            "Nenhum registro pendente para fornecedor informado."
            view-as alert-box.
        return.
    end.
    clear frame frame-a all no-pause.
    
    display tt-titulo.marca   format "x" no-label 
            tt-titulo.titnum    format "x(10)"
            tt-titulo.titpar    format "99" 
            tt-titulo.modcod    
            tt-titulo.titdtemi  format "99/99/99" 
            tt-titulo.titdtven  format "99/99/99" column-label "Dt.Vcto."
            tt-titulo.titvlcob  column-label "Vl.Cobrado" format ">>>,>>9.99" 
            tt-titulo.titsit    
            tt-titulo.etbcod   column-label "FL" format ">>9"
                with frame frame-a 12 down row 6.

    recatu1 = recid(tt-titulo).
    
    color display message esqcom1[esqpos1] with frame f-com1.
    
    vtotal = 0.
    vjuro = 0.
    vdesc = 0.
    t-total = 0.
    for each btt-titulo where btt-titulo.marca = "*" no-lock.
                    vtotal = vtotal + btt-titulo.titvlcob.
                    vjuro  = vjuro  + btt-titulo.titvljur.
                    vdesc  = vdesc  + btt-titulo.titvldes.
    end.
    t-total = vtotal + vjuro - vdesc.
    
                disp "----- MARCADOS -----" at 1 no-label
                     vtotal label "Principal"
                     vjuro at 6 label "Juro"
                     vdesc at 2 label "Desconto"
                     t-total at 5 label "Total"
                     with frame f-tot overlay row 16 no-box
                     side-label column 60
                     .
    repeat:

        find next tt-titulo where true.
        /*
                (if vdtven-i <> ? then (tt-titulo.titdtven >= vdtven-i and
                                   tt-titulo.titdtven <= vdtven-f)
                              else true) and
            /*(if vdtven-f <> ? then tt-titulo.titdtven <= vdtven-f
                              else true) and*/
            (if vmodcod <> "" then tt-titulo.modcod = vmodcod
                              else true)
            no-error.   */
            /*
                 true.
        if vdtven-i <> ? and tt-titulo.titdtven < vdtven-i
        then next.
        if vdtven-f <> ? and tt-titulo.titdtven > vdtven-f
        then next.
        if vmodcod <> "" and tt-titulo.modcod <> vmodcod
        then next.
              */  
        if not available tt-titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
            
        display tt-titulo.marca   format "x" no-label
                tt-titulo.titnum    format "x(10)"
                tt-titulo.titpar    format "99" 
                tt-titulo.modcod    
                tt-titulo.titdtemi  format "99/99/99" 
                tt-titulo.titdtven  format "99/99/99" 
                tt-titulo.titvlcob  column-label "Vl.Cobrado" 
                    format ">>>,>>9.99" 
                tt-titulo.titsit    
                tt-titulo.etbcod   column-label "FL" format ">>9"
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-titulo where recid(tt-titulo) = recatu1.

        on f7 recall.
        choose field tt-titulo.titnum 
            go-on(cursor-down cursor-up cursor-left cursor-right F7 PF7
                  page-up page-down tab PF4 F4 ESC return v V f F).
       if  keyfunction(lastkey) = "RECALL"
       then do with frame fproc centered row 5 overlay color message side-label:
            
            prompt-for tt-titulo.titnum colon 10.
            
            find first tt-titulo where tt-titulo.titnum = 
                                       input tt-titulo.titnum no-error.
            recatu1 = if avail tt-titulo
                      then recid(tt-titulo) 
                      else ?. 
            leave. 
            
       end. 
       on f7 help.
       
       if  keyfunction(lastkey) = "V" or
           keyfunction(lastkey) = "v"
       then do with frame fdt centered row 5 overlay color message side-label:
            vdt = today.
            update vdt label "Vencimento".
            find first tt-titulo where tt-titulo.titdtven <= vdt no-error.
            recatu1 = if avail tt-titulo
                      then recid(tt-titulo) 
                      else ?. 
            leave.
        end. 
        if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-titulo where true no-error.
                if not avail tt-titulo
                then leave.
                recatu1 = recid(tt-titulo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-titulo where true no-error.
                if not avail tt-titulo
                then leave.
                recatu1 = recid(tt-titulo).
            end.
            leave.
        end.

        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-titulo where true no-error.
            if not avail tt-titulo
            then next.
            color display normal tt-titulo.titnum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-titulo where true no-error.
            if not avail tt-titulo
            then next.
            color display normal tt-titulo.titnum.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.
          
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.
            pause 0.
            
            if esqcom1[esqpos1] = "Marca/Desmarca"
            then do:
                /*
                if tt-titulo.titsit = "CON"
                then do:
                    bell.
                    message color red/with
                        "Titulo " tt-titulo.titnum + " ja confirmado."
                        view-as alert-box.
                    recatu1 = recid(tt-titulo).
                    next bl-princ.
                end.
                */
                if tt-titulo.marca = "*"
                then tt-titulo.marca = "".
                else tt-titulo.marca = "*".
                disp tt-titulo.marca with frame frame-a.
                vtotal = 0.
                vjuro = 0.
                vdesc = 0.
                for each btt-titulo where btt-titulo.marca = "*" no-lock.
                    vtotal = vtotal + btt-titulo.titvlcob.
                    vjuro  = vjuro  + btt-titulo.titvljur.
                    vdesc  = vdesc  + btt-titulo.titvldes.
                end.
                t-total = vtotal + vjuro - vdesc.
                disp vtotal label "Principal"
                     vjuro at 6 label "Juro"
                     vdesc at 2 label "Desconto"
                     t-total at 5 label "Total"
                     with frame f-tot overlay row 16 no-box
                     side-label column 60.
            end.
            
            if esqcom1[esqpos1] = "  Estorna"
            then do:
                if tt-titulo.titsit <> "CON"
                then next bl-princ.
                
                disp   tt-titulo.titnum
                           tt-titulo.modcod 
                           tt-titulo.cobcod
                           tt-titulo.titdtven
                           tt-titulo.titvlcob
                           /*tt-titulo.titvljur
                           tt-titulo.titvldes
                           */
                           tt-titulo.titsit
                           with frame frame-conf-est
                           overlay row 7 1 column column 10
                           title " estorno confirmação ".

                    pause 0.
 
                find titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = tt-titulo.modcod and
                                  titulo.etbcod = tt-titulo.etbcod and
                                  titulo.clifor = tt-titulo.clifor and
                                  titulo.titnum = tt-titulo.titnum and
                                  titulo.titpar = tt-titulo.titpar and
                                  titulo.titdtemi = tt-titulo.titdtemi
                                  NO-LOCK no-error.
                sresp = no.
                message "Estornar confirmação do titulo?" titulo.titnum
                update sresp.

                if sresp
                then do transaction:
                    find current titulo exclusive.

                    find titulo2 where
                                titulo2.empcod = tt-titulo.empcod and
                                titulo2.titnat = tt-titulo.titnat and
                                titulo2.modcod = tt-titulo.modcod and
                                titulo2.etbcod = tt-titulo.etbcod and
                                titulo2.clifor = tt-titulo.clifor and
                                titulo2.titnum = tt-titulo.titnum and
                                titulo2.titpar = tt-titulo.titpar and
                                titulo2.titdtemi = tt-titulo.titdtemi
                                no-error.
                    if avail titulo2
                    then delete titulo2.

                    tt-titulo.titsit = "LIB".
                    tt-titulo.cobcod = 1.
                    titulo.titsit = tt-titulo.titsit.
                    titulo.cobcod = tt-titulo.cobcod.
                    disp tt-titulo.cobcod
                         tt-titulo.titsit with frame frame-conf-est.
                    pause 1 no-message.
                end.
            end.
            
            if esqcom1[esqpos1] = "  Confirma"
            then do with frame f-altera overlay row 6 1 column centered.
                recatu1 = recid(tt-titulo).
                run confirma-tit.
                next bl-princ.
            end.

            if esqcom1[esqpos1] = "  Deposito"
            then do with frame f-deposito overlay row 6 1 column centered.
                find titulo2 where
                                titulo2.empcod = tt-titulo.empcod and
                                titulo2.titnat = tt-titulo.titnat and
                                titulo2.modcod = tt-titulo.modcod and
                                titulo2.etbcod = tt-titulo.etbcod and
                                titulo2.clifor = tt-titulo.clifor and
                                titulo2.titnum = tt-titulo.titnum and
                                titulo2.titpar = tt-titulo.titpar and
                                titulo2.titdtemi = tt-titulo.titdtemi
                                NO-LOCK no-error.
                if avail titulo2 and
                   titulo2.titbanpag > 0
                then do:
                    disp titulo2.titbanpag
                         titulo2.titagepag
                         titulo2.titconpag.
                    pause.      
                end.
                else message color red/with "Sem registro de deposito"
                        view-as alert-box.
            end.
            if esqcom1[esqpos1] = " GERA CTB"
            then do:
                find titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = tt-titulo.modcod and
                                  titulo.etbcod = tt-titulo.etbcod and
                                  titulo.clifor = tt-titulo.clifor and
                                  titulo.titnum = tt-titulo.titnum and
                                  titulo.titpar = tt-titulo.titpar
                                  no-lock no-error.
                if avail titulo
                then run gera-ctb.p(input recid(titulo)).
            end.
            
        end.
        /*****/
        if keyfunction(lastkey) = "F" or
           keyfunction(lastkey) = "f"
        then do:
            update vdtven-i label "Vencimento inicial"
                with frame f-fil side-label centered row 10 overlay 
                color message column 40.
            vdtven-f = vdtven-i.
            update vdtven-f at 1 label "Vencimento final  "
                with frame f-fil title "Filtro".
            update vmodcod at 1 label "Modalidade        "
                with frame f-fil. 
            hide frame f-fil no-pause.
            recatu1 = ?.
            next bl-princ.           
        end.   
        /****/
        view frame frame-a .

        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
                
        display tt-titulo.marca   format "x" no-label
                tt-titulo.titnum    format "x(10)"
                tt-titulo.titpar    format "99" 
                tt-titulo.modcod    
                tt-titulo.titdtemi  format "99/99/99" 
                tt-titulo.titdtven  format "99/99/99" 
                tt-titulo.titvlcob  column-label "Vl.Cobrado" 
                        format ">>>,>>9.99" 
                tt-titulo.titsit    
                tt-titulo.etbcod   column-label "FL" format ">>9"
                    with frame frame-a.
        /*
        display esqcom1[esqpos1] with frame f-com1.
        */
        recatu1 = recid(tt-titulo).
    end.
end.
 
end procedure. 

{setbrw.i}

procedure ttmf:

    def buffer bformpag for formpag.  
    if vformpag > 0
    then find first bformpag where
                    bformpag.tipo = "" and
                    bformpag.codigo = vformpag
                    no-lock no-error.
    else find first bformpag where 
               bformpag.tipo = "" and
               bformpag.descricao begins "BRADESCO" 
               no-lock no-error.
    if avail bformpag
    then c-formpg =  bformpag.descricao.

    find first tabaux where
         tabaux.tabela = "TIPO DE PAGAMENTO" and
         (if vtippag > 0
          then tabaux.nome_campo = string(vtippag,"99")
          else true)
         NO-LOCK no-error.
    if avail tabaux
    then c-tippag = tabaux.valor_campo.
    find first tabaux where
         tabaux.tabela = "TIPO DE DOCUMENTO" and
         (if vtipdoc > 0
          then tabaux.nome_campo = string(vtipdoc,"99")
          else true)
         NO-LOCK no-error.
    if avail tabaux
    then c-tipdoc = tabaux.valor_campo.
    find first tabaux where
         tabaux.tabela = "MODALIDADE DE PAGAMENTO" and
         (if vmodpag > 0
          then tabaux.nome_campo = string(vmodpag,"99")
          else tabaux.valor_campo = "TITULO DE TERCEIRO")
         NO-LOCK no-error.
    if avail tabaux
    then c-modpag = tabaux.valor_campo.
    find first tabaux where
         tabaux.tabela = "FINALIDADE DOC/TED"  and
         (if vfinpag > 0
          then tabaux.nome_campo = string(vfinpag,"99")
          else true)
         NO-LOCK no-error.
    if avail tabaux
    then c-finpag = tabaux.valor_campo.


    disp c-formpg format "x(25)"
        with frame f-formpg no-label title " forma de pagamento " column 54
        row 5.
    disp c-tippag format "x(25)" 
        with frame f-tippag no-label title " tipo pagamento " column 54.
    disp c-tipdoc format "x(25)"
        with frame f-tipdoc no-label title " tipo documento " column 54.
    disp c-modpag format "x(25)"
        with frame f-modpag no-label title " modalidade pagamento " column 54. 
    disp c-finpag format "x(25)"
        with frame f-finpag no-label title " finalidade DOC/TED " column 54.


    assign
            a-seeid = -1 a-recid = -1 a-seerec = ?
                        .
    form with frame f-linha.                        
    do on error undo, return:
    repeat on endkey undo:
        update c-formpg go-on(F7) with frame f-formpg.
        if keyfunction(lastkey) = "RETURN"
        then leave.
        if keyfunction(lastkey) <> "help"
        then next.
    
        run form-pag.
    end.
    repeat on endkey undo:
        update c-tippag go-on(F7) with frame f-tippag.
        if keyfunction(lastkey) = "RETURN"
        then leave.
        if keyfunction(lastkey) <> "help"
        then next.
    
        run tip-pag.

    end.
    repeat on endkey undo:
        update c-tipdoc go-on(F7) with frame f-tipdoc.
        
        if keyfunction(lastkey) = "RETURN"
        then leave.
        if keyfunction(lastkey) <> "help"
        then next.
 
        run tip-doc.

    end.
    repeat on endkey undo:
        update c-modpag go-on(F7) with frame f-modpag.
        
        if keyfunction(lastkey) = "RETURN"
        then leave.
        if keyfunction(lastkey) <> "help"
        then next.
 
        run mod-pag.

    end.
    end.
end procedure.

procedure form-pag:
    assign a-seeid = -1 a-recid = -1 a-seerec = ? .

    {sklcls.i
            &color = with/cyan
            &file = formpag   
            &cfield = formpag.descricao
            &ofield = " formpag.descricao "  
            &where  = " tipo = """" use-index indx2 "
            &aftselect1 = " 
            if keyfunction(lastkey) = ""RETURN""
                            then do:
                                c-formpg = formpag.descricao. 
                                leave keys-loop.

                            end.
                          "  
            &form   = " frame f-1 14 down row 5 column 47  no-label
                                overlay title "" formas de pagamento "" "
                                
        } 
    hide frame f-1.        
end procedure.
procedure tip-pag:
    assign
            a-seeid = -1 a-recid = -1 a-seerec = ?
     .
     {sklcls.i
            &color = with/cyan
            &file = tabaux   
            &cfield = tabaux.valor_campo
            &ofield = " tabaux.valor_campo format ""x(25)"" "  
            &where  = " tabaux.tabela = ""TIPO DE PAGAMENTO"" "
            &aftselect1 = " 
            if keyfunction(lastkey) = ""RETURN""
                            then do:
                                c-tippag = tabaux.valor_campo. 
                                leave keys-loop.

                            end.
                          "  
            &form   = " frame f-2 10 down row 8 column 50 no-label
                                overlay title "" tipo de pagamento "" "
                                
        } 
    hide frame f-2.        
end procedure.

procedure tip-doc:
    assign
            a-seeid = -1 a-recid = -1 a-seerec = ?
     .
     {sklcls.i
            &color = with/cyan
            &file = tabaux   
            &cfield = tabaux.valor_campo
            &ofield = " tabaux.valor_campo format ""x(25)"" "  
            &where  = " tabaux.tabela = ""TIPO DE DOCUMENTO"" "
            &aftselect1 = " 
            if keyfunction(lastkey) = ""RETURN""
                            then do:
                                c-tipdoc = tabaux.valor_campo. 
                                leave keys-loop.

                            end.
                          "  
            &form   = " frame f-2 10 down row 8 column 50 no-label
                                overlay title "" tipo de pagamento "" "
                                
        } 
    hide frame f-2.        
end procedure.


procedure mod-pag:
    
    assign
            a-seeid = -1 a-recid = -1 a-seerec = ?
     .
     {sklcls.i
            &color = with/cyan
            &file = tabaux   
            &cfield = tabaux.valor_campo
            &ofield = " tabaux.valor_campo format ""x(25)"" "  
            &where  = " tabaux.tabela = ""MODALIDADE DE PAGAMENTO"" "
            &aftselect1 = " 
            if keyfunction(lastkey) = ""RETURN""
                            then do:
                                c-modpag = tabaux.valor_campo. 
                                leave keys-loop.

                            end.
                          "  
            &form   = " frame f-2 10 down row 14 column 50 no-label 
                                overlay title "" modalidade de pagamento "" "
                                
        } 
        
    hide frame f-2.   
end procedure.

procedure for-con-pg:
    def input parameter rec-tit as recid.
    def output parameter vbarcode as char.
    
    def var q-forconpg as int.

    def var p-cpfcgc as char format "x(15)".
    def var p-nomerz as char format "x(31)".
    def var p-banco as char .
    def var p-agencia as char .
    def var p-digage as char format "x(3)".
    def var p-conta as char format "x(10)".
    def var p-digcon as char format "x(3)".
    def var p-tpconta as int format "9".   
    
    if c-modpag begins "DOC" or
       c-modpag begins "TED" or
       c-modpag begins "CREDITO EM CONTA"
    then do:
        l1:
        repeat:
        q-forconpg = 0.
        for each forconpg where
                 forconpg.forcod = forne.forcod
                 no-lock.
            q-forconpg = q-forconpg + 1.
        end.
        if q-forconpg >= 1
        then do:
            assign a-seeid = -1 a-recid = -1 a-seerec = ? .
            {sklcls.i
                &color = with/cyan
                &file = forconpg   
                &help = "F1-Inclui  F2-Altera"
                &cfield = forconpg.rsnome
                &ofield = " forconpg.rsnome format ""x(20)""
                                    column-label ""Nome/RazSoc""
                            forconpg.numban
                            forconpg.numagen
                            forconpg.numcon  format ""x(11)""
                            "  
                &where  = " forconpg.forcod = forne.forcod "
                &aftselect1 = " 
                            if keyfunction(lastkey) = ""RETURN""
                            then do:
                                find first tt-titulo where
                                    recid(tt-titulo) = rec-tit no-error.
                                assign
                                    tt-titulo2.titbanpag = forconpg.numban
                                    tt-titulo2.titagepag = forconpg.numagen + 
                                            ""-"" + forconpg.digitoage
                                    tt-titulo2.titconpag = forconpg.numcon + 
                                            ""-"" + forconpg.digitocon
                                    .
                                leave keys-loop.
                            end.
                            if keyfunction(lastkey) = ""GO""
                            then do:
                                sforconpg = forconpg.forcod.
                                run forconpg.p.
                                sforconpg = 0.
                                run remonta-frame.
                                next l1.
                            end.
            
                          "  
                &form   = " frame f-3 3 down row 13  
                                overlay title "" conta deposito "" "
                                
            } 
            hide frame f-3 no-pause.
        end. 
        else do:
            /************
            find first forconpg where
                       forconpg.forcod = forne.forcod
                       no-lock no-error.
            if avail forconpg
            then do:
                assign
                    tt-titulo2.titbanpag = forconpg.numban
                    tt-titulo2.titagepag = forconpg.numagen
                    tt-titulo2.titconpag = forconpg.numcon
                    .
            end.     
            else do:
                bell.
                message color red/with
                "Fornecedor sem cadatro para deposito."
                view-as alert-box.
                p-retorna = yes.

            end.
            ******/
            
            repeat on endkey undo:
                if keyfunction(lastkey) = "END-ERROR"
                then do:
                    p-retorna = yes.
                    leave.
                end.
                p-tpconta = 1.
                update p-cpfcgc at 1    label "       CPF"
                   p-nomerz at 1        label "      Nome"
                   p-banco  at 1        label "     Banco"
                   p-agencia at 1       label "   Agencia"
                   p-digage             label "  Dig"
                   p-conta at 1         label "     Conta"
                   p-digcon             label "Dig"
                   p-tpconta at 1       label "Tipo conta"
                   help "Informe 1 para conta corrente ou 2 para poupanca."
                   with frame f-bac row 14 overlay side-label
                   column 7 title " Informações para depósito "
                   .
                if p-cpfcgc = "" or
                   p-nomerz = "" or
                   p-banco = "" or
                   p-agencia = "" or
                   p-conta = "" or
                   p-tpconta = 0
                then undo, retry.
                assign
                     tt-titulo2.char1 = "CGCCPF=" +  p-cpfcgc +
                                        "|NOMERZ=" + p-nomerz
                     tt-titulo2.titbanpag = int(p-banco)
                     tt-titulo2.titagepag = p-agencia + "-" + p-digage
                     tt-titulo2.titconpag = p-conta   + "-" + p-digcon
                     tt-titulo2.int1 = p-tpconta
                                        .
                leave.                        
            end.

        end. 
        leave l1.
        end.
    end. 
    else do:
        assign
                    tt-titulo2.titbanpag = 0
                    tt-titulo2.titagepag = ""
                    tt-titulo2.titconpag = ""
                    .

    end.
    if c-modpag = "TITULO DE TERCEIRO"
        and tt-titulo2.codbar = ""
    THEN do :

        run fatu-codbar.p(input recid(titulo),
                          output vbarcode).

    END.
    hide frame f-codb no-pause.
    
end procedure.

procedure confirma-tit:

    def var vtotal as dec init 0.
    def var vjuro  as dec init 0.
    def var vdesc  as dec init 0.
    def var vcobra like titulo.cobcod.
    def var vbarcode as char.
    
    def buffer btabaux for tabaux.
    def buffer ctabaux for tabaux.
    def buffer dtabaux for tabaux.
    
    for each tt-marca : delete tt-marca. end.
    
    for each tt-titulo where
             tt-titulo.marca = "*" no-lock.
        vtotal = vtotal + tt-titulo.titvlcob.
        vjuro  = vjuro  + tt-titulo.titvljur.
        vdesc  = vdesc  + tt-titulo.titvldes.

        create tt-marca.
        buffer-copy tt-titulo to tt-marca.
        
    end.

    for each tt-titulo where tt-titulo.marca = "*" :

        display tt-titulo.marca   format "x" no-label 
            tt-titulo.titnum    format "x(10)"
            tt-titulo.titpar    format "99" 
            tt-titulo.titdtemi  format "99/99/99" 
            tt-titulo.titdtven  format "99/99/99" 
            tt-titulo.titvlcob  column-label "Vl.Cobrado" format ">>>,>>9.99" 
            tt-titulo.titsit    
                with frame frame-c 6 down overlay 
                row 5 title " TITULOS PARA CONFIRMAR ".

        vcobra = tt-titulo.cobcod.
    end. 
    t-total = vtotal + vjuro - vdesc.   
    disp vtotal label "Principal"
         vjuro  label "Juro"
         vdesc  label "Desconto"
         t-total label "Total"
         with frame f-tot overlay row 15 1 column no-box side-label.
        
    if vtotal = 0
    then do:
        message color red/with
        "Favor marcar o(s) titulo(s) para confirmacao."
        view-as alert-box.
        return.
    end.  
    
    def var Vencimento as date.
    do on error undo:
         update vencimento with frame f-tot.
         if vencimento = ? or vencimento < today
         then do:
             message color red/with
             "Vencimento deve ser igual ou maior que a data de hoje."
             view-as alert-box.
             undo.
         end.
    end.
    sresp = no.
    message "Confirma vencimento informado?" update sresp.
    if not sresp then return.
        
    for each tt-titulo where tt-titulo.marca = "*" :
        tt-titulo.titdtven = vencimento.
        display tt-titulo.marca   format "x" no-label 
            tt-titulo.titnum    format "x(10)"
            tt-titulo.titpar    format "99" 
            tt-titulo.titdtemi  format "99/99/99" 
            tt-titulo.titdtven  format "99/99/99" 
            tt-titulo.titvlcob  column-label "Vl.Cobrado" format ">>>,>>9.99" 
            tt-titulo.titsit    
                with frame frame-cc 6 down overlay 
                row 5 title " TITULOS PARA CONFIRMAR ".

        vcobra = tt-titulo.cobcod.
    end. 
        
    update vcobra with frame f-tot.
    find cobra where cobra.cobcod = vcobra no-lock no-error.
    if not avail cobra 
    then do:
        message color red/with
                "Codigo para cobranca nao cadastrado."
                view-as alert-box.
        return.
    end.
        
    p-retorna = no.
    if vcobra = 3
    then run ttmf.
                        
    if keyfunction(lastkey) = "END-ERROR" or p-retorna
    then return.
    
    find first formpag where formpag.tipo = "" and
                             formpag.descricao = c-formpg
                             no-lock no-error.
                             
    find first tabaux where tabaux.tabela = "TIPO DE DOCUMENTO" and
                            tabaux.valor_campo = c-tipdoc
                            no-lock no-error.

    find first btabaux where btabaux.tabela = "TIPO DE PAGAMENTO" and
                            btabaux.valor_campo = c-tippag
                            no-lock no-error.
                            
    find first ctabaux where ctabaux.tabela = "MODALIDADE DE PAGAMENTO" and
                            ctabaux.valor_campo = c-modpag
                            no-lock no-error.

    find first dtabaux where dtabaux.tabela = "FINALIDADE DOC/TED"  and
                            dtabaux.valor_campo = c-finpag
                            no-lock no-error.
                            
    vbarcode = "".
    for each tt-titulo where tt-titulo.marca = "*":                 
        find titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = tt-titulo.modcod and
                                  titulo.etbcod = tt-titulo.etbcod and
                                  titulo.clifor = tt-titulo.clifor and
                                  titulo.titnum = tt-titulo.titnum and
                                  titulo.titpar = tt-titulo.titpar and
                                  titulo.titdtemi = tt-titulo.titdtemi
                                  no-error.
        if avail titulo
        then do on error undo :

            if tt-titulo.titdtven <> titulo.titdtven
            then titulo.titdtven = tt-titulo.titdtven.
            
            if vcobra = 3
            then do:
                create tt-titulo2.
                
                find titulo2 where
                                titulo2.empcod = titulo.empcod and
                                titulo2.titnat = titulo.titnat and
                                titulo2.modcod = titulo.modcod and
                                titulo2.etbcod = titulo.etbcod and
                                titulo2.clifor = titulo.clifor and
                                titulo2.titnum = titulo.titnum and
                                titulo2.titpar = titulo.titpar and
                                titulo2.titdtemi = titulo.titdtemi
                                no-error.
                if avail titulo2
                then buffer-copy titulo2 to tt-titulo2.
                else assign
                         tt-titulo2.empcod = titulo.empcod 
                         tt-titulo2.titnat = titulo.titnat
                         tt-titulo2.modcod = titulo.modcod
                         tt-titulo2.etbcod = titulo.etbcod
                         tt-titulo2.clifor = titulo.clifor
                         tt-titulo2.titnum = titulo.titnum
                         tt-titulo2.titpar = titulo.titpar
                         tt-titulo2.titdtemi = titulo.titdtemi.

                assign
                    vformpag = tt-titulo2.formpag
                    vtipdoc  = tt-titulo2.tipdoc
                    vtippag  = tt-titulo2.tippag
                    vmodpag  = tt-titulo2.modpag
                    vfinpag  = tt-titulo2.finpag.

                if int(btabaux.nome_campo) = 2 and
                   int(tabaux.nome_campo) = 5
                then do:
                   vbarcode = "".
                   find first fatudesp where
                              fatudesp.clicod = tt-titulo2.clifor and
                              fatudesp.fatnum = int(tt-titulo2.titnum)
                              no-lock no-error.
                   if avail fatudesp
                      and acha("GNRE",fatudesp.char2) <> ?
                   then vbarcode = "Bar=" + acha("CBARRAS",fatudesp.char2).
                   /***
                   do:
                        assign
                            tt-titulo2.codbarras = 
                                    "Bar=" + acha("CBARRAS",fatudesp.char2)
                            vbarcode = "Bar=" + acha("CBARRAS",fatudesp.char2)
                                    .

                        assign        
                            tt-titulo2.cobcod = vcobra
                            tt-titulo2.formpag = formpag.codigo
                            tt-titulo2.tippag = int(btabaux.nome_campo)
                            tt-titulo2.tipdoc = int(tabaux.nome_campo)
                            tt-titulo2.modpag = int(ctabaux.nome_campo)
                            tt-titulo2.finpag = int(dtabaux.nome_campo).

                   end.
                   **/
                end.
                if vbarcode = ""
                then
                run for-con-pg(recid(tt-titulo),
                                output vbarcode).
        
                else tt-titulo2.codbarras = vbarcode .
                
                if keyfunction(lastkey) = "END-ERROR" or
                    p-retorna = yes
                then do on error undo:
                    if avail titulo2
                    then delete titulo2.
                    delete tt-titulo2.
                    leave.
                end.
                
                assign        
                    tt-titulo2.cobcod = vcobra
                    tt-titulo2.formpag = formpag.codigo
                    tt-titulo2.tipdoc = int(tabaux.nome_campo)
                    tt-titulo2.tippag = int(btabaux.nome_campo)
                    tt-titulo2.modpag = int(ctabaux.nome_campo)
                    tt-titulo2.finpag = int(dtabaux.nome_campo).

                find titulo2 where
                                titulo2.empcod = tt-titulo2.empcod and
                                titulo2.titnat = tt-titulo2.titnat and
                                titulo2.modcod = tt-titulo2.modcod and
                                titulo2.etbcod = tt-titulo2.etbcod and
                                titulo2.clifor = tt-titulo2.clifor and
                                titulo2.titnum = tt-titulo2.titnum and
                                titulo2.titpar = tt-titulo.titpar and
                                titulo2.titdtemi = tt-titulo2.titdtemi
                                no-error.
 
                if not avail titulo2
                then create titulo2.
                
                buffer-copy tt-titulo2 to titulo2.
            end.

            assign tt-titulo.cobcod = vcobra
                   tt-titulo.titsit = "CON"
                   titulo.titsit = tt-titulo.titsit
                   titulo.cobcod = tt-titulo.cobcod
                   tt-titulo.marca = "".
        end.             
    end.
end procedure.

procedure remonta-frame:
    disp vforcod with frame f1 side-label width 80 no-box row 3.
        find forne where forne.forcod = vforcod no-lock no-error.
            disp forne.fornom no-label with frame f1.
                pause 0.
                    for each tt-titulo where tt-titulo.marca = "*" :
                            display tt-titulo.marca   format "x" no-label
                                        tt-titulo.titnum    format "x(10)"
                                                    tt-titulo.titpar    format "99"
            tt-titulo.titdtemi  format "99/99/99"
                        tt-titulo.titdtven  format "99/99/99"
                                    tt-titulo.titvlcob  column-label "Vl.Cobrado" format ">>>,>>9.99"
            tt-titulo.titsit
                            with frame frame-c 6 down overlay
                                            row 5 title " TITULOS PARA CONFIRMAR ".
    end.
    
    disp c-formpg format "x(25)"
                with frame f-formpg no-label title " forma de pagamento " column 54
        row 5.
            disp c-tippag format "x(25)"
                    with frame f-tippag no-label title " tipo pagamento " column 54.
    disp c-tipdoc format "x(25)"
            with frame f-tipdoc no-label title " tipo documento " column 54.
                disp c-modpag format "x(25)"
                        with frame f-modpag no-label title " modalidade pagamento " column 54.
    disp c-finpag format "x(25)"
            with frame f-finpag no-label title " finalidade DOC/TED " column 54.
    pause 0.
end procedure.
    
