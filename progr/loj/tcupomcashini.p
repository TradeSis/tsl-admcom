/* helio 05042023 - complementos */
/* 032023 helio cupom cash back antecipacao parcelas */
{admcab.i}

def var vhostname as char.
def var xetbcod as int.
input through hostname.
import vhostname.
input close.

def var pdtremessa as date format "99/99/9999".

def var copcoes as char format "x(60)" extent 15 init
    [/*1*/ " consulta cupons ANTECIPACAO PAGTO cliente abertos",
     /*2*/ " consulta cupons ANTECIPACAO PAGTO cliente " ,
     "",
     /*4*/ " consulta cupons ANTECIPACAO PAGTO abertos ",
     /*5*/ " consulta cupons ANTECIPACAO PAGTO usados ",
     /*6*/ " consulta cupons ANTECIPACAO PAGTO todos ",
     "",
     /*8*/ " consulta cupons ANTECIPACAO PAGTO nao exportados",
           "",
           "",
     /*11*/  " reabertura de cupom (sem nsu)",
     "",
     "",
     /*14*/ " parametrizacao geracao de cash back",
           ""].

def var iopcoes as int.

if setbcod <> 999
then do:
    copcoes = "".
    copcoes[1] = " consulta cupons ANTECIPACAO PAGTO cliente abertos".
    copcoes[2] = " consulta cupons ANTECIPACAO PAGTO cliente ".
    copcoes[11] = " reabertura de cupom (sem nsu)".    
end.

repeat.

    disp
        copcoes
        with frame fop
        row 3 centered title " CUPONS CASHBACK " no-labels
        width 70.
    choose field copcoes
        with frame fop.        
    iopcoes = frame-index.
    if  trim(copcoes[iopcoes]) = "" then next.
    
    hide frame fop no-pause.
    if iopcoes = 1 /*1*/ 
    then do: 

        run loj/tcupcashcli.p ("ABERTOS", input trim(copcoes[iopcoes])).
        
    end.
    if iopcoes = 2 /*3*/ 
    then do: 

        run loj/tcupcashcli.p ("TODOS", input trim(copcoes[iopcoes])).
        
    end.
    

    if iopcoes = 4 /*4*/ 
    then do: 

        run loj/tcupcashlis.p ("ABERTOS",
                              input trim(copcoes[iopcoes])).
        
    end.

    if iopcoes = 5 /*5*/ 
    then do: 

        run loj/tcupcashlis.p ("USADOS",
                              input trim(copcoes[iopcoes])).
        
    end.
    if iopcoes = 6 /*6*/ 
    then do: 

        run loj/tcupcashlis.p ("TODOS",
                              input trim(copcoes[iopcoes])).
        
    end.
    
    if iopcoes = 8 /*3*/ 
    then do: 

        run loj/tcupcashlis.p ("NAOCSV",
                              input trim(copcoes[iopcoes])).
        
    end.
    
    if iopcoes = 11 /*11*/ 
    then do: 

        run loj/tcupcashcli.p ("REABERTURA", input trim(copcoes[iopcoes])).
        
    end.
        

    if iopcoes = 14 /*14*/ 
    then do: 
    
        run loj/tcupomcashparam.p.

        
    end.
    
        
end.

hide frame fop no-pause.
hide frame fmod no-pause.
  
