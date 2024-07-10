{admcab.i}

{setbrw.i}                                                                      

def var vnomes as char extent 12 
    init["JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO",
         "JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"].
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Consulta","  Inclui","  Altera",""].
def var esqcom2         as char format "x(15)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

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

def temp-table tt-meta
    field setcod like metadesp.setcod
    field valor  like metadesp.metval
    field valgrupo as dec
    field valmodal as dec.

def var vsetcod like setor.setcod.
update vsetcod  label "Setor"
       with frame f-cba 1 down width 80
       side-label.
if vsetcod > 0
then do:
    find first setaut where setaut.setcod = vsetcod no-lock.
    disp setaut.setnom no-label with frame f-cba.
end.
else disp "Todos os setores" @ setaut.setnom with frame f-cba.

def var vano as int.
vano = year(today).
update vano label "Ano" format "9999" with frame f-cba.
form " " 
     tt-meta.setcod  column-label "Setor"
     setaut.setnom   no-label      format "x(25)"
     tt-meta.valor  column-label "Valor Mes"    format ">>,>>>,>>9.99"
     tt-meta.valgrupo column-label "Grupo Mod." format ">>,>>>,>>9.99" 
     tt-meta.valmodal column-label "Modalidade" format ">>,>>>,>>9.99"
     " "
     with frame f-linha 11 down color with/cyan /*no-box*/
     .

def var vdes-f1 as char.  

vdes-f1 =  " *** ANO: " + STRING(VANO) + " *** " +
     "  CONTROLE DE DESPESAS  -  " + 
     if vsetcod <> 0
     then SETAUT.SETNOM else ""  .
      
disp vdes-f1         
         FORMAT "X(80)"
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
    
def var t-valmeta as dec.
def var t-valmeta1 as dec.
def var t-valmeta2 as dec.
disp "                T O T A L          " 
    t-valmeta  format ">>,>>>,>>9.99"
    t-valmeta1 format ">>,>>>,>>9.99"
    t-valmeta2 format ">>,>>>,>>9.99"
    with frame f2 1 down width 80 color message no-box no-label            
    row 20 . 

procedure cria-tt-meta:

for each tt-meta: 
    delete tt-meta.
end.
def buffer bmetadesp for metadesp.
for each bmetadesp where bmetadesp.etbcod = setbcod and
                         bmetadesp.metano = vano and
                       (if vsetcod > 0
                        then bmetadesp.setcod = vsetcod else true)
                        no-lock:
    find first tt-meta where  
               tt-meta.setcod = bmetadesp.setcod
               no-error .
    if not avail tt-meta
    then do:
        create tt-meta.
        tt-meta.setcod = bmetadesp.setcod.
    end.
    if bmetadesp.modcod = "" and
       bmetadesp.modgru = ""
    then do:
        tt-meta.valor = tt-meta.valor + bmetadesp.metval.    
        t-valmeta = t-valmeta + bmetadesp.metval.
    end.
    else do:
        if bmetadesp.modcod = ""
        then do: 
            tt-meta.valgrupo = tt-meta.valgrupo + bmetadesp.metval.    
            t-valmeta1 = t-valmeta1 + bmetadesp.metval.
        end.
        else do:
            tt-meta.valmodal = tt-meta.valmodal + bmetadesp.metval.    
            t-valmeta2 = t-valmeta2 + bmetadesp.metval.
        end.
    end.
end.               

end procedure.

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
    
    run cria-tt-meta.

    disp vdes-f1
         with frame f1.
    pause 0.
    disp t-valmeta 
         t-valmeta1 with frame f2.
    pause 0.
        
    {sklclstb.i  
        &color = with/cyan
        &file = tt-meta  
        &cfield = tt-meta.setcod
        &noncharacter = /* 
        &ofield = " setaut.setnom when avail setaut
                    tt-meta.valor 
                    tt-meta.valgru
                    tt-meta.valmodal "  
        &aftfnd1 = " find setaut where
                          setaut.setcod = tt-meta.setcod no-lock no-error.
                   "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom1[esqpos1] = ""  Inclui"" or
                           esqcom1[esqpos1] = ""  Altera"" or
                           esqcom1[esqpos1] = ""  consulta""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  bell.
                         sresp = no.
                         message 
                         ""Nenhum registro encontrato. Incluir ?""
                         update sresp.
                         if sresp
                         then do:
                            run metadespm.p ( vsetcod, vano, """" ).
                         end.
                         else leave l1.
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
    THEN do:
        scroll from-current down with frame f-linha.
        repeat on error undo:
            clear frame f-linha.
            prompt-for tt-meta.setcod with frame f-linha.
            find setaut where 
                setaut.setcod = 
                input frame f-linha tt-meta.setcod no-lock no-error.
            if not avail setaut
            then do:
                message "Setor nao cadatrado.".
                pause.
                undo.
            end.    
            create tt-meta.
            tt-meta.setcod = input frame f-linha tt-meta.setcod.
            leave.
        end.
        if keyfunction(lastkey) = "end-error"
        then.
        else run metadespm.p ( tt-meta.setcod, vano, "" ).
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        run metadespm.p ( tt-meta.setcod, vano, "" ).
    END.
    if esqcom1[esqpos1] = "  CONSULTA"
    THEN DO:
        run metadespm.p ( tt-meta.setcod, vano, "Consulta" ).        
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

