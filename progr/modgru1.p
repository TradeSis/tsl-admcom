{admcab.i}
{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqpos3         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  MARCA","  MODAL","  INCLUI","  EXCLUI"].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","  IMPRIME","","",""].
def var esqcom3         as char format "x(15)" extent 5
    initial [" INCLUI", " EXCLUI", " "," "," "].
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
def var esqhel3         as char format "x(12)" extent 5
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
form
    esqcom3
    with frame f-com3
                 row 3 no-box no-labels side-labels column 1
                 centered.                 
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

/*
disp "                         GRUPOS DE MODALIDADES       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
*/
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def buffer bmodgru for modgru.
def buffer cmodgru for modgru.
def buffer dmodgru for modgru.
def var vmarca as char format "!".
def temp-table tt-modgru like modgru.
def temp-table t-modgru like modgru
            index i1 mognom.
form    vmarca no-label  
        t-modgru.modcod 
        t-modgru.mognom column-label "Descricao" 
        with  frame f-linha
        title " Grupos de Modalidades "
        11 down row 5 width 43
        .

form bmodgru.modcod column-label "Mod"
     modal.modnom   column-label "Descricao" format "x(25)"
     /*lanaut.lancod column-label "CodCTB"
     lanaut.lanhis column-label "His" format ">>9"*/
     with frame f-linha1 column 45
     title " Modalidades do Grupo "
     11 down row 5

     .

l1: repeat:
    
    for each tt-modgru:
        delete tt-modgru.
    end.    
    for each t-modgru:
        delete t-modgru.
    end.
    for each modgru where modgru.mogsup = 0 no-lock
            break by mognom:
        create t-modgru.
        buffer-copy modgru to t-modgru.
    end. 
    hide frame esqcom1 no-pause.
    hide frame esqcom2 no-pause.

    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    PAUSE 0.

    hide frame f-linha no-pause.
    clear frame f-linha all.

    {sklclstb.i  
        &color = with/cyan
        &file = t-modgru
        &cfield = t-modgru.mognom 
        &ofield  = " t-modgru.modcod vmarca no-label "
        &where = " t-modgru.mogsup = 0 "
        &aftfnd1 = "         find first tt-modgru 
                               where tt-modgru.mogsup = t-modgru.mogsup and
                                     tt-modgru.mogcod = t-modgru.mogcod and
                                     tt-modgru.modcod = t-modgru.modcod
                                     no-error.
            if avail tt-modgru
            then vmarca = ""*"".
            else vmarca = """". 
            "
 
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  INCLUI""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  " 
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
    def buffer bmodgru for modgru.
    if keyfunction(lastkey) = "END-ERROR"   
    then do:
        hide frame f-com3.
        view frame f-com1.
        view frame f-com2.
    end.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        {modgru.in}
    END.
    if esqcom1[esqpos1] = "  MODAL"
    THEN DO:
        run modal.
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        find first bmodgru where bmodgru.mogsup = t-modgru.mogcod
        no-lock no-error.
    if avail bmodgru
    then do:
        message color red/with
            "Grupo tem modalidade associada" skip
            "exclusao nao permitida"
            view-as alert-box.
    end.
    else do:
        sresp = no.
        message "Confirma excluir grupo " t-modgru.mognom update sresp.
        if not sresp 
        then .
        else do:
        find modgru where modgru.mogsup = t-modgru.mogsup and
                          modgru.mogcod = t-modgru.mogcod and
                          modgru.modcod = t-modgru.modcod
                          no-error.
        if avail modgru
        then delete modgru.
        end.
    end. 
        
    END.
    if esqcom2[esqpos2] = "  IMPRIME"
    THEN DO on error undo:
        run relatorio.
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
    def buffer cmodgru for modgru.
    def buffer dmodgru for modgru.
    def var vlinha as char.
    def var varquivo as char.
    def var vmodcod like modgru.modcod .
    
    find first tt-modgru where 
               tt-modgru.modcod <> "" no-error.
    if not avail tt-modgru
    then do:
        for each tt-modgru: delete tt-modgru. end.
        FOR EACH MODGRU NO-LOCK:
            create tt-modgru.
            buffer-copy modgru to tt-modgru.
        end.    
    end.           
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/modgru." + string(time).
    else varquivo = "l:\relat\modgru.txt".
    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "80"
            &Page-Line = "64"
            &Nom-Rel   = ""modgru""
            &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A PAGAR"""
            &Tit-Rel   = """ GRUPOS E SUAS MODALIDADES """
            &Width     = "80"
            &Form      = "frame f-cabcab"}
     for each tt-modgru where tt-modgru.modcod <> "",
         first cmodgru where cmodgru.mogsup = 0 and
                             cmodgru.mogcod = tt-modgru.mogcod
                              no-lock:
        vlinha = cmodgru.modcod + " - " + cmodgru.mognom .
        put vlinha format "x(70)" skip.
        for each dmodgru where dmodgru.mogsup = cmodgru.mogcod no-lock:
            find modal where 
                 modal.modcod = dmodgru.modcod
                 no-lock.
            vlinha =  dmodgru.modcod + " - " +
                 modal.modnom .
            put "      " vlinha format "x(70)" skip.
        end.
        put fill("-",60) format "x(60)" skip.
    end.
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
    for each tt-modgru:
        delete tt-modgru.
    end.    
end procedure.

procedure modal:

esqpos3 = 1.
disp esqcom3 with frame f-com3.
hide frame f-com1.
hide frame f-com2.

    l2: repeat:
    i-seeid = a-seeid.
    i-recid = a-recid.
    
    hide frame f-linha1 no-pause.
    clear frame f-linha1 all.
    a-seeid = -1. a-recid = -1. a-seerec = ?.
    
    {sklcls.i
        &help = "F4=Retorna"
        &file = bmodgru
        &cfield = bmodgru.modcod
        &ofield  = " modal.modnom when avail modal 
                     /*lanaut.lancod when avail lanaut
                     lanaut.lanhis when avail lanaut*/ 
                     "
        &aftfnd1 = "
            find modal where modal.modcod = bmodgru.modcod
                            no-lock no-error.
            find first lanaut where lanaut.etbcod  = ? and
                                    lanaut.forcod  = ? and
                                    lanaut.modcod  = bmodgru.modcod
                                    no-lock no-error.
                    "        
        &where = " bmodgru.mogsup = t-modgru.mogcod "
        &naoexiste1 = " run inclui. "
        &aftselect1 = " run aftselect1(recid(bmodgru)).
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  INCLUI""
                        then do:
                            next l2.
                        end.
                        else next keys-loop. "
        &otherkeys1 = " run controle1. "
                  
        &form = " frame f-linha1 "
    }
    /*        &otherkeys = " bmodgru.ok "*/

    if keyfunction(lastkey) = "END-ERROR"
    then do:
        hide frame f-linha1 no-pause.
        hide frame f-com3.
        view frame f-com1.
        view frame f-com2.
        leave l2.
    end.
    end.
end procedure.

procedure controle1:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos3 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom3[ve] with frame f-com3.
                    end.
                end.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom3[esqpos3] with frame f-com3.
                    esqpos3 = if esqpos3 = 5 then 5 else esqpos3 + 1.
                    color display messages esqcom3[esqpos3] with frame f-com3.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom3[esqpos3] with frame f-com3.
                    esqpos3 = if esqpos3 = 1 then 1 else esqpos3 - 1.
                    color display messages esqcom3[esqpos3] with frame f-com3.
                end.
                next.
            end.
end procedure.

procedure aftselect1:
    def input parameter r-recid as recid.
    clear frame f-linha1 all.
    def buffer bmodgru for modgru.
    if keyfunction(lastkey) = "END-ERROR"   
    then do:
        hide frame f-com1.
        hide frame f-com2.
        view frame f-com3.
    end.
    
    if esqcom3[esqpos3] = " INCLUI"
    THEN DO on error undo:
        {bmodgru.in}
    END.
    if esqcom3[esqpos3] = " EXCLUI"
    THEN DO:
        find bmodgru where recid(bmodgru) = r-recid no-error.
        if avail bmodgru
        then do:
        sresp = no.
        message "Confirma excluir " bmodgru.modcod update sresp.
        if sresp = yes
        then do:
            
            delete bmodgru.
        end.
        end.
    END.

end procedure.

procedure inclui.
    {bmodgru.in}
end.
