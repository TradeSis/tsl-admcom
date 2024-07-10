/*  cyber/pagamentos.p                                                 */


def var vtipo as char.
vtipo = "PAGTO".
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
 


def var vsequencia                  as int.
def var vqtd_registros              as int.
def var vchave_contrato             as char.
def var vtitdtpag                   as char.
def var vtitvlpag                   as dec.
def var vcod_transacao as char.

{cyb/sequencias.i vtipo vsequencia}

{cyb/arquivo.i ""pagamentos""}

output to value(varq).
/* HEADER */
put unformatted
    "H"               format "x"          /* TIPO              0001 - 0001 */ 
    "2"               format "x"          /* PRODUTO           0002 - 0031 */
    "CYBER"           format "x(8)"       /* EMPRESA           0032 - 0039 */ 
    "PGTO"            format "x(30)"      /* ARQUIVO           0040 - 0069 */
    vdata_geracao     format "xxxxxxxx"   /* DATA DE GERACAO   0070 - 0077 */ 
    vsequencia        format "9999999999" /* SEQUENCIA ARQUIVO 0078 - 0087 */
    fill(" ",18  )    format "x(46)"    /* FILLER            0088 - 3208 */
    skip.
vqtd_registros = vqtd_registros + 1.


for each t_contrato where t_contrato.tipo = vtipo.

    find cyber_controle of t_contrato no-lock.
    find contrato of cyber_controle no-lock no-error.
 
    vtitdtpag = formatadata(cyber_controle.ultdtpag).
    vtitvlpag = cyber_controle.ultvlrpag.
 /**
    run cyber/chave_contrato.p (input  recid(cyber_contrato),
                                output vchave_contrato).
    
    **/
    
vchave_contrato = string(cyber_controle.loja ,"999") +
                  string(cyber_controle.contnum,"99999999999"). 
                            
     
    def var vestava as char format "x(30)".
    def var vficou  as char format "x(30)".
    def var vpagamentos as char format "x(30)".
    def var vtitpar as int.
    def var vloop as int.

    vestava = cyber_controle.cybparpg.
    vficou  = cyber_controle.parpg.

    if length(vestava) < length(vficou) and
       vestava <> "" 
    then vpagamentos = replace(vficou,vestava,"").
    else vpagamentos = vficou.
    do vloop = 1 to     num-entries(vpagamentos).
        vtitpar = int(entry(vloop,vpagamentos)).
        if vtitpar = ? or vtitpar = 0 then next. 
        find first titulo where 
            titulo.empcod = 19 and 
            titulo.titnat = no and 
            titulo.modcod = contrato.modcod and 
            titulo.etbcod = contrato.etbcod and 
            titulo.clifor = cyber_controle.cliente and 
            titulo.titnum = string(cyber_controle.contnum) and
            titulo.titpar = vtitpar
            no-lock no-error.
        if avail titulo
        then do:
            vtitdtpag = formatadata(titulo.titdtpag).
            vtitvlpag = titulo.titvlpag.

        end.      
            
           
        vcod_transacao = string(vtitpar,"999999").
        put unformatted
            "500"  /* tipo registro */           format "x(3)"    /* Obrigatorio */
            "2"    /* grupo */                   format "x(1)"    /* Obrigatorio */
            vchave_contrato                      format "x(25)"   /* obrigatorio */
    
            vtitdtpag                            format "x(8)"    /* obrigatorio */
            vtitdtpag                            format "x(8)"    /* obrigatorio */
            vtitvlpag  * 100              format "999999999999999"
            vtitvlpag  * 100              format "999999999999999"
            ""                                   format "x(15)"
            vcod_transacao                       format "x(6)"
        
            ""                                   format "x(8)"
            skip.        
        vqtd_registros = vqtd_registros + 1.
    end.
end.

/* TRAILER */
vqtd_registros = vqtd_registros + 1.
put unformatted
    "T"               format "x"          /* TIPO              0001 - 0001 */ 
    vdata_geracao     format "xxxxxxxx"   /* DATA DE GERACAO   0002 - 0009 */ 
    vqtd_registros    format "9999999999" /* QUANTIDADE DE REGISTROS ARQUIVO
                                                               0010 - 0019 */
    vsequencia        format "9999999999" /* SEQUENCIA ARQUIVO 0020 - 0029 */
    fill(" ",75)    format "x(75)"    /* FILLER            0030 - 3208 */
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

