/* Helio 12082024 - novo exportador direto para oto */
def var vnome as char.
def var vsobrenome as char.
def var vcatcod as int.
def var vnroparc as int.
def var vbairro as char.
def var vzip as char.
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
    ["lebes_orders","lebes_order_items","lebes_customers","lebes_products","lebes_sellers","lebes_stores"].

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

def var vcp as char init "|".
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
"CUSTOMER_ID" vcp
"ORDER_DATE" vcp
"ORDER_DATE_TS" vcp
"ORDER_ID" vcp
"ORDER_STORE" vcp
"ORDER_STORE_TYPE" vcp
"ORDER_DELIVERY_TYPE" vcp
"ORDER_STATUS" vcp
"ORDER_PAYMENT_METHOD" vcp
"ORDER_PAYMENT_TYPE" vcp
"ORDER_INSTALLMENTS" vcp
"ORDER_CANCELED" vcp
"ORDER_TOTAL" vcp
"CUSTOM_FIELD_01" vcp
"CUSTOM_FIELD_02" vcp
"CUSTOM_FIELD_03" vcp
"CUSTOM_FIELD_04" vcp
"CUSTOM_FIELD_05" vcp
"CUSTOM_FIELD_06" vcp
"CUSTOM_FIELD_07" vcp
"CUSTOM_FIELD_08" vcp
"CUSTOM_FIELD_09" vcp
"CUSTOM_FIELD_10" vcp

       skip.

put stream ite unformatted  
"ORDER_ITEM_ID" vcp
"ORDER_ITEM_STORE" vcp
"ORDER_ITEM_DATE" vcp
"ORDER_ITEM_SEQ" vcp
"ORDER_ITEM_SKU" vcp
"ORDER_ITEM_SELLER_ID" vcp
"ORDER_ITEM_QUANTITY" vcp
"ORDER_ITEM_LIST_PRICE" vcp
"ORDER_ITEM_PRICE" vcp

        
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
        vnroparc = if avail finan then finan.finnpc else 0.    
        vcatcod = 0.
        for each movim where 
                movim.etbcod = plani.etbcod and
                movim.placod = plani.placod
                no-lock.
            find produ      where produ.procod = movim.procod no-lock no-error.
            if not avail produ then next.
            if produ.catcod = 31 or produ.catcod = 41
            then do:
                vcatcod = produ.catcod.
                leave.
            end.
        end.        
        put stream ven unformatted 
            comasp(string(clien.clicod))    vcp
            comasp(string(plani.pladat,"99/99/9999"))    vcp
            "NULL" vcp
            comasp(string(plani.placod))    vcp
            comasp(string(plani.etbcod))    vcp 
            comasp(estab.tipoLoja)  vcp
            "NULL" vcp
            comasp("FECHADO")       vcp
            comasp(string(vcod_plano) +  " - " + vdesc_plano) vcp
            comasp(string(plani.crecod))    vcp
            string(vnroparc)  vcp
            "0" vcp
            comasp(trim(string(vvalorvenda,"->>>>>>>>>>9.99")))     vcp
            vcatcod vcp            
            "NULL" vcp
            comasp(string(plani.pladat,"99/99/9999"))    vcp
            comasp(replace(clien.zona,";"," "))      vcp            
            comasp(string(plani.numero))    vcp
            comasp(plani.serie) vcp /* #2 */ 
            "NULL" vcp
            "NULL" vcp
            "NULL" vcp
            "NULL" vcp
            
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
                comasp(string(movim.movseq))           vcp     /*Sequencial do item do pedido*/
                comasp(string(movim.procod))           vcp     /*ID do produto*/
                comasp(string(plani.vencod))           vcp     /*Id do vendedor do produto*/
                comasp(trim(string(movim.movqtm,"->>>>>>>>>>9.99")))           vcp     /*Quantidade adquirida*/
                "NULL" vcp
                comasp(trim(string(movim.movpc ,"->>>>>>>>>>9.99")))            vcp     /*Preço unitário*/
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
"CUSTOMER_ID" vcp
"DOCUMENT_NUMBER" vcp
"MKT_CLOUD_ID" vcp
"EMAIL" vcp
"EMAIL_PERMISSION" vcp
"MOBILE_NUMBER" vcp
"MOBILE_PERMISSION" vcp
"WHATSAPP_PERMISSION" vcp
"FIRST_NAME" vcp
"LAST_NAME" vcp
"PREF_STORE" vcp
"PREF_SELLER" vcp
"CREATE_DATE" vcp
"COUNTRY" vcp
"STATE" vcp
"CITY" vcp
"ZIPCODE" vcp
"ADDRESS" vcp
"ADDRESS_N" vcp
"ADDRESS_COMPLEMENT" vcp
"GENDER" vcp
"DATE_BIRTH" vcp
"FIRST_ORDER" vcp
"TYPE_PERSON" vcp
"RFV" vcp
"DATA_SOURCE" vcp
"PHONE_NUMBER" vcp
"CUSTOM_FIELD_01" vcp
"CUSTOM_FIELD_02" vcp
"CUSTOM_FIELD_03" vcp
"CUSTOM_FIELD_04" vcp
"CUSTOM_FIELD_05" vcp
"CUSTOM_FIELD_06" vcp
"CUSTOM_FIELD_07" vcp
"CUSTOM_FIELD_08" vcp
"CUSTOM_FIELD_09" vcp
"CUSTOM_FIELD_10" vcp
"CUSTOM_FIELD_11" vcp
"CUSTOM_FIELD_12" vcp
"CUSTOM_FIELD_13" vcp
"CUSTOM_FIELD_14" vcp
"CUSTOM_FIELD_15" vcp
"CUSTOM_FIELD_16" vcp
"CUSTOM_FIELD_17" vcp
"CUSTOM_FIELD_18" vcp
"CUSTOM_FIELD_19" vcp
"CUSTOM_FIELD_20" vcp
"CUSTOM_FIELD_21" vcp
"CUSTOM_FIELD_22" vcp
"CUSTOM_FIELD_23" vcp
"CUSTOM_FIELD_24" vcp
"CUSTOM_FIELD_25" vcp
"CUSTOM_FIELD_26" vcp
"CUSTOM_FIELD_27" vcp
"CUSTOM_FIELD_28" vcp
"CUSTOM_FIELD_29" vcp
"CUSTOM_FIELD_30" vcp
"CUSTOM_FIELD_31" vcp
"CUSTOM_FIELD_32" vcp
"CUSTOM_FIELD_33" vcp
"CUSTOM_FIELD_34" vcp
"CUSTOM_FIELD_35" vcp
"CUSTOM_FIELD_36" vcp
"CUSTOM_FIELD_37" vcp
"CUSTOM_FIELD_38" vcp
"CUSTOM_FIELD_39" vcp
"CUSTOM_FIELD_40" vcp
"CUSTOM_FIELD_41" vcp
"CUSTOM_FIELD_42" vcp
"CUSTOM_FIELD_43" vcp
"CUSTOM_FIELD_44" vcp
"CUSTOM_FIELD_45" vcp
"CUSTOM_FIELD_46" vcp
"CUSTOM_FIELD_47" vcp
"CUSTOM_FIELD_48" vcp
"CUSTOM_FIELD_49" vcp
"CUSTOM_FIELD_50" vcp
                
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

    
    vnome = entry(1,clien.clinom," ").
    vsobrenome = trim(replace(clien.clinom,vnome,"")) no-error.
    if vsobrenome = ? then vsobrenome = "".
    put unformatted
        comasp(string(tt-cli.clicod))               vcp 
        comasp(replace(clien.ciccgc,";"," "))        vcp     /*Número do documento (Cpf/Cnpj)*/
        "NULL" vcp
        comasp(replace(clien.zona,";"," "))                  vcp
        string(voptinEmail,"1/0")        vcp
        comasp(replace(clien.fax,";"," "))                   vcp
        string(clien.optinSMS,"1/0")   vcp
        string(clien.optinWhatsApp,"1/0")   vcp
        comasp(vnome)   vcp     /*   Nome completo*/
        comasp(vsobrenome)        vcp     /*   Nome completo*/
        comasp(string(clien.etbcad,"999"))       vcp 
        "NULL" vcp             
        comasp(string(clien.dtcad,"99/99/9999"))         vcp     /* Data de criação na origem*/
        comasp("BRA")                       vcp
        comasp(substring(clien.ufecod[1],1,2))     vcp     /*Estado*/
        comasp(replace(clien.cidade[1],";"," "))     vcp     /*Cidade*/
        comasp(string(clien.cep[1]))        vcp     /* Código postal do logradouro*/
        comasp(clien.endereco[1] + "#" + clien.bairro[1])     vcp     /*Bairro*/
        comasp(string(clien.numero[1])) vcp
        comasp(replace(clien.compl[1],";"," "))      vcp     /*Complemento do número do logradouro*/
        comasp(clien.genero)   vcp     
        comasp(string(clien.dtnasc,"99/99/9999"))        vcp     /*  Data de nascimento*/
        "NULL" vcp             
        comasp(if clien.tippes then "F" else "J") vcp     /*   Tipo de documento (CPF / CI / Passaporte)*/
        "NULL" vcp
        "NULL" vcp
        comasp(replace(clien.fone,";"," "))                  vcp
        "NULL" vcp
        comasp(replace(clien.proprof[1],";"," "))   vcp     /*   profissao*/
        comasp(trim(string(clien.prorenda[1],"->>>>>>>>>>9.99")))   vcp     /*renda*/
        comasp(replace(clien.ciins,";"," "))         vcp     /*rg_ie*/
        comasp(string(vspc_lebes,"SIM/NAO"))         vcp     /*spc_lebes*/
"NULL" vcp
"NULL" vcp
"NULL" vcp
        comasp(replace(clien.pai,";"," "))           vcp     /* nom_pai*/
        comasp(replace(clien.mae,";"," "))           vcp     /* nom_mae*/
        comasp(trim(string(vSaldoLimite,"->>>>>>>>>>9.99")))                vcp
        comasp(trim(string(vvlrlimite,"->>>>>>>>>>9.99")))                  vcp
        comasp(trim(string(vComprometido,"->>>>>>>>>>9.99")))               vcp
comasp((if vdata_ultima_compra = ? then "" else string(vdata_ultima_compra,"99/99/9999"))) vcp
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
        "NULL" vcp /* comasp(string(vCliente_Feirao_ativo,"SIM/NAO"))       vcp*/
        comasp(string(tt-cli.clicod))               vcp 
        "NULL" vcp
        "NULL" vcp                
/*ok*/  comasp(replace(cestcivil,";"," "))           vcp     /*  Estado civil*/
        "NULL" vcp        
        comasp(vrfv) vcp /* helio 26032024 - RFV */
        comasp(vclassificacao) vcp /* helio 26032024 - RFV */
        comasp(if clien.tippes then "CPF" else "CNPJ") vcp     /*   Tipo de documento (CPF / CI / Passaporte)*/
                    
        
        
/*      comasp(replace(substr(clien.conjuge,1,50),";"," "))  vcp     /* conjuge_nome*/ 
        comasp(replace(substr(clien.conjuge,51,20),";"," ")) vcp     /* conjuge_cpf*/
        comasp(string(clien.nascon,"99/99/9999"))        vcp     /* conjuge_dt_nasc*/
*/
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        
        skip.

        
end.
output close.

/* PRODUTOS */

hide message no-pause.
message today string(time,"HH:MM:SS") "Exportando" varq[4].

/*03.07.19 retirar as ASPAS dos produtos*/

output to value(vdir + vtmp[4]).
    put unformatted 
"PRODUCT_SKU" vcp
"PRODUCT_ID" vcp
"PRODUCT_NAME" vcp
"PRODUCT_TAG" vcp
"PRODUCT_SIZE" vcp
"PRODUCT_CATEGORY" vcp
"PRODUCT_SUBCATEGORY" vcp
"PRODUCT_GENDER" vcp
"PRODUCT_LINE" vcp
"PRODUCT_COLOR" vcp
"PRODUCT_BRAND" vcp
"PRODUCT_IMAGE" vcp
"PRODUCT_URL"

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
        string(produ.procod)        vcp /* SKU do produto*/
        replace(produ.pronom,";"," ")        vcp /*    Nome do produto*/ /* 02.07.19 retirado aspas */
        "NULL" vcp
        "NULL" vcp    
        if avail classe then replace(classe.clanom,";"," ") else ""      vcp /*    Classe*/
        if avail subclasse then replace(subclasse.clanom,";"," ") else ""   vcp /* Subclasse */
        "NULL" vcp        
        if avail depto then replace(depto.clanom,";"," ")  else ""      vcp /*    Departamento*/
        "NULL" vcp
        if avail fabri then replace(fabri.fabfant,";"," ") else ""      vcp /*   Marca do produto*/
        "NULL" vcp
        "NULL" vcp
        skip.
        
        
end.
output close.

/* VENDEDORES */

hide message no-pause.
message today string(time,"HH:MM:SS") "Exportando" varq[5].

output to value(vdir + vtmp[5]).
    put unformatted 
    "SELLER_ID" vcp
    "SELLER_NAME" vcp
    "SELLER_NAME_OTO" vcp
    "SELLER_STORE" vcp
    "SELLER_DISABLED" vcp
    
        skip.

for each tt-vend.
 
    find first func  where 
                    func.etbcod = tt-vend.etbcod and  
                    func.funcod = tt-vend.vencod 
               no-lock no-error.
    
    put unformatted 
        comasp(string(tt-vend.vencod))  vcp /*   ID do vendedor*/
        comasp(if avail func then replace(func.funnom,";"," ") else "" )   vcp /*    Nome do vendedor*/
        comasp(if avail func then replace(func.funnom,";"," ") else "" )   vcp /*    Nome do vendedor*/
        comasp(string(tt-vend.etbcod))  vcp /*   Nome da loja*/
        "NULL" vcp
        skip.
        
        
end.
output close.

/* ESTABS */

hide message no-pause.
message today string(time,"HH:MM:SS") "Exportando" varq[6].
output to value(vdir + vtmp[6]).
put unformatted
"STORE_ID" vcp
"STORE_NAME" vcp
"STORE_NAME_OTO" vcp
"STORE_TYPE" vcp
"STORE_EMAIL" vcp
"STORE_CLUSTER" vcp
"STORE_COUNTRY" vcp
"STORE_STATE" vcp
"STORE_CITY" vcp
"STORE_NEIGHBORHOOD" vcp
"STORE_STATUS" vcp
"ECOMMERCE_ID" vcp
"CUSTOM_FIELD_01" vcp
"CUSTOM_FIELD_02" vcp
"CUSTOM_FIELD_03" vcp
"CUSTOM_FIELD_04" vcp
"CUSTOM_FIELD_05" vcp
"CUSTOM_FIELD_06" vcp
"CUSTOM_FIELD_07" vcp
"CUSTOM_FIELD_08" vcp
"CUSTOM_FIELD_09" vcp
"CUSTOM_FIELD_10" vcp

        
        skip.

for each estab no-lock.
    release supervisor.
    find filialsup  of estab no-lock no-error.
    if avail filialsup
    then  find supervisor of filialsup no-lock no-error.
                find tabaux where 
                     tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                     tabaux.nome_campo = "BAIRRO" no-error.
                if avail tabaux
                then vbairro = tabaux.valor_campo.
                else vbairro = "".
    
    put unformatted 
        comasp(string(estab.etbcod)) vcp /*    ID da loja    */
        comasp(replace(estab.etbnom,";"," ")) vcp /*    Nome da loja    */
        comasp(replace(estab.etbnom,";"," ")) vcp /*    Nome da loja    */
        if estab.etbcod = 200 then "E" else "L" vcp       
        "NULL" vcp
        "NULL" vcp
        comasp("BRA")        vcp /* País da loja       */
        comasp(replace(estab.ufecod,";"," ")) vcp /*   Estado da loja   */
        comasp(replace(estab.munic,";"," "))  vcp /*    Cidade da loja  */
        comasp(replace(vbairro,";"," "))  vcp /*    Cidade da loja  */
        "NULL" vcp
        "NULL" vcp
        (if avail supervisor then  supervisor.supnom  else "") vcp             
        comasp(replace(estab.etbserie,";"," ")) vcp
        comasp(replace(estab.endereco,";"," ")) vcp /*02.07.19 acrescentado ; */
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        "NULL" vcp
        
        skip.
        
        
end.
output close.

/* TROCA NOME PARA OFICIAL */

run marcarfv. /* helio 26032024 - RFV */

hide message no-pause.
message today string(time,"HH:MM:SS") "Fechando arquivos".

vhora = "_" + 
         string( year(vdate),"9999") +
         string(month(vdate),"99")   +
         string(  day(vdate),"99")
        + "_" + replace(string(vtime,"HH:MM:SS"),":","").
do vloop = 1 to 6:
    vcoma = "mv " + vdir + vtmp[vloop] + " " + vdir + varq[vloop] + vhora + ".csv".
    unix silent value(vcoma).

    unix silent value("chmod 777 " + vdir + varq[vloop] + vhora + ".csv").
    vzip  = "cd " + vdir + " ; zip -q " +  varq[vloop] + vhora + ".zip " +  varq[vloop] + vhora + ".csv" .
    unix silent value(vzip).
    unix silent value("rm -f " + vdir + varq[vloop] + vhora + ".csv").
    unix silent value("chmod 777 " + vdir + varq[vloop] + vhora + ".zip").
        
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

