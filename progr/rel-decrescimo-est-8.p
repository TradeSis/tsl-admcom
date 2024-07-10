{admcab.i}

update  vetbcod like estab.etbcod at 2  label "Filial"
        with frame f1.
if vetbcod > 0
then do:
find estab where estab.etbcod = vetbcod no-lock no-error.
if not avail estab then undo.
disp estab.etbnom no-label with frame f1.
end.
        
update  vdti as date at 1 format "99/99/9999" label "Periodo"
        vdtf as date format "99/99/9999" no-label
        with frame f1 side-label width 80.
        
if vdti = ? or vdtf = ? or vdti > vdtf
then do:
    message color red/with
    "Periodo invalido."
    view-as alert-box.
    undo.
end.
def temp-table tt-ajuste no-undo
    field etbcod like estab.etbcod
    field movdat like movim.movdat
    field motivo as char
    field procod like produ.procod
    field pronom like produ.pronom
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    field codfis like produ.codfis  format ">>>>>>>>9"
    field ufemi  like plani.ufemi
    field ieemi  as char
    field forcod like forne.forcod
    field nfentra like plani.numero format ">>>>>>>>9"
    field dtentra like plani.dtinclu
    field bicms   like plani.bicms
    field icmsentra like plani.icms
    field mva as dec
    field icms like plani.icms
    field ipi like plani.ipi
    field bsubst like plani.bsubst
    field icmssubst like plani.icmssubst
    index i1 etbcod
    .
        
def buffer bplani for plani.
def buffer bmovim for movim.

def var vdata as date.
for each estab no-lock:
    if vetbcod > 0 and estab.etbcod <> vetbcod then next.
    disp estab.etbcod label "Processando filial " 
    with 1 down side-label . pause 0.
do vdata = vdti to vdtf:
    for each plani where plani.etbcod = estab.etbcod and
                     plani.movtdc = 8 and
                     plani.pladat = vdata
                     no-lock.
        find tipmov where tipmov.movtdc = plani.movtdc no-lock.

        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc
                             no-lock,
            first produ where produ.procod = movim.procod and
                              produ.proipiper = 99 no-lock:
            find estoq where estoq.procod = movim.procod and
                             estoq.etbcod = movim.etbcod
                             no-lock no-error.            
            create tt-ajuste.
            assign
                tt-ajuste.etbcod = movim.etbcod
                tt-ajuste.movdat = movim.movdat
                tt-ajuste.motivo = tipmov.movtnom  
                tt-ajuste.procod = movim.procod
                tt-ajuste.pronom = produ.pronom
                tt-ajuste.movqtm = movim.movqtm
                tt-ajuste.movpc  = movim.movpc * movim.movqtm
                tt-ajuste.codfis = produ.codfis
                tt-ajuste.icms   = produ.proipiper
                tt-ajuste.dtentra = ?
                .
                /***
            if avail estoq
            then tt-ajuste.movpc = estoq.estvenda * movim.movqtm. 
                    ***/
            find last bmovim where bmovim.procod = movim.procod and
                                   bmovim.movtdc = 4 and
                                   bmovim.datexp < movim.movdat
                                   no-lock no-error.
            if avail bmovim
            then do:
                find first bplani where bplani.etbcod = bmovim.etbcod and
                                         bplani.placod = bmovim.placod and
                                         bplani.movtdc = bmovim.movtdc 
                                         no-lock no-error.
                if avail bplani
                then do:
                    find forne where forne.forcod = bplani.emite
                                                no-lock no-error.
                    if avail forne
                    then assign
                            tt-ajuste.ufemi = forne.ufecod
                            tt-ajuste.ieemi = forne.forinest
                            tt-ajuste.forcod = forne.forcod
                            .
                    assign
                        tt-ajuste.nfentra = bplani.numero
                        tt-ajuste.dtentra = bplani.dtinclu
                        tt-ajuste.ipi     = bmovim.movipi / bmovim.movqtm
                        tt-ajuste.bsubst  = bmovim.movbsubst / bmovim.movqtm
                        tt-ajuste.icmssubst = bmovim.movsubst / bmovim.movqtm
                        .
                end.
                assign
                    tt-ajuste.bicms = bmovim.movbicms / bmovim.movqtm
                    tt-ajuste.icmsentra = bmovim.movalicms
                    .
            end. 
            find clafis where clafis.codfis = produ.codfis no-lock no-error.
            if avail clafis
            then tt-ajuste.mva = clafis.mva_estado1.

        end.                                 
    end.
end.
end.    

def var varquivo as char.
def var varquivo-csv as char.
varquivo = "/admcom/relat/decrescimo-estoque." + string(time).
varquivo-csv = "/admcom/relat/decrescimo-estoque-" + string(time) + ".csv".

output to value(varquivo-csv).
    
put "Filial;Data;Motivo;Produto;Descricao;Qunat;ValorVenda;NCM;UFemi;IEemi;Fornecedor;NFc
ompra;DtEntra;BC ICMS;Aliq.Emi;MVA;AliqInt;IPI;BC ST;Valor ST" skip.

for each tt-ajuste:
    put unformatted     
                tt-ajuste.etbcod ";"
                tt-ajuste.movdat ";"
                tt-ajuste.motivo ";"
                tt-ajuste.procod ";"
                tt-ajuste.pronom ";"
                tt-ajuste.movqtm ";"
                tt-ajuste.movpc  ";"
                tt-ajuste.codfis ";"
                tt-ajuste.ufemi  ";"
                tt-ajuste.ieemi  ";"
                tt-ajuste.forcod ";"
                tt-ajuste.nfentra ";"
                tt-ajuste.dtentra ";"
                tt-ajuste.bicms ";"
                tt-ajuste.icmsentra ";"
                tt-ajuste.codfis   ";"
                tt-ajuste.mva ";"
                tt-ajuste.icms ";"
                tt-ajuste.ipi  ";"
                tt-ajuste.bsubst  ";"
                tt-ajuste.icmssubst 
                skip.
                                                
end.
output close.

{mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "275"  
        &Page-Line = "66"
        &Nom-Rel   = ""prodevduv""  
        &Nom-Sis   = """ADMCOM CONTABILIDADE"""
        &Tit-Rel   = """RELATORIO AJUSTE DECRESCIMO ESTOQUE"""
        &Width     = "275"
        &Form      = "frame f-cabcab"}

    disp with frame f1.


for each tt-ajuste break by tt-ajuste.etbcod:
    disp    
                tt-ajuste.etbcod  column-label "Fil" 
                tt-ajuste.movdat  column-label "Data"
                tt-ajuste.motivo  column-label "Motivo" format "x(18)"
                tt-ajuste.procod  column-label "Produto"
                tt-ajuste.pronom  column-label "Descricao" format "x(40)"
                tt-ajuste.movqtm(total by tt-ajuste.etbcod)  column-label "Quant"
                tt-ajuste.movpc(total by tt-ajuste.etbcod)   column-label "Valor Venda"
                tt-ajuste.codfis  column-label "NCM"
                tt-ajuste.ufemi   column-label "UFemi"
                tt-ajuste.ieemi   column-label "IEemi"  format "x(15)"
                tt-ajuste.forcod  column-label "Fornecedor"
                tt-ajuste.nfentra column-label "NFentrada"
                tt-ajuste.dtentra column-label "DtEntrada"
                tt-ajuste.bicms   column-label "BC ICMS"
                tt-ajuste.icmsentra  column-label "AliqEmi"
                tt-ajuste.mva     column-label "MVA"
                tt-ajuste.icms    column-label "AliqInt"
                tt-ajuste.ipi     column-label "IPI"
                tt-ajuste.bsubst  column-label "BC ST"
                tt-ajuste.icmssubst column-label "Valor ST"
                with frame f-disp down width 290.
        down with frame f-disp.                
                                                
end.
output close.


message color red/with
    "Arquivo CSV gerado" skip
    varquivo-csv
    view-as alert-box.
    

run visurel.p(varquivo,"").


