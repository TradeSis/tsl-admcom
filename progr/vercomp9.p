{admcab.i}


def var v-produto as integer format ">>>>>>>>9".

update v-produto label "Cod Produto".
           
                                                                             
find last liped where procod = v-produto and com.liped.etbcod = 999 no-lock.        
/* disp liped.pednum. */ 
find first produ where com.produ.procod = v-produto no-lock.
disp produ.pronom.
                                                  
for each pedid where pedid.pednum = liped.pednum and com.pedid.etbcod =    
liped.etbcod no-lock.                                                  
                                                                       
find compr where compr.comcod = pedid.comcod.                          
disp pedid.pednum pedid.etbcod pedid.comcod compr.comnom pedid.peddat. 
end.   
                                                                
pause.                                                                       
                                                                       
                                                                                                                                              