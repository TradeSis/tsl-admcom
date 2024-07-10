{admcab.i}
{setbrw.i}

def var vtipo   as char.
def var vcodigo as int.
def var vcobertura like prontaentrega.cobertura.

form with frame f-cobertura side-label.


def buffer p-produ for produ.
def buffer p-classe for clase.
def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5.

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer depto for clase.
def buffer setor for clase.
def buffer grupo for clase.
def buffer subclasse for clase. 
def buffer rclase for clase.

def buffer clase0 for clase.
def buffer clase1 for clase.
def buffer clase2 for clase.
def buffer clase3 for clase.
def buffer clase4 for clase.

form depto.clacod format ">>>>>>>>9" no-label
     depto.clanom format "x(25)" no-label
     ProntaEntrega.PEntrega  no-label
     ProntaEntrega.cobertura no-label
     with frame f-depto 13 Down color 
     centered title "   DEPARTAMENTOS  " .

form setor.clacod format ">>>>>>>>9" no-label
     setor.clanom format "x(25)" no-label
     ProntaEntrega.PEntrega  no-label
     ProntaEntrega.cobertura no-label
     with frame f-setor 13 Down color 
     centered title "   SETORES  " .

form grupo.clacod format ">>>>>>>>9" no-label
     grupo.clanom format "x(25)" no-label
     ProntaEntrega.PEntrega  no-label
     ProntaEntrega.cobertura no-label
     with frame f-GRUPO 13 Down color 
     centered title "   GRUPOS  " .

form clase.clacod format ">>>>>>>>9" no-label
     clase.clanom format "x(25)" no-label
     ProntaEntrega.PEntrega  no-label
     ProntaEntrega.cobertura no-label
     with frame f-classe 13 Down color 
     centered title "   CLASSES  " .

form subclaSse.clacod format ">>>>>>>>9" no-label
     subclaSse.clanom format "x(25)" no-label
     ProntaEntrega.PEntrega  no-label
     ProntaEntrega.cobertura no-label
     with frame f-subclasse 13 Down color 
     centered title "   SUB-CLASSES  " .

form produ.procod format ">>>>>>>>9" no-label
     produ.pronom format "x(25)" no-label
     ProntaEntrega.PEntrega  no-label
     ProntaEntrega.cobertura no-label
     with frame f-produto 13 Down color 
     centered title "   PRODUTOS   " .

def var vclacod like clase.clacod.
def var vclasup like clase.clasup.
def var vclanom like clase.clanom.
def var vclagrau like clase.clagrau.
def var vsupcla like clase.clasup.
def var vgraucla like clase.clagrau.
 
def buffer inc-clase for clase.
def buffer sup-clase for clase.
def buffer alt-clase for clase.
                       
form skip(1) vclacod at 4 format ">>>>>>>>9" label "Codigo"
     vclanom at 1 format "x(25)" label "Descricao"
     with frame f-inclui 1 down  overlay title "    INCLUIR   "
     side-label row 10 color message.
     
disp "=============================    C L A S S E S   "
     "============================="
            with frame f1 1 down width 80                                       
             no-box no-label row 4.
                                                  
disp "=======================================" + 
     "======================================="
    with frame f2 1 down width 80  no-box no-label            
    row 20.                                                                     

def var i as int.

l0: repeat:
    esqcom1 = "".
    assign
        esqcom1[1] = "  SETORES"
        esqcom1[2] = " Incluir PA"
        esqcom1[3] = " Alterar PA"
        esqcom1[4] = " Excluir PA".
    clear frame f-com1 all.
    disp esqcom1 with frame f-com1.
    assign
         a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1.
    hide frame f-depto no-pause.
    clear frame f-depto all.
    color display message esqcom1[esqpos1] with frame f-com1.
    {sklclstb.i  
        &file = depto
        &cfield = depto.clacod
        &noncharacter = /* 
        &ofield = " depto.clanom
                ProntaEntrega.Pentrega  when avail ProntaEntrega
                ProntaEntrega.cobertura when avail ProntaEntrega"
        &aftfnd1 = "find ProntaEntrega
                                where ProntaEntrega.Tipo   = ""C""
                                  and ProntaEntrega.Codigo = depto.clacod
                           no-lock no-error."
        &where  = " depto.clacod = 100000000 and
                    depto.clasup = 0 
                    USE-INDEX ICLACOD NO-LOCK"
        &aftselect1 = " find first rclase where rclase.clacod = depto.clacod
                                   no-lock. 
                        vtipo   = ""C"".
                        vcodigo = depto.clacod.
                        run aftselect.
                        hide frame f-cobertura no-pause.
                        a-seeid = -1.
                        a-recid = recid(depto).
                        if esqcom1[esqpos1] = ""  relatorios""
                        then next keys-loop.
                        else next l0."
        &naoexiste1 = " " 
        &otherkeys1 = "run controle."
        &locktype = " "
        &form   = " frame f-depto "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l0.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  setores"
    THEN DO on error undo:
        vsupcla = depto.clacod.
        vgraucla = 1.
        run setor.
    END.
    if esqcom1[esqpos1] = "  grupos "
    THEN DO on error undo:
        vsupcla = setor.clacod.
        vgraucla = 2.
        run grupo.
    END.
    if esqcom1[esqpos1] = "  classes "
    THEN DO on error undo:
        vsupcla = grupo.clacod.
        vgraucla = 3.
        run classe .
    END.
    if esqcom1[esqpos1] = "sub-classes "
    THEN DO on error undo:
        vsupcla = clase.clacod.
        vgraucla = 4.
        run subclasse .
    END.
    if esqcom1[esqpos1] = " produtos "
    THEN DO on error undo:
        run produto.
    END.
    if esqcom1[esqpos1] = "  RELATORIOS "
    THEN DO on error undo:
        run relatorio.
    END.
    if esqcom1[esqpos1] = " Incluir PA"
    THEN DO on error undo with frame f-cobertura side-label:
        find ProntaEntrega where ProntaEntrega.Tipo   = vtipo
                             and ProntaEntrega.Codigo = vcodigo
                           no-lock no-error.
        if avail ProntaEntrega
        then do.
            message "Pronta Entrega ja cadastrada" view-as alert-box.
            undo.
        end.
        disp yes @ ProntaEntrega.Pentrega.
        prompt-for ProntaEntrega.Pentrega
            ProntaEntrega.cobertura.
        
        create ProntaEntrega.
        assign
            ProntaEntrega.Tipo   = vtipo
            ProntaEntrega.Codigo = vcodigo
            ProntaEntrega.Pentrega  = input ProntaEntrega.Pentrega
            ProntaEntrega.Cobertura = input ProntaEntrega.cobertura.
    END.

    if esqcom1[esqpos1] = " Alterar PA"
    THEN DO on error undo with frame f-cobertura side-label:
        find ProntaEntrega where ProntaEntrega.Tipo   = vtipo
                             and ProntaEntrega.Codigo = vcodigo
                           no-error.
        if not avail ProntaEntrega
        then do.
            message "Pronta Entrega nao cadastrada" view-as alert-box.
            undo.
        end.
        update
            ProntaEntrega.Pentrega
            ProntaEntrega.cobertura.
    end.                    

    if esqcom1[esqpos1] = " Excluir PA"
    THEN DO on error undo with frame f-cobertura side-label:
        find ProntaEntrega where ProntaEntrega.Tipo   = vtipo
                             and ProntaEntrega.Codigo = vcodigo
                           no-error.
        if not avail ProntaEntrega
        then do.
            message "Pronta Entrega nao cadastrada" view-as alert-box.
            undo.
        end.
        message "Confirma Exclusao?" update sresp.
        if sresp
        then delete ProntaEntrega.
    end.
end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
end ~procedure.              

procedure relatorio:
    def var vindex as int.
    def var tipo-rel as char extent 5 format "x(25)".
    tipo-rel[1] = "SELECIONADO".
    tipo-rel[2] = "SELECIONADO COM PRODUTOS".
    tipo-rel[3] = "GERAL".
    tipo-rel[4] = "GERAL COM PRODUTOS".
    
    vindex = 0.
    
    repeat on endkey undo, leave:
    
        disp tipo-rel with frame f-rel 1 down  side-labe no-label
            column 53 row 4  overlay
            .
        choose field tipo-rel with frame f-rel .
        vindex = frame-index.
        leave.    
    
    end.
    
    hide frame f-rel.
    
    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/classes." + string(time).
    else varquivo = "..~\relat~\classes." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "160"  
                &Cond-Var  = "160" 
                &Page-Line = "160" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """TITULO""" 
                &Width     = "160"
                &Form      = "frame f-cabcab"}

    if vindex = 1 or vindex = 2
    then do:

        if rclase.clagrau = 0
        then do with frame f11-1:   
        disp "DEPARTAMENTO" skip
             "  SETOR" skip
             "    GRUPO" skip
             "      CLASSE" skip
             "        SUB-CLASSE AQUI" SKIP.

        if vindex = 2
            then disp "          PRODUTOS".


        for each clase0 where clase0.clasup = 0 and
                              clase0.clacod = rclase.clacod  no-lock:
            disp clase0.clacod no-label
                 clase0.clanom no-label format "x(30)".
            for each clase1 where
                clase1.clasup = clase0.clacod no-lock:
                disp "  " clase1.clacod no-label
                    clase1.clanom no-label format "x(30)".
                for each clase2 where
                    clase2.clasup = clase1.clacod no-lock:
                    disp "                " clase2.clacod no-label
                        clase2.clanom no-label format "x(30)".
                    for each clase3 where
                        clase3.clasup = clase2.clacod no-lock:
                        disp "                              " clase3.clacod no-label
                           clase3.clanom no-label format "x(30)".
                        for each clase4 where
                            clase4.clasup = clase3.clacod no-lock:
                            disp "                                           " clase4.clacod no-label
                                clase4.clanom no-label format "x(30)".
                            if vindex = 2
                            then
                            for each produ where
                                     produ.clacod = clase4.clacod no-lock
                                     BY PRODU.PRONOM.
                                disp "          " produ.procod no-label
                                        format ">>>>>>>>9"
                                        produ.pronom no-label format "x(30)".
                            end.                 
                        end.
                    end.
                end.
            end.
        end.
        end.
        else if rclase.clagrau = 1
        then do with frame f11-2:   
            disp 
             "SETOR" skip
             "  GRUPO" skip
             "    CLASSE" skip
             "      SUB-CLASSE aqui 5" SKIP.

            if vindex = 2
            then disp "        PRODUTOS".


            for each clase1 where
                clase1.clacod = rclase.clacod no-lock:
               
                /* disp  clase1.clacod no-label
                    clase1.clanom no-label format "x(30)". */
                    
                for each clase2 where
                    clase2.clasup = clase1.clacod no-lock:
                   
                    /* disp "  " clase2.clacod no-label
                        clase2.clanom no-label format "x(30)". */
                        
                        
                    for each clase3 where
                        clase3.clasup = clase2.clacod no-lock:
                       
                     /*   disp "                        " clase3.clacod no-label
                           clase3.clanom no-label format "x(30)". */
                           
                        for each clase4 where
                            clase4.clasup = clase3.clacod no-lock:
                            disp "produ.clacod =  " clase4.clacod " or " no-label
                             /*   clase4.clanom no-label format "x(30)" */ .
                            if vindex = 2
                            then
                            for each produ where
                                     produ.clacod = clase4.clacod no-lock
                                     BY PRODU.PRONOM.
                                disp "        " produ.procod no-label
                                        format ">>>>>>>>9"
                                        produ.pronom no-label format "x(30)".
                            end.                 
                        end.
                    end.
                end.
            end.
        end.
        else if rclase.clagrau = 2
        then do with frame f11-3:   
             disp
             "GRUPO" skip
             "  CLASSE" skip
             "    SUB-CLASSE aqui 4" SKIP.
             if vindex = 2
             then disp "      PRODUTOS".


                for each clase2 where
                    clase2.clacod = rclase.clacod no-lock:
                    disp clase2.clacod no-label
                        clase2.clanom no-label format "x(30)".
                    for each clase3 where
                        clase3.clasup = clase2.clacod no-lock:
                        disp "  " clase3.clacod no-label
                           clase3.clanom no-label format "x(30)".
                        for each clase4 where
                            clase4.clasup = clase3.clacod no-lock:
                            disp "    " clase4.clacod no-label
                                clase4.clanom no-label format "x(30)".
                            for each produ where
                                     produ.clacod = clase4.clacod no-lock
                                     BY PRODU.PRONOM.
                                if vindex = 2
                                then
                                disp "      " produ.procod no-label
                                        format ">>>>>>>>9"
                                        produ.pronom no-label format "x(30)".
                            end.                 
                        end.
                    end.
                end.
        end.
        else if rclase.clagrau = 3
        then do with frame f11-4:
             disp
             "CLASSE" skip
             "  SUB-CLASSE aqui 3" SKIP.

             if vindex = 2
             then disp "    PRODUTOS".

                    for each clase3 where
                        clase3.clacod = rclase.clacod no-lock:
                        disp clase3.clacod no-label
                           clase3.clanom no-label format "x(30)".
                        for each clase4 where
                            clase4.clasup = clase3.clacod no-lock:
                            disp "   " clase4.clacod no-label
                                clase4.clanom no-label format "x(30)".
                            if vindex = 2
                            then
                            for each produ where
                                     produ.clacod = clase4.clacod no-lock
                                     BY PRODU.PRONOM.
                                disp "      " produ.procod no-label
                                        format ">>>>>>>>9"
                                        produ.pronom no-label format "x(30)".
                            end.                 
                        end.
                    end.
        end.
        else if rclase.clagrau = 4
        then do with frame f11-5:
            disp 
             "SUB-CLASSE" SKIP.

            if vindex = 2
            then disp "  PRODUTOS".

                        for each clase4 where
                            clase4.clacod = rclase.clacod no-lock:
                            disp clase4.clacod no-label
                                clase4.clanom no-label format "x(30)".
                            if vindex = 2
                            then
                            for each produ where
                                     produ.clacod = clase4.clacod no-lock
                                     BY PRODU.PRONOM.
                                disp "   " produ.procod no-label
                                        format ">>>>>>>>9"
                                        produ.pronom no-label format "x(30)".
                            end.                 
                        end.
        end.

    end.
    
    if vindex = 3
    then do with frame f12:
        disp "DEPARTAMENTO" skip
             "  SETOR"      skip
             "    GRUPO"     skip
             "      CLASSE"  skip
             "        SUB-CLASSE aqui 2 ".

        for each clase0 where clase0.clasup = 0 and
                              clase0.clacod > 100000  no-lock:
            disp clase0.clacod no-label
                 clase0.clanom no-label format "x(30)".
            for each clase1 where
                clase1.clasup = clase0.clacod no-lock:
                disp " " clase1.clacod no-label
                    clase1.clanom no-label format "x(30)".
                for each clase2 where
                    clase2.clasup = clase1.clacod no-lock:
                    disp "   " clase2.clacod no-label
                        clase2.clanom no-label format "x(30)".
                    for each clase3 where
                        clase3.clasup = clase2.clacod no-lock:
                        disp "     " clase3.clacod no-label
                           clase3.clanom no-label format "x(30)".
                        for each clase4 where
                            clase4.clasup = clase3.clacod no-lock:
                            disp "       " clase4.clacod no-label
                                clase4.clanom no-label format "x(30)".
                        end.
                    end.
                end.
            end.
        end.
    end.
    if vindex = 4
    then do with frame f13:
        disp "DEPARTAMENTO" skip
             "  SETOR" skip
             "    GRUPO" skip
             "      CLASSE" skip
             "        SUB-CLASSE" skip
             "          PRODUTOS".
        for each clase0 where clase0.clasup = 0 and
                              clase0.clacod > 100000  no-lock:
            disp clase0.clacod no-label
                 clase0.clanom no-label format "x(30)".
            for each clase1 where
                clase1.clasup = clase0.clacod no-lock:
                disp " " clase1.clacod no-label
                    clase1.clanom no-label format "x(30)".
                for each clase2 where
                    clase2.clasup = clase1.clacod no-lock:
                    disp "   " clase2.clacod no-label
                        clase2.clanom no-label format "x(30)".
                    for each clase3 where
                        clase3.clasup = clase2.clacod no-lock:
                        disp "     " clase3.clacod no-label
                           clase3.clanom no-label format "x(30)".
                        for each clase4 where
                            clase4.clasup = clase3.clacod no-lock:
                            disp "       " clase4.clacod no-label
                                clase4.clanom no-label format "x(30)".
                            for each produ where
                                     produ.clacod = clase4.clacod no-lock
                                     BY PRODU.PRONOM.
                                disp "         " produ.procod no-label
                                        format ">>>>>>>>9"
                                        produ.pronom no-label format "x(30)".
                            end.                 
                        end.
                    end.
                end.
            end.
        end.
    end.

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

procedure setor:
    assign
        a-seeid = -1
        a-recid = -1
        esqpos1  = 1.

    l1: repeat:
        esqcom1[1] = "  GRUPOS".
        clear frame f-com1 all.
        disp esqcom1 with frame f-com1.
        assign
            a-seerec = ?
            esqpos1 = 1.
        hide frame f-setor no-pause.
        clear frame f-setor all.
        color display message esqcom1[esqpos1] with frame f-com1.
        disp "DEPARTAMENTO" SKIP
             depto.clacod AT 3 no-label format ">>>>>>>>9"
             depto.clanom format "x(22)" no-label
             with frame f-sel0 no-box 1 down
             column 47 row 6 side-label.
        {sklclstb.i  
            &file = setor
            &cfield = setor.clacod
            &noncharacter = /* 
            &ofield = " setor.clanom
                        ProntaEntrega.Pentrega  when avail ProntaEntrega
                        ProntaEntrega.cobertura when avail ProntaEntrega"
            &aftfnd1 = "find ProntaEntrega
                                where ProntaEntrega.Tipo   = ""C""
                                  and ProntaEntrega.Codigo = setor.clacod
                           no-lock no-error."
            &where  = " setor.clacod > 1000000 and
                        setor.clasup = depto.clacod "
            &aftselect1 = " 
                        find first rclase where rclase.clacod = setor.clacod
                                   no-lock. 
                        vtipo   = ""C"".
                        vcodigo = setor.clacod.
                        run aftselect.
                        hide frame f-cobertura no-pause.
                        a-seeid = -1.
                        a-recid = recid(setor).
                        if esqcom1[esqpos1] = ""  relatorios""
                        then next keys-loop.
                        else next l1.
                        "
            &naoexiste1 = " message color red/with
                                ""Nenhum registro encontrado para SETOR""
                            view-as alert-box.
                            esqcom1[1] = """".
                            esqcom1[2] = """".
                            esqcom1[3] = """".
                            hide frame f-sel0.
                            leave l1. "       
            &otherkeys1 = " run controle. "
            &locktype = " "
            &form   = " frame f-setor "
        }   
        if keyfunction(lastkey) = "end-error"
        then DO:
            esqcom1[1] = "".
            esqcom1[2] = "".
            esqcom1[3] = "".
            hide frame f-sel0.
            leave l1.       
        END.
    end.
end procedure.

procedure grupo:

    assign
        a-seeid = -1
        a-recid = -1
        esqpos1  = 1.

    l2: repeat:
        esqcom1[1] = "  CLASSES".
        clear frame f-com1 all.
        disp esqcom1 with frame f-com1.
        assign
            a-seerec = ?
            esqpos1 = 1.
        hide frame f-grupo no-pause.
        clear frame f-grupo all.
        color display message esqcom1[esqpos1] with frame f-com1.
        disp "SETOR" SKIP
             setor.clacod at 3 no-label format ">>>>>>>>9"              
             setor.clanom format "x(22)" no-label
             with frame f-sel1 no-box 1 down
             column 47 row 8 side-label.
        {sklclstb.i  
            &file = grupo
            &cfield = grupo.clacod
            &noncharacter = /* 
            &ofield = " grupo.clanom
                        ProntaEntrega.Pentrega  when avail ProntaEntrega
                        ProntaEntrega.cobertura when avail ProntaEntrega"
            &aftfnd1 = "find ProntaEntrega
                                where ProntaEntrega.Tipo   = ""C""
                                  and ProntaEntrega.Codigo = grupo.clacod
                           no-lock no-error."
            &where  = " grupo.clacod > 10000 and
                        grupo.clasup = setor.clacod "
            &aftselect1 = " 
                        find first rclase where rclase.clacod = grupo.clacod
                                   no-lock. 
                        vtipo   = ""C"".
                        vcodigo = grupo.clacod.
                        run aftselect.
                        hide frame f-cobertura no-pause.
                        a-seeid = -1.
                        a-recid = recid(grupo).
                        if esqcom1[esqpos1] = ""  relatorios""
                        then next keys-loop.
                        else next l2. "
            &naoexiste1 = " message color red/with
                                ""Nenhum registro encontrado para GRUPO""
                            view-as alert-box.
                            esqcom1[1] = """".
                            hide frame f-sel1.
                            leave l2. " 
            &otherkeys1 = " run controle. "
            &locktype = " "
            &form   = " frame f-grupo "
        }   
        if keyfunction(lastkey) = "end-error"
        then DO:
            esqcom1[1] = "".
            hide frame f-sel1.
            leave l2.       
        END.
    end.

end procedure.
procedure classe:

    assign
        a-seeid = -1
        a-recid = -1
        esqpos1  = 1.

    l3: repeat:
        esqcom1[1] = "SUB-CLASSES".
        clear frame f-com1 all.
        disp esqcom1 with frame f-com1.
        assign
            a-seerec = ?
            esqpos1 = 1.
        hide frame f-classe no-pause.
        clear frame f-classe all.
        color display message esqcom1[esqpos1] with frame f-com1.
        
        disp "GRUPO"
             grupo.clacod at 3 no-label format ">>>>>>>>9" 
             grupo.clanom no-label format "x(22)"
             with frame f-sel2 no-box 1 down
             column 47 row 10 side-label.
 
         {sklclstb.i  
            &file = clase
            &cfield = clase.clacod
            &noncharacter = /* 
            &ofield = " clase.clanom
                        ProntaEntrega.Pentrega  when avail ProntaEntrega
                        ProntaEntrega.cobertura when avail ProntaEntrega"
            &aftfnd1 = "find ProntaEntrega
                                where ProntaEntrega.Tipo   = ""C""
                                  and ProntaEntrega.Codigo = clase.clacod
                           no-lock no-error. "
            &where  = " clase.clacod > 10000 and
                        clase.clasup = grupo.clacod "
            &aftselect1 = " 
                        find first rclase where rclase.clacod = clase.clacod
                                   no-lock. 
                        vtipo   = ""C"".
                        vcodigo = clase.clacod.
                        run aftselect.
                        hide frame f-cobertura no-pause.
                        a-seeid = -1.
                        a-recid = recid(clase).
                        if esqcom1[esqpos1] = ""  relatorios""
                        then next keys-loop.
                        else next l3. "
            &naoexiste1 = " message color red/with
                                ""Nenhum registro encontrado para CLASSE""
                            view-as alert-box.
                            esqcom1[1] = """".
                            hide frame f-sel2.
                            leave l3. " 
            &otherkeys1 = " run controle. "
            &locktype = " "
            &form   = " frame f-classe "
        }   
        if keyfunction(lastkey) = "end-error"
        then DO:
            esqcom1[1] = "".
            hide frame f-sel2.
            leave l3.       
        END.
    end.

end procedure.

procedure subclasse:

    assign
        a-seeid = -1
        a-recid = -1
        esqpos1  = 1.

    l4: repeat:
        esqcom1[1] = " PRODUTOS".
        clear frame f-com1 all.
        disp esqcom1 with frame f-com1.
        assign
            a-seerec = ?
            esqpos1 = 1.
        hide frame f-SUBclasse no-pause.
        clear frame f-subclasse all.
        color display message esqcom1[esqpos1] with frame f-com1.
        
        disp "CLASSE" SKIP
             clase.clacod at 3 no-label format ">>>>>>>>9"
             clase.clanom  no-label    format "x(22)"
             with frame f-sel3 no-box 1 down
             column 47 row 12 side-label.

        {sklclstb.i  
            &file = subclasse
            &cfield = subclasse.clacod
            &noncharacter = /* 
            &ofield = " subclasse.clanom
                        ProntaEntrega.Pentrega  when avail ProntaEntrega
                        ProntaEntrega.cobertura when avail ProntaEntrega"
            &aftfnd1 = "find ProntaEntrega
                                where ProntaEntrega.Tipo   = ""C""
                                  and ProntaEntrega.Codigo = subclasse.clacod
                           no-lock no-error. "
            &where  = " subclasse.clacod > 10000 and
                        subclasse.clasup = clase.clacod "
            &aftselect1 = " 
                        find first rclase where rclase.clacod = subclasse.clacod
                                   no-lock. 
                        vtipo   = ""C"".
                        vcodigo = subclasse.clacod.
                        run aftselect.
                        hide frame f-cobertura no-pause.
                        a-seeid = -1.
                        a-recid = recid(subclasse).
                        if esqcom1[esqpos1] = ""  relatorios"" 
                        then next keys-loop.
                        else next l4. "
            &naoexiste1 = " message color red/with
                            ""Nenhum registro encontrado para SUB-CLASSE""
                            view-as alert-box.
                            esqcom1[1] = """".
                            hide frame f-sel3.
                            leave l4. " 
            &otherkeys1 = " run controle. "
            &locktype = " "
            &form   = " frame f-subclasse "
        }   
        if keyfunction(lastkey) = "END-ERROR"
        then DO:
            esqcom1[1] = "".
            hide frame f-sel3.
            leave l4.       
        END.
    end.
end procedure.

procedure produto:
    def var p-procod like produ.procod.

    def buffer bprodu for produ.
    
    assign
        esqpos1  = 1.       

    l5: repeat:
        esqcom1[1] = "".
        clear frame f-com1 all.
        disp esqcom1 with frame f-com1.
        assign
            a-seeid = -1 a-recid = -1 a-seerec = ?
            esqpos1 = 1.
        hide frame f-produto no-pause.
        clear frame f-produto all.
        color display message esqcom1[esqpos1] with frame f-com1.
 
        disp "SUB-CLASSE"  SKIP
             subclasse.clacod at 3 no-label format ">>>>>>>>9"
             subclasse.clanom no-label format "x(15)"
             with frame f-sel4 no-box 1 down
             column 47 row 14 side-label.
        find first compra_classe where 
             compra_classe.clacod = subclasse.clacod no-lock no-error.
        if avail compra_classe
        then do: 
            disp skip(1) 
             "     SUB-CLASSE ANTES : "   AT 1 compra_classe.cla-antes 
             no-label 
             with frame f-sel4.
        end.     
                
        {sklclstb.i  
            &file = produ
            &help = "Tecle [P] para procura ".
            &cfield = produ.procod
            &noncharacter = /* 
            &ofield = " produ.pronom
                        ProntaEntrega.Pentrega  when avail ProntaEntrega
                        ProntaEntrega.cobertura when avail ProntaEntrega"
            &aftfnd1 = "find ProntaEntrega
                                where ProntaEntrega.Tipo   = ""P""
                                  and ProntaEntrega.Codigo = produ.procod
                           no-lock no-error. "
            &where  = " produ.catcod = int(subclasse.claper) and
                        produ.clacod = subclasse.clacod 
                        use-index catcla "
            &aftselect1 = "
                        vtipo   = ""P"".
                        vcodigo = produ.procod.
                        run aftselect.
                        hide frame f-cobertura no-pause.
                        a-seeid = -1.
                        a-recid = recid(produ).
                        if esqcom1[esqpos1] = ""  relatorios""
                        then next keys-loop.
                        else next l5. "
            &naoexiste1 = " message ""Nenhum registro para PRODUTO""
                            view-as alert-box.
                            leave l5.  " 
            &otherkeys1 = " run controle. 
                            if keyfunction(lastkey) = ""P""
                            then do:
                                update p-procod label ""Codigo produto""
                                    with frame f-proc 1 down
                                    side-label overlay.
                                find bprodu where    
                                bprodu.catcod = int(subclasse.claper) and
                                bprodu.clacod = subclasse.clacod and
                                bprodu.procod = p-procod
                                no-lock no-error.
                                if not avail bprodu
                                then do:
                                    message ""Produto não encontrado em ""
                                     subclasse.clanom
                                     view-as alert-box.
                                end.
                                else do:
                                    assign a-recid = recid(bprodu)
                                            a-seeid = -1.
                                    next keys-loop.
                                end.
                            end. "
            &locktype = " "
            &form   = " frame f-produto "
        }   
        if keyfunction(lastkey) = "end-error"
        then DO:
            esqcom1[1] = "".
            esqcom1[2] = "".
            esqcom1[3] = "".
            hide frame f-sel4.
            leave l5.       
        END.
    end.
    esqcom1[5] = "  RELATORIOS".
end procedure.

