{difregtab.i}

def input parameter p-vez as int.
def input parameter p-etbcod like estab.etbcod.
def input parameter p-funcod like func.funcod.
def input parameter p-rectab as recid.
def input parameter p-banco as char.
def input parameter p-tabela as char.
def input parameter p-acao as char.

def var vretorno as log.

vretorno = no.
/***/
run difregtab.p(input p-vez, 
                        input p-rectab ,
                        input p-banco ,
                        input p-tabela ,
                        output vretorno).

if p-vez = 2 and
   vretorno = yes
then do on error undo:
    find first table-raw no-error.
    find tablog where tablog.etbcod = p-etbcod and
                      tablog.funcod = p-funcod and
                      tablog.data = today and
                      tablog.hora = time
                      no-error.
    if not avail tablog
    then  create tablog.
    assign
        tablog.etbcod = p-etbcod
        tablog.funcod = p-funcod
        tablog.data   = today
        tablog.hora   = time
        tablog.banco  = p-banco
        tablog.tabela = p-tabela
        tablog.acao   = p-acao.
    if avail table-raw 
    then assign
            tablog.antes  = table-raw.registro1
            tablog.depois = table-raw.registro2
            tablog.char1  = table-raw.char1
            tablog.char2  = table-raw.char2.
    for each table-raw:
        delete table-raw.
    end.    
end. 
else if p-vez = 2
then do:
    for each table-raw:
        delete table-raw.
    end.
end.
