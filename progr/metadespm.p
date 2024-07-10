{admcab.i}
{setbrw.i}                                                                      

def input parameter vsetcod like setor.setcod.
def input parameter vano as int.
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
    initial ["","  Inclui","  Altera","  ","  Modalidade"].
if vtipo = "Consulta"
then esqcom1 = "".

def var esqcom2         as char format "x(15)" extent 5
            initial ["","  Exclui","","",""].
if vtipo = "Consulta"
then assign esqcom1 = "" esqcom2 = "" 
        esqcom1[2] = "" /*"  Grupo Mod"*/
        esqcom1[3] = "  Modalidade".

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

def var val-meta-modal as dec.
def var val-meta-grupo as dec.
form " " 
     metadesp.metmes  column-label "Mes"
     vdesmes as char no-label   format "x(15)"
     metadesp.metval  column-label "Valor Mes"   format ">>,>>>,>>9.99"
     val-meta-grupo   column-label "Grupo Mod."  format ">>,>>>,>>9.99"
     val-meta-modal   column-label "Modalidade" format ">>,>>>,>>9.99"
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
def var vdisp-f1 as char.                                                                                
vdisp-f1 = " *** ANO: " + STRING(VANO) + " *** " +
     "  CONTROLE DE DESPESAS  -  " + SETAUT.SETNOM .
disp vdisp-f1          FORMAT "X(80)"
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
/**                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
**/
def var t-valmeta as dec.
def var t-valmeta1 as dec.
def var t-valmeta2 as dec.
disp "       T O T A L            " 
    t-valmeta                     format ">>,>>>,>>9.99"
    t-valmeta1  no-label          format ">>,>>>,>>9.99"                 
    t-valmeta2  no-label          format ">>,>>>,>>9.99"
    with frame f2 1 down width 80 color message no-box no-label            
    row 20 .  
    
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
    t-valmeta1 = 0.
    t-valmeta2 = 0.
    for each bmetadesp where bmetadesp.etbcod = setbcod and
                             bmetadesp.setcod = vsetcod and
                             bmetadesp.metano = vano
                        no-lock:
        if bmetadesp.modcod = "" and
           bmetadesp.modgru = ""
        then t-valmeta = t-valmeta + bmetadesp.metval.
        else do:
            if bmetadesp.modcod = ""
            then t-valmeta1 = t-valmeta1 + bmetadesp.metval.
            else t-valmeta2 = t-valmeta2 + bmetadesp.metval.
        end.
    end. 
    disp vdisp-f1 with frame f1.
    disp t-valmeta 
         t-valmeta1 
         t-valmeta2 with frame f2.
    pause 0.

    {sklclstb.i  
        &color = with/cyan
        &file = metadesp  
        &cfield = metadesp.metmes
        &noncharacter = /* 
        &ofield = " vnomes[metadesp.metmes] @ vdesmes
                    metadesp.metval
                    val-meta-grupo
                    val-meta-modal
                    "  
        &aftfnd1 = " 
            val-meta-grupo = 0.
            val-meta-modal = 0.
            for each bmetadesp where 
                     bmetadesp.etbcod = setbcod and
                     bmetadesp.setcod = vsetcod and
                     (bmetadesp.modgru <> """" or
                      bmetadesp.modcod <> """") and
                     bmetadesp.metano = vano and
                     bmetadesp.metmes = metadesp.metmes
                     no-lock:
                if bmetadesp.modcod = """"
                then val-meta-grupo = val-meta-grupo + bmetadesp.metval.
                else val-meta-modal = val-meta-modal + bmetadesp.metval.
            end.         
        "
        &where  = " metadesp.etbcod = setbcod and
                    metadesp.setcod = vsetcod and
                    metadesp.modgru = """" and
                    metadesp.modcod = """" and
                    metadesp.metano = vano "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom1[esqpos1] = ""  inclui"" or
                           esqcom1[esqpos1] = ""  altera"" or
                           esqcom1[esqpos1] = ""  Modalidade"" or
                           esqcom1[esqpos1] = ""  Grupo Mod""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  
                    scroll from-current down with frame f-linha.
                    create metadesp.
                    update metadesp.metmes
                            with frame f-linha.
                    disp vnomes[metadesp.metmes] @ vdesmes
                            with frame f-linha.
                    update metadesp.metval
                           with frame f-linha.
                    metadesp.etbcod = setbcod.
                    metadesp.setcod = vsetcod.
                    metadesp.metano = vano.      
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
                    create metadesp.
                    update metadesp.metmes
                            with frame f-linha.
                    disp vnomes[metadesp.metmes] @ vdesmes
                            with frame f-linha.
                    update metadesp.metval
                           with frame f-linha.
                    metadesp.etbcod = setbcod.
                    metadesp.setcod = vsetcod.
                    metadesp.metano = vano.      
        
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        update metadesp.metval with frame f-linha.
        /*
        if metadesp.metval = 0
        then run metadespmo.p ( vsetcod, vano, metadesp.metmes, """" ).
        */
    END.
    if esqcom1[esqpos1] = "  GRUPO MOD"
    THEN DO:
        if vtipo = "Consulta"
        then run metadespmg.p ( vsetcod, vano, metadesp.metmes, "Consulta" ).
        else run metadespmg.p ( vsetcod, vano, metadesp.metmes, "" ).
    END.
    if esqcom1[esqpos1] = "  MODALIDADE"
    THEN DO:
        if vtipo = "consulta"
        then run metadespmo.p ( vsetcod, vano, metadesp.metmes, "Consulta" ).
        else run metadespmo.p ( vsetcod, vano, metadesp.metmes, "" ).
    END.
    if esqcom2[esqpos2] = "  EXCLUI"
    THEN DO:
        sresp = no.
        message "Confirma excluir?" update sresp.
        if sresp
        then do:
            delete metadesp.
        end.
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

