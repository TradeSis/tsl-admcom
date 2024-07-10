def {1} shared var pacnv-avista     as dec.
def {1} shared var pacnv-aprazo    as dec.
def {1} shared var pacnv-principal  like fin.titulo.titvlcob.
def {1} shared var pacnv-acrescimo  like fin.titulo.titvlcob.
def {1} shared var pacnv-entrada    like fin.titulo.titvlcob.
def {1} shared var pacnv-seguro     like fin.titulo.titvlcob.
def {1} shared var pacnv-crepes     as dec.
def {1} shared var pacnv-troca      as dec.
def {1} shared var pacnv-voucher    as dec.
def {1} shared var pacnv-black      as dec.
def {1} shared var pacnv-chepres    as dec.
def {1} shared var pacnv-combo      as dec.
def {1} shared var pacnv-abate      as dec.
def {1} shared var pacnv-novacao    as log.
def {1} shared var pacnv-renovacao   as log.
def {1} shared var pacnv-feiraonl    as log.
def {1} shared var pacnv-cpfautoriza as char.
def {1} shared var pacnv-juroatu     as dec.
def {1} shared var pacnv-juroacr     as dec.
def {1} shared var pacnv-orinf       as dec.
def {1} shared var pacnv-orinl       as dec.

assign
    pacnv-avista     = 0
    pacnv-aprazo     = 0
    pacnv-principal  = 0
    pacnv-acrescimo  = 0
    pacnv-entrada    = 0
    pacnv-seguro     = 0
    pacnv-crepes     = 0
    pacnv-troca      = 0
    pacnv-voucher    = 0
    pacnv-black      = 0
    pacnv-chepres    = 0
    pacnv-combo      = 0
    pacnv-abate      = 0
    pacnv-novacao    = no
    pacnv-renovacao  = no
    pacnv-feiraonl   = no
    pacnv-cpfautoriza = ""
    pacnv-juroatu     = 0
    pacnv-juroacr     = 0
    pacnv-orinf       = 0
    pacnv-orinl       = 0
    .




