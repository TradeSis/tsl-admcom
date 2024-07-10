/********************************************************
 Programa: leb-exp-estab.p
 Autor: Rafael A (Kbase IT)
 Descricao: Extrator de dados das filiais
 Uso: run leb-exp-estab.p (output <nome-arq>).
 Historico: 28/04/2015 - Rafael A (Kbase IT) - Criacao
********************************************************/

def output param varq as char no-undo.

def var vsupervisor as char no-undo.
def var vcnpj       as char no-undo.
def var vcep        as char no-undo.
def var vbairro     as char no-undo.
def var vtp-lograd  as char no-undo.
def var vtel        as char no-undo.
def var vnum        as char no-undo.
def var vlograd     as char no-undo.
def var vendereco   as char no-undo.

def temp-table tt-exp-estab
    field rede          as char
    field diretoria     as char
    field regional      as char
    field cnpj          as char
    field raz-social    as char
    field bandeira      as char
    field num-filial    as char
    field nome-fant     as char
    field cod-loja-rede as char
    field cod-loja-sam  as char
    field tp-lograd     as char
    field lograd        as char
    field num           as char
    field complem       as char
    field bairro        as char
    field cidade        as char
    field estado        as char
    field cep           as char
    field ddd           as char
    field tel           as char
    index idx01 num-filial asc.

for each estab no-lock:

    assign vsupervisor = ""
           vcep        = ""
           vbairro     = ""
           vtp-lograd  = ""
           vcnpj       = ""
           vtel        = ""
           vnum        = ""
           vlograd     = ""
           vendereco   = "".

    if not can-find(first tt-exp-estab 
                    where int(tt-exp-estab.num-filial) = estab.etbcod) then do:
        
        vendereco = estab.endereco.
        
        find first filialsup where filialsup.etbcod = estab.etbcod
                                   no-lock no-error.
                                                                                       if avail filialsup then do:
            find first supervisor 
                 where supervisor.supcod = filialsup.supcod
                       no-lock no-error.
                                                                                           if avail supervisor then
                vsupervisor = supervisor.supnom.
            else 
                vsupervisor = "".
        end.
        else
            vsupervisor = "".
            
        
        if estab.endereco begins "rua" then 
            assign vtp-lograd = "Rua"
                   vendereco  = substr(estab.endereco, 4).
        else if estab.endereco begins "avenida" then
                    assign vtp-lograd = "Avenida"
                           vendereco  = substr(estab.endereco, 8).
        else if estab.endereco begins "av." then
            assign vtp-lograd = "Avenida"
                   vendereco  = substr(estab.endereco, 4).
         else if estab.endereco begins "av" then
                     assign vtp-lograd = "Avenida"
                            vendereco  = substr(estab.endereco, 3).
        else 
            vtp-lograd = "".
        
        
        find tabaux where tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999")                       and tabaux.nome_campo = "BAIRRO" no-lock no-error.
        
        if avail tabaux then 
            vbairro = tabaux.valor_campo.
        else 
            vbairro = "".
                                             
        
        find tabaux where tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999")                       and tabaux.nome_campo = "CEP" no-lock no-error.
        
        if avail tabaux then 
            vcep = replace(tabaux.valor_campo,"-","").
        else 
            vcep = "".
        
        if num-entries(vendereco, ",") > 1 then do:
            assign vnum    = entry(2, vendereco, ",")
                   vlograd = entry(1, vendereco, ",").
        end.
        else do:
            assign vnum    = ""
                   vlograd = vendereco.
        end.
        
        assign vcnpj = replace(
                            replace(
                                replace(estab.etbcgc,"/",""),
                            "-",""),
                       ".","").
               vtel  = replace(substr(string(estab.etbserie), 3),"-","").
        
        create tt-exp-estab.
        assign tt-exp-estab.rede          = ""
               tt-exp-estab.diretoria     = ""
               tt-exp-estab.regional      = ""
               tt-exp-estab.cnpj          = vcnpj
               tt-exp-estab.raz-social    = caps(estab.etbnom)
               tt-exp-estab.bandeira      = ""
               tt-exp-estab.num-filial    = string(estab.etbcod)
               tt-exp-estab.nome-fant     = estab.etbnom
               tt-exp-estab.cod-loja-rede = string(estab.etbcod)
               tt-exp-estab.cod-loja-sam  = ""
               tt-exp-estab.tp-lograd     = vtp-lograd
               tt-exp-estab.lograd        = vlograd
               tt-exp-estab.num           = vnum
               tt-exp-estab.complem       = ""
               tt-exp-estab.bairro        = vbairro
               tt-exp-estab.cidade        = estab.munic
               tt-exp-estab.estado        = estab.ufecod
               tt-exp-estab.cep           = vcep
               tt-exp-estab.ddd           = substr(string(estab.etbserie),1,2)
               tt-exp-estab.tel           = vtel.

    end.
end.

varq = "/admcom/export_clubes/leb-ext-estab-" + string(time) + ".csv".

output to value (varq).

/* cabecalho */
put "Rede; Diretoria; Regional; CNPJ Loja; Razão Social da Loja; Bandeira;"     "Número Filial; Nome Fantasia; Código Loja na Rede;"
    "Código Loja na Samsung; Tipo Logradouro; Logradouro; Numero;"
    "Complemento; Bairro; Cidade; Estado; CEP; DDD; Telefone" skip.


for each tt-exp-estab no-lock:
    export delimiter ";" tt-exp-estab.
end.

output close.