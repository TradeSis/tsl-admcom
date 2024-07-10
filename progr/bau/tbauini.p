/* #082022 helio bau */
{admcab.i}

def var vhostname as char.
def var xetbcod as int.
input through hostname.
import vhostname.
input close.

def var pdtremessa as date format "99/99/9999".
def var copcoes as char format "x(60)" extent 15 init 
    [/*1*/ " vendas series Lebes     - BAU ",
     /*2*/ " vendas outras series    - BAU ",   
     /*3*/ " pagamentos              - BAU ",
     /*4*/ " conciliacao Jequiti     - BAU",
     /*5*/ " consulta por cpf        - BAU ",
     /*6*/ " repasse em csv          - BAU ",
     /*7*/ "",
     /*8*/ " parametros    - BAU",
     
     /*14*/ ""].

def var iopcoes as int.

repeat.

    disp
        copcoes
        with frame fop
        row 3 centered title " BAU JEQUITI " no-labels
        width 70.
    choose field copcoes
        with frame fop.        
    iopcoes = frame-index.


    if iopcoes = 1 /*1*/ 
    then do: 

        run bau/tbaupagamento.p ("VENDAS", "VENDAPROPRIA",
                              input trim(copcoes[iopcoes])).
        
    end.

    if iopcoes = 2 /*2*/ 
    then do: 

        run bau/tbaupagamento.p ("VENDAS", "VENDAOUTROS",
                              input trim(copcoes[iopcoes])).
        
    end.

    if iopcoes = 3 /*3*/ 
    then do: 

        run bau/tbaupagamento.p ("VENDAS", "PAGAMENTO",
                              input trim(copcoes[iopcoes])).
        
    end.
        
    if iopcoes = 4 /*4*/ 
    then do: 

        run bau/tbaupagamento.p ("CONCILIACAO", "",
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
  