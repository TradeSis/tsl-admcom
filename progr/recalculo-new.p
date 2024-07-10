{admcab.i new}

def buffer bhiest for hies.
def var vetbcod like estab.etbcod.
def var vdata1 as date.
def var vdata2 as date.
def var vdtaux as date.
def var vprocod like produ.procod.
def var vsal-ant as dec.
def var vsal-ent as dec.
def var vsal-sai as dec.
def var vsal-atu as dec.
def var vest-atu as dec.

def var c-dir as char init "/admcom/import/recalculo.csv" format "x(59)".

def temp-table tt-movim
    field etbcod like estab.etbcod
    field procod like produ.procod.

vdata1 = today.
vdata2 = today.


update c-dir label "Pasta e arquivo" help "Layout do arquivo: etbcod ; procod" with 1 col side-label width 80 title " Informe os dados abaixo: ".

input from value(c-dir) no-convert.
    repeat:
        create tt-movim.
        import delimiter ";" tt-movim no-error.
    end.
input close.


for each tt-movim.

    vetbcod = tt-movim.etbcod.

    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        bell.
        message color red/with
        "Estabelecimento nao cadastrado"
        view-as alert-box.
        next.
    end.

    disp vetbcod format ">>9" estab.etbnom 
    with frame f-data side-label width 80.

    vprocod = tt-movim.procod.

    find produ where produ.procod = vprocod no-lock no-error.
    if not avail produ 
    then do:
        bell.
        message color red/with
        "Produto nao cadatrado"
        view-as alert-box.
        next.
    end.     

    disp vprocod format ">>>>>>>9" produ.pronom format "x(45)" 
                with frame f-data side-label.

    sparam = "PRODUTO=SIM" +
         "|PROCOD=" + STRING(vprocod) +
         "|ETBCOD=" + string(vetbcod) +
         "|DATAINICIO=01/01/2011" +
         "|CONFIRMAR=SIM" + 
         "|ATUALIZAR=SIM" +
         "|".
         
    run removest20142-new.p.

    sparam = "".

end.

message "TERMINEI!". pause.