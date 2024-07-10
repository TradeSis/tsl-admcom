{admcab.i}
def input parameter p-catcod like produ.catcod.
def input parameter p-tamanho as char.

{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Inclui","  Exclui","",""].
def var esqcom2         as char format "x(20)" extent 5
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

form 
     with frame f-linha 8 down color with/cyan 
     width 80.
                                                                                
disp "                         ENQUADRAMENTO FILIAIS A TAMANHO   " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def  var vfiliais as char.

def temp-table tt-etbtam like etbtam.

l1: repeat:

    hide frame esqcom1 .
    hide frame esqcom2 .
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    
    hide frame f-linha no-pause.
    clear frame f-linha all.
    
    /**********************/
    for each tt-etbtam:
        delete tt-etbtam.
    end.    
    

    for each etbtam where etbtam.catcod  = p-catcod and
                          etbtam.tamanho = p-tamanho and  
                          etbtam.situacao = "E" 
                           no-lock by etbtam.etbcod:
        create tt-etbtam.
        buffer-copy etbtam to tt-etbtam.
         
    end.
    hide frame f-linha no-pause.
    
    /**************************/
    {sklclstb.i  
        &color = with/cyan
        &file = tt-etbtam  
        &cfield = tt-etbtam.etbcod
        &noncharacter = /* 
        &ofield = " estab.etbnom no-label when avail estab "  
        &aftfnd1 = "
            find estab where estab.etbcod = tt-etbtam.etbcod no-lock no-error.
            "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom1[esqpos1] = ""  inclui""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "   run inclui. 
                if keyfunction(lastkey) = ""end-error""
                then leave l1.
                else next l1.
             " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha  "
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
    def var vetbcod like estab.etbcod.
    def var vqtd as int.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        run inclui.
        /**
        scroll from-current down with frame f-linha.
        create tt-etbtam.
        tt-etbtam.tamanho = p-tamanho.
        update tt-etbtam.etbcod with frame f-linha  .
        find estab where estab.etbcod = tt-etbtam.etbcod
                    no-lock no-error.
        if not avail estab then undo.            
        find first etbtam where 
                   etbtam.catcod = p-catcod and 
                   etbtam.etbcod = estab.etbcod and
                   etbtam.situacao = "E"
                   no-lock no-error.
        if avail etbtam
        then do:
            bell.
            message color red/with
            "Filial ja associada ao tamanho. "
            view-as alert-box.
            undo.
        end.           
        else do:
            vqtd = 0.
            for each etbtam where
                     etbtam.catcod = p-catcod and
                     etbtam.tamanho = tt-etbtam.tamanho
                     no-lock.
                vqtd = vqtd + 1.
            end.
            find first tamloja where
                       tamloja.catcod = p-catcod and
                       tamloja.tamanho = tt-etbtam.tamanho
                       no-lock no-error.
            if avail tamloja and tamloja.limite = vqtd 
            then do:
                message color red/with 
                 "Tamanho com limite maximo de filiais."
                 view-as alert-box.
                 undo.
            end.
            else do:                
            create etbtam.
            assign
                etbtam.catcod  = p-catcod
                etbtam.tamanho = tt-etbtam.tamanho
                etbtam.etbcod  = tt-etbtam.etbcod
                etbtam.data-enquadramento = today
                etbtam.situacao = "E"
                .
            end.
        end.*/    
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
    
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        update vetbcod with frame f-exclui
                centered 1 down side-label row 8
                overlay.
        find first etbtam where 
                   etbtam.catcod = p-catcod and 
                   etbtam.etbcod = vetbcod and
                   etbtam.situacao = "E"   and
                   etbtam.tamanho = tt-etbtam.tamanho
                    no-error.
        if not avail etbtam
        then do:
            bell.
            message color red/with
            "Filial nao enquadrada ao tamanho " tt-etbtam.tamanho
            view-as alert-box.
            undo.
        end.           
        else do:
            delete etbtam.
        end.     
    END.
    if esqcom2[esqpos2] = "novo enquadramento"
    THEN DO :
        run enquadra-filiais-tamanho.
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

procedure inclui:
    def var vqtd as int.
    scroll from-current down with frame f-linha.
        create tt-etbtam.
        tt-etbtam.tamanho = p-tamanho.
        update tt-etbtam.etbcod with frame f-linha  .
        find estab where estab.etbcod = tt-etbtam.etbcod
                    no-lock no-error.
        if not avail estab then undo.            
        find first etbtam where 
                   etbtam.catcod = p-catcod and 
                   etbtam.etbcod = estab.etbcod and
                   etbtam.situacao = "E"
                   no-lock no-error.
        if avail etbtam
        then do:
            bell.
            message color red/with
            "Filial ja associada ao tamanho. "
            view-as alert-box.
            undo.
        end.           
        else do:
            vqtd = 0.
            for each etbtam where
                     etbtam.catcod = p-catcod and
                     etbtam.tamanho = tt-etbtam.tamanho
                     no-lock.
                vqtd = vqtd + 1.
            end.
            find first tamloja where
                       tamloja.catcod = p-catcod and
                       tamloja.tamanho = tt-etbtam.tamanho
                       no-lock no-error.
            if avail tamloja and tamloja.limite = vqtd 
            then do:
                message color red/with 
                 "Tamanho com limite maximo de filiais."
                 view-as alert-box.
                 undo.
            end.
            else do:                
            create etbtam.
            assign
                etbtam.catcod  = p-catcod
                etbtam.tamanho = tt-etbtam.tamanho
                etbtam.etbcod  = tt-etbtam.etbcod
                etbtam.data-enquadramento = today
                etbtam.situacao = "E"
                .
            end.
        end. 
end procedure.        
            
            
                 
                        
                        
                        

