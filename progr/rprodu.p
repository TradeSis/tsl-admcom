{admcab.i}
def var varquivo as char.
def var vcatcod     like produ.catcod.

def var vicms as dec.
def var v-desc as char.

form
    skip 
    vcatcod  label   "Departamento"  colon 15
    v-desc format "x(30)" no-label
    with frame f-x centered 1 down side-labels title "Dados Iniciais" 
                     color white/bronw row 3  width 70.

v-desc = "Geral".
disp v-desc with frame f-x.
repeat:

    do on error undo: 
    
        update vcatcod  with frame f-x.
        if vcatcod = 0
        then v-desc = "Geral".
        else do: 
             find categoria where categoria.catcod = vcatcod no-lock no-error.
             if avail categoria
             then v-desc = categoria.catnom.
             else undo, retry.
        end.
        disp v-desc with frame f-x.
    end.

   def var v-i as int. 
   if opsys = "UNIX"
   then assign varquivo = "/admcom/relat/rprodu-" + string(time) + ".xls".
   else assign varquivo = "l:\relat\rprodu-" + string(time) + ".xls".

   output to value(varquivo) page-size 0.
   
   put unformat   
       "Código;Descricao;Classificacao Fiscal;Al.ICMS;PIS;COFINS;Departamento"
        SKIP.

   for each produ no-lock:
       if vcatcod >  0 and produ.catcod <> vcatcod
       then next.

       run busca-ali.

       put unformat produ.procod ";" 
                    produ.pronom ";"
                    produ.codfis ";"
                    vicms ";"
                    "1.65;7.60;"
                    produ.catcod skip.

    end.   
     output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(input varquivo, input "").
    end.
    else do:
        os-command silent start value(varquivo).
    end.        

end.   
procedure busca-ali.   
      /*** copia do gerpla.p (grava-ali) */     

   def var vali as char.
        
       if produ.proipiper = 17 or
          produ.proipiper = 0
       then vali = "01".
       if produ.proipiper = 12.00 or
          produ.pronom begins "Computa"
       then vali = "FF".
       if produ.pronom begins "Pneu" or
          produ.proipiper = 99
       then vali = "FF".
       if produ.proseq = 1
          then vali = "03".
    
        if vali = "01"
        then vicms = 17.
        else if vali = "02"
             then vicms = 12.
             else if vali = "03"
                  then vicms = 7.
                  else if vali = "04"
                       then vicms = 25.
                       else vicms = 0.
                                    
end procedure.



