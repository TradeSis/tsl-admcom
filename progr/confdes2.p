/*
**** Relatório para conferencia das despesas financeiras  (confdes2.p)  
*/
{/admcom/progr/admcab-batch.i}

def var vpago like fin.titluc.titvlpag.
def var vdesc like fin.titluc.titvlpag.
def var vjuro like fin.titluc.titvlpag.
 
def var vtotcomp    like fin.titluc.titvlcob.
def var ventrada    like fin.titluc.titvlcob.
def var vdata       like fin.titluc.titdtemi.

def input parameter vetbcod like estab.etbcod.
def input parameter vdti like fin.titluc.titdtemi.
def input parameter vdtf like fin.titluc.titdtemi.

def var sresumo     as   log format "Resumo/Geral" initial yes.
def var wpar        as int format ">>9" .

def temp-table tt-auxtit like fin.titluc.

def buffer bfin-titluc for fin.titluc.

def shared temp-table tt-diverg
    field empcod like fin.titluc.empcod
    field titnat like fin.titluc.titnat
    field modcod like fin.titluc.modcod
    field etbcod like fin.titluc.etbcod
    field clifor like fin.titluc.clifor
    field titnum like fin.titluc.titnum
    field titpar like fin.titluc.titpar
    field titsit like fin.titluc.titsit
    field titdtpag like fin.titluc.titdtpag 
    field titvlcob like fin.titluc.titvlcob    
    field obs    as char format "x(40)"
    field marca as char
    index etbcod is primary
           etbcod
           titnum     
    index titnum is unique
           empcod
           titnat
           modcod
           etbcod
           CliFor
           titnum
           titpar
    index mar marca.


for each estab where estab.etbcod = vetbcod and
                     estab.etbnom begins "DREBES-FIL" no-lock.
        
    assign ventrada = 0
           vtotcomp = 0
           vpago = 0
           vdesc = 0
           vjuro = 0.
    
    do vdata = vdti to vdtf:
            
        assign ventrada = 0
               vtotcomp = 0
               vpago = 0
               vdesc = 0
               vjuro = 0.

        /**** qual a regra?
        for each fin.titluc where fin.titluc.empcod = wempre.empcod and
                                  fin.titluc.titnat = yes and
                                  fin.titluc.titdtven = vdata and
                                  fin.titluc.etbcod   = estab.etbcod
                                            no-lock:
                
                if not can-find(first finloja.titluc 
                       where finloja.titluc.empcod = fin.titluc.empcod and
                             finloja.titluc.titnat = fin.titluc.titnat and
                             finloja.titluc.modcod = fin.titluc.modcod and
                             finloja.titluc.etbcod = fin.titluc.etbcod and
                             finloja.titluc.clifor = fin.titluc.clifor and
                             finloja.titluc.titnum = fin.titluc.titnum and
                             finloja.titluc.titpar = fin.titluc.titpar)
               then do:
                 create tt-auxtit.
                 buffer-copy fin.titluc to tt-auxtit.
                 run p-cria-tt ("fin").
               end.
                
          end.
        *****/

        for each finloja.titluc where 
                    finloja.titluc.etbcob = estab.etbcod and
                    finloja.titluc.titdtpag = vdata and
                    finloja.titluc.empcod = 19 and
                    finloja.titluc.titnat = yes and
                    finloja.titluc.titsit = "pag"
                  /*   and
                   finloja.titluc.titdtven = vdata and
                    finloja.titluc.etbcod = estab.etbcod */
                    no-lock: 
                    
              if finloja.titluc.titdtpag < vdti or
                 finloja.titluc.titdtpag > vdtf then next.

            find fin.titluc 
                       where fin.titluc.empcod = finloja.titluc.empcod and
                             fin.titluc.titnat = finloja.titluc.titnat and
                             fin.titluc.modcod = finloja.titluc.modcod and
                             fin.titluc.etbcod = finloja.titluc.etbcod and
                             fin.titluc.clifor = finloja.titluc.clifor and
                             fin.titluc.titnum = finloja.titluc.titnum and
                             fin.titluc.titpar = finloja.titluc.titpar
                             no-lock no-error.
            if not avail fin.titluc
            then do:
                 if finloja.titluc.titsit = "pag"
                 then do:
                    create fin.titluc.
                    buffer-copy finloja.titluc to fin.titluc.
                    run paga-titluc.p (recid(fin.titluc)). 
                 end.
              /*   else do:
                     create tt-auxtit.
                     buffer-copy finloja.titluc to tt-auxtit.
                     run p-cria-tt ("loja").
                 end. */
               end.
            else do:
                 if fin.titluc.titsit <> finloja.titluc.titsit or
                    fin.titluc.titvlpag <> finloja.titluc.titvlpag or
                    fin.titluc.titdtpag <> finloja.titluc.titdtpag
                 then do:
                      if finloja.titluc.titsit = "pag"
                      then do:
                           find bfin-titluc where rowid(bfin-titluc)
                                            = rowid(fin.titluc) exclusive-lock.
                           assign 
                               bfin-titluc.titdtpag = finloja.titluc.titdtpag
                               bfin-titluc.titvlpag = finloja.titluc.titvlpag
                               bfin-titluc.titsit   = finloja.titluc.titsit
                               bfin-titluc.etbcobra = finloja.titluc.etbcobra.
                           run paga-titluc.p (recid(fin.titluc)). 
                      end.
                  
                  /*****
                      create tt-auxtit.

                      if fin.titluc.titsit = "pag"
                      then do:
                           buffer-copy fin.titluc to tt-auxtit.
                           run p-cria-tt("divm").
                       end.
                      else do:     
                           buffer-copy finloja.titluc to tt-auxtit.
                           run p-cria-tt("DivF").
                      end.
                      *****/ 
                 end.

                 else
                   if fin.titluc.titsit = "pag"
                   then do:
                        find foraut where foraut.forcod = fin.titluc.clifor
                                           no-lock no-error.
                        if not avail foraut
                        then next.                   

                        if foraut.autlp = yes and
                           not can-find(first banfin.titulo where
                               banfin.titulo.empcod = fin.titluc.empcod and
                               banfin.titulo.titnat = fin.titluc.titnat and
                               banfin.titulo.modcod = foraut.modcod and
                               banfin.titulo.etbcod = fin.titluc.etbcod and
                               banfin.titulo.clifor = fin.titluc.clifor and
                               banfin.titulo.titnum = fin.titluc.titnum and
                               banfin.titulo.titpar = fin.titluc.titpar)
                       and not can-find(first banfin.titulo where
                               banfin.titulo.empcod = fin.titluc.empcod and
                               banfin.titulo.titnat = fin.titluc.titnat and
                               banfin.titulo.modcod = fin.titluc.modcod and
                               banfin.titulo.etbcod = fin.titluc.etbcod and
                               banfin.titulo.clifor = fin.titluc.clifor and
                               banfin.titulo.titnum = fin.titluc.titnum and
                               banfin.titulo.titpar = fin.titluc.titpar)
    
                        then 
                           if not can-find(first banfin.titulo where
                                banfin.titulo.empcod = fin.titluc.empcod and
                                banfin.titulo.titnat = fin.titluc.titnat and
                                banfin.titulo.modcod = foraut.modcod and
                                banfin.titulo.etbcod = 999 and 
                                banfin.titulo.clifor = fin.titluc.clifor and
                                banfin.titulo.titnum = fin.titluc.titnum and
                                banfin.titulo.titpar = fin.titluc.titpar)
                           then do:   
                                 create tt-auxtit.
                                 buffer-copy finloja.titluc 
                                             to tt-auxtit.
                                 run p-cria-tt ("lp").
                        end.
                        else do:
                             if foraut.autlp = no and
                              not can-find(first fin.titulo where
                                fin.titulo.empcod = fin.titluc.empcod and
                                fin.titulo.titnat = fin.titluc.titnat and
                                fin.titulo.modcod = foraut.modcod and
                                fin.titulo.etbcod = fin.titluc.etbcod and
                                fin.titulo.clifor = fin.titluc.clifor and
                                fin.titulo.titnum = fin.titluc.titnum and
                                fin.titulo.titpar = fin.titluc.titpar)
                             then do:
                                  create tt-auxtit.
                                  buffer-copy finloja.titluc to tt-auxtit.
                                  run p-cria-tt ("tit_fin").
                               end.
                        end.                  

                  end.
                  if finloja.titluc.titsit = "PAG"
                  then do:
                      run paga-titluc.p (input recid(fin.titluc)).
                  end.
             end.
        end.
        for each fin.titluc where fin.titluc.empcod = wempre.empcod and
                                  fin.titluc.titnat = yes and
                                  fin.titluc.titdtven = vdata and
                                  fin.titluc.etbcod   = estab.etbcod
                                            no-lock:
            if fin.titluc.titsit = "PAG"
            then do:
                run paga-titluc.p (input recid(fin.titluc)).
            end.
        end.
    end.            
end.

/*
if not can-find(first tt-diverg where tt-diverg.etbcod = vetbcod)
then do:
     create tt-diverg.
     assign tt-diverg.etbcod = vetbcod
            tt-diverg.titsit = ""
            tt-diverg.obs = "Nenhum divegencia encontrada".
  end.
*/

procedure p-cria-tt.

  def input parameter p-tipo as char.
 
  def buffer btt-diverg for tt-diverg.

  find last btt-diverg where btt-diverg.empcod = tt-auxtit.empcod and
                             btt-diverg.titnat = tt-auxtit.titnat and
                             btt-diverg.modcod = tt-auxtit.modcod and
                             btt-diverg.etbcod = tt-auxtit.etbcod and
                             btt-diverg.clifor = tt-auxtit.clifor and
                             btt-diverg.titnum = tt-auxtit.titnum and
                             btt-diverg.titpar = tt-auxtit.titpar no-error.
   if not avail btt-diverg
   then do:
        create tt-diverg.
        assign tt-diverg.empcod = tt-auxtit.empcod
               tt-diverg.titnat = tt-auxtit.titnat
               tt-diverg.modcod = tt-auxtit.modcod
               tt-diverg.etbcod = tt-auxtit.etbcod
               tt-diverg.clifor = tt-auxtit.clifor
               tt-diverg.titnum = tt-auxtit.titnum
               tt-diverg.titpar = tt-auxtit.titpar.
   end.
  assign tt-diverg.titsit = tt-auxtit.titsit
         tt-diverg.titdtpag = tt-auxtit.titdtpag 
         tt-diverg.titvlcob = tt-auxtit.titvlcob
         tt-diverg.obs    = (if p-tipo = "fin"
                             then "Não encontrado na Loja"
                             else if p-tipo = "loja"
                                  then "Não encotrado na Matriz"
                                  else if p-tipo = "Divf"
                                     then "Diverg entre Matriz(L) e Loja(P)"
                                     else if p-tipo = "Divm"
                                        then "Diverg entre Loja(L) e Matriz(P)"
                                     else
                                       if p-tipo = "LP"
                                       then "Nao encontrado na LP"
                                       else "Nao encontrou titulo na Matriz").
                                        
   for each tt-auxtit:
       delete tt-auxtit.
   end.

end procedure.


