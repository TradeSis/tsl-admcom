{admcab.i}
def input parameter vrec as recid.


find fin.titluc where recid(fin.titluc) = vrec no-error.
if avail fin.titluc
then do:
    find finloja.titluc 
         where finloja.titluc.empcod = fin.titluc.empcod and
               finloja.titluc.titnat = fin.titluc.titnat and 
               finloja.titluc.modcod = fin.titluc.modcod and
               finloja.titluc.etbcod = fin.titluc.etbcod and
               finloja.titluc.clifor = fin.titluc.clifor and
               finloja.titluc.titnum = fin.titluc.titnum and
               finloja.titluc.titpar = fin.titluc.titpar no-error.
    if avail finloja.titluc
    then delete finloja.titluc.

    delete fin.titluc.
    
end.    
        
 