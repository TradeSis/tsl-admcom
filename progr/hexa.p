{admcab.i}

def var xx as char.
def var base as int.
def var dec  as int format ">>>>>>>>9".
def var res  as int format "->>>,>>9".
def var div  as dec.
def var hex1 as char format "x(10)".
def var hex2 as char format "x(10)".
def var hexa as char format "X(10)".
base = 16.
dec  = 0.
res = 0.
div = 0.
repeat:
   hex2 = "".
   hex1 = "".
   update dec label "Decimal" with frame f1 side-label centered.
   repeat: 
      res = (dec mod base).
      hex1 = string(res,"99") + hex1.  
      if res <= 9
      then hex1 = string(res,"9").
      if res = 10
         then hex1 = "A".
      if res = 11
         then hex1 = "B".
      if res = 12
         then hex1 = "C".
      if res = 13
         then hex1 = "D".
      if res = 14
         then hex1 = "E".
      if res = 15
         then hex1 = "F".
      div = ((dec / base) - 0.50).
      dec = int(div).

      hex2 = hex1 + hex2.
      if dec = 0
      then leave.
   end.
   disp hex2 label "Hexadecimal" with frame f1.
end.      
