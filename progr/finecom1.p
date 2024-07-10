/*
*
*    MANUTENCAO EM financiamentos                  finan.p    02/05/95
*
*/

{admcab.i} 
def var i as int.
def var vfuncod like func.funcod.
def var vsenha like func.senha.

def var vmarca          as char format "x"         no-undo.
def var vmarca2         as char    no-undo.

def temp-table wfin
    field wrec as recid.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(16)" extent 4
            initial ["Marca E-Commerce","","",""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bfinan           for finan.
def buffer bfinecom         for finecom.
def var vfincod             like finan.fincod.
def var varquivo            as char.
def var vint-cod-plan-igual as integer no-undo.
def var vlog-resp           as logical no-undo.  

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
    for each wfin:
        delete wfin.
    end.
    for each cpag no-lock:
        find finan where finan.fincod = cpag.cpagcod no-lock no-error.
        if avail finan
        then do:
            create wfin.
            assign wfin.wrec = recid(finan).
        end.
    end.
    /*
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
    if func.funfunc <> "D.COMPRAS"
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
    */
 


bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then
        find first finan where finan.fincod < 100 no-error.
    else
        find finan where recid(finan) = recatu1.
        vinicio = no.
    if not available finan
    then do:
        form finan
            with frame f-altera
            overlay row 6 1 column centered color white/cyan.
        message "Cadastro de financiamento Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-altera:
                create finan.
                update finan.
                finan.finnom = caps(finan.finnom).
                vinicio = yes.
        end.
    end.
    clear frame frame-a all no-pause.
    find first wfin    where wfin.wrec      = recid(finan) no-error.
    find first finecom where finecom.fincod = finan.fincod no-lock no-error.
    display if avail wfin then "*" else "" @ vmarca no-label
            finan.fincod
            finan.finnom
            finan.finent   
            finan.finnpc
            finan.finfat
            if avail finecom and finecom.exporta-ecom then " * Sim *"
                                                      else "   Nao"
            @ vmarca2 label "E-Commerce" 
            with frame frame-a 14 down centered color white/red.

    recatu1 = recid(finan).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next finan where
                finan.fincod < 100.
        if not available finan
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio = no
        then
        down
            with frame frame-a.
        find first wfin    where wfin.wrec      = recid(finan) no-error.
        find first finecom where finecom.fincod = finan.fincod no-lock no-error.
        display if avail wfin then "*" else "" @ vmarca no-label
            finan.fincod
            finan.finnom
            finan.finent     
            finan.finnpc
            finan.finfat
            if avail finecom and finecom.exporta-ecom then " * Sim *"
                                                      else "   Nao"
            @ vmarca2
            with frame frame-a 14 down centered color white/red.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find finan where recid(finan) = recatu1.

        choose field finan.fincod
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
                esqpos2 = if esqpos2 = 5
                          then 5
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
                find next finan where
                    finan.fincod < 100 no-error.
                if not avail finan
                then leave.
                recatu2 = recid(finan).
            end.
            if reccont = frame-down(frame-a)
            then recatu1 = recatu2.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev finan where
                    finan.fincod < 100 no-error.
                if not avail finan
                then leave.
                recatu1 = recid(finan).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next finan where
                finan.fincod < 100 no-error.
            if not avail finan
            then next.
            color display white/red
                finan.fincod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev finan where
                finan.fincod < 100 no-error.
            if not avail finan
            then next.
            color display white/red
                finan.fincod.
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
            then do with frame f-altera.
                create finan.
                UPDATE FINAN.fincod
                       FINAN.finnom
                       FINAN.finent
                       FINAN.finnpc
                       FINAN.finfat
                       FINAN.datexp FORMAT "99/99/9999".
                finan.finnom = caps(finan.finnom).
                recatu1 = recid(finan).
                leave.
            end.
            if esqcom1[esqpos1] = "Consulta"  or
               esqcom1[esqpos1] = "Exclusao"  or
               esqcom1[esqpos1] = "Alteracao" or
               esqcom1[esqpos1] = "Listagem"
            then do with frame f-altera:
                disp finan.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera:
                UPDATE FINAN.fincod
                       FINAN.finnom
                       FINAN.finent
                       FINAN.finnpc
                       FINAN.finfat
                       FINAN.datexp FORMAT "99/99/9999".

                finan.finnom = caps(finan.finnom).
            end.
            /*
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-altera:
                message "Confirma Exclusao de" finan.finnom update sresp.
                if not sresp
                then leave.
                find next finan where finan.fincod < 100 no-error.
                if not available finan
                then do:
                    find finan where recid(finan) = recatu1.
                    find prev finan where finan.fincod < 100 no-error.
                end.
                recatu2 = if available finan
                          then recid(finan)
                          else ?.
                find finan where recid(finan) = recatu1.
                delete finan.
                recatu1 = recatu2.
                leave.
            end.
            */
            
            if esqcom1[esqpos1] = "Marca E-Commerce"
            then do:
                find first finecom where finecom.fincod = finan.fincod                                         no-lock no-error.
                if not avail finecom
                then do:

                    assign vint-cod-plan-igual = 0.
                    
                    bloco_parcela_igual:
                    for each bfinan where bfinan.finent = finan.finent
                                      and bfinan.finnpc = finan.finnpc no-lock,
                                       
                        first finecom where finecom.fincod = bfinan.fincod
                                        and finecom.exporta-ecom = yes no-lock:
                                            
                        assign vint-cod-plan-igual = finecom.fincod.
                        
                        leave bloco_parcela_igual.

                    end.
                    
                    if vint-cod-plan-igual > 0
                    then do:
                    
                            run mensagem.p
                             (input-output vlog-resp,
                              input " Já existe o plano " +                                    string(vint-cod-plan-igual) +
                                    " selecionado para " +                                                           "  o E-Commerce com a mesma quantidade" +                                       "     de  parcelas.                    "   +
                                    "                                     " +
                                    "       " +
                                    "    Para incluir o plano " +
                                    string(finan.fincod) +                                                          " você    " +                                                                  "         precisará desmarcar o " +
                                    string(vint-cod-plan-igual) + "."
                                       ,
                                 input "",
                                 input " Ok ",
                                 input " Ok ").
                        leave.
                                                    
                    end.

                    create bfinecom.
                    assign bfinecom.fincod       = finan.fincod
                           bfinecom.exporta-ecom = yes.
                    
                    release bfinecom.

                    display "Sim" @ vmarca2
                           with frame frame-a.
                end.
                else do:
                    if finecom.exporta-ecom then do:
                        
                        find first bfinecom where bfinecom.fincod = finan.fincod
                                               exclusive-lock no-error.  
                                               
                        assign bfinecom.exporta-ecom = no.

                        release bfinecom.

                        display "Nao" @ vmarca2
                               with frame frame-a.
                               
                    end.
                    else do:

                        assign vint-cod-plan-igual = 0.
                        
                        bloco_parcela_igual:
                        for each bfinan where bfinan.finent = finan.finent
                                          and bfinan.finnpc = finan.finnpc no-lock,

                            first finecom where finecom.fincod = bfinan.fincod
                                            and finecom.exporta-ecom = yes no-lock:

                            assign vint-cod-plan-igual = finecom.fincod.

                            leave bloco_parcela_igual.

                        end.

                        if vint-cod-plan-igual > 0
                        then do:

                            run mensagem.p
                             (input-output vlog-resp,
                              input " Já existe o plano " +                                     string(vint-cod-plan-igual) +
                                    " selecionado para " +                                                           "  o E-Commerce com a mesma quantidade" +                                       "     de  parcelas.                    "   +
                                    "                                     " +
                                    "       " +
                                    "    Para incluir o plano " +
                                    string(finan.fincod) +                                                          " você    " +                                                                   "         precisará desmarcar o " +
                                    string(vint-cod-plan-igual) + "."
                                       ,
                                 input "",
                                 input " Ok ",
                                 input " Ok ").

                        leave.

                    end.

                        find first bfinecom where bfinecom.fincod = finan.fincod
                                               exclusive-lock no-error.

                        assign bfinecom.exporta-ecom = yes.
                        
                        release bfinecom.
                        
                        display "Sim" @ vmarca2
                               with frame frame-a.
                    
                    end.
                end.
            end.
            
            if esqcom1[esqpos1] = "Marca"
            then do:
                find FIRST wfin where wfin.wrec = recid(finan) no-error.
                if not avail wfin
                then do:
                    create wfin.
                    create cpag.
                    assign wfin.wrec = recid(finan)
                           cpag.cpagcod = finan.fincod.
                    display "*" @ vmarca
                            with frame frame-a.
                end.
                else do:
                    delete wfin.
                    find cpag where cpag.cpagcod = finan.fincod.
                    delete cpag.
                    display "" @ vmarca
                            with frame frame-a.
                end.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do:
                message "Confirma Impressao do finanelecimento" update sresp.
                if not sresp
                then LEAVE.
                recatu2 = recatu1.
                output to printer.  
                    
   /* Inicia o gerˆnciador de ImpressÆo */
     
    varquivo = "..\relat\ra" + string(time).

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "135"
        &Page-Line = "66"
        &Nom-Rel   = ""finan.p""
        &Nom-Sis   = """SISTEMA GERENCIAL"""
        &Tit-Rel   = """CADASTRO DE FINANCIAMENTOS"""
       &Width     = "135"
       &Form      = "frame f-cabcab"}
 

                
                for each finan where finan.fincod < 100 no-lock:
                    display finan.fincod
                            finan.finnom
                            finan.finent
                            finan.finnpc
                            finan.finfat
                            finan.datexp format "99/99/9999".  
                end.
    
     {mrod.i}  
    /* output close. */
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
        find first wfin    where wfin.wrec      = recid(finan) no-error.
        find first finecom where finecom.fincod = finan.fincod no-lock no-error.             display if avail wfin then "*" else "" @ vmarca no-label
            finan.fincod
            finan.finnom 
            finan.finent 
            finan.finnpc
            finan.finfat
            if avail finecom and finecom.exporta-ecom then " * Sim *"
                                                      else "   Nao"
            @ vmarca2  label "E-Commerce"  
                        with frame frame-a 14 down centered color white/red.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(finan).
   end.
end.
