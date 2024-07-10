{admcab.i}

def new shared temp-table tt-pedid like pedid.
def new shared temp-table tt-liped like liped.
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

def var p-ok as log.

run pedger5.p.

p-ok = no.

run manager_nfe.p (input "995_5152",
                   input ?,
                   output p-ok).

