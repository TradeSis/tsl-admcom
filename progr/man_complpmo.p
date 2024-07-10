{admcab.i}
{setbrw.i}                                                                      

prompt-for complpmo.mescomp label "Competencia Mes/Ano" format "99"
        validate(input complpmo.mescomp > 0 ,"Informe o mes de competencia.")
           "/"
           complpmo.anocomp no-label  format "9999"
           validate(input complpmo.anocomp > 0,"Informe o ano de competencia.")
           with frame f-ma side-label width 80
           .
           
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  INCLUIR","  FECHAR","  EXCLUIR",""].
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

form complpmo.dtlanini column-label "DtLanIni"
     complpmo.dtlanfim column-label "DtLanFim"
     complpmo.etbcod   column-label "Filial"
     complpmo.forcod   column-label "Fornecedor"
     complpmo.vencod   column-label "Consultor"
     complpmo.setcod   column-label "Setor"
     complpmo.modcod   column-label "Modal"
     complpmo.situacao column-label "Sit"
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                                
def var i as int.
def buffer bcomplpmo for complpmo.

def temp-table tt-complpmo like complpmo.

l1: repeat:

    color disp normal esqcom1[esqpos1] with frame f-com1.
    color disp normal esqcom2[esqpos2] with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = complpmo  
        &cfield = complpmo.dtlanini
        &noncharacter = /* 
        &ofield = " complpmo.dtlanfim
                    complpmo.etbcod  when complpmo.etbcod > 0
                    complpmo.forcod  when complpmo.forcod > 0
                    complpmo.vencod  when complpmo.vencod > 0
                    complpmo.setcod  when complpmo.setcod > 0
                    complpmo.modcod  
                    complpmo.situacao
                    "  
        &aftfnd1 = " "
        &where  = " complpmo.anocomp = input frame f-ma complpmo.anocomp and
                    complpmo.mescomp = input frame f-ma complpmo.mescomp
                    "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUIR"" or
                           esqcom1[esqpos1] = ""  INCLUIR"" or
                           esqcom1[esqpos1] = ""  FECHAR""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " esqcom1[esqpos1] = ""  INCLUIR"".
                        run aftselect.
                        esqcom1[esqpos1] = """".
                        if keyfunction(lastkey) = ""END-ERROR""
                        then leave l1.
                        else next l1.
                         " 
        &otherkeys1 = " run controle. "
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
    empty temp-table tt-complpmo.
    if esqcom1[esqpos1] = "  INCLUIR"
    THEN DO on error undo, return 
                with frame f-inclu 1 down side-label
                1 column row 8 centered title " incluir ":
        prompt-for complpmo.dtlanini label "lancto inicial  "
                   validate(input complpmo.dtlanini <> ?,"Data invalida.") 
                   complpmo.dtlanfim label "lancto final    "
                   validate(input complpmo.dtlanfim <> ? and
                            input complpmo.dtlanini <= input complpmo.dtlanfim
                            ,"Periodo invalido.").
        prompt-for complpmo.etbcod   label "codigo filial   "
                   validate(input complpmo.etbcod = 0 or
                            (input complpmo.etbcod > 0 and
                             can-find (first estab where 
                                     estab.etbcod = input complpmo.etbcod)),
                             "Filial não cadastrada.").        

        prompt-for complpmo.forcod   label "cod fornecedor  "
                   validate(input complpmo.forcod = 0 or
                            (input complpmo.forcod > 0 and
                             can-find (first forne where
                                   forne.forcod = input complpmo.forcod)),
                                   "Fornecedor não cadastrado.").
        
        prompt-for complpmo.vencod   label "codigo consultor  "
                   validate(input complpmo.vencod = 0 or
                           (input complpmo.vencod > 0 and
                             input complpmo.etbcod > 0 and
                             can-find (first func where
                                func.etbcod = input complpmo.etbcod and
                                func.funcod = input complpmo.vencod)),
                "Consultor não cadastrado ou codigo da filial não informado.")
                .

        prompt-for complpmo.setcod   label "codigo setor      "
                validate(input complpmo.setcod = 0 or
                         (input complpmo.setcod > 0 and
                          can-find(first setor where
                                         setor.setcod = input complpmo.setcod)),
                         "Setor não cadatrado.").
        
        prompt-for complpmo.modcod   label "Modalidade        "
                   validate(input complpmo.modcod = "" or
                            (input complpmo.modcod <> "" and
                             can-find(first modal where
                                        modal.modcod = input complpmo.modcod)),
                             "Modalidade não cadastrada.").           
        
        message "Confirma incluir?" update sresp.
        if not sresp then undo.      
        
        do on error undo:
            create complpmo.
            assign
                complpmo.anocomp = input frame f-ma complpmo.anocomp
                complpmo.mescomp = input frame f-ma complpmo.mescomp
                complpmo.dtlanini = input complpmo.dtlanini
                complpmo.dtlanfim = input complpmo.dtlanfim
                complpmo.etbcod   = input complpmo.etbcod
                complpmo.forcod   = input complpmo.forcod
                complpmo.vencod   = input complpmo.vencod
                complpmo.setcod  = input complpmo.setcod
                complpmo.modcod   = input complpmo.modcod
                complpmo.dtinclu  = today
                complpmo.situacao = "A"
                .
                
        end.             
    END.
    if esqcom1[esqpos1] = "  FECHAR"
    THEN DO:
        sresp = no.
        message "Confirma fechar competencia?" update sresp.
        if sresp
        then do on error undo.
            find bcomplpmo where 
                recid(bcomplpmo) = recid(complpmo) no-error.
            if avail bcomplpmo and
                     bcomplpmo.situacao = "A"
            then bcomplpmo.situacao = "F".
            else do:
                message color red/with
                 "Situação não permite fechamento."
                 view-as alert-box.
            end.
        end.
    END.
    if esqcom1[esqpos1] = "  EXCLUIR"
    THEN DO:
        sresp = no.
        message "Confirma excluir registro?" update sresp.
        if sresp
        then do on error undo.
            find bcomplpmo where 
                recid(bcomplpmo) = recid(complpmo) no-error.
            if avail bcomplpmo and
                     bcomplpmo.situacao = "A"
            then delete bcomplpmo.
            else do:
                message color red/with
                 "Exclusão não perimitida."
                 view-as alert-box.
            end.
        end.
    END.
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
    else do:
        {mrod.i}
    end.
end procedure.

