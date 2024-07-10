{admcab.i}

def shared temp-table tt-chq
    field rec  as recid
    index rec is primary unique rec asc.

find first tt-chq no-error.
if not avail tt-chq
then do:
    bell.
    message "Nenhum Cheque foi selecionado".
    pause 2 no-message.
    leave.
end.    
    
    
def var varqsai as char.

def var n-arq as char format "x"  extent 50 init
    
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E",
     "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
     "T", "U", "V", "X", "Y", "Z"].
      
def var i-cont as int.

def var funcao          as char format "x(20)".
def var parametro       as char format "x(20)".

def var vdtmov      as date format "99/99/9999".
def var vtotvalor   like fin.chq.valor.
def var par-agencia         like fin.chq.agencia.
def var par-conta           like fin.chq.conta.
def var par-seqdia          as   int.
def var par-codempresa      as char format "xxxx".
def var par-convenio        as char format "xx".
def var par-codarquivo      as char format "xxxxxx".
def var par-ageapres        as int  format "9999".
def var par-today           as date format "99/99/9999".
        
input from ../banrisul/banris.ini no-echo.
repeat with frame ffffff:
    set funcao parametro.
    if funcao = "AGENCIA"
    then pAR-AGENCIA = int(parametro).
    if funcao = "CONTA"
    then pAR-CONTA = parametro.
    if funcao = "SEQDIA"
    then pAR-SEQDIA = int(parametro).
    if funcao = "CODEMpRESA"
    then pAR-CODEMpRESA = parametro.
    if funcao = "CONVENIO"
    then pAR-convenio = parametro.
    if funcao = "CODARQUIVO"
    then pAR-CODARQUIVO = parametro.
    if funcao = "AGEApRES"
    then pAR-ageapres = int(parametro).
    if funcao = "DATA"
    then pAR-today = date(parametro).
end.
input close.

vdtmov = today.
if vdtmov <> par-today
then
    assign par-seqdia = 0
           par-today  = today.
par-seqdia = par-seqdia + 1.

varqsai = "../banrisul/biuvcm" + n-arq[par-seqdia] + ".mov" .

output to value(varqsai).
i-cont = i-cont + 1.
/****       REGISTRO HEADER         ****/

put "H"                     format "x"              /* tipo reg             */
    par-agencia             format "9999"           /* agencia              */
    par-conta               format "9999999999"     /* conta                */
    wempre.emprazsoc        format "x(25)"          /* nome empresa         */
    041                     format "999"            /* banco                */
    "8"                     format "x"              /* dv banco             */
    9                       format "9"              /* interface ext        */
    year (vdtmov)           format "9999"           /* ano dt movimento     */
    month(vdtmov)           format "99"             /* mes dt movimento     */
    day  (vdtmov)           format "99"             /* dia dt movimento     */
    year (today)            format "9999"           /* ano dt arquivo       */
    month(today)            format "99"             /* mes dt arquivo       */
    day  (today)            format "99"             /* dia dt arquivo       */    substr(string(time,"hh:mm"),1,2)
                            format "xx"             /* hora criacao arq     */
    substr(string(time,"hh:mm"),4,2)
                            format "xx"             /* minito cri. arq      */
    par-seqdia              format "9999"           /* sequencial arq dia   */
    ""                      format "xx"             /* cod.dev arq "  "     */
    ""                      format "x"              /* filles brancos       */
    par-codempresa          format "xxxx"           /* cod definido banco   */
    par-convenio            format "xx"             /* cod convenio         */
    par-codarquivo          format "xxxxxx"         /* cod arquivo          */
    par-ageapres            format "9999"           /* agenc onde sao entre */
    ""                      format "x(62)"          /* filler brancos       */
    i-cont                  format "9999999999"     
    skip.
def var vseqchq as int.
vseqchq = 0.
for each tt-chq,
    chq where recid(chq) = tt-chq.rec .
    chq.exportado = yes.
    i-cont = i-cont + 1.
    vseqchq = vseqchq + 1.
    put unformatted
        chq.comp                format "999"    /* camara compensacao       */
        chq.banco               format "999"    /* banco do cheque          */
        chq.agencia             format "9999"   /* agencia do cheque        */
        chq.controle1           format "9"      /* c1/dv1                   */
        chq.conta               format "999999999999" /* conta              */
        chq.controle2           format "9"      /* c2/dv2                   */
        chq.numero              format "999999" /* numero cheque            */
        chq.controle3           format "9"      /* c3/dv3                   */
        0                       format "99"     /* tipo documento           */
        string(chq.valor * 100,"99999999999999999")
                                format "99999999999999999" /* valor chq     */
        ""                      format "xx"
        "1"                     format "x"
        041                     format "999"
        1                       format "9999"
        0                       format "999"
        vseqchq                 format "999999"
        0                       format "9"
        year (today)            format "9999"           /* ano dt arquivo   */
        month(today)            format "99"             /* mes dt arquivo   */
        day  (today)            format "99"             /* dia dt arquivo   */
        ""                      format "x(14)"  
        0                       format "99999999"
        0                       format "999999"
        ""                      format "x(44)"
        i-cont                  format "9999999999" 
        skip.
    vtotvalor = vtotvalor + chq.valor.
end.
i-cont = i-cont + 1.
/****       REGISTRO TRAILLER       ****/

put "T"                     format "x"              /* tipo reg             */
    par-agencia             format "9999"           /* agencia              */
    par-conta               format "9999999999"     /* conta                */
    wempre.emprazsoc        format "x(25)"          /* nome empresa         */
    041                     format "999"            /* banco                */
    "8"                     format "x"              /* dv banco             */
    9                       format "9"              /* interface ext        */
    year (vdtmov)           format "9999"           /* ano dt movimento     */
    month(vdtmov)           format "99"             /* mes dt movimento     */
    day  (vdtmov)           format "99"             /* dia dt movimento     */
    year (today)            format "9999"           /* ano dt arquivo       */
    month(today)            format "99"             /* mes dt arquivo       */
    day  (today)            format "99"             /* dia dt arquivo       */    substr(string(time,"hh:mm"),1,2)
                            format "xx"             /* hora criacao arq     */
    substr(string(time,"hh:mm"),4,2)
                            format "xx"             /* minito cri. arq      */
    par-seqdia              format "9999"           /* sequencial arq dia   */
    ""                      format "xx"             /* cod.dev arq "  "     */
    ""                      format "x"              /* filles brancos       */
    par-codempresa          format "xxxx"           /* cod definido banco   */
    ""                      format "xxx"            /* filler brancos       */
    string(vtotvalor * 100,"999999999999999")
                                format "999999999999999" /* valor chq       */
    ""                      format "x(56)"          /* filler brancos       */
    i-cont                  format "9999999999"     
    skip.

output close.

output to ../banrisul/banris.ini no-echo.
do:
    put "AGENCIA    " pAR-AGENCIA       format "9999"       skip.
    put "CONTA      " pAR-CONTA         format "9999999999" skip.
    put "SEQDIA     " pAR-SEQDIA        format "9999"       skip.
    put "CODEMPRESA " pAR-CODEMpRESA    format "xxxx"       skip.
    put "CONVENIO   " pAR-convenio      format "xx"         skip.
    put "CODARQUIVO " pAR-CODARQUIVO    format "xxxxxx"     skip.
    put "AGEAPRES   " pAR-ageapres      format "9999"       skip.
    put "DATA       " pAR-today         format "99/99/9999" skip. 
end.
output close.

if opsys = "UNIX"
then
    unix silent cp
            value(varqsai + " " + string(day  (today),"99")
                                + string(month(today),"99") 
                                + substr(string(time,"HH:MM"),1,2)
                                + substr(string(time,"HH:MM"),4,2)
                                + "-" + varqsai 
                                    ) .
else
    dos silent 
            value(  "copy " + 
                    varqsai + " c:/temp/" + string(day  (today),"99")
                                + string(month(today),"99") 
                                + substr(string(time,"HH:MM"),1,2)
                                + substr(string(time,"HH:MM"),4,2)
                                + "-" + varqsai 
                                    ) .
                                        
message "Arquivo Gerado ** " varqsai " **"
        view-as alert-box.


