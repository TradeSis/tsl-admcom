{admcab.i}

def var vdata as date init today.
def var vtempo-atu as int.

def var vindex as int.

update vdata label "Dia" with frame f1 1 down side-label
width 80.

if vdata <= 09/20/11
then do:
    message color red/with
    "Controle iniciou em 21/09/2011"
    view-as alert-box.
    vdata = 09/21/11.
    disp vdata with frame f1.
end.    
    
vtempo-atu = 10.
update vtempo-atu label "      Tempo segundos atualiza tela"
    with frame f1.
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
    initial ["","","","",""].
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

def temp-table tt-tblogrep like tblogrep
    index i1 int1 descending etbcod ascending 
    .


form  
     with frame f-linha 10 down color with/cyan /*no-box*/
     column 30 width 50 overlay.
                                                                         
                                                                                
disp "            TEMPO DE REPLICAÇÃO POR FILIAL       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

for each tblogrep where tblogrep.tipo = "REPLICA" and
                        tblogrep.data = vdata and
                        tblogrep.banco = ""
                        no-lock .
    create tt-tblogrep.
    buffer-copy tblogrep to tt-tblogrep.
    tt-tblogrep.char1 = string(time,"hh:mm:ss").
    tt-tblogrep.char2 = string(tt-tblogrep.tempo,"hh:mm:ss").
    tt-tblogrep.char3 = string(time - tt-tblogrep.tempo,"hh:mm:ss").
end.    
def var vtotal as int extent 7.
vindex = 7.
def var vmarca as char extent 7 format "x(4)".
vmarca[7] = "==>>".

def var vtime as int.

l1: repeat:
    for each tt-tblogrep: delete tt-tblogrep. end.
    vtotal = 0.
    
    if vdata = today
    then vtime = time.
    else vtime = 0.
    for each estab where
             estab.etbcod < 400  and
             estab.etbcgc <> "" no-lock:
        create tt-tblogrep.
        tt-tblogrep.etbcod = estab.etbcod.
    end.
             
    for each tt-tblogrep by tt-tblogrep.etbcod:
        find first tblogrep where tblogrep.tipo = "REPLICA" and
                        tblogrep.etbcod = tt-tblogrep.etbcod and
                        tblogrep.data = vdata and
                        tblogrep.banco = ""
                        no-lock no-error .
        if avail tblogrep
        then buffer-copy tblogrep to tt-tblogrep.
        tt-tblogrep.char1 = string(vtime,"hh:mm:ss").
        tt-tblogrep.char2 = string(tt-tblogrep.tempo,"hh:mm:ss").
        tt-tblogrep.char3 = string(vtime - tt-tblogrep.tempo,"hh:mm:ss").
        
        if (vtime - tt-tblogrep.tempo) < 1800
        then assign
                vtotal[1] = vtotal[1] + 1
                 tt-tblogrep.int1 = 1
                .
        else if (vtime - tt-tblogrep.tempo) < 3600
            then assign 
                    vtotal[2] = vtotal[2] + 1
                    tt-tblogrep.int1 = 2
                    .
            else if (vtime - tt-tblogrep.tempo) < 7200
                then assign
                        vtotal[3] = vtotal[3] + 1
                        tt-tblogrep.int1 = 3
                        .
                else if (vtime - tt-tblogrep.tempo) < 10800
                    then assign
                            vtotal[4] = vtotal[4] + 1
                            tt-tblogrep.int1 = 4
                            .
                    else if (vtime - tt-tblogrep.tempo) < 14400
                        then assign
                                vtotal[5] = vtotal[5] + 1
                                tt-tblogrep.int1 = 5
                                .
                        else assign
                                vtotal[6] = vtotal[6] + 1
                                tt-tblogrep.int1 = 6
                                .
        vtotal[7] = vtotal[7] + 1.
                
    end. 
    for each tt-tblogrep:
        if vindex <> 7 and
           tt-tblogrep.int1 <> vindex
        then delete tt-tblogrep.
    end.       
    vmarca = "".
    vmarca[vindex] = "==>>".
    clear frame f-total all.
    disp vtotal[1] label "Abaixo de 30 min "  format ">>9"
         vmarca[1] no-label
         vtotal[2] label "Abaixo de 1 hora "  format ">>9"
         vmarca[2] no-label
         vtotal[3] label "Abaixo de 2 horas"  format ">>9"
         vmarca[3] no-label
         vtotal[4] label "Abaixo de 3 horas"  format ">>9"
         vmarca[4] no-label
         vtotal[5] label "Abaixo de 4 horas"  format ">>9"
         vmarca[5] no-label
         vtotal[6] label "Acima  de 4 horas"  format ">>9"
         vmarca[6] no-label
         vtotal[7] label "Todas as filiais "  format ">>9"
         vmarca[7] no-label
         with frame f-total side-label
         overlay width 29.
    pause 0.     
    color disp message vtotal[vindex] 
                       vmarca[vindex] with frame f-total.
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstp.i  
        &color = with/cyan
        &help = "TAB = Filtro   F4 = Sair"
        &file = tt-tblogrep  
        &cfield = tt-tblogrep.etbcod
        &pause = vtempo-atu 
        &noncharacter = /* 
        &ofield = " estab.etbnom no-label format ""x(15)""
                    tt-tblogrep.char1 column-label ""Proces"" 
                    tt-tblogrep.char2 column-label ""Replica""
                    tt-tblogrep.char3 column-label ""Difer""  
                      "  
        &aftfnd1 = " find estab where estab.etbcod = tt-tblogrep.etbcod
                            no-lock no-error.
                            "
        &where  = " true use-index i1 no-lock"
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if keyfunction(lastkey) = ""TAB""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenhum registro encontrado.""
                        view-as alert-box.
                        vindex = 7 .
                        next l1.
                        "
                         
        &otherkeys1 = " run controle.
                        if keyfunction(lastkey) = """" or
                           keyfunction(lastkey) = ""RETURN""
                                   then next l1. 
                        "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        hide frame f-total.
        hide frame f-disp.
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  Filtro"
    THEN DO on error undo:

    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
    
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
                clear frame f-linha all. 
                vmarca[vindex] = "".
                disp vmarca[vindex]  with frame f-total.
                color disp normal vtotal[vindex] 
                                  vmarca[vindex]
                                  with frame f-total.
                choose field vtotal with frame f-total.

                vindex = frame-index.
                
                vmarca[vindex] = "==>>".

                disp vmarca[vindex]  with frame f-total.
                pause 0.

                /**
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
                */
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

