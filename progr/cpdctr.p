/*
*
*    cpd-controle.p    -    Esqueleto de Programacao    com esqvazio


            substituir    cpd-controle
                          <tab>
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Listagem "," OK ", ""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de cpd-controle ",
             " Alteracao da cpd-controle ",
             " Exclusao  da cpd-controle ",
             " Consulta  da cpd-controle ",
             " Listagem  Geral de cpd-controle "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def buffer bcpd-controle       for cpd-controle.
def var vcpd-controle         like cpd-controle.etbcod.


form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

run verifica.    
    

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find cpd-controle where recid(cpd-controle) = recatu1 no-lock.
    if not available cpd-controle
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(cpd-controle).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available cpd-controle
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find cpd-controle where recid(cpd-controle) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(cpd-controle.etbcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(cpd-controle.etbcod)
                                        else "".
            run color-message.
            choose field cpd-controle.etbcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) color white/black.
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
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
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail cpd-controle
                    then leave.
                    recatu1 = recid(cpd-controle).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cpd-controle
                    then leave.
                    recatu1 = recid(cpd-controle).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cpd-controle
                then next.
                color display white/red cpd-controle.etbcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cpd-controle
                then next.
                color display white/red cpd-controle.etbcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form cpd-controle
                 with frame f-cpd-controle color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) format ">>>>9" esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    run  listagem.
                    leave.
                end.
                if esqcom1[esqpos1] = " OK "
                then do on error undo.
                     find cpd-controle where recid(cpd-controle) = recatu1.
                     cpd-controle.impsit  = yes.
                     recatu1 = ?. 
                     leave.
                end.


            end.
            else do:
                display caps(esqcom2[esqpos2]) format ">>>>9" esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.            
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(cpd-controle).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
display Cpd-controle.etbcod  no-label format ">9"
        Cpd-controle.contcli  column-label "cli" format ">>>>>9"
        cpd-controle.contcli <> cpd-controle.icontcli format "/*"
        Cpd-controle.contcon  column-label "ctr" format ">>>>>9"               cpd-controle.contcon <> cpd-controle.icontcon format "/*"
        Cpd-controle.contest  column-label "est" format ">>>>>9"
        cpd-controle.contest <> cpd-controle.icontest format "/*"
        Cpd-controle.contmov  column-label "mov" format ">>>>>9"
        cpd-controle.contmov <> cpd-controle.icontmov format "/*"
        Cpd-controle.contpla  column-label "pla" format ">>>>>9"
        cpd-controle.contpla <> cpd-controle.icontpla format "/*"
        Cpd-controle.contpro  column-label "pro" format ">>>>>9"       
        cpd-controle.contpro <> cpd-controle.icontpro format "/*"
        Cpd-controle.conttit  column-label "tit" format ">>>>>9"
        cpd-controle.conttit <> cpd-controle.iconttit format "/*"
        Cpd-controle.DtExp    column-label "exp" format "99999999"

/*        Cpd-controle.Dtini    column-label "dti" format "99999999"*/
/*        Cpd-controle.iDtini   no-label           format "99999999"*/
/*        Cpd-controle.Dtfim    column-label "dtf" format "99999999"*/
/*        Cpd-controle.iDtfim   no-label           format "99999999"*/
/*        Cpd-controle.ImpSit   no-label            */
 
 
        with frame frame-a 11 down centered color white/red row 5 
                    no-box.
end procedure.
procedure color-message.
color display message
        cpd-controle.etbcod
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        cpd-controle.etbcod
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first cpd-controle where cpd-controle.impsit = no
                                                no-lock no-error.
    else  
        find last cpd-controle  where cpd-controle.impsit = no
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next cpd-controle  where cpd-controle.impsit = no
                                                no-lock no-error.
    else  
        find prev cpd-controle   where cpd-controle.impsit = no
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev cpd-controle where cpd-controle.impsit = no  
                                        no-lock no-error.
    else   
        find next cpd-controle where cpd-controle.impsit = no
         
                                        no-lock no-error.
        
end procedure.

procedure listagem   .
{mdadmcab.i &Saida     = "printer" 
            &Page-Size = "64" 
            &Cond-Var  = "160" 
            &Page-Line = "66" 
            &Nom-Rel   = ""cpdctr"" 
            &Nom-Sis   = """SISTEMA transmissao""" 
            &Tit-Rel   = """listagem de conferencia importacao lojas """
            &Width     = "160" 
            &Form      = "frame f-cabcab1"}

for each cpd-controle where impsit = no no-lock
                    break by etbcod.
        disp Cpd-controle.etbcod  label "Etb" format ">>9"
                Cpd-controle.ImpSit   no-label format "Ok/N"           
        
        Cpd-controle.contcli   column-label "Clientes" format ">>>>>9"
        Cpd-controle.icontcli  column-label "Imp" format ">>>>>9"
        cpd-controle.contcli <> cpd-controle.icontcli format "/*"

        Cpd-controle.contest  column-label "Estoque" format ">>>>>9"
        Cpd-controle.icontest column-label "Imp" format ">>>>>9"
        cpd-controle.contest <> cpd-controle.icontest format "/*"
        
        Cpd-controle.contmov  column-label "Movim" format ">>>>>9"
        Cpd-controle.icontmov  column-label "Imp" format ">>>>>9"
        cpd-controle.contmov <> cpd-controle.icontmov format "/*"
        
        Cpd-controle.contpla  column-label "Plani" format ">>>>>9"
        Cpd-controle.icontpla  column-label "Imp" format ">>>>>9"
        cpd-controle.contpla <> cpd-controle.icontpla format "/*"
        
        Cpd-controle.contpro  column-label "Produ" format ">>>>>9"       
        Cpd-controle.icontpro  column-label "Imp" format ">>>>>9"       
        cpd-controle.contpro <> cpd-controle.icontpro format "/*"
        
        Cpd-controle.conttit  column-label "Titulo" format ">>>>>9"
        Cpd-controle.iconttit  column-label "Imp" format ">>>>>9"
        cpd-controle.conttit <> cpd-controle.iconttit format "/*"
        
        Cpd-controle.DtExp    column-label "Dt.Exp" format "99999999"

        Cpd-controle.Dtini    column-label "Dt.Ini" format "99999999"
        Cpd-controle.iDtini   column-label "Imp"    format "99999999"
        Cpd-controle.Dtfim    column-label "Dt.Fim" format "99999999"
        Cpd-controle.iDtfim   column-label "Imp"    format "99999999"
        with frame flin down width 260.
                            

end.
output close.
recatu1 = ?.
end procedure.

def temp-table tt-etb
    field etbcod    like estab.etbcod
    index etbcod is primary unique etbcod asc.


procedure verifica.
input from ./controle.cpd no-echo.
repeat transaction.
   create tt-etb.
   import tt-etb.
end.
input close.
for each cpd-controle /*where cpd-controle.impsit = yes*/ .
    find tt-etb where tt-etb.etbcod = cpd-controle.etbcod
                    no-error.
    if not avail tt-etb
    then do:
        cpd-controle.impsit = yes.
        next.
    end.                             
    if cpd-controle.conttit = cpd-controle.iconttit and
       cpd-controle.contcli = cpd-controle.icontcli and
       cpd-controle.contpro = cpd-controle.icontpro and
       cpd-controle.contest = cpd-controle.icontest
    then cpd-controle.impsit = yes.
end.
end procedure.


         
