{admcab.i}

def var vip as char.

def var vobs like titluc.titobs.
def var vlpag like titluc.titvlpag.
def var vldes like titluc.titvldes.
def var vljur like titluc.titvljur.

def var varquivo as char.
def var vdti            like plani.pladat.
def var vdtf            like plani.pladat.
def var vtitsit         like titluc.titsit.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
            initial ["Autorizacao","Consulta","Listagem","Observacao",
                     "Pagamento","Exclusao"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

def temp-table tt-titluc
    field wrec as recid.
    
def buffer btitluc       for titluc.
def var vetbcod         like titluc.etbcod.
def var vsetcod         like setaut.setcod.

    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered width 80.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
                 
repeat:
                 
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
    recatu1 = ?.
    
    vtitsit = "AUT".
    
    hide frame frame-a no-pause.
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.
    
    update vsetcod label "Setor" 
               with frame ff1 side-label width 80.
    if vsetcod = 0
    then display "GERAL" @ setaut.setnom with frame ff1.
    else do:
        find setaut where setaut.setcod = vsetcod no-lock no-error.
        if not avail setaut
        then do:
            message "Setor nao cadastrado".
            undo, retry.
    
        end.
        display setaut.setnom no-label with frame ff1.
    end.
    update vtitsit label "Situacao" with frame ff1.
    
    for each tt-titluc:
        delete tt-titluc.
    end.
        
        
    for each foraut where if vsetcod = 0
                          then true
                          else foraut.setcod = setaut.setcod no-lock:
        for each titluc where titluc.clifor = foraut.forcod and
                              titluc.etbcod < 900 no-lock:
            if titluc.etbcod = 993 or
               titluc.etbcod = 995 or
               titluc.etbcod = 996 or
               titluc.etbcod = 998 or
               titluc.etbcod = 999 or
               titluc.etbcod = 900
            then next.      
            if titluc.titsit = vtitsit
            then do:
                create tt-titluc.
                assign tt-titluc.wrec = recid(titluc).
            end.
        end.
    end.
    
    
    
    
    
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then find first tt-titluc where true no-error.
    else find tt-titluc where recid(tt-titluc) = recatu1.
    vinicio = yes.
    if not available tt-titluc
    then do:
        message "Nenhuma despesa cadastrada".
        pause.
        leave bl-princ.
    end.
    clear frame frame-a all no-pause.
    
    find titluc where recid(titluc) = tt-titluc.wrec no-lock.
    find foraut where foraut.forcod = titluc.clifor no-lock no-error.
    

    display titluc.etbcod    column-label "Fl" format ">>9"
            titluc.titnum    column-label "Despesa" format "x(10)"
            titluc.clifor    column-label "Codigo" format ">>>>>9"
            foraut.fornom    column-label "Fornecedor" format "x(20)"
            titluc.titdtven  column-label "Dt.Venc"  format "99/99/99"
            titluc.titdtpag  column-label "Dt.Pag."  format "99/99/99" 
            titluc.titvlcob  column-label "Valor" format ">>,>>9.99"
            titluc.titsit 
            foraut.autlp     
                with frame frame-a 14 down centered.

    recatu1 = recid(tt-titluc).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-titluc where true.
        if not available tt-titluc
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.

        find titluc where recid(titluc) = tt-titluc.wrec no-lock.


        find foraut where foraut.forcod = titluc.clifor no-lock no-error.

        display titluc.etbcod 
                titluc.titnum     
                titluc.clifor     
                foraut.fornom     
                titluc.titdtven   
                titluc.titdtpag
                titluc.titvlcob   
                titluc.titsit 
                foraut.autlp 
                 with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-titluc where recid(tt-titluc) = recatu1.
        find titluc where recid(titluc) = tt-titluc.wrec no-lock.


        run color-message.
        choose field titluc.etbcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        run color-normal.
        
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
                find next tt-titluc where true no-error.
                if not avail tt-titluc
                then leave.
                recatu1 = recid(tt-titluc).
                find titluc where recid(titluc) = tt-titluc.wrec no-lock.

            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-titluc where true no-error.
                if not avail tt-titluc
                then leave.
                recatu1 = recid(tt-titluc).
                find titluc where recid(titluc) = tt-titluc.wrec no-lock.

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
            find next tt-titluc where true no-error.
            if not avail tt-titluc
            then next.
            find titluc where recid(titluc) = tt-titluc.wrec no-lock.
            color display normal
                titluc.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-titluc where true no-error.
            if not avail tt-titluc
            then next.
            find titluc where recid(titluc) = tt-titluc.wrec no-lock.
            color display normal
                titluc.etbcod.
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
            then do transaction with frame f-inclui overlay 
                row 6 1 column centered.
                create titluc.
                update titluc.titnum
                       titluc.etbcod.
                recatu1 = recid(titluc).
                leave.
            end.
            if esqcom1[esqpos1] = "Autorizacao"
            then do transaction with frame f-altera 
                overlay row 6 1 column centered.
                
                find titluc where recid(titluc) = tt-titluc.wrec.
                if titluc.titsit = "PAG"
                then do:
                    message "Despesa ja paga".
                    pause.
                    undo, retry.
                end.     
                
                update titluc.titsit 
                  help "[NEG - Negado] - [LIB - Liberado] - [BLO - Bloqueado]"  
                    with frame f-altera no-validate.
                    
                if titluc.titsit <> "NEG" and
                   titluc.titsit <> "LIB" and
                   titluc.titsit <> "BLO"
                then do:
                    message "Situacao Invalida".
                    undo, retry.
                end.
                titluc.datexp = today.

            end. 
            
            if esqcom1[esqpos1] = "Observacao"
            then do transaction:
                if titluc.titsit = "Pag"
                then do:
                    message "Despesa Paga". 
                    pause. 
                    undo, retry.
                end.
                find titluc where recid(titluc) = tt-titluc.wrec.

                update titluc.titobs[1] no-label 
                       titluc.titobs[2] no-label 
                            with frame f-obs centered
                                title "Observacoes".
            
                titluc.datexp = today.
            end.

            if esqcom1[esqpos1] = "Pagamento"
            then do:
                if titluc.titsit = "lib" and
                   titluc.etbcod < 900 and {conv_difer.i titluc.etbcod}
                then do on error undo, retry:
                    vldes = 0.
                    vljur = 0.
                    
                    update vldes label "Valor Desconto" at 1
                           vljur label "Valor Juros   " at 1
                        with frame f-pag side-label centered.
                        
                    vlpag = titluc.titvlcob - vldes + vljur.
                         
                    update vlpag label "Valor Pago    " at 1
                        with frame f-pag.

                    if vlpag < titluc.titvlcob
                    then vldes = titluc.titvlcob - vlpag.
                    else vljur = vlpag - titluc.titvlcob. 
                    
                    message "Confirma Pagamento da despesa" update sresp.
                    if sresp
                    then do transaction:
                        assign titluc.titdtpag = today
                               titluc.titvlpag = vlpag
                               titluc.titvljur = vljur
                               titluc.titvldes = vldes
                               titluc.etbcobra = setbcod
                               titluc.datexp   = today
                               titluc.cxacod   = scxacod
                               titluc.titsit   = "pag".
                        
                        message "Pagando despesa na matriz.....".
                        
                        find foraut where foraut.forcod = fin.titluc.clifor 
                                        no-lock.
        
                        connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld 
                                banfin no-error.
                        
                        connect fin -H erp.lebes.com.br -S sdrebfin -N tcp -ld 
                                        finmatriz no-error.
   
                        
                        run paga-titluc.p (recid(titluc)).
                
                
                        disconnect finmatriz.

                        if foraut.autlp = yes
                        then disconnect banfin.
                        
                        hide message no-pause.       
                 
                    
                    end.
                end.
                else do:
                    message "Despesa nao autorizada".
                    pause.
                    undo, retry.
                end.
                leave.
            end.  


            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 centered side-label.

                find titluc where recid(titluc) = tt-titluc.wrec no-lock.

                disp titluc.etbcod   label "Filial    "  at 1 
                     titluc.titnum   label "Despesa   "  at 1
                     titluc.clifor   label "Fornecedor"  at 1.
                        
                find foraut where foraut.forcod = titluc.clifor no-lock.
                display foraut.fornom no-label.        
                
     
                display        
                     titluc.modcod   label "Modalidade"  at 1
                     titluc.titdtemi label "Emissao   "  at 1
                     titluc.titdtven label "Vencimento"  at 1
                     titluc.titdtpag label "Pagamento "  at 1
                     titluc.cxacod   label "Caixa     "  at 1
                     titluc.datexp   label "Exportado "  at 1
                        format "99/99/9999"
                        with frame f-consulta no-validate.
                        
                display titluc.titobs[1] no-label 
                        titluc.titobs[2] no-label 
                            with frame f-obs centered
                                title "Observacoes".
                
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do transaction with frame f-exclui 
                overlay row 6 1 column centered.

               
                message "Confirma Exclusao de" titluc.titnum update sresp.
                if not sresp
                then leave.
                find next tt-titluc where true no-error.
                if not available tt-titluc
                then do:
                    find tt-titluc where recid(tt-titluc) = recatu1.
                    find prev tt-titluc where true no-error.
                end.
                recatu2 = if available tt-titluc
                          then recid(tt-titluc)
                          else ?.
           
                find tt-titluc where recid(tt-titluc) = recatu1.

                find titluc where recid(titluc) = tt-titluc.wrec. 
                if titluc.titsit = "PAG"
                then do:
                    message "Despesa ja paga".
                    pause.
                    undo, retry.
                end.     

 
                
                vip = "filial" + string(titluc.etbcod,">>9").

                
                if titluc.etbcod < 900 and {conv_difer.i titluc.etbcod} 
                    and  titluc.etbcod <> 22
                then do: 
                    message "Deletando despesa na loja.....". 
                    connect fin -H value(vip) -S sdrebfin -N tcp -ld finloja no-error.
                    if not connected ("finloja")  
                    then do:  
                        message "Filial nao conectada".  
                        pause.  
                        undo, retry. 
                    end. 
                    
                    run deleta-titluc.p (recid(titluc)). 
                    disconnect finloja.
                    hide message no-pause.
                    delete tt-titluc.
                end.
                else do:
                    delete titluc.
                    delete tt-titluc.
                end.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do:
                update vdti label "Periodo de Vencimento"
                       vdtf no-label
                            with frame f-lista width 80 side-label.
                            
                recatu2 = recatu1.

                if opsys = "UNIX"
                then varquivo = "/admcom/relat/titluc" + STRING(day(today))
                            + "." + string(time).
                else varquivo = "..\relat\titluc" + STRING(day(today))
                            + "." + string(time).

                {mdad.i
                    &Saida     = "value(varquivo)"  
                    &Page-Size = "64" 
                    &Cond-Var  = "130" 
                    &Page-Line = "66" 
                    &Nom-Rel   = ""titluc""
                    &Nom-Sis   = """SISTEMA FINANCEIRO"""
                    &Tit-Rel   = """DESPESAS DAS FILIAIS EM "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
                    &Width     = "130"
                    &Form      = "frame f-cabcab"}


                                                  /*era titdtpag*/
                for each titluc where titluc.titsit = vtitsit and
                                      titluc.titdtven >= vdti and
                                      titluc.titdtven <= vdtf no-lock:
                    find foraut where foraut.forcod = titluc.clifor 
                        no-lock no-error.

                    display titluc.etbcod    
                            titluc.titnum     
                            titluc.clifor     
                            foraut.fornom format "x(30)"     
                            titluc.titdtven   
                            titluc.titvlcob(total)   
                            titluc.titvlpag(total)
                            titluc.titsit  
                            foraut.autlp 
                                with frame f-lista2 width 130 down.
 
                end.
                output close.
                if opsys = "UNIX"
                then do:
                    run visurel.p(varquivo, "").
                end.
                else do:
                {mrod.i}
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
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.

        find titluc where recid(titluc) = tt-titluc.wrec no-lock.

        find foraut where foraut.forcod = titluc.clifor no-lock no-error.

        display titluc.etbcod    
                titluc.titnum    
                titluc.clifor    
                foraut.fornom    
                titluc.titdtven
                titluc.titdtpag  
                titluc.titvlcob  
                titluc.titsit 
                foraut.autlp
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-titluc).
   end.
end.

procedure color-message.
color display message
        titluc.etbcod
        titluc.titnum
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        titluc.etbcod
        titluc.titnum
        with frame frame-a.
end procedure.

end.

