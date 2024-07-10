/********************************************************
 Programa: leb-exp-produ.p
 Autor: Rafael A (Kbase IT)
 Descricao: Extrator de dados dos produtos
 Uso: run leb-exp-produ.p (input <lista-fornec>, output <nome-arq>).
 Historico: 28/04/2015 - Rafael A (Kbase IT) - Criacao
********************************************************/

def input  param p-fornec as char no-undo. /* relaciona com produ.fabcod */
def output param varq     as char no-undo.

def var i as int no-undo.

def temp-table tt-exp-produ
    like produ.

def temp-table tt-fornec
    field p-fornec as int.
    
do i = 1 to num-entries(p-fornec,","):
    if not can-find(first tt-fornec 
                    where tt-fornec.p-fornec = int(entry(i,p-fornec,",")))
    then do:
        create tt-fornec.
        assign tt-fornec.p-fornec = int(entry(i,p-fornec,",")).
    end.
end.

for each produ no-lock:
    
    if not can-find(first tt-fornec
                    where tt-fornec.p-fornec = produ.fabcod) then next.
    
    if not can-find(first tt-exp-produ
                    where tt-exp-produ.itecod = produ.itecod) then do:
        create tt-exp-produ.
        buffer-copy produ to tt-exp-produ.
    end.
end.

varq = "/admcom/export_clubes/leb-ext-produ-" + string(time) + ".csv".

output to value (varq).

/* cabecalho */
put "Produto; Nome Produto; Desc.Automacao; Fab.; Classe; UC; UV; ABC;"
    "Data Cadastro; Pagina; Seq; IPI %; IPI Valor; Clas.Fiscal; Conversao;"     "Conversao; Refer. Terceiros; Tam; Cor; Item; Estacao; prozort;"
    "Caracteristica; Categoria; Cod; datexp; Exportado; codfis; codori;"
    "codtri; D.Revista; PVP; Descontinuado; DatFimVida; OpenToBuy; TempCod"
    skip.

for each tt-exp-produ no-lock:
    export delimiter ";" tt-exp-produ.
end.

output close.