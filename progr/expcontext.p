/* helio 15082023 - 499799 - SEPARAÇÃO DE DATA DE ÚLTIMA COMPRA E DE ÚLTIMA NOVAÇÃO INTEGRAÇÃO PMWEB E 513689 - DATA NOVAÇÃO */
/* helio 12062023 Demanda 343 - ID 30263 - Envio de Limite disponível para a PMWEB */
/* Varre Pagamentos, para Export Saldo Atualizado Lmite 29/10/2021  */
/* HUBSEG 19/10/2021 */


def var vhostname as char.
def var xetbcod as int.
input through hostname.
import vhostname.
input close.
def var vhml as log.
vhml = no.
if vhostname = "SV-CA-DB-DEV" or 
   vhostname = "SV-CA-DB-QA"
then vhml = yes.

if not vhml
then run /admcom/progr/forcacontexttrg.p.

{/admcom/progr/neuro/achahash.i}
{/admcom/progr/neuro/varcomportamento.i}

function comasp return character (
    input pcampo as char):
    def var vasp    as char init "\"".
    return
        vasp + pcampo + vasp.
end function.


def var vhora   as char.
def var vloop   as int.
def var vcoma   as char.
def var vdir    as char init "/admcom/tmp/context/".

def var vtmp    as char extent 6 init
    ["tmp1","tmp2","tmp3","tmp4","tmp5","tmp6"].
def var varq    as char extent 6 init
    ["order","orderitems","contacts","products","sellers","stores"].

def var vmini_pedido as log.
def var vtime   as int.
def var vdate   as date.

def var vdtfim  as date.

vdate = today.
vtime = time.


def var vCod_plano as int.
def var vDesc_plano as char.
def var vphone_loja as char.

def buffer depto    for clase.  /*DEPARTAMENTO  */
def buffer setor    for clase.  /*    SETOR  */
def buffer grupo    for clase.  /*        GRUPO  */
def buffer classe   for clase.  /*            CLASSE  */
def buffer subclasse for clase. /*                SUB-CLASSE */
                                                  
def var par-parametro  as char init "EXPCONTEXT".
def var par-dtultimoprocesso as date. /* Periodo de verificacao */
def var vconta as int.

def var vvlrlimite as dec.
def var vvctolimite as date.
def var vcomprometido as dec.
def var vcomprometidoPR as dec.
def var vcomprometidoHUBSEG as dec.

def var vsaldoLimite as dec.
def var vspc_lebes as log.

def var vdata_ultima_compra         as date.
def var vdata_ultima_novacao         as date.
def var vvlr_contratos              as dec.
def var vqtd_pagas                  as int.
def var vqtd_abertas                as int.
def var vqtd_atraso_ate_15_dias     as int.
def var vqtd_atraso_de_16_a_45_dias as int.         
def var vqtd_atraso_acima_de_45     as int.
def var vReparcelamento             as log format "SIM/NAO".
def var vqtd_dias_Atraso_Atual      as int.
def var vdata_ult_pgto              as date.
def var vdata_prox_vcto_aberto      as date.
def var vSituacao_contrato              as log.
def var vCliente_Feirao_ativo           as log.
def var voptinEmail                 as log.
def var vtotalnov               as dec.
def var vsaldofeiraoaberto      as dec.

def var vcp as char init ";".
def var cestcivil as char.
def var vvalorvenda as dec.
def var vven_transacao as int.
def var verro       as log.
def var vdata       as date.

def var vrfv as char. /* helio 26032024 - RFV */
def var vclassificacao as char. /* helio 26032024 - RFV */

def temp-table tt-cli no-undo
    field clicod            like clien.clicod
    index clitrans is unique primary
                clicod asc.


def temp-table tt-pro no-undo
    field procod            like produ.procod
    index clitrans is unique primary
                procod asc.

def temp-table tt-vend no-undo
    field etbcod            like plani.etbcod
    field vencod            like plani.vencod
    index vendtrans is unique primary
                etbcod asc vencod  asc.

find first tab_ini where tab_ini.parametro = par-parametro
    no-lock no-error.
if not avail tab_ini
then do on error undo transaction:
    create tab_ini.
    tab_ini.etbcod = 0.
    tab_ini.parametro = par-parametro.
    tab_ini.valor  = if time <= 60000
                     then string(today - 1,"99/99/9999")
                     else string(today    ,"99/99/9999").
end.

par-dtultimoprocesso = date(tab_ini.valor) - 3.
if par-dtultimoprocesso = ?
then par-dtultimoprocesso = today - 3.

vdtfim = if time <= 60000 
         then today - 1 
         else today. 


hide message no-pause.
message today string(time,"HH:MM:SS") "Exportando" varq[1] "e" varq[2] "desde" par-dtultimoprocesso "ate" vdtfim.

def stream ven. output stream ven to value(vdir + vtmp[1]). 
def stream ite. output stream ite to value(vdir + vtmp[2]). 

put stream ven unformatted  
       comasp("ORDER_ID")               vcp     /*ID da transação*/
       comasp("ORDER_STORE ID")         vcp     /*ID da loja*/
       comasp("ORDER_STORE_TYPE")       vcp     /*Tipo de loja origem*/
       comasp("ORDER_DATE")             vcp     /*Data de faturamento do pedido*/
       comasp("ORDER_REQUEST_DATE")     vcp     /*Data de solicitação do pedido*/
       comasp("COD_CLIENT")             vcp     /*ID único do cliente*/
       comasp("EMAIL")                  vcp     /*Endereço de e-mail*/
       comasp("ORDER_STATUS")           vcp     /*Status do pedido*/
       comasp("PAYMENT_METHOD")         vcp     /*Forma de pagamento*/
       comasp("ORDER_TOTAL_PRICE")      vcp     /*Valor total do pedido*/
       comasp("Nota")                   vcp     /*Nota*/
       comasp("Cod_plano")  vcp
       comasp("Desc_plano") vcp
       comasp("Serie")      vcp         /* #2 */
       skip.

put stream ite unformatted  
        comasp("ORDER_ID")              vcp     /*ID da transação*/
        comasp("ORDER_STORE")           vcp     /*ID da loja*/
        comasp("ORDER_DATE")            vcp     /*Data do pedido*/
        comasp("PRODUCT_ID")           vcp     /*SKU do produto*/
        comasp("PRODUCT_ITEM_SEQ")      vcp     /*Sequencial do item do pedido*/
        comasp("QUANTITY")              vcp     /*Quantidade adquirida*/
        comasp("PRICE")                 vcp     /*Preço unitário*/
        comasp("SELLER_ID")             vcp     /*Id do vendedor do produto*/
        comasp("PRODUCT_NAME")          vcp     /*Nome do produto*/
        skip.

/*#4*/
def var vvendas as int.
vvendas = 0.
for each contexttrg where contexttrg.movtdc = 5 and 
          contexttrg.dtenvio = ?
         no-lock.
    find plani where recid(plani) = contexttrg.trecid no-lock no-error.
    if not avail plani
    then next.
/*#4*/    
    /*#4for each plani where
    *    plani.datexp  >= par-dtultimoprocesso and
    *    plani.datexp  <= vdtfim no-lock.
    *
    *    if plani.movtdc <> 5
    *    then next.
        #4*/
        
        find estab where estab.etbcod = plani.etbcod no-lock no-error.
        if not avail estab then next.
                         
        find clien where clien.clicod = plani.desti no-lock no-error.
        if not avail clien
        then find clien where clien.clicod = 1 no-lock.

        vvalorvenda = if plani.biss > 0  
                      then plani.biss
                      else (plani.platot /* 09.07.19 - plani.vlserv*/  ).
 
        find first tt-cli where tt-cli.clicod = clien.clicod 
            no-error.         
        if not avail tt-cli
        then do:
            create tt-cli.
            tt-cli.clicod = clien.clicod. 
            vvendas = vvendas + 1.
        end.    

        find first tt-vend where 
                tt-vend.etbcod = plani.etbcod and
                tt-vend.vencod = plani.vencod 
            no-error.         
        if not avail tt-vend
        then do:
            create tt-vend.
            tt-vend.etbcod = plani.etbcod. 
            tt-vend.vencod = plani.vencod. 
        end.    

        vcod_plano = if plani.pedcod = ?
                     then 0
                     else plani.pedcod.
        find finan where finan.fincod = vcod_plano no-lock no-error.
        vdesc_plano = if avail finan
                      then finan.finnom
                      else "".   
                        
        put stream ven unformatted 
            comasp(string(plani.placod))    vcp
            comasp(string(plani.etbcod))    vcp 
            comasp(estab.tipoLoja)  vcp
            comasp(string(plani.pladat,"99/99/9999"))    vcp
            comasp(string(plani.pladat,"99/99/9999"))    vcp
            comasp(string(clien.clicod))    vcp
            comasp(replace(clien.zona,";"," "))      vcp            
            comasp("FECHADO")       vcp
            comasp(string(plani.crecod))    vcp
            comasp(trim(string(vvalorvenda,"->>>>>>>>>>9.99")))     vcp
            comasp(string(plani.numero))    vcp
            comasp(string(vcod_plano)) vcp
            comasp(vdesc_plano) vcp
            comasp(plani.serie) vcp /* #2 */ 
            skip.

        for each movim where 
                movim.etbcod = plani.etbcod and
                movim.placod = plani.placod
                no-lock.
            find produ      where produ.procod = movim.procod no-lock no-error.
            if not avail produ then next.

            /**
            find subclasse   where subclasse.clacod = produ.clacod no-lock no-error.
            find classe      where classe.clacod    = subclasse.clasup no-lock no-error.
            find grupo       where grupo.clacod     = classe.clacod no-lock no-error.
            find setor       where setor.clacod     = grupo.clasup no-lock no-error.
            find depto       where depto.clacod     = setor.clasup no-lock no-error.
            **/
            
            find first tt-pro where
                tt-pro.procod = movim.procod no-error.
            if not avail tt-pro
            then do:
                create tt-pro.
                tt-pro.procod = movim.procod.
            end.
            put stream ite unformatted  
                comasp(string(plani.placod))           vcp     /*ID da transação*/
                comasp(string(plani.etbcod))           vcp     /*ID da loja*/
                comasp(string(plani.pladat,"99/99/9999"))           vcp     /*Data do pedido*/
                comasp(string(movim.procod))           vcp     /*ID do produto*/
                comasp(string(movim.movseq))           vcp     /*Sequencial do item do pedido*/
                comasp(trim(string(movim.movqtm,"->>>>>>>>>>9.99")))           vcp     /*Quantidade adquirida*/
                comasp(trim(string(movim.movpc ,"->>>>>>>>>>9.99")))            vcp     /*Preço unitário*/
                comasp(string(plani.vencod))           vcp     /*Id do vendedor do produto*/
                replace(produ.pronom,";"," ")          vcp     /*Nome do produto*/ /*02.07.19 - retirado aspas */
                skip.
        end.
    end.       

output stream ven close.
output stream ite close.

hide message no-pause.
message today string(time,"HH:MM:SS") vvendas "clientes com vendas".

hide message no-pause.
message today string(time,"HH:MM:SS") "Verificando Alteracoes de limite".
def var valter as int.
valter = 0.
/* CLIENTES ALTERACAO DE COMPORTAMENTO, SALDO ETC */
for each neuclien where 
    neuclien.compdtultalter >= par-dtultimoprocesso and
    neuclien.compdtultalter <= vdtfim
    no-lock.
    find clien where clien.clicod = neuclien.clicod 
        no-lock no-error.
    if not avail clien
    then next.
        
        find first tt-cli where tt-cli.clicod = clien.clicod 
            no-error.         
        if not avail tt-cli
        then do:
            create tt-cli.
            tt-cli.clicod = clien.clicod. 
            valter = valter + 1.
        end.    
end.    

/* VERIFICACAO DE CLIENTES COM PAGAMENTOS */
hide message no-pause.
message today string(time,"HH:MM:SS") valter "clientes com alteracao limite".

hide message no-pause.
message today string(time,"HH:MM:SS") "Verificando pagamentos de parcelas".
def var vpagos as int.

vpagos = 0.
for each titulo where titulo.titnat = no and
    titulo.titdtpag >= par-dtultimoprocesso and
    titulo.titdtpag <= vdtfim
    no-lock.
    if titulo.modcod  = "CRE" or titulo.modcod begins "CP"
    then.
    else next.
    find clien where clien.clicod = titulo.clifor
        no-lock no-error.
    if not avail clien
    then next.
        
        find first tt-cli where tt-cli.clicod = clien.clicod 
            no-error.         
        if not avail tt-cli
        then do:
            create tt-cli.
            tt-cli.clicod = clien.clicod. 
            vpagos = vpagos + 1.
        end.    
end.    

hide message no-pause.
message today string(time,"HH:MM:SS") vpagos "clientes com pagamento".

/* helio 26032024 - RFV */
for each clirfv where clirfv.datexp = ? no-lock.
    find tt-cli where tt-cli.clicod = clirfv.clicod no-lock no-error.
    if not avail tt-cli
    then do:
        create tt-cli.
        tt-cli.clicod = clirfv.clicod. 
    end.
end.
/* helio 26032024 - RFV */

vconta = 0. 
for each tt-cli. 
    vconta = vconta + 1.
end.


/* CLIENTES */

hide message no-pause.
message today string(time,"HH:MM:SS") "Exportando" varq[3] vconta .

output to value(vdir + vtmp[3]).
    put unformatted
        comasp("COD_CLIENT") vcp
        comasp("EMAIL") vcp
        comasp("MOBILE_NUMBER") vcp
        comasp("PHONE_NUMBER") vcp
        comasp("COUNTRY") vcp
        comasp("STATE") vcp
        comasp("CITY") vcp
        comasp("NEIGHBORHOOD") vcp
        comasp("ADDRESS") vcp
        comasp("ADDRESS_NUMBER") vcp
        comasp("COMPLEMENT") vcp
        comasp("POSTAL_CODE") vcp
        comasp("TYPE_PERSON") vcp
        comasp("GENDER") vcp
        comasp("MARITAL_STATUS") vcp
        comasp("BIRTH_DATE") vcp
        comasp("FULL_NAME") vcp
        comasp("SOURCE_CREATED_DATE") vcp
        comasp("DOCUMENT_NUMBER") vcp
        comasp("DOCUMENT_TYPE") vcp
        
        comasp("profissao") vcp
        comasp("renda") vcp
        comasp("rg_ie") vcp
        comasp("spc_lebes") vcp
        comasp("conjuge_nome") vcp
        comasp("conjuge_cpf") vcp
        comasp("conjuge_dt_nasc") vcp
        comasp("nom_pai") vcp
        comasp("nom_mae") vcp
        comasp("LimiteDisponivel") vcp
        comasp("LimiteTotal") vcp
        comasp("LimiteUtilizado") vcp
        comasp("data_ultima_compra") vcp
        comasp("vlr_contratos") vcp
        comasp("qtd_pagas") vcp
        comasp("qtd_abertas") vcp
        comasp("qtd_atraso_ate_15_dias") vcp
        comasp("qtd_atraso_de_16_a_45_dias") vcp
        comasp("qtd_atraso_acima_de_45") vcp
        comasp("Reparcelamento") vcp
        comasp("qtd_dias_Atraso_Atual") vcp
        comasp("data_ult_pgto") vcp
        comasp("data_prox_vcto_aberto") vcp
        comasp("Situacao_contrato") vcp
        comasp("Cliente_Feirao_ativo") vcp
        comasp("OptinEmail") vcp
        comasp("loja_de_origem") vcp /*02.07.19*/
        comasp("data_ultima_novacao") vcp
        comasp("RFV") vcp           /* helio 26032024 - RFV */
        comasp("classificacao") vcp /* helio 26032024 - RFV */
      
        skip.


for each tt-cli.

    if tt-cli.clicod = 0 then next.
    if tt-cli.clicod = 10845208 /* DemoGorgon */
    then next.

 
    find clien where clien.clicod = tt-cli.clicod no-lock no-error.
    if not avail clien
    then next.
    find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
    
    if clien.ciccgc = ? or /*#1 */
       clien.ciccgc = "" or
       clien.ciccgc = "?"
    then next.
    
    cestcivil = if clien.estciv = 1 then "Solteiro" else
                if clien.estciv = 2 then "Casado"   else
                if clien.estciv = 3 then "Viuvo"    else
                if clien.estciv = 4 then "Desquitado" else
                if clien.estciv = 5 then "Divorciado" else
                if clien.estciv = 6 then "Falecido" else "". 

    vvlrlimite = 0.
    vvctolimite = ?.
    vdata_ult_pgto = ?.
    vcomprometido = 0.
    vcomprometidopr = 0.
    vsaldoLimite = 0.
    vspc_lebes  = no.
    vCliente_Feirao_ativo = no.
    vReparcelamento = no.

        vvlr_contratos    = 0.
        vqtd_pagas        = 0.
        vqtd_abertas      = 0.
        vqtd_atraso_ate_15_dias     = 0.
        vqtd_atraso_de_16_a_45_dias = 0.
        vqtd_atraso_acima_de_45     = 0.

    
    if avail neuclien
    then do:
        vvlrlimite = neuclien.vlrlimite.
        vvctolimite = neuclien.vctolimite.
    end.
    

    def var c1 as char.
    def var r1 as char format "x(30)".
    def var il as int.
    def var vcampo as char format "x(20)". 

    var-propriedades = "".
    
    run /admcom/progr/neuro/comportamento.p (clien.clicod,?,output var-propriedades).

    do il = 1 to num-entries(var-propriedades,"#") with down.
    
        vcampo = entry(1,entry(il,var-propriedades,"#"),"=").
        if vcampo = "FIM"
        then next.
        r1 = pega_prop(vcampo).

        if vcampo = "LIMITETOM" 
        then do:
            vcomprometido = dec(r1).
        end.    
        if vcampo = "LIMITETOMPR" /* H30072021 usar LIMITETOMPR para saldo limite */
        then do:
            vcomprometidoPR = dec(r1).
        end.    
        if vcampo = "LIMITETOMHUBSEG" 
        then do:
            vcomprometidohubseg = dec(r1).
        end.    
        
        if vcampo = "DTULTPAGTO"
        then do:
            vdata_ult_pgto = date(r1).
        end.

        if vcampo = "DTULTCPA" then vdata_ultima_compra = date(r1).        
        if vcampo = "DTULTNOV" then vdata_ultima_novacao = date(r1).        
        

        if vcampo = "SALDOFEIRAOABERTO"
        then do:
            vsaldofeiraoaberto = dec(r1).
            if vsaldofeiraoaberto <> ? and
               vsaldofeiraoaberto > 0
            then do:
                vCliente_Feirao_ativo = yes.
            end.
        end.
        if vcampo = "MAIORACUM"
        then do:
            vvlr_contratos = dec(r1).
        end.
        if vcampo = "PARCPAG"
        then do:
            vqtd_pagas = int(r1).
        end.
        if vcampo = "PARCABERT"
        then do:
            vqtd_abertas = int(r1).
        end.
        if vcampo = "ATRASOPARC"
        then do: 
            if num-entries(r1,"|") = 3  /* helio 25052022 https://trello.com/c/5sfH8VZf/650-erro-arquivos-pmweb */
            then do:
                vqtd_atraso_ate_15_dias     = int(entry(1,r1,"|")).
                vqtd_atraso_de_16_a_45_dias = int(entry(2,r1,"|")).
                vqtd_atraso_acima_de_45     = int(entry(3,r1,"|")).
            end.
            if vqtd_atraso_ate_15_dias = ? then vqtd_atraso_ate_15_dias = 0.
            if vqtd_atraso_de_16_a_45_dias = ? then vqtd_atraso_de_16_a_45_dias = 0.
            if vqtd_atraso_acima_de_45 = ? then vqtd_atraso_acima_de_45 = 0.
        end.
        if vcampo = "TOTALNOV"
        then do:
            vtotalnov = dec(r1).
            if vtotalnov <> ? and
               vtotalnov > 0
            then do:
                vReparcelamento = yes.
            end.
        end.
        if vcampo = "ATRASOATUAL"
        then do:
            vqtd_dias_atraso_atual = int(r1).
        end.
        if vcampo = "DTPROXVCTOABE"
        then do:
            vdata_prox_vcto_aberto = date(r1).            
        end.
   end.
    
    vsaldoLimite = vvlrlimite - vcomprometidoPR - vcomprometidohubseg.
    /** helio 12062023
    *if vvctolimite < today or vvctolimite = ? or
    *    vsaldoLimite < 0
    *then vsaldoLimite = 0. 
    */
    
    
    find first clispc where clispc.clicod = clien.clicod
                                and clispc.dtcanc = ?
                          no-lock no-error.
    if avail clispc
    then do:
        vspc_lebes = yes. 
    end.
    find cpclien of clien no-lock no-error.

    voptinEmail = no.
    if avail cpclien and
       cpclien.emailpromocional 
    then voptinEmail = yes.   

    vsituacao_contrato = if vcomprometido > 0 then yes else no.
    
    /* helio 26032024 - RFV */    
    vrfv = "".
    vclassificacao= "".
    find clirfv where clirfv.clicod = tt-cli.clicod no-lock no-error.
    if avail clirfv
    then do:
        vrfv = clirfv.rfv.
        vclassificacao = clirfv.classificacao.
    end.
    /* helio 26032024 - RFV */
    
    put unformatted
        comasp(string(tt-cli.clicod))               vcp /*helio 15062022 https://trello.com/c/mDv70bK7/657-erro-arquivos-pmweb */
        comasp(replace(clien.zona,";"," "))                  vcp
        comasp(replace(clien.fax,";"," "))                   vcp
        comasp(replace(clien.fone,";"," "))                  vcp
        comasp("BRA")                       vcp
        comasp(replace(clien.ufecod[1],";"," "))     vcp     /*Estado*/
        comasp(replace(clien.cidade[1],";"," "))     vcp     /*Cidade*/
        comasp(replace(clien.bairro[1],";"," "))     vcp     /*Bairro*/
        comasp(replace(clien.endereco[1],";"," "))   vcp     /*Logradouro*/
        comasp(string(clien.numero[1]))     vcp     /*Número do logradouro*/
        comasp(replace(clien.compl[1],";"," "))      vcp     /*Complemento do número do logradouro*/
        comasp(string(clien.cep[1]))        vcp     /* Código postal do logradouro*/
        comasp(string(clien.tippes,"F/J")) vcp     /* Pessoa Física ou Jurídica (F/J)*/
        comasp(string(clien.sexo,"M/F"))   vcp     /*  Gênero (M/F) */
/*ok*/  comasp(replace(cestcivil,";"," "))           vcp     /*  Estado civil*/
        comasp(string(clien.dtnasc,"99/99/9999"))        vcp     /*  Data de nascimento*/
        comasp(replace(clien.clinom,";"," "))        vcp     /*   Nome completo*/
        comasp(string(clien.dtcad,"99/99/9999"))         vcp     /* Data de criação na origem*/
        comasp(replace(clien.ciccgc,";"," "))        vcp     /*Número do documento (Cpf/Cnpj)*/
        comasp(if clien.tippes then "CPF" else "CNPJ") vcp     /*   Tipo de documento (CPF / CI / Passaporte)*/
        
        comasp(replace(clien.proprof[1],";"," "))   vcp     /*   profissao*/
        comasp(trim(string(clien.prorenda[1],"->>>>>>>>>>9.99")))   vcp     /*renda*/
        comasp(replace(clien.ciins,";"," "))         vcp     /*rg_ie*/
        
/*ok*/  comasp(string(vspc_lebes,"SIM/NAO"))         vcp     /*spc_lebes*/
        
        comasp(replace(substr(clien.conjuge,1,50),";"," "))  vcp     /* conjuge_nome*/
        comasp(replace(substr(clien.conjuge,51,20),";"," ")) vcp     /* conjuge_cpf*/
        comasp(string(clien.nascon,"99/99/9999"))        vcp     /* conjuge_dt_nasc*/
        comasp(replace(clien.pai,";"," "))           vcp     /* nom_pai*/
        comasp(replace(clien.mae,";"," "))           vcp     /* nom_mae*/

/*ok*/  comasp(trim(string(vSaldoLimite,"->>>>>>>>>>9.99")))                vcp
/*ok*/  comasp(trim(string(vvlrlimite,"->>>>>>>>>>9.99")))                  vcp
/*ok*/  comasp(trim(string(vComprometido,"->>>>>>>>>>9.99")))               vcp
        
/*ok*/  comasp((if vdata_ultima_compra = ? then "" else string(vdata_ultima_compra,"99/99/9999"))) vcp
/*ok*/  comasp(trim(string(vvlr_contratos,"->>>>>>>>>>9.99")))                  vcp
/*ok*/  comasp(string(vqtd_pagas))                      vcp
/*ok*/  comasp(string(vqtd_abertas))                    vcp
/*ok*/  comasp(string(vqtd_atraso_ate_15_dias))         vcp
/*ok*/  comasp(string(vqtd_atraso_de_16_a_45_dias))     vcp
/*ok*/  comasp(string(vqtd_atraso_acima_de_45))         vcp
/*ok*/  comasp(string(vReparcelamento,"SIM/NAO"))             vcp
/*ok*/  comasp(string(vqtd_dias_Atraso_Atual))               vcp
/*ok*/  comasp((if vdata_ult_pgto = ? then "" else string(vdata_ult_pgto,"99/99/9999")))              vcp
/*ok*/  comasp((if vdata_prox_vcto_aberto = ? then "" else string(vdata_prox_vcto_aberto,"99/99/9999")))      vcp
/*ok*/  comasp(string(vSituacao_contrato,"ABERTO/FECHADO"))   vcp
/*ok*/  comasp(string(vCliente_Feirao_ativo,"SIM/NAO"))       vcp
/*ok*/  comasp(string(voptinEmail,"SIM/NAO"))       vcp
/*02.07.19*/  comasp(string(clien.etbcad,"999"))       vcp 
/*ok*/  comasp((if vdata_ultima_novacao = ? then "" else string(vdata_ultima_novacao,"99/99/9999"))) vcp
        comasp(vrfv) vcp /* helio 26032024 - RFV */
        comasp(vclassificacao) vcp /* helio 26032024 - RFV */
        skip.

        
end.
output close.

/* PRODUTOS */

hide message no-pause.
message today string(time,"HH:MM:SS") "Exportando" varq[4].

/*03.07.19 retirar as ASPAS dos produtos*/

output to value(vdir + vtmp[4]).
    put unformatted 
        "PRODUCT_ID"   vcp /* ID do produto*/
        "PRODUCT_NAME"  vcp /*    Nome do produto*/
        "CATEGORY"      vcp /*    Classe*/
        "SUBCATEGORY"   vcp /* Subclasse */
        "BRAND"         vcp /*   Marca do produto*/
        "LINE"          vcp /*    Departamento*/
        "PrecoVenda"    vcp /*  PrecoVenda*/
        "Setor"         vcp /*   Setor*/
        "StatusPE"      vcp /*    StatusPE*/
        "DataCadastro"  vcp /*    DataCadastro*/
        "DataAlteracao" vcp /*   DataAlteracao*/
        "Grupo"         vcp /*   Grupo*/
        skip.

for each tt-pro.
 
    find produ where produ.procod = tt-pro.procod no-lock no-error.
    if not avail produ then next.
     
    find subclasse   where subclasse.clacod = produ.clacod no-lock no-error. 
    if avail subclasse
    then do:
        find classe      where classe.clacod    = subclasse.clasup no-lock no-error. 
        if avail classe
        then do:
            find grupo       where grupo.clacod     = classe.clacod no-lock no-error. 
            if avail grupo
            then do:
                find setor       where setor.clacod     = grupo.clasup no-lock no-error. 
                if avail setor
                then do:
                    find depto       where depto.clacod     = setor.clasup no-lock no-error.
                end.    
            end.    
        end.            
    end.
    find fabri       where fabri.fabcod = produ.fabcod no-lock no-error.
    find first estoq where estoq.procod = produ.procod no-lock no-error.
    
    if produ.proipival = 1 
    then vmini_pedido = yes. 
    else vmini_pedido = no.
                                                    
    put unformatted 
        string(produ.procod)        vcp /* SKU do produto*/
        replace(produ.pronom,";"," ")        vcp /*    Nome do produto*/ /* 02.07.19 retirado aspas */
        if avail classe then replace(classe.clanom,";"," ") else ""      vcp /*    Classe*/
        if avail subclasse then replace(subclasse.clanom,";"," ") else ""   vcp /* Subclasse */
        if avail fabri then replace(fabri.fabfant,";"," ") else ""      vcp /*   Marca do produto*/
        if avail depto then replace(depto.clanom,";"," ")  else ""      vcp /*    Departamento*/
        trim(string(if avail estoq then estoq.estvenda else 0,"->>>>>>>>>>9.99"))  vcp /*  PrecoVenda*/
        if avail setor then replace(setor.clanom,";"," ")  else ""      vcp /*   Setor*/
        string(vmini_pedido,"SIM/NAO")      vcp /*    StatusPE*/
        string(produ.prodtcad,"99/99/9999")        vcp /*    DataCadastro*/
        string(produ.datexp,"99/99/9999")        vcp /*   DataAlteracao*/
        replace(if avail grupo then grupo.clanom else "",";"," ")        vcp /*   Grupo*/
        skip.
        
        
end.
output close.

/* VENDEDORES */

hide message no-pause.
message today string(time,"HH:MM:SS") "Exportando" varq[5].

output to value(vdir + vtmp[5]).
    put unformatted 
        comasp("SELLER_ID") vcp /*   ID do vendedor*/
        comasp("STORE")     vcp /*   Nome da loja*/
        comasp("NAME")      vcp /*    Nome do vendedor*/
        skip.

for each tt-vend.
 
    find first func  where 
                    func.etbcod = tt-vend.etbcod and  
                    func.funcod = tt-vend.vencod 
               no-lock no-error.
    
    put unformatted 
        comasp(string(tt-vend.vencod))  vcp /*   ID do vendedor*/
        comasp(string(tt-vend.etbcod))  vcp /*   Nome da loja*/
        comasp(if avail func then replace(func.funnom,";"," ") else "" )   vcp /*    Nome do vendedor*/
        skip.
        
        
end.
output close.

/* ESTABS */

hide message no-pause.
message today string(time,"HH:MM:SS") "Exportando" varq[6].
output to value(vdir + vtmp[6]).
    put unformatted 
        comasp("STORE_ID")  vcp /*    ID da loja    */
        comasp("NAME")      vcp /*    Nome da loja    */
        comasp("CITY")      vcp /*    Cidade da loja  */
        comasp("STATE")     vcp /*   Estado da loja   */
        comasp("COUNTRY")   vcp /* País da loja       */
        comasp("PHONE")     vcp
        comasp("ADDRESS")   vcp
        skip.

for each estab no-lock.
 
    put unformatted 
        comasp(string(estab.etbcod)) vcp /*    ID da loja    */
        comasp(replace(estab.etbnom,";"," ")) vcp /*    Nome da loja    */
        comasp(replace(estab.munic,";"," "))  vcp /*    Cidade da loja  */
        comasp(replace(estab.ufecod,";"," ")) vcp /*   Estado da loja   */
        comasp("BRA")        vcp /* País da loja       */
        comasp(replace(estab.etbserie,";"," ")) vcp
        comasp(replace(estab.endereco,";"," ")) vcp /*02.07.19 acrescentado ; */
        skip.
        
        
end.
output close.

/* TROCA NOME PARA OFICIAL */

run marcarfv. /* helio 26032024 - RFV */

hide message no-pause.
message today string(time,"HH:MM:SS") "Fechando arquivos".

vhora = "_" + string(vdate,"99999999") + "_" + replace(string(vtime,"HH:MM:SS"),":","").
do vloop = 1 to 6:
    vcoma = "mv " + vdir + vtmp[vloop] + " " + vdir + varq[vloop] + vhora + ".csv".
    unix silent value(vcoma).
end.

hide message no-pause.
message today string(time,"HH:MM:SS") "Marcando Fim".

if not vhml
then do:
    for each contexttrg where contexttrg.movtdc = 5 and contexttrg.dtenvio = ? exclusive.
        contexttrg.dtenvio = today.
        contexttrg.hrenvio = time.
    end.

    do on error undo  transaction:
    
        find first tab_ini where tab_ini.parametro = par-parametro
            exclusive-lock no-error.
        if avail tab_ini
        then do:
            
            tab_ini.valor = string(vdtfim,"99/99/9999").

        end.

    end.
end.
    
hide message no-pause.
message today string(time,"HH:MM:SS") "FIM".    


/* helio 26032024 - campo RFV */
procedure marcarfv.
    for each clirfv where clirfv.datexp = ? no-lock.
        run marcandorfv.
    end.
end procedure.

procedure marcandorfv.
    do on error undo.
        find current clirfv exclusive no-wait no-error.
        if avail clirfv
        then do:
            clirfv.datexp = datetime(today,mtime).
        end.            
    end.
end procedure.
/* helio 26032024 - campo RFV */

