/* helio 31072024 */
DEF INPUT  PARAM    lcJsonEntrada AS LONGCHAR.
DEF OUTPUT PARAM    vretorno          AS CHAR.
{admcab-batch.i}
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros serialize-name "parametros"
    field etb_ini       AS INT
    field etb_fim       AS INT.
                        
hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
if not avail ttparametros then return.


def buffer btitulo for titulo.

def var cestcivil as char.
def var tiporeceita as char.
def var jurosdivida as dec.
def var totaldivida as dec.
def var fatorusar as dec.
         def var diasdeatraso as int.
    def var parcelafinal as dec.
    def var i-real    as int no-undo.
    def var d-centavo as dec decimals 2 no-undo.
                    
    def var i-novoreal    as int no-undo.
    def var d-novocentavo as dec decimals 2 no-undo.
                                                    
    def var d-novaparcela like estoq.estven.
    def var d-novototal   like estoq.estven.

def var statuscli as char.
def var statusmoecod like titulo.moecod.

def var varquivo  as character.
def var varquivo2 as character.                               
def var varquivo3 as character.

def var numeronovocontrato as char.
def var statusnovocontrato as char.
def var datanovocontrato as date.


varquivo = "/admcom/import/cdlpoa/cdleld-cp-pag-" 
+ string(day(today))  
+ string(month(today))  
+ string(year(today))  
+  "-" + string(time) + ".csv".

/* parametros vem do ttparametros */
etb_ini = ttparametros.etb_ini.
etb_fim = ttparametros.etb_fim.

output to value(varquivo).

put "cpf;codigocliente;contrato;datavencimento;datapagamento;valorparcela;valorpago;moeda;estab recebimento;modalidade;" skip. 

for each titulo use-index titdtpag where titulo.empcod = 19 
                                and titulo.titnat = no and
                                 titdtpag >= today - etb_fim and
                                 titdtpag <= today - etb_ini and
                             titulo.modcod begins "CP" and
                             titulo.titsit = "PAG" 
  no-lock.


find first clien where clien.clicod = titulo.clifor no-lock no-error.
                               
                                                         
put 
    clien.ciccgc ";"
    titulo.clifor ";"
    titulo.titnum ";"
    titulo.titdtven ";"
    titulo.titdtpag ";"
    titulo.titvlcob format ">>>>>>>>>>9.99" ";"
    titulo.titvlpag format ">>>>>>>>>>9.99" ";"
    titulo.moecod ";"
    titulo.etbcobra ";"
    titulo.modcod ";"  
     ";"
     ";".


                  put ";;;;;".
               

   put titulo.tpcontrato format "x(1)" ";"
       titulo.titpar ";".

    put  skip.
    
    end.


output close. 
/* Lucas 24072024 - adicionado variavel vretorno para retorno no programa 1 */
vretorno = varquivo.



















