{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.

update vetbcod label "Filial"
            with frame f-1 1 down width 80 side-label.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f-1 .
end.

update vdti at 1 label "Periodo"
       vdtf no-label 
        with frame f-1.


def temp-table tt-clirenda like clirenda.

for each clirenda where clirenda.datinclu >= vdti and
                        clirenda.datinclu <= vdtf 
                        no-lock:
    if vetbcod > 0 and
        vetbcod <> clirenda.etbcod
    then undo.
   
    find clien where clien.clicod = clirenda.clicod no-lock no-error.
        if not avail clien then next.
        
    find rendaprofi where
         rendaprofi.etbcod = clirenda.etbcod and
         rendaprofi.codprof = clirenda.codprof
         no-lock no-error.
    if not avail rendaprofi
    then find rendaprofi where
            rendaprofi.etbcod = 0 and
            rendaprofi.codprof = clirenda.codprof
            no-lock no-error.
    if not avail rendaprofi then next.

    if rendaprofi.valrenda <> clien.prorenda[1]
    then.
    else  next.
    
    create tt-clirenda.
    buffer-copy clirenda to tt-clirenda.
    tt-clirenda.renda-profissao = rendaprofi.valrenda.
end.

def var varquivo as char.
varquivo = "/admcom/relat/rclirenda." + string(time).

{mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "64"
            &Nom-Rel   = ""RCLIRENDA""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """ALTERACAO DE RENDA "" +
                                  string(vdti,""99/99/9999"") + "" ATE "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}

disp with frame f-1.
def var vcli-nome as char.    

for each tt-clirenda:
    find clien where clien.clicod = tt-clirenda.clicod no-lock no-error.
    find func where
         func.etbcod = tt-clirenda.etbcod and
         func.funcod = tt-clirenda.funcod
         no-lock no-error.
         
        vcli-nome = string(tt-clirenda.funcod) + " - " .
        if avail func
        then vcli-nome = vcli-nome + func.funnom.

        disp 
           tt-clirenda.clicod   column-label "Codigo"
           clien.clinom when avail clien   column-label "Nome"
                        format "x(30)"
           vcli-nome column-label "Responsavel" format "x(30)"
           tt-clirenda.renda-antes column-label "Renda!Anterior"
           tt-clirenda.renda-atual     column-label "Renda!Informada"
           tt-clirenda.codprof          column-label "Profissao"
           tt-clirenda.char1     format "x(30)"    no-label
           with frame f-renda down

           width 150.
           
end.
output close.
           
run visurel.p(varquivo, "").
           
