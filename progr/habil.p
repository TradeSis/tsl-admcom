{admcab.i}

def buffer xclien for clien.
def buffer bfunc for func.
def var vgera           like clien.clicod.
def var vcredito        as l format "Normal/Facil".

def var    vclicod   like clien.clicod.
def var    vciccgc   like habil.ciccgc.
def var    vcelular  like habil.celular.
def var    vgercod   like habil.gercod.
def var    vvencod   like habil.vencod.
def var    vpmtcod   like habil.pmtcod.

repeat:
    find estab where estab.etbcod = setbcod no-lock no-error.
    
    disp setbcod label "Loja....." estab.etbnom no-label skip
         today format "99/99/9999" label "Dt.Habil."
         with frame f-habil centered title " Habilitacao ".
    
    assign vciccgc  = ""
           vcelular = ""
           vgercod  = 0
           vvencod  = 0
           vpmtcod  = 0.

    update skip vciccgc label "CPF......"
           with frame f-habil  side-labels.

    find first xclien where xclien.ciccgc = vciccgc no-lock no-error.
    if not avail xclien
    then do:
       /*
        
                do on error undo:
                    do for geranum on error undo:
                        find geranum where geranum.etbcod = setbcod.
                        vgera = geranum.clicod.
                        assign geranum.clicod = geranum.clicod + 1.
                    end.
                end.

                do on error undo:
                    
                    create clien.
                    assign clien.clicod = int(string(string(vgera,"99999999") +
                                              string(setbcod,">>9"))).
                    assign clien.vencod    = 0
                           clien.exportado = yes.
                    
                    update /*clien.clicod*/
                           clien.clinom
                           clien.tippes with color white/cyan.
                    vcredito = yes.

                    update vcredito label "Credito".
                    if vcredito
                    then clien.classe = 0.
                    else clien.classe = 1.
                end.
                run clioutb4.p (input recid(clien),
                                input "I") .
        
                find xclien where xclien.clicod = clien.clicod
                                  no-lock no-error.
                disp xclien.clinom no-label with frame f-habil.

      */ message "comentei essa parte.... estava dando erro".
        
    end.
    else disp xclien.clinom no-label with frame f-habil.
    
    do on error undo:
        update vcelular label "Celular.." with frame f-habil.    
        if vcelular = ""
        then do:
            message "Informe o numero do celular.".
            undo.
        end.
    end.

    find habil where habil.ciccgc = vciccgc
                 and habil.celular = vcelular no-lock no-error.
    if avail habil
    then do:                            
        find func where func.funcod = habil.vencod no-lock.
        find bfunc where bfunc.funcod = habil.gercod no-lock.
        
        disp skip 
             habil.vencod @ vvencod
             func.funnom no-label   skip
             habil.gercod @ vgercod 
             bfunc.funnom no-label 
             with frame f-habil.          
             
        message "Habilitacao ja Cadastrada".
        pause. undo.
        
    end.
    else do:
        do on error undo:

            vvencod = 0.
            update skip vvencod label "Vendedor." with frame f-habil.
            find func where func.funcod = vvencod no-lock no-error.
            if not avail func
            then do:
                message "Vendedor nao Cadastrado".
                undo.
            end.  
            else disp func.funnom no-label with frame f-habil.
        
        end.
    
        /*do on error undo:

            vpmtcod = 0.
            update skip vpmtcod label "Promotora" with frame f-habil.
            
            find promot where promot.pmtcod = vpmtcod no-lock no-error.
            if not avail promot
            then do:
                message "Promotora nao Cadastrado".
                undo.
            end.  
            else disp promot.pmtnom no-label with frame f-habil.
        end.*/

        do on error undo:
        
            vgercod = 0.
            update skip vgercod label "Gerente.." with frame f-habil.
            find bfunc where bfunc.funcod = vgercod no-lock no-error.
            if not avail bfunc
            then do:
                message "Gerente nao Cadastrado".
                undo.
            end.
            else disp bfunc.funnom no-label with frame f-habil.
        
        end.
    
        message "Confirma os Dados Informados?" update sresp.
        if sresp
        then do:
           create habil.        
           assign habil.etbcod  = setbcod
                  habil.celular = vcelular
                  habil.habdat  = today
                  habil.ciccgc  = vciccgc
                  habil.vencod  = vvencod
                  habil.gercod  = vgercod
                  habil.pmtcod  = 0.
                  
           message "Habilitacao Incluida". pause 1 no-message.
        end.    
    end.    
    
end.    
