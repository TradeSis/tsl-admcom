{admcab.i}   

def temp-table tt-fis
    field opfcod  like fiscal.opfcod
    field alicms  like fiscal.alicms
    field tot-pla like fiscal.platot format "->>,>>>,>>9.99"
    field tot-bic like fiscal.platot format "->>,>>>,>>9.99"
    field tot-icm like fiscal.platot format "->>,>>>,>>9.99"
    field tot-ipi like fiscal.platot format "->>,>>>,>>9.99" 
    field tot-out like fiscal.platot format "->>,>>>,>>9.99".

    
def temp-table tt-uf
    field ufecod  like forne.ufecod
    field uftotal like plani.platot format ">>,>>>,>>9.99".
    
    
def var varquivo as char.
def var vali like fiscal.alicms.
def var vemi like fiscal.plaemi.
def var vrec like fiscal.plarec.
def var vopf like fiscal.opfcod.
def var tipo as char format "x(20)" extent 2
        initial["GERAL","RESUMO"].

def var vnumero like fiscal.numero.
def var vforcod like forne.forcod.
def var totpla like plani.platot. 
def var totbic like plani.platot.
def var toticm like plani.platot.
def var totipi like plani.platot.
def var totout like plani.platot.
    

def input parameter vetb like estab.etbcod.
def input parameter vmovtdc like tipmov.movtdc.
def input parameter vdt1 as date.
def input parameter vdt2 as date.
def var v-mar as dec.
def var vmarca          as char format "x"                          no-undo.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
   initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem","Procura"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bfiscal       for fiscal.

def var v-ven  as dec.
def var v-con  as dec.
def var v-acr  as dec.

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
    v-ven = 0.
    v-acr = 0.
    v-con = 0.

    totpla = 0.
    totbic = 0.
    toticm = 0.
    totipi = 0.
    totout = 0.
    
    for each fiscal where fiscal.desti = vetb   and
                          fiscal.movtdc = vmovtdc and
                          fiscal.plarec >= vdt1 and
                          fiscal.plarec <= vdt2 no-lock:
                          
        assign totpla = totpla + fiscal.platot
               totbic = totbic + fiscal.bicms
               toticm = toticm + fiscal.icms
               totipi = totipi + fiscal.ipi
               totout = totout + fiscal.outras.
    end.
    
    display 
            totpla label "Total     " format ">>>,>>>,>>9.99" at 01
            totbic label "Tot Bicms " format ">>>,>>>,>>9.99" 
            toticm label "Tot Icms  " format ">>>,>>>,>>9.99" at 01 
            totipi label "Tot Ipi   " format ">>>,>>>,>>9.99" 
            totout label "Tot Outr" format ">>>,>>>,>>9.99" 
                with frame ftot side-label row 18.
    
def var uf-ecod like forne.ufecod. 
    
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first fiscal where fiscal.desti = vetb and
                                fiscal.movtdc = vmovtdc and
                                fiscal.plarec >= vdt1 and
                                fiscal.plarec <= vdt2 no-error.
    else
        find fiscal where recid(fiscal) = recatu1.
        vinicio = no.
    if not available fiscal
    then do:
        form fiscal
            with frame f-altera
            overlay row 6 1 column centered color white/cyan.
        message "Cadastro de Ecf Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do transaction with frame f-altera3 row 6 overlay
                1 column centered color white/cyan:

                
                vforcod = 0.
                create fiscal.
                update vforcod label "Emite".
                find forne where forne.forcod = vforcod no-lock no-error.
                if not avail forne
                then do:
                    message "Fornecedor nao Cadastrado".
                    undo, retry.
                end.
                display forne.fornom no-label format "x(40)".
                fiscal.emite = vforcod.
                fiscal.movtdc = vmovtdc.
                fiscal.serie  = "U".

                
                update fiscal.numero
                       fiscal.plaemi
                       fiscal.plarec.

                do on error undo, retry:
                    update fiscal.opfcod format "9999".
                    find tofis where tofis.tofcod = fiscal.opfcod 
                                        no-lock no-error.
                    if not avail tofis
                    then do:
                        message "Operacao Fiscal Nao Cadastrada".
                        undo, retry.
                    end.
                end.
                
                
                update fiscal.platot
                       fiscal.bicms  
                       fiscal.alicms 
                       fiscal.icms   
                       fiscal.ipi    
                       fiscal.outras 
                       fiscal.plaobs[1] 
                       fiscal.plaobs[2]
                       fiscal.plaobs[3].
           
                fiscal.desti  = vetb.
                fiscal.movtdc = vmovtdc.

                totpla = 0.
                totbic = 0.
                toticm = 0.
                totipi = 0.
                totout = 0.
    
                for each fiscal where fiscal.desti = vetb   and
                                      fiscal.movtdc = vmovtdc and
                                      fiscal.plarec >= vdt1 and
                                      fiscal.plarec <= vdt2 no-lock:
                          
                    assign totpla = totpla + fiscal.platot
                           totbic = totbic + fiscal.bicms
                           toticm = toticm + fiscal.icms
                           totipi = totipi + fiscal.ipi
                           totout = totout + fiscal.outras.
                end.
    
                vinicio = yes.
        end.
    end.
    clear frame frame-a all no-pause.

    
    display 
            totpla 
            totbic 
            toticm 
            totipi 
            totout 
                with frame ftot side-label row 18.
    
    display fiscal.emite column-label "Emite" 
            fiscal.plarec 
            fiscal.numero 
            fiscal.opfcod column-label "OPF" format ">999"
            fiscal.platot format ">>,>>>,>>9.99"
            fiscal.bicms  format ">>,>>9.9"
            fiscal.icms   format ">>,>>9.9"
            fiscal.ipi    format ">>,>>9.9" 
            fiscal.outras format ">,>>9.9"
                with frame frame-a 10 down centered color white/red .

    recatu1 = recid(fiscal).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    def var b-subst like plani.bsubst.
    def var i-subst like plani.icmssubst.
    repeat:
        find next fiscal where fiscal.desti = vetb and
                               fiscal.movtdc = vmovtdc and
                               fiscal.plarec >= vdt1 and
                               fiscal.plarec <= vdt2 no-error.
        if not available fiscal
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio = no
        then down with frame frame-a.
 
        display 
            fiscal.emite column-label "Emite" 
            fiscal.plarec
            fiscal.numero 
            fiscal.opfcod column-label "OPF"
            fiscal.platot 
            fiscal.bicms 
            fiscal.icms 
            fiscal.ipi 
            fiscal.outras 
                with frame frame-a.
            
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find fiscal where recid(fiscal) = recatu1.

        choose field fiscal.emite
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
                esqpos2 = if esqpos2 = 6
                          then 6
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
                find next fiscal where fiscal.desti = vetb and
                                       fiscal.movtdc = vmovtdc and
                                       fiscal.plarec >= vdt1 and
                                       fiscal.plarec <= vdt2 no-error.
                if not avail fiscal
                then leave.
                recatu2 = recid(fiscal).
            end.
            if reccont = frame-down(frame-a)
            then recatu1 = recatu2.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev fiscal where fiscal.desti = vetb and
                                       fiscal.movtdc = vmovtdc and
                                       fiscal.plarec >= vdt1 and
                                       fiscal.plarec <= vdt2 no-error.
                if not avail fiscal
                then leave.
                recatu1 = recid(fiscal).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next fiscal where fiscal.desti = vetb and
                                   fiscal.movtdc = vmovtdc and
                                   fiscal.plarec >= vdt1 and
                                   fiscal.plarec <= vdt2 no-error.
            if not avail fiscal
            then next.
            color display white/red
                fiscal.emite.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev fiscal where fiscal.desti = vetb and
                                   fiscal.movtdc = vmovtdc and
                                   fiscal.plarec >= vdt1 and
                                   fiscal.plarec <= vdt2 no-error.
            if not avail fiscal
            then next.
            color display white/red
                fiscal.emite.
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
            then do transaction with frame f-inc side-label.
                
                /* vforcod = 0. */
                create bfiscal.
                update vforcod label "Emite".
                find forne where forne.forcod = vforcod no-lock no-error.
                if not avail forne
                then do:
                    message "Fornecedor nao Cadastrado".
                    undo, retry.
                end.
                display forne.fornom no-label.
                bfiscal.emite = vforcod.
                bfiscal.serie = "U".

                bfiscal.plaemi = vemi.
                bfiscal.plarec = vrec.
                
                update bfiscal.numero
                       bfiscal.serie  
                       bfiscal.plaemi.
                /**       
                find first fiscal where fiscal.desti = vetb     and
                                         fiscal.movtdc = vmovtdc and
                                         fiscal.emite  = vforcod and
                                         fiscal.plarec = vrec and
                                         fiscal.numero = bfiscal.numero
                                                 no-lock no-error.
                if avail fiscal
                then do:
                    message "Nota Ja existe".
                    recatu1 = recid(fiscal).
                    delete bfiscal.
                    next bl-princ.
                end.
                **/
                do on error undo, retry:
                    update bfiscal.plarec.
                    if bfiscal.plarec < vdt1 or
                       bfiscal.plarec > vdt2
                    then undo, retry.
                    
                    if bfiscal.plarec < bfiscal.plaemi
                    then do:
                        message "Data Invalida".
                        undo, retry.
                            
                    end.

                end.

                find first fiscal where fiscal.desti = vetb     and
                                         fiscal.movtdc = vmovtdc and
                                         fiscal.emite  = vforcod and
                                         fiscal.plarec = vrec and
                                         fiscal.numero = bfiscal.numero
                                                 no-lock no-error.
                if avail fiscal
                then do:
                    message "Nota Ja existe".
                    recatu1 = recid(fiscal).
                    delete bfiscal.
                    next bl-princ.
                end.

                vemi = bfiscal.plaemi.
                vrec = bfiscal.plarec.
                        
             
                bfiscal.opfcod = vopf.
                do on error undo, retry:
                    update bfiscal.opfcod format ">999".
                    find tofis where tofis.tofcod = bfiscal.opfcod 
                                        no-lock no-error.
                    if not avail tofis 
                    then do:
                        message "Operacao Fiscal Nao Cadastrada".
                        undo, retry.
                    end.
                    
                    if (forne.ufecod = "RS" and
                        substring(string(tofis.tofcod),1,1) <> "1") or
  
                       (forne.ufecod <> "RS" and
                        substring(string(tofis.tofcod),1,1) <> "2") 
                        
                    then do:
                        message "Operacao Fiscal Invalida".
                        undo, retry.
                    end.
                end.
                vopf = bfiscal.opfcod.
                
                do on error undo, retry:
                    update bfiscal.platot format "->>>,>>9.99".
                    if bfiscal.platot = 0
                    then undo, retry.
                end.

                bfiscal.bicms = bfiscal.platot.
                do on error undo, retry:
                    update bfiscal.bicms format "->>>,>>9.99".
                    if bfiscal.bicms > bfiscal.platot
                    then undo, retry.
                end.
                bfiscal.alicms = vali.
                do on error undo, retry:
                    
                    update bfiscal.alicms.
                    if bfiscal.alicms = 0 and
                       bfiscal.bicms > 0
                    then undo, retry.
                end.
                vali = bfiscal.alicms.

                bfiscal.icms = bfiscal.bicms * (bfiscal.alicms / 100).
                update bfiscal.icms.
                    
                if bfiscal.bicms < bfiscal.platot
                then bfiscal.outras = (bfiscal.platot - bfiscal.bicms).
                do on error undo, retry:
                    
                    update bfiscal.outras format "->>>,>>9.99".
 
                    if bfiscal.platot < (bfiscal.bicms + 
                                         bfiscal.outras +           
                                         bfiscal.ipi)
                    then do:
                        message "Valor nao confere".
                        undo, retry.
                    end.
                end.

                do on error undo, retry:
                    
                    bfiscal.ipi = bfiscal.platot - (bfiscal.bicms + 
                                                    bfiscal.outras + 
                                                    bfiscal.ipi).
                    update bfiscal.ipi format "->>>,>>9.99".
                    
                    if bfiscal.platot <> bfiscal.bicms + 
                                         bfiscal.outras +           
                                         bfiscal.ipi
                    then do:
                        message "Valor nao confere".
                        undo, retry.
                    end.
                end.    
                update    
                       bfiscal.plaobs[1] 
                       bfiscal.plaobs[2]
                       bfiscal.plaobs[3].
                
                bfiscal.desti  = vetb.
                bfiscal.movtdc = vmovtdc.

                totpla = 0.
                totbic = 0.
                toticm = 0.
                totipi = 0.
                totout = 0.
    
                for each fiscal where fiscal.desti = vetb   and
                                      fiscal.movtdc = vmovtdc and
                                      fiscal.plarec >= vdt1 and
                                      fiscal.plarec <= vdt2 no-lock:
                          
                    assign totpla = totpla + fiscal.platot
                           totbic = totbic + fiscal.bicms
                           toticm = toticm + fiscal.icms
                           totipi = totipi + fiscal.ipi
                           totout = totout + fiscal.outras.
                end.
    
 
                recatu1 =  recid(bfiscal).                 
                leave.
            end.
            
            
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-altera:
                message "Confirma Exclusao" fiscal.emite update sresp.
                if not sresp
                then leave.
                find next fiscal where fiscal.emite = vetb   and
                                       fiscal.movtdc = vmovtdc and
                                       fiscal.plarec >= vdt1 and
                                       fiscal.plarec <= vdt2 no-error.
                if not available fiscal
                then do:
                    find fiscal where recid(fiscal) = recatu1.
                    find prev fiscal where fiscal.desti = vetb and
                                           fiscal.movtdc = vmovtdc and
                                           fiscal.plarec >= vdt1 and
                                           fiscal.plarec <= vdt2
                                no-error.
                end.
                recatu2 = if available fiscal
                          then recid(fiscal)
                          else ?.
                find fiscal where recid(fiscal) = recatu1.
                do transaction:
                    delete fiscal.
                end.

                totpla = 0.
                totbic = 0.
                toticm = 0.
                totipi = 0.
                totout = 0.
    
                for each fiscal where fiscal.desti = vetb   and
                                      fiscal.movtdc = vmovtdc and
                                      fiscal.plarec >= vdt1 and
                                      fiscal.plarec <= vdt2 no-lock:
                                  
                    assign totpla = totpla + fiscal.platot
                           totbic = totbic + fiscal.bicms
                           toticm = toticm + fiscal.icms
                           totipi = totipi + fiscal.ipi
                           totout = totout + fiscal.outras.
                end.
                
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do transaction with frame f-alt side-label centered row 10.
                          
                vforcod = fiscal.emite.
                update vforcod label "Emite".
                
                find forne where forne.forcod = vforcod no-lock no-error.
                if not avail forne
                then do:
                    message "Fornecedor nao Cadastrado".
                    undo, retry.
                end.
                display forne.fornom no-label.
                
                fiscal.emite = vforcod.

                update fiscal.numero
                       fiscal.serie
                       fiscal.plaemi.
                do on error undo, retry:
                    update fiscal.plarec.
                    if fiscal.plarec < vdt1 or
                       fiscal.plarec > vdt2
                    then undo, retry.
                    
                    if fiscal.plarec < fiscal.plaemi
                    then do:
                        message "Data Invalida".
                        undo, retry.
                    end.
                end.

                        
             
                do on error undo, retry:
                    update fiscal.opfcod format ">999".
                    find tofis where tofis.tofcod = fiscal.opfcod 
                                        no-lock no-error.
                    if not avail tofis 
                    then do:
                        message "Operacao Fiscal Nao Cadastrada".
                        undo, retry.
                    end.
                    /*
                    if (forne.ufecod = "RS" and
                        substring(string(tofis.tofcod),1,1) <> "1") or
  
                       (forne.ufecod <> "RS" and
                        substring(string(tofis.tofcod),1,1) <> "2") 
                        
                    then do:
                        message "Operacao Fiscal Invalida".
                        undo, retry.
                    end. */
                end.

                do on error undo, retry:
                    update fiscal.platot format "->>>,>>9.99".
                    if fiscal.platot = 0
                    then undo, retry.
                end.
                do on error undo, retry:
                    update fiscal.bicms format "->>>,>>9.99".
                    if fiscal.bicms > fiscal.platot
                    then undo, retry.
                end.
                do on error undo, retry:
                    
                    update fiscal.alicms.
                    if fiscal.alicms = 0 and
                       fiscal.bicms > 0
                    then undo, retry.
                end.

                fiscal.icms = fiscal.bicms * (fiscal.alicms / 100).
                update fiscal.icms.
                    
                if fiscal.bicms < fiscal.platot
                then fiscal.outras = (fiscal.platot - fiscal.bicms).
                do on error undo, retry:
                    
                    update fiscal.outras format "->>>,>>9.99".
                end.

                do on error undo, retry:
                    
                    fiscal.ipi = fiscal.platot - (fiscal.bicms + 
                                                  fiscal.outras + 
                                                  fiscal.ipi).
                    update fiscal.ipi format "->>>,>>9.99".
                    
                    if fiscal.platot <> fiscal.bicms + 
                                        fiscal.outras +           
                                        fiscal.ipi
                    then do:
                        message "Valor nao confere".
                        undo, retry.
                    end.
                end.    
                update    
                       fiscal.plaobs[1] 
                       fiscal.plaobs[2]
                       fiscal.plaobs[3].
                

                totpla = 0.
                totbic = 0.
                toticm = 0.
                totipi = 0.
                totout = 0.
    
                for each bfiscal where bfiscal.desti = vetb   and
                                       bfiscal.movtdc = vmovtdc and
                                       bfiscal.plarec >= vdt1 and
                                       bfiscal.plarec <= vdt2 no-lock:
                          
                    assign totpla = totpla + bfiscal.platot
                           totbic = totbic + bfiscal.bicms
                           toticm = toticm + bfiscal.icms
                           totipi = totipi + bfiscal.ipi
                           totout = totout + bfiscal.outras.
                end.
    
 
                recatu1 =  recid(fiscal).                 
                leave.

            
            end.
            
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao"
            then do with frame f-altera2 side-label:
                disp fiscal.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do:
                vnumero = 0.
                update vnumero label "Numero" 
                       vforcod label "Fornecedor"
                        with frame f-procura side-label overlay centered row 5.
 
                find first bfiscal where bfiscal.desti = vetb     and
                                         bfiscal.movtdc = vmovtdc and
                                         bfiscal.emite  = vforcod and
                                         bfiscal.plarec >= vdt1 and
                                         bfiscal.plarec <= vdt2 and
                                        /* bfiscal.serie = fiscal.serie and*/
                                         bfiscal.numero = vnumero
                                                 no-lock no-error.
                if not avail bfiscal
                then do:
                    message "Nota nao Cadastrada".
                    recatu1 = recid(fiscal).
                    leave.
                end.
                recatu1 = recid(bfiscal).
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do:

                for each tt-uf:
                    delete tt-uf.
                end.
                recatu2 = recatu1.
                
                display tipo no-label with frame f1 no-label row 10 centered.

                choose field tipo with frame f1.
                hide frame f1 no-pause.

                if frame-index = 1
                then do:
                    if opsys = "UNIX"
                    then varquivo = "/admcom/relat/ctb99." + string(time) .
                    else varquivo = "l:~\relat~\ctb99".
                    {mdad.i
                        &Saida     = "value(varquivo)"
                        &Page-Size = "64"
                        &Cond-Var  = "130"
                        &Page-Line = "66"
                        &Nom-Rel   = ""manfis1""
                        &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
                        &Tit-Rel   = """LISTAGEM DE NOTAS DE ENTRADA  "" + 
                                     ""ESTABELECIMENTO:  "" + string(vetb) + 
                                     "" "" +
                                   string(vdt1,""99/99/9999"") + "" ate "" +
                                   string(vdt2,""99/99/9999"")"
                        &Width     = "130"
                        &Form      = "frame f-cabcab"}
                    for each fiscal where fiscal.desti = vetb and
/*                                        fiscal.movtdc = vmovtdc and */
                                          fiscal.plarec >= vdt1 and
                                          fiscal.plarec <= vdt2 
                                                no-lock break by fiscal.opfcod
                                                              by fiscal.numero:
                        
                        find forne where forne.forcod = fiscal.emite 
                                        no-lock no-error.
                        if avail forne
                        then do:
                            uf-ecod = forne.ufecod.
                            find first tt-uf where tt-uf.ufecod = forne.ufecod 
                                                    no-error.
                            if not avail tt-uf  
                            then do:  
                                create tt-uf.  
                                assign tt-uf.ufecod = forne.ufecod.  
                            end.  
                        end.
                        else do:
                            uf-ecod = "RS".
                            find first tt-uf where 
                                tt-uf.ufecod = "RS" no-error.
                            if not avail tt-uf  
                            then do:  
                                create tt-uf.  
                                assign tt-uf.ufecod = "RS".  
                            end.  
                        end.
                        assign
                            b-subst = 0
                            i-subst = 0.
                        find first plani where
                                   plani.etbcod = fiscal.desti and 
                                   plani.emite = fiscal.emite and
                                   plani.desti = fiscal.desti and
                                   plani.movtdc = fiscal.movtdc and
                                   plani.numero = fiscal.numero and
                                   plani.serie = fiscal.serie
                                   no-lock no-error.
                        if avail plani
                        then assign
                                b-subst = plani.bsubst
                                i-subst = plani.icmssubst
                                .      

                        tt-uf.uftotal = tt-uf.uftotal + fiscal.platot.
                        display 
                               fiscal.emite column-label "Emite" 
                               fiscal.plarec
                               fiscal.numero format ">>>>>>>>9"
                               uf-ecod format "xx" column-label "UF"
                               fiscal.opfcod column-label "OPF" format "9999"
                               fiscal.platot(total by fiscal.opfcod)
                                            format ">>,>>>,>>9.99"
                               fiscal.bicms(total by fiscal.opfcod)
                                            format ">>,>>>,>>9.99"
                               fiscal.icms(total by fiscal.opfcod)  
                                            format ">>,>>>,>>9.99"
                               b-subst(total by fiscal.opfcod)
                                             format ">>,>>>,>>9.99"
                                        column-label "Base!Subst."
                               i-subst(total by fiscal.opfcod)
                                            format ">>,>>>,>>9.99"
                                        column-label "ICMS!Subst."    
                               fiscal.ipi(total by fiscal.opfcod) 
                                            format ">,>>>,>>9.99"
                               fiscal.outras(total by fiscal.opfcod) 
                                            format ">,>>>,>>9.99" 
                               forne.fornom when avail forne format "x(30)" 
                                    with frame flista width 200 down.
                    end.
                    for each tt-uf:
                        disp tt-uf.ufecod column-label "UF"
                             tt-uf.uftotal(total) column-label "Total"
                                        format ">>,>>>,>>9.99"
                                            with frame f-uf down width 200.
                    end.                        
                    output close.  
                    if opsys = "UNIX"
                    then do:
                        run visurel.p(varquivo,"").
                    end.
                    else do:    
                        {mrod.i}
                    end.
                end.
                else do:
                    
                    for each tt-fis:
                        delete tt-fis.
                    end.                        

                    if opsys = "UNIX"
                    then varquivo = "/admcom/relat/ctb98." + string(time) .
                    else varquivo = "l:~\relat~\ctb98".

                    {mdad.i
                        &Saida     = "value(varquivo)"
                        &Page-Size = "64"
                        &Cond-Var  = "130"
                        &Page-Line = "66"
                        &Nom-Rel   = ""manfis1""
                        &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
                        &Tit-Rel   = """LISTAGEM DE NOTAS DE ENTRADA  "" + 
                                     ""ESTABELECIMENTO:  "" + string(vetb) + 
                                     "" "" +
                                   string(vdt1,""99/99/9999"") + "" ate "" +
                                   string(vdt2,""99/99/9999"")"
                        &Width     = "130"
                        &Form      = "frame f-cabcab3"}

                     
                     
                    for each fiscal where fiscal.desti = vetb and
                                          fiscal.plarec >= vdt1 and
                                          fiscal.plarec <= vdt2 no-lock:
                    
                        find first tt-fis where tt-fis.alicms = fiscal.alicms and
                                                tt-fis.opfcod = fiscal.opfcod no-error.
                        if not avail tt-fis 
                        then do: 
                            create tt-fis. 
                            assign tt-fis.opfcod = fiscal.opfcod 
                                   tt-fis.alicms = fiscal.alicms.
                        end. 
                        assign tot-pla = tot-pla + fiscal.platot  
                               tot-bic = tot-bic + fiscal.bicms  
                               tot-icm = tot-icm + fiscal.icms  
                               tot-ipi = tot-ipi + fiscal.ipi  
                               tot-out = tot-out + fiscal.out.
                    end.
                    for each plani where plani.desti = vetb   and
                                         plani.movtdc = 11    and
                                         plani.datexp >= vdt1 and
                                         plani.datexp <= vdt2 no-lock:
                    
                        find first tt-fis where tt-fis.alicms = 0 and
                                                tt-fis.opfcod = plani.hiccod no-error.
                        if not avail tt-fis 
                        then do: 
                            create tt-fis. 
                            assign tt-fis.opfcod = plani.hiccod 
                                   tt-fis.alicms = 0.
                        end. 
                        assign tot-pla = tot-pla + plani.platot  
                               tot-bic = tot-bic + plani.bicms  
                               tot-icm = tot-icm + plani.icms  
                               tot-ipi = tot-ipi + plani.ipi  
                               tot-out = tot-out + plani.outras.
                    end.

                    for each tt-fis by tt-fis.opfcod 
                                    by tt-fis.alicms:
                                     
                        display tt-fis.opfcod format "9999"
                                tt-fis.alicms 
                                tt-fis.tot-pla(total) column-label "Total" 
                                tt-fis.tot-bic(total) column-label "Base ICMS" 
                                tt-fis.tot-icm(total) column-label "ICMS" 
                                tt-fis.tot-ipi(total) column-label "IPI" 
                                tt-fis.tot-out(total) column-label "Outras"
                                        with frame flista1 width 200 down.
                    end.
                    output close.          
                    if opsys = "UNIX"
                    then do:
                        run visurel.p(varquivo,"").
                    end.
                    else do:    
                        {mrod.i}
                    end.

                end.
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
        if keyfunction (lastkey) = "end-error"
        then view frame frame-a.

        display 
            fiscal.emite column-label "Emite" 
            fiscal.plarec
            fiscal.numero 
            fiscal.opfcod column-label "OPF"
            fiscal.platot 
            fiscal.bicms 
            fiscal.icms 
            fiscal.ipi 
            fiscal.outras 
                with frame frame-a.
 
        
       display totpla 
               totbic 
               toticm 
               totipi 
               totout 
                with frame ftot side-label row 18.
         
        
       display totpla 
               totbic 
               toticm 
               totipi 
               totout with frame ftot width 80.
    
 
            
            
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(fiscal).
   end.
end.                         
