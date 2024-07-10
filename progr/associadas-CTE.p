{admcab.i}
{setbrw.i}                                                                      

def input parameter recid-cte as recid.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Exclui "," ","",""].
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


def buffer bplani for plani.

form 
     docrefer.numori format ">>>>>>>>9" column-label "Numero"
     docrefer.etbcod format ">>9"
     docrefer.codedori  format ">>>>>>>>>9" column-label "Emitente"
     forne.fornom format "x(20)" no-label
     docrefer.dtemiori column-label "Emissao"
     bplani.dtinclu column-label "Entrada"
     with frame f-linha row 6 down color with/cyan /*no-box*/
        title " Notas Fiscais associadas "
        width 80
     .
                                                                         
disp "                          CONHECIMENTO DE FRETE       "
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
pause 0.                             

def buffer btbcntgen for tbcntgen.                            
def var i as int.

find plani where recid(plani) = recid-cte no-lock.

disp plani.numero label "Numero Conhecimento" with frame f-c 1 down
                row 5 no-box side-label.
pause 0.
                

l1: repeat:
    clear frame f-com1 all.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    hide frame f-linha no-pause.
    clear frame f-linha all.
    pause 0.
    {sklclstb.i  
        &color = with/cyan
        &file = docrefer  
        &cfield = docrefer.numori
        &noncharacter = /* 
        &ofield = " docrefer.etbcod
                    docrefer.codedori
                    forne.fornom when avail forne
                    docrefer.dtemiori
                    bplani.dtinclu when avail plani
                    "  
        &aftfnd1 = " find first bplani where bplani.etbcod = docrefer.etbcod and
                                      bplani.emite  = docrefer.codedori and
                                      bplani.serie  = docrefer.serieori and
                                      bplani.numero = int(docrefer.numori)
                                      no-lock no-error.
                     find forne where 
                          forne.forcod = docrefer.codedori no-lock no-error. 
                          "
        &where  = " docrefer.etbcod = plani.etbcod and
                    docrefer.codrefer = string(plani.emite) and
                    docrefer.serierefer = plani.serie and
                    docrefer.numerodr   = plani.numero "
        &aftselect1 = " run aftselect.
                        if esqcom1[esqpos1] = ""  exclui""
                        then next l1.
                        next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenum registro encontrado.""
                        view-as alert-box.
                        leave l1.
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
hide frame f-c no-pause.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = " "
    THEN DO on error undo:
    END.
    if esqcom1[esqpos1] = " "
    THEN DO:
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        if not plani.notsit
        then do:
            bell.
            message color red/with
            "Conhecimento " plani.numero " ja FECHADO."
            view-as alert-box.
        end. 
        else do:
            sresp = no.
            message "Confirma EXCLUIR associada " docrefer.numori "?"
            update sresp.
            if sresp
            then do on error undo:
                delete docrefer.
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

