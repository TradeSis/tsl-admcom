/*
*
*    Esqueletao de Programacao
*
*/

{admcab.i}

def buffer regtroca for asstec_aux.

def temp-table asstec_aux
    field oscod like asstec.oscod
    field nome_campo as char
    field valor_campo as char
    field tipo_campo as char
    field data_campo as date
    field datexp as date
    field expostar as log
    .

def var vprocod like produ.procod.
def var vconfinado as log format "Sim/Nao".
def var recimp as recid.
def var fila as char.
def var xx as int.
def var vetbnom like estab.etbnom.
def var vfabnom like fabri.fabnom format "x(20)".
def var vfornom like forne.fornom format "x(20)".
def var varquivo as char.
def var vdata1 like plani.pladat initial today.
def var vdata2 like plani.pladat initial today.
def temp-table tt-asstec like asstec.
def temp-table wfasstec  like asstec
    index ind-1 oscod desc.
def var vserie  like asstec.apaser.    
def var vclicod like clien.clicod.
def var vfabcod like fabri.fabcod.
def var vforcod like forne.forcod.
def var v-escolha as int.
def var escolha   as char format "x(10)".

def var vpend as char format "x(11)" extent 4
        initial ["TODAS","PENDENTES","FECHADAS","POSTO"].

def var v-totalizador as int.
def var vopcao  as char format "x(15)" 
    extent 4 initial["Cliente","Ord.Servico","Serie","Produto"]. 

def var vpronom like produ.pronom.
def var vclinom like clien.clinom.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
/*
def var esqcom1         as char format "x(12)" extent 6
   initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem","Procura"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Reg. Troca","","","",""].
*/

def var esqcom1         as char format "x(12)" extent 6 initial ["Alteracao","Reg. Troca","Inclusao","Exclusao","Consulta","Procura"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Listagem","","","",""].

def buffer basstec       for asstec.
def var vetbcod         like asstec.etbcod.
def var voscod          like asstec.oscod.
def var v-imei-cel-aux  as character no-undo.
def var v-cel-doa-aux   as logical format "Sim/Nao" no-undo.
def var v-proobs-aux    like asstec.proobs no-undo.

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

repeat:
    recatu1 = ?.
    vetbcod = setbcod.
    update vetbcod label "Fil"
        with frame fest color white/cyan 
            side-labels no-box row 4 centered.
    
    /* find estab where estab.etbcod = vetbcod no-lock. */
    
    vfabcod = 0.
    update vfabcod label "Fabricante" with frame fest.
    if vfabcod = 0
    then display "TODOS" @ fabri.fabfant with frame fest.
    else do:
        find fabri where fabri.fabcod = vfabcod no-lock no-error.
        if not avail fabri
        then do:
            message "Fabricante nao cadastrado".
            pause.
            undo, retry.
        end.
        display fabri.fabfant no-label format "x(15)" with frame fest.
    end. 
    
    vforcod = 0.
    update vforcod label "Ass.Tec." with frame fest.
    if vforcod = 0
    then display "TODOS" @ forne.forfant with frame fest.
    else do:
        find forne where forne.forcod = vforcod no-lock no-error.
        if not avail forne
        then do:
            message "Fornecedor nao cadastrado".
            pause.
            undo, retry.
        end.
        display forne.forfant no-label format "x(15)" with frame fest.
    end. 
    

    
    display vpend no-label 
        with frame f-sit no-box row 5 centered.
    choose field vpend with frame f-sit.        
    v-escolha = frame-index.
    
    for each wfasstec:
        delete wfasstec.
    end.

    v-totalizador = 0.
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock.
        for each asstec where asstec.etbcod = estab.etbcod no-lock.
        
            if vfabcod <> 0
            then do:
                find produ where produ.procod = asstec.procod no-lock no-error.
                if not avail produ
                then next.
                if produ.fabcod = vfabcod
                then.
                else next.
            
            end.
            if vforcod <> 0
            then do:
                if asstec.forcod = vforcod
                then.
                else next.
            end.
            
            if v-escolha = 2
            then do:
                if dtretass = ?
                then.
                else next.
            end.

            if v-escolha = 3
            then do:
                if dtretass <> ?
                then.
                else next.
            end.
            if v-escolha = 4 
            THEN DO:
                IF dtenvass <> ? and
                    dtretass = ?
                then.
                else next.  
            END.
            create wfasstec.
            buffer-copy asstec to wfasstec.
        
        
            v-totalizador = v-totalizador + 1.
        
        end.    
        
    end.    
    /*
    display v-totalizador label "Totalizador" format ">>>>9"
            "O.S" with frame fest.
    */
    
    

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find first wfasstec where true no-error.
    else find first wfasstec where recid(wfasstec) = recatu1 no-lock.
    vinicio = yes.
    if not available wfasstec
    then do with frame f-inclui1 overlay row 6 width 80 side-labels
                            no-validate.
        message "Cadastro de Assistencia Tecnica Vazia".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
       
        for each tt-asstec:
            delete tt-asstec.
        end.
                
        create tt-asstec.     
        assign tt-asstec.etbcod = setbcod.
                
        update tt-asstec.etbcod colon 10 label "Filial".
               
        display tt-asstec.oscod colon 40 label "O.S.".

        update tt-asstec.forcod colon 10 label "Cod.Assis".
        find forne where forne.forcod = tt-asstec.forcod no-lock no-error.
        if not avail forne
        then do: 
            message "Assistencia nao cadastrada".
            pause.
            undo.
        end.
        display forne.fornom no-label.
                                    
                
        update tt-asstec.procod colon 10.
               
        find produ where produ.procod = tt-asstec.procod no-lock no-error.
        if not avail produ      
        then undo,retry.
        else display produ.pronom no-label format "x(30)".
                
        update tt-asstec.apaser format "x(15)" colon 10.
                
        update tt-asstec.clicod colon 10 label "Cliente".
               
        find first clien where clien.clicod = tt-asstec.clicod no-lock no-error.
        if not avail clien
        then undo,retry.
        else display clien.clinom no-label.
                 
        update tt-asstec.pladat colon 10 label "Data NF"
               tt-asstec.planum colon 50 
               tt-asstec.proobs colon 10 label "Obs.Prod."
               tt-asstec.defeito colon 10 
               tt-asstec.nftnum colon 10 label "NF Transf" 
               tt-asstec.reincid colon 50 
               tt-asstec.dtentdep colon 25 label "Dt.Entrada Deposito"
               tt-asstec.dtenvass colon 60 label "Dt.Envio Assistencia" 
               tt-asstec.dtretass colon 25 label "Dt.Retirada Assistencia" 
               tt-asstec.dtenvfil colon 60 label "Dt.Envio para Filial" 
               tt-asstec.osobs colon 10 label "Obs.OS".
       
        do transaction:  
            create asstec.  
            
            find last basstec no-lock no-error. 
            if avail basstec  
            then asstec.oscod = basstec.oscod + 1.  
            else asstec.oscod = 1. 
   
            display asstec.oscod @ tt-asstec.oscod
                            colon 40 label "O.S.".
            
                
            assign /* asstec.oscod  = tt-asstec.oscod */
                   asstec.etbcod = tt-asstec.etbcod 
                   asstec.forcod = tt-asstec.forcod 
                   asstec.procod = tt-asstec.procod 
                   asstec.apaser = tt-asstec.apaser 
                   asstec.clicod = tt-asstec.clicod 
                   asstec.plaetb = tt-asstec.plaetb 
                   asstec.pladat = tt-asstec.pladat 
                   asstec.planum = tt-asstec.planum 
                   asstec.serie  = tt-asstec.serie 
                   asstec.proobs = tt-asstec.proobs 
                   asstec.defeito = tt-asstec.defeito 
                   asstec.nftnum  = tt-asstec.nftnum 
                   asstec.reincid = tt-asstec.reincid 
                   asstec.dtentdep = tt-asstec.dtentdep 
                   asstec.dtenvass = tt-asstec.dtenvass 
                   asstec.dtretass = tt-asstec.dtretass 
                   asstec.dtenvfil = tt-asstec.dtenvfil 
                   asstec.osobs    = tt-asstec.osobs.
        
        end.

        create wfasstec.
        buffer-copy asstec to wfasstec.  
        find asstec where asstec.oscod = wfasstec.oscod no-lock no-error.
        
        recatu1 = recid(wfasstec).
        vinicio = no.
        

    end.
    clear frame frame-a all no-pause.
    
    find first produ where produ.procod = wfasstec.procod no-lock no-error.
    if avail produ
    then vpronom = produ.pronom.
    else vpronom = "".
    find first clien where clien.clicod = wfasstec.clicod no-lock no-error.
    if avail clien and clien.clicod <> 0
    then vclinom = clien.clinom.
    else vclinom = "ESTOQUE".
    pause 0.
    display
        wfasstec.etbcod column-label "Fil"
        wfasstec.oscod  format ">>>>>>9"
        wfasstec.datexp column-label "Data!Inclusao"
        wfasstec.procod
        vpronom format "x(20)"
        wfasstec.clicod 
        vclinom format "x(14)"  /*25*/
            with frame frame-a 10 down centered
                title "TOTAL DE O.S: " + string(v-totalizador,"99999").

    recatu1 = recid(wfasstec).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next wfasstec where true no-lock no-error.
        if not available wfasstec
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.

    find first produ where produ.procod = wfasstec.procod no-lock no-error.
    if avail produ
    then vpronom = produ.pronom.
    else vpronom = "".
    find first clien where clien.clicod = wfasstec.clicod no-lock no-error.
    if avail clien and clien.clicod <> 0
    then vclinom = clien.clinom.
    else vclinom = "ESTOQUE".
    
    display
        wfasstec.etbcod 
        wfasstec.oscod
        wfasstec.datexp
        wfasstec.procod
        vpronom 
        wfasstec.clicod 
        vclinom with frame frame-a.

 

    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find first wfasstec where recid(wfasstec) = recatu1 no-lock.

        choose field wfasstec.etbcod
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

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next wfasstec where true no-lock no-error.
                if not avail wfasstec
                then leave.
                recatu1 = recid(wfasstec).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev wfasstec where true no-error.
                if not avail wfasstec
                then leave.
                recatu1 = recid(wfasstec).
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
            find next wfasstec where true no-error.
            if not avail wfasstec
            then next.
            color display normal
                wfasstec.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev wfasstec where true no-error.
            if not avail wfasstec
            then next.
            color display normal
                wfasstec.etbcod.
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
            then do with frame f-inclui overlay row 6 width 80 side-labels.
            
                    
                for each tt-asstec:
                    delete tt-asstec.
                end.
                
                run inclui-os.
                
                /***
                create tt-asstec.    

                assign tt-asstec.etbcod = setbcod.
                
                update tt-asstec.etbcod colon 11 label "Filial"
                           with frame f-inclui no-validate.
               
                disp tt-asstec.oscod when tt-asstec.oscod > 0
                            colon 40 label "O.S." 
                                    with frame f-inclui.

                update tt-asstec.forcod colon 11 label "Cod.Assis".
                find forne where forne.forcod = tt-asstec.forcod 
                            no-lock no-error.
                if not avail forne
                then do:
                    message "Assistencia nao cadastrada".
                    pause.
                    undo.
                end.
                display forne.fornom no-label  format "x(30)"
                        forne.forfone.
                                    
                
                update tt-asstec.procod colon 11
                           with frame f-inclui no-validate.
               
                find produ where produ.procod = tt-asstec.procod 
                                                    no-lock no-error.
                if not avail produ      
                then undo,retry.
                else display produ.pronom no-label format "x(30)"
                                    with frame f-inclui.
                
                update tt-asstec.apaser format "x(20)" colon 11
                                   with frame f-inclui no-validate.
                
                update tt-asstec.clicod colon 11 label "Cliente"
                                   with frame f-inclui no-validate.
               
                find first clien where clien.clicod = tt-asstec.clicod 
                                            no-lock no-error.
                if not avail clien
                then undo,retry.
                else display clien.clinom no-label with frame f-inclui.
                 
                update tt-asstec.pladat colon 11 label "Data NF"
                       tt-asstec.planum colon 50 .

                v-imei-cel-aux = "".
                if can-find(first plaviv where
                                  plaviv.procod = tt-asstec.procod and
                                  plaviv.exportado = yes)
                then do:
                                                  
                  find first tbprice where tbprice.etb_venda  = tt-asstec.etbcod
                                       and tbprice.nota_venda = tt-asstec.planum
                                       and tbprice.data_venda = tt-asstec.pladat
                                                    no-lock no-error.
                   if available tbprice
                   then do:
                   
                       assign v-imei-cel-aux = tbprice.serial.
                                              
                   end.
                   
                   bloco_inclui_imei:                                                               repeat with frame f-inclui:    
                       update v-imei-cel-aux colon 11
                                      label "IMEI Cel." format "x(20)"
                                                    with frame f-inclui.       
                       if v-imei-cel-aux = ""
                       then do:
                                              
                           message "O campo IMEI Cel. tem preenchimento obrigatorio".
                           undo,retry.
                           
                       end.
                       else leave bloco_inclui_imei.

                   end.
                                          
                end.
                   
                if (today - 9) <= tt-asstec.pladat
                then update v-cel-doa-aux colon 50
                             label "DOA" format "Sim/Nao"
                                    with frame f-inclui.                      
                else disp v-cel-doa-aux colon 50
                             label "DOA" format "Sim/Nao"
                                    with frame f-inclui.
                    
                                                          
                if keyfunction(lastkey) = "END-ERROR"
                THEN UNDO,retry.
                
                update tt-asstec.proobs colon 11 label "Obs.Prod."
                       tt-asstec.defeito colon 11 
                       tt-asstec.nftnum colon 11 label "NF Transf" 
                       tt-asstec.reincid colon 50 
                       tt-asstec.dtentdep colon 25 label "Dt.Entrada Deposito"
                       tt-asstec.dtenvass colon 60 
                                label "Dt.Envio Assistencia" 
                       tt-asstec.dtretass colon 25 
                                label "Dt.Retirada Assistencia"
                       tt-asstec.dtenvfil colon 60 
                                label "Dt.Envio para Filial" 
                       tt-asstec.osobs colon 11 label "Obs.OS"
                                       with frame f-inclui.
       
                do transaction:

                    create asstec.  
                
                    
                    find last basstec no-lock no-error.
                    if avail basstec 
                    then asstec.oscod = basstec.oscod + 1. 
                    else asstec.oscod = 1. 
   
                    display asstec.oscod @ tt-asstec.oscod
                            colon 40 label "O.S." 
                                    with frame f-inclui.
                    
                    
                    assign asstec.etbcod = tt-asstec.etbcod
                        /* asstec.oscod  = tt-asstec.oscod */
                           asstec.forcod = tt-asstec.forcod
                           asstec.procod = tt-asstec.procod
                           asstec.apaser = tt-asstec.apaser
                           asstec.clicod = tt-asstec.clicod
                           asstec.plaetb = tt-asstec.plaetb
                           asstec.pladat = tt-asstec.pladat
                           asstec.planum = tt-asstec.planum
                           asstec.serie  = tt-asstec.serie
                           asstec.defeito = tt-asstec.defeito
                           asstec.nftnum  = tt-asstec.nftnum
                           asstec.reincid = tt-asstec.reincid
                           asstec.dtentdep = tt-asstec.dtentdep
                           asstec.dtenvass = tt-asstec.dtenvass
                           asstec.dtretass = tt-asstec.dtretass
                           asstec.dtenvfil = tt-asstec.dtenvfil
                           asstec.osobs    = tt-asstec.osobs.
                           
                    if v-imei-cel-aux <> "" then do:
                                               
                        asstec.proobs = tt-asstec.proobs
                                         + "|IMEI=" + v-imei-cel-aux
                                         + "|DOA=" + string(v-cel-doa-aux).
                                         
                    end.
                    else asstec.proobs = tt-asstec.proobs.
                           
                end.
                create wfasstec.
                buffer-copy asstec to wfasstec.  
                ***/
                
                find asstec where asstec.oscod = wfasstec.oscod 
                                no-lock no-error.
                
                recatu1 = recid(wfasstec).
                leave.
                
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 width 80 side-labels.
                
                for each tt-asstec:
                    delete tt-asstec.
                end.
                create tt-asstec.
                {asstec.i tt-asstec wfasstec}

                
                disp tt-asstec.etbcod colon 10 label "Filial"
                     tt-asstec.oscod colon 40 label "O.S." 
                       with frame f-altera no-validate.
               
                update tt-asstec.etbcod
                       tt-asstec.forcod colon 10 label "Cod.Assis".
                find forne where forne.forcod = tt-asstec.forcod 
                            no-lock no-error.
                if not avail forne
                then do:
                    message "Assistencia nao cadastrada".
                    pause.
                    undo.
                end.
                display forne.fornom no-label
                        forne.forfone.
                
                update tt-asstec.procod colon 10
                       with frame f-altera no-validate.
                
                find first produ where produ.procod = tt-asstec.procod 
                        no-lock no-error.
                if not avail produ
                then undo,retry.
                else display produ.pronom no-label format "x(30)"
                                with frame f-altera.
                
                update tt-asstec.apaser format "x(20)" colon 10
                       with frame f-altera no-validate.
                if tt-asstec.clicod > 1
                then disp tt-asstec.clicod with frame f-altera.
                else update tt-asstec.clicod colon 10 label "Cliente"
                       with frame f-altera no-validate.
               
                find first clien where clien.clicod = tt-asstec.clicod
                            no-lock no-error.
                if not avail clien
                then undo,retry.
                else display clien.clinom no-label with frame f-altera.
                 
                update tt-asstec.pladat colon 10 label "Data NF"
                       tt-asstec.planum colon 50 
                        with frame f-altera.
    
                assign v-imei-cel-aux = ""
                       v-cel-doa-aux  = no.
                if can-find(first plaviv where plaviv.procod = tt-asstec.procod
                                           and plaviv.exportado = yes)
                then do:
                
                    if acha("DOA",tt-asstec.proobs) <> ""
                    then do:
                   
                        assign
                        v-cel-doa-aux = (acha("DOA",tt-asstec.proobs) = "Yes")
                        tt-asstec.proobs =
                replace(tt-asstec.proobs,"|DOA=" + string(v-cel-doa-aux),"").

                    end.
                                                           
                    if acha("IMEI",tt-asstec.proobs) <> ""
                    then do:
                      assign
                      v-imei-cel-aux = acha("IMEI",tt-asstec.proobs)                                 tt-asstec.proobs =
                      replace(tt-asstec.proobs,"|IMEI=" + v-imei-cel-aux,"").

                    end.
                    else do:
                                        
                        find first tbprice where
                                   tbprice.etb_venda = tt-asstec.etbcod and
                                   tbprice.nota_venda = tt-asstec.planum and
                                   tbprice.data_venda = tt-asstec.pladat
                                                no-lock no-error.
                        if available tbprice
                        then do:
                        
                            assign v-imei-cel-aux = tbprice.serial.

                        end.
                        
                    end.
                   
                    bloco_altera_imei:
                    repeat with frame f-altera:

                        update v-imei-cel-aux colon 10
                                    label "IMEI Cel." format "x(20)"
                                            with frame f-altera.
                                            
                        if v-imei-cel-aux = ""
                        then do:
                                                                               
                            message "O campo IMEI Cel. tem preenchimento obrigatorio".
                            undo,retry.
                                                           
                        end.
                        else leave bloco_altera_imei.

                    end.
 
                    if (tt-asstec.datexp - 9) <= tt-asstec.pladat
                    then update v-cel-doa-aux colon 50
                                  label "DOA"
                                    with frame f-altera.
                    else display v-cel-doa-aux colon 50
                                  label "DOA"
                                    with frame f-altera.
               
                end.
                                       
                if keyfunction(lastkey) = "END-ERROR"
                THEN UNDO,retry.
                
                update tt-asstec.proobs colon 10 label "Obs.Prod."
                       tt-asstec.defeito colon 10 
                       tt-asstec.nftnum colon 10 label "NF Transf" 
                       tt-asstec.reincid colon 50 
                       tt-asstec.dtentdep colon 25 label "Dt.Entrada Deposito"
                       tt-asstec.dtenvass colon 60 label "Dt.Envio Assistencia"
                       tt-asstec.dtretass 
                            colon 25 label "Dt.Retirada Assistencia"
                       tt-asstec.dtenvfil colon 60 label "Dt.Envio para Filial" 
                       tt-asstec.osobs colon 10 label "Obs.OS"
                           with frame f-altera.
                       
                do transaction:
                
                    find asstec where asstec.oscod = wfasstec.oscod.
                    
                    assign asstec.etbcod   = tt-asstec.etbcod
                           asstec.procod   = tt-asstec.procod 
                           asstec.clicod   = tt-asstec.clicod 
                           asstec.plaetb   = tt-asstec.plaetb 
                           asstec.planum   = tt-asstec.planum 
                           asstec.serie    = tt-asstec.serie 
                           asstec.apaser   = tt-asstec.apaser 
                           asstec.defeito  = tt-asstec.defeito 
                           asstec.nftnum   = tt-asstec.nftnum 
                           asstec.dtentdep = tt-asstec.dtentdep 
                           asstec.dtenvass = tt-asstec.dtenvass 
                           asstec.reincid  = tt-asstec.reincid 
                           asstec.dtretass = tt-asstec.dtretass 
                           asstec.dtenvfil = tt-asstec.dtenvfil 
                           asstec.osobs    = tt-asstec.osobs 
                           asstec.pladat   = tt-asstec.pladat 
                           asstec.forcod   = tt-asstec.forcod.
      
                    if v-imei-cel-aux <> ""
                    then do:
                                                                   
                        asstec.proobs = tt-asstec.proobs
                                            + "|IMEI=" + v-imei-cel-aux
                                            + "|DOA=" + string(v-cel-doa-aux).
            
                    end.
                    else asstec.proobs = tt-asstec.proobs.
                           
                    delete wfasstec.
                    
                end.
                create wfasstec.
                buffer-copy asstec to wfasstec.  
       
                recatu1 = recid(wfasstec).

                find asstec where asstec.oscod = wfasstec.oscod no-lock.
                
                leave.
   
             
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 width 80 side-labels.
            
                find asstec where asstec.oscod = wfasstec.oscod no-lock.
                
                find first regtroca where
                                   regtroca.oscod = asstec.oscod and
                                   regtroca.nome_campo = "REGISTRO-TROCA"
                                   no-lock no-error.
 
                 disp asstec.etbcod colon 10 label "Filial"
                     asstec.oscod  colon 40 label "O.S." 
                     asstec.datexp colon 67 label "Data Inclusao"
                     asstec.pladat colon 11 label "Data Venda"
                     asstec.planum colon 40 label "Numero Venda"
                     asstec.clicod colon 11 label "cliente"
                       with frame f-consulta no-validate.
               
                find first clien where clien.clicod = asstec.clicod 
                                    no-lock no-error.
                if not avail clien
                then .
                else display clien.clinom no-label format "x(35)"
                        with frame f-consulta.
                      
                if avail regtroca
                then disp regtroca.valor_campo no-label
                            format "x(20)".
                
                disp  asstec.procod colon 10
                        with frame f-consulta no-validate.
               
                find first produ where produ.procod = asstec.procod 
                            no-lock no-error.
                if not avail produ
                then undo,retry.
                else display produ.pronom no-label format "x(30)"
                                with frame f-consulta.
                if asstec.serie = "N"
                then vconfinado = no.
                else vconfinado = yes.
                
                disp vconfinado label "Confinado?"
                    with frame f-consulta.
                
                find forne where forne.forcod = asstec.forcod 
                            no-lock no-error.

                display asstec.forcod colon 10 label "Cod.Ass."
                        forne.fornom no-label when avail forne
                        forne.forfone when avail forne.
                
                disp asstec.apaser format "x(20)" colon 10
                       with frame f-consulta no-validate.
                
                if acha("IMEI",asstec.proobs) <> ""
                then do:

                    assign v-cel-doa-aux = (acha("DOA",asstec.proobs) = "yes").
                    assign v-proobs-aux =                                                             replace(asstec.proobs,"|DOA=" + trim(string(v-cel-doa-aux,"yes/no")),"").


                    assign
                       v-imei-cel-aux = acha("IMEI",asstec.proobs)
                       v-proobs-aux =
                          replace(v-proobs-aux,"|IMEI=" + v-imei-cel-aux,"").

                      disp v-imei-cel-aux label "IMEI Cel." format "x(20)"
                           v-cel-doa-aux  colon 50 label "DOA"
                                      format "Sim/Nao" with frame f-consulta.

                end.
                else v-proobs-aux = asstec.proobs.

                disp v-proobs-aux colon 10 label "Obs.Prod."
                     asstec.defeito colon 10 
                     asstec.nftnum colon 10 label "NF Transf" 
                     asstec.reincid colon 50 
                     asstec.dtentdep colon 25 label "Dt.Entrada Deposito"
                     asstec.dtenvass colon 60 label "Dt.Envio Assistencia"
                     asstec.dtretass colon 25 label "Dt.Retirada Assistencia"
                     asstec.dtenvfil colon 60 label "Dt.Envio para Filial" 
                     asstec.osobs colon 10 label "Obs.OS"
                       with frame f-consulta.

                find last osxnf where osxnf.oscod  = asstec.oscod
                                  and osxnf.movtdc = 6 no-lock no-error.
                                        
                if available osxnf
                then do:
                                        
                    find first plani where plani.movtdc = osxnf.movtdc and
                               plani.etbcod = osxnf.etbcod and
                               plani.emite  = osxnf.emite  and
                               plani.serie  = osxnf.serie  and
                               plani.numero = osxnf.numero
                                     no-lock no-error.
                    if avail plani then do:
                                         
                        disp osxnf.numero label "NF Envio para Filial"
                             plani.pladat label "NF Data"
                             with frame f-consulta.
                       
                    end.
                           
                end.
            
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" wfasstec.oscod update sresp.
                if not sresp
                then leave.
                find next wfasstec where true no-error. 
                if not available wfasstec
                then do:
                    find first wfasstec where recid(wfasstec) = recatu1.
                    find prev wfasstec where true no-error.
                end.
                recatu2 = if available wfasstec
                          then recid(wfasstec)
                          else ?.
                do transaction:
                    find first wfasstec where recid(wfasstec) = recatu1.
                                       
                    find asstec where asstec.oscod = wfasstec.oscod no-error.
                    delete asstec.
                    delete wfasstec.
                    
                end.
                recatu1 = recatu2.
                leave.
            end.

            if esqcom1[esqpos1] = "Procura"
            then do with frame f-opcao:
                hide frame f-oscod no-pause.
                hide frame f-cli no-pause.
                hide message.
                display vopcao no-label 
                        with frame f-opcao no-label centered.
                choose field vopcao.
                if frame-index = 1
                then do:
                    update vclicod label "Cliente" with frame f-cli
                                side-label width 80.
                    find clien where clien.clicod = vclicod no-lock no-error.
                    if avail clien
                    then display clien.clinom with frame f-cli.
                    find first wfasstec where 
                               wfasstec.clicod = vclicod no-error.
                    if not avail wfasstec
                    then do:
                        find first asstec where asstec.clicod = vclicod 
                                    no-lock no-error.
                        if not avail asstec
                        then do:
                            message "Assistencia Tecnica nao cadastrada".
                            undo, retry.
                        end.
                        else do:
                            
                           create wfasstec. 
                           buffer-copy asstec to wfasstec.
                        
                        end.
                    end.
                end.       
                if frame-index = 2
                then do:
                    update voscod with frame f-oscod centered side-label.
                    find first wfasstec where wfasstec.oscod = voscod no-error.
                    
                    if not avail wfasstec
                    then do:
                        find first asstec where asstec.oscod = voscod 
                                    no-lock no-error.
                        if not avail asstec
                        then do:
                            message "Assistencia Tecnica nao cadastrada".
                            undo, retry.
                        end.
                        else do:
                            
                           create wfasstec. 
                           buffer-copy asstec to wfasstec.
                        
                        end.
                    
                    end.
                    
                end.
                if frame-index = 3
                then do:
                    vserie = "".
                    update vserie with frame f-serie centered side-label.
                    find first wfasstec where wfasstec.apaser = vserie
                                    no-error.
                    if not avail wfasstec
                    then do:
                    
                        find first asstec where asstec.apaser = vserie 
                                no-lock no-error.
                        if not avail asstec
                        then do:
                            message "Assistencia Tecnica nao cadastrada".
                            undo, retry.
                        end.
                        else do:
                            
                           create wfasstec. 
                           buffer-copy asstec to wfasstec.
                        
                        end.
                    end.
                end.
                if frame-index = 4
                then do:
                    update vprocod with frame f-procod centered side-label.
                    find first wfasstec where 
                               wfasstec.procod = vprocod no-error.
                    
                    if not avail wfasstec
                    then do:
                        bell.
                        message color red/with
                        "Nenhum registro encontrado."
                        view-as alert-box.
                    end.    
                    else do:
                        for each wfasstec where
                                 wfasstec.procod <> vprocod .
                            delete wfasstec.
                        end.
                        recatu1 = ?.
                        next bl-princ.             
                    end.
                end.

            end.
            if esqcom1[esqpos1] = "Reg. Troca"
                and wfasstec.clicod > 0
            then do with  frame f-disp-rg:
                disp  
                wfasstec.etbcod column-label "Fil"
                wfasstec.oscod  format ">>>>>>9"
                wfasstec.datexp column-label "Data!Inclusao"
                wfasstec.procod
                /*vpronom format "x(20)" */
                wfasstec.clicod 
                /*vclinom format "x(14)"*/   
                with frame f-disp-rg 1 down.
                pause 0.
                
                run reg-troca.p(input wfasstec.oscod).

                hide frame f-disp-rg.
                leave.
            end.

        end.
        else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                            with frame f-com2.
                            
            if esqcom2[esqpos2] = "Listagem"
            then do:
                message "Confirma Impressao das O.S" update sresp.
                if not sresp
                then leave.

                message "Listar OS selecionada ou Listagem Geral?"
                        update sresp format "Selecionada/Geral".

                recatu2 = recatu1.

                if v-escolha = 1
                then escolha = "TODAS".

                if v-escolha = 2
                then escolha = "PENDENTES".

                if v-escolha = 3
                then escolha = "FECHADAS".
                
                if vetbcod = 0
                then vetbnom = " TODAS FILIAIS".
                else vetbnom = " FILIAL: " + string(vetbcod,">99").

                
                if vfabcod = 0
                then vfabnom = "TODOS FABRICANTES".
                else vfabnom = fabri.fabnom.

 
                if vforcod   = 0
                then vfornom = "TODAS ASSISTENCIAS".
                else vfornom = forne.fornom.
                
                message entry(2,sparam,";"). pause.
                
                if opsys = "unix"  and entry(2,sparam,";") <> "AniTA"
                then do:
                    
                    find first impress where impress.codimp = setbcod 
                            no-lock no-error.
                    if avail impress 
                    then do:
                        run acha_imp.p (input recid(impress),
                                        output recimp).                                                 find impress where recid(impress) = recimp
                            no-lock no-error.
                            
                                        
                        assign fila = string(impress.dfimp). 
                    end.    
                    varquivo = "/admcom/relat/os." + string(time).
 
                    xx = 0.
                    
                    output to value(varquivo) page-size 63.
                    put escolha at 30 " - "
                        vetbnom skip(2).
                    for each wfasstec break by wfasstec.etbcod
                                            by wfasstec.oscod:
                
                        if sresp
                        then if recid(wfasstec) <> recatu2
                             then next.
                        /*
                        xx = xx + 1.
                        */
                        find first produ where produ.procod = wfasstec.procod 
                                                    no-lock no-error.
                        find first clien where clien.clicod = wfasstec.clicod 
                                        no-lock no-error.
                        if avail clien and clien.clicod <> 0
                        then vclinom = clien.clinom.
                        else vclinom = "ESTOQUE".
                        find estoq where estoq.etbcod = 998 and
                                         estoq.procod = produ.procod
                                         no-lock no-error.
                        if avail estoq
                        then xx = estoq.estatual.
                        else xx = 0. 
                        display xx /*(count by wfasstec.etbcod) */
                                            column-label "Qtd" format "->>>>9"
                                wfasstec.etbcod column-label "Filial"
                                wfasstec.oscod  column-label "OS"
                                wfasstec.procod column-label "Codigo"
                                wfasstec.datexp column-label "DataInclusao"
                                produ.pronom when avail produ 
                                            column-label "Produto"
                                wfasstec.clicod column-label "Cliente"
                                        format ">>>>>>>>>>>9"
                                vclinom         column-label "Nome"
                                    with frame f-lista width 150 down.
                                
                        if last-of(wfasstec.etbcod)
                        then xx = 0.
 
                    end.
                    output close.
    
                    os-command silent lpr value(fila + " " + varquivo).
                end.                     
 
                else do:
                    if opsys = "UNIX"
                    then varquivo = "/admcom/relat/osl." + string(time).
                    else varquivo = "l:~\relat~\osw." + string(time).

                    {mdad.i &Saida     = "value(varquivo)" 
                            &Page-Size = "0" 
                            &Cond-Var  = "120" 
                            &Page-Line = "66"
                            &Nom-Rel   = ""asstec""
                            &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
                            &Tit-Rel   = """LISTAGEM DE OS - "" +
                                          escolha + "" - "" +
                                          vetbnom + "" - "" +
                                          vfabnom + "" - "" +
                                          vfornom" 
                            &Width     = "150"
                            &Form      = "frame f-cabcab"}
    
                    xx = 0.
                    for each wfasstec break by wfasstec.etbcod
                                            by wfasstec.oscod:

                        if sresp
                        then if recid(wfasstec) <> recatu2
                             then next.
                        /*
                        xx = xx + 1.
                        */
                        find first produ where produ.procod = wfasstec.procod 
                                                    no-lock no-error.
                        find first clien where clien.clicod = wfasstec.clicod 
                                        no-lock no-error.
                        if avail clien and clien.clicod <> 0
                        then vclinom = clien.clinom.
                        else vclinom = "ESTOQUE".

                        find estoq where estoq.etbcod = 998 and
                                         estoq.procod = produ.procod
                                         no-lock no-error.
                        if avail estoq
                        then xx = estoq.estatual.
                        else xx = 0. 
                        
                        display xx /*(count by wfasstec.etbcod) */
                                            column-label "Qtd" format "->>>>9"
                                wfasstec.etbcod column-label "Filial"
                                wfasstec.oscod  column-label "OS"
                                wfasstec.procod column-label "Codigo"
                                wfasstec.datexp column-label "DataInclusao"  
                                produ.pronom when avail produ 
                                            column-label "Produto"
                                wfasstec.clicod column-label "Cliente"
                                    format ">>>>>>>>>>>>9"
                                vclinom         column-label "Nome"
                                    with frame f-lista2 width 190 down.
                                
                        if last-of(wfasstec.etbcod)
                        then xx = 0.
 
                    end.
                    output close.
                    if opsys = "UNIX"
                    then do:
                        run visurel.p(varquivo, "").
                    end.
                    else do:    
                    {mrod.i}
                    end.
                end.
     
                
                recatu1 = recatu2.
                leave.
            end.

          end.
          view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        
        find first produ where produ.procod = wfasstec.procod no-lock no-error.
        if avail produ
        then vpronom = produ.pronom.
        else vpronom = "".
        find first clien where clien.clicod = wfasstec.clicod no-lock no-error.
        if avail clien and clien.clicod <> 0
        then vclinom = clien.clinom.
        else vclinom = "ESTOQUE".

        display
            wfasstec.etbcod
            wfasstec.oscod 
            wfasstec.datexp
            wfasstec.procod
            vpronom 
            wfasstec.clicod 
            vclinom  with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(wfasstec).
   end.
end.
end.

procedure reg-troca:
    def var vsel as char format "x(15)" extent 2
        init["30 DIAS","REINCIDENCIA"].
    def var vmarca as char format "x" extent 2.
    format "[" space(0) vmarca[1] space(0) "]"  
       vsel[1]             skip
       "[" space(0) vmarca[2] space(0) "]"  
       vsel[2]             skip
       /*
       "[" space(0) vmarca[3] space(0) "]"
       vsel[3]            skip
       */
       with frame f-sel
       1 down centered no-label row 12 overlay
       title " Aut. Troca ".

    def var vi as in init 0.
    def var va as int init 0.

    vi = 1.
    vmarca = "".
    find first asstec_aux where
               asstec_aux.oscod = wfasstec.oscod and
               asstec_aux.nome_campo = "REGISTRO-TROCA"
               no-lock no-error.
    if avail asstec_aux
    then do:
        if asstec_aux.valor_campo = "30 DIAS"
        then assign
                vi = 1
                vmarca[vi] = "*".
        else if asstec_aux.valor_campo = "REINCIDENCIA"
        THEN assign
                 vi = 2
                 vmarca[vi] = "*".
    end.                
    
    disp     vmarca
         vsel with frame f-sel.
    va = vi.    
   
    if vmarca[va] = ""
    then do:           
    /*repeat:*/
        choose field vsel with frame f-sel.
        vmarca[va] = "". 
        vmarca[frame-index] = "*".
        va = frame-index.    
                        
        disp vmarca
           with frame f-sel.
    /*end.*/
    message vmarca[va]. pause.
    
    if vmarca[va] = "*"
    then do transaction:
        message "11111". pause.
        find first asstec_aux where
               asstec_aux.oscod = wfasstec.oscod and
               asstec_aux.nome_campo = "REGISTRO-TROCA"
               no-error.
        if not avail asstec_aux
        then do:
            create asstec_aux.
            assign
                asstec_aux.oscod = wfasstec.oscod
                asstec_aux.nome_campo = "REGISTRO-TROCA"
                asstec_aux.data_campo = today
                .
        end.        
        if va = 1
        then asstec_aux.valor_campo = "30 DIAS".
        else if va = 2
            then asstec_aux.valor_campo = "REINCIDENCIA".
    end.
    end.
    else pause.
    
end procedure.

procedure inclui-os.
    
    def var vgarbiz as log init yes.
    
    create tt-asstec.    

    tt-asstec.etbcod = setbcod.
                
    do with frame f-inclui:
    update tt-asstec.etbcod colon 11 label "Filial"
                           with frame f-inclui no-validate.
               
    disp tt-asstec.oscod when tt-asstec.oscod > 0
                            colon 40 label "O.S." 
                                    with frame f-inclui.
    do on error undo, retry:
        update tt-asstec.pladat colon 11 label "Data Venda"
           tt-asstec.planum colon 40 label "Numero Venda"
           with frame f-inclui.
        vgarbiz = no.
        if tt-asstec.planum > 0
        then do:
            find first plani where plani.etbcod = tt-asstec.etbcod and
                                   plani.movtdc = 5 and
                                   plani.emite  = tt-asstec.etbcod and
                                   plani.serie = "V" and
                                   plani.numero = tt-asstec.planum and
                                   plani.pladat = tt-asstec.pladat
                                   no-lock no-error.
            if not avail plani
            then do:
                bell.
                message color red/with
                "Venda não encontrada com numero informado."
                 view-as alert-box.
                undo, retry.
            end.
            find clien where clien.clicod = plani.desti no-lock no-error.
            tt-asstec.clicod = clien.clicod.
            disp tt-asstec.clicod with frame f-inclui.
            if tt-asstec.clicod <> 1
            then do:
                display clien.clinom no-label with frame f-inclui.      
                /***
                find first tabaux where tabaux.tabela = "PLANOBIZ" and
                           tabaux.valor_campo = string(plani.pedcod)
                           no-lock no-error.
                if avail tabaux
                then do:
                    vgarbiz = yes.
                    for each titulo where
                             titulo.clifor = clien.clicod and
                             titulo.titsit = "LIB"
                             no-lock:
                        if today - titulo.titdtven > 30
                        then vgarbiz = no.
                        else vgarbiz = yes.
                    end.
                    if vgarbiz and plani.pladat >= 11/01/2011
                    then do:

                        bell.
                        message color red/with
                        " GARANTIA PLANO BI$ "
                        view-as alert-box.
                        
                    end.
                end.              
                ***/
            end.
        end.    
    end.
    if tt-asstec.clicod = 0
    then do:
        update tt-asstec.clicod format ">>>>>>>>>>>9" colon 11 label "Cliente"
                                   with frame f-inclui no-validate.
               
        find first clien where clien.clicod = tt-asstec.clicod 
                                            no-lock no-error.
        if not avail clien
        then undo,retry.
        else display clien.clinom no-label with frame f-inclui.
    end.
     
    update tt-asstec.forcod colon 11 label "Cod.Assis".
    find forne where forne.forcod = tt-asstec.forcod 
                            no-lock no-error.
    if not avail forne
    then do:
         message "Assistencia nao cadastrada".
         pause.
         undo.
    end.
    display forne.fornom no-label  format "x(30)"
                        forne.forfone.
                                    
                
    update tt-asstec.procod colon 11
                 with frame f-inclui no-validate.
               
    find produ where produ.procod = tt-asstec.procod 
                                                    no-lock no-error.
    if not avail produ      
    then undo,retry.
    else display produ.pronom no-label format "x(30)"
                                    with frame f-inclui.
                

    /***/
find first tabaux where tabaux.tabela = "PLANOBIZ" and
                           tabaux.valor_campo = string(plani.pedcod)
                           no-lock no-error.
                if avail tabaux
                then do:
                    vgarbiz = yes.
                    for each titulo where
                             titulo.clifor = clien.clicod and
                             titulo.titsit = "LIB"
                             no-lock:
                        if today - titulo.titdtven > 30
                        then vgarbiz = no.
                        else vgarbiz = yes.
                    end.
                    if vgarbiz and plani.pladat >= 11/01/2011
                       and produ.catcod <> 41
                    then do:

                        bell.
                        message color red/with
                        " GARANTIA PLANO BI$ "
                        view-as alert-box.
                        
                    end.
                end.    
    /***/
    update tt-asstec.apaser format "x(20)" colon 11
                                   with frame f-inclui no-validate.
                
                v-imei-cel-aux = "".
                if can-find(first plaviv where
                                  plaviv.procod = tt-asstec.procod and
                                  plaviv.exportado = yes)
                then do:
                                                  
                  find first tbprice where tbprice.etb_venda  = tt-asstec.etbcod
                                       and tbprice.nota_venda = tt-asstec.planum
                                       and tbprice.data_venda = tt-asstec.pladat
                                                    no-lock no-error.
                   if available tbprice
                   then do:
                   
                       assign v-imei-cel-aux = tbprice.serial.
                                              
                   end.
                   
               bloco_inclui_imei:
               repeat with frame f-inclui:    
                       update v-imei-cel-aux colon 11
                                      label "IMEI Cel." format "x(20)"
                                                    with frame f-inclui.       
                       if v-imei-cel-aux = ""
                       then do:
                                              
               message "O campo IMEI Cel. tem preenchimento obrigatorio".
                           undo,retry.
                           
                       end.
                       else leave bloco_inclui_imei.

                   end.
                                          
                end.
                   
                if (today - 9) <= tt-asstec.pladat
                then update v-cel-doa-aux colon 50
                             label "DOA" format "Sim/Nao"
                                    with frame f-inclui.                      
                else disp v-cel-doa-aux colon 50
                             label "DOA" format "Sim/Nao"
                                    with frame f-inclui.
                    
                                                          
                if keyfunction(lastkey) = "END-ERROR"
                THEN UNDO,retry.
                
                update tt-asstec.proobs colon 11 label "Obs.Prod."
                       tt-asstec.defeito colon 11 
                       tt-asstec.nftnum colon 11 label "NF Transf" 
                       tt-asstec.reincid colon 50 
                       tt-asstec.dtentdep colon 25 label "Dt.Entrada Deposito"
                       tt-asstec.dtenvass colon 60 
                                label "Dt.Envio Assistencia" 
                       tt-asstec.dtretass colon 25 
                                label "Dt.Retirada Assistencia"
                       tt-asstec.dtenvfil colon 60 
                                label "Dt.Envio para Filial" 
                       tt-asstec.osobs colon 11 label "Obs.OS"
                                       with frame f-inclui.
       
                do transaction:

                    create asstec.  
                
                    
                    find last basstec no-lock no-error.
                    if avail basstec 
                    then asstec.oscod = basstec.oscod + 1. 
                    else asstec.oscod = 1. 
   
                    display asstec.oscod @ tt-asstec.oscod
                            colon 40 label "O.S." 
                                    with frame f-inclui.
                    
                    
                    assign asstec.etbcod = tt-asstec.etbcod
                        /* asstec.oscod  = tt-asstec.oscod */
                           asstec.forcod = tt-asstec.forcod
                           asstec.procod = tt-asstec.procod
                           asstec.apaser = tt-asstec.apaser
                           asstec.clicod = tt-asstec.clicod
                           asstec.plaetb = tt-asstec.plaetb
                           asstec.pladat = tt-asstec.pladat
                           asstec.planum = tt-asstec.planum
                           asstec.serie  = tt-asstec.serie
                           asstec.defeito = tt-asstec.defeito
                           asstec.nftnum  = tt-asstec.nftnum
                           asstec.reincid = tt-asstec.reincid
                           asstec.dtentdep = tt-asstec.dtentdep
                           asstec.dtenvass = tt-asstec.dtenvass
                           asstec.dtretass = tt-asstec.dtretass
                           asstec.dtenvfil = tt-asstec.dtenvfil
                           asstec.osobs    = tt-asstec.osobs.
                           
                    if v-imei-cel-aux <> "" then do:
                                               
                        asstec.proobs = tt-asstec.proobs
                                         + "|IMEI=" + v-imei-cel-aux
                                         + "|DOA=" + string(v-cel-doa-aux).
                                         
                    end.
                    else asstec.proobs = tt-asstec.proobs.
                    if vgarbiz = yes
                    then do:
                        find first regtroca where
                                   regtroca.oscod = asstec.oscod and
                                   regtroca.nome_campo = "REGISTRO-TROCA"
                        no-error.
                        if not avail regtroca
                        then do:
                            create regtroca.
                            assign
                                regtroca.oscod = asstec.oscod
                                regtroca.nome_campo = "REGISTRO-TROCA"
                                regtroca.data_campo = today
                                .
                        end.        
                        regtroca.valor_campo = "GARANTIA PLANO BI$".
 
                        find current regtroca no-lock.
 
                    end.       
                end.
                create wfasstec.
                buffer-copy asstec to wfasstec. 
    end.
end procedure.
