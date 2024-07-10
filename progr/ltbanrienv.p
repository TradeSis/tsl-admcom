{admcab.i}

def input parameter par-reclotcre  as recid.

def var vct      as int.
def var vseqarq  as int.
def var vcgc     as dec  init 96662168000131.
def var vcodconv as int  init 5348.
def var vagencia as int  init 878.          
def var vconta   as char init "0608896002". 
def var vlotenro as int.
def var vlotereg as int.
def var vlotevlr as dec.
def var vtotreg  as int.
def var varq     as char.
def var vbancod  as char.
def var vmoeda   as char.
def var vdac     as char.
def var vfatorv  as char.
def var vvalor   as char.
def var vlivre   as char.
def var vdv123   as char.
def var vbarcode as char.
def var vbancod2 as char.
def var vtime    as char.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

vseqarq = lotcretp.ultimo + 1.
if opsys = "unix"
then varq = "/admcom/banrisul/titulos/dreb" + string(vseqarq, "999999").
else varq = "l:~\banrisul~\titulos~\dreb" + string(vseqarq, "999999").

disp
    varq    label "Arquivo"   colon 15 format "x(50)"
    vseqarq label "Sequencia" colon 15
    with side-label title "Remessa - " + lotcretp.ltcretnom.

/*
    Verificar o banco do boleto
*/
for each lotcretit of lotcre where lotcretit.ltsituacao = yes
                               and lotcretit.ltvalida   = ""
                             exclusive,
                         titulo2 where titulo2.empcod = wempre.empcod
                                   and titulo2.titnat = lotcretp.titnat
                                   and titulo2.modcod = lotcretit.modcod
                                   and titulo2.etbcod = lotcretit.etbcod
                                   and titulo2.clifor = lotcretit.clfcod
                                   and titulo2.titnum = lotcretit.titnum
                                   and titulo2.titpar = lotcretit.titpar
                                 no-lock.

    if acha("Bar", titulo2.codbarras) <> ?
    then do.
        vbarcode = acha("Bar", titulo2.codbarras).
        lotcretit.spcetbcod = int(substr(vbarcode,  1,  3)).
    end.
    else do.
        vbarcode = acha("Dig", titulo2.codbarras).
        lotcretit.spcetbcod = int(substr(vbarcode,  1,  3)).
    end.
    lotcretit.numero = titulo2.codbarras.
end.

/*

*/
output to value(varq).
/*
    Header de arquivo
*/
vtime = string(time, "hh:mm:ss").
put unformatted
    "041"
    "0000"
    "0"
    " "         format "x(9)"
    2           format "9"
    vcgc        format "99999999999999"
    vcodconv    format "99999"
    ""          format "x(15)"
    vagencia    format "99999"
    "0"
    "000"
    vconta      format "x(10)"
    "0"
    "DREBES LTDA" format "x(30)"
    "BANRISUL"  format "x(30)"    
    ""          format "x(10)"
    "1"         /* Remessa */
    today       format "99999999"
    substr(vtime, 1, 2)
    substr(vtime, 4, 2)
    substr(vtime, 7, 2)
    vseqarq     format "999999"
    "020"       /* versao */
    1600        format "99999" /* densidade */
    ""          format "x(20)"
    ""          format "x(20)"
    ""          format "x(29)"
    skip.

for each lotcretit of lotcre where lotcretit.ltsituacao = yes
                               and lotcretit.ltvalida   = ""
                             exclusive,
                         titulo where titulo.empcod = wempre.empcod
                                  and titulo.titnat = lotcretp.titnat
                                  and titulo.modcod = lotcretit.modcod
                                  and titulo.etbcod = lotcretit.etbcod
                                  and titulo.clifor = lotcretit.clfcod
                                  and titulo.titnum = lotcretit.titnum
                                  and titulo.titpar = lotcretit.titpar
                                no-lock
                   break by lotcretit.spcetbcod /***titulo.etbcod***/
                         by titulo.clifor.

    find lotcreag of lotcretit no-lock.
    if lotcreag.ltsituacao <> yes /* desmarcado */ or
       lotcreag.ltvalida   <> ""  /* invalido */
    then next.

    find forne where forne.forcod = lotcretit.clfcod no-lock.
    find titulo2 of titulo no-lock.

    if acha("Bar", titulo2.codbarras) <> ?
    then do.
        vbarcode = acha("Bar", titulo2.codbarras).
        /* codigo de barras */
        assign
            vbancod = substr(vbarcode,  1,  3)
            vmoeda  = substr(vbarcode,  4,  1)
            vdac    = substr(vbarcode,  5,  1)
            vfatorv = substr(vbarcode,  6,  4)
            vvalor  = substr(vbarcode, 10, 10)
            vlivre  = substr(vbarcode, 20, 25)
            vdv123  = "".
    end.
    else do.
        vbarcode = acha("Dig", titulo2.codbarras).
        /* codigo digitavel */
        assign
            vbancod = substr(vbarcode,  1,  3)
            vmoeda  = substr(vbarcode,  4,  1)
            vdac    = substr(vbarcode, 33,  1)
            vfatorv = substr(vbarcode, 34,  4)
            vvalor  = substr(vbarcode, 38, 10)
            vlivre  = substr(vbarcode,  5,  5) +
                      substr(vbarcode, 11, 10) +
                      substr(vbarcode, 22, 10)
            vdv123  = substr(vbarcode, 10, 1) +
                      substr(vbarcode, 21, 1)+
                      substr(vbarcode, 32, 1).
    end.

    if vbancod <> vbancod2 and
       (vbancod2 = ""    or
        vbancod  = "041" or
        vbancod2 = "041")
    then do.
        if vlotereg > 0
        then do.
            /*
                Trailler de lote
            */
            vtotreg = vtotreg + 1.
            put unformatted
                "041"
                vlotenro    format "9999" /* nro.lote */
                "5"   
                ""          format "x(9)"
                vlotereg + 2   format "999999"
                vlotevlr * 100 format "999999999999999999"
                ""          format "x(18)"
                ""          format "x(171)"
                ""          format "x(10)"
                skip.

            assign
                vlotereg = 0
                vlotevlr = 0.
        end.

        assign
            vlotenro = vlotenro + 1
            vtotreg  = vtotreg  + 1.

        /*
            Header de Lote
        */
        put unformatted
            "041"
            vlotenro    format "9999"      /* nro.lote */
            "1"
            "C"
            "20"        /* Pagamento fornecedor */
            if vbancod = "041" then "30" else "31"        /* forma lcto */
            "020"
            " "
            "2"
            vcgc        format "99999999999999"
            vcodconv    format "99999"
            ""          format "x(15)"
            vagencia    format "99999"
            "0000"
            vconta      format "x(10)"
            " "
            "DREBES LTDA" format "x(30)"
            ""          format "x(40)"
            ""          format "x(30)"
            ""          format "x(5)"
            ""          format "x(15)"
            ""          format "x(20)"
            ""          format "x(8)"
            "RS"
            "VA"
            " "         format "x(6)"
            " "         format "x(10)"
            skip.    
    end.        
    
    /*
        Segmento J
    */    
    assign
        vlotereg = vlotereg + 1
        vlotevlr = vlotevlr + titulo.titvlcob
        vtotreg  = vtotreg + 1
        vbancod2 = vbancod.

    put unformatted
        "041"
        vlotenro        format "9999" /* nro.lote */
        "3"
        vlotereg        format "99999"
        "J"
        "0"
        "00"
        vbancod         format "x(3)"
        vmoeda          format "x(1)"
        vdac            format "x(1)"
        vfatorv         format "x(4)"
        vvalor          format "x(10)"
        vlivre          format "x(25)"
        forne.fornom    format "x(30)"
        titulo.titdtven format "99999999"
        titulo.titvlcob * 100 format "999999999999999"
        0               format "999999999999999" /* Desconto */
        0               format "999999999999999" /* zeros */
        titulo.titdtven format "99999999"
        titulo.titvlcob * 100 format "999999999999999"
        0               format "999999999999999"
        ""              format "x(5)"
        "2" + forne.forcgc format "x(15)"
        ""              format "x(25)"
        vdv123          format "x(3)"
        ""              format "x(10)"
        skip.        

    /* identificar o arquivo que foi enviado */
    assign
        lotcretit.spcseqproc  = vlotenro /* Nro lote */
        lotcretit.spcseqtrans = vlotereg /* Reg no lote */.
end.        
        
/*
    Trailler de lote
*/
if vlotereg > 0
then do.
    vtotreg = vtotreg + 1.
    put unformatted
        "041"
        vlotenro    format "9999" /* nro.lote */
        "5"   
        ""          format "x(9)"
        vlotereg + 2   format "999999"
        vlotevlr * 100 format "999999999999999999"
        ""          format "x(18)"
        ""          format "x(171)"
        ""          format "x(10)"
        skip.
end.

/*
    Trailler de arquivo
*/
put unformatted
    "041"
    "9999"
    "9"
    ""          format "x(9)"
    vlotenro    format "999999" /* nro de lotes */
    vtotreg + 2 format "999999"
    "000000"
    ""          format "x(205)"
    skip.

output close.

do on error undo.
    find current lotcretp exclusive.
    lotcretp.ultimo = lotcretp.ultimo + 1.
    
    find lotcre where recid(lotcre) = par-reclotcre exclusive.
    assign
        lotcre.ltdtenvio = today
        lotcre.lthrenvio = time
        lotcre.ltfnenvio = sfuncod
        lotcre.arqenvio  = varq.
end.
find lotcre where recid(lotcre) = par-reclotcre no-lock.

if opsys = "unix"
then do.
    unix silent unix2dos value(varq).
    unix silent chmod 777 value(varq).
end.

message "Registros gerados: " vtotreg " " varq view-as alert-box.

