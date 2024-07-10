/*                          
*
*    tbclube.p    -    Esqueleto de Programacao    com esqvazio


            substituir    tbclube
                          cli
*
*/

def var setbcod-aux     as integer.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Consulta "," "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de tbclube ",
             " Consulta Participante ",
             "  ",
             "  ",
             "  "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def buffer btbclube       for tbclube.
def var vtbclube         like tbclube.clicod.
def var vmail-ok          as logical.

def temp-table tt-tbclube like tbclube.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
                 
form
    tt-tbclube.etbcod       label "Filial"           at 10     skip
    tt-tbclube.funcod       label "Cod. Func"        at 07    
    func.funnom          no-label                    at 29          skip 
    tt-tbclube.funmat       label "Matricula"        at 07     skip
 /* tt-tbclube.tpassoc      label "Tipo Associado"   at 02     skip  */
    tt-tbclube.clicod       label "Cod.Cliente"      at 05    
    clien.clinom         no-label                           skip
    tt-tbclube.email        label "E-mail" format "x(50)"    at 10  skip
    tt-tbclube.char1  label "Celular" format "(99) 9999-9999"  at 09    skip
/*  tt-tbclube.pontuacao    label "Pontuacao"        at 07    skip  */
/*  tt-tbclube.modalidade   label "Modalidade"       at 06    skip  */
        with frame f-tt-tbclube side-labels
                            color black/cyan
                          centered row 5 .

                 
form
    tbclube.etbcod       label "Filial"           at 10     skip
    tbclube.funcod       label "Cod. Func"        at 07     
    func.funnom       no-label                    at 29     skip
    tbclube.funmat       label "Matricula"        at 07     skip
/*  tbclube.tpassoc      label "Tipo Associado"   at 02     skip */
    tbclube.clicod       label "Cod.Cliente"      at 05    
    clien.clinom      no-label                              skip
    tbclube.email        label "E-mail"           at 10     skip
    tbclube.char1      label "Celular"          at 09     skip
/*  tbclube.pontuacao    label "Pontuacao"        at 07     skip */
/*  tbclube.modalidade   label "Modalidade"       at 06     skip */
    tbclube.dtinclu      label "Data Cad" at 08   skip
            with frame f-tbclube side-labels
                        color black/cyan
                                  centered row 5 .


form
    setbcod-aux format ">>9" label "Filial"
    with frame f-etbcod-aux overlay centered side-label title "Digite o código da filial." row 10.

if setbcod = 999
then do:
    
    assign esqcom1[3] = " Alteracao "
           esqcom1[4] = " Exclusao " .

    update setbcod-aux 
                with frame f-etbcod-aux.

end.
else assign setbcod-aux = setbcod.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tbclube where recid(tbclube) = recatu1 no-lock.
        
        find first clien where clien.clicod = tbclube.clicod no-lock no-error.
        
    if not available tbclube
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tbclube).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tbclube
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
            find tbclube where recid(tbclube) = recatu1 no-lock.
            
            find first clien where clien.clicod = tbclube.clicod
                                no-lock no-error. 

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tbclube.funcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tbclube.funcod)
                                        else "".
            run color-message.
            choose field /*clien.clinom*/ tbclube.etbcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) /* color white/black */.
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
                    if not avail tbclube
                    then leave.
                    recatu1 = recid(tbclube).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tbclube
                    then leave.
                    recatu1 = recid(tbclube).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tbclube
                then next.
                color display white/red /*clien.clinom*/ tbclube.etbcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tbclube
                then next.
                color display white/red tbclube.etbcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            /*
            form tbclube
                 with frame f-tbclube color black/cyan
                      centered side-label row 5 .
            */          
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-tbclube on error undo.
                    
                    release tt-tbclube.                                        

                    empty temp-table tt-tbclube.

                    create tt-tbclube.
                    
                    do on error undo, retry: 
                    
                        update tt-tbclube.etbcod.    
                        
                        if not can-find (first estab
                                         where estab.etbcod = tt-tbclube.etbcod)
                        then do:
                        
                            message "Codigo de Filial inválido, pressione F7"                                     +       " para pesquisar.".
                                    
                            undo, retry.
                                    
                        end.
                        
                        update tt-tbclube.funcod.
                        
                        if not can-find (first func
                                         where func.etbcod = tt-tbclube.etbcod
                                           and func.funcod = tt-tbclube.funcod)
                        then do:
                        
                            message "Código de Funcionário inválido, pressione "
                                    "F7 para pesquisar".
                        
                            undo, retry.
                        end.
                        else do:
                        
                            find first func
                                 where func.etbcod = tt-tbclube.etbcod 
                                   and func.funcod = tt-tbclube.funcod
                                        no-lock no-error.
                                        
                            display func.funnom.
                            
                        end.
                        
                        update tt-tbclube.funmat.
                            
                     /* update tt-tbclube.tpassoc.  */
                           
                        update tt-tbclube.clicod.
                            
                        if not can-find(first clien
                                        where clien.clicod = tt-tbclube.clicod)
                        then do:
                                            
                            message "Código de cliente inválido, pressione F7"                                     " para pesquisar.".
                                                    
                            undo, retry.                
                                            
                        end.
                        else do:
                                   
                            find first clien
                                 where clien.clicod = tt-tbclube.clicod                                                      no-lock no-error.
                            display clien.clinom.               
                                            
                        end.                    
                            
                        update tt-tbclube.email.
                        
                        assign vmail-ok = no.
                        
                        run pfval_mail2.p (input  tt-tbclube.email,
                                           output vmail-ok) no-error.
                        if not vmail-ok and tt-tbclube.email <> "" 
                        then do:
                                                   
                            message "E-mail inválido.".
                            undo,retry.                       
                                                   
                        end.                           
                        
                        update tt-tbclube.char1.
                        
                        if tt-tbclube.char1 = ""
                        then do:
                        
                            message "O campo celular tem preenchimento"
                                     " obrigatório.".
                                    
                            undo, retry.

                        end.
                        
                     /* update tt-tbclube.pontuacao 
                               tt-tbclube.modalidade
                                  with frame f-tt-tbclube. */
                    
                    end.
                    
                    create tbclube.
                    
                    assign tt-tbclube.nomclube = "ClubeBis"
                           tt-tbclube.dtinclu = today 
                            .             
                                
                    buffer-copy tt-tbclube to tbclube.
                    
                    release tt-tbclube.

                    clear frame f-tt-tbclube.
                                
                    recatu1 = recid(tbclube).
                    
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tbclube.
                    find first func where func.etbcod = tbclube.etbcod
                                      and func.funcod = tbclube.funcod
                                            no-lock no-error.
                                            
                    find first clien where clien.clicod = tbclube.clicod
                                            no-lock no-error.
                
                    disp tbclube.etbcod   
                         tbclube.funcod    
                         func.funnom when avail func
                         tbclube.funmat    
                      /* tbclube.tpassoc    */
                         tbclube.clicod    
                         clien.clinom when avail clien
						 clien.ciccgc when avail clien label "CPF"
						 clien.dtnasc when avail clien label "Dt Nasc"
                         tbclube.email     
                         tbclube.char1   
                      /* tbclube.pontuacao   */
                      /* tbclube.modalidade  */
                         tbclube.dtinclu
                           with frame f-tbclube.
                
                end.
                
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-tbclube on error undo.
                    find tbclube where
                            recid(tbclube) = recatu1 
                        exclusive.
                    
                    empty temp-table tt-tbclube.
                    
                    create tt-tbclube.
                    
                    buffer-copy tbclube to tt-tbclube.
                    
                    do on error undo, retry: 
                    
                        update tt-tbclube.etbcod.    
                        
                        if not can-find (first estab
                                         where estab.etbcod = tt-tbclube.etbcod)
                        then do:
                        
                            message "Codigo de Filial inválido, pressione F7"  ~                                   +       " para pesquisar.".
                                    
                            undo, retry.
                                    
                        end.
                        
                        update tt-tbclube.funcod.
                        
                        if not can-find (first func
                                         where func.etbcod = tt-tbclube.etbcod
                                           and func.funcod = tt-tbclube.funcod)
                        then do:
                        
                            message "Código de Funcionário inválido, pressione "
                                    "F7 para pesquisar".
                        
                            undo, retry.
                        end.
                        
                        update tt-tbclube.funmat.
                        /*    
                        update tt-tbclube.tpassoc.
                        */   
                        update tt-tbclube.clicod.
                            
                        if not can-find(first clien
                                        where clien.clicod = tt-tbclube.clicod)
                        then do:
                                            
                            message "Código de cliente inválido, pressione F7" ~                                    " para pesquisar.".
                                                    
                            undo, retry.                
                                            
                        end.                    
                            
                        update tt-tbclube.email.
                        
                        update tt-tbclube.char1.
                        
                        if tt-tbclube.char1 = ""
                        then do:
                        
                            message "O campo celular tem preenchimento"
                                     " obrigatório.".
                                    
                            undo, retry.

                        end.
                        /*
                        update tt-tbclube.pontuacao 
                               tt-tbclube.modalidade
                                  with frame f-tt-tbclube. */
                    
                    end.
                    
                    buffer-copy tt-tbclube to tbclube no-error.
                    
                    release tt-tbclube.
                    
                    empty temp-table tt-tbclube.
                    
                end.
                
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" clien.clinom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tbclube where tbclube.nomclube = "ClubeBis"                                 no-error.
                    if not available tbclube
                    then do:
                        find tbclube where recid(tbclube) = recatu1.
                       find prev tbclube where tbclube.nomclube = "ClubeBis"                                     no-error.
                    end.
                    recatu2 = if available tbclube
                              then recid(tbclube)
                              else ?.
                    find tbclube where recid(tbclube) = recatu1
                            exclusive.
                    delete tbclube.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run ltbclube.p (input 0).
                    else run ltbclube.p (input tbclube.clicod).
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
        recatu1 = recid(tbclube).
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

find first clien where clien.clicod = tbclube.clicod no-lock no-error.

display tbclube.etbcod     column-label "Fil"     
        tbclube.clicod     label "Cod.Cliente"
        clien.clinom       format "x(25)"
        tbclube.funcod     column-label "Func"         
        tbclube.funmat     column-label "Matricula"       
    /*  tbclube.tpassoc    column-label "Tipo Assoc"   format "x(10)" */
    /*  tbclube.email        label "E-mail"       */
        tbclube.char1      label "Celular"       format "x(14)"
    /*  tbclube.pontuacao    label "Pontuacao"    */
    /*  tbclube.modalidade   label "Modalidade"    format "x(10)" */
        with frame frame-a 11 down centered color white/red row 5 width 75.
end procedure.
procedure color-message.
color display message
        tbclube.etbcod    
        tbclube.clicod
        clien.clinom
        tbclube.funcod    
        tbclube.funmat    column-label "Matricula"
/*      tbclube.tpassoc    */
        tbclube.char1      format "x(14)"
/*        tbclube.pontuacao 
        tbclube.modalidade */
        with frame frame-a width 75.
end procedure.
procedure color-normal.
color display normal
        tbclube.etbcod    
        tbclube.funcod    
        tbclube.funmat     column-label "Matricula"
/*      tbclube.tpassoc    */
        tbclube.clicod    
        clien.clinom
        tbclube.char1    format "x(14)"
/*      tbclube.pontuacao 
        tbclube.modalidade   */
        with frame frame-a width 75.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do: 
    if esqascend  
    then do: 
        find first tbclube where tbclube.etbcod  = setbcod-aux
                             and tbclube.nomclube = "ClubeBis" no-lock no-error.
                                                
        find first clien where clien.clicod = tbclube.clicod no-lock no-error.                                        
    end.
    else do: 
        find last tbclube where tbclube.etbcod = setbcod-aux
                            and tbclube.nomclube = "ClubeBis" no-lock no-error.
        
        find first clien where clien.clicod = tbclube.clicod no-lock no-error.
        
    end.                                         

end.
if par-tipo = "seg" or par-tipo = "down" 
then do: 
    if esqascend  
    then do: 
        find next tbclube where tbclube.etbcod = setbcod-aux
                            and tbclube.nomclube = "ClubeBis" no-lock no-error.
        
        find first clien where clien.clicod = tbclube.clicod no-lock no-error.
                                                
    end.                                            
    else do: 
        find prev tbclube where tbclube.etbcod = setbcod-aux
                            and tbclube.nomclube = "ClubeBis" no-lock no-error.
        
        find first clien where clien.clicod = tbclube.clicod no-lock no-error.
                                                
    end.         
end.
if par-tipo = "up" 
then do:                 
    if esqascend   
    then do:  
        find prev tbclube where tbclube.etbcod = setbcod-aux
                            and tbclube.nomclube = "ClubeBis" no-lock no-error.
                                        
        find first clien where clien.clicod = tbclube.clicod no-lock no-error.
                                                   
    end.
    else do:  
        find next tbclube where tbclube.etbcod = setbcod-aux
                            and tbclube.nomclube = "ClubeBis" no-lock no-error.
                                     
        find first clien where clien.clicod = tbclube.clicod no-lock no-error.                                
    end.                                    
end.        
end procedure.
         
