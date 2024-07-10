{admcab.i}
           
if connected ("banfin")
then disconnect banfin.
                       
if entry(1,sparam,";") = "sv-ca-dbr.lebes.com.br"
then connect /dados/bases/banfin -H sv-ca-dbr.lebes.com.br.
else connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.

run reltitforlp.p.

disconnect banfin.
         
