
def output parameter vestatus as char.
def output parameter vok as log.
def shared temp-table tt-dep like fin.depban.

vok = no.
vestatus = "DEPOSITO NAO ENCONTRADO NA FILIAL". 
for each tt-dep where tt-dep.etbcod > 0:
    find finloja.depban where finloja.depban.etbcod = tt-dep.etbcod and
                       finloja.depban.dephora = tt-dep.dephora and
                       finloja.depban.datexp = tt-dep.datexp
                       no-error.
    if avail finloja.depban
    then do:
        delete finloja.depban.
        vestatus = "DEPOSITO EXCLUIDO NA FILIAL".    
        vok = yes.
    end.
end.                       
