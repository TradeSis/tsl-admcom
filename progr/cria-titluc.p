{admcab.i}
def input parameter vrec as recid.


find fin.titluc where recid(fin.titluc) = vrec no-lock.

create finloja.titluc. 
buffer-copy fin.titluc to finloja.titluc.
        
 