/* helio 01112022 - Relatório porcentagem por filial - gerar csv */
{admcab.i}
def input parameter par-etbcod  like ctdescat.etbcod.


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Consulta "," ", " "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de ctdescat ",
             " Alteracao da ctdescat ",
             " Exclusao  da ctdescat ",
             " Consulta  da ctdescat ",
             " Listagem  Geral de ctdescat "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


def buffer bctdescat      for ctdescat.


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

find estab where estab.etbcod = par-etbcod no-lock no-error.
disp par-etbcod estab.etbnom when avail estab
    with frame fcab no-box side-labels width 80 color messages row 3.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find ctdescat where recid(ctdescat) = recatu1 no-lock.
    if not available ctdescat
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(ctdescat).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ctdescat
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
            find ctdescat where recid(ctdescat) = recatu1 no-lock.
            find categoria of ctdescat no-lock.

            /*status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(ctdescat.<tab>nom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(ctdescat.<tab>nom)
                                        else "".
            
            */
            
            if par-etbcod = 0
            then do:
                esqcom1[1] = "".
                esqcom1[4] = " csv".
            end.    
            else do:
                esqcom1[1] = " Inclusao".
                esqcom1[4] = "".
            end.    
             
            disp esqcom1 with frame f-com1. 
            
            run color-message.
            
            choose field ctdescat.etbcod
                         ctdescat.catcod
                         categoria.catnom
                         ctdescat.descmax 
                         ctdescat.descmed ctdescat.margemregional
                help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
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
                    if not avail ctdescat
                    then leave.
                    recatu1 = recid(ctdescat).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ctdescat
                    then leave.
                    recatu1 = recid(ctdescat).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ctdescat
                then next.

                color display white/red ctdescat.etbcod
                                        ctdescat.catcod 
                                        ctdescat.descmax ctdescat.margemregional
                                        ctdescat.descmed with frame frame-a.
                         
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ctdescat
                then next.

                color display white/red ctdescat.etbcod
                                        ctdescat.catcod  
                                        ctdescat.descmax ctdescat.margemregional
                                        ctdescat.descmed with frame frame-a.
                                        
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:

            form skip(1)
                 space(3) ctdescat.etbcod  label "Filial........." skip
                 space(3) ctdescat.catcod  label "Categoria......" categoria.catnom no-label skip
                 space(3) ctdescat.descmax label "Desconto Máximo Produto" skip
                 space(3) ctdescat.descmed label "Margem Loja" 
                 space(3) ctdescat.margemregional
                 space(3) skip(1)
                 with frame f-ctdescat color black/cyan
                      centered side-label row 8 .
                      
            hide frame frame-a no-pause.

            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-ctdescat on error undo.
                    
                    create ctdescat.
                    ctdescat.etbcod = par-etbcod.
                    disp ctdescat.etbcod.
                    update  ctdescat.catcod  .
                    find categoria where categoria.catcod = ctdescat.catcod no-lock no-error.
                    if not avail categoria
                    then do:
                        message "categoria invalida".
                        undo.
                    end.
                    disp categoria.catnom .
                    update    
                           ctdescat.descmax 
                           ctdescat.descmed
                           ctdescat.margemregional.
                           
                    recatu1 = recid(ctdescat).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-ctdescat.

                        
                    disp ctdescat.etbcod 
                         ctdescat.catcod 
                         categoria.catnom
                         ctdescat.descmax
ctdescat.margemregional                         
                         ctdescat.descmed.
                    
                end.

                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-ctdescat on error undo.
                    find ctdescat where
                            recid(ctdescat) = recatu1 exclusive.
                            
                    update 
                           ctdescat.descmax 
                           ctdescat.descmed
                           ctdescat.margemregional.
                           
                end.

                if esqcom1[esqpos1] = " csv"
                then do:
                    def var vconfirma as log format "Sim/Nao".
                    
                    message "confirma gerar arquivo?" update vconfirma. 
                    
                    run geracsv.
                    leave.

                end.
                
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
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
        recatu1 = recid(ctdescat).
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
    find categoria where categoria.catcod = ctdescat.catcod no-lock no-error.
    display ctdescat.etbcod   column-label "Filial"
            ctdescat.catcod   column-label "Categoria"
            categoria.catnom  no-label when avail categoria
            ctdescat.descmax  column-label "Desconto!Máximo!Produto"
            ctdescat.descmed  column-label "Margem!Loja"
            ctdescat.margemregional

            with frame frame-a 8 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message ctdescat.etbcod 
                          ctdescat.catcod 
                          ctdescat.descmax  ctdescat.margemregional
                          ctdescat.descmed with frame frame-a.
end procedure.

procedure color-normal.
    color display normal ctdescat.etbcod 
                         ctdescat.catcod 
                         ctdescat.descmax ctdescat.margemregional
                         ctdescat.descmed with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first ctdescat where 
                    (if par-etbcod = 0
                     then true
                     else ctdescat.etbcod = par-etbcod)
                                                no-lock no-error.
    else  
        find last ctdescat  where 
                    (if par-etbcod = 0
                     then true
                     else ctdescat.etbcod = par-etbcod)
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next ctdescat  where 
                    (if par-etbcod = 0
                     then true
                     else ctdescat.etbcod = par-etbcod)
                                                no-lock no-error.
    else  
        find prev ctdescat   where 
                     (if par-etbcod = 0
                     then true
                     else ctdescat.etbcod = par-etbcod)
        
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev ctdescat where 
                    (if par-etbcod = 0
                     then true
                     else ctdescat.etbcod = par-etbcod)
                                        no-lock no-error.
    else   
        find next ctdescat where 
                    (if par-etbcod = 0
                     then true
                     else ctdescat.etbcod = par-etbcod)
        
                                        no-lock no-error.
        
end procedure.
         



procedure geraCSV.
def var pordem as int.
 
def var varqcsv as char format "x(65)".
varqcsv = "/admcom/relat/desconto_" + 
                string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
    
    
disp varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "csv desconto"
                            overlay.


message "Aguarde...". 
pause 1 no-message.

output to value(varqcsv).

put unformatted
    "Filial;Categoria;Desconto Maximo Produto;Margem Loja;Margem Regional;"
    skip.
    
    for each ctdescat no-lock.
        find categoria where categoria.catcod = ctdescat.catcod no-lock no-error.
        put unformatted
            ctdescat.etbcod   ";"
            categoria.catnom  ";"
            trim(string(ctdescat.descmax,">>>>>>>>>9.99"))  ";"
            trim(string(ctdescat.descmed,">>>>>>>>>9.99"))  ";"
            trim(string(ctdescat.margemregional,">>>>>>>>>9.99"))  ";"
            
            skip.
    end.     

output close.

pause 5.

end procedure.


