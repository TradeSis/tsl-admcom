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
    initial ["","  Marca","  Confirma","",""].
def var esqcom2         as char format "x(15)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

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

def temp-table tt-plani like plani
    field marca as char format "X".

form tt-plani.marca no-label
     tt-plani.numero format ">>>>>>>>9" column-label "Numero"
     tt-plani.etbcod format ">>9"
     tt-plani.emite  format ">>>>>>>>>9" column-label "Emitente"
     forne.fornom format "x(20)" no-label
     tt-plani.pladat column-label "Emissao"
     tt-plani.dtinclu column-label "Entrada"
     with frame f-linha row 6 down color with/cyan /*no-box*/
        title " Marque as NFs e confirme para associar "
        width 80
     .
                                                                         
disp "                          CONHECIMENTO DE FRETE       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
pause 0.                             

def buffer btbcntgen for tbcntgen.                            

def var i as int.

def buffer bplani for plani.
def buffer bmovim for movim.
def buffer bprodu for produ.

find plani where recid(plani) = recid-cte no-lock.

disp plani.numero label "Numero Conhecimento" with frame f-c 1 down
                row 5 no-box side-label.
pause 0.
                
for each bplani where
         bplani.movtdc  = 4   and
         bplani.etbcod  = plani.etbcod and
         bplani.respfre = yes and
         bplani.dtincl  > today - 5 /*and
         bplani.notsit      */
          no-lock,
    first bmovim where bmovim.etbcod = bplani.etbcod and
                      bmovim.placod = bplani.placod and
                      bmovim.movtdc = bplani.movtdc and
                      bmovim.movdat = bplani.pladat
                      no-lock,
    first bprodu where bprodu.procod = bmovim.procod and
                      bprodu.catcod = 41
                      no-lock
          :
    
    find first docrefer where
               docrefer.numori      = bplani.numero and
               docrefer.serieori    = bplani.serie  and
               docrefer.codedori    = bplani.emite  and
               docrefer.dtemiori    = bplani.pladat
               no-lock no-error.
    
    if not avail docrefer
    then do: 
        create tt-plani.
        buffer-copy bplani to tt-plani.
    end.
end.          
pause 0.

l1: repeat:
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
        &file = tt-plani  
        &cfield = tt-plani.numero
        &noncharacter = /* 
        &ofield = " tt-plani.marca
                    tt-plani.etbcod
                    tt-plani.emite
                    forne.fornom when avail forne
                    tt-plani.pladat
                    tt-plani.dtinclu
                    "  
        &aftfnd1 = " find forne where 
                          forne.forcod = tt-plani.emite no-lock. "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        if esqcom1[esqpos1] = ""  Confirma""
                        then leave keys-loop.
                        next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " message ""Nenhum registro encontrato"" 
                            view-as alert-box.
                        leave l1. " 
        &otherkeys1 = " run controle. "
        &locktype = " no-lock "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
    if esqcom1[esqpos1] = "  Confirma"
    then do:
        leave l1.
    end.
end.
hide frame f-c no-pause.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  marca"
    THEN DO on error undo:
        if tt-plani.marca = ""
        then tt-plani.marca = "*".
        else tt-plani.marca = "".
        disp tt-plani.marca with frame f-linha.
    END.
    if esqcom1[esqpos1] = "  confirma"
    THEN DO:
        run associa-CTR-NF.
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

procedure associa-CTR-NF:
    for each tt-plani where tt-plani.marca = "*":
        create docrefer.
        assign
            docrefer.etbcod      = plani.etbcod
            docrefer.tiporefer   = plani.movtdc
            docrefer.tipmov      = "E"
            docrefer.tipoemi     = "T"
            docrefer.tipmovref   = "E"
            docrefer.modelorefer = ""
            docrefer.serierefer  = plani.serie
            docrefer.numerodr    = plani.numero
            docrefer.codrefer    = string(plani.emite)
            docrefer.modeloori   = ""
            docrefer.numori      = tt-plani.numero
            docrefer.serieori    = tt-plani.serie
            docrefer.codedori    = tt-plani.emite
            docrefer.dtemiori    = tt-plani.pladat
            docrefer.datadr      = plani.pladat
            docrefer.datexp      = today
            
            .
        delete tt-plani.
    end. 
end procedure.
