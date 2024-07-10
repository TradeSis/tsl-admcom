find func where func.funcod = sfuncod and
                func.etbcod = setbcod 
                no-lock no-error.

def var i-sen{1}           as int.
def var vsenha{1}          as char format "x(6)".
def var vsenha{1}1         like vsenha{1} label "SENHA".

i-sen{1} = 0.
repeat on endkey undo, return.

    vsenha{1} = "2505".
    vsenha{1}1 = "".
    update vsenha{1}1 BLANK
           with frame fsenha{1} overlay centered row 10 color
                      black/red side-labels.
    if vsenha{1} <> vsenha{1}1  and
       "29830"    <> vsenha{1}1  and
       /*"10050"    <> vsenha{1}1  and*/
       "3636"    <> vsenha{1}1  and
       "1508"    <> vsenha{1}1  and
       /*"201050"  <> vsenha{1}1  and*/
       "3636"  <> vsenha{1}1  and
       "m2611o"  <> vsenha{1}1  and
           "2255"  <> vsenha{1}1  and
       "0639"    <> vsenha{1}1  and
       "79787"  <> vsenha{1}1 and
       func.senha <> vsenha{1}1
    then do:
        message "Senha Invalida".
        i-sen{1} = i-sen{1} + 1.
        if i-sen{1} > 3
            then do:
            pause 0.
            undo, return.
        end.
        next.
    end.
    leave.
end.
hide frame fsenha{1} no-pause.
