{admcab.i}
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
    initial ["","  Inclui","  Altera","  Exclui"," Relatorio"].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","  Filiais","","",""].
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


def buffer dprodu for produ.
def var vestmin as dec.

form prosubst.procod column-label "Substituido"
     produ.pronom no-label  format "x(20)"
     prosubst.prosub column-label "Substituto"
     dprodu.pronom no-label format "x(20)"
     prosubst.estmin column-label "Minimo" format ">>>9"
     prosubst.situacao column-label "Sit" format "x"
     with frame f-linha 11 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
disp "                       MANUTENÇÃO PRODUTO SUBSTITUTO       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

esqcom1[1] = "   ==>> ".
esqcom2[1] = "   ==>> ".
color disp message  esqcom1[1] with frame f-com1.
l1: repeat:
    disp with frame f1.
    disp with frame f2.
    clear frame f-com1 all.
    clear frame f-com2 all.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if esqregua 
    then do:
        color disp message esqcom1[esqpos1] with frame f-com1.
        color disp normal esqcom2[esqpos2] with frame f-com2.
    end.
    else do:
        color disp message esqcom2[esqpos2] with frame f-com2.
        color disp normal esqcom1[esqpos1] with frame f-com1.
    end.

    {sklclstb.i  
        &color = with/cyan
        &file = prosubst  
        &cfield = prosubst.procod
        &noncharacter = /* 
        &ofield = " produ.pronom
                    prosubst.prosub
                    dprodu.pronom
                    prosubst.estmin 
                    prosubst.situacao
                    "  
        &aftfnd1 = " find produ where produ.procod = prosubst.procod
                        no-lock no-error. 
                     find dprodu where dprodu.procod = prosubst.prosub
                        no-lock no-error.
                        "
        &where  = " prosubst.tipo = ""G"" and
                    prosubst.situacao <> ""EXC"" "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  FILIAIS""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenhum registro encontrado.""
                        view-as alert-box.
                        esqpos1 = 2.
                        esqcom1[esqpos1] = ""  INCLUI"".
                        run aftselect.
                        if keyfunction(lastkey) = ""end-error""
                        then leave keys-loop.
                        else next l1.
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
    def buffer bprodu for produ.
    def buffer cprodu for produ.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        prompt-for prosubst.procod label "Substituido"
                with frame f-inclui side-label centered.
        find bprodu where bprodu.procod = input prosubst.procod
                no-lock no-error .
        if avail bprodu
        then disp bprodu.pronom no-label with frame f-inclui.
        else undo.        
        prompt-for prosubst.prosub label "Substituto "
                   with frame f-inclui.
        find cprodu where cprodu.procod = input prosubst.prosub
                        no-lock no-error.
        if avail cprodu
        then disp cprodu.pronom no-label with frame f-inclui.
        else undo.     
        vestmin = 3.                   
        update vestmin label "Quantidade minima"
                with frame f-inclui.
        create prosubst.
        assign
            prosubst.tipo = "G"
            prosubst.etbcod = 0
            prosubst.procod = input prosubst.procod
            prosubst.prosub = input prosubst.prosub
            prosubst.estmin = vestmin
            prosubst.datinclu = today
            prosubst.horinclu = time
            prosubst.datexp = today
            prosubst.exportado = no
            prosubst.situacao = "B"
                .

    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        update prosubst.estmin
               prosubst.situacao
                with frame f-linha
                .
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        sresp = no.
        MESSAGE "Confirma excluir? " update sresp.
        if sresp
        then prosubst.situacao = "EXC" .   
    END.
    if esqcom1[esqpos1] = " Relatorio"
    THEN DO:
        run relatorio.
    END.

    if esqcom2[esqpos2] = "  Filiais"
    THEN DO on error undo:
        
        run prosubst-fil.p(recid(prosubst)) .
        esqregua = no.
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
    then varquivo = "/admcom/relat/prosubst." + string(time).
    else varquivo = "..~\relat~\prosubst."  + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """   CONTROLE PRODUTO SUBSTITUTO  """ 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    for each prosubst where prosubst.situacao <> "EXC" /*and
                            prosubst.tipo = "G" */
            no-lock:
        
        find produ where produ.procod = prosubst.procod no-lock no-error.
        find dprodu where dprodu.procod = prosubst.prosub no-lock no-error.
        
        disp prosubst.etbcod column-label "Fil"
             prosubst.procod column-label "Substituido"
             produ.pronom no-label  format "x(20)"
             prosubst.prosub column-label "Substituto"
             dprodu.pronom no-label format "x(20)"
             prosubst.estmin column-label "Minimo" format ">>>9"
             prosubst.situacao column-label "Sit" format "x"
                with frame f-disp down width 110 .
 
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

