/*  cyber/pagamentos.p
#1 24.07.19 - tratamento de not avail contrato, envia pelo menos 1 registro
*/

def var vtipo as char.
vtipo = "PAGTO".
def var varquivo as char.

{csl/cybcab.i}

def shared var v-today as date.
def shared var v-time as int.

def shared temp-table t_contrato no-undo
    field contnum like cslog_controle.contnum
    field tipo as char
    index c is unique primary contnum asc tipo asc
    index t tipo asc.

def var vsequencia                  as int.
def var vqtd_registros              as int.
def var vchave_contrato             as char.
def var vtitdtpag                   as char.
def var vtitvlpag                   as dec.
def var vcod_transacao as char.
def var vok as log.

{csl/sequencias.i vtipo vsequencia}
{csl/arquivo.i ""pagamentos""}

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

    find cslog_controle of t_contrato no-lock.
    find contrato of cslog_controle no-lock no-error.
 
    vtitdtpag = formatadata(cslog_controle.ultdtpag).
    vtitvlpag = cslog_controle.ultvlrpag.
    vcod_transacao = "".
    vok = no.
    
    vchave_contrato = string(cslog_controle.loja ,"999") +
                      string(cslog_controle.contnum,"99999999999"). 
     
    def var vestava as char format "x(30)".
    def var vficou  as char format "x(30)".
    def var vpagamentos as char format "x(30)".
    def var vtitpar as int.
    def var vloop as int.

    if avail contrato /* #1 */
    then do.
        vestava = cslog_controle.cybparpg.
        vficou  = cslog_controle.parpg.

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
                    titulo.clifor = cslog_controle.cliente and 
                    titulo.titnum = string(cslog_controle.contnum) and
                    titulo.titpar = vtitpar
                no-lock no-error.
            if avail titulo
            then do:
                vtitdtpag = formatadata(titulo.titdtpag).
                vtitvlpag = titulo.titvlpag.
            end.      
            vcod_transacao = string(vtitpar,"999999").

            run exporta.
            vok = yes.
        end.
    end. /* avail */

    /* #1 */
    if not vok
    then run exporta.
end.

/* TRAILER */
vqtd_registros = vqtd_registros + 1.
put unformatted
    "T"               format "x"          /* TIPO              0001 - 0001 */ 
    vdata_geracao     format "xxxxxxxx"   /* DATA DE GERACAO   0002 - 0009 */ 
    vqtd_registros    format "9999999999" /* QUANTIDADE DE REGISTROS ARQUIVO
                                                               0010 - 0019 */
    vsequencia        format "9999999999" /* SEQUENCIA ARQUIVO 0020 - 0029 */
    fill(" ",75)      format "x(75)"      /* FILLER            0030 - 3208 */
    skip.

output close.
{csl/arquivozip.i}


procedure exporta.

    put unformatted
        "500"  /* tipo registro */           format "x(3)"    /* Obrigatorio */
        "2"    /* grupo */                   format "x(1)"    /* Obrigatorio */
        vchave_contrato                      format "x(25)"   /* obrigatorio */
    
        vtitdtpag                            format "x(8)"    /* obrigatorio */
        vtitdtpag                            format "x(8)"    /* obrigatorio */
        vtitvlpag  * 100                     format "999999999999999"
        vtitvlpag  * 100                     format "999999999999999"
        ""                                   format "x(15)"
        vcod_transacao                       format "x(6)"        
        ""                                   format "x(8)"
        skip.        
        vqtd_registros = vqtd_registros + 1.

end procedure.
