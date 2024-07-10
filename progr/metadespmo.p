{admcab.i}
{setbrw.i}                                                                      

def input parameter vsetcod like setor.setcod.
def input parameter vano as int.
def input parameter vmes as int.
def input parameter vtipo as char.

find setaut where setaut.setcod = vsetcod no-lock.

def var vnomes as char extent 12 
    init["JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO",
         "JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"]
    .
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Inclui","  Altera","  Exclui",""].
if vtipo = "Consulta"
then esqcom1 = "".

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

form " " 
     metadesp.modcod  column-label "Modalidade"
     modal.modnom no-label 
     metadesp.metval  column-label "Valor Meta" format ">>,>>>,>>9.99"
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
disp " *** MES/ANO: " + string(vmes) + "/" + STRING(VANO) + " *** " +
     "    -  " + SETAUT.SETNOM
         FORMAT "X(80)"
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
/**                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
**/
def var t-valmeta as dec.
disp "                                        " 
    t-valmeta label "T O T A L " format ">>,>>>,>>9.99"
     "      "
    with frame f2 1 down width 80 color message no-box no-label            
    row 20 side-label.  
    
def buffer bmetadesp for metadesp.
l1: repeat:
    clear frame f-com1 all.
    clear frame f-com2 all.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    hide frame f-linha no-pause.
    clear frame f-linha all.

    t-valmeta = 0.
    for each bmetadesp where bmetadesp.etbcod = setbcod and
                             bmetadesp.setcod = vsetcod and
                             bmetadesp.modgru = "" and
                             bmetadesp.modcod <> "" and
                             bmetadesp.metano = vano and
                             bmetadesp.metmes = vmes 
                        no-lock:
        t-valmeta = t-valmeta + bmetadesp.metval.
    end. 
    disp t-valmeta  with frame f2.
    pause 0.

    {sklclstb.i  
        &color = with/cyan
        &file = metadesp  
        &cfield = metadesp.modcod
        &noncharacter = /* 
        &ofield = " modal.modnom when avail modal
                    metadesp.metval
                    "  
        &aftfnd1 = " find modal where 
                          modal.modcod = metades.modcod no-lock no-error.
                          "
        &where  = " metadesp.etbcod = setbcod and
                    metadesp.modgru = """" and
                    metadesp.modcod <> """" and
                    metadesp.setcod = vsetcod and
                    metadesp.metano = vano and
                    metadesp.metmes = vmes 
                    "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom1[esqpos1] = ""  inclui"" or
                           esqcom1[esqpos1] = ""  altera""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  
            if vtipo = ""consulta""
            then do:
                message color red/with
                ""Nenhum registro encontrado.""
                view-as alert-box.
                leave l1.
            end.
                
                    scroll from-current down with frame f-linha.
                    create metadesp.
                    update metadesp.modcod
                            with frame f-linha.
                    find first bmetadesp where
                               bmetadesp.etbcod = setbcod and
                               bmetadesp.setcod = vsetcod and
                               bmetadesp.modgru = """" and 
                               bmetadesp.modcod = metadesp.modcod  and
                               bmetadesp.metano = vano and
                               bmetadesp.metmes = vmes
                               no-lock no-error.
                    if avail bmetadesp
                    then do:
                        bell.
                        message color red/with
                        ""Registro meta ja exite para modalidade.""
                        view-as alert-box.
                        leave l1.
                    end.           
                    find modal where modal.modcod =
                        metadesp.modcod no-lock no-error.
                    if not avail modal
                    then do:
                        message color red/with
                        ""Modalidade nao cadatrada.""
                        view-as alert-box.
                        leave l1.
                    end.
                    metadesp.modcod = caps(metadesp.modcod).
                    disp    metadesp.modcod
                            modal.modnom with frame f-linha.
                    update metadesp.metval with frame f-linha.
                    metadesp.etbcod = setbcod.
                    metadesp.setcod = vsetcod.
                    metadesp.metano = vano.
                    metadesp.metmes = vmes.     
                    next l1.
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

        scroll from-current down with frame f-linha.
        do on error undo:
                    create metadesp.
                    update metadesp.modcod
                            with frame f-linha.
                    find modgru where
                         modgru.modcod = metadesp.modcod and
                         modgru.mogsup > 0
                         no-lock no-error.
                    if not avail modgru
                    then do:
                        bell.
                        message color red/with
                        "Classe informada nao esta associada ao grupo"
                        view-as alert-box.
                        undo.
                    end.
                         
                    find first bmetadesp where
                               bmetadesp.etbcod = setbcod and
                               bmetadesp.setcod = vsetcod and
                               bmetadesp.modgru = "" and 
                               bmetadesp.modcod = metadesp.modcod  and
                               bmetadesp.metano = vano and
                               bmetadesp.metmes = vmes
                               no-lock no-error.
                    if avail bmetadesp
                    then do:
                        bell.
                        message color red/with
                        "Registro meta ja exite para modalidade"
                        view-as alert-box.
                        undo.
                    end. 
                    find modal where modal.modcod =
                        metadesp.modcod no-lock no-error.
                    if not avail modal
                    then do:
                        message color red/with
                        "Modalidade nao cadatrada."
                        view-as alert-box.
                        undo.
                    end.
                    metadesp.modcod = caps(metadesp.modcod).
                    disp metadesp.modcod
                         modal.modnom with frame f-linha.
                    update metadesp.metval with frame f-linha.
                    metadesp.etbcod = setbcod.
                    metadesp.setcod = vsetcod.
                    metadesp.metano = vano.
                    metadesp.metmes = vmes. 
            end.    
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        update metadesp.metval with frame f-linha.
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        sresp = no.
        message "Confirma excluir?" update sresp.
        if sresp
        then do:
            delete metadesp.
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

