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
    initial ["","  MODAL","  INCLUI","  EXCLUI",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","  IMPRIME","","",""].
def var esqcom3         as char format "x(12)" extent 3
    initial ["   ALTERA ","   INCLUI","   EXCLUI "].
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
def var esqhel3         as char format "x(12)" extent 3
   initial [" ",
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
                 row 3 no-box no-labels side-labels column 40
                 .                 
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
form    
        t-modgru.modcod format "x(3)" no-label
        t-modgru.mognom column-label "Descricao" format "x(29)"
        with  frame f-linha
        title " Grupos de Modalidades "
        11 down row 5 width 35 overlay
        .

form bmodgru.modcod column-label "Mod" format "x(3)"
     modal.modnom   column-label "Descricao" format "x(30)"
     with frame f-l1 column 36 width 45 overlay
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
        &ofield  = " t-modgru.modcod "
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
    clear frame f-l1 all.
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
color display messages esqcom3[esqpos3] with frame f-com3.
hide frame f-com1.
hide frame f-com2.

    l2: repeat:
    i-seeid = a-seeid.
    i-recid = a-recid.
    
    hide frame f-l1 no-pause.
    clear frame f-l1 all.
    a-seeid = -1. a-recid = -1. a-seerec = ?.
    
    {sklcls.i
        &help = "F4=Retorna"
        &file = bmodgru
        &cfield = bmodgru.modcod
        &ofield  = " modal.modnom when avail modal 
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
                        if esqcom1[esqpos1] = ""   EXCLUI"" or
                           esqcom2[esqpos2] = ""   INCLUI""
                        then do:
                            next l2.
                        end.
                        else next keys-loop. "
        &otherkeys1 = " run controle1. "
                  
        &form = " frame f-l1 "
    }
    /*        &otherkeys = " bmodgru.ok "*/

    if keyfunction(lastkey) = "END-ERROR"
    then do:
        hide frame f-l1 no-pause.
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
                    do ve = 1 to 3:
                    color display normal esqcom3[ve] with frame f-com3.
                    end.
                end.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom3[esqpos3] with frame f-com3.
                    esqpos3 = if esqpos3 = 3 then 3 else esqpos3 + 1.
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
    clear frame f-l1 all.
    /*
    def buffer bmodgru for modgru.
    */
    disp bmodgru.modcod modal.modnom with frame f-l1.
    pause 0.
    if keyfunction(lastkey) = "END-ERROR"   
    then do:
        hide frame f-com1.
        hide frame f-com2.
        view frame f-com3.
    end.
    if esqcom3[esqpos3] = "   ALTERA"
    THEN DO on error undo:
        run altera.
    end.
    if esqcom3[esqpos3] = "   INCLUI"
    THEN DO on error undo:
        run inclui.
    END.
    if esqcom3[esqpos3] = "   EXCLUI"
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

def var vclasse as char extent 3 init["Orçamento","Projeto","Fornecedor"] 
                    format "x(12)".
def var vsclas1 as char extent 2 init["Limiar","Incremento"] format "x(12)".
def var vsclas2 as char extent 2 init["Investimento","Despesa"] format "x(12)".
def var vm  as char extent 3 format "X(3)".
def var vm1 as char extent 2 format "x(3)".
def var vm2 as char extent 2 format "x(3)".
def var vforcod as int format ">>>>>>9".

form vm[1] space(0)
     vclasse[1] skip(3)
     vm[2] space(0) 
     vclasse[2] skip(2)
     vm[3] space(0)
     vclasse[3]
     with frame f-m 1 down overlay no-label 
     column 37 row 9 .
form vm1[1] space(0)
     vsclas1[1] skip
     vm1[2] space(0)
     vsclas1[2]
     with frame f-m1 1 down overlay no-label 
     column 54 row 9.
form vm2[1] space(0)
     vsclas2[1] skip
     vm2[2] space(0)
     vsclas2[2]
     with frame f-m2 1 down overlay no-label 
     column 54 row 13.
form vforcod column-label "Fornec" 
            with frame f-f 6 down row 7 column 71
            overlay.
 
procedure altera:    
    def var vim as int.
    def var vim1 as int.
    def var vim2 as int.

    vm = "".
    vm1 = "".
    vm2 = "".
    vforcod = 0.
    
    disp vm  vclasse with frame f-m.
    disp vm1 vsclas1 with frame f-m1.
    disp vm2 vsclas2 with frame f-m2.
    l1:
    repeat on endkey undo with frame f-m:
        if keyfunction(lastkey) = "END-ERROR"
        then leave l1.
        find first modclasf where
                   modclasf.tipomcf = 1 and 
                   modclasf.modcod = bmodgru.modcod 
                   no-error. 
        if avail modclasf
        then vim = modclasf.tipclas.
        else vim = 0.
        if vim > 0 
        then do:
            vm[vim] = "(X)".
            disp vm[vim].  
            if vim = 1
            then do:
                assign
                    vim1 = modclasf.tipsclas
                    vim2 = 0.
                vm1[vim1] = "(X)".
                disp vm1[vim1] with frame f-m1.
            end.
            else do:
                assign
                    vim2 = modclasf.tipsclas
                    vim1 = 0.
                vm2[vim2] = "(X)".
                disp vm2[vim2] with frame f-m2.
            end.    
        end.               
        find first modclasf where
             modclasf.tipo = 2 and
             modclasf.modcod = bmodgru.modcod
             no-lock no-error.
        if avail modclasf
        then do:
            vm[3] = "(X)".
            disp vm[3].
        end.     
        
        choose field vclasse with frame f-m.
 
        vim = frame-index.
        if vim = 1
        then do:
        find first modclasf where
                   modclasf.tipomcf = 1 and
                   modclasf.modcod = bmodgru.modcod and
                   modclasf.clascod = vclasse[2]
                   no-lock no-error.
            if avail modclasf
            then undo, retry.
        end.
        if vim = 2
        then do:
        find first modclasf where
                   modclasf.tipomcf = 1 and
                   modclasf.modcod = bmodgru.modcod and
                   modclasf.clascod = vclasse[1]
                   no-lock no-error.
            if avail modclasf
            then undo, retry.
        end.
        if vm[vim] = "(X)"
        then vm[vim] = "".
        else vm[vim] = "(X)".
        disp vm[vim] with frame f-m.
        if vim1 > 0
        then do:
            vm1[vim1] = "".
            disp vm1[vim1] with frame f-m1.
        end.
        if vim2 > 0
        then do:
            vm2[vim2] = "".
            disp vm2[vim2] with frame f-m2.
        end.
        if vim = 1
        then do:
            find first modclasf where
                   modclasf.tipomcf = 1 and
                   modclasf.modcod = bmodgru.modcod and
                   modclasf.clascod = vclasse[vim]
                   no-error.
            if avail modclasf  
            then do on error undo:
                vim1 = modclasf.tipsclas.
                modclasf.tipclas = 0.
                modclasf.tipsclas = 0.
                modclasf.clascod = "" .
                modclasf.sclascod = "" .
                next l1.
            end.
            else do on error undo: 
                find first modclasf where
                            modclasf.tipo = 1 and
                            modclasf.modcod = bmodgru.modcod 
                            no-error.
                if not avail modclasf                
                then create modclasf.

                assign
                        modclasf.tipomcf = 1 
                        modclasf.modcod = bmodgru.modcod 
                        .

                repeat on endkey undo with frame f-m1:
                    choose field vsclas1.
                    vim1 = frame-index.
                    if vm1[vim1] = "(X)"
                    then vm1[vim1] = "".
                    else vm1[vim1] = "(X)".
                    disp vm1[vim1] with frame f-m1.
                    leave.
                end.
                assign
                    modclasf.clascod = vclasse[vim]
                    modclasf.sclascod = vsclas1[vim1]
                    modclasf.tipclas = vim
                    modclasf.tipsclas = vim1
                    .                
            end.
        end.     
        else if vim = 2
        then do:
            find first modclasf where
                   modclasf.tipo = 1 and
                   modclasf.modcod = bmodgru.modcod and
                   modclasf.clascod = vclasse[vim]
                   no-error.
            if avail modclasf  
            then do on error undo:
                vim2 = modclasf.tipsclas.
                modclasf.tipclas = 0.
                modclasf.tipsclas = 0.
                modclasf.clascod = "" .
                modclasf.sclascod = "" .
                next l1.
            end.
            else do on error undo: 
                find first modclasf where
                            modclasf.tipo = 1 and
                            modclasf.modcod = bmodgru.modcod 
                            no-error.
                if not avail modclasf                
                then create modclasf.

                assign
                        modclasf.tipomcf = 1 
                        modclasf.modcod = bmodgru.modcod 
                        .
                repeat on endkey undo with frame f-m2:
                    choose field vsclas2.
                    vim2 = frame-index.
                    if vm2[vim2] = "(X)"
                    then vm2[vim2] = "".
                    else vm2[vim2] = "(X)".
                    disp vm2[vim2] with frame f-m2.
                    leave.
                end.
                assign
                    modclasf.clascod = vclasse[vim]
                    modclasf.sclascod = vsclas1[vim2]
                    modclasf.tipclas = vim
                    modclasf.tipsclas = vim2
                    . 
            end.
        end.
        else if vim = 3
        then do:
        /*
        leave.
    end.  */
    vm[3] = "(X)" .
    disp vm[3].
    repeat with frame f-f:
        clear frame f-f all.
        for each modclasf where
             modclasf.tipo = 2 and
             modclasf.modcod = bmodgru.modcod
             no-lock:
            disp modclasf.forcod @ vforcod with frame f-f.
            down with frame f-f.
        end.         
        vforcod = 0.
        update vforcod.
        find forne where forne.forcod = vforcod no-lock no-error.
        if not avail forne
        then leave.
        find first modclasf where
                   modclasf.tipomcf = 2 and
                   modclasf.modcod = bmodgru.modcod and
                   modclasf.forcod = vforcod
                   no-lock no-error.
        if avail modclasf
        then undo, retry.
        else do on error undo:
            create modclasf.
            assign
                modclasf.tipomcf = 2
                modclasf.descmcf = "FORNECEDOR"
                modclasf.modcod = bmodgru.modcod
                modclasf.forcod = vforcod
                .
        end.        
    end.
    end.
    leave.
    end.
    hide frame f-m no-pause.
    hide frame f-m1 no-pause.
    hide frame f-m2 no-pause.
    hide frame f-f no-pause.
end.
