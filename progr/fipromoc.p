/*
*
*    Esqueletao de Programacao
*
*/

{admcab.i}
{difregtab.i new}
def input parameter p-rec as recid.

def var vmes as int.
def var vano as int.
def var vdesmes as char format "x(10)" extent 12
    init["Janeiro","Fevereiro","Marco","Abril","Maio","Junho",
         "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].

def temp-table tt-caixa
    field cxacod like caixa.cxacod
    .
def var vdti as date.
def var vdtf as date.
def var vdtauxi as date.
def var vdtauxf as date.
def buffer bctpromoc for ctpromoc.
def buffer dctpromoc for ctpromoc.
find bctpromoc where recid(bctpromoc) = p-rec no-lock. 

form ctpromoc.etbcod
     estab.etbnom
     ctpromoc.situacao  no-label format "!"
                validate(ctpromoc.situacao = "I" or
                                 ctpromoc.situacao = "A" or
                                 ctpromoc.situacao = "E"
                                 ,"Informe Corretamente")
     help "Informe:  A=Ativo  I=Inativo  E=Exceto"
     with frame f-linha.

{setbrw.i}
bl-princ:
repeat:
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        .
    hide frame f-linha no-pause.
    {sklcls.i
        &help = "ENTER=Altera F8=Caixa I =Inclui E =Exclui"
        &file = ctpromoc
        &cfield = ctpromoc.etbcod
        &noncharacter = /*
        &ofield = " estab.etbnom  format ""x(20)""  
                    when avail estab 
                    ctpromoc.situacao "
        &where = " ctpromoc.sequencia = bctpromoc.sequencia and
                   ctpromoc.etbcod > 0
                 "
        &aftfnd1 = " find estab where
                        estab.etbcod = ctpromoc.etbcod
                        no-lock no-error.
                  "
        &naoexiste1 = "
            /*if bctpromoc.situacao = ""M""
            then.
            else do:
                message color red/with 
                 ""Nenhum registro encontrado.""
                    view-as alert-box.
                leave bl-princ.
            end.
            */
            sresp = no.
            message
            ""Nenhuma Filial cadastrada para Promocao. Deseja Cadstrar ?""
            update sresp.
            if not sresp  
            then leave bl-princ.
            run inclui.
            hide frame f-linha no-pause.
            next bl-princ.
            "
        &aftselect1 = "
            if keyfunction(lastkey) = ""RETURN""
            THEN DO:
                color disp message estab.etbnom with frame f-linha.
                update ctpromoc.situacao with frame f-linha.
            END.         "
        &otherkeys1 = "
            find ctpromoc where recid(ctpromoc) = a-seerec[frame-line].
            if keyfunction(lastkey) = ""clear""
            then do:
                color disp message estab.etbnom with frame f-linha.
                run in-caixa.
                next bl-princ.
            end.
            
            if keyfunction(lastkey) = ""new-line""  or
               keyfunction(lastkey) = ""INSERT-MODE"" or
               keyfunction(lastkey) = ""I""
            then do:
                /*if bctpromoc.situacao = ""M""
                then.
                else next keys-loop.
                */
                color display normal
                      ctpromoc.etbcod with frame f-linha.
                run inclui. 
                hide frame f-linha no-pause.
                next bl-princ.
            end.
            if keyfunction(lastkey) = ""DELETE-LINE"" or
               keyfunction(lastkey) = ""CUT"" or
               keyfunction(lastkey) = ""E""
            then do:
                if bctpromoc.situacao = ""M""
                then.
                else next keys-loop.

                sresp = no.
                message ""Confirma excluir da promocao a Filial"" 
                 ctpromoc.etbcod ""?"" update sresp.
                if sresp 
                then do:
                    create table-raw.
                    raw-transfer ctpromoc to table-raw.registro2.
                    run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(ctpromoc), input ""ADM"",
                                    input ""ctpromoc"", 
                                    input ""EXCLUI-FILIAL"").
 
                    delete ctpromoc.
                    hide frame f-linha no-pause.
                    next bl-princ.
                end.
                next keys-loop.
            end.
            "
        &form   = " frame f-linha 10 down row 7 overlay
                    title "" Filiais da promocao "" 
                    color with/cyan width 35 no-label "
    }                        
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-linha no-pause.
        leave bl-princ.
    end.     
end.

procedure inclui.
    repeat on endkey undo, leave:
        find last dctpromoc where
                    dctpromoc.sequencia = bctpromoc.sequencia 
                    no-lock no-error.

        scroll from-current down with frame f-linha.
        create ctpromoc.
        assign
            ctpromoc.promocod = bctpromoc.promocod
            ctpromoc.sequencia = bctpromoc.sequencia
            ctpromoc.linha     = dctpromoc.linha + 1
            ctpromoc.fincod = ?
            ctpromoc.situacao = "A"
            .
        do on error undo:
            update  ctpromoc.etbcod  with frame f-linha.
            find estab where estab.etbcod = ctpromoc.etbcod
                no-lock no-error.
            if not avail estab
            then do:
                message color red/with
                    "Filial " ctpromoc.etbcod " nao cadastrada." 
                    view-as alert-box.
                undo.
            end.
        
            disp estab.etbnom with frame f-linha.
            update ctpromoc.situacao with frame f-linha.
        end.
        create table-raw.
        raw-transfer ctpromoc to table-raw.registro2.
        run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(ctpromoc), input "ADM",
                                    input "ctpromoc", 
                                    input "INCLUI-FILIAL").
    end.
            
end procedure.

procedure in-caixa:
    def var vi as int.
    for each tt-caixa:
        delete tt-caixa.
    end.
    do vi = 1 to 100:
        if ctpromoc.cxacod[vi] = 0
        then leave.
        
        create tt-caixa.
        tt-caixa.cxacod = ctpromoc.cxacod[vi].
    end.
    bl1: repeat:
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        .
    hide frame f-linha1 no-pause.
    {sklcls.i
        &help = "                                   I = Inclui  E = Exclui"
        &file = tt-caixa
        &cfield = tt-caixa.cxacod
        &noncharacter = /*
        &ofield = caixa.cxanom
        &where = true
        &aftfnd1 = " find caixa where 
                          caixa.etbcod = ctpromoc.etbcod and
                          caixa.cxacod = tt-caixa.cxacod
                          no-lock no-error.
                  "
        &naoexiste1 = "
            if bctpromoc.situacao = ""M""
            then.
            else do:
                message color red/with
                    ""Nenhum registro encontrado.""
                    view-as alert-box.
                leave bl1.
            end.
            sresp = no.
            message
            ""Nenhum Caixa encontrado para Promocao. Deseja Incluir ?""
            update sresp.
            if not sresp
            then leave bl1.
            repeat on endkey undo, leave:
        scroll from-current down with frame f-linha1.
        create tt-caixa.
        do on error undo:
            update  tt-caixa.cxacod  with frame f-linha1.
            find caixa where caixa.etbcod = ctpromoc.etbcod    and
                             caixa.cxacod = tt-caixa.cxacod
                no-lock no-error.
            if not avail caixa
            then do:
                message color red/with
                    ""Caixa "" tt-caixa.cxacod "" nao cadastrada."" 
                    view-as alert-box.
                undo.
            end.
        
            disp caixa.cxanom with frame f-linha1.
        end.
   end.
            hide frame f-linha1 no-pause.
            next bl1.
            "
        &otherkeys1 = "
            find tt-caixa where recid(tt-caixa) = a-seerec[frame-line].
            if keyfunction(lastkey) = ""new-line"" OR
               keyfunction(lastkey) = ""INSERT-MODE"" or
               keyfunction(lastkey) = ""I""
            then do:
                if bctpromoc.situacao = ""M""
                then.
                else next keys-loop.

                color display normal
                      tt-caixa.cxacod with frame f-linha.
                repeat on endkey undo, leave:
        scroll from-current down with frame f-linha1.
        create tt-caixa.
        do on error undo:
            update  tt-caixa.cxacod  with frame f-linha1.
            find caixa where caixa.etbcod = ctpromoc.etbcod    and
                             caixa.cxacod = tt-caixa.cxacod
                no-lock no-error.
            if not avail caixa
            then do:
                message color red/with
                    ""Caixa "" tt-caixa.cxacod "" nao cadastrada."" 
                    view-as alert-box.
                undo.
            end.
        
            disp caixa.cxanom with frame f-linha1.
        end.
   end.

                hide frame f-linha1 no-pause.
                next bl1.
            end.
            if keyfunction(lastkey) = ""DELETE-LINE"" or
               keyfunction(lastkey) = ""CUT"" or
               keyfunction(lastkey) = ""E""
            then do:
                if bctpromoc.situacao = ""M""
                then.
                else next keys-loop.
                sresp = no.
                message ""Confirma excluir da promocao o caixa ""
                        tt-caixa.cxacod "" da Filial"" 
                 ctpromoc.etbcod ""?"" update sresp.
                if sresp 
                then do:
                    delete tt-caixa.
                    hide frame f-linha1 no-pause.
                    next bl1.
                end.
                next keys-loop.
            end.
            "
        &form   = " frame f-linha1 10 down column 40 row 7 
                    title "" Caixas da promocao Filial "" +
                        string(ctpromoc.etbcod) + "" "" 
                    color with/cyan width 40 no-label overlay"
    } 
    if keyfunction(lastkey) = "end-error"
    then do:
        ctpromoc.cxacod = 0.
        vi = 0.
        for each tt-caixa where
                 tt-caixa.cxacod > 0 
                 no-lock break by tt-caixa.cxacod.
            vi = vi + 1.
            ctpromoc.cxacod[vi] = tt-caixa.cxacod.
        end.

        hide frame f-linha1 no-pause.
        leave bl1.   
    end.    
    end.
end procedure.    
        
procedure inclui-cxa.
    repeat on endkey undo, leave:
        scroll from-current down with frame f-linha1.
        create tt-caixa.
        do on error undo:
            update  tt-caixa.cxacod  with frame f-linha1.
            find caixa where caixa.etbcod = ctpromoc.etbcod    and
                             caixa.cxacod = tt-caixa.cxacod
                no-lock no-error.
            if not avail caixa
            then do:
                message color red/with
                    "Caixa " tt-caixa.cxacod " nao cadastrada." 
                    view-as alert-box.
                undo.
            end.
        
            disp caixa.cxanom with frame f-linha1.
        end.
   end.
            
end procedure.

