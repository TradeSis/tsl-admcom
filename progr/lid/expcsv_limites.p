{admcab.i}

def var vcliini  as int format ">>>>>>>>>>9" label "de".
def var vclifim  as int format ">>>>>>>>>>9" label "ate".
def var varqcsv as char format "x(60)" label "csv".


def var vt as int.
def var vi as int.
def var xtime as int.

def var vcp as char init ";".
def var vvlr_aberto as dec.
def var vfinanceira as log.
def var vdt_primvenc as date.
def var vqtd_parcelas as int.
def var vtpcontrato as char.
def var vcpf as char.


def var vvlrlimite  as dec.
def var vvlrdisponivel as dec.
def var vvctolimite as date.
def var var-comprometidoPrincipal as dec.
def var var-comprometidoTotal     as dec.
def var var-comprometidoNovacao     as dec.
def var var-comprometidoNormal     as dec.
def var var-comprometidoEPPrincipal as dec.
def var var-comprometidoEPTotal     as dec.
def var var-comprometidoEPNovacao     as dec.
def var var-comprometidoEPNormal     as dec.

    def var vdataUltimaCompra as char.
    def var vquantidadeContratos as char.
    def var vquantidadeParcelasPagas as char.
    def var vquantidadeParcelasEmAberto as char.
    def var vquantidadeAte15Dias as char.
    def var vquantidadeAte45Dias as char.
    def var vquantidadeAcima45Dias as char.

/** #092022 - novos campos para BI
credito
dataUltimaCompra
quantidadeContratos
quantidadeParcelasPagas
quantidadeParcelasEmAberto
quantidadeAte15Dias
quantidadeAte45Dias
quantidadeAcima45Dias
*/
/* #092022 */
def var vDTULTCPA as date format "99/99/9999".

/* #092022 */


{../progr/neuro/achahash.i}  /* 03.04.2018 helio */
{../progr/neuro/varcomportamento.i} /* 03.04.2018 helio */



xtime = time.


update vcliini vclifim 
    with frame f1 side-labels centered
    title "clientes".

varqcsv = "/admcom/tmp/lidia/limites_" + string(today,"999999") + ".csv".



def stream csvlimite.
output stream csvlimite to value(varqcsv).

put stream csvlimite unformatted skip 
    "TIPO"
vcp "CODIGOCLIENTE"
vcp "CPFCNPJ"
vcp "NOMECLIENTE"
vcp "LIMITE"
vcp "VCTOLIMITE"
vcp "SALDOLIMITE"
vcp "COMPROMETIDO"
vcp "COMPROMETIDOTOTAL"
vcp "COMPROMETIDOPRINCIPAL"
vcp "COMPROMETIDONOVACAO"
vcp "COMPROMETIDONORMAL"
    /* #092022 */
    vcp "dataUltimaCompra"
    vcp "quantidadeContratos"
    vcp "quantidadeParcelasPagas"
    vcp "quantidadeParcelasEmAberto"
    vcp "quantidadeAte15Dias"
    vcp "quantidadeAte45Dias"
    vcp "quantidadeAcima45Dias"
    /* #092022 */

 skip.
 
/*  Todos emitidos a partir de 2016 ou com alguma parcela em aberto  */


for each clien 
        where clien.clicod >= vcliini and clien.clicod <= vclifim
        no-lock use-index clien.

    find neuclien where neuclien.clicod = clien.clicod no-lock no-error. 

    vt = vt + 1.    
    if vt mod 2000 = 0 or vt = 1
    then do:
        hide message no-pause.
        message "limites" today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") vt vi.
        pause 1 no-message.
    end.
    vcpf  = ?.
    
        if avail neuclien then vcpf = trim(string(neuclien.cpf,">>>>>>>>>>>>>>>")).
        if vcpf = ?
        then do:
                vcpf = clien.ciccgc.
        end.
        if vcpf = ?
        then vcpf = "".

    vvlrlimite = 0.
    vvctolimite = ?.
    vvlrdisponivel = 0.

    if avail neuclien
    then do:
        vvlrlimite = /* helio 17052023
                    *if neuclien.vctolimite < today
                    *then 0
                    *else*/ neuclien.vlrlimite.
        vvctolimite = neuclien.vctolimite.
    end.
    var-propriedades = "" .


      if avail neuclien and neuclien.clicod = ?
      then run /admcom/progr/neuro/limites.p (neuclien.cpfCnpj,   output var-propriedades).
      else run /admcom/progr/neuro/comportamento.p (clien.clicod,?,   output var-propriedades).

      var-comprometidoTotal     = dec(pega_prop("LIMITETOM")).
      var-comprometidoPrincipal = dec(pega_prop("LIMITETOMPR")).
      var-comprometidoNovacao   = dec(pega_prop("LIMITETOMNOV")).
      var-comprometidoNormal    = dec(pega_prop("LIMITETOMNORM")).
      vvlrdisponivel = dec(pega_prop("LIMITEDISP")).

      if vvlrlimite = ? then vvlrlimite = 0.
      if vvlrdisponivel = ? then vvlrdisponivel = 0.  

    if var-comprometidoPrincipal = ? then var-comprometidoPrincipal = 0.
    if var-comprometidoTotal = ? then var-comprometidoTotal = 0.
    if var-comprometidoNovacao = ? then var-comprometidoNovacao = 0.
    if var-comprometidoNormal = ? then var-comprometidoNormal = 0.

    /*helio 17052023
    *if vvlrdisponivel < 0
    *then vvlrdisponivel = 0.
    */

    /** #092022 */
      vDTULTCPA                 = date(pega_prop("DTULTCPA")).
    vdataUltimaCompra    =  if vDTULTCPA = ? then ""
                                       else string(year(vDTULTCPA),"9999") + "-" + 
                                            string(month(vDTULTCPA),"99")   + "-" + 
                                            string(day(vDTULTCPA),"99"). 
    vquantidadeContratos         = pega_prop("QTDECONT").
    vquantidadeParcelasPagas     = pega_prop("PARCPAG").
    vquantidadeParcelasEmAberto  = pega_prop("PARCABERT").
    
    def var r1 as char.
    r1 = pega_prop("ATRASOPARC")  .
    r1 = replace(r1,"%",""). 
    if num-entries(r1,"|") = 3 /* helio 20072022 ID 139086 - ERRO no adm */ 
    then do: 
        vquantidadeAte15Dias = (entry(1,r1,"|")). 
        vquantidadeAte45Dias = (entry(2,r1,"|")). 
        vquantidadeAcima45Dias = (entry(3,r1,"|")). 
    end.    
    
    /* #092022 */

    put stream csvlimite unformatted
            "Global"
        vcp if avail clien then string(clien.clicod) else ""
        vcp vcpf
        vcp if avail clien then clien.clinom else if avail neuclien then neuclien.nome_pessoa else ""
        vcp trim(string(vvlrLimite,"->>>>>>>>>>>>>>>>>9.99"))
        vcp  if vvctolimite = ? then "" else (string(year(vvctolimite),"9999") + "-" + string(month(vvctolimite),"99")   + "-" + string(day(vvctolimite),"99"))
        vcp trim(string(vvlrdisponivel,"->>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoPrincipal,"->>>>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoTotal,"->>>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoPrincipal,"->>>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoNovacao,"->>>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoNormal,"->>>>>>>>>>>>>>>>>>9.99"))
            vcp vdataUltimaCompra 
    vcp vquantidadeContratos 
    vcp vquantidadeParcelasPagas 
    vcp vquantidadeParcelasEmAberto 
    vcp vquantidadeAte15Dias 
    vcp vquantidadeAte45Dias 
    vcp vquantidadeAcima45Dias 

        
        skip.
        


    vvlrlimite = dec(pega_prop("LIMITEEP")).
    vvlrdisponivel = dec(pega_prop("LIMITEDISPEP")).

        var-comprometidoEPTotal     = dec(pega_prop("LIMITETOMEP")).
        var-comprometidoEPPrincipal = dec(pega_prop("LIMITETOMPREP")).
        var-comprometidoEPNovacao   = dec(pega_prop("LIMITETOMEPNOV")).
        var-comprometidoEPNormal    = dec(pega_prop("LIMITETOMEPNORM")).

      if vvlrlimite = ? then vvlrlimite = 0.
      if vvlrdisponivel = ? then vvlrdisponivel = 0.  
      if var-comprometidoEPPrincipal = ? then var-comprometidoEPPrincipal = 0.
      if var-comprometidoEPTotal = ? then var-comprometidoEPTotal = 0.
      if var-comprometidoEPNovacao = ? then var-comprometidoEPNovacao = 0.
      if var-comprometidoEPNormal = ? then var-comprometidoEPNormal = 0.

      /* helio 17052023
      *if vvlrdisponivel < 0
      *then vvlrdisponivel = 0.
      */
      
    put stream csvlimite unformatted
            "EP"
        vcp if avail clien then string(clien.clicod) else ""
        vcp vcpf
        vcp if avail clien then clien.clinom else if avail neuclien then neuclien.nome_pessoa else ""
        vcp trim(string(vvlrLimite,"->>>>>>>>>>>>>>>>>9.99"))
        vcp  if vvctolimite = ? then "" else (string(year(vvctolimite),"9999") + "-" + string(month(vvctolimite),"99")   + "-" + string(day(vvctolimite),"99"))
        vcp trim(string(vvlrdisponivel,"->>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoEPPrincipal,"->>>>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoEPTotal,"->>>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoEPPrincipal,"->>>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoEPNovacao,"->>>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoEPNormal,"->>>>>>>>>>>>>>>>>>9.99"))
            vcp vdataUltimaCompra 
    vcp vquantidadeContratos 
    vcp vquantidadeParcelasPagas 
    vcp vquantidadeParcelasEmAberto 
    vcp vquantidadeAte15Dias 
    vcp vquantidadeAte45Dias 
    vcp vquantidadeAcima45Dias 

        
        skip.


    vvlrlimite = 0.
    vvctolimite = ?.
    vvlrdisponivel = 0.

    if avail neuclien
    then do:
        vvlrlimite = /*helio 17052023
                    *if neuclien.vctolimite < today
                    *then 0
                    else*/ neuclien.vlrlimite.
        vvctolimite = neuclien.vctolimite.
    end.

    vvlrdisponivel = dec(pega_prop("LIMITEDISP")).

      if vvlrlimite = ? then vvlrlimite = 0.
      if vvlrdisponivel = ? then vvlrdisponivel = 0.  

      var-comprometidoTotal     = dec(pega_prop("LIMITETOMCDC")).
      var-comprometidoPrincipal = var-comprometidoPrincipal - var-comprometidoEPPrincipal.
      var-comprometidoNovacao   = var-comprometidoNovacao - var-comprometidoEPNovacao.
      var-comprometidoNormal    = var-comprometidoNormal - var-comprometidoEPNormal.


    if var-comprometidoPrincipal = ? then var-comprometidoPrincipal = 0.
    if var-comprometidoTotal = ? then var-comprometidoTotal = 0.
    if var-comprometidoNovacao = ? then var-comprometidoNovacao = 0.
    if var-comprometidoNormal = ? then var-comprometidoNormal = 0.

    /* helio 17052023
    *if vvlrdisponivel < 0
    *then vvlrdisponivel = 0.
    */

    put stream csvlimite unformatted
            "CDC"
        vcp if avail clien then string(clien.clicod) else ""
        vcp vcpf
        vcp if avail clien then clien.clinom else if avail neuclien then neuclien.nome_pessoa else ""
        vcp trim(string(vvlrLimite,"->>>>>>>>>>>>>>>>>9.99"))
        vcp  if vvctolimite = ? then "" else (string(year(vvctolimite),"9999") + "-" + string(month(vvctolimite),"99")   + "-" + string(day(vvctolimite),"99"))
        vcp trim(string(vvlrdisponivel,"->>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoPrincipal,"->>>>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoTotal,"->>>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoPrincipal,"->>>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoNovacao,"->>>>>>>>>>>>>>>>>>9.99"))
        vcp trim(string(var-comprometidoNormal,"->>>>>>>>>>>>>>>>>>9.99"))
        
        
            vcp vdataUltimaCompra 
    vcp vquantidadeContratos 
    vcp vquantidadeParcelasPagas 
    vcp vquantidadeParcelasEmAberto 
    vcp vquantidadeAte15Dias 
    vcp vquantidadeAte45Dias 
    vcp vquantidadeAcima45Dias 

        skip.
        

end.            


output stream csvlimite close.



message "arquivo" varqcsv "gerado.".
pause.



