/*
*
*    asstec_e.p    -    Esqueleto de Programacao    com esqvazio
*
*/

{admcab.i}
def var xx as int.
def var varquivo as char.
def var fila as char.
def var recimp as reci.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Alteracao "," Consulta "," Listagem "," Envia Posto ",""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Alteracao da asstec ",
             " Consulta  da asstec ",
             " Listagem  de asstec ",
             " Envia para Posto    ",
             "                     "]   .
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def buffer basstec       for asstec.
def var vasstec         like asstec.oscod.


form
    esqcom1
    with frame f-com1
                 row 6 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var vdti as date.
def var vetbcod like estab.etbcod.    
def var vfabcod like fabri.fabcod.
def var vforcod like forne.forcod.
def var v-totalizador as dec.
def var vpronom like produ.pronom.
def var vclinom like clien.clinom.
def new shared temp-table wfasstec  like asstec.
def var vcontinua as log.

repeat:
    recatu1 = ?.

    vetbcod = 0.
    update vetbcod label "Fil"
        with frame fest color message
            side-labels no-box row 4 centered.

    vfabcod = 0.
    update vfabcod label "Fabricante" 
        with frame fest 
            side-labels no-box row 4 centered width 80.
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
    
    update vdti label "Data envio posto" format "99/99/9999"
        with frame fest.
    
    v-totalizador = 0.
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock.
        for each asstec where asstec.etbcod = estab.etbcod and
                              asstec.dtenvass = vdti no-lock.
            if asstec.dtretass <> ? or
               asstec.dtenvfil <> ? 
            then next.              
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
            vcontinua = yes.
            for each osxnf where 
                     osxnf.oscod = asstec.oscod no-lock:
               find plani where plani.movtdc = osxnf.movtdc and
                                plani.etbcod = osxnf.etbcod and
                                plani.emite  = osxnf.emite  and
                                plani.serie  = osxnf.serie  and
                                plani.numero = osxnf.numero
                                no-lock no-error.
               if avail plani and 
                  plani.desti = asstec.forcod
               then do:
                    vcontinua = no.
                    leave.
               end. 
            end.          
            if vcontinua = no then next.
                       
            create wfasstec.
            buffer-copy asstec to wfasstec.
        
            v-totalizador = v-totalizador + 1.
        
        end.    
    end. 
    /*
    display v-totalizador label "Totalizador" format ">>>>9"
            "O.S" with frame fest.
    */
    
def var vinicio as log init no.
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    
    if recatu1 = ?
    then find first wfasstec where true no-error.
    else find first wfasstec where recid(wfasstec) = recatu1 no-lock.
    
    vinicio = yes.
    if not available wfasstec
    then do:
        bell.
        message color red/with
            "Nenhum registro encontrado."
            view-as alert-box.
        leave bl-princ.    
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
        wfasstec.datexp column-label "Inclusao"
        wfasstec.procod
        vpronom format "x(20)"
        wfasstec.clicod 
        vclinom format "x(14)"  /*25*/
            with frame frame-a 9 down centered
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
                      page-down   page-up
                      tab PF4 F4 ESC return).

        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                color display message esqcom2[esqpos2] with frame f-com2.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                color display message esqcom1[esqpos1] with frame f-com1.
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

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form asstec
                 with frame f-asstec color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-asstec on error undo.
                    /*recatu1 = recid(asstec).
                    */
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-consulta side-label.
                    find asstec where asstec.oscod = wfasstec.oscod no-lock.
    
                    disp asstec.etbcod colon 10 label "Filial"
                     asstec.oscod  colon 40 label "O.S." 
                     asstec.procod colon 10
                        with frame f-consulta no-validate.
               
                    find first produ where produ.procod = asstec.procod 
                            no-lock no-error.
                    if not avail produ
                    then undo,retry.
                    else display produ.pronom no-label format "x(30)"
                                with frame f-consulta.
                    find forne where forne.forcod = asstec.forcod 
                            no-lock no-error.

                    display asstec.forcod colon 10 label "Cod.Ass."
                        forne.fornom no-label when avail forne
                        forne.forfone when avail forne.
                 
                
                
                    disp asstec.apaser format "x(20)" colon 10
                       with frame f-consulta no-validate.
                
                    disp asstec.clicod colon 10 label "Cliente"
                       with frame f-consulta no-validate.
               
                    find first clien where clien.clicod = asstec.clicod 
                                    no-lock no-error.
                    if not avail clien
                    then undo,retry.
                    else display clien.clinom no-label with frame f-consulta.
                 
                    disp asstec.pladat colon 10 label "Data NF"
                     asstec.planum colon 50 
                     asstec.proobs colon 10 label "Obs.Prod."
                     asstec.defeito colon 10 
                     asstec.nftnum colon 10 label "NF Transf" 
                     asstec.reincid colon 50 
                     asstec.dtentdep colon 25 label "Dt.Entrada Deposito"
                     asstec.dtenvass colon 25 label "Dt.Envio Assistencia"
                   /*asstec.dtretass colon 25 label "Dt.Retirada Assistencia"
                     asstec.dtenvfil colon 60 label "Dt.Envio para Filial" 
                    */
                     asstec.osobs colon 10 label "Obs.OS"
                       with frame f-consulta.
                    if esqcom1[esqpos1] = " Alteracao "
                    then do transaction:
                        find wfasstec where 
                                recid(wfasstec) = recatu1.
                        find asstec where asstec.oscod = wfasstec.oscod.
                        update asstec.dtenvass with frame f-consulta.
                        if wfasstec.dtenvass <> asstec.dtenvass
                        then delete wfasstec.
                    end.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    message "Confirma Impressao das O.S" update sresp.
                    if not sresp
                    then leave.

                    if opsys = "unix" 
                    then do:
                    
                        find first impress where impress.codimp = setbcod 
                            no-lock no-error.
                        if avail impress 
                        then do:
                            run acha_imp.p (input recid(impress),
                                        output recimp). 
                            find impress where recid(impress) = recimp
                            no-lock no-error.
                                        
                            assign fila = string(impress.dfimp). 
                        end.    
                        varquivo = "/admcom/relat/asstec." + string(time).
 
                    end.    
                    else varquivo = "/admcom/relat/asstec." + string(time).
                
                    {mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "0" 
                        &Cond-Var  = "120" 
                        &Page-Line = "66"
                        &Nom-Rel   = ""asstec_e""
                        &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
                        &Tit-Rel   = """LISTAGEM DE OS """
                        &Width     = "150"
                        &Form      = "frame f-cabcab"}
    
                    disp with frame fest.
                    xx = 0.
                    for each wfasstec break by wfasstec.etbcod
                                        by wfasstec.oscod:
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
                        display xx column-label "Qtd" format ">>>>9"
                                wfasstec.etbcod column-label "Filial"
                                wfasstec.oscod  column-label "OS"
                                wfasstec.procod column-label "Codigo"
                                produ.pronom when avail produ 
                                            column-label "Produto"
                                wfasstec.clicod column-label "Cliente"
                                vclinom         column-label "Nome"
                                    with frame f-lista width 140 down.
                        down with frame f-lista.        
                        if last-of(wfasstec.etbcod)
                        then xx = 0.
                    end.
                    output close.
                    if opsys = "unix"
                    then do:
                        run visurel.p(varquivo,"").
                        sresp = no.
                        message "Confirma Impressao ?" update sresp.
                        if sresp
                        then 
                        os-command silent lpr value(fila + " " + varquivo).
                    end.
                    else do:
                        {mrod.i}.
                    end.    
                    leave.
                end.
                if esqcom1[esqpos1] = " Envia Posto "
                then do:
                    message color with/red
                    "Esta operaracao gera uma Nota Fisacal de" skip
                    " Remessa para Conserto "
                    view-as alert-box.
                    pause 0.
                    message "Confirma operacao " esqcom1[esqpos1]
                            update sresp.
                    if sresp
                    then do:
                        run os_posto.p .
                    end.
                    leave bl-princ.
                end. 
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        /*
        else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
        end.
        view frame frame-a .
        */
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
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.
end.
/**
procedure frame-a.
display asstec 
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        asstec.oscod
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        asstec.oscod
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first asstec where true
                                                no-lock no-error.
    else  
        find last asstec  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next asstec  where true
                                                no-lock no-error.
    else  
        find prev asstec   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev asstec where true  
                                        no-lock no-error.
    else   
        find next asstec where true 
                                        no-lock no-error.
        
end procedure.
***/         
