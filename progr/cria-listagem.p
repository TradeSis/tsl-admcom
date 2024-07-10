def var vcont as int.
def var vcelular as char.
def var i as int.


output to ./listagem-fones-vivo2.txt.

for each rfvcli where rfvcli.nota = "554"
                   or rfvcli.nota = "553"
                   or rfvcli.nota = "545"
                no-lock break by rfvcli.valor desc.

     find clien where clien.clicod = rfvcli.clicod no-lock no-error.
     if not avail clien
     then next.

     /***spc***/
     find first clispc where clispc.clicod = clien.clicod 
                         and clispc.dtcanc = ? no-lock no-error.
     if avail clispc
     then next.
     /*********/

            
     if clien.fax begins "96" or
        clien.fax begins "97" or
        clien.fax begins "98" or
        clien.fax begins "99"
     then.
     else next.
     
     vcelular = "".
     do i = 1 to length(clien.fax):
     
        if substring(clien.fax,i,1) = "0" or
           substring(clien.fax,i,1) = "1" or
           substring(clien.fax,i,1) = "2" or
           substring(clien.fax,i,1) = "3" or
           substring(clien.fax,i,1) = "4" or
           substring(clien.fax,i,1) = "5" or
           substring(clien.fax,i,1) = "6" or
           substring(clien.fax,i,1) = "7" or
           substring(clien.fax,i,1) = "8" or
           substring(clien.fax,i,1) = "9"
        then   
            vcelular = vcelular + substring(clien.fax,i,1).


     end.
     
     vcont = vcont + 1.
     
     if vcont = 5001
     then leave.
     
     
     put "51" vcelular format "x(15)" skip.
     
     /*disp rfvcli.clicod clien.clinom format "x(20)" 
            clien.fax rfvcli.nota rfvcli.valor vcont.*/
     
end.
output close.

/*unix more ./listagem-fones.txt. */