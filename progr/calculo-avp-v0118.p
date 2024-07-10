{admcab.i new}
{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Altera","  Inclui","  Cancela",""].
def var esqcom2         as char format "x(18)" extent 5
initial ["    Indicadores","     Simular","    Processar","   Contabilizar",
""].
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

form 
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                                
disp "                      CALCULO AVP DEVEDORES E CREDORES " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     

def buffer btbcntgen for tbcntgen.                            
def var i as int.

def var vindcod like indic.indcod.

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
        &file = tbparavp  
        &cfield = tbparavp.datref
        &noncharacter = /* 
        &ofield = " tbparavp.datref    column-label ""Referencia""
                    tbparavp.dtiemis   column-label ""DtiEmis""
                    tbparavp.dtfemis   column-label ""DtfEmis""
                    tbparavp.natureza  column-label ""Natureza""
                    tbparavp.indcod    no-label
                    indic.inddes  format ""x(15)""  when avail indic
                        column-label ""Indicador""
                    tbparavp.situacao format ""x(10)""
                    "  
        &aftfnd1 = " find first indic where
                                indic.indcod = tbparavp.indcod
                                no-lock no-error.
                                "
        &where  = " "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" and
                           esqcom1[esqpos1] = ""  INCLUI"" and
                           esqcom1[esqpos1] = ""    Processar""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " 
                        if esqcom1[esqpos1] = ""  INCLUI""
                        then do:
                            run aftselect.
                            esqcom1[esqpos1] = """" .
                            next l1.
                        end.
                        bell.
                        sresp = no.
                        message ""Nenhum registro encontrato. deseja incluir?""
                         update sresp.
                        if sresp
                        then do:
                            esqcom1[esqpos1] = ""  INCLUI"" .
                            next keys-loop.
                        end.
                        else leave l1.
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
    def buffer bindic for indic.
    if esqregua
    then do:
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        find first bindic no-lock no-error.
        if not avail bindic
        then do:
            hide frame f-com1 no-pause.
            hide frame f-com2 no-pause.
            hide frame f1 no-pause.
            hide frame f2 no-pause.
            run cadindic.p.
            esqcom1[esqpos1] = "".
            disp esqcom1 with frame f-com1.
            disp esqcom2 with frame f-com2.
            assign
                a-seeid = -1 a-recid = -1 a-seerec = ?
                esqpos1 = 1 esqpos2 = 1.
            disp  with frame f1.
            disp  with frame f2.
        end.
            
        prompt-for tbparavp.datref  label "Referencia-1"
                   with frame f-inc.
        if input frame f-inc tbparavp.datref < 01/01
        then do:
            bell.
            message color ed/with
            "Referencia bloqueda para processamento."
            view-as alert-box.
            undo.      
        end.
                    
        prompt-for tbparavp.dtiemis label "DtiEmis"
                   tbparavp.dtfemis label "DtfEmis"
                   with frame f-inc
                   .
 
        if (input frame f-inc tbparavp.dtiemis = ? and
            input frame f-inc tbparavp.dtfemis = ?) or
           (input frame f-inc tbparavp.dtfemis = ? and
            input frame f-inc tbparavp.dtiemis <> ? and
            input frame f-inc tbparavp.dtiemis <= 
            input frame f-inc tbparavp.datref) or
           (input frame f-inc tbparavp.dtiemis = ? and 
            input frame f-inc tbparavp.dtfemis <> ? and
            input frame f-inc tbparavp.dtfemis <= 
            input frame f-inc tbparavp.datref)
        then.
        else do:
                bell.
                message color red/with
                "Periodo de emissao invalido."
                view-as alert-box.
                undo.
        end. 
        prompt-for tbparavp.natureza label "Natureza" 
                   /*tbparavp.indcod  Label "Indicador"  */
                   with frame f-inc 1 down centered row 6
                   side-label 1 column overlay
                   .

        /*
        run indic-help.
        */
        
        disp vindcod  Label "Indicador"
            with frame f-inc.
        pause 0.
        if keyfunction(lastkey) = "RETURN"
        then do :
            create tbparavp.
            assign
                tbparavp.datref = input frame f-inc tbparavp.datref
                tbparavp.dtiemis = input frame f-inc tbparavp.dtiemis
                tbparavp.dtfemis = input frame f-inc tbparavp.dtfemis
                tbparavp.natureza = input frame f-inc tbparavp.natureza
                tbparavp.indcod = vindcod
                tbparavp.situacao = "PENDENTE"
                .
        end.
    END.
    else if esqcom1[esqpos1] = "  ALTERA"
    THEN DO :
        if tbparavp.situacao = "PENDENTE"
        THEN DO on error undo:
            update 
                tbparavp.dtiemis 
                tbparavp.dtfemis
                with frame f-linha.
            
            if (tbparavp.dtiemis = ? and tbparavp.dtfemis = ?) or
               (tbparavp.dtfemis = ? and tbparavp.dtiemis <> ? and
                tbparavp.dtiemis <= tbparavp.datref) or
               (tbparavp.dtiemis = ? and tbparavp.dtfemis <> ? and
                tbparavp.dtfemis <= tbparavp.datref)
            then.
            else do:
                bell.
                message color red/with
                "Periodo de emissao invalido."
                view-as alert-box.
                undo.
            end.    

            update    
                tbparavp.natureza 
                tbparavp.indcod  
                   with frame f-linha.
        end.
        if sfuncod = 101
        then update tbparavp.situacao with frame f-linha.
    END.
    else if esqcom1[esqpos1] = "  Cancela"
    then do:
        if tbparavp.situacao = "PENDENTE"
        THEN DO:
            bell.
            sresp = no.
            if tbparavp.natureza
            then message "Confirma CANCELAR parametro PAGAR" 
                        tbparavp.datref "?" update sresp.
            else message "Confirma CANCELAR parametro RECEBER" 
                        tbparavp.datref "?" update sresp.
            if sresp
            then tbparavp.situacao = "CANCELADO".
        end.
        else do:
            bell.
            message color rdd/with
             "Situacao " tbparavp.situacao 
               "impossivel CANCELAR" 
                view-as alert-box.
        end.

                
    end.
    else if esqcom1[esqpos1] = "  Exclui"
    THEN DO:
        /**
        bell.
        sresp = no.
        message "Confirma excluir?" update sresp.
        if sresp
        then delete tbparavp.
        **/
    END.
    end.
    else do:
    if esqcom2[esqpos2] = "    Indicadores"
    THEN DO :
        hide frame f-com1 no-pause.
            hide frame f-com2 no-pause.
            hide frame f1 no-pause.
            hide frame f2 no-pause.
            run cadindic.p.
            esqcom1[esqpos1] = "".
            disp esqcom1 with frame f-com1.
            disp esqcom2 with frame f-com2.
            assign
                a-seeid = -1 a-recid = -1 a-seerec = ?
                esqpos1 = 1 esqpos2 = 1.
            disp  with frame f1.
            disp  with frame f2.
    END.
    else if esqcom2[esqpos2] = "     Simular"
    THEN DO:
        if tbparavp.situacao = "PENDENTE"
        THEN DO:        
            BELL.
            sresp = no.
            message "Confirma SIMULAR calculo AVP ?" update sresp.
            if sresp
            then do:
                if tbparavp.natureza = no
                then do:
                    connect ninja -H db2 -S sdrebninja -N tcp.
                    
                    run receber_calculo_AVP.p(input "SIMULAR",
                                       input recid(tbparavp) ).
                    
                    if connected ("ninja")
                    then disconnect ninja.
                end.
                else do:
                    run pagar_calculo_AVP.p(input "SIMULAR",
                                            input recid(tbparavp)).
                end.
            end.
        end.
        else do:
            bell.
            message color rdd/with
             "Situacao " tbparavp.situacao 
               "impossivel SIMULAR" 
                view-as alert-box.
        end.
    END.
    else if esqcom2[esqpos2] = "    Processar"
    THEN DO:
        if tbparavp.situacao = "PENDENTE"
        then do:
            BELL.
            sresp = no.
            message "Confirma PROCESSAR calculo AVP ?" update sresp.
            if sresp
            then do:
                if tbparavp.natureza = no
                then do:
                    connect ninja -H db2 -S sdrebninja -N tcp.
                    run receber_calculo_AVP.p(input "PROCESSAR",
                                       input recid(tbparavp) ).
                    if connected ("ninja")
                    then disconnect ninja.
                end.
                else do:
                    run pagar_calculo_AVP.p(input "PROCESSAR",
                                        input recid(tbparavp)).
                end.
            end.
        end.        
        else do:
            bell.
            message color rdd/with
             "Situacao " tbparavp.situacao 
               "impossivel PROCESSAR" 
                view-as alert-box.
        end.
    END.
    else if esqcom2[esqpos2] = "   Contabilizar"
    THEN DO:
        if tbparavp.situacao = "PROCESSADO" and
        tbparavp.val1_AVP > 0
        then do:   
             bell.
             sresp = no.
             message "Confirma CONTABILIZAR calculo AVP ?" update sresp.
             if sresp
             then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run contabilizar-AVP.p(input recid(tbparavp)).
                view frame f-com1.
                view frame f-com2.
             end.
        end.
        else do:
            if tbparavp.situacao <> "PROCESSADO"
            then do:
                bell.
                message color rdd/with
                    "Situacao " tbparavp.situacao 
                        "impossivel CONTABILIZAR" 
                        view-as alert-box.
            end.
            else if tbparavp.val1_AVP <= 0
                then do:
                    bell.
                    message color rdd/with
                    "Valor " tbparavp.val5_AVP 
                        "impossivel CONTABILIZAR" 
                        view-as alert-box.
                end.        
        end.
    END.
    end.
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

form with frame f-linha2.

procedure indic-help.

    clear frame f-linha2 all.
    hide frame f-linha2 no-pause.
    {sklcls.i
        &help       = "ENTER=Seleciona F4=Retorna"
        &file       = indic
        &cfield     = indic.inddesc
        &ofield     = " indic.indcod "
        &where      = "true"
        &locktype   = "no-lock"
        &color      = yellow
        &color1     = blue
        &naoexiste1 = "
                    do:
                    message ""Nenhum registro encontrado"" 
                    view-as alert-box.
                   leave keys-loop.
                   end. "
        &aftselect1 = " do:
                    vindcod = indic.indcod.
                   leave keys-loop. 
                   end. " 
        &form       = " frame f-linha2 down column 30
                        title "" selecione um indicador "" 
                        overlay "}

    hide frame f-linha2 no-pause.
    
end procedure.
