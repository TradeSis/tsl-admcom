def input parameter p-tipo as char.
def input parameter p-etbcod like ger.estab.etbcod.
def output parameter p-status as char.

def shared temp-table tt-menu like ger.menu.
def shared temp-table lj-menu like ger.menu.
def shared temp-table mt-menu like ger.menu.

if p-tipo = "REF"
then do:
    for each gerloja.menu no-lock:
        create tt-menu.
        buffer-copy gerloja.menu to tt-menu.
    end.
end.
else if p-tipo = "CFE"
then do:
    p-status = "Divergencia nao encontrada".
    for each tt-menu no-lock:
        find first gerloja.menu where
               gerloja.menu.aplico = tt-menu.aplicod and
               gerloja.menu.menniv = tt-menu.menniv  and
               gerloja.menu.ordsup = tt-menu.ordsup  and
               gerloja.menu.menord = tt-menu.menord  and
               gerloja.menu.mentit = tt-menu.mentit  and
               gerloja.menu.menpro = tt-menu.menpro
               no-lock no-error.
        if not avail gerloja.menu
        then do:
            p-status = "DIVERGENCIA ENCONTRADA".
            create mt-menu.
            buffer-copy tt-menu to mt-menu.
            find first gerloja.menu where
               gerloja.menu.aplico = tt-menu.aplicod and
               gerloja.menu.menniv = tt-menu.menniv  and
               gerloja.menu.ordsup = tt-menu.ordsup  and
               gerloja.menu.menord = tt-menu.menord  
               no-lock no-error.
            if avail gerloja.menu
            then do:
                create lj-menu.
                buffer-copy gerloja.menu to lj-menu.
            end.
        end.
    end.
end.
    
    
