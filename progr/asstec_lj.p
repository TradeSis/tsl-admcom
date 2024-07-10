/*                                                  
*
*    Esqueletao de Programacao
*
*/

{admcab.i}

def buffer regtroca for asstec_aux.

def var vetopecod like asstec.etopecod.
def var vconfinado as log format "Sim/Nao".
def var vfornom like forne.fornom.
def var vfone   like forne.forfone.
def var varquivo as char.
def temp-table tt-asstec like asstec.
def temp-table wfasstec  like asstec
    index ind-1 oscod desc.
def var vserie  like asstec.apaser.    
def var vclicod as int format ">>>>>>>>>9".
def var vfabcod like fabri.fabcod.
def var vforcod like forne.forcod.
def var v-escolha as int.
def var vpend as char format "x(11)" extent 3
        initial ["TODAS","PENDENTES ","   FECHADOS"].
def var v-totalizador as int.
def var vopcao  as char format "x(15)" 
    extent 3 initial["cliente","Ord.Servico","Serie"]. 
def var vpronom like produ.pronom.
def var vclinom like clien.clinom.
def var reccont         as int.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
   initial ["Inclusao","","Consulta","Impressao","Procura"].

def buffer basstec       for asstec.
def var vetbcod         like asstec.etbcod.
def var voscod          like asstec.oscod.
def var v-imei-cel-aux  as character no-undo.
def var v-cel-doa-aux   as logical format "Sim/Nao" no-undo.
def var v-conta-asstec  as integer.
def var v-proobs-aux    like asstec.proobs no-undo.

    form
        esqcom1
            with frame f-com1 row 3 no-box no-labels side-labels column 1.
    esqpos1  = 1.
    recatu1 = ?.
    vetbcod = setbcod.
    find estab where estab.etbcod = vetbcod no-lock no-error.
         
    vfabcod = 0.
    vforcod = 0.
    
    display vpend no-label 
        with frame f-sit no-box row 5 centered.
   
    choose field vpend with frame f-sit.
    v-escolha = frame-index.
    
    for each wfasstec:
        delete wfasstec.
    end.

    v-totalizador = 0.
        for each asstec where asstec.etbcod = vetbcod no-lock.
        
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
            then
                if asstec.forcod = vforcod
                then.
                else next.

            if v-escolha = 2
            then
                if asstec.dtretass = ?
                then.
                else next.

            if v-escolha = 3
            then
                if asstec.dtretass <> ?
                then.
                else next.
 
            create wfasstec.
            buffer-copy asstec to wfasstec.
        
            v-totalizador = v-totalizador + 1.
        end.    

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then find first wfasstec where true no-error.
    else find first wfasstec where recid(wfasstec) = recatu1 no-lock.
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
        run selope (output vetopecod).
        if vetopecod = ?
        then leave.
        run not_incos_lj.p (vetopecod, output recatu2).

        if recatu2 <> ?
        then recatu1 = recatu2.
        next.
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
        wfasstec.oscod format ">>>>>>9"
        wfasstec.datexp column-label "Data!Inclusao"
        wfasstec.procod
        vpronom format "x(19)"
        wfasstec.clicod  format ">>>>>>>>>9"
        vclinom format "x(15)"
            with frame frame-a 11 down centered
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
        down with frame frame-a.

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
                  PF4 F4 ESC return).
        if keyfunction(lastkey) = "cursor-right"
        then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
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
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
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

            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 width 80 side-labels.
                for each tt-asstec:
                    delete tt-asstec.
                end.
                run selope (output vetopecod).
                if vetopecod = ?
                then leave.
                run not_incos_lj.p (vetopecod, output recatu2).
                if recatu2 <> ?
                then recatu1 = recatu2.
                leave.
            end.

            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 width 80 side-labels.
            
                find asstec 
                    where asstec.oscod = wfasstec.oscod no-lock no-error.
                if not avail asstec then leave.
                
                disp asstec.etbcod colon 11 label "Filial"
                     asstec.oscod colon 40 label "O.S." 
                     asstec.datexp colon 65 label "Data Inclusao"
                     asstec.pladat colon 11 label "Data Venda"
                     asstec.planum colon 40 label "Numero Venda"
                     asstec.clicod colon 11 label "Cliente" format ">>>>>>>>>9"
                       with frame f-consulta no-validate.
               
                find first clien where clien.clicod = asstec.clicod 
                                    no-lock no-error.
                if not avail clien
                then .
                else display clien.clinom no-label format "x(34)"
                    with frame f-consulta.
 
                find first regtroca where
                                   regtroca.oscod = asstec.oscod and
                                   regtroca.nome_campo = "REGISTRO-TROCA"
                       no-lock no-error.
                if avail regtroca
                then disp regtroca.valor_campo no-label format "x(20)".
                disp  asstec.procod colon 11
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
                             
                
                vfornom = "". 
                vfone   = "".
               
                /*Gerson*/
                if connected ("germatriz") 
                then disconnect germatriz.
/*

                connect ger -H erp.lebes.com.br -S sdrebger -N tcp -ld germatriz 
                            no-error. 
    
                run busca_fone.p (input  asstec.forcod,
                                  output vfornom,
                                  output vfone).
                                  
                
                disconnect germatriz. 
  */              

                display asstec.forcod colon 11 label "Cod.Ass."
                        vfornom no-label 
                        vfone.                
                
                disp asstec.apaser format "x(15)" colon 10
                       with frame f-consulta no-validate.
                
                if acha("IMEI",asstec.proobs) <> ""
                then do:
                    assign  v-cel-doa-aux = (acha("DOA",asstec.proobs) = "yes").
                    assign v-proobs-aux = replace(asstec.proobs,"|DOA=" + 
                              trim(string(v-cel-doa-aux,"yes/no")),"").

                    assign
                      v-imei-cel-aux = acha("IMEI",asstec.proobs)
                      v-proobs-aux =
                          replace(v-proobs-aux,"|IMEI=" + v-imei-cel-aux,"").
                    
                      disp v-imei-cel-aux colon 11 label "IMEI Cel."
                                            format "x(20)"
                           v-cel-doa-aux  colon 50 label "DOA"
                                    format "Sim/Nao" with frame f-consulta.


                end.
                else v-proobs-aux = asstec.proobs.
                
                disp v-proobs-aux colon 11 label "Obs.Prod."
                     asstec.defeito colon 11 
                     asstec.nftnum colon 11 label "NF Transf" 
                     asstec.reincid colon 50 
                     asstec.dtentdep colon 25 label "Dt.Entrada Deposito"
                     asstec.dtenvass colon 60 label "Dt.Envio Assistencia"
                     asstec.dtretass colon 25 label "Dt.Retirada Assistencia"
                     asstec.dtenvfil colon 60 label "Dt.Envio para Filial" 
                     asstec.osobs colon 11 label "Obs.OS"
                       with frame f-consulta.

                next bl-princ.
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
                    update vclicod format ">>>>>>>>>9" label "cliente" with frame f-cli
                                side-label width 80.
                    find clien where clien.clicod = vclicod 
                                    no-lock no-error.
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
                recatu1 = recid(wfasstec).
                leave.
            end.

            if esqcom1[esqpos1] = "Impressao"
            then do with frame f-Lista  width 80 side-labels.
                /*message "Confirma Impressao da O.S : " wfasstec.oscod
                        update sresp.
                if not sresp
                then leave.  */
                recatu2 = recatu1.
                find estab where estab.etbcod = setbcod no-lock no-error.
                
                varquivo = "/admcom/relat/os" + 
                            string(wfasstec.oscod,"999999") +
                            "." + string(time).

                {mdadmcab.i 
                    &Saida     = "value(varquivo)"
                    &Page-Size = "64"
                    &Cond-Var  = "160"
                    &Page-Line = "66"
                    &Nom-Rel   = ""asstec""
                    &Nom-Sis   = """ASSISTENCIA TECNICA"""
                    &Tit-Rel   = """O.S :  "" + 
                                 string(wfasstec.oscod,""999999"") +
                                 "" Filial "" + string(estab.etbcod) + "" - "" +
                                               estab.etbnom"
                    &Width     = "160"
                    &Form      = "frame f-cabcab2"}

                find asstec where asstec.oscod = wfasstec.oscod no-lock.
    
                disp asstec.etbcod colon 10 label "Filial"
                     asstec.oscod colon 40 label "O.S." 
                     asstec.procod colon 10
                        with frame f-lista.
               
                find first produ where produ.procod = asstec.procod 
                            no-lock no-error.
                if not avail produ
                then undo,retry.
                else display produ.pronom no-label format "x(30)"
                                with frame f-lista.
                
                find forne where forne.forcod = asstec.forcod  
                                no-lock no-error.

                display asstec.forcod colon 10 label "Cod.Ass."
                        forne.fornom no-label 
                                  when avail forne
                        forne.forfone when avail forne.
                
                disp asstec.apaser format "x(15)" colon 10
                       with frame f-lista.
                
                disp asstec.clicod colon 10 label "cliente"
                       with frame f-lista.
               
                find first clien where clien.clicod = asstec.clicod 
                                    no-lock no-error.

                if not avail clien
                then undo,retry.
                else do:
                     if asstec.clicod <> 0
                     then 
                     display clien.clinom no-label 
                             clien.ciinsc colon 10 label "RG" 
                             clien.ciccgc colon 50 label "CPF"
                             clien.endereco[1] colon 10 label "Endereco"
                             clien.numero[1]   colon 60 label "Numero"
                             clien.bairro[1]   colon 10 label "Bairro"
                             clien.cidade[1]   colon 50 label "Cidade"
                             clien.cep[1]      colon 10 label "Cep"
                             " "               colon 10
                                 with frame f-lista.
                end. 
                disp asstec.pladat colon 10 label "Data NF"
                     asstec.planum colon 50
                        with frame f-lista.
                        
                if acha("IMEI",asstec.proobs) <> ""
                then do:
                                                    
                    assign  v-cel-doa-aux = (acha("DOA",asstec.proobs) = "yes").
                    assign v-proobs-aux =                                                                replace(asstec.proobs,"|DOA=" + trim(string(v-cel-doa-aux,"yes/no")),"").
                    assign
                      v-imei-cel-aux = acha("IMEI",asstec.proobs)
                      v-proobs-aux =
                          replace(v-proobs-aux,"|IMEI=" + v-imei-cel-aux,"").

                      disp v-imei-cel-aux colon 10 label "IMEI Cel."
                                      format "x(20)"
                           v-cel-doa-aux  colon 50 label "DOA"
                                      format "Sim/Nao" with frame f-lista.

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
                       with frame f-lista.
                
                output close.
                
                {porta-relatorio.i}

                recatu1 = recid(wfasstec).
                leave.
            end.
          view frame frame-a .
        end.

        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        
        find first produ where produ.procod = wfasstec.procod no-lock no-error.
        if avail produ
        then vpronom = produ.pronom.
        else vpronom = "".
        find clien where clien.clicod = wfasstec.clicod 
                                no-lock no-error.
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

        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(wfasstec).
   end.
end.

procedure selope.
    {setbrw.i}

    def output parameter par-etiqope like etiqope.etopecod.

    par-etiqope = ?.
    form with frame f-linha overlay.

    clear frame f-linha all.
    assign a-seerec = ?.
    assign a-seeid  = -1  
           a-recid  = -1.

    {sklcls.i
        &color  = withe
        &color1 = brown
        &file   = etiqope 
        &noncharacter = /* 
        &ofield = etiqope.etopenom
        &cfield = etiqope.etopecod
        &where  = "etiqope.etopecod < 100"
        &LockType = "no-lock"
        &form   = "frame f-linha 10 down row 5 no-label 
                     title "" TIPOS DE OPERACAO """}. 
    if keyfunction(lastkey) = "end-error"
    then do.
        hide frame f-linha no-pause.
        leave.
    end.    
    find etiqope where recid(etiqope) = a-seerec[frame-line(f-linha)] 
                 no-lock no-error.
    
    par-etiqope = if avail etiqope
                 then etiqope.etopecod
                 else ?.
    hide frame f-linha no-pause.
end procedure.


