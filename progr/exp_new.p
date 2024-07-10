{admcab.i}
def input parameter vetbcod like estab.etbcod.
def input parameter vpedtdc like pedid.pedtdc.
def input parameter vcomnom like compr.comnom.
def var varq as char.

if opsys = "UNIX"
then varq =  "/admcom/newfree/" +  string(year(today),"9999") + 
             string(month(today),"99") + 
             string(day(today),"99") + ".ped".
             
else varq =  "l:~\newfree~\" +  string(year(today),"9999") + 
             string(month(today),"99") + 
             string(day(today),"99") + ".ped".
       
output to value(varq).
    for each pedid where pedid.pedtdc = vpedtdc and
                         pedid.etbcod = vetbcod and
                         pedid.peddat = today   and
                         pedid.clfcod = 5027 no-lock:
        
        for each liped of pedid no-lock:
            find produ where produ.procod = liped.procod no-lock.
            
            for each lipgra of liped no-lock:
                put unformatted
                    pedid.pednum format "999999"
                    liped.procod format "999999"
                    produ.prorefter format "x(15)"
                    produ.pronom format "x(50)"
                    lipgra.corcod format "x(03)"
                    lipgra.tamcod format "x(03)"
                    lipgra.lipqtd format "9999999999999.99" 
                    liped.lippreco format "9999999999999.99" 
                    
                    day(pedid.peddat) format "99" 
                    month(pedid.peddat) format "99"
                    year(pedid.peddat)  format "9999"
                    
                    day(pedid.peddti) format "99" 
                    month(pedid.peddti) format "99"
                    year(pedid.peddti)  format "9999" 
                    
                    day(pedid.peddtf) format "99" 
                    month(pedid.peddtf) format "99"
                    year(pedid.peddtf)  format "9999" 
                    
                    vcomnom format "x(30)"
                    pedid.pedobs[1] format "x(50)"
                    pedid.pedobs[2] format "x(50)"
                    pedid.pedobs[3] format "x(50)"
                    pedid.pedobs[4] format "x(50)"
                    pedid.pedobs[5] format "x(50)" skip.
            
            
            end.

                             
                             
        end.
                         
    end.
output close.
