{admcab.i}
def var vsenha as int.
def var vnumero as int format "999999".
def var vv as char.

repeat:

    vnumero = 0.
    update vnumero label "Numero NF" 
            with frame f1 side-label width 80.
            
    vv = string(year(today),"9999")  + 
         string(month(today),"99") +
         string(day(today),"99").
         
              
    display (( (int(vv) * 0.5) - (vnumero * 4))) format ">>>>>>>>9"
            label "Senha" with frame f1.
    
end.        
