
{admcab.i}

def buffer btbpromoc for tbpromoc.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclui","Altera","Imprime","",""]
            .
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
esqregua  = yes.
esqpos1  = 1.
esqpos2  = 1.

bl-princ:
repeat:

    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then find first tbpromoc no-lock no-error.
    else find tbpromoc where recid(tbpromoc) = recatu1 no-lock no-error.

    if not available tbpromoc
    then do:
        sresp = no.
        message "Nenhum registro encontrado. Deseja incluir ? "
        update sresp.
        if not sresp
        then  leave bl-princ.  
        else do on endkey undo, leave bl-princ.  
            create tbpromoc.
            tbpromoc.promocod = 1.
            disp tbpromoc.promocod with frame f-inclu 1 down
                centered side-label row 10.
            update tbpromoc.descricao at 1  
                with frame f-inclu.
            tbpromoc.descricao = caps(tbpromoc.descricao).            
        end.
    end.

    clear frame frame-a all no-pause.
    
    display tbpromoc.promocod 
            tbpromoc.descricao  
            with frame frame-a 13 down centered.

    recatu1 = recid(tbpromoc).
    
    color display message esqcom1[esqpos1] with frame f-com1.

    repeat:
    
        find next tbpromoc no-lock no-error.
        
        if not available tbpromoc
        then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        down with frame frame-a.
        
        display tbpromoc.promocod
                tbpromoc.descricao
            with frame frame-a.

    end.
    
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
        find tbpromoc where recid(tbpromoc) = recatu1 no-error.

        choose field tbpromoc.descricao go-on(cursor-down cursor-up 
                                         cursor-left cursor-right 
                                         tab PF4 F4 ESC return).

        if keyfunction(lastkey) = "TAB"
        then do:
        
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 6
                          then 6
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        
        if keyfunction(lastkey) = "cursor-down"
        then do:
        
            find next tbpromoc
                        no-lock no-error.
            
            if not avail tbpromoc
            then next.
            
            color display normal tbpromoc.descricao.
            
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.

        end.

        if keyfunction(lastkey) = "cursor-up"
        then do:
        
            find prev tbpromoc
                            no-lock no-error.
            if not avail tbpromoc
            then next.
            
            color display normal tbpromoc.descricao.
            
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
            
        end.
        
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        
        hide frame frame-a no-pause.

        if esqregua
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Imprime"
            then do:
                sresp = no.
                message "Confirma Imprimir ?" update sresp.
                if sresp then run relatorio.
                recatu1 = recid(tbpromoc).
                leave.
            end.
            
            if esqcom1[esqpos1] = "Inclui"
            then do on endkey undo, next bl-princ:
                find last btbpromoc no-lock.
                create tbpromoc.
                tbpromoc.promocod = btbpromoc.promocod + 1.
                disp tbpromoc.promocod with frame f-inclu.
                update tbpromoc.descricao 
                    with frame f-inclu.
                tbpromoc.descricao = caps(tbpromoc.descricao).
                recatu1 = recid(tbpromoc).
                leave.
            end.
            
            if esqcom1[esqpos1] = "Altera"
            then do: 
                disp tbpromoc.promocod with frame f-inclu.
                update tbpromoc.descricao with frame f-inclu.
                tbpromoc.descricao = caps(tbpromoc.descricao).
                recatu1 = recid(tbpromoc).
                leave.
            end.
        end. 
        else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
        end.
          view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        display tbpromoc.promocod
            tbpromoc.descricao
            with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tbpromoc).
   end.
end.

procedure relatorio:
    
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "../relat/prom" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999").
    else varquivo = "..\relat\prom" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999").
                                  
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""tbpromoc"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """LISTAGEM DE PROMOCOES""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    for each tbpromoc:
        disp tbpromoc.promocod
             tbpromoc.descricao
            with frame f-disp down width 80.
        down with frame f-disp.    
    end.
    
    output close.

    IF opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"")       .
    end.
    else do:
        {mrod.i}
    end.

end procedure.

