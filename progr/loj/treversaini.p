/* #082022 helio REVERSA */
{admcab.i}

def var vhostname as char.
def var xetbcod as int.
input through hostname.
import vhostname.
input close.

def var pdtremessa as date format "99/99/9999".
def var copcoes as char format "x(60)" extent 5 init 
    [/*1*/ " caixas abertas     - REVERSA ",
     /*2*/ " caixas fechadas    - REVERSA ",   
     /*3*/ " ",
     /*4*/ "",
     /*5*/ ""].

def var iopcoes as int.

repeat.

    disp
        copcoes
        with frame fop
        row 3 centered title " REVERSA LOJAS " no-labels
        width 70.
    choose field copcoes
        with frame fop.        
    iopcoes = frame-index.


    if iopcoes = 1 /*1*/ 
    then do: 

        run loj/treversaloj.p ("ABERTAS",
                              input trim(copcoes[iopcoes])).
        
    end.

    if iopcoes = 2 /*2*/ 
    then do: 
        run loj/treversaloj.p ("FECHADAS",
                              input trim(copcoes[iopcoes])).
        
    end.

        
end.

hide frame fop no-pause.
hide frame fmod no-pause.
  