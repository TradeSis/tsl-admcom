def var vsenha as char format "x(10)".
{admcab.i}
{setbrw.i}                                                                      
def var e-mail as char extent 9 format "x(40)".                               
def var v as char.                                                              
form " "                            
     tbcntgen.etbcod    format ">>9"    column-label "Filial"
     estab.etbnom no-label
     tbcntgen.validade format "99/99/9999"  column-label  "Validade"
     " "
     with frame f-linha 13 down color with/cyan no-box
     centered.
                                                                         
                                                                                
disp "               BLOQUEIO DO SERIAL NA VENDA DE CELULAR  "
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
    &help = "ENTER=Altera F4=Sair F9=Inclui F10=Exclui"
    &file = tbcntgen                                                            
    &cfield = tbcntgen.etbcod
    &noncharacter = /*
    &ofield = " estab.etbnom when avail estab
                tbcntgen.validade
              "  
    &aftfnd1 = "
        find estab where 
             estab.etbcod = tbcntgen.etbcod no-lock no-error.
        "
    &where  = " tbcntgen.tipcon = 4 "
    &aftselect1 = " update tbcntgen.validade
                        with frame f-linha. " 
    &naoexiste1 = " create tbcntgen.
                    assign
                        tbcntgen.tipcon = 4 
                        . 
                    
                    update tbcntgen.etbcod with frame f-linha.
                    find estab where 
                         estab.etbcod = tbcntgen.etbcod no-lock no-error.
                    if not avail estab
                    then do:
                        message   ""Filial nao cadatrada."".
                        pause.
                        undo, next l1.
                    end.
                    disp estab.etbnom with frame f-linha.
                    update 
                           tbcntgen.validade
                           with frame f-linha.
                        "
    &abrelinha1 = " 
                    scroll from-current down with frame f-linha.
                    create tbcntgen.
                    assign
                        tbcntgen.tipcon = 4 
                        . 
                    
                    update tbcntgen.etbcod with frame f-linha.
                    find estab where 
                         estab.etbcod = tbcntgen.etbcod no-lock no-error.
                    if not avail estab
                    then do:
                        message   ""Filial nao cadatrada."".
                        pause.
                        undo, next l1.
                    end.
                    disp estab.etbnom with frame f-linha.
                    update 
                           tbcntgen.validade 
                           with frame f-linha.
 
                    " 
    &otherkeys1 = "
                if keyfunction(lastkey) = ""DELETE-LINE"" or
                   keyfunction(lastkey) = ""CUT""
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


