{admcab.i}
{setbrw.i}                                                                      

def input parameter p-codmix like tabmix.codmix.

def new shared var sexclui as log init no.

find first tabmix where tabmix.tipomix = "M"
                    and tabmix.codmix = p-codmix no-lock.

def temp-table tt-tabmix like tabmix.
def new shared temp-table tt-mix 
    field marca as char
    field codmix like tabmix.codmix
    field descmix like tabmix.descmix
    index i1 descmix
    .
def var vprocod like produ.procod.
def var vpronom like produ.pronom. 
def var vop as char format "x(20)"  extent 6.
def var vindex as int.
vop[1] = "1.CONSULTAR PRODUTO".
vop[2] = "2.INCLUIR PRODUTO".
VOP[3] = "3.EXCLUIR PRODUTO".
VOP[4] = "4.EXCLUIR CLASSE".
VOP[5] = "5.EXPORTAR MIX".
vop[6] = "6.IMPORTAR MIX".
do:
    find first tabmix where tabmix.tipomix = "M"
                    and tabmix.codmix = p-codmix no-lock.

    vindex = 0.
    disp vop with frame f-op 1 column no-label width 24
          title substr(tabmix.descmix,1,20).
    choose field vop with frame f-op.
    if keyfunction(lastkey) = "end-error"
    then leave.
    vindex = frame-index.
    if vindex = 1
    then run consulta.
    else if vindex = 2
    then run inclui.
    else if vindex = 3
    then run exclui.
    else if vindex = 4
    then run exc-classe.
    else if vindex = 5
    then do.
        sresp = no.
        message "Confirma exportar MIX" p-codmix tabmix.descmix "?" 
        update sresp.
        if sresp
        then run expmix01.p(input p-codmix, 0).
    end.
    else if vindex = 6
    then run impmix01.p.
end.    

PROCEDURE INCLUI:
    DO on error undo, retry with frame f-inclui 
                              side-label centered color message
                              row 10 :
                prompt-for vprocod  label "Produto" format ">>>>>>>9" .
                    
                vpronom = " ".    
                find produ where produ.procod = input vprocod 
                         no-lock.
                if avail produ
                then vpronom = produ.pronom.   
                disp vpronom  label "Descricao".
                create tt-tabmix.
                assign tt-tabmix.codmix = ?
                    tt-tabmix.tipomix = "P"
                    tt-tabmix.promix  = input vprocod
                    tt-tabmix.etbcod  = 0.
                
                assign tt-tabmix.qtdmix = 1. tt-tabmix.mostruario = yes.
                update  tt-tabmix.mostruario  at 1 label "Mostruario" .
                if tt-tabmix.mostruario
                then update tt-tabmix.qtdmix      at 1 label "Quantidade".
                else tt-tabmix.qtdmix = 0.
                disp tt-tabmix.qtdmix.
                /*
                run ver-classe(input produ.procod).
                */
                update  tt-tabmix.sazonal     at 4 label "Sazonal"    .
                update tt-tabmix.campoint2  label "Dias cobertura(minimo)"
                            format ">>9".
                if tt-tabmix.sazonal
                then do on error undo, retry:
                    update    tt-tabmix.qtdsazonal  label "QtdSazonal" 
                        help "Informe o quantidade para produto sazonal"
                       tt-tabmix.dtsazonali  label "Inicio" 
                        help "Informe a data inicio do periodo sazonal" 
                       tt-tabmix.dtsazonalf  label "Fim"
                        help "Informe a data fim do periodo sazonal" .
                    if tt-tabmix.dtsazonali = ? or 
                        tt-tabmix.dtsazonalf = ? or
                       tt-tabmix.dtsazonali > tt-tabmix.dtsazonalf
                    then undo.   
                end.
                else assign 
                    tt-tabmix.dtsazonali = ? 
                    tt-tabmix.dtsazonalf = ? 
                    tt-tabmix.qtdsazonal = 0.
                repeat :
                    
                    run selmix01.p(input 0, input "").
                    
                    find first tt-mix where 
                           tt-mix.codmix > 0 no-error.
                    if not avail tt-mix
                    then do:
                        sresp = no.
                        run mensagem.p (input-output sresp,
                         input "Voce precisa selecionar pelo menos um MIX." +
                          "!Se voce deseja selecionar um MIX marque CONTINUAR."
                          + "!Mas se vc deseja sair da inclusao marque SAIR."
                          + "!!       QUAL SUA DECISAO ? ",
                              input "",
                              input "CONTINUAR",
                              input "    SAIR").
                        if sresp = no 
                        then leave.                   
                    end. 
                    else do:
                        for each tt-mix where tt-mix.codmix > 0:
                            tt-tabmix.codmix = tt-mix.codmix.

                            do on error undo:
                                create tabmix.
                                buffer-copy tt-tabmix to tabmix.
                                release tabmix no-error.
                            end.
                           /* message tt-mix.codmix tt-tabmix.promix.*/
                                pause 1 no-message.
                            run expmix01.p(input tt-mix.codmix, 
                                           input tt-tabmix.promix).

                            
                            /*
                            delete tt-mix.
                            */
                            /*
                            run grava-tablog.p 
                                (input 2, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "INCLUI").
                            */
                        end.
                        leave.
                    end.           
                end.
    END.
    hide frame f-inclui no-pause.
END PROCEDURE.
PROCEDURE EXCLUI:
    DO:
        update vprocod format ">>>>>>>9" with frame f-EXCLU
                        1 down side-label row 5 overlay
                        centered color message.
        find first tabmix where 
             tabmix.codmix >= 0 and
             tabmix.tipomix = "P" and
             tabmix.promix  = vprocod   
             no-lock no-error.
        if not avail tabmix
        then do:
            message "Nao encontrado".
            pause.
        end.
        else repeat :
            
            run selmix01.p(input vprocod, input "P").
            find first tt-mix where  tt-mix.codmix > 0 no-error.
            if not avail tt-mix
            then do:
                sresp = no.
                run mensagem.p (input-output sresp,
                         input "Voce precisa selecionar pelo menos um MIX." +
                          "!Se voce deseja selecionar um MIX marque CONTINUAR."
                          + "!Mas se vc deseja sair da exclusao marque SAIR."
                          + "!!       QUAL SUA DECISAO ? ",
                              input "",
                              input "CONTINUAR",
                              input "    SAIR").
                if sresp = no 
                then leave.                   
            end. 
            else do:
                sresp = no.
                run mensagem.p (input-output sresp,
                         input 
                           "!!      CONFIRMA EXCLUIR ? ",
                              input "",
                              input "   SIM",
                              input "   NAO").
                if sresp = no 
                then leave. 
                for each tt-mix where tt-mix.codmix > 0:
                    find first tabmix where 
                         tabmix.codmix = tt-mix.codmix and
                         tabmix.tipomix = "P" and
                         tabmix.promix  = vprocod   
                             no-error.
                    if avail tabmix
                    then do:
                        /*
                        run grava-tablog.p 
                                (input 2, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "EXCLUI").
                        */
                        tabmix.mostruario = no.
                        sexclui = yes.
                        run expmix01.p(input tabmix.codmix, 
                                       input tabmix.promix).
                        sexclui = no.
                        delete tabmix.
                    end.
                    delete tt-mix.
                end.    
                leave.
            end.
        end.
    END.
    hide frame f-EXCLU no-pause.
END PROCEDURE.

PROCEDURE CONSULTA:
    
    update vprocod format ">>>>>>>9" with frame f-procura
                        1 down side-label row 5 overlay
                        centered color message.
    run selmix02.p(input vprocod).
 
    hide frame f-procura no-pause.
END PROCEDURE.

PROCEDURE exc-classe:
    def var vclacod like produ.clacod.
    repeat:
        update vclacod format ">>>>>>>>9" with frame f-EXCclasse
                        1 down side-label row 5 overlay
                        centered color message.
        find clase where clase.clacod = vclacod no-lock no-error.
        if not avail clase
        then do:
            message "Classe não encontrada." .
            pause. 
            next.
        end.                  
        find first tabmix where 
             tabmix.codmix >= 0 and
             tabmix.tipomix = "F" and
             tabmix.promix  = vclacod   
             no-lock no-error.
        if not avail tabmix
        then do:
            message "Nenhum MIX liberado para Classe.".
            pause.
        end.
        else repeat :
            run selmix01.p(input vclacod, input "F").
            find first tt-mix where  tt-mix.codmix > 0 no-error.
            if not avail tt-mix
            then do:
                sresp = no.
                run mensagem.p (input-output sresp,
                         input "Voce precisa selecionar pelo menos um MIX." +
                          "!Se voce deseja selecionar um MIX marque CONTINUAR."
                          + "!Mas se vc deseja sair da exclusao marque SAIR."
                          + "!!       QUAL SUA DECISAO ? ",
                              input "",
                              input "CONTINUAR",
                              input "    SAIR").
                if sresp = no 
                then leave.                   
            end. 
            else do:
                sresp = no.
                run mensagem.p (input-output sresp,
                         input 
                           "!!      CONFIRMA EXCLUIR ? ",
                              input "",
                              input "   SIM",
                              input "   NAO").
                if sresp = no 
                then leave.
                find first produ where produ.clacod = vclacod no-lock no-error.
                if avail produ
                then do:
                for each produ where produ.clacod = vclacod no-lock.
                    for each tt-mix where tt-mix.codmix > 0:
                       find first tabmix where 
                             tabmix.codmix = tt-mix.codmix and
                             tabmix.tipomix = "P" and
                             tabmix.promix  = produ.procod 
                             no-error.
                       if avail tabmix
                       then do:
                            /*
                            run grava-tablog.p 
                                (input 2, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "EXCLUI").
                            */
                            if tabmix.mostruario = yes
                            then do:
                            tabmix.mostruario = no.
                            run expmix01.p(input tabmix.codmix, 
                                       input tabmix.promix).
                            end.
                            delete tabmix.
                        end.
                        find first tabmix where 
                             tabmix.codmix = tt-mix.codmix and
                             tabmix.tipomix = "F" and
                             tabmix.promix  = vclacod   
                             no-error.
                        if avail tabmix
                        then delete tabmix.
                        
                    end.
                end. 
                end.
                else do:
                for each clase where clase.clasup = vclacod no-lock.
                for each produ where produ.clacod = clase.clacod no-lock.
                    for each tt-mix where tt-mix.codmix > 0:
                       find first tabmix where 
                             tabmix.codmix = tt-mix.codmix and
                             tabmix.tipomix = "P" and
                             tabmix.promix  = produ.procod 
                             no-error.
                       if avail tabmix
                       then do:
                            /*
                            run grava-tablog.p 
                                (input 2, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "EXCLUI").
                            */
                            if tabmix.mostruario = yes
                            then do:
                            tabmix.mostruario = no.
                            run expmix01.p(input tabmix.codmix, 
                                       input tabmix.promix).
                            end.
                            delete tabmix.
                        end.
                        find first tabmix where 
                             tabmix.codmix = tt-mix.codmix and
                             tabmix.tipomix = "F" and
                             tabmix.promix  = vclacod   
                             no-error.
                        if avail tabmix
                        then delete tabmix.
                        
                    end.
                end.      
                end.
                end.
                
                find first tabmix where 
                             tabmix.codmix = tt-mix.codmix and
                             tabmix.tipomix = "F" and
                             tabmix.promix  = vclacod   
                             no-error.
                        if avail tabmix
                        then delete tabmix.
                
                for each tt-mix: delete tt-mix. end.
                leave.
            end.
        END.
       hide frame f-EXCclasse no-pause.
       leave.
    end.        
END PROCEDURE.

/**
procedure ver-classe:
    def input parameter p-procod like produ.procod.
    def buffer b-tabmix for tabmix.
    def buffer b-produ  for produ.
    def var qtd-cla as int.
    def var qtd-pro as int.

    find b-produ where b-produ.procod = p-procod no-lock.
    find clase where clase.clacod = b-produ.clacod no-lock.
    qtd-cla = 0.
    find b-tabmix where b-tabmix.tipomix = "C" and
                        b-tabmix.codmix  = p-codmix and
                        b-tabmix.promix  = b-produ.clacod
                        no-lock no-error.
    if avail b-tabmix 
    then qtd-cla = qtd-cla + b-tabmix.qtdmix.
    qtd-pro = 0.
    for each b-produ where b-produ.clacod = clase.clacod no-lock.
        find b-tabmix where b-tabmix.tipomix = "P" and
                        b-tabmix.codmix  = p-codmix and
                        b-tabmix.promix  = b-produ.procod
                        no-lock no-error.
        if avail b-tabmix
        then qtd-pro = qtd-pro + b-tabmix.qtdmix.
    end.
    if qtd-cla > 0 and
       qtd-pro > qtd-cla
    then do:
        message color red/with   skip(1)
        "   A soma das qauntidades dos produtos ja informados    " 
        qtd-pro skip
        "   esta maior que a quantidade informada para classe  " 
        qtd-cla skip(1)
        view-as alert-box.
    end.   
end procedure.
**/
