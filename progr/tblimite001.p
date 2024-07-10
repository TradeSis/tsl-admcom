{admcab.i}
{setbrw.i}                                                                      

def input parameter tp-tipo as int.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  ALTERA","  INCLUI","",""].
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

find first tblimite where tblimite.tipo_limite = tp-tipo no-lock no-error.

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


def temp-table t-tblimite like tblimite.
/*
    field tipo_limite like tblimite.tipo_limite
    field desc_limite like tblimite.desc_limite
    index i1 tipo_limite
    .
  */
def var vetbnom like estab.etbnom.

form tblimite.campo1 column-label  "Fil"
     vetbnom   
     tblimite.campo2 column-label "Limite"
     tblimite.situacao column-label "Sit"
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
disp "                    " tblimite.desc_limite 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.
def buffer btblimite for tblimite.


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
        &file = tblimite  
        &cfield = tblimite.campo1
        &noncharacter = /* 
        &ofield = " vetbnom
                    tblimite.campo2
                    tblimite.situacao
                    "  
        &aftfnd1 = " find estab where estab.etbcod = tblimite.campo1
                            no-lock no-error.
                     if avail estab
                     then vetbnom = estab.etbnom.
                     else if tblimite.campo1 = 0
                         then vetbnom = ""PARAMETRO GERAL"".
                         else vetbnom = """".    
                            "
        &where  = " tblimite.tipo_limite = tp-tipo "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  INCLUI""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " esqcom1[esqpos1] = ""  INCLUI"".
                        run aftselect. " 
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
    for each t-tblimite. delete t-tblimite. end.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo with frame f-linha:
        scroll from-current down .
        prompt-for tblimite.campo1.
        if input tblimite.campo1 > 0
        then do:
            find estab where estab.etbcod = 
                            input tblimite.campo1 no-lock no-error.
            if not avail estab
            then do:
                bell.
                message color red/with
                "Filial não cadastrada."
                view-as alert-box.
                scroll from-current up.
                undo.
            end.    
        end.    
        prompt-for tblimite.campo2.
        sresp = no.
        message "Confirma incluir?" update sresp.
        if sresp
        then do:
            create btblimite.
            assign
                btblimite.tipo_limite = tblimite.tipo_limite
                btblimite.desc_limite = tblimite.desc_limite
                btblimite.campo1 = input tblimite.campo1
                btblimite.campo2 = input tblimite.campo2
                btblimite.datexp = today
                btblimite.dtinclu = today
                .
        end.
        else undo.             
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        update tblimite.campo2 tblimite.situacao
        with frame f-linha.
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
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

