{admcab.i}

def new shared temp-table tt-titulo like fin.titulo.

def var varquivo as char.
def var vetbi   like estab.etbcod.
def var vdata as date.
def var vanalitico as log label "Analitico/Sintetico"
                     format "Analitico/Sintetico" init yes.
def var v-desc as char.

def var vfinan as dec.
def var v-perdido as dec no-undo.
def var vclinom   like clien.clinom.
def var vlimite as dec format ">>,>>>,>>>,>>9.99" init 0.
def var auxlimite as dec format ">>>,>>>,>>>,>>9.99".

def var vtotal as dec.
def var vqtde  as int.

def temp-table tt-perda     
    field etbcod as int COLUMN-Label "FIL"
    field titvlcob  as dec column-label "Total"
                    format ">>>>>>,>>>,>>9.99"
    field qtde      as int column-label "Quantidade"
                       format ">>>,>>>,>>9"
    field finan  as dec column-label "Financeira"
    index ind1 is primary unique
        etbcod.

FUNCTION f-regra RETURNS dec(INPUT vtitvlcob AS dec, 
                             input vtitdtven as date,
                             input vclicod as int).
     def var aux-perdido as dec init 0.                        

            if (vtitvlcob < 5000.01)
            then aux-perdido = vtitvlcob.
            else if (vtitvlcob > 5000.00 and
                    vtitvlcob < 30000.01 and
                    vtitdtven <= vdata /*- 365*/ ) 
                 then do:

                      if can-find(first cobranca where 
                                        cobranca.clicod = vclicod)
                       then aux-perdido = vtitvlcob.
                 end.
                 else if (vtitvlcob > 30000.01 and
                          vtitdtven <= vdata /*- 365*/)
                      then do:
                           if can-find(first cobranca where 
                                       cobranca.clicod = vclicod)
                           then aux-perdido = vtitvlcob.
                      end.

    RETURN (aux-perdido). 
end FUNCTION.   

form
    skip 
    vetbi  label   "Filial"  colon 18  help "[0] = Geral "
    v-desc no-label
    vdata  label     "Data Base"    colon 18
    vlimite label  "Limitar Valor Em" colon 18 
            help "Informar valor limite. [0,00] = sem Limite"
    /*
    vanalitico label "Alitico/Sintetico" colon 18
    */
    with frame f-etb centered 1 down side-labels title "Parametros Iniciais" 
                     color white/bronw row 3  width 70.

form  with frame f-rel width 100 down .                      

vdata = today.
vetbi = 1.
def var vdias as dec.
def var vjuro as dec.

repeat:
    for each tt-perda:
        delete tt-perda.
    end.
    for each tt-titulo :
        delete tt-titulo.
    end.
        
    auxlimite = 0.
    
    update vetbi
           with frame f-etb.
    if vetbi = 0
    then v-desc = "Geral".
    else do:
         find estab where estab.etbcod = vetbi no-lock no-error.
         if not avail estab then next.
         v-desc = estab.etbnom.
         
    end.
    disp v-desc with frame f-etb.
    update vdata help "Data base para contagem do credito imcobravel"
            format "99/99/9999"
           vlimite
           /*
           vanalitico help "[A] Analitico, [S] Sintetico"
            */
    with frame f-etb.
     
    if opsys = "UNIX"
    Then varquivo = "../relat/creincob" + string(time) + ".xls".
    else varquivo = "l:\relat\creincob" + string(time) + ".xls".


    def var vx as int.
    def stream stela.

    for each estab where if vetbi = 0 
                         then true
                         else (estab.etbcod = vetbi) 
                     no-lock:
    
         output stream stela to terminal.                         
            disp stream stela "Processando...    " estab.etbcod  no-label
                    with frame ffff centered .
         output stream stela close.                               
         pause 0.

            
        for each d.titulo where d.titulo.empcod = 19 and
                  d.titulo.titnat = no and
                  d.titulo.modcod = "CRE" and  
                  d.titulo.titsit = "LIB" and
                  d.titulo.etbcod = estab.etbcod and
                  d.titulo.titdtven <= vdata /*- 180*/
               no-lock.  
               
            assign v-perdido = f-regra(d.titulo.titvlcob,
                                        d.titulo.titdtven,
                                        d.titulo.clifor).
            if v-perdido > 0
            then 
            
            if d.titulo.titvlcob >= vlimite
            then do:

                create tt-titulo.
                buffer-copy titulo to tt-titulo.
                
            end. 
        end. 
         
        for each fin.titulo where fin.titulo.empcod = 19 and
                 fin.titulo.titnat = no and
                 fin.titulo.modcod = "CRE" and
                 fin.titulo.titsit = "LIB" and
                 fin.titulo.etbcod = estab.etbcod and
                 fin.titulo.titdtven < vdata /*- 180*/
               no-lock.  
               
            assign v-perdido = f-regra(fin.titulo.titvlcob,
                                       fin.titulo.titdtven,
                                       fin.titulo.clifor).
                                       
            if v-perdido > 0
            then 
            if fin.titulo.titvlcob >= vlimite
            then do:

                 create tt-titulo.
                 buffer-copy fin.titulo to tt-titulo.
                 
            end. 
        end.   
        
   end.
   if connected ("d")
   then disconnect d.

   run relincob01.p(vdata).
   
   leave.
    
end.





