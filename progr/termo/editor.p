def input param prec as recid.
{termo/mnemo.i}

do transaction:

find termos where recid(termos) = prec exclusive.    

/*copy-lob from file 
    "/u/bsweb/progr/app/termos/BILHETES/carnedeparcelas.txt" to termos.termo.
*/
def var vtexto as longchar no-undo.

copy-lob from termos.termo to vtexto.

repeat.    
    update  vtexto
    help "CTRL-d Deleta Linha, ENTER no inicio INSERE LINHA, F7 para mnemos"
    
    VIEW-AS EDITOR LARGE INNER-LINES 16 INNER-CHARS 66 
         go-on (f7 pf7 f4 pf4 f8 PF8)

 WITH FRAME ftexto WIDTH 68
 no-box no-labels centered
 row 4.
    
    if keyfunction(lastkey) = "END-ERROR"
    then do:
        leave.
    end.        
    if keyfunction(lastkey) = "RECALL"   or
      keyfunction(lastkey) = "HELP"
    then do:
        hide frame ftexto no-pause.
        for each ttmnemos.
            disp ttmnemos
                with row 4 centered overlay
                12 down.
        end.            
        pause.
    end.        
         
     
end.  
copy-lob from vtexto to termos.termo.



end.

hide frame ftexto no-pause.


