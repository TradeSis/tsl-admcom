{admcab.i}
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
                    vtitdtven <= vdata - 365 ) 
                 then do:

                      if can-find(first cobranca where 
                                        cobranca.clicod = vclicod)
                       then aux-perdido = vtitvlcob.
                 end.
                 else if (vtitvlcob > 30000.01 and
                          vtitdtven <= vdata - 365)
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

    vanalitico label "Alitico/Sintetico" colon 18
    with frame f-etb centered 1 down side-labels title "Parametros Iniciais" 
                     color white/bronw row 3  width 70.

form  with frame f-rel width 100 down .                      

vdata = today.
vetbi = 1.

repeat:
    for each tt-perda:
        delete tt-perda.
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
           vlimite
           vanalitico help "[A] Analitico, [S] Sintetico"
    with frame f-etb.
     
    if opsys = "UNIX"
    Then varquivo = "../relat/creincob" + string(time) + ".xls".
    else varquivo = "l:\relat\creincob" + string(time) + ".xls".

   output to value(varquivo) page-size 0.
   
   put unformat 
      "Filial;Titulo;PC;Vencimento;Valor Cobrado;Cliente;Nome cliente" at 1 
       SKIP.

    
/*
    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""CREINCOB""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """CREDITO INCOBRAVEL """
            &Width     = "100"
            &Form      = "frame f-cabcab"}
  */
    def var vx as int.
    def stream stela.
    for each estab where if vetbi = 0 
                         then true
                         else (estab.etbcod = vetbi) 
                     no-lock:
    
         output stream stela to terminal.                         
            disp stream stela estab.etbcod auxlimite no-label
                    with frame ffff centered. 
         output stream stela close.                               
         pause 0.

        if auxlimite >= vlimite and vlimite > 0     
        then leave.                                 

        if auxlimite < vlimite or vlimite = 0
        then
          for each d.titulo where d.titulo.empcod = 19 and
                  d.titulo.titnat = no and
                  d.titulo.modcod = "CRE" and  
                  d.titulo.titsit = "LIB" and
                  d.titulo.etbcod = estab.etbcod and
                  d.titulo.titdtven < vdata - 180
               no-lock.  
               
            assign v-perdido = f-regra(d.titulo.titvlcob,
                                        d.titulo.titdtven,
                                        d.titulo.clifor).
            if v-perdido > 0
            then do:
                 auxlimite = auxlimite + v-perdido.

                 find clien where clien.clicod = d.titulo.clifor 
                                no-lock no-error.
                 if avail clien then vclinom = clien.clinom.
                 else vclinom = "".

                 find first envfinan where envfinan.empcod = 19
                                       and envfinan.titnat = no
                                       and envfinan.modcod = "CRE"
                                       and envfinan.etbcod = d.titulo.etbcod
                                       and envfinan.clifor = d.titulo.clifor
                                       and envfinan.titnum = d.titulo.titnum
                                       no-lock no-error.
                                                                    
                 if vanalitico
                 then do:
                      put unformat  
                           d.titulo.etbcod  ";"
                           d.titulo.titnum  ";"
                           d.titulo.titpar  ";"
                           d.titulo.titdtven format "99/99/9999" ";"
                           d.titulo.titvlcob ";"
                           d.titulo.clifor  ";"
                           vclinom.
                      if avail envfinan 
                      then put ";F".
                      else put ";L".       
                      put skip.
                 end.
                 find tt-perda where tt-perda.etbcod = d.titulo.etbcod
                            no-error.
                 if not avail tt-perda
                 then do:
                      create tt-perda.
                      assign tt-perda.etbcod = d.titulo.etbcod.
                 end.
                 if avail envfinan
                 then tt-perda.finan = tt-perda.finan + d.titulo.titvlcob.
                 else tt-perda.titvlcob = tt-perda.titvlcob +
                                            d.titulo.titvlcob.
                 tt-perda.qtde     = tt-perda.qtde + 1.
                    
                 if auxlimite >= vlimite and vlimite > 0 
                 then leave. 
            end. 
          end. 

         
        if auxlimite < vlimite or vlimite = 0
        then
            for each fin.titulo where fin.titulo.empcod = 19 and
                 fin.titulo.titnat = no and
                 fin.titulo.modcod = "CRE" and
                 fin.titulo.titsit = "LIB" and
                 fin.titulo.etbcod = estab.etbcod and
                 fin.titulo.titdtven < vdata - 180
               no-lock.  
               
            assign v-perdido = f-regra(fin.titulo.titvlcob,
                                       fin.titulo.titdtven,
                                       fin.titulo.clifor).
                                       
            if v-perdido > 0
            then do:
                 auxlimite = auxlimite + v-perdido.
                 
                 find clien where clien.clicod = fin.titulo.clifor 
                                no-lock no-error.
                 if avail clien
                 then vclinom = clien.clinom.
                 else vclinom = "".
                 
                 find first envfinan where envfinan.empcod = 19
                                       and envfinan.titnat = no
                                       and envfinan.modcod = "CRE"
                                       and envfinan.etbcod = fin.titulo.etbcod
                                       and envfinan.clifor = fin.titulo.clifor
                                       and envfinan.titnum = fin.titulo.titnum
                                       no-lock no-error.
                
                 if vanalitico
                 then do:
                      put unformat
                           fin.titulo.etbcod ";"
                           fin.titulo.titnum ";"
                           fin.titulo.titpar ";"
                           fin.titulo.titdtven format "99/99/9999" ";"
                           fin.titulo.titvlcob ";"
                           fin.titulo.clifor ";"
                           vclinom.
                      if avail envfinan
                      then put ";F".
                      else put ";L".
                      put       skip.

                 end.      
                 find tt-perda where tt-perda.etbcod = fin.titulo.etbcod
                            no-error.
                 if not avail tt-perda
                 then do:
                      create tt-perda.
                      assign tt-perda.etbcod = fin.titulo.etbcod.
                 end.
                 if avail envfinan
                 then tt-perda.finan = tt-perda.finan + fin.titulo.titvlcob.
                 else tt-perda.titvlcob = tt-perda.titvlcob +
                                            fin.titulo.titvlcob .
                 tt-perda.qtde     = tt-perda.qtde + 1.
                 if auxlimite >= vlimite and vlimite > 0 
                 then leave.                           

            end. 
         end.   
  /*       find tt-perda where tt-perda.etbcod = estab.etbcod no-lock no-error.
         if vanalitico and
            avail tt-perda
         then do:
             put unformat "-----------   -----------------" at 20.
              put "TOTAL: " at 10
                          tt-perda.qtde at 20 
                          tt-perda.titvlcob at 34
                          skip(1).
             
          end.
          */
    end.

   assign vqtde  = 0
          vtotal = 0
          vfinan = 0.

   put unformat skip
                ";Totais por estabelecimento" skip
                "Filial;Quantidade;Loja;Financeira" skip.
  
    for each tt-perda break
                      by tt-perda.etbcod:
        
             put  unformat 
                  tt-perda.etbcod ";"
                  tt-perda.qtde  ";" /* (total) */
                  tt-perda.titvlcob ";" /* (total) */
                  tt-perda.finan  /* Financeira */
                  skip .
            assign vqtde  = vqtde + tt-perda.qtde
                   vtotal = vtotal + tt-perda.titvlcob
                   vfinan = vfinan + tt-perda.finan.
    end.
    
      put unformat 
          "Total:" ";"
          vqtde ";" 
          vtotal ";" 
          vfinan
          skip (3).
    output close.     

    
    if opsys = "UNIX"
    then do:
        run visurel.p(input varquivo, input "").
    end.
    else do:
        os-command silent start value(varquivo).
    end.        

    
end.





