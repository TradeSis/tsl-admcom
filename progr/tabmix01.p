{admcab.i}
{setbrw.i}              
{difregtab.i new}

def new shared var sexclui as log init no.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  INCLUI","  ALTERA","  EXCLUI"," OUTRAS OPCOES"].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","  PRODUTOS","  CLASSES","  FILIAIS","COPIA PADRAO"].

{segregua.i}

form
    esqcom1
    with frame f-com1 row 3 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels column 1 centered.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

form " " 
    tabmix.codmix column-label "" format ">>9"
    tabmix.descmix column-label "Descricao" format "x(40)"
    tabmix.etbcod column-label "Filial Base" format ">>9"
    tabmix.campolog1 column-label "Diferenciado" format "Sim/Nao"
    " "
    with frame f-linha 10 down color with/cyan /*no-box*/ centered.                                                                                             
disp "                         TABELA CONTROLE DE MIX       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

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
        &file = tabmix  
        &cfield = tabmix.descmix
        &ofield = " tabmix.codmix
                    tabmix.etbcod 
                    tabmix.campolog1 "  
        &aftfnd1 = " "
        &where  = " tabmix.tipomix = ""M"" use-index indx-2 "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        disp with frame f1.
                        disp with frame f2.
                        disp with frame f-com1.
                        disp with frame f-com2.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  EXCLUI"" 
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " 
            do on error undo, retry with frame f-linha:
                prompt-for 
                    tabmix.descmix.
                    
                do on error undo, retry: 
                    prompt-for tabmix.etbcod.
                    find estab where 
                        estab.etbcod = input frame f-linha tabmix.etbcod 
                            no-lock no-error.
                    if not avail estab
                    then do:
                        message ""Filial nao cadatrada"".
                        pause.
                        undo, retry.
                    end.        
                end.
                create tabmix.
                assign
                    tabmix.tipomix = ""M""
                    tabmix.codmix  = 1
                    tabmix.descmix = input frame f-linha tabmix.descmix
                    tabmix.etbcod  = input frame f-linha tabmix.etbcod.
            end.
            next l1.
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
    def buffer btabmix for tabmix.
    if esqcom1[esqpos1] = "  INCLUI" or
       esqcom1[esqpos1] = "INCLUI"
    THEN DO on error undo, retry with frame f-linha:
        scroll from-current down.
                prompt-for 
                    tabmix.descmix.
                    
                do on error undo, retry: 
                    prompt-for tabmix.etbcod.
                    find estab where 
                        estab.etbcod = input frame f-linha tabmix.etbcod 
                            no-lock no-error.
                    if not avail estab
                    then do:
                        message "Filial nao cadatrada".
                        pause.
                        undo, retry.
                    end.        
                end.
                find last btabmix where
                          btabmix.tipomix = "M" /*and
                          btabmix.codmix < 99*/ no-lock.
                create tabmix.
                assign
                    tabmix.tipomix = "M"
                    tabmix.codmix  = btabmix.codmix + 1
                    tabmix.descmix = input frame f-linha tabmix.descmix
                    tabmix.etbcod  = input frame f-linha tabmix.etbcod.

                 create table-raw.
                 raw-transfer tabmix to table-raw.registro2.
                 run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "INCLUI").
         
         a-recid = recid(tabmix).
    END.
    if esqcom1[esqpos1] = "  ALTERA" or
       esqcom1[esqpos1] = "ALTERA"
    THEN DO:
        create table-raw.
        raw-transfer tabmix to table-raw.registro1.
        run grava-tablog.p (input 1, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "ALTERA").
 
        update tabmix.descmix
               tabmix.etbcod 
               tabmix.campolog1 with frame f-linha. 

        raw-transfer tabmix to table-raw.registro2.
        run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "ALTERA").
    
        a-recid = recid(tabmix).
    END.
    if esqcom1[esqpos1] = "  EXCLUI" or
       esqcom1[esqpos1] = "EXCLUI"
    THEN DO:
/***
        find first btabmix where 
                   btabmix.tipomix = "F" and
                   btabmix.codmix = tabmix.codmix
                   no-lock no-error.
        if not avail btabmix
        then do:
***/
            sresp = no.
            message "Confirma excluir MIX " tabmix.codmix "?" update sresp.
            if sresp
            then do:

                create table-raw.
                raw-transfer tabmix to table-raw.registro2.
                run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "EXCLUI").
 
                for each btabmix where btabmix.codmix = tabmix.codmix .
                    delete btabmix.
                end.
            end.
/***
        end.           
        else do:
            message color red/with
            "Excluir primeiro FILIAIS associados ao MIX.
            "  view-as alert-box.
        end.
***/
    END.
    if esqcom1[esqpos1] = " OUTRAS OPCOES"
    THEN DO on error undo, retry with frame f-linha:
        run outmix01.p(input tabmix.codmix).
        a-recid = recid(tabmix).
    end.
    if esqcom2[esqpos2] = "  PRODUTOS" or
       esqcom2[esqpos2] = "PRODUTOS"
    THEN DO on error undo:
        RUN promix01.p (input tabmix.codmix).
        a-recid = recid(tabmix).
    END.
    if esqcom2[esqpos2] = "  CLASSES" or
       esqcom2[esqpos2] = "CLASSES"
    THEN DO on error undo:
        RUN clamix01.p (input tabmix.codmix).
        a-recid = recid(tabmix).
    END.
    if esqcom2[esqpos2] = "  FILIAIS" or
       esqcom2[esqpos2] = "FILIAIS"
    THEN DO on error undo:
        RUN filmix01.p (input tabmix.codmix).
        a-recid = recid(tabmix).
    END.
    if esqcom2[esqpos2] = "COPIA PADRAO"
    THEN DO on error undo:
        RUN copmix01.p.
        a-recid = recid(tabmix).
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

