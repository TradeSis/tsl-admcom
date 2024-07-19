DEF INPUT  PARAM    lcJsonEntrada AS LONGCHAR.
DEF OUTPUT  PARAM    arquivo AS CHAR.

{tsr/tsrelat.i}

DEF VAR hentrada AS HANDLE.

def temp-table ttparametros serialize-name "parametros"
    field etb_ini       AS INT
    field etb_fim       AS INT.
                        
hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.


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


output to value(varquivo).
/* Lucas - retorno do varquivo */
arquivo = varquivo.
output to value(arquivo). 

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




















