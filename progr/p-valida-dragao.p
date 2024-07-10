def input parameter par-etbcod     as integer.
def input parameter par-diretorio  as char.

def var i as integer.
def var vdir-arq-bkp-titulo as char.
def var vdir-arq-bkp-contrato as char.
def var vdir-arq-bkp-clispc as char.

assign i = 0.

for each dragao.titulo where dragao.titulo.etbcod = par-etbcod no-lock.
      
    run p-copia-dragao.p (input "titulo",
                          input recid(dragao.titulo)).

end.    


for each dragao.contrato where dragao.contrato.etbcod = par-etbcod no-lock.

    run p-copia-dragao.p (input "clispc",
                          input recid(dragao.contrato)).
        

    run p-copia-dragao.p (input "contrato",
                          input recid(dragao.contrato)).

end.



