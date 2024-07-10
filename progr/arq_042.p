{admcab.i}

def var varqsai2 as char.

def var j as int.
def var varqsai1_biu as char.
def var varqsai2_biu as char.

def var vdata like plani.pladat.
def var vconta as int format "9999999999".

def shared temp-table tt-che
    field rec  as recid
    field cmc7 as char format "x(40)"
    index rec is primary unique rec asc.

find first tt-che no-error.
if not avail tt-che
then do:
    bell.
    message "Nenhum Cheque foi selecionado".
    pause 2 no-message.
    leave.
end.    
    
def var varqsai  as char.
def var varqsai3 as char.
def var vlocsai  as char. 
def var varq001  as char.
def var varq002  as char.
def var varq003  as char.
def var varqent  as char.
def var vdtanom  as char form "x(06)"       init ""                no-undo.

def var n-arq as char format "x"  extent 52 init
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E",
     "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
     "T", "U", "V", "X", "Y", "Z", 
     "1A", "2A", "3A", "4A", "5A", "6A", "7A", "8A", "9A", 
     "1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B"].

def var i-cont as int.

def var vcmc7_dv3   as int.
def var vcmc7_cta   as dec.

def var funcao      as char format "x(20)".
def var parametro   as char format "x(20)".

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

/* --------------------ATRIBUICOES------------------------------------------ */

if opsys = "UNIX"
then do:
        assign vlocsai = "../banrisul/".
end.
else do:
        assign vlocsai = "L:~\banrisul~\".    
end.
        
assign varq003 = "banris.ini".
assign varq002 = string(day(today),"99") + 
                 string(month(today),"99") + 
                 string(year(today),"9999") + 
                 ".txt".
assign vdtanom = string(day(today),"99")   + 
                 string(month(today),"99") + 
                 string(year(today),"9999").                 

assign varqsai3 = vlocsai + varq003.
assign varqsai2 = vlocsai + varq002.             
 
/* --------------------PROCEDIMENTOS---------------------------------------- */          
input from value(varqsai3) no-echo.   /*../banrisul/banris.ini no-echo.*/
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

vdata = today.
update vdata label "Data de Envio" with frame f1 side-label centered.

vdtmov = today.

if vdtmov <> par-today
then assign par-seqdia = 0
            par-today  = today.
            
vdtmov = vdata.    

par-seqdia = par-seqdia + 1.

/* 1. ----------------------------------------------------------------------- */

assign varq001 = "biuvcm" + n-arq[par-seqdia] + ".mov" .

assign varqsai  = vlocsai + varq001. 

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
    year (vdata)        format "9999"           /* ano dt arquivo       */
    month(vdata)        format "99"             /* mes dt arquivo       */
    day  (vdata)        format "99"             /* dia dt arquivo       */ substr(string(time,"hh:mm"),1,2)
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
 def var dv-1 as int.
 def var dv-2 as int.
 def var dv-3 as int.
 def var dv-t as char.
    
 vseqchq = 0.
 for each tt-che,
    chq where recid(chq) = tt-che.rec .
    chq.exportado = yes.
    
    
    find chqenv where chqenv.recenv = int(recid(chq)) no-error. 
    if not avail chqenv
    then find chqenv where chqenv.banco = chq.banco and
                           chqenv.agencia = chq.agencia and
                           chqenv.conta = chq.conta and
                           chqenv.numero = chq.numero
                           no-error.
    if not avail chqenv  
    then do:  
        create chqenv. 
        assign chqenv.recenv = int(recid(chq))
               chqenv.banco = chq.banco
               chqenv.agencia = chq.agencia
               chqenv.conta = chq.conta
               chqenv.numero = chq.numero
               chqenv.datenv = today
               chqenv.datexp = chq.data
               chqenv.texto1  = tt-che.cmc7.
    end.
    else do:
        if chqenv.chaenv <> ""
        then  chqenv.chaenv = "".
        
        assign
            chqenv.datenv = today
            chqenv.datexp = chq.data
            chqenv.texto1  = tt-che.cmc7.
    end.
    
    assign
        dv-t = "" dv-1 = 0 dv-2 = 0 dv-3 = 0.
        
    dv-t = string(chq.comp,"999") + string(chq.numero,"999999") + "5".
    run dvmod10.p(input dv-t, output dv-2).
    dv-t = "".
    dv-t = string(chq.banco,"999") + string(chq.agencia,"9999").
    run dvmod10.p(input dv-t, output dv-1).
    dv-t = "".
    dv-t = string(dec(chq.conta),"9999999999").
    run dvmod10.p(input dv-t, output dv-3).
    
    
    i-cont = i-cont + 1.
    vseqchq = vseqchq + 1.

    if tt-che.cmc7 <> ""
    then
        assign
            vcmc7_cta = dec(substr(tt-che.cmc7,23,10)) 
            vcmc7_dv3 = int(substring(tt-che.cmc7,33,1)). 
    else 
        assign 
            vcmc7_cta = dec(chq.conta)
            vcmc7_dv3 = dv-3.
 
    put unformatted
        chq.comp                format "999"    /* camara compensacao       */
        chq.banco               format "999"    /* banco do cheque          */
        chq.agencia             format "9999"   /* agencia do cheque        */
        dv-2                    format "9"   
        "00" 
        /*
        dec(chq.conta)          format "9999999999" /* conta              */
        */
        /**/
        vcmc7_cta               format "9999999999" /* conta              */
        /**/
        dv-1                    format "9"
        int(string(chq.numero,"999999")) format "999999" /* numero cheque */
        /*
        dv-3                    format "9"
        */
        /**/
        vcmc7_dv3               format "9" 
        /**/
        "00"
        string(chq.valor * 100,"99999999999999999")
                                format "99999999999999999" /* valor chq     */
        "  50410001000"
        vseqchq                 format "999999"
        "0"
        year (vdata)            format "9999"      /* ano dt arquivo   */
        month(vdata)            format "99"        /* mes dt arquivo   */
        day  (vdata)            format "99"        /* dia dt arquivo   */
        ""                      format "x(14)"  
        "00000000000000"
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
    year (vdata)        format "9999"           /* ano dt arquivo       */
    month(vdata)        format "99"             /* mes dt arquivo       */
    day  (vdata)        format "99"             /* dia dt arquivo       */    substr(string(time,"hh:mm"),1,2)
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

/* 3. ----------------------------------------------------------------------- */

output to value(varqsai3) no-echo.  /*../banrisul/banris.ini no-echo.*/
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

/* 2. ----------------------------------------------------------------------- */
                         
output to value(varqsai2) append.    
for each tt-che:

    find chq where recid(chq) = tt-che.rec no-lock.
    
    put recid(chq) format "9999999999"
        vtotvalor format "999999999999.99"
        varqsai format "x(30)" skip.
        
end.
output close.
    
/* ------------------------------------------------------------------------- */  
if opsys = "UNIX"
then
    unix silent cp
            value(varqsai + " " + string(day  (vdata),"99")
                                + string(month(vdata),"99") 
                                + substr(string(time,"HH:MM"),1,2)
                                + substr(string(time,"HH:MM"),4,2)
                                + "-" + varqsai 
                                    ) .
else
    dos silent 
            value(  "copy " + 
                    varqsai + " c:/temp/" + string(day(vdata),"99")
                                + string(month(vdata),"99") 
                                + substr(string(time,"HH:MM"),1,2)
                                + substr(string(time,"HH:MM"),4,2)
                                + "-" + varqsai 
                                    ) .
                                        
/* -----------------BACKUP ARQUIVOS----------------------------------------- */
def var cLocalBk     as char form "x(030)"                 init ""     no-undo.
def var cLocArq1a    as char form "x(120)"                 init ""     no-undo. 


if opsys = "UNIX"
then do:
        assign cLocalBk = "../banrisul/backup/".
end.
else do:
        assign cLocalBk = "L:~\banrisul~\backup~\".    
end.
 
assign cLocArq1a  = trim(cLocalBk) + trim(varq001) + trim(vdtanom).

if opsys = "UNIX"
then do:
         unix silent cp value(varqsai)   value(cLocArq1a).
end.
else do:
        os-command silent copy value(" " + trim(varqsai)  + " " + trim(cLocArq1a)).
end.         
/* ------------------FINAL BACKUP ARQUIVOS---------------------------------- */
message "Arquivo Gerado ** " varqsai " **"
        view-as alert-box.


procedure backup_biu:

varqsai1_biu = "../banrisul/backup_biu/biuvcm" 
             + n-arq[par-seqdia] 
             
             + " - "
             + string(day(today),"99")  
             + string(month(today),"99")   
             + string(year(today),"9999")   
             + " - "
             
             + ".mov" .


output to value(varqsai1_biu).
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
    year (vdata)        format "9999"           /* ano dt arquivo       */
    month(vdata)        format "99"             /* mes dt arquivo       */
    day  (vdata)        format "99"             /* dia dt arquivo       */ 
    substr(string(time,"hh:mm"),1,2)
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
 for each tt-che,
    chq where recid(chq) = tt-che.rec .
    chq.exportado = yes.


    assign
        dv-t = "" dv-1 = 0 dv-2 = 0 dv-3 = 0.
        
    dv-t = string(chq.comp,"999") + string(chq.numero,"999999") + "5".
    run dvmod10.p(input dv-t, output dv-2).
    dv-t = "".
    dv-t = string(chq.banco,"999") + string(chq.agencia,"9999").
    run dvmod10.p(input dv-t, output dv-1).
    dv-t = "".
    dv-t = string(dec(chq.conta),"9999999999").
    run dvmod10.p(input dv-t, output dv-3).
    

    i-cont = i-cont + 1.
    vseqchq = vseqchq + 1.
    put unformatted
        chq.comp                format "999"    /* camara compensacao       */
        chq.banco               format "999"    /* banco do cheque          */
        chq.agencia             format "9999"   /* agencia do cheque        */
        dv-2                    format "9"   
        "00" 
        dec(chq.conta)          format "9999999999" /* conta              */
        dv-1                    format "9"
        int(string(chq.numero,"999999")) format "999999" /* numero cheque */
        dv-3                    format "9"
        "00"
        string(chq.valor * 100,"99999999999999999")
                                format "99999999999999999" /* valor chq     */
        "  50410001000"                      format "xx"
        vseqchq                 format "999999"
        "0"
        year (vdata)            format "9999"      /* ano dt arquivo   */
        month(vdata)            format "99"        /* mes dt arquivo   */
        day  (vdata)            format "99"        /* dia dt arquivo   */
        ""                      format "x(14)"  
        "00000000000000"
        ""                      format "x(44)"
        i-cont                  format "9999999999" 
        skip.
 
    /***
    put unformatted
        chq.comp                format "999"    /* camara compensacao       */
        chq.banco               format "999"    /* banco do cheque          */
        chq.agencia             format "9999"   /* agencia do cheque        */
        dv-2 /*chq.controle1*/  format "9"      /* c1/dv1                   */
        "00" 
        dec(chq.conta)          format "9999999999" /* conta              */
        dv-1 /*chq.controle2*/  format "9"      /* c2/dv2                   */
        chq.numero              format "999999" /* numero cheque            */
        dv-3 /*chq.controle3*/  format "9"      /* c3/dv3                   */
        "00"
        string(chq.valor * 100,"99999999999999999")
                                format "99999999999999999" /* valor chq     */
        "  1"                      format "xx"
        "1"                     format "x"
        041                     format "999"
        1                       format "9999"
        0                       format "999"
        vseqchq                 format "999999"
        0                       format "9"
        year (vdata)            format "9999"      /* ano dt arquivo   */
        month(vdata)            format "99"        /* mes dt arquivo   */
        day  (vdata)            format "99"        /* dia dt arquivo   */
        ""                      format "x(14)"  
        0                       format "99999999"
        0                       format "999999"
        ""                      format "x(44)"
        i-cont                  format "9999999999" 
        skip.
    ***/
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
    year (vdata)        format "9999"           /* ano dt arquivo       */
    month(vdata)        format "99"             /* mes dt arquivo       */
    day  (vdata)        format "99"             /* dia dt arquivo       */   
                        substr(string(time,"hh:mm"),1,2)
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



varqsai2_biu = "../banrisul/backup_biu/" + string(day(today),"99") 
                                         + string(month(today),"99")  
                                         + string(year(today),"9999")  
                                         + ".txt".
                          
output to value(varqsai2_biu) append.    
for each tt-che:

    find chq where recid(chq) = tt-che.rec no-lock.
    
    put recid(chq) format "9999999999"
        vtotvalor format "999999999999.99"
        varqsai format "x(30)" skip.
        
end.
output close.
    
 

end procedure.
