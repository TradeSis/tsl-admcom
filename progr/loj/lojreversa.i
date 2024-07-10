def new global shared var spid as int.
def new global shared var spidseq as int.

def {1} shared temp-table ttabertas no-undo serialize-name "reversa"
    field estabOrigem    as int
    field etbdest   as int
    field codCaixa  as int
    field catcod    as int    
    field pid    as int
    field dtalt     as date
    field hralt     as int
    field idPedidoGerado    as char
    index x codcaixa asc.

def {1} shared temp-table ttitens no-undo serialize-name "itens"
    field sequencial as int
    field codigoProduto   as int
    field quantidade    as int.
            



def temp-table tterro no-undo serialize-name "return"
    field pstatus as char serialize-name "status"
    field erro  as char.

