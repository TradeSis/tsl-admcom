/*REGRA Produtos - Últimos 500 cadastrados em Móveis (31) e Moda (41)*/
/*REGRA Fornecedores - TODOS!*/
/*REGRA Clientes - Exportar TODOS do tipo 3 (funcionários*/

def var vqtdsel as int init 500.


def var vconta as int.
def var vsel as int. 
def var vhora   as char.
def var vloop   as int.
def var vcoma   as char.
def var vcp     as char init ";".
def var vdir    as char init "/admcom/tmp/SAPpoc/".

def var cestcivil as char.
def var vtmp    as char extent 3 init
    ["tmp1","tmp2","tmp3"].
def var varq    as char extent 3 init
    ["produtos_lebes","fornecedores_lebes","clientes_lebes"].

def var vtime   as int.
def var vdate   as date.

vdate = today.
vtime = time.

def var vmini_pedido as log.


def buffer depto    for clase.  /*DEPARTAMENTO  */
def buffer setor    for clase.  /*    SETOR  */
def buffer grupo    for clase.  /*        GRUPO  */
def buffer classe   for clase.  /*            CLASSE  */
def buffer subclasse for clase. /*                SUB-CLASSE */


def temp-table tt-pro no-undo
    field procod            like produ.procod
    field codean            like produ.proindice
    field tempogarantia     as int format "99"
    field aliquotaicms      as dec format "999.99"
    field classiffiscal     as int format "99999999"
    index clitrans is unique primary
                procod asc.

def temp-table tt-cli no-undo
    field clicod            like clien.clicod
    index clitrans is unique primary
                clicod asc.


/* PRODUTOS */
hide message no-pause.
message "Selecionando" varq[1].

run seleciona-produto.
vconta = 0.
for each tt-pro.
    vconta = vconta + 1.
end.
 
hide message no-pause.
message "Exportando" vdir varq[1] vconta.

output to value(vdir + vtmp[1]).

    put unformatted      
        "CODIGO LEBES"              vcp
        "DATA CADASTRO"             vcp
        "DESCRICAO LONGA"           vcp
        "DESC ABREVIADA"            vcp
        "DEPARTAMENTO"              vcp
        "COD FABRICANTE"            vcp
        "DESC FABRICANTE"           vcp
        "CODIGO BARRAS"             vcp
        "TEMPO GARANTIA (meses)"    vcp
        "UNIDADE VENDA"             vcp
        "VOLUME"                    vcp
        "ALTURA EMBALAGEM"          vcp
        "LARGURA EMBALAGEM"         vcp
        "COMPRIMENTO EMBALAGEM"     vcp
        "PESO EMBALAGEM"            vcp
        "ALTURA PRODUTO"            vcp
        "LARGURA PRODUTO"           vcp
        "COMPRIMENTO PRODUTO"       vcp
        "PESO PRODUTO"              vcp
        "PESO TOTAL"                vcp
        "PESO TARA"                 vcp
        "PESO LIQUIDO"              vcp
        "ALIQUOTA ICMS"             vcp
        "CLASSIFICACAO FISCAL"      vcp
        skip.


    for each tt-pro.
 
        find produ where produ.procod = tt-pro.procod no-lock. 
        find subclasse   where subclasse.clacod = produ.clacod no-lock no-error. 
        find classe      where classe.clacod    = subclasse.clasup no-lock no-error. 
        find grupo       where grupo.clacod     = classe.clacod no-lock no-error. 
        find setor       where setor.clacod     = grupo.clasup no-lock no-error. 
        find depto       where depto.clacod     = setor.clasup no-lock no-error.

        find fabri       where fabri.fabcod = produ.fabcod no-lock no-error.
        find first estoq where estoq.procod = produ.procod no-lock no-error.
    
        if produ.proipival = 1 
        then vmini_pedido = yes. 
        else vmini_pedido = no.
                                                    
        put unformatted      
            produ.procod                vcp /* "CODIGO LEBES" */
            produ.prodtcad  format "99/99/9999"            vcp /* "DATA CADASTRO" */
            produ.pronom                vcp /* "DESCRICAO LONGA" */
            produ.pronom                vcp /* "DESC ABREVIADA"*/
            if avail depto then depto.clanom  else ""      vcp /* "DEPARTAMENTO"  */
            produ.fabcod                vcp /* "COD FABRICANTE"  */
            if avail fabri then fabri.fabfant else ""      vcp /* "DESC FABRICANTE" */
            tt-pro.codean               vcp /* "CODIGO BARRAS" */
            tt-pro.tempogarantia  format "999"      vcp /* "TEMPO GARANTIA (meses)" */
            "UN"                        vcp /* "UNIDADE VENDA" */
            ""                          vcp /* "VOLUME" */
            ""                          vcp /* "ALTURA EMBALAGEM" */
            ""                          vcp /* "LARGURA EMBALAGEM" */
            ""                          vcp /* "COMPRIMENTO EMBALAGEM" */
            ""                          vcp /* "PESO EMBALAGEM" */
            ""                          vcp /* "ALTURA PRODUTO" */
            ""                          vcp /* "LARGURA PRODUTO" */
            ""                          vcp /* "COMPRIMENTO PRODUTO" */
            ""                          vcp /* "PESO PRODUTO" */
            ""                          vcp /* "PESO TOTAL" */
            ""                          vcp /* "PESO TARA" */
            ""                          vcp /* "PESO LIQUIDO" */
            tt-pro.aliquotaicms format "999.99"        vcp /* "ALIQUOTA ICMS" */
            tt-pro.classiffiscal format "99999999"       vcp /* "CLASSIFICACAO FISCAL" */
            skip.
        
    end.
    
output close.


/* FORNECEDORES */
/* REGRA - Fornecedores - TODOS! */


hide message no-pause.
message "Exportando" vdir varq[2].

output to value(vdir + vtmp[2]).

    put unformatted      
        "CNPJ"              vcp
        "IE"                vcp
        "RAZAO SOCIAL"      vcp
        "NOME FANTASIA"     vcp
        "ENDEREÇO"          vcp
        "NUMERO"            vcp
        "BAIRRO"            vcp
        "CEP"               vcp
        "CIDADE"            vcp
        "ESTADO"            vcp
        "PAIS"              vcp
        "TELEFONE"          vcp
        "EMAIL"             vcp
        skip.   

    for each fabri no-lock. 
        find first forne where forne.forcod = fabri.fabcod no-lock no-error.
        if not avail forne then next.
        

        put unformatted
        forne.forcgc    FORMAT "99999999999999" vcp /* "CNPJ" */
        trim(forne.forinest)                          vcp /* "IE" */
        trim(forne.fornom)                            vcp /* "RAZAO SOCIAL" */
        trim(forne.forfant)                           vcp /* "NOME FANTASIA" */
        trim(forne.forrua)                            vcp /* "ENDEREÇO" */
        forne.fornum                            vcp /* "NUMERO" */
        trim(forne.forbairro)                         vcp /* "BAIRRO" */
        forne.forcep                            vcp /* "CEP" */
        trim(forne.formunic)                          vcp /* "CIDADE" */
        forne.ufecod                            vcp /* "ESTADO" */
        forne.forpais                           vcp /* "PAIS" */
        trim(forne.forfone)                           vcp /* "TELEFONE" */
        trim(forne.email)                             vcp /* "EMAIL" */
        skip.   
        
    end.
    
output close.


/* CLIENTES */

hide message no-pause.
message "Selecionando" varq[3].

run seleciona-clientes.
vconta = 0.
for each tt-cli.
    vconta = vconta + 1.
end.
    
hide message no-pause.
message "Exportando" vdir varq[3]  vconta.

output to value(vdir + vtmp[3]).
    
    put unformatted
        "CPF" vcp
        "RG"  vcp
        "NOME" vcp
        "SEXO" vcp
        "ESTADO CIVIL" vcp
        "DATA NASCIMENTO" vcp
        "NOME MAE" vcp
        "ENDEREÇO" vcp
        "NUMERO" vcp
        "BAIRRO"  vcp
        "CEP" vcp
        "CIDADE" vcp
        "ESTADO" vcp
        "TELEFONE RESIDENCIAL" vcp
        "CELULAR" vcp
        "E-MAIL"  vcp
        "EMPRESA"  vcp     
        "DATA ADMISSAO" vcp
        "RENDA"    vcp
        skip.

for each tt-cli.
 
    find clien where clien.clicod = tt-cli.clicod no-lock.
    find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
    
    cestcivil = if clien.estciv = 1 then "Solteiro" else
                if clien.estciv = 2 then "Casado"   else
                if clien.estciv = 3 then "Viuvo"    else
                if clien.estciv = 4 then "Desquitado" else
                if clien.estciv = 5 then "Divorciado" else
                if clien.estciv = 6 then "Falecido" else "". 

    put unformatted
        neuclien.cpfcnpj            vcp /* "CPF" */
        clien.ciins                 vcp /* "RG"  */
        clien.clinom                vcp /* "NOME" */
        string(clien.sexo,"M/F")    vcp /* "SEXO" */
        cestcivil                   vcp /* "ESTADO CIVIL" */
        clien.dtnasc   format "99/99/9999"             vcp /* "DATA NASCIMENTO" */
        trim(clien.mae)                   vcp /* "NOME MAE" */
        clien.endereco[1]           vcp /* "ENDEREÇO" */
        clien.numero[1]             vcp /* "NUMERO" */
        clien.bairro[1]             vcp /* "BAIRRO"  */
        clien.cep[1]                vcp /* "CEP" */
        clien.cidade[1]             vcp /* "CIDADE" */
        clien.ufecod[1]             vcp /* "ESTADO" */
        clien.fone                  vcp /* "TELEFONE RESIDENCIAL" */
        clien.fax                   vcp /* "CELULAR" */
        clien.zona                  vcp /* "E-MAIL"  */
        trim(clien.proemp[1])             vcp /* "EMPRESA"  */     
        clien.prodta[1]  format "99/99/9999"           vcp /* "DATA ADMISSAO" */
        clien.prorenda[1] format ">>>>>>>>>9.99"          vcp /* "RENDA"    */
        skip.


        
end.
output close.





/* TROCA NOME PARA OFICIAL */

hide message no-pause.
message "Fechando arquivos".

/*vhora = "_" + string(vdate,"99999999") + "_" + replace(string(vtime,"HH:MM:SS"),":","").*/

vhora = "_" + string(vdate,"99999999").

do vloop = 1 to 3:
    if search(vdir + vtmp[vloop]) <> ?
    then do:
        vcoma = "mv " + vdir + vtmp[vloop] + " " + vdir + varq[vloop] + vhora + ".csv".
        unix silent value(vcoma).
        vcoma = "chmod -f 777 " + vdir + varq[vloop] + vhora + ".csv".
        unix silent value(vcoma).
        
    end.    
end.

hide message no-pause.
message "Exportados em " vdir vhora.




procedure seleciona-produto.

    /*REGRA Produtos - Últimos 500 cadastrados em Móveis (31) e Moda (41)*/

    /* Nao tem INDICE por prodtcad, entao vou ler POR DATEXP, 
       e ordernar por PRODTCAD */
    vsel = 0.
    for each produ use-index idatexp no-lock
        break by produ.prodtcad desc.
        
        if produ.catcod = 31 or
           produ.catcod = 41
        then.
        else next.

        create tt-pro.
        tt-pro.procod = produ.procod.
        tt-pro.codean = if produ.proindice <> ?
                        then if trim(produ.proindice) = "SEM GTIN"
                             then ""
                             else produ.proindice
                        else "".
        tt-pro.classiffiscal = produ.codfis.
        tt-pro.aliquotaicms = produ.proipiper.
        tt-pro.tempogarantia = 0.
        find first produaux where produaux.procod     = produ.procod
                              and produaux.nome_campo = "TempoGar"
                    NO-LOCK no-error.
        if avail produaux 
        then tt-pro.tempogarantia = int(produaux.valor_campo).

        vsel = vsel + 1.
        
        if vsel >= vqtdsel
        then leave.
        

    end.

end procedure.


procedure seleciona-clientes.
/*REGRA Clientes - Exportar TODOS do tipo 3 (funcionários*/

    for each clien where clien.tipocod = 3
        no-lock.

        find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
        if not avail neuclien
        then next.

        create tt-cli.
        tt-cli.clicod = clien.clicod.
        
        
    end.

end procedure.

