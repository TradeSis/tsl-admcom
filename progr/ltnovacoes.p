/*Busca contratos com novacoes*/
def input parameter par-clifor      like d.titulo.clifor.
def input parameter par-titdtpag    like d.titulo.titdtemi.
def input parameter par-titnum      like d.titulo.titnum.
def input parameter par-parcela     like d.titulo.titpar.
def output parameter ventradaren    like d.titulo.titvlcob.
def output parameter vtitnumnovo    like d.titulo.titnum.

for each  d.titulo where
          d.titulo.clifor     = par-clifor   and 
          d.titulo.titdtemi   = par-titdtpag and
          d.titulo.titnum    <> par-titnum   and 
          d.titulo.titpar     = par-parcela  
          no-lock.

    assign ventradaren = ventradaren + d.titulo.titvlpag.
    assign vtitnumnovo = d.titulo.titnum.


end.
