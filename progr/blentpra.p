def var vsenha as char format "x(10)".
{admcab.i}
{setbrw.i}                                                                      
ON F9 NEW-LINE.
ON PF9 NEW-LINE.
def var e-mail as char extent 9 format "x(40)".                               
def var v as char.                                                              
form " "                            
     tbcntgen.numini    format "x(8)"    column-label "Fornecedor"
     forne.fornom no-label
     /*
     tbcntgen.valor     format ">>9"  column-label "Dias"
*/
     tbcntgen.validade format "99/99/9999"  column-label  "Validade"
     " "
     with frame f-linha 13 down color with/cyan no-box
     centered.
                                                                         
                                                                                
disp "               BLOQUEIO ENTRADA CELULAR COM ARQUIVO SERIAIS  "                            
            with frame f1 1 down width 80                                       
            color message no-box no-label.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 19.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.
l1: repeat:
assign                                                                          
    a-seeid = -1 a-recid = -1 a-seerec = ?. 
hide frame f-linha no-pause.
CLEAR FRAME F-LINHA ALL.
{sklcls.i                                                                       
    &help = "ENTER=Altera F4=Sair I=Inclui F10=Exclui"
    &file = tbcntgen                                                            
    &cfield = tbcntgen.numini
    &noncharacter = /*
    &ofield = " forne.fornom when avail forne
                tbcntgen.validade
              "  
    &aftfnd1 = "
        find forne where 
            forne.forcod = int(tbcntgen.numini) no-lock no-error.
        "
    &where  = " tbcntgen.tipcon = 2 "
    &aftselect1 = " update tbcntgen.validade
                        with frame f-linha. " 
    &naoexiste1 = " create tbcntgen.
                    assign
                        tbcntgen.tipcon = 2 
                        tbcntgen.etbcod = 0
                        . 
                    
                    update tbcntgen.numini 
                            with frame f-linha.
                    find forne where 
                         forne.forcod = int(tbcntgen.numini) no-lock no-error.
                    if not avail forne
                    then do:
                        message   ""Fornecedor nao cadatrado."".
                        pause.
                        undo, next l1.
                    end.
                    disp forne.fornom with frame f-linha.
                    update 
                           tbcntgen.validade
                           with frame f-linha.
                        "
    &abrelinha1 = " 
                    scroll from-current down with frame f-linha.
                    create tbcntgen.
                    assign
                        tbcntgen.tipcon = 2 
                        tbcntgen.etbcod = 0
                        . 
                    
                    update tbcntgen.numini label ""Fornecedor""
                        with frame f-linha1.
                    find forne where 
                         forne.forcod = int(tbcntgen.numini) no-lock no-error.
                    if not avail forne
                    then do:
                        message   ""Fornecedor nao cadatrado."".
                        pause.
                        undo, next l1.
                    end.
                    disp forne.fornom no-label with frame f-linha1.
                    update 
                           tbcntgen.validade label ""Validate""
                           with frame f-linha1 side-label centered
                           overlay color message row 10 1 column.
 
                    " 
    &otherkeys1 = "
                if keyfunction(lastkey) = ""DELETE-LINE""
                THEN DO:
                find tbcntgen where recid(tbcntgen) = a-seerec[frame-line]
                        .
                sresp = no.
                message ""Confirma EXCLUIR registro ?"" update sresp.
                if sresp
                then do:
                    delete tbcntgen.
                    next l1.
                end.
                END.
                if lastkey = keycode(""i"") or lastkey = keycode(""I"")
                then do:
                    run inclui.
                    next l1.
                end.
                        
               "                                                              
    &locktype = "no-lock"
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

procedure inclui:
                    scroll from-current down with frame f-linha.
                    create tbcntgen.
                    assign
                        tbcntgen.tipcon = 2 
                        tbcntgen.etbcod = 0
                        . 
                    
                    update tbcntgen.numini label "Fornecedor"
                        with frame f-linha1.
                    find forne where 
                         forne.forcod = int(tbcntgen.numini) no-lock no-error.
                    if not avail forne
                    then do:
                        message   "Fornecedor nao cadatrado.".
                        pause.
                    end.
                    else do:
                    disp forne.fornom no-label with frame f-linha1.
                    update 
                           tbcntgen.validade label "Validate"
                           with frame f-linha1 side-label centered
                           overlay color message row 10 1 column.
                    end.
                    
 end procedure.
