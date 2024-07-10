/*  cyber/parcela.p                                                          */

def var vtipo as char.
vtipo = "PARCE".
def var varquivo as char.

{cyb/cybcab.i}

def shared var v-today as date.
def shared var v-time as int.


def  shared temp-table c_contrato no-undo
    field contnum like cyber_controle.contnum
    index c is unique primary contnum asc.
def  shared temp-table t_contrato no-undo
    field contnum like cyber_controle.contnum
    field tipo as char
    index c is unique primary contnum asc tipo asc
    index t tipo asc.
def  shared temp-table t_interface no-undo
    field tipo as char
    field qtd  as int
    index t is unique primary tipo asc.
 



def var vsequencia      as int.
def var vqtd_registros  as int.
def var vchave_contrato as char.
def var vstatus         as char.

{cyb/sequencias.i vtipo vsequencia}

{cyb/arquivo.i ""parcelas""}

output to value(varq).

/* HEADER */
put unformatted
    "H"               format "x"          /* TIPO              0001 - 0001 */ 
    "2"               format "x"          /* PRODUTO           0002 - 0031 */
    "CYBER"           format "x(8)"       /* EMPRESA           0032 - 0039 */ 
    "PARCELAS"        format "x(30)"      /* ARQUIVO           0040 - 0069 */
    vdata_geracao     format "xxxxxxxx"   /* DATA DE GERACAO   0070 - 0077 */ 
    vsequencia        format "9999999999" /* SEQUENCIA ARQUIVO 0078 - 0087 */
    fill(" ",102)     format "x(159)"     /* FILLER            0088 - 3208 */
    skip.
vqtd_registros = vqtd_registros + 1.

def var vclicod as int.

for each t_contrato where t_contrato.tipo = vtipo.

    find cyber_controle of t_contrato no-lock.
    
    find contrato of cyber_controle no-lock no-error.

    find cyber_contrato where cyber_contrato.contnum = cyber_controle.contnum
        no-lock no-error.
    vclicod = if avail cyber_contrato
              then cyber_contrato.clicod
              else cyber_controle.cliente.  
    def var vmodcod as char.
    vmodcod = if avail contrato
    then if contrato.modcod <> ""
         then contrato.modcod
         else "CRE"
    else "CRE".
  
     for each titulo where 
        titulo.empcod = 19 and 
        titulo.titnat = no and 
        titulo.modcod = vmodcod and
        titulo.etbcod = cyber_controle.loja and 
        titulo.clifor = vclicod and 
        titulo.titnum = string(cyber_controle.contnum) 
        no-lock
            by titulo.titpar.
     
            if titulo.clifor <= 1 or
               titulo.clifor = ? or
               titulo.titpar = 0 or
               titulo.titnum = "" or
               titulo.titvlcob <= 0.01 /*** 02.08.16 ***/
            then next.
        
        if titulo.titdtven >= today
        then next.

/**
for each LotCreTit of lotcre no-lock.
**/

    vchave_contrato             = "".   

    /**
    find FIRST titulo where 
                titulo.empcod = 19
            and titulo.titnat = no
            and titulo.modcod = lotCreTit.modcod
            and titulo.etbcod = LotCreTit.etbcod
            and titulo.clifor = LotCreTit.clfcod
            and titulo.titnum = LotCreTit.titnum
            and titulo.titpar = LotCreTit.titpar
            and titulo.titvlcob > 0.01 /*** 02.08.16 ***/
            no-lock no-error.
    if not avail titulo
    then next.
    **/
    
/**    find cyber_contrato where cyber_contrato.contnum = int(LotCreTit.titnum)
                        no-lock.
    **/
    
    find clien where clien.clicod = vclicod no-lock no-error.
    if not avail clien then next.

/**
run cyber/chave_contrato.p (input  recid(cyber_contrato),
                            output vchave_contrato).
**/

vchave_contrato = string(cyber_controle.loja ,"999") +
                  string(cyber_controle.contnum,"99999999999"). 
                            
    
    run juro_titulo.p (0, input titulo.titdtven, titulo.titvlcob,
                       output par-juros).
    if titulo.titdtpag <> ?
    then vstatus = "PAG". /* Pago */
    else if titulo.titdtven >= today
    then vstatus = "LIB". /* A vencer */
    else vstatus = "ATR". /* Em atraso */
    
    put unformatted
        ""     /* tipo registro */       format "x(3)"    /* 1 Obrigatorio */
        "2"    /* grupo */               format "x(1)"    /* 4 Obrigatorio */
        vchave_contrato                  format "x(25)"   /* 5 obrigatorio */
        clien.ciccgc    /* cpf/cnpj */   format "x(25)"   /* 30 Obrigatorio */
        titulo.titpar                 format "999"     /* 55 */
        titulo.titvlcob * 100            format "999999999999999" /* 58 */
        vstatus                          format "x(20)"   /* 73 */
        formatadata(titulo.titdtven)     format "xxxxxxxx" /* 93 */
        formatadata(titulo.titdtpag)     format "xxxxxxxx" /* 101 */
        formatadata(titulo.titdtemi)     format "xxxxxxxx" /* 109 */
        titulo.etbcod                 format "9999"     /* 117 */
        formatadata(today)               format "xxxxxxxx" /* 121 */
        titulo.titvlpag * 100            format "999999999999999" /* 129 */
        par-juros * 100                  format "999999999999999" /* 144 */
        0                                format "999999999999999" /* 159 */
        if titulo.etbcobra <> ?
        then titulo.etbcobra else 0      format "9999"  /* 174 */
        titulo.modcod                 format "x(40)" /* 178 */
        skip.
    vqtd_registros = vqtd_registros + 1.
end.

end.

/* TRAILER */
vqtd_registros = vqtd_registros + 1.
put unformatted
    "T"              format "x"          /* TIPO              0001 - 0001 */ 
    vdata_geracao    format "99999999"   /* DATA DE GERACAO   0002 - 0009 */ 
    vqtd_registros   format "9999999999" /* QUANTIDADE DE REGISTROS ARQUIVO
                                                              0010 - 0019 */
    vsequencia       format "9999999999" /* SEQUENCIA ARQUIVO 0020 - 0029 */
    fill(" ",159)    format "x(159)"     /* FILLER            0030 - 3208 */
    skip.

output close.
{cyb/arquivozip.i}


/**
do on error undo.
    find current lotcretp exclusive.
    lotcretp.ultimo = lotcretp.ultimo + 1.
    
    find lotcre where recid(lotcre) = par-reclotcre exclusive.
    assign
        lotcre.ltdtenvio = vtoday
        lotcre.lthrenvio = vtime
        lotcre.arqenvio  = varq.
end.
find lotcre where recid(lotcre) = par-reclotcre no-lock.
**/

