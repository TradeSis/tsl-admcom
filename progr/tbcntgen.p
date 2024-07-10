{admcab.i}
{cntgendf.i}
{setbrw.i}    

def var vesc as char format "x(15)" extent 2
    init["  GUARDIAN"," INFORMATIVO"].
def var vindex as int.    
disp vesc with frame f-esc 1 down no-label centered.
choose field vesc with frame f-esc.
vindex = frame-index.
    
hide frame f-esc no-pause.

def var p-tipo as char.

def var vsenha as char format "x(10)".

update vsenha blank label "Senha"
       with frame f-senha centered side-labels. 
           
hide frame f-senha no-pause.

if vsenha = "dg@lebes"  and vindex = 1
then.
else if vsenha = "info@lebes" and vindex = 2
    then.
    else return.
 
if vindex = 1
then p-tipo = "GUARDIAN".
if vindex = 2
then p-tipo = "INFORMATIVO".

def var e-mail as char extent 9 format "x(40)".                               
def var v as char.                                                              
form " "                            
     tbcntgen.etbcod    format ">>>9"    column-label "Cod"
     tbcntgen.campo1[1] format "x(30)"  column-label "Descricao"
     tbcntgen.campo1[2] format "x(29)"  column-label "Processamento"
     " "
     with frame f-linha 13 down color with/cyan no-box.
                

disp "                  PARAMETROS CONTROLE " p-tipo format "x(15)"
            with frame f1 1 down width 80                                       
            color message no-box no-label.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 19.                                                                     
def buffer btbcntgen for tbcntgen.                                             def var i as int.
l1: repeat:
assign                                                                          
    a-seeid = -1 a-recid = -1 a-seerec = ?. 
hide frame f-linha no-pause.
{sklcls.i                                                                       
    &help = "F1=Altera  F4=Sair  F8=E-Mail  F9=Inclui"
    &file = tbcntgen                                                            
    &cfield = tbcntgen.campo1[1]
    &ofield = " tbcntgen.etbcod
                tbcntgen.campo1[2]
                tbcntgen.validade
              "  
    &where  = " tbcntgen.tipcon = 1 and
                tbcntgen.numini = p-tipo "
    &otherkeys = " tbcntgen.al " 
    &naoexiste = " tbcntgen.in "
    &abrelinha = " tbcntgen.in "                                               
    &locktype = "no-lock"
    &form   = " frame f-linha "                                                 
}   
if keyfunction(lastkey) = "end-error"
then DO:
    /*
    OUTPUT TO value(varq) .
    for each tbcntgen where tbcntgen.tipcon = 1 no-lock:
        export tbcntgen.
    end.
    output close.     
    */
    leave l1.       
END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.


