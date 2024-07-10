{admcab.i}

def var vforcod like forne.forcod .

def temp-table tt-lanaut like lanaut
    field datlan as date.
 
update vforcod label "Fornecedor"
    with frame f1 1 down side-label width 80.

find forne where forne.forcod = vforcod no-lock.

disp forne.fornom no-label with frame f1.

for each estab no-lock:

    /*for each modal no-lock:
    */
    find last titulo use-index iclicod where
              titulo.clifor = forne.forcod and
              titulo.titnat = yes and
              titulo.empcod = 19  and
              titulo.etbcod = estab.etbcod   
              no-lock no-error.  
    /*find first titulo where titulo.empcod = 19 and
                titulo.titnat = yes and
                titulo.modcod = modal.modcod and
                titulo.etbcod = estab.etbcod and
                titulo.clifor = forne.forcod 
                no-lock no-error.
    */
    if avail titulo
    then do:
        find lanaut where   lanaut.etbcod = estab.etbcod and
                            lanaut.forcod = forne.forcod 
                            no-lock no-error.
        if avail lanaut
        then do:
            create tt-lanaut.
            buffer-copy lanaut to tt-lanaut.
            tt-lanaut.datlan = titulo.titdtpag.
            tt-lanaut.modcod = titulo.modcod.
        end.
    end.
    /*end.*/
end.

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
    initial ["","  Altera","Altera tudo","",""].
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


form tt-lanaut.etbcod  column-label "Filial"
     tt-lanaut.datlan  column-label "Data"
     tt-lanaut.lancod  column-label "Conta"
     tt-lanaut.lanhis  column-label "Historico"
     tt-lanaut.comhis  column-label "Complemento" format "x(45)"
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
               
def var vlancod like lanaut.lancod.
def var vlanhis like lanaut.lanhis.
def var vcomhis like lanaut.comhis.

                                                                                
disp "                  ULTIMO LANÇAMENTO CONTABIL       " 
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
        &file = tt-lanaut  
        &cfield = tt-lanaut.etbcod
        &noncharacter = /* 
        &ofield = " tt-lanaut.datlan
                    tt-lanaut.lancod
                    tt-lanaut.lanhis
                    tt-lanaut.comhis "  
        &aftfnd1 = " "
        &where  = " "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  altera"" or
                           esqcom2[esqpos2] = ""altera tudo""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenhum registro encontrado.""
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
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        update tt-lanaut.lancod
               tt-lanaut.lanhis
               tt-lanaut.comhis 
               with frame f-linha.
        
        find last   lanaut where   
                            lanaut.etbcod = tt-lanaut.etbcod and
                            lanaut.forcod = tt-lanaut.forcod 
                             no-error.
        if avail lanaut
        then do transaction:
            assign
                lanaut.lancod = tt-lanaut.lancod
                lanaut.lanhis = tt-lanaut.lanhis
                lanaut.comhis = tt-lanaut.comhis
                .
        end.
    END.
    if esqcom1[esqpos1] = "Altera tudo"
    THEN DO:

        update vlancod
               vlanhis
               vcomhis 
               with frame f-linha1 centered row 8 1 down
               side-label overlay.
    
        sresp = no.
        message "Confirma alterar todos os ultimos lançamentos?"
        update sresp.

        if sresp
        then do:
            for each tt-lanaut:
                find last   lanaut where   
                            lanaut.etbcod = tt-lanaut.etbcod and
                            lanaut.forcod = tt-lanaut.forcod 
                             no-error.
                if avail lanaut
                then do transaction:
                    assign
                        lanaut.lancod = vlancod
                        lanaut.lanhis = vlanhis
                        lanaut.comhis = vcomhis
                        .
                end.
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


