/*
* tempocxa.p
* Estatistica de tempo dos caixas
*
*/
{admcab.i} 

def var varquivo as char.

def var vok as char format "x(01)".
def var vdti            like plani.pladat initial today.
def var vdtf            like plani.pladat initial today.
def var esqregua        as log.

def var vetbini         like estab.etbcod.
def var vetbfim         like estab.etbcod.
def var vtempo          as int init 1.
def var vctempo         as char format "x(5)". 
vdti     = today - 1.
vdtf     = today .

form
    skip 
    vetbini  label  "Filial Inicial"  colon 25
    vetbfim  label  "Filial Final"  colon 50
    skip
    vdti  label     "Data Inicial"   colon 25
    vdtf  label     "Data Final"     colon 50
    vtempo label    "Tempo Minimo(segundos)"   colon 25
    with frame f-etb centered 1 down side-labels title "Dados Iniciais" 
                     color white/bronw row 3  width 70.

do on error undo: 
    update vetbini
           vetbfim  with frame f-etb.
    if vetbfim = 0
    then do:
         find last estab no-lock no-error.
         vetbfim = estab.etbcod.
         disp vetbfim with frame f-etb.
    end.
    if vetbini > vetbfim  
    then undo.
end.      
do on error undo: 
    update vdti
           vdtf  with frame f-etb.
    if vdti > vdtf  
    then undo.

    update vtempo with frame f-etb.
end.      

if opsys = "UNIX"
then varquivo = "../relat/tempocxa" + string(day(today),"99") + "." 
               + string(time).
else varquivo = "l:\relat\tempocxa" + string(day(today),"99") + "." 
               + string(time).


/*         database                    
        {mdad.i
           &Saida     = "value(varquivo)"
           &Page-Size = "84"
           &Cond-Var  = "80"
           &Page-Line = "66"
           &Nom-Rel   = """tempocxa"""
           &Nom-Sis   = """SISTEMA DE GERENCIAMENTO"""
           &Tit-Rel   = """ESTATISTICA DE TEMPO DE ATENDIMENTO"""
           &Width     = "100"
           &Form      = "frame f-cab"}.
           */
    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""tempocxa""
            &Nom-Sis   = """SISTEMA DE GERENCIAMENTO"""
            &Tit-Rel   = """ESTATISTICA DE TEMPO DE ATENDIMENTO"""
            &Width     = "100"
            &Form      = "frame f-cab"}
           
for each estab where estab.etbcod >= vetbini
                 and estab.etbcod <= vetbfim
                 no-lock.
                 
    if can-find(first tempocxa where tempocxa.etbcod = estab.etbcod
                        and tempocxa.datinc >= vdti
                        and tempocxa.datinc <= vdtf
                        and tempocxa.tempo >= vtempo)
    then put unformat skip(1) 
                 "Filial: " estab.etbcod " - "  estab.etbnom
                 skip(1) .

    for each tempocxa where tempocxa.etbcod = estab.etbcod
                        and tempocxa.datinc >= vdti
                        and tempocxa.datinc <= vdtf
                        and tempocxa.tempo >= vtempo
                no-lock.         
         find func where func.etbcod = tempocxa.etbcod
                     and func.funcod = tempocxa.funcod 
                     no-lock no-error.
                     
          vctempo = substring(string(tempo,"hh:mm:ss"),4).

         disp tempocxa.cxacod column-label "Cxa"
              tempocxa.funcod Column-label "Matr"
          /*    (if avail func then func.funnom else "")  format "x(10)" */
              tempocxa.datinc column-label "Data"
              string(tempocxa.horini,"hh:mm:ss") column-label "h.Inicio"
            /*  string(tempocxa.horfin,"hh:mm:ss") column-label "h.Fim"
             */  vctempo column-label "MM:SS"
              tempocxa.DESCR column-label "OPERACAO" format "x(150)"
            WITH FRAME f-relat width 200 66 down.
    end.
end.      
put skip(2).
                 
output close.

 if opsys = "UNIX"
 then run visurel.p(input varquivo, input "").
 else do:
      {mrod.i}  end. 

