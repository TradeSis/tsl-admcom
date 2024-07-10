/* #112022 helio Gestão de itens promocionais */
{admcab.i}
def var petbcod like estab.etbcod.
def var vhostname as char.
def var xetbcod as int.
input through hostname.
import vhostname.
input close.

def var vfiltraperiodo as log format "Sim/Nao".
def var vdtini as date format "99/99/9999".
def var vdtfim as date format "99/99/9999".

def var copcoes as char format "x(60)" extent 7 init 
    [/*1*/ " bloqueio de descontos em itens promocionais",
     /*2*/ " bloqueio de quantidade vendida em itens promocionais ",   
     /*3*/ " libera cotas de planos ",
     /*4*/ " carga de cotas de planos",
     /*5*/ " carga de cotas de cluster",
     /*6*/ " Clusters de Planos   (cadastramento)",
     /*7*/ " Relatorio de Cotas e Cluster" ].

def var iopcoes as int.

repeat.

    disp
        copcoes
        with frame fop
        row 3 centered title " GESTAO DE ITENS PROMOCIONAIS " no-labels
        width 70.
    choose field copcoes
        with frame fop.        
    iopcoes = frame-index.


    if iopcoes = 1 /*1*/ 
    then do: 
        RUN loj/produbloq.p (input copcoes[iopcoes]).
    end.

    if iopcoes = 2 /*2*/ 
    then do: 
        run loj/promqtd.p (input copcoes[iopcoes]).
        
    end.
    if iopcoes = 3 /*3*/ 
    then do: 
        hide message no-pause.
        message "informe filial ou zero para todas".
        update petbcod label "informe filial ou zero para todas" colon 40
            with frame ffilial
            row 9 centered side-labels overlay.
         hide message no-pause.
          
        find estab where estab.etbcod = petbcod no-lock no-error.
        if not avail estab and petbcod > 0
        then do:
            message "filial invalida".
            undo.
        end.     
        vfiltraperiodo  = no. 
        vdtini = ?.
        vdtfim = ?.
        
        update vfiltraperiodo label "filtrar periodo?"  colon 40
         with frame ffilial.
        disp vdtini colon 40 label "de" vdtfim label "ate"
                        with frame ffilial.
                        
        if vfiltraperiodo
        then do:            
            update vdtini colon 40 label "de" vdtfim label "ate"
                with frame ffilial.
        end.        
        run loj/fincotaetb.p (input petbcod,input copcoes[iopcoes] + " Filial: " + string(petbcod) + " " + (if avail estab then estab.munic else ""),
                                input vdtini , input vdtfim).
        
    end.
    if  iopcoes = 4
    then do:
        run loj/fincotacarga.p (input copcoes[iopcoes]).
    end.    

  if  iopcoes = 5
    then do:
        run loj/fincotaclcarga.p (input copcoes[iopcoes]).
    end.    



    if iopcoes = 6
    then do:
        run loj/fincclus.p (input copcoes[iopcoes] ).
    
    end.
    if iopcoes = 7 /*3*/ 
    then do: 
        run loj/fincotarel.p (input copcoes[iopcoes]).
    end.

        
end.

hide frame fop no-pause.
hide frame fmod no-pause.
  