def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".

def var varquivo as char format "x(40)".



repeat:


    update vdti label "Periodo"
           vdtf no-label
           varquivo label "Caminho" with frame f1 side-label width 80.



    output to value(varquivo).
    
    for each lanfor where lanfor.datope >= vdti and
                          lanfor.datope <= vdtf no-lock:
                         

        put lanfor.conta format "x(28)".
        
        put string(lanfor.clifor) format "x(14)"
            day(lanfor.datope) format "99"
            "/"
            month(lanfor.datope) format "99"
            "/"
            substr(string(year(lanfor.datope)),3,2) format "99"
            lanfor.histo format "x(50)"
            (lanfor.valope * 100) format ">>>>>>>>>>>>>>>>>".
            

        put lanfor.tipope.

        put lanfor.tipdoc.
        
        put lanfor.numdoc format "x(12)". 
        
        put (lanfor.valtit * 100) format ">>>>>>>>>>>>>>>>>".
        
        put day(lanfor.datemi) format "99"
            "/"
            month(lanfor.datemi) format "99"
            "/"
            substring(string(year(lanfor.datemi)),3,2) format "99".


        put day(lanfor.datven) format "99"
            "/"
            month(lanfor.datven) format "99"
            "/"
            substring(string(year(lanfor.datven)),3,2) format "99".

        put lanfor.numarq.
        put skip.
        
        
        

        
                              
    end.
end.
                                        
                                        
