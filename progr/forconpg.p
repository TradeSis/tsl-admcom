{admcab.i}
{setbrw.i}                                                                      

ON F7 help.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  CONSULTA","  INCLUI","  ALTERA",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


form " " 
     " "
     with frame f-linha 11 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
disp "                     CONTAS BANCARIAS DE FORNECEDORES       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.
def var vnumban like banco.numban.
def temp-table tt-banco 
    field numban like banco.numban
    index i1 numban.
    
def temp-table tt-forconta
    field forcod like forne.forcod
    field fornom like forne.fornom
    index i1 forcod
    index i2 fornom.

def new global shared var sforconpg as int.    
for each forconpg where
            (if sforconpg > 0 then forconpg.forcod = sforconpg
                                else true)
            no-lock:
    if acha("SITUACAO",forconpg.char1) = "INATIVO"
    then next.
    find forne where forne.forcod = forconpg.forcod no-lock no-error.
    find first tt-forconta where
               tt-forconta.forcod = forconpg.forcod no-error.
    if not avail tt-forconta
    then do:
        create tt-forconta.
        tt-forconta.forcod = forconpg.forcod
        .
        if avail forne
        then tt-forconta.fornom = forne.fornom
                .
    end.
end.                
l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    
    {sklclstb.i  
        &color = with/cyan
        &file = tt-forconta  
        &cfield = tt-forconta.fornom
        &noncharacter = /* 
        &ofield = " tt-forconta.forcod
                    "  
        &aftfnd1 = " find forne where forne.forcod = tt-forconta.forcod
                        no-lock no-error.
                    "
        &where  = " true use-index i2 "
        &aftselect1 = " 
                        run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUIR"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop.
                        " 
        &go-on = TAB F7 PF7
        &naoexiste1 = " esqcom1[esqpos1] = ""  INCLUI"". 
                        run aftselect.
                        if sforconpg > 0
                        then leave l1.
                        " 
        &otherkeys1 = " if keyfunction(lastkey) <> ""HELP""
                        THEN run controle.
                        else do:
                            run znome2.p.
                            if sretorno <> """"
                            then do:
                                find first tt-forconta where
                                           tt-forconta.forcod = int(sretorno)
                                           no-error.
                                if not avail tt-forconta
                                then do:
                                    bell.
                                    message color red/with
                                    ""Nenhum registro encontrato.""
                                    view-as alert-box.
                                    next keys-loop.
                                end.        
                                a-recid = recid(tt-forconta).
                                a-seeid = -1.
                            end.           
                        end.
                         "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo, retry:
        prompt-for forconpg.forcod label "Fornecedor"
                 with frame f-novo
                 1 column row 5 centered.
        find forne where forne.forcod = input frame f-novo forconpg.forcod
                no-lock.
        disp forne.fornom @ forconpg.rsnome 
             with frame f-novo.
        if length(forne.forcgc) > 11
        then disp forne.forcgc @ forconpg.cnpj with frame f-novo.
        else disp "" @ forconpg.cnpj with frame f-novo.
        if length(forne.forcgc) = 11
        then disp forne.forcgc @ forconpg.cpf with frame f-novo.
        else disp "" @ forconpg.cpf with frame f-novo.
    
        prompt-for forconpg.rsnome 
                   forconpg.cnpj
                   forconpg.cpf
                   with frame f-novo.
        do on error undo, retry:
           prompt-for forconpg.numban 
                      forconpg.numagen
                      forconpg.digitoage
                      forconpg.numcon
                      forconpg.digitocon
                      forconpg.tipoconta
                      validate(input forconpg.tipoconta = 1 or
                               input forconpg.tipoconta = 2 , 
                        "Valor deve ser 1 ou 2 conforme o tipo de conta")
                      help "1-Conta corrente  2-Conta poupança"
                with frame f-novo.
        end.

        prompt-for obs[1] label "Observacao" 
                   format "x(50)"
                   obs[2] label "          "
            format "x(60)" with frame f-novo.
        
        if keyfunction(lastkey) = "RETURN"
        then do:
            create tt-forconta.
            tt-forconta.forcod = input frame f-novo forconpg.forcod.
            tt-forconta.fornom = forne.fornom.
            
            create forconpg.
            assign
                forconpg.forcod = tt-forconta.forcod
                forconpg.rsnome = input frame f-novo forconpg.rsnome
                forconpg.cnpj   = input frame f-novo forconpg.cnpj  
                forconpg.cpf    = input frame f-novo forconpg.cpf 
                forconpg.numban = input frame f-novo forconpg.numban 
                forconpg.numagen = input frame f-novo forconpg.numagen 
                forconpg.digitoage = input frame f-novo forconpg.digitoage 
                forconpg.numcon = input frame f-novo forconpg.numcon 
                forconpg.tipoconta = input frame f-novo forconpg.tipoconta
                forconpg.digitocon = input frame f-novo forconpg.digitocon
                forconpg.obs[1] = input frame f-novo forconpg.obs[1]
                forconpg.obs[2] = input frame f-novo forconpg.obs[2]
                .
                
        end.
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        run forconpg-con(input tt-forconta.forcod).
        
        vnumban = 0.
        pause 0.
        message "Numero do Banco para Alteracao:" update vnumban.
        
        run forconpg-alt(input tt-forconta.forcod).
    END.
    if esqcom1[esqpos1] = "  CONSULTA"
    THEN DO:
        run forconpg-con(input tt-forconta.forcod).     
    END.
    if esqcom1[esqpos1] = "  EXCLUIR"
    then do:
        run forconpg-exc(input tt-forconta.forcod).
    end.
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
    END.

end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
end procedure.

procedure relatorio:

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """TITULO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
end procedure.


procedure forconpg-con:
    def input parameter vforcod like forne.forcod.
    find forne where forne.forcod = vforcod no-lock.
     
    for each forconpg where
             forconpg.forcod = forne.forcod
             no-lock by numban:
        find first banco where 
                   banco.numban = forconpg.numban
                   no-lock no-error.
                   
        disp forconpg.rsnome
             forconpg.cnpj
             forconpg.cpf
             forconpg.numban
             (if forconpg.digitoagen <> ""
              then forconpg.numagen + "-" + forconpg.digitoagen 
              else forconpg.numagen) label "Agencia"
             (if forconpg.digitocon <> ""
              then forconpg.numcon + "-" + forconpg.digitocon
              else forconpg.numcon) label "Conta corrente"
             (if forconpg.tipocon = 1
              then string(forconpg.tipocon,"999") + " Conta corrente"
              else if forconpg.tipocon = 2
                  then string(forconpg.tipocon,"999") + " Conta poupança"
                  else string(forconpg.tipocon,"999"))
               label "Tipo conta" format "x(20)"
             forconpg.obs[1] format "x(60)" label "Observacao"
             with frame f-disp 1 column 2 down row 4
             title " " + string(forne.forcod) + "-" + forne.fornom + " ".
        down with frame f-disp.
        
    end.         
end procedure.

procedure forconpg-alt:
    def input parameter vforcod like forne.forcod.

    find forne where forne.forcod = vforcod no-lock.
    def var vqtd as int. 
    vqtd = 0.
    for each forconpg where
             forconpg.forcod = forne.forcod 
             no-lock.
        vqtd = vqtd + 1. 
    end.            
                 
    for each forconpg where
             forconpg.forcod = forne.forcod and
             forconpg.numban = vnumban
             by numban:
         
         disp forconpg.rsnome
             forconpg.cnpj
             forconpg.cpf
             forconpg.numban 
             forconpg.numagen
             forconpg.digitoagen
             forconpg.numcon
             forconpg.digitocon
             forconpg.tipocon
              /*
             (if forconpg.digitoagen <> ""
              then forconpg.numagen + "-" + forconpg.digitoagen 
              else forconpg.numagen) label "Agencia"
             (if forconpg.digitocon <> ""
              then forconpg.numcon + "-" + forconpg.digitocon
              else forconpg.numcon) label "Conta corrente"
             (if forconpg.tipocon = 1
              then string(forconpg.tipocon,"999") + " Conta corrente"
              else if forconpg.tipocon = 2
                  then string(forconpg.tipocon,"999") + " Conta poupança"
                  else string(forconpg.tipocon,"999"))
               label "Tipo conta"
               */
              forconpg.obs[1] format "x(60)" label "Observacao"
             with frame f-alt 1 column. 
 
         do on error undo:
         update forconpg.rsnome
             forconpg.cnpj
             forconpg.cpf
             with frame f-alt.
         if forconpg.rsnome = "" and
            forconpg.cnpj = "" and
            forconpg.cpf = ""
         then do:
            bell.
            sresp = no.
            message "Deseja excluir?" update sresp.
            if sresp
            then do on error undo:
                if vqtd = 1
                then do:
                    find first tt-forconta where
                               tt-forconta.forcod = forne.forcod
                               no-error.
                    if avail tt-forconta
                    then delete tt-forconta.           
                end.
                delete forconpg. 
            end.
            else undo, retry.
         end.
         else do:
             
         update forconpg.numban when forconpg.numban = 0
             forconpg.numagen
             forconpg.digitoage label "Digito agencia"
             forconpg.numcon
             forconpg.digitocon label "Digito conta"
             forconpg.tipocon
             validate(input forconpg.tipoconta = 1 or
                               input forconpg.tipoconta = 2 , 
                        "Valor deve ser 1 ou 2 conforme o tipo de conta")
             help "1-Conta corrente  2-Conta poupança"
             forconpg.obs[1] format "x(60)" label "Observacao"
             with frame f-alt 1 column. 
        end.        
        end.
    end.         
end procedure.

procedure forconpg-exc:
    def input parameter vforcod like forne.forcod.
    sresp = no.
    message "Confirma excluir?" update sresp.
    if sresp
    then do:
        for each forconpg where
                 forconpg.forcod = vforcod exclusive:
            forconpg.char1 = "SITUACAO=INATIVO|".
            find first tt-forconta where
                       tt-forconta.forcod = forconpg.forcod no-error.
            if avail tt-forconta
            then delete tt-forconta.
        end.         
    end.
end procedure.
