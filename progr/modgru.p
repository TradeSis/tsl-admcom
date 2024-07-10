{admcab.i} 
{setbrw.i}

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
        .


form bmodgru.modcod column-label "Mod"
     modal.modnom   column-label "Descricao" format "x(25)"
     /*lanaut.lancod column-label "CodCTB"
     lanaut.lanhis column-label "His" format ">>9"*/
     with frame f-linha1 down column 42
     title " Modalidades do Grupo "
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
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        .
    hide frame f-linha no-pause.    
    {sklcls.i
        &help = "ENTER=Marca F1=Modal F4=Sair F8=Imprime F9=Inclui F10=Exclui"
        &file = t-modgru
        &cfield = t-modgru.mognom 
        &ofield  = " t-modgru.modcod vmarca no-label"
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
        &naoexiste = " modgru.in " 
        &abrelinha = " modgru.in "
        &aftselect1 = " /*update /*modgru.modcod*/ 
                        modgru.mognom with frame f-linha. */
                      if keyfunction(lastkey) = ""RETURN""
                      then do:
                        find first tt-modgru 
                               where tt-modgru.mogsup = t-modgru.mogsup and
                                     tt-modgru.mogcod = t-modgru.mogcod and
                                     tt-modgru.modcod = t-modgru.modcod
                                     no-error.
                        if avail tt-modgru
                        then do:
                            delete tt-modgru.
                            vmarca = "" "".
                        end.          
                        else do:
                            create tt-modgru.
                            buffer-copy t-modgru to tt-modgru.
                            vmarca = ""*"".
                        end.       
                        disp vmarca with frame f-linha.
                        next keys-loop.
                      end. 
                    "
        &otherkeys = " modgru.ok "
        &form = " frame f-linha down "
    }
    if keyfunction(lastkey) = "END-ERROR"
    then do:
        hide frame f-linha no-pause.
        leave l1.
    end.
end.
message "Atualizando LP......  Aguarde!".
run atulpfin.p .

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
