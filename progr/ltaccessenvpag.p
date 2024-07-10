/* Arquivo de envio Lote Access */
{admcab.i}

def input parameter par-reclotcre  as recid.

def var vparcela like titulo.titpar.
def var vtitnum like titulo.titnum.
def var vclifor like titulo.clifor.
def var vtitdtpag like titulo.titdtpag.
def var vltotal like contrato.vltotal.
def var vdtinicial like contrato.dtinicial.

def new shared temp-table tt-titulo like titulo.
def new shared temp-table tt-contratolp like contrato.
 
def new shared temp-table tt-contrato
    field registro           as int format 9 initial 3
    field tipooper           as char
    field etbcod             like estab.etbcod
    field codigocliente      as int
    field numerotitulo       as char
    field qtdrenegociacao    as int
    field datacompra         as date
    field valorentrada       as dec
    field constaspc          as char
    field qtdparcelascontr   as int
    field valorcontrato      as dec
    field dataultpagamento   as date
    field lojacompra         as int
    field nomeagente         as char
    field especietitulo      as char
    field numultparcpaga     as int
    field saldocontrato      as dec
    field vlrentcontrreneg   as dec.
    
def var vtitnumnovo     like titulo.titnum.
def var vetbcod         like estab.etbcod.
def var varquivo        as char.
def var varqexp         as char.
def var vdti            like plani.pladat.
def var vdtf            like plani.pladat.
def var vvlrtitulo      as dec.
def var vct             as int.
def var vseqarq         as int format "999999999".
def var vcgc            as dec  init 96662168000131.
def var vlotenro        as int.
def var vlotereg        as int.
def var vlotevlr        as dec.
def var vtotreg         as int.
def var varq            as char.
def var vqtd-parcelas   as int.
def var vdtultimopag    as date.
def var vultimaparpag   as int.
def var vsaldocontrato  like contrato.vltotal.
def var vspc            as char.  
def var vnumerocontrato as int.
def var vvalorcontrato  like contrato.vltotal.
def var vsaldo          like fin.contrato.vltotal.
def var vnovacao        as log.
def var vetbcobra       like titulo.etbcobra.
def var vreftel         as char.
def var vprotel         as char.        
def var vfone           as char.
def var vcelular        as char.
def buffer bclien       for clien.
def buffer bcontrato    for contrato.
def buffer btitulo      for titulo.
def var vqtdparcelas    as int.

for each tt-contrato:
    delete tt-contrato.
end.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

vseqarq = lotcre.ltcrecod.

if opsys = "unix"
then varq = "/admcom/custom/nede/arquivos/" + "PAG" + string(vseqarq, "99999999~~9") + ".txt".
else varq = "l:~\access~\titulos~\dreb" + "PAG" + string(vseqarq, "999999999")
+ ".txt".

disp
    varq    label "Arquivo"   colon 15 format "x(50)"
    vseqarq label "Lote" colon 15 
    with side-label title "Remessa - " + lotcretp.ltcretnom.

if connected ("d") then disconnect d.
run conecta_d.p.
if connected ("d")
then do:
    run ltaccessenvpglp.p (input recid(lotcre)).
    disconnect d.
end.                     
hide message no-pause.


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
    
    find tt-titulo where    tt-titulo.empcod = titulo.empcod
                        and tt-titulo.modcod = titulo.modcod
                        and tt-titulo.titnat = titulo.titnat
                        and tt-titulo.etbcod = titulo.etbcod
                        and tt-titulo.clifor = titulo.clifor
                        and tt-titulo.titnum = titulo.titnum
                        and tt-titulo.titpar = titulo.titpar no-error.
    
    if not avail tt-titulo
    then do:
        create tt-titulo.
        buffer-copy titulo to tt-titulo.
    end.
end.


for each tt-titulo:
    
    find contrato where int(tt-titulo.titnum) = contrato.contnum 
    no-lock no-error.
    
    if avail contrato 
    then assign vnumerocontrato = contrato.contnum
                vltotal = contrato.vltotal
                vdtinicial = contrato.dtinicial.
    
    
    if not avail contrato 
    then 
    find first tt-contratolp where tt-contratolp.contnum = 
    int(tt-titulo.titnum)     no-lock no-error.
    
    if avail tt-contratolp 
    then assign vnumerocontrato = tt-contratolp.contnum
                vltotal         = tt-contratolp.vltotal
                vdtinicial      = tt-contratolp.dtinicial.

    if not avail tt-contratolp and not avail contrato 
    then do:
       vnumerocontrato = int(tt-titulo.titnum).
    end.

    find clien where clien.clicod = tt-titulo.clifor no-lock.
    
    find tt-contrato where int(tt-contrato.numerotitulo) = vnumerocontrato          and  tt-contrato.etbcod = tt-titulo.etbcod no-error.
    
    if not avail tt-contrato 
    then do:
    
    create tt-contrato.
    assign    
        tt-contrato.registro            = 3
        tt-contrato.tipooper            = "A"
        tt-contrato.etbcod              = tt-titulo.etbcod
        tt-contrato.codigocliente       = clien.clicod 
        tt-contrato.numerotitulo        = string(vnumerocontrato)      
        tt-contrato.qtdrenegociacao     = 0
        tt-contrato.datacompra          = vdtinicial
        tt-contrato.valorentrada        = if tt-titulo.titpar = 0 then                                                    tt-titulo.titvlcob else 0
        tt-contrato.constaspc           = ""
        tt-contrato.qtdparcelascontr    = 0
        tt-contrato.valorcontrato       = vltotal
        tt-contrato.dataultpagamento    = ?
        tt-contrato.lojacompra          = tt-titulo.etbcod
        tt-contrato.nomeagente          = ""
        tt-contrato.especietitulo       = "C"
        tt-contrato.numultparcpaga      = titulo.titpar
        tt-contrato.saldocontrato       = 0
        tt-contrato.vlrentcontrreneg    = 0.
            
   end.
   assign
        vlotereg = vlotereg + 1
        vlotevlr = vlotevlr + titulo.titvlcob
        vtotreg  = vtotreg + 1.
    
    /*
    /* identificar o arquivo que foi enviado */
    assign
        lotcretit.spcseqproc  = vlotenro /* Nro lote */
        lotcretit.spcseqtrans = vlotereg /* Reg no lote */.
    */    
end.
        

if connected ("d") then disconnect d.
run conecta_d.p.
if connected ("d")
then do:
    run lttitulolp.p.
    disconnect d.
end.                     
hide message no-pause.

vtotreg = 0.

/* busca todos os titulos dos contratos */
for each tt-contrato.

    vtotreg = vtotreg + 1.               
    vqtd-parcelas  = 0.
    vdtultimopag   = ?.
    vultimaparpag  = 0.
    vsaldocontrato = 0.
    vvalorcontrato = 0.
    vsaldo         = 0.
    vspc = "N".
    vnovacao = no.
    vclifor = 0.
    vtitdtpag = ?.
    vtitnum = "".
    vparcela = 0.

    find clispc where clispc.clicod  = tt-contrato.codigocliente and
                      clispc.contnum = int(tt-contrato.numerotitulo)
                      no-lock no-error.

    if avail clispc 
    then do:
        if clispc.dtcanc = ?
        then vspc = "S".
    end.

    for each titulo where titulo.empcod = 19
                      and titulo.titnat = no
                      and titulo.modcod = "CRE"
                      and titulo.etbcod = tt-contrato.etbcod
                      and titulo.clifor = tt-contrato.codigocliente
                      and titulo.titnum = tt-contrato.numerotitulo
                      no-lock break by titulo.titnum.
        
        vvalorcontrato = vvalorcontrato + titulo.titvlcob.
        vqtd-parcelas = vqtd-parcelas + 1.

        if titulo.titdtpag <> ?  
        then vsaldocontrato = vsaldocontrato +  titulo.titvlcob.
        
        if vsaldocontrato < 0 then vsaldocontrato = 0.
        
        if titulo.titdtpag <> ?
        then assign tt-contrato.dataultpagamento = titulo.titdtpag.
        
        /*Verifica se existem titulos com novacao no contrato*/
        if fin.titulo.etbcobra > 900 
        then assign vnovacao   = yes 
                    vetbcobra  = fin.titulo.etbcod. 
    
        if fin.titulo.moecod = "NOV" and fin.titulo.etbcobra < 900
        then assign vnovacao   = yes
                    vetbcobra  = fin.titulo.etbcobra.
    
    end. /*titulo*/

    vsaldo = vvalorcontrato - vsaldocontrato.
    if vsaldo <= 0 then vsaldo = 0.
    
    if vsaldo = 0 
    then assign tt-contrato.tipooper = "R".
    
    assign tt-contrato.valorcontrato      = vvalorcontrato.
    assign tt-contrato.qtdparcelascontr   = vqtd-parcelas.                     
    assign tt-contrato.saldocontrato      = vsaldo.
    assign tt-contrato.constaspc          = vspc.

    if tt-contrato.saldocontrato <> 0
    then assign tt-contrato.tipooper = "A".

end. /*tt-contrato*/


def var ventradaren like titulo.titvlcob.
/*Verificar as novacoes e buscar valor da primeira parcela renegociada paga */

if connected ("d") then disconnect d.
run conecta_d.p.
if connected ("d")
then do:

for each tt-contrato.
    
    vnovacao  = no.
    vetbcobra = 0.
    ventradaren = 0.

    for each fin.titulo where fin.titulo.empcod = 19
                      and fin.titulo.titnat = no
                      and fin.titulo.modcod = "CRE"
                      and fin.titulo.etbcod = tt-contrato.etbcod
                      and fin.titulo.clifor = tt-contrato.codigocliente
                      and fin.titulo.titnum = tt-contrato.numerotitulo
                      no-lock break by fin.titulo.titnum.
        
        
        /*Verifica se existem titulos com novacao no contrato*/
        if titulo.etbcobra > 900 or titulo.moecod = "NOV"
        then do:
            
               assign vclifor   = titulo.clifor
                      vtitdtpag = titulo.titdtpag
                      vtitnum   = titulo.titnum.
                      
               if titulo.etbcobra > 90
               then vparcela = 51.
               else vparcela =  0.
        end.

    
    end. /*titulo*/
    
    run ltnovacoes.p ( input vclifor,
                       input vtitdtpag,
                              input vtitnum,
                              input vparcela,
                              output ventradaren,
                              output vtitnumnovo ).

    assign tt-contrato.vlrentcontrreneg = ventradaren.

end. /*tt-contrato*/
disconnect d.
end.                     
hide message no-pause.


run pi-exporta-arquivo. 
message "Arquivo " + varqexp + " gerado com sucesso" view-as alert-box.

procedure pi-exporta-arquivo.
output to value(varq).
for each tt-contrato no-lock.
            
    run pi-registro3.
        
end.
output close.
end procedure.         

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
then do.                      /*
    unix silent unix2dos value(varq).
    unix silent chmod 777 value(varq). */
end.

message "Registros gerados: " vtotreg " " varq view-as alert-box.


procedure pi-registro3.
def var vnumtitulo as int format "9999999999".
    vnumtitulo = 0.
    assign
    vnumtitulo = int(tt-contrato.numerotitulo).
    
    if tt-contrato.vlrentcontrreneg > 0 then 
    tt-contrato.qtdrenegociacao = 1.
         
        
    /* Registro tipo 3 */
    put unformatted
        tt-contrato.registro            format "9"
        tt-contrato.tipooper            format "x(1)"
        "C" + string(tt-contrato.etbcod,"999") +                                         string(vnumtitulo,"9999999999") format "x(25)"
        tt-contrato.qtdrenegociacao     format "99"
        tt-contrato.datacompra          format "99999999"
        tt-contrato.valorentrada * 100  format "999999999999"
        tt-contrato.constaspc           format "x(1)"
        tt-contrato.qtdparcelascontr    format "999"
        tt-contrato.valorcontrato * 100 format "999999999999"
        tt-contrato.dataultpagamento    format "99999999"
        tt-contrato.lojacompra          format "999"
        tt-contrato.nomeagente          format "x(30)"
        tt-contrato.especietitulo       format "x(1)"
        tt-contrato.numultparcpaga      format "999"
        tt-contrato.saldocontrato * 100 format "999999999999"
        tt-contrato.vlrentcontrreneg * 100   format "999999999999"
    skip.

end procedure.
        

