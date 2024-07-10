{admcab.i}

def var v-opera as char format "x(30)" extent 5.
def var p-valor as char.
def var vindex as int.

assign
    v-opera[1] = "TRANSFERENCIA PARA REVENDA"
    v-opera[3] = "NOTA FISCAL ACOBERTADA".

disp v-opera with frame f-opera 1 down
                no-label centered row 6 1 column.

choose field v-opera with frame f-opera.

vindex = frame-index.

if vindex = 1
then run loj/nftra_NFe.p.
else if vindex = 3
then run loj/nfveneco.p.

