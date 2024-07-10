/********************************************************
 Programa: leb-exp-vendas.p
 Autor: Rafael A (Kbase IT)
 Descricao: Extrator de dados das filiais
 Uso: run leb-exp-vendas.p (input <lista-fornec>, 
                            input <dataIni>, 
                            input <dataFim>,
                            output <nome-arq>).
 Historico: 29/04/2015 - Rafael A (Kbase IT) - Criacao
********************************************************/

def var vdebug as log no-undo init "no".
def var vtini  as dec no-undo.
def var vtfim  as dec no-undo.

def input  param p-fornec as char no-undo. /* relaciona com produ.fabcod */
def input  param p-dtini  as date no-undo.
def input  param p-dtfim  as date no-undo.
def output param varq     as char no-undo.

def var vcnpj         as char no-undo.
def var vcpf          as char no-undo.
def var vcupom-fiscal as char no-undo.
def var vcod-ecf      as char no-undo.

def var i as int no-undo.

def temp-table tt-exp-vendas
    field rede            as char
    field cnpj            as char
    field bandeira        as char
    field num             as char
    field cpf-part        as char
    field cod-lebes       as char
    field cod-prod-sam    as char
    field desc-prod       as char
    field qtd             as char
    field val-bruto-venda as char
    field dt-venda        as char
    field nf-venda        as char
    field nf-serie        as char
    field cupom-fiscal    as char
    field cod-ecf         as char.

def temp-table tt-fornec
    field p-fornec as int
    index idx01 p-fornec asc.

def temp-table tt-clubebis like tbclube
    index idx01 is primary funcod asc
                           etbcod asc.

if vdebug then
    output to value ("/home/kbase/gargalo-ext-vendas").

if vdebug then put unformatted time skip.
vtini = time.

do i = 1 to num-entries(p-fornec,","):
    if not can-find(first tt-fornec
           where tt-fornec.p-fornec = int(entry(i,p-fornec,",")))
    then do:
        create tt-fornec.
        assign tt-fornec.p-fornec = int(entry(i,p-fornec,",")).
    end.
end.

if vdebug then put unformatted time skip.
vtfim = time.

if vdebug then put unformatted "tt-fornec total: " 
    string(vtfim - vtini) skip.

if vdebug then put unformatted time skip.
vtini = time.

for each tbclube no-lock:

    if tbclube.nomclube <> "ClubeBis" then next.

    create tt-clubebis.
    buffer-copy tbclube to tt-clubebis.
end.

if vdebug then put unformatted time skip.
vtfim = time.

if vdebug then put unformatted "tt-cluebis total: " 
    string(vtfim - vtini) skip.

for each estab no-lock:
    for each plani where plani.movtdc  = 5            and
                         plani.etbcod  = estab.etbcod and
                         plani.pladat >= p-dtini      and
                         plani.pladat <= p-dtfim      no-lock:
    
        if vdebug then put unformatted  skip fill("-",50) skip.
        
        for each movim /* use-index icurva */
                       where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod /* and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat and */
                             no-lock:
    
            assign vcnpj         = ""
                   vcpf          = ""
                   vcupom-fiscal = ""
                   vcod-ecf      = "".
        
            if vdebug then put unformatted "Produ "  time skip.
            vtini = time.
            
            find first produ 
                 where produ.procod = movim.procod no-lock no-error.

            if not avail produ then next.
        
            if not can-find(first tt-fornec
                            where tt-fornec.p-fornec = produ.fabcod) then next.
        
            if vdebug then put unformatted "Produ " time skip.
            vtfim = time.
            
            if vdebug then put unformatted "produ total: " 
                string(vtfim - vtini) skip.
            
            if vdebug then put unformatted "TabEcf " time skip.
            vtini = time.
            
            for each tabecf where tabecf.etbcod = plani.etbcod  and
                                  tabecf.equi   = plani.cxacod  and
                                  tabecf.datini <= plani.pladat and
                                  tabecf.datfin >= plani.pladat
                                  no-lock:
            
                if vcod-ecf <> "" then
                   vcod-ecf = vcod-ecf + ",".
            
                vcod-ecf = vcod-ecf + string(tabecf.serie).
            end.
        
            if vdebug then put unformatted "TabEcf " time skip.
            vtfim = time.
            
            if vdebug then put unformatted "tabecf total: " 
                string(vtfim - vtini) skip.
            
            if avail estab then
                vcnpj = replace(
                           replace(
                               replace(estab.etbcgc,"/",""),
                           "-",""),
                        ".","").
            else
                vcnpj = "".
        
            if vdebug then put unformatted "CPF vend " time skip.
            vtini = time.
                        
            /* inicio busca cpf vendedor */
            find first tt-clubebis 
                 where tt-clubebis.funcod   = plani.vencod and
                       tt-clubebis.etbcod   = plani.etbcod
                       no-lock no-error.
                                         
            if avail tt-clubebis then                                         
                find first clien 
                     where clien.clicod = tt-clubebis.clicod no-lock no-error.
        
            if avail clien then do:
                vcpf = replace(clien.ciccgc,"-","").
            end.
            else vcpf = "".
            
            if vcpf = "" then next.
            
            /* fim busca cpf vendedor */
            if vdebug then put unformatted "CPF vend " time skip.
            vtfim = time.
            
            if vdebug then put unformatted "busca cpf total: "
                string(vtfim - vtini) skip.

            if num-entries(plani.notped, "|") > 1 then
                vcupom-fiscal = entry(2,plani.notped,"|").
            else
                vcupom-fiscal = plani.notped.
            
            create tt-exp-vendas.
            assign tt-exp-vendas.rede            = ""
                   tt-exp-vendas.cnpj            = vcnpj
                   tt-exp-vendas.bandeira        = ""
                   tt-exp-vendas.num             = string(movim.etbcod)
                   tt-exp-vendas.cpf-part        = vcpf
                   tt-exp-vendas.cod-lebes       = string(movim.procod)
                   tt-exp-vendas.cod-prod-sam    = if avail produ then
                                                      produ.prorefter
                                                   else ""
                   tt-exp-vendas.desc-prod       = if avail produ then 
                                                      produ.pronom
                                                   else ""
                   tt-exp-vendas.qtd             = string(movim.movqtm)
                   tt-exp-vendas.val-bruto-venda = string(plani.platot)
                   tt-exp-vendas.dt-venda        =
                                        string(movim.movdat,"99/99/9999")
                   tt-exp-vendas.nf-venda        = string(plani.numero)
                   tt-exp-vendas.nf-serie        = string(plani.serie)
                   tt-exp-vendas.cupom-fiscal    = vcupom-fiscal
                   tt-exp-vendas.cod-ecf         = vcod-ecf.
               
        end.
    end.
end.

if vdebug then output close.

varq = "/admcom/export_clubes/leb-ext-vendas-" + string(time) + ".csv".

output to value (varq).

/* cabecalho */
put "Rede; CNPJ Loja; Bandeira; Numero Filial; CPF Participante; Codigo Lebes;"    "Codigo Produto (Referência); Descricao do Produto; Quantidade;"      "Valor Bruto de Venda (Unitario); Data Venda; NF Venda; Serie da NF;"
    "Cupom Fiscal; Codigo do ECF" skip.

for each tt-exp-vendas no-lock:
    export delimiter ";" tt-exp-vendas.
end.

output close.
