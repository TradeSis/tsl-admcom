def new shared temp-table tt-plani like plani.

{movim-fil22-movtdc12.i new}
/*
def new shared temp-table tt-movim like movim
    field descricao-produto as char.
*/
def new shared temp-table reg-c
    field CNPJ-emitente   as        CHAR 
    field CNPJ-destino   as         CHAR  
    field total-produtos          as DEC 
    field base-icms               as DEC 
    field valor-icms              as DEC 
    field base-substitucao        as DEC 
    field valor-icms-substiuicao  as DEC 
    field valor-acrescimo         as DEC  
    field valor-desconto          as DEC  
    field valor-frete             as DEC  
    field valor-seguro            as DEC  
    field valor-despesas          as DEC  
    field valor-ipi               as DEC  
    field valor-outras            as DEC  
    field valor-isento            as DEC  
    field total-da-nota           as DEC  
    field obs as char extent 6
    field CNPJ-transportador   as char
    field NOME-transportador   as char
    field QTD-Volumes          as INT
    field Especie              as CHAR 
    field Tipo-frete           as char
    field Placa                as CHAR
    field UF-transp            as CHAR
    .

def new shared temp-table reg-i
    field cfop                      as INT 
    field sequencia                 as INT 
    field codigo-produto            as INT 
    field descricao-produto         as CHAR 
    field quantidade                as DEC 
    field valor-unitario            as DEC 
    field Aliquota-icms             as DEC 
    field valor-icms                as DEC 
    field aliquota-ipi              as DEC 
    field valor-ipi                 as DEC 
    .

run impprenf.p.

find first reg-c no-error.
if not avail reg-c then return.
find first reg-i no-error.
if not avail reg-i then return.
def var vtrans    like  clien.clicod.

find tipmov where tipmov.movtdc = 13 no-lock.
find first opcom where opcom.movtdc = tipmov.movtdc no-lock no-error.

def var vserie like plani.serie.
vserie = "55".
def var v-ok as log.
v-ok = no.

def var vcnpjemite as char.
def var vcnpjdesti as char.
vcnpjemite = substr(reg-c.cnpj-emite,1,2) + "." +
             substr(reg-c.cnpj-emite,3,3) + "." +
             substr(reg-c.cnpj-emite,6,3) + "/" + 
             substr(reg-c.cnpj-emite,9,4) + "-" +
             substr(reg-c.cnpj-emite,13,2) .
vcnpjdesti = substr(reg-c.cnpj-destino,1,2) + "." +
             substr(reg-c.cnpj-destino,3,3) + "." +
             substr(reg-c.cnpj-destino,6,3) + "/" + 
             substr(reg-c.cnpj-destino,9,4) + "-" +
             substr(reg-c.cnpj-destino,13,2) .
          
find first forne where forcgc = trim(reg-c.cnpj-destino) no-lock no-error.
if not avail forne
then find first forne where forcgc = vcnpjdesti no-lock no-error.

if forne.ufecod <> "RS"
then find first opcom where opcom.movtdc = tipmov.movtdc
                        and opcom.opccod = "6202"
                            no-lock no-error.

find first estab where estab.etbcgc = trim(reg-c.cnpj-emite) no-lock no-error.
if not avail estab
then find first estab where estab.etbcgc = vcnpjemite no-lock no-error.
if avail estab
then do:
    create tt-plani.
    assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = ?
               tt-plani.protot   = reg-c.total-produtos 
               tt-plani.desti    = forne.forcod
               tt-plani.bicms    = reg-c.base-icms
               tt-plani.icms     = reg-c.valor-icms
               tt-plani.bsubst   = reg-c.base-substitucao
               tt-plani.icmssubst = reg-c.valor-icms-substiuicao
               tt-plani.descpro  = reg-c.valor-desconto
               tt-plani.acfprod  = reg-c.valor-acrescimo
               tt-plani.frete    = reg-c.valor-frete
               tt-plani.seguro   = reg-c.valor-seguro
               tt-plani.desacess = reg-c.valor-despesas
               tt-plani.ipi      = reg-c.valor-ipi
               tt-plani.platot   = reg-c.total-da-nota 
               tt-plani.serie    = vserie
               tt-plani.numero   = 0
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.emite    = estab.etbcod
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = int(opcom.opccod)
               tt-plani.notfat   = estab.etbcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.nottran  = vtrans
               tt-plani.dtinclu  = today
              tt-plani.notobs[1] = trim(reg-c.obs[1]) + " " + trim(reg-c.obs[2])
              tt-plani.notobs[2] = trim(reg-c.obs[3]) + " " + trim(reg-c.obs[4])
              tt-plani.notobs[3] = trim(reg-c.obs[5]) + " " + trim(reg-c.obs[6])
               tt-plani.hiccod   = int(opcom.opccod)
               tt-plani.outras = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
               tt-plani.isenta = tt-plani.platot 
                        - tt-plani.outras - tt-plani.bicms.

    for each reg-i by sequencia:
        create tt-movim.
        ASSIGN tt-movim.movtdc = tt-plani.movtdc
               tt-movim.ocnum   = reg-i.cfop
               tt-movim.PlaCod = tt-plani.placod
               tt-movim.etbcod = tt-plani.etbcod
               tt-movim.movseq = reg-i.sequencia
               tt-movim.procod = reg-i.codigo-produto
               tt-movim.descricao-produto = reg-i.descricao-produto
               tt-movim.movqtm = reg-i.quantidade
               tt-movim.movpc  = reg-i.valor-unitario
               tt-movim.MovAlICMS = reg-i.aliquota-icms
               tt-movim.movicms   = reg-i.valor-icms
               tt-movim.MovAlIPI  = reg-i.aliquota-ipi
               tt-movim.movipi    = reg-i.valor-ipi
               tt-movim.movdes    = 0
               tt-movim.movdat    = tt-plani.pladat
               tt-movim.MovHr     = int(time)
               tt-movim.desti     = tt-plani.desti
               tt-movim.emite     = tt-plani.emite.
               
                      
    end.
    /*
    sresp = no.
    message "Confirma Emissao da Nota " update sresp.
    if sresp
    then*/ 

    run pre_nfe_5202.p (output v-ok).

    if v-ok
    then unix silent value("mv /admcom/nfe/logosystem/PreNota.txt 
                               /admcom/nfe/logosystem/PreNota.uso").
                               
end.
