/* #012023 helio cupom desconto b2b */
{admcab.i}

def var vhostname as char.
def var xetbcod as int.
input through hostname.
import vhostname.
input close.

def var pdtremessa as date format "99/99/9999".
def var copcoes as char format "x(60)" extent 15 init 
    [/*1*/ " geracao de cupons B2B ",
     /*2*/ " consulta cupons B2B",
     /*3*/ " consulta cupons B2B abertos ",
     /*3*/ " consulta cupons B2B usados ",
     
     /*14*/ ""].

def var iopcoes as int.

repeat.

    disp
        copcoes
        with frame fop
        row 3 centered title " CUPONS B2B " no-labels
        width 70.
    choose field copcoes
        with frame fop.        
    iopcoes = frame-index.

    hide frame fop no-pause.
    if iopcoes = 1 /*1*/ 
    then do: 

        run loj/tcupombgera.p.
        
    end.

    if iopcoes = 2 /*2*/ 
    then do: 

        run loj/tcupomblis.p ("TODOS",
                              input trim(copcoes[iopcoes])).
        
    end.

    if iopcoes = 3 /*3*/ 
    then do: 

        run loj/tcupomblis.p ("ABERTOS",
                              input trim(copcoes[iopcoes])).
        
    end.
        
    if iopcoes = 4 /*4*/ 
    then do: 

        run loj/tcupomblis.p ("USADOS",
                              input trim(copcoes[iopcoes])).

    end.

    if iopcoes = 5 /*5*/ 
    then do: 

        run bau/tbaupagamento.p ("CLIENTE", "",
                              input trim(copcoes[iopcoes])).
        
    end.
    if iopcoes = 6 /*6*/ 
    then do: 

        run bau/tbaupagamento.p ("REPASSE", "",
                                  input trim(copcoes[iopcoes])).

    end.

    if iopcoes = 8 /*8*/ 
    then do: 

        run bau/bauprodu.p  (input trim(copcoes[iopcoes])).
        
    end.
        
end.

hide frame fop no-pause.
hide frame fmod no-pause.
  