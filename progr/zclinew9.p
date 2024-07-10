{admcab.i}.
{setbrw.i}.

def var sretorno as char.

def var v-clacod like clase.clacod.
def var v-num as int.
def var v-datini as date format "99/99/9999".
def var v-datfim as date format "99/99/9999".
def var v-cpf like clien.ciccgc.
def var v-rg like clien.ciinsc.

def buffer bclien for clien.

def var v-op as char format "x(15)" extent 2
    initial [" CPF "," NOME "].
    
    /*,"",
             "  RG  ","","", "","","FONET."].*/

form
    v-rg   label "RG" 
    with frame f-rg
        centered
        row 10
        title " PROCURA "
        1 down
        side-labels
        overlay.

form
    v-cpf     label "CPF" 
    with frame f-cpf
        centered
        row 10
        title " PROCURA "
        1 down side-labels
        overlay.
        
form
    v-datini    label "Inicio"
    with frame f-data
        centered
        title " Datas para Pesquisa "
        1 down
        side-labels
        overlay.

form
    v-op[1]
    v-op[2]
    /*v-op[3]
    v-op[4]
    v-op[5]
    v-op[6]*/
    with frame f-opcao 
        /*centered*/  col 40
        overlay
        color cyan/black
        no-labels 
        1 down
        title " Opcoes "
        side-labels.

form
    clien.clicod
    
        help "ENTER=Seleciona"
    clien.clinom
    with frame f-sobrenome
        centered
        down
        title " Clientes - Pesquisa por Sobrenome " .

form
    clien.clicod
    clien.clinom
    clien.dtnasc
    with frame f-nascimento
        centered
        down
        title " Clientes - Pesquisa por Data de Nascimento " .

form
    clien.clicod
    clien.clinom format "x(35)"
    clien.ciinsc
        help "ENTER=Seleciona  F8=Procura "
    with frame f-identidade
        centered
        down
        title " Clientes - Pesquisa por Identidade " .
 
form
    clien.clicod 
    clien.clinom
    clien.ciccgc
        help "ENTER=Seleciona  F8=Procura"
    with frame f-ciccgc
        centered
        down
        title " Clientes - Pesquisa por CGC/CPF " .

form
    clien.clicod
    clien.clinom
    
     with frame f-consulta
        centered
        down
        title " Clientes - Pesquisa Normal " .
        
form
    clien.clicod
    clien.clinom
    
    with frame f-consult1
        centered
        down
        title " Funcionarios - Pesquisa Normal " .

repeat :
    clear frame f-consulta all.
    hide frame f-consulta.
    clear frame f-sobrenome all.
    hide frame f-sobrenome.
    clear frame f-cgcpf all.
    hide frame f-ciccgc.
    clear frame f-opcao all.
    hide frame f-opcao no-pause.
    hide frame f-data no-pause.

    hide frame f-opcao no-pause.
    clear frame f-consulta all.
    hide frame f-consulta.
    clear frame f-sobrenome all.
    hide frame f-sobrenome.
    clear frame f-cgcpf all.
    hide frame f-ciccgc.
    clear frame f-opcao all.
    hide frame f-opcao no-pause.
    hide frame f-data no-pause.
    hide frame f-cpf no-pause.
    hide frame f-rg no-pause.
    hide frame f-identidade no-pause.
        
    disp v-op with frame f-opcao.
    choose field v-op with frame f-opcao.

    /*********
    if frame-index = 2
    then do :         
        assign
            i-seeid = -1
            i-recid = -1
            i-seerec = ?.

        {abrowse.i
            &File = clien
            &CField = clien.clinom
            &Ofield = " clien.clicod  clien.clinom " 
            &Where = "true" 
            &AftSelect1 = "
                    if keyfunction(lastkey) = ""RETURN""
                    THEN DO:
                    frame-value = clien.clicod. 
                    leave keys-loop. 
                    END. "
            &locktype = "no-lock" 
            &Form = " frame f-sobrenome" 
        } .
        
        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame f-sobrenome no-pause.
            undo.
        end.
        hide frame f-sobrenome no-pause.
        leave.
    end.    
    *********/
    
    
    if frame-index = 1 /*cpf*/
    then do : 
                /*
        {zoomesq.i clien clicod ciccgc 20 Cliente "true"}
                  */
                
                
                    v-cpf = "".
                    update v-cpf with frame f-cpf.
                    find first bclien where bclien.ciccgc = v-cpf no-lock
                    no-error.
                    if not avail bclien
                    then do :
                        bell. message "Cliente nao existe". 
                        pause. clear frame f-cpf all. hide frame f-cpf.
                    end.
                    frame-value = bclien.clicod.
                    sretorno = string(bclien.clicod).
        /***********
        assign
            i-seeid = -1
            i-recid = -1
            i-seerec = ?.

        {abrowse.i
            &File = clien
            &CField = clien.ciccgc
            &Ofield = "
                clien.clicod 
                clien.clinom "    
            &Where = "true"
            &AftSelect1 = "frame-value = clien.clicod. 
                       leave keys-loop. "
            &LockType = "no-lock"
            &Otherkeys = " 
                if keyfunction(lastkey) = ""CLEAR""
                then do :
                    update v-cpf with frame f-cpf.
                    find first bclien where bclien.ciccgc = v-cpf no-lock
                    no-error.
                    if not avail bclien
                    then do :
                        bell. message ""Cliente nao existe"". 
                        pause. clear frame f-cpf all. hide frame f-cpf.
                    end.
                    else do : 
                        i-recid = recid(bclien).
                    end.
                    i-seeid = -1.
                    next keys-loop.
                end. "  
            &Form = " frame f-ciccgc" 
        } .

        **********/
        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame f-ciccgc no-pause.
            undo.
        end.

        
        hide frame f-ciccgc no-pause.
        leave.
    end.
    if frame-index = 2
    then do : 

      pause 0.
      /********
      {achaand.i clien clien.clicod clien.clinom 62 Clientes "true" "use-index clien2" "clinom"}
      
      sretorno = frame-value.
      
      if keyfunction(lastkey) = "end-error"
      then do:
          undo.
      end.
      */
      run zclien.p.  
        
      hide frame f-opcao no-pause.
      leave.
    end. 
    
    
    if frame-index = 6
    then do : 
        assign
            i-seeid = -1
            i-recid = -1
            i-seerec = ?.

        {abrowse.i
            &File = clien
            &CField = clien.clinom
            &Ofield = "
                clien.clicod 
                 "            
            &Where = "true"
            &AftSelect1 = "
                       if keyfunction(lastkey) = ""RETURN""
                                            THEN DO:
                                            
                        frame-value = clien.clicod. 
                       leave keys-loop. END.
                        "
            &LockType = "no-lock"
            &Form = " frame f-consult1" 
        } .
        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame f-consult1 no-pause.
            undo.
        end.

        
        hide frame f-consult1 no-pause.
        leave.
    end.  
    if frame-index = 5
    then do :
        clear frame f-data all.
        hide frame f-data no-pause.
        update 
            v-datini 
            with frame f-data.
        hide frame f-data no-pause.

        if v-datini = ? 
        then do :
            bell. message "Data informada invalida".
            pause. clear frame f-data all.
            hide frame f-data no-pause.
            undo.
        end.    

        assign
            i-seeid = -1
            i-recid = -1
            i-seerec = ?.

        {abrowse.i
            &File = clien
            &CField = clien.clicod
            &Ofield = " clien.clinom clien.dtnasc "
            &nonCharacter = /*            
            &Where = "clien.dtnasc = v-datini"  
            &AftSelect1 = "
                        if keyfunction(lastkey) = ""RETURN""
                                            THEN DO:
                                            
                        frame-value = clien.clicod. 
                       leave keys-loop. END.
                       "
            &AftFnd = "
                find first clien where clien.clicod = clien.clicod 
                                  no-lock."
            &Locktype = " no-lock "  
            &Form = " frame f-nascimento" 
        } .

        hide frame f-data no-pause.
        hide frame f-nascimento no-pause.
        
        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame f-data no-pause.
            hide frame f-nascimento no-pause.
            undo.
        end.
        
        leave.
    end. 
    
    if frame-index = 9
    then do:
       
        run zfonetic.p.
        if keyfunction(lastkey) = "end-error"
        then do:
            undo.
        end.
        
        leave.
        
        
    end.   
       
    if frame-index = 4
    then do :
        assign
            i-seeid = -1
            i-recid = -1
            i-seerec = ?.

        {abrowse.i
            &File = clien
            &CField = clien.ciinsc
            &Ofield = " clien.clinom clien.clicod "
            &Where = "true"
            &AftSelect1 = "
                       if keyfunction(lastkey) = ""RETURN""
                                            THEN DO:
                                            
                        frame-value = clien.clicod. 
                       leave keys-loop. END .
                       "
            &Otherkeys = "
                if keyfunction(lastkey) = ""CLEAR""
                then do :
                    update v-rg with frame f-rg.
                    find first bclien where bclien.ciinsc = v-rg 
                                      no-lock no-error.
                    if not avail bclien
                    then do :
                        bell. message ""Cliente nao existe"". 
                        pause. clear frame f-rg all. hide frame f-rg.
                    end.
                    else do : 
                        i-recid = recid(bclien).
                    end.
                    i-seeid = -1. next keys-loop. 
                end. "   
            &Locktype = " no-lock "  
            &Form = " frame f-identidade" 
        } .
        
        hide frame f-identidade no-pause.
        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame f-identidade no-pause.
            undo.
        end.
        
        leave.
    end.  
end.

hide frame f-opcao no-pause.
hide frame f-consulta.
hide frame f-sobrenome.
hide frame f-ciccgc.
hide frame f-opcao no-pause.
hide frame f-data no-pause.
hide frame f-cpf no-pause.
hide frame f-rg no-pause.
hide frame f-identidade.
