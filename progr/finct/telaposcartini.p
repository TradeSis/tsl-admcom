/* 17/09/2021 helio*/

{admcab.i}
def var vmodais as char.
def var vmodcod as char.
def var v-cont as int.

def var creferencia as char format "x(10)".

def var vtitle as char init "Posicao de Carteira".
def new shared var vetbcod like estab.etbcod.
def new shared var vdtini as date format "99/99/9999" label "De".
def new shared var vdtfin as date format "99/99/9999" label "Ate".             
def new shared var vmodal      as log format "Sim/Nao".

def new shared temp-table tt-modalidade-selec 
    field modcod as char.
def new shared var vmod-sel as char.
form creferencia
     vdtini
     vdtfin 
     vmod-sel format "x(20)"
     vetbcod
     estab.etbnom format "x(20)"
         with frame fcab
        no-labels
        row 3 no-box width 80
        color messages.
repeat:
    for each tt-modalidade-selec.
        delete tt-modalidade-selec.
    end.    
        
disp vtitle  @ estab.etbnom
    with frame fcab.
    
    {finct/pedemes.i}
    
find estab where estab.etbcod = vetbcod no-lock no-error.
creferencia =  "Referencia".
disp creferencia
     /*vdtini when vreferencia = no*/
     vdtfin 
     vmod-sel 
     vetbcod
     (if vetbcod = 0
      then "Geral"
      else estab.etbnom) @ estab.etbnom 
         with frame fcab.

    run finct/telactbposcartref.p ("Geral","","geral",?,?,?,?,?).


end.

