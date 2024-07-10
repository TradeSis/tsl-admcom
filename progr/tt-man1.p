/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def var vok as log.
def var vtexto as char.
def var v-dig as int.
def var v-banco   like chq.banco. 
def var v-agencia like chq.agencia.  
def var v-conta   like chq.conta.  
def var v-numero  like chq.numero.

def var i as int.
def buffer bchqtit for chqtit.
def var vfuncod like func.funcod.

def var vsenha like func.senha.

def input parameter totchq like chq.valor.
def shared temp-table tt-man
    field marca as char format "x"
    field rec as recid
    field banco like chq.banco
    field agencia like chq.agencia
             index ind-1 banco
                    agencia.
 
def new shared temp-table tt-che
    field rec  as recid
    index rec is primary unique rec asc.

def temp-table tt-chq
    field marca  as char format "x(01)"
    field etbcod like estab.etbcod
    field chqpre like plani.platot
    field chqdia like plani.platot
    field depdia like plani.platot
    field deppre like plani.platot
    field difpre like plani.platot format "->,>>9.99"
    field difdia like plani.platot format "->,>>9.99"
        index ind-1 etbcod
        index ind-2 marca.
 
def var vetbcod  like chqtit.etbcod.
def var vcomp    like chq.comp.
def var vbanco   like chq.banco.
def var vagencia like chq.agencia.
def var vcontrole1 like chq.controle1.
def var vconta     like chq.conta.
def var vcontrole2 like chq.controle2.
def var vnumero    like chq.numero. 
def var vcontrole3 like chq.controle3.
def var vdatemi    like chq.datemi.
def var vdata      like chq.data.
def var vvalor     like chq.valor.
                      
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Marca","Inclusao","Alteracao","Exclusao","Consulta"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Gera Arquivo","   Listagem ","","",""].


def buffer btt-man       for tt-man.


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
    
    display "Total............." 
            totchq to 74 
             with frame f-tot width 74
                no-label no-box color message row 21. 

     
form with frame f-inclui.

bl-princ:
repeat:

    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first tt-man where
            true no-error.
    else
        find tt-man where recid(tt-man) = recatu1.
    vinicio = yes.
    if not available tt-man
    then do:
        message "nao existe cheque para esta loja neste periodo".
        pause.
        sresp = no.
        message "Incluir cheque?" update sresp.
        if not sresp
        then return.
        else do with frame f-inclui overlay row 6 1 column centered.
                
                
                vcomp   = 010.
                vetbcod = 0.
                
                update vetbcod label "Filial"
                       vcomp  
                       vbanco
                       vagencia
                       vcontrole1
                       vconta format "x(10)"
                       vcontrole2
                       vnumero
                       vcontrole3
                       vdatemi label "Emissao"
                       vdata   label "Vencimento"
                       vvalor  label "Valor".
                       
                for each chqtit where chqtit.banco   = vbanco   and
                                      chqtit.agencia = vagencia and
                                      chqtit.conta   = vconta   and
                                      chqtit.numero  = vnumero:

                    delete chqtit.
                                      
                end.                
                
                       
                for each chq where chq.banco   = vbanco   and
                                   chq.agencia = vagencia and
                                   chq.conta   = vconta   and
                                   chq.numero  = vnumero:

                    delete chq.
                                      
                end.          
                
                
                create chq.       
                assign chq.comp      = vcomp
                       chq.banco     = vbanco
                       chq.agencia   = vagencia
                       chq.controle1 = vcontrole1
                       chq.conta     = vconta
                       chq.controle2 = vcontrole2
                       chq.numero    = vnumero
                       chq.controle3 = vcontrole3
                       chq.datemi    = vdatemi
                       chq.data      = vdata
                       chq.valor     = vvalor.
                       

       

                create chqtit.
                assign chqtit.etbcod  = vetbcod
                       chqtit.banco   = vbanco
                       chqtit.agencia = vagencia
                       chqtit.conta   = vconta
                       chqtit.numero  = vnumero
                       chqtit.clifor  = 1
                       chqtit.titnat  = no 
                       chqtit.modcod  = "cre".
                
                
                recatu1 = recid(tt-man).
                leave.

            end.
            next.

    end.
    clear frame frame-a all no-pause.
    find chq where recid(chq) = tt-man.rec no-error.
    pause 0.
    display tt-man.marca
            tt-man.banco 
            tt-man.agencia  
            chq.conta format "x(12)"  
            chq.numero  
            chq.datemi  
            chq.data 
            chq.valor with frame frame-a 13 down centered.



    recatu1 = recid(tt-man).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-man where
                true.
        if not available tt-man
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.

        find chq where recid(chq) = tt-man.rec no-error.
        display tt-man.marca
                tt-man.banco 
                tt-man.agencia 
                chq.conta format "x(12)" 
                chq.numero 
                chq.datemi 
                chq.data 
                chq.valor with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-man where recid(tt-man) = recatu1.

        choose field tt-man.banco
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
                esqpos1 = if esqpos1 = 5
                          then 5
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

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-man where true no-error.
                if not avail tt-man
                then leave.
                recatu1 = recid(tt-man).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-man where true no-error.
                if not avail tt-man
                then leave.
                recatu1 = recid(tt-man).
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
            find next tt-man where
                true no-error.
            if not avail tt-man
            then next.
            color display normal
                tt-man.banco.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-man where
                true no-error.
            if not avail tt-man
            then next.
            color display normal
                tt-man.banco.
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
            if esqcom1[esqpos1] = "Marca"
            then do:
                if tt-man.marca = ""
                then tt-man.marca = "*".
                else tt-man.marca = "".
                disp tt-man.marca with frame frame-a.
            end.
            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
                
                
                vcomp   = 010.
                vetbcod = 0.
                
                update vetbcod label "Filial"
                       vcomp  
                       vbanco
                       vagencia
                       vcontrole1
                       vconta format "x(10)"
                       vcontrole2
                       vnumero
                       vcontrole3
                       vdatemi label "Emissao"
                       vdata   label "Vencimento"
                       vvalor  label "Valor".
                       
                for each chqtit where chqtit.banco   = vbanco   and
                                      chqtit.agencia = vagencia and
                                      chqtit.conta   = vconta   and
                                      chqtit.numero  = vnumero:

                    delete chqtit.
                                      
                end.                
                
                       
                for each chq where chq.banco   = vbanco   and
                                   chq.agencia = vagencia and
                                   chq.conta   = vconta   and
                                   chq.numero  = vnumero:

                    delete chq.
                                      
                end.          
                
                
                create chq.       
                assign chq.comp      = vcomp
                       chq.banco     = vbanco
                       chq.agencia   = vagencia
                       chq.controle1 = vcontrole1
                       chq.conta     = vconta
                       chq.controle2 = vcontrole2
                       chq.numero    = vnumero
                       chq.controle3 = vcontrole3
                       chq.datemi    = vdatemi
                       chq.data      = vdata
                       chq.valor     = vvalor.
                       

       

                create chqtit.
                assign chqtit.etbcod  = vetbcod
                       chqtit.banco   = vbanco
                       chqtit.agencia = vagencia
                       chqtit.conta   = vconta
                       chqtit.numero  = vnumero
                       chqtit.clifor  = 1
                       chqtit.titnat  = no 
                       chqtit.modcod  = "cre".
                
                
                recatu1 = recid(tt-man).
                leave.

            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
               
                
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
                if func.funcod <> 30 and
                   func.funcod <> 29 and
                   func.funcod <> 404
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
                
                find chq where recid(chq) = tt-man.rec.
                
                find first bchqtit of chq no-lock.
                /*
                assign v-banco   = chq.banco
                       v-agencia = chq.agencia
                       v-conta   = chq.conta 
                       v-numero  = chq.numero.
                */

                update chq.banco
                       chq.agencia
                       chq.conta  format "x(18)"
                       chq.numero
                       chq.data
                       chq.datemi
                       chq.controle1
                       chq.controle2
                       chq.controle3
                       chq.comp
                       chq.exportado
                       chq.valor
                    with frame f-altera no-validate.
                
                assign v-banco   = chq.banco
                       v-agencia = chq.agencia
                       v-conta   = chq.conta 
                       v-numero  = chq.numero.
                
                find first chqtit where 
                           chqtit.etbcod  = bchqtit.etbcod and
                           chqtit.titnat  = bchqtit.titnat and
                           chqtit.modcod  = bchqtit.modcod and
                           chqtit.clifor  = bchqtit.clifor and
                           chqtit.titnum  = bchqtit.titnum and
                           chqtit.titpar  = bchqtit.titpar and
                           chqtit.banco   = bchqtit.banco  and
                           chqtit.agencia = bchqtit.agencia and
                           chqtit.conta   = bchqtit.conta   and
                           chqtit.numero  = bchqtit.numero no-error.
                if avail chqtit
                then do: 
                
                    assign chqtit.banco   = v-banco 
                           chqtit.agencia = v-agencia 
                           chqtit.conta   = v-conta   
                           chqtit.numero  = v-numero. 

                end.
                
                
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                find chq where recid(chq) = tt-man.rec.

                disp chq with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                
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
                if func.funcod <> 30 and
                   func.funcod <> 29 and
                   func.funcod <> 404 
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
                
                find chq where recid(chq) = tt-man.rec.
                message "Confirma Exclusao do cheque" chq.numero 
                update sresp.
                if not sresp
                then leave.
                find next tt-man where true no-error.
                if not available tt-man
                then do:
                    find tt-man where recid(tt-man) = recatu1.
                    find prev tt-man where true no-error.
                end.
                recatu2 = if available tt-man
                          then recid(tt-man)
                          else ?.
                find tt-man where recid(tt-man) = recatu1.
                find chq where recid(chq) = tt-man.rec.
                delete tt-man.
                find first chqtit of chq no-error.
                if avail chqtit
                then delete chqtit.
                delete chq.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "   Listagem "
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de tt-manidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                
                
                output to printer.
                    for each tt-man:
                        display tt-man.rec format ">>>>>>>>>9"
                                tt-man.banco
                                tt-man.agencia.
                    end.
                output close.
                
                
                recatu1 = recatu2.
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            
            if esqcom2[esqpos2] = "Gera Arquivo"
            then do:
                
                for each tt-che:
                    delete tt-che.
                end.
                for each tt-man where 
                         tt-man.marca = "*" no-lock:
                    find chq where recid(chq) = tt-man.rec 
                         no-error.
                    if not avail chq then next.
                         
                    find first chqtit of chq no-lock no-error. 
                    if not avail chqtit 
                    then next.
                    
                    message "Gerando arquivo....".
                    
                    display chq.banco
                            chq.numero
                            chq.valor(total)
                             with 1 down centered. pause 0.
                            
                            
                    find tt-che where tt-che.rec = recid(chq) no-error.
                    if not avail tt-che
                    then do:
                        create tt-che.
                        assign tt-che.rec = recid(chq).
                    end.
                    
                    vtexto = string(chq.numero).
                    run verif11.p ( input vtexto , 
                                    output v-dig).

                    if v-dig <> chq.controle3
                    then chq.controle3 = v-dig.
        
                end.
                
                run arq041r.p(0).
                recatu1 = ?. /* recid(tt-chq). */
                
            end.
            next bl-princ.
          end.
          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
            find chq where recid(chq) = tt-man.rec no-error.
        display tt-man.marca no-label
                tt-man.banco 
                tt-man.agencia  
                chq.conta format "x(12)"   
                chq.numero   
                chq.datemi   
                chq.data  
                chq.valor with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-man).
   end.
end.
