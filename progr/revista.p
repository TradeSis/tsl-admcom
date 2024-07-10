{admcab.i}
{setbrw.i}                                                                      

DEF VAR SETBANT AS INT.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  INCLUI","  ALTERA","  EXCLUI",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
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

form " " 
    revista.etbcod  column-label "Fil"
    revista.datini  column-label "Periodo"
    revista.datfim  no-label
    revista.proco   column-label "Produto"
    produ.pronom    no-label format "x(25)"
    revista.tolerancia  column-label "Tolerancia"
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered width 80.
                                                                         
                                                                                
disp "                  PRODUTOS DA REVISTA   " 
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
        &color = with/cyan
        &file = revista  
        &cfield = revista.etbcod
        &noncharacter = /* 
        &ofield = " revista.datini
                    revista.datfim
                    revista.procod
                    produ.pronom when avail produ
                    revista.tolerancia
                   "  
        &aftfnd1 = " find produ where produ.procod = revista.procod
                        no-lock no-error. "
        &where  = " "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  do on error undo.
                    scroll from-current down with frame f-linha.
                    create revista.
                    
                    revista.datini = date(month(today),01,year(today)). 
                    revista.datfim = date(if month(today) = 12 then 1
                        else month(today) + 1,01,if month(today) = 12
                        then year(today) + 1 else year(today)) - 1.
                        
                    update 
                        revista.etbcod 
                        revista.datini validate(revista.datini <> ?,
                                    ""Informe a data corretamente."")
                        revista.datfim validate(revista.datfim <> ? and
                                    revista.datfim >= revista.datini,
                                    ""Informe a data corretamente."")
                        revista.procod 
                        with frame f-linha.
                        
                    find produ where produ.procod = revista.procod 
                                    no-lock no-error.
                    if not avail produ
                        then do:
                            message ""Produto nao cadatrado"".
                            pause.
                            next keys-loop.
                        end.  
                    disp produ.pronom with frame f-linha.
                    
                    revista.tolerancia = 30.
                    update revista.tolerancia
                        with frame f-linha.
                      
                    next keys-loop.
                                         end." 
        &otherkeys1 = " run controle. "
        &locktype = " no-lock "
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
    def buffer brevista for revista.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo: 
                    scroll from-current down with frame f-linha.
                    create revista.
                    
                    revista.datini = date(month(today),01,year(today)). 
                    revista.datfim = date(if month(today) = 12 then 1
                        else month(today) + 1,01,if month(today) = 12
                        then year(today) + 1 else year(today)) - 1.
                     
                    update 
                        revista.etbcod 
                        revista.datini 
                        revista.datfim 
                        with frame f-linha.
                    do on error undo:    
                    update    revista.procod 
                        with frame f-linha.
                    find produ where produ.procod = revista.procod 
                                    no-lock no-error.
                    if not avail produ
                        then do:
                            message "Produto nao cadatrado".
                            pause.
                            undo.
                        end.                  
                    disp produ.pronom with frame f-linha.
                    sresp = no.
                    run tem-mix.
                    if sresp = no
                    then do transaction:
                        message color red/with
                        "Produto nao faz parte do MIX DE PRODUTOS da filial."
                        VIEW-AS ALERT-BOX
                        .
                        NEXT.
                    end.
                    revista.tolerancia = 30.
                    update revista.tolerancia 
                        with frame f-linha.
                    end.
                    /***
                    find first brevista where 
                                brevista.etbcod = revista.etbcod and
                                        brevista.procod = revista.procod and
                                        brevista.datini = revista.datini and
                                        brevista.datfim = revista.datfim
                                        no-lock.
                    repeat on endkey undo, leave:
                        scroll from-current down with frame f-linha.
                        create revista.
                        assign
                            revista.etbcod = brevista.etbcod
                            revista.datini = brevista.datini 
                            revista.datfim = brevista.datfim
                            .
                        disp revista.etbcod
                             revista.datini
                             revista.datfim
                             with frame f-linha.
                        do on error undo:
                        update    

                            revista.procod  with frame f-linha.

                        find produ where produ.procod = revista.procod 
                                    no-lock no-error.
                        if not avail produ
                        then do:
                            message "Produto nao cadatrado".
                            pause.
                            undo.
                        end.    
                    
                        disp produ.pronom with frame f-linha.
                        revista.tolerancia = 30.
                        update revista.tolerancia 
                            with frame f-linha.
                        end.
                    end.       */            
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO on error undo:
        update 
                        revista.etbcod 
                        revista.datini 
                        revista.datfim 
                        revista.procod 
                        revista.tolerancia
                        with frame f-linha.
 
    
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO on error undo:
        
        sresp = no.
        message "Confirma EXCLUIR regsitro? " update sresp.
        if sresp
        then         DELETE REVISTA.
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

procedure tem-mix.
def buffer e-tabmix for tabmix.
def buffer p-tabmix for tabmix.
def var qtd-mix as dec.
def var qtd-min as dec.
def var tem-mix as log.
def var tem-min as log.
def var pro-mix as log.
def var pro-min as log.
def var dat-mix as date init ?.
def var dat-min as date init ?.
tem-mix = no.
tem-min = no.
pro-mix = no.
pro-min = no.
qtd-mix = 0.
qtd-min = 0.
tem-mix = yes.
                
for each tabmix where tabmix.tipomix = "M" and
                      tabmix.codmix  <> 99 no-lock:
    find first e-tabmix where e-tabmix.tipomix = "F" and
                       e-tabmix.codmix  = tabmix.codmix and
                       e-tabmix.promix  = com.produ.clacod 
                       no-lock no-error.
    if not avail e-tabmix
    then do:
         find first e-tabmix where 
                    e-tabmix.tipomix = "F" and
                    e-tabmix.codmix  = tabmix.codmix 
                    no-lock no-error.
         if avail e-tabmix
         then do:
             find first etbtam where 
                        etbtam.catcod = 31 and
                        etbtam.etbcod = e-tabmix.etbcod and
                        etbtam.situacao = "E"
                        no-lock no-error.
             if avail etbtam and
                (etbtam.tamanho = "M" or
                 etbtam.tamanho = "G" or
                 etbtam.tamanho = "GG")
             then do:
                tem-mix = no.
                leave.
             end.
             else next.
        end.
     end.    
     
     find first p-tabmix where p-tabmix.tipomix = "P" and
                             p-tabmix.codmix  = e-tabmix.codmix and
                             p-tabmix.promix  = com.produ.procod and
                             p-tabmix.etbcod = 0
                             no-lock no-error.
     if not avail p-tabmix
     then do:
         find first e-tabmix where 
                    e-tabmix.tipomix = "F" and
                    e-tabmix.codmix  = tabmix.codmix 
                    no-lock no-error.
         if avail e-tabmix
         then do:
             find first etbtam where 
                        etbtam.catcod = 31 and
                        etbtam.etbcod = e-tabmix.etbcod and
                        etbtam.situacao = "E"
                        no-lock no-error.
             if avail etbtam and
                (etbtam.tamanho = "M" or
                 etbtam.tamanho = "G" or
                 etbtam.tamanho = "GG")
             then do:
                tem-mix = no.
                leave.
             end.
        end.
     end.    
end.
if tem-mix = yes
then sresp = yes.

end procedure.
