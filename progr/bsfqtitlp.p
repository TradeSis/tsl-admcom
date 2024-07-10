{admcab.i}

def input parameter pclicod like clien.clicod.

def new shared temp-table tt-titulo like d.titulo.
for each d.titulo  where

                                          d.titulo.titnat = no and
                                          d.titulo.clifor  = pclicod and
                                          d.titulo.titsit = "LIB" no-lock.
create tt-titulo.
buffer-copy d.titulo to tt-titulo .
end.