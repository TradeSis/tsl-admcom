{admcab.i}
{setbrw.i}

def buffer p-produ for produ.
def buffer p-classe for clase.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  ALTERAR","  INCLUIR","","  RELATORIOS"].
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
     with frame f-depto 13 Down color 
     centered title "   DEPARTAMENTOS  " .

form setor.clacod format ">>>>>>>>9" no-label
     setor.clanom format "x(25)" no-label
     with frame f-setor 13 Down color 
     centered title "   SETORES  " .

form grupo.clacod format ">>>>>>>>9" no-label
     grupo.clanom format "x(25)" no-label
     with frame f-GRUPO 13 Down color 
     centered title "   GRUPOS  " .

form clase.clacod format ">>>>>>>>9" no-label
     clase.clanom format "x(25)" no-label
     with frame f-classe 13 Down color 
     centered title "   CLASSES  " .

form subclaSse.clacod format ">>>>>>>>9" no-label
     subclaSse.clanom format "x(25)" no-label
     with frame f-subclasse 13 Down color 
     centered title "   SUB-CLASSES  " .

form produ.procod format ">>>>>>>>9" no-label
     produ.pronom format "x(25)" no-label
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
    esqcom1[1] = "".
    esqcom1[2] = "".
    esqcom1[3] = "".
    esqcom1[1] = "  SETORES".
    clear frame f-com1 all.
    clear frame f-com2 all.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
         a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-depto no-pause.
    clear frame f-depto all.
    color display message esqcom1[esqpos1] with frame f-com1.
    {sklclstb.i  
        &file = depto
        &cfield = depto.clacod
        &noncharacter = /* 
        &ofield = " depto.clanom "  
        &aftfnd1 = " "
        &where  = " depto.clacod > 1000000 and
                    depto.clasup = 0 
                    USE-INDEX ICLACOD "
        &aftselect1 = " esqcom1[3] = ""  INCLUIR"".
                        esqcom1[2] = ""  ALTERAR"".
                        find first rclase where
                                   rclase.clacod = depto.clacod
                                   no-lock. 
                        run aftselect.
                        a-seeid = -1.
                        a-recid = recid(depto).
                        if esqcom1[esqpos1] = ""  relatorios""
                        then next keys-loop.
                        else next l0.
                        "
        &go-on = TAB 
        &naoexiste1 = "  " 
        &otherkeys1 = " run controle. "
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
    if esqcom1[esqpos1] = "  INCLUIR"
    THEN DO on error undo:
        run inclui.
    END.
    if esqcom1[esqpos1] = "  ALTERAR"
    THEN DO on error undo:
        run alterar.
    END.
    if esqcom1[esqpos1] = "  ALTERA P"
    THEN DO on error undo:
        run altera-p.
    END.
    if esqcom1[esqpos1] = "COPIA PARA"
    THEN DO on error undo:
        run copiapara-p.
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
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """TITULO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    if vindex = 1 or vindex = 2
    then do:

        if rclase.clagrau = 0
        then do with frame f11-1:   
        disp "DEPARTAMENTO" skip
             "  SETOR" skip
             "    GRUPO" skip
             "      CLASSE" skip
             "        SUB-CLASSE" SKIP.

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
                    disp "    " clase2.clacod no-label
                        clase2.clanom no-label format "x(30)".
                    for each clase3 where
                        clase3.clasup = clase2.clacod no-lock:
                        disp "      " clase3.clacod no-label
                           clase3.clanom no-label format "x(30)".
                        for each clase4 where
                            clase4.clasup = clase3.clacod no-lock:
                            disp "        " clase4.clacod no-label
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
             "      SUB-CLASSE" SKIP.

            if vindex = 2
            then disp "        PRODUTOS".


            for each clase1 where
                clase1.clacod = rclase.clacod no-lock:
                disp  clase1.clacod no-label
                    clase1.clanom no-label format "x(30)".
                for each clase2 where
                    clase2.clasup = clase1.clacod no-lock:
                    disp "  " clase2.clacod no-label
                        clase2.clanom no-label format "x(30)".
                    for each clase3 where
                        clase3.clasup = clase2.clacod no-lock:
                        disp "    " clase3.clacod no-label
                           clase3.clanom no-label format "x(30)".
                        for each clase4 where
                            clase4.clasup = clase3.clacod no-lock:
                            disp "      " clase4.clacod no-label
                                clase4.clanom no-label format "x(30)".
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
             "    SUB-CLASSE" SKIP.
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
             "  SUB-CLASSE" SKIP.

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
             "        SUB-CLASSE ".

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
        esqregua = yes
        esqpos1  = 1
        esqpos2  = 1.

    l1: repeat:
        esqcom1[1] = "".
        esqcom1[1] = "  GRUPOS".
        clear frame f-com1 all.
        clear frame f-com2 all.
        disp esqcom1 with frame f-com1.
        disp esqcom2 with frame f-com2.
        assign
            a-seerec = ?
            esqpos1 = 1 esqpos2 = 1. 
        hide frame f-setor no-pause.
        clear frame f-setor all.
        color display message esqcom1[esqpos1] with frame f-com1.
        disp "DEPARTAMENTO" SKIP
             depto.clacod AT 3 no-label format ">>>>>>>>9"
             depto.clanom format "x(24)" no-label
             with frame f-sel0 no-box 1 down
             column 39 row 6 side-label.
        {sklclstb.i  
            &file = setor
            &cfield = setor.clacod
            &noncharacter = /* 
            &ofield = " setor.clanom "  
            &aftfnd1 = " "
            &where  = " setor.clacod > 1000000 and
                        setor.clasup = depto.clacod "
            &aftselect1 = " 
                        find first rclase where
                                   rclase.clacod = setor.clacod
                                   no-lock. 
                        run aftselect.
                        a-seeid = -1.
                        a-recid = recid(setor).
                        if esqcom1[esqpos1] = ""  relatorios""
                        then next keys-loop.
                        else next l1.
                        "
            &go-on = TAB 
            &naoexiste1 = " bell.
                            message color red/with
                                ""Nenhum registro encontrado para SETOR""
                            view-as alert-box.
                            esqcom1[1] = """".
                            esqcom1[2] = """".
                            esqcom1[3] = """".
                            hide frame f-sel0.
                            leave l1.
                          "       
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
        esqregua = yes
        esqpos1  = 1
        esqpos2  = 1.

    l2: repeat:
        esqcom1[1] = "".
        esqcom1[1] = "  CLASSES".
        clear frame f-com1 all.
        clear frame f-com2 all.
        disp esqcom1 with frame f-com1.
        disp esqcom2 with frame f-com2.
        assign
            a-seerec = ?
            esqpos1 = 1 esqpos2 = 1. 
        hide frame f-grupo no-pause.
        clear frame f-grupo all.
        color display message esqcom1[esqpos1] with frame f-com1.
        disp "SETOR" SKIP
             setor.clacod at 3 no-label format ">>>>>>>>9"              
             setor.clanom format "x(24)" no-label
             with frame f-sel1 no-box 1 down
             column 39 row 8 side-label.
        {sklclstb.i  
            &file = grupo
            &cfield = grupo.clacod
            &noncharacter = /* 
            &ofield = " grupo.clanom "  
            &aftfnd1 = " "
            &where  = " grupo.clacod > 10000 and
                        grupo.clasup = setor.clacod "
            &aftselect1 = " 
                        find first rclase where
                                   rclase.clacod = grupo.clacod
                                   no-lock. 
                        run aftselect.
                        a-seeid = -1.
                        a-recid = recid(grupo).
                        if esqcom1[esqpos1] = ""  relatorios""
                        then next keys-loop.
                        else next l2.
                        "
            &go-on = TAB 
            &naoexiste1 = " bell.
                            message color red/with
                                ""Nenhum registro encontrado para GRUPO""
                            view-as alert-box.
                            sresp = no.
                            message ""Deseja incluir GRUPO? "" update sresp.
                            if sresp
                            then do:
                                vsupcla = setor.clacod.
                                vgraucla = 1.
                                run inclui.
                            end.
                            esqcom1[1] = """".
                            hide frame f-sel1.
                            leave l2.
                            " 
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
        esqregua = yes
        esqpos1  = 1
        esqpos2  = 1.

    l3: repeat:
        esqcom1[1] = "".
        esqcom1[1] = "SUB-CLASSES".
        clear frame f-com1 all.
        clear frame f-com2 all.
        disp esqcom1 with frame f-com1.
        disp esqcom2 with frame f-com2.
        assign
            a-seerec = ?
            esqpos1 = 1 esqpos2 = 1. 
        hide frame f-classe no-pause.
        clear frame f-classe all.
        color display message esqcom1[esqpos1] with frame f-com1.
        
        disp "GRUPO"
             grupo.clacod at 3 no-label format ">>>>>>>>9" 
             grupo.clanom no-label format "x(24)"
             with frame f-sel2 no-box 1 down
             column 39 row 10 side-label.
 
         {sklclstb.i  
            &file = clase
            &cfield = clase.clacod
            &noncharacter = /* 
            &ofield = " clase.clanom "  
            &aftfnd1 = " "
            &where  = " clase.clacod > 10000 and
                        clase.clasup = grupo.clacod "
            &aftselect1 = " 
                        find first rclase where
                                   rclase.clacod = clase.clacod
                                   no-lock. 
                        run aftselect.
                        a-seeid = -1.
                        a-recid = recid(clase).
                        if esqcom1[esqpos1] = ""  relatorios""
                        then next keys-loop.
                        else next l3.
                        "
            &go-on = TAB 
            &naoexiste1 = " bell.
                            message color red/with
                                ""Nenhum registro encontrado para CLASSE""
                            view-as alert-box.
                            sresp = no.
                            message ""Deseja incluir CLASSE? "" update sresp.
                            if sresp
                            then do:
                                vsupcla = grupo.clacod.
                                vgraucla = 2.
                                run inclui.
                            end.
                            esqcom1[1] = """".
                            hide frame f-sel2.
                            leave l3.
                          " 
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
        esqregua = yes
        esqpos1  = 1
        esqpos2  = 1.

    l4: repeat:
        esqcom1[1] = "".
        esqcom1[1] = " PRODUTOS".
        clear frame f-com1 all.
        clear frame f-com2 all.
        disp esqcom1 with frame f-com1.
        disp esqcom2 with frame f-com2.
        assign
            a-seerec = ?
            esqpos1 = 1 esqpos2 = 1. 
        hide frame f-SUBclasse no-pause.
        clear frame f-subclasse all.
        color display message esqcom1[esqpos1] with frame f-com1.
        
        disp "CLASSE" SKIP
             clase.clacod at 3 no-label format ">>>>>>>>9"
             clase.clanom  no-label    format "x(24)"
             with frame f-sel3 no-box 1 down
             column 39 row 12 side-label.

        {sklclstb.i  
            &file = subclasse
            &cfield = subclasse.clacod
            &noncharacter = /* 
            &ofield = " subclasse.clanom "  
            &aftfnd1 = " "
            &where  = " subclasse.clacod > 10000 and
                        subclasse.clasup = clase.clacod "
            &aftselect1 = " 
                        find first rclase where
                                   rclase.clacod = subclasse.clacod
                                   no-lock. 
                        run aftselect.
                        a-seeid = -1.
                        a-recid = recid(subclasse).
                        if esqcom1[esqpos1] = ""  relatorios"" 
                        then next keys-loop.
                        else next l4.
                        "
            &go-on = TAB 
            &naoexiste1 = " bell.
                            message color red/with
                            ""Nenhum registro encontrado para SUB-CLASSE""
                            view-as alert-box.
                            sresp = no.
                            message ""Deseja incluir SUB-CLASSE? ""
                                    update sresp.
                            if sresp
                            then do:
                                vsupcla = clase.clacod.
                                vgraucla = 3.
                                run inclui.
                            end.
                            esqcom1[1] = """".
                            hide frame f-sel3.
                            leave l4.
                            " 
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
    def var vcomprador as char init "" FORMAT "X(15)".
    def var vgestor as char init "" FORMAT "X(15)".

    assign
        esqregua = yes
        esqpos1  = 1       
        esqpos2  = 1.

    l5: repeat:
        esqcom1 = "".
        esqcom1[2] = "  ALTERA P".
        esqcom1[3] = "COPIA PARA".
        clear frame f-com1 all.
        clear frame f-com2 all.
        disp esqcom1 with frame f-com1.
        disp esqcom2 with frame f-com2.
        assign
            a-seeid = -1 a-recid = -1 a-seerec = ?
            esqpos1 = 1 esqpos2 = 1. 
        hide frame f-produto no-pause.
        clear frame f-produto all.
        color display message esqcom1[esqpos1] with frame f-com1.
 
        disp "SUB-CLASSE"  SKIP
             subclasse.clacod at 3 no-label format ">>>>>>>>9"
             subclasse.clanom no-label format "x(15)"
             with frame f-sel4 no-box 1 down
             column 39 row 14 side-label.
        find first compra_classe where 
             compra_classe.clacod = subclasse.clacod no-lock no-error.
        if avail compra_classe
        then do: 
            find first compr where compr.comcod = compra_classe.comprador
                    no-lock no-error.
            if avail compr
            then vcomprador = compr.comnom.
            else vcomprador = "".
            find first compr where compr.comcod = compra_classe.gestor
                    no-lock no-error.
            if avail compr
            then vgestor = compr.comnom.
            else vgestor = "".
        
            disp skip(1) /*
             "         GESTOR       : "   AT 1 CAPS(VGESTOR) 
             FORMAT "X(15)" NO-LABEL
             "         COMPRADOR    : "   AT 1 CAPS(vcomprador) 
             FORMAT "X(15)" no-label */
             "     SUB-CLASSE ANTES : "   AT 1 compra_classe.cla-antes 
             no-label 
             with frame f-sel4.
        end.     
                
        {sklclstb.i  
            &file = produ
            &cfield = produ.procod
            &noncharacter = /* 
            &ofield = " produ.pronom "  
            &aftfnd1 = " "
            &where  = " produ.catcod = int(subclasse.claper) and
                        produ.clacod = subclasse.clacod 
                        use-index catcla "
            &aftselect1 = " 
                        run aftselect.
                        a-seeid = -1.
                        a-recid = recid(produ).
                        if esqcom1[esqpos1] = ""  relatorios""
                        then next keys-loop.
                        else next l5.

                        "
            &go-on = TAB 
            &naoexiste1 = " bell.
                            message color red/with
                            ""Nenhum registro para PRODUTO""
                            view-as alert-box.
                            leave l5. 
                            " 
            &otherkeys1 = " run controle. 
                        "
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
    esqcom1[2] = "  ALTERAR".
    esqcom1[3] = "  INCLUIR".
    esqcom1[5] = "  RELATORIOS".
end procedure.

procedure inclui:
    vclanom = "".
    vclagrau = ?.
    vclasup = ?.
    vclacod = 0.
    clear frame f-inclui all.
    do on error undo:
        update vclanom with frame f-inclui.
        if vclanom = ""
        then undo.     
    end.          
    if vclanom <> ""
    then do:
        vclacod = 0.
        find last inc-clase where inc-clase.clasup = vsupcla 
                use-index iclacod no-error.
        if avail inc-clase
        then assign
                vclagrau = inc-clase.clagrau 
                vclasup  = inc-clase.clasup.
        else assign        
                vclagrau = vgraucla + 1.
                vclasup  = vsupcla.
                
        if not avail inc-clase
        then do:
            if vclagrau = 1
            then vclacod = vclasup + 1000000.
            else if vclagrau = 2
            then vclacod = vclasup + 10000.
            else if vclagrau = 3
            then vclacod = vclasup + 100.
            else if vclagrau = 4
            then vclacod = vclasup + 1.
        end.
        else do:
            if vclagrau = 1
            then vclacod = inc-clase.clacod + 1000000.
            else if vclagrau = 2
            then vclacod = inc-clase.clacod + 10000.
            else if vclagrau = 3
            then vclacod = inc-clase.clacod + 100.
            else if vclagrau = 4
            then vclacod = inc-clase.clacod + 1.
        end.
        disp vclacod vclagrau with frame f-inclui.
        sresp = no.
        message "Confirma incluir?" update sresp.
        if sresp 
        then do:
        
            create inc-clase.
            assign
                inc-clase.clacod = vclacod
                inc-clase.clanom = vclanom
                inc-clase.clasup = vclasup
                inc-clase.clagrau = vclagrau
                inc-clase.claordem = rclase.claordem
                inc-clase.claimp = no
                inc-clase.clatipo =  rclase.clatipo
                inc-clase.claper =   rclase.claper
                .
        end.
        vclacod = 0.
        vclanom = "".
        clear frame f-inclui all.
    end.
end procedure.
procedure alterar:
    find inc-clase where inc-clase.clacod = rclase.clacod no-error.
    vclacod = inc-clase.clacod.
    vclanom = inc-clase.clanom.
    clear frame f-inclui all.
    disp vclacod with frame f-inclui.
    do on error undo, retry:
        update vclanom with frame f-inclui.
        if vclanom = ""
        then undo.
    end.
    if vclanom <> "" and
       vclanom <> ? and
       vclanom <> "~~"
    then inc-clase.clanom = vclanom.

    vclacod = 0.
    vclanom = "".
    clear frame f-inclui all.
end procedure.
procedure altera-p:
    find p-produ where p-produ.procod = produ.procod no-error.
    if avail p-produ
    then do:
        disp p-produ.procod  at 1 label "Codigo" format ">>>>>>>>9"
             p-produ.pronom  at 1 label "Descricao" format "x(25)"
             p-produ.clacod  at 1 label "Sub-Classe" format ">>>>>>>>9"
             with frame f-altprodu 1 down side-label row 10
             overlay color message.
        do on error undo, retry:
            update p-produ.clacod
                with frame f-altprodu.
            if p-produ.clacod = 0 or
               p-produ.clacod = ?
            then undo, retry.
            find first p-classe where
                 p-classe.clacod = p-produ.clacod no-lock no-error.
            if not avail p-classe or p-classe.clagrau <> 4
            then undo.     
            p-produ.datexp = today.
        end.
    end.
end procedure.
procedure copiapara-p:
    def var vsubatu like clase.clacod.
    def var vsubpos like clase.clacod.
    do on error undo:
        
        vsubatu = subclasse.clacod.
        vsubpos = 0.
        
        update vsubatu label "Copiar da SUB-CLASSE"
           with frame f-copiapara.
        if vsubatu = 0 or
           vsubatu = ?
        then undo.   
        find first p-classe where
                 p-classe.clacod = vsubatu no-lock no-error.
        if not avail p-classe or p-classe.clagrau <> 4
        then undo.  
               
        update vsubpos label "Para SUB-CLASSE"
           with frame f-copiapara 1 down
           centered side-label row 10 color message overlay.
        if vsubpos = 0 or
           vsubpos = ?
        then undo.   
        find first p-classe where
                 p-classe.clacod = vsubpos no-lock no-error.
        if not avail p-classe or p-classe.clagrau <> 4
        then undo.         
        sresp = no.
        message "Confirma transferir produtos?" update sresp.
        if sresp = no
        then undo.   
        for each p-produ where 
             p-produ.clacod = vsubatu.
            p-produ.clacod = vsubpos.
            p-produ.datexp = today.
            disp p-produ.procod  at 1 label "Codigo" format ">>>>>>>>9"
             p-produ.pronom  at 1 label "Descricao" format "x(25)"
             p-produ.clacod  at 1 label "Sub-Classe" format ">>>>>>>>9"
             with frame f-altprodu 1 down side-label row 10
             overlay color message.
        end.
    end.
end procedure.