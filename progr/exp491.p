def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".



def var vcep  as char format "x(08)".
def var vcgc  as char format "x(14)".
def var vinsc as char format "x(14)".
def var ii as int.

def var varquivo as char format "x(40)".
def temp-table tt-forne
    field forcod like forne.forcod. 



repeat:


    update vdti label "Periodo"
           vdtf no-label
           varquivo label "Caminho" with frame f1 side-label width 80.



    output to value(varquivo).
    
    for each lanfor where lanfor.datope >= vdti and
                          lanfor.datope <= vdtf no-lock:
                         

        find tt-forne where tt-forne.forcod = int(lanfor.clifor) no-error.
        if not avail tt-forne
        then do:

            create tt-forne.
            assign tt-forne.forcod = int(lanfor.clifor).
            
        end.

    end.
    
    for each tt-forne:
    
        find forne where forne.forcod = tt-forne.forcod no-lock no-error.
        if not avail forne
        then next.
                    
  
        
        ii = 0.  
        vcgc = "".
        
            
        do ii = 1 to 20:  
        
            if substring(forne.forcgc,ii,1) = "." or
               substring(forne.forcgc,ii,1) = "-" or
               substring(forne.forcgc,ii,1) = "/"
            then. 
            else vcgc = vcgc + substring(forne.forcgc,ii,1).
        
        end.


        
        ii = 0.  
        vinsc = "".
        
            
        do ii = 1 to 20:  
        
            if substring(forne.forinest,ii,1) = "." or
               substring(forne.forinest,ii,1) = "-" or
               substring(forne.forinest,ii,1) = "/"
            then. 
            else vinsc = vinsc + substring(forne.forinest,ii,1).
        
        end.

        
        ii = 0.  
        vcep = "".
        
            
        do ii = 1 to 20:  
        
            if substring(forne.forcep,ii,1) = "." or
               substring(forne.forcep,ii,1) = "-" or
               substring(forne.forcep,ii,1) = "/"
            then. 
            else vcep = vcep + substring(forne.forcep,ii,1).
        
        end.





            
        
        
        put day(today) format "99"
            "/"
            month(today) format "99"
            "/"
            substr(string(year(today)),3,2) format "99"
            string(forne.forcod) format "x(14)"
            vcgc  format "x(14)"
            vinsc format "x(14)"
            " "   format "x(14)"
            forne.fornom format "x(70)"
            forne.forrua format "x(45)"
            string(forne.fornum) format "x(05)"
            forne.forcomp format "x(10)" 
            forne.forbairro format "x(20)"
            forne.formunic  format "x(20)"
            forne.ufecod    format "x(2)"
            " "             format "x(20)"
            vcep            format "x(08)"
            skip.
             
            
        
                              
    end.
end.
                                        
                                        
