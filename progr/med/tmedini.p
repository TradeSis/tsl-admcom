/* medico na tela 042022 - helio */
{admcab.i}

def var vhostname as char.
def var xetbcod as int.
input through hostname.
import vhostname.
input close.

def var pdtremessa as date format "99/99/9999".
def var copcoes as char format "x(60)" extent 15 init 
    [/*1*/ " vendas        - CHAMA DOUTOR ",
     /*2*/ " cancelamentos - CHAMA DOUTOR ",
     /*3*/ " consultas por cpf - CHAMA DOUTOR ",
     /*4*/ " repasses mensais - CHAMA DOUTOR",
     /*5*/ "",
     /*6*/ "",
     /*7*/ "",
     /*8*/ " parametros    - CHAMA DOUTOR ",
     
     /*14*/ ""].

def var iopcoes as int.

repeat.

    disp
        copcoes
        with frame fop
        row 3 centered title " CHAMA DOUTOR " no-labels
        width 70.
    choose field copcoes
        with frame fop.        
    iopcoes = frame-index.


    if iopcoes = 1 /*1*/ 
    then do: 

        run med/tmedadesao.p ("VENDAS",
                              input trim(copcoes[iopcoes]),
                              ?,
                              ?).
        
    end.
        
    if iopcoes = 2 /*2*/ 
    then do: 

        run med/tmedadesao.p ("CANCELAMENTOS", 
                              input trim(copcoes[iopcoes]),
                              ?,?).
        
    end.

    if iopcoes = 3 /*3*/ 
    then do: 

        run med/tmedadesao.p ("CLIENTE", 
                              input trim(copcoes[iopcoes]),
                              ?,?).
        
    end.

    if iopcoes = 4 /*4*/ 
    then do: 

        run med/tmedrepasses.p (input trim(copcoes[iopcoes])).
        
    end.
        
    if iopcoes = 8 /*8*/ 
    then do: 

        run med/medprodu.p.
                    /* input trim(copcoes[iopcoes])).*/
        
    end.
        
end.

hide frame fop no-pause.
hide frame fmod no-pause.
  