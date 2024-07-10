def input param poperacao as char.
{admcab.i}
{iep/tfilsel.i}
def var vsel as int.
def var vabe as dec.

def temp-table ttcontnum no-undo
    field contnum as int.
    
def var vin as int.

   def var vi as int. def var ctpcontrato as char.
    
   def var varqin  as char format "x(65)".
    def var vcobout like cobra.cobcod label "Carteira".
   def var vcp  as char init ";".
    pause 0.
    

    run get_file.p ("/admcom/tmp/iep/","csv",output varqin).
    
    disp skip(2) varqin  label "Entrada" colon 10
            skip(2) 
                   with frame fx
        centered 
        overlay
        side-labels
        color messages
        row 4
        with title "ARQUIVO CSV COM LISTA DE  CONTRATOS".
        
if search(varqin) = ?
then do:
    message "arquivo" varqin "nao encontrado".
    pause.
    return.
end.    


hide message no-pause.
message "importando arquivo" varqin.

for each ttcontnum.
    delete ttcontnum.
end.
pause 0 before-hide.
input from value(varqin).
repeat transaction on error undo , next.
    create ttcontnum.
    import delimiter ";" ttcontnum.contnum no-error.
    if ttcontnum.contnum = 0 or ttcontnum.contnum = ? or error-status:error
    then do:
        delete ttcontnum.
        next.
    end.    
end.
input close.

pause before-hide.
for each ttcontnum where ttcontnum.contnum = 0 or ttcontnum.contnum = ? . 
    delete ttcontnum.
end.
for each ttcontnum break by ttcontnum.contnum.
    
    if first-of(ttcontnum.contnum) 
    then do:
        run iep/pavalctrsel.p   (poperacao, ttcontnum.contnum,yes,input-output vsel, input-output vabe).
        next.
    end.    

    delete ttcontnum.
end.    
hide frame fx no-pause.
pause 0 before-hide.     

    

    
    




