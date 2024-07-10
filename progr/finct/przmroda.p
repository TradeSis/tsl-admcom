/* 17/09/2021 helio*/

def var pdtrefsaida as date.
def var pdtrefini   as date.
def var pdtiniproc  as date.
def var phriniproc  as int.
def buffer pctbprzmprod for ctbprzmprod.
def stream csv.

do on error undo:
    find first pctbprzmprod where pctbprzmprod.pstatus = "PROCESSAR"  and pctbprzmprod.pparametro <> "CARTEIRA"
        exclusive no-wait no-error.
    if not avail pctbprzmprod
    then do:
        message "NADA PARA PROCESSAR" today string(time,"HH:MM:SS").
        quit.
    end.
end.    

    find current pctbprzmprod no-lock.


    pdtrefsaida    = pctbprzmprod.dtfimper /*date(month(pctbprzmprod.dtfimper),01,year(pctbprzmprod.dtfimper))*/ .
    pdtrefini      = pctbprzmprod.dtiniper /*date(month(pctbprzmprod.dtiniper),01,year(pctbprzmprod.dtiniper))*/ .
    pdtiniproc     = today.
    phriniproc     = time.

    hide message no-pause.
    message color normal "fazendo calculos... aguarde..."
        pctbprzmprod.dtiniper pctbprzmprod.dtfimper pdtrefini pdtrefsaida pctbprzmprod.pparametros.

    run processa.

message "FIM" today string(time,"HH:MM:SS").

procedure processa.


    for each ctbprzmprod where 
            ctbprzmprod.pparametros = pctbprzmprod.pparametros and
            ctbprzmprod.dtiniper     = pctbprzmprod.dtiniper and
            ctbprzmprod.dtfimper     = pctbprzmprod.dtfimper and
            ctbprzmprod.pstatus <> "PROCESSAR":
        delete ctbprzmprod.
    end.     

    do on error undo:
    
        find first ctbprzmprod where 
                    ctbprzmprod.pstatus = "PROCESSAR" and
                    ctbprzmprod.pparametros = pctbprzmprod.pparametros and
                    ctbprzmprod.dtiniper = pctbprzmprod.dtiniper and 
                    ctbprzmprod.dtfimper = pctbprzmprod.dtfimper and 
                    ctbprzmprod.campo = "TOTAL" and 
                    ctbprzmprod.valor = "" no-error. 
        if not avail ctbprzmprod
        then do:
            message "nao encontrei parametros".
            return.
        end.    
            
            ctbprzmprod.dtrefSAIDA = pdtrefSAIDA.
            ctbprzmprod.vlrPago    = 0.
            ctbprzmprod.qtdPC      = 0.
            ctbprzmprod.PrzMedio   = 0.
            ctbprzmprod.pstatus    = "PROCESSANDO".
            ctbprzmprod.dtiniproc  = pdtiniproc.
            ctbprzmprod.hriniproc  = phriniproc.
            ctbprzmprod.dtfimproc  = ?.
            ctbprzmprod.hrfimproc  = ?.

    end.

def var vconta as int init 0.
def var vmodcod as char.
def var vproduto as char.


def var vdias as int.
def var vfator as dec decimals 10 format ">>>>>>9.9999999999".
def var vperc as dec  decimals 10 format ">>>9.9999999999".
def var vcontat as int.                                            
pause 0 before-hide.
vconta = 0.
vcontat = 0.

/*for each ctbposhiscart where ctbposhiscart.dtrefsaida >= pdtrefini and ctbposhiscart.dtrefsaida <=  pdtrefSAIDA no-lock.*/

for each titulo where titulo.titnat = no and
                      titulo.titdtpag >= pdtrefini and titulo.titdtpag <= pdtrefSAIDA
        no-lock.
    if titulo.titsit <> "PAG"
    then next.    
    if titulo.modcod = "CRE" or
       titulo.modcod = "CP0" or
       titulo.modcod = "CP1" or
       titulo.modcod = "CPN"
    then.
    else next.
                                  

    vcontat = vcontat + 1.
    if vcontat mod 1000 = 0
    then do on error undo:
        find first ctbprzmprod where 
                    ctbprzmprod.pparametros = pctbprzmprod.pparametros and
                    ctbprzmprod.dtiniper = pctbprzmprod.dtiniper and 
                    ctbprzmprod.dtfimper = pctbprzmprod.dtfimper and 
                    ctbprzmprod.campo = "TOTAL" and 
                    ctbprzmprod.valor = "" no-error. 
        if not avail ctbprzmprod
        then do:
            create ctbprzmprod.        
            ctbprzmprod.pparametros = pctbprzmprod.pparametros.
            ctbprzmprod.dtiniper   = pctbprzmprod.dtiniper.
            ctbprzmprod.dtfimper   = pctbprzmprod.dtfimper.
            ctbprzmprod.campo      = "TOTAL".
            ctbprzmprod.valorcampo = "".
            ctbprzmprod.dtrefSAIDA = pdtrefSAIDA.
            ctbprzmprod.vlrPago    = 0.
            ctbprzmprod.qtdPC      = 0.
            ctbprzmprod.PrzMedio   = 0.
            ctbprzmprod.dtinc      = today.
            ctbprzmprod.hrinc      = time.
            ctbprzmprod.dtiniproc  = pdtiniproc.
            ctbprzmprod.hriniproc  = phriniproc.
            ctbprzmprod.dtfimproc  = ?.
            ctbprzmprod.hrfimproc  = ?.
        end.  
        ctbprzmprod.hrfimproc  = time.
        ctbprzmprod.pstatus    = "PROCESSANDO".
    end.    

        if titulo.titdtpag <> ?
        then do:
            if titulo.titdtpag >= pctbprzmprod.dtiniper and
               titulo.titdtpag <= pctbprzmprod.dtfimper
            then.
            else do:
                next.
            end.    
        end.
        else do:
            next.
        end.    

    /**end.
    else do:
        next.
    end. **/   

    vconta = vconta + 1.
    if vconta mod 1000 = 0 or vconta = 1
    then do:
        hide message no-pause.
        message color normal "fazendo calculos... aguarde...   registros="  vconta " tempo="  string(time - phriniproc,"HH:MM:SS")
           pctbprzmprod.dtiniper pctbprzmprod.dtfimper pdtrefini pdtrefsaida pctbprzmprod.pparametros.

    end.

    do:
        find first ctbprzmprod where 
                    ctbprzmprod.pparametros = pctbprzmprod.pparametros and
                    ctbprzmprod.dtiniper = pctbprzmprod.dtiniper and 
                    ctbprzmprod.dtfimper = pctbprzmprod.dtfimper and 
                    ctbprzmprod.campo = "TOTAL" and 
                    ctbprzmprod.valor = "" no-error. 
        if not avail ctbprzmprod
        then do:
            create ctbprzmprod.        
            ctbprzmprod.pparametros = pctbprzmprod.pparametros.
            ctbprzmprod.dtiniper   = pctbprzmprod.dtiniper.
            ctbprzmprod.dtfimper   = pctbprzmprod.dtfimper.
            ctbprzmprod.campo      = "TOTAL".
            ctbprzmprod.valorcampo = "".
            ctbprzmprod.dtrefSAIDA = pdtrefSAIDA.
            ctbprzmprod.vlrPago    = 0.
            ctbprzmprod.qtdPC      = 0.
            ctbprzmprod.PrzMedio   = 0.
            ctbprzmprod.dtinc      = today.
            ctbprzmprod.hrinc      = time.
            ctbprzmprod.dtiniproc  = pdtiniproc.
            ctbprzmprod.hriniproc  = phriniproc.
            ctbprzmprod.dtfimproc  = ?.
            ctbprzmprod.hrfimproc  = ?.
        end.  
        ctbprzmprod.hrfimproc  = time.
        ctbprzmprod.pstatus    = "PROCESSANDO".
        ctbprzmprod.qtdpc     = ctbprzmprod.qtdpc     + 1.
        ctbprzmprod.vlrPago   = ctbprzmprod.vlrPago + titulo.titvlcob /*ctbposhiscart.valorSAIDA*/ .
    end.
   
    if lookup("PROPRIEDADE",pctbprzmprod.pparametros) > 0
    then do:
        find cobra where cobra.cobcod = titulo.cobcod /*ctbposhiscart.cobcod*/ no-lock.
        find first ctbprzmprod where 
                    ctbprzmprod.pparametros = pctbprzmprod.pparametros and
                    ctbprzmprod.dtiniper = pctbprzmprod.dtiniper and 
                    ctbprzmprod.dtfimper = pctbprzmprod.dtfimper and 
                    ctbprzmprod.campo = "PROPRIEDADE" and 
                    ctbprzmprod.valorCampo = string(titulo.cobcod,"99") + "-" + caps(cobra.cobnom) no-error. 
        if not avail ctbprzmprod
        then do:
            create ctbprzmprod.        
            ctbprzmprod.pparametros = pctbprzmprod.pparametros.
            ctbprzmprod.dtiniper   = pctbprzmprod.dtiniper.
            ctbprzmprod.dtfimper   = pctbprzmprod.dtfimper.
            ctbprzmprod.campo      = "PROPRIEDADE".
            ctbprzmprod.valorcampo = string(titulo.cobcod,"99") + "-" + caps(cobra.cobnom) .
            ctbprzmprod.dtrefSAIDA = pdtrefSAIDA.
            ctbprzmprod.vlrPago    = 0.
            ctbprzmprod.qtdPC      = 0.
            ctbprzmprod.PrzMedio   = 0.
            ctbprzmprod.dtinc      = today.
            ctbprzmprod.hrinc      = time.
            ctbprzmprod.dtiniproc  = pdtiniproc.
            ctbprzmprod.hriniproc  = phriniproc.
            ctbprzmprod.dtfimproc  = ?.
            ctbprzmprod.hrfimproc  = ?.
        end.  
        ctbprzmprod.hrfimproc  = time.
        ctbprzmprod.pstatus    = "PROCESSANDO".
        ctbprzmprod.qtdpc     = ctbprzmprod.qtdpc     + 1.
        ctbprzmprod.vlrPago   = ctbprzmprod.vlrPago + titulo.titvlcob /*ctbposhiscart.valorSAIDA*/ .

    end.
      
    if lookup("FILIAL",pctbprzmprod.pparametros) > 0
    then do:
        find first ctbprzmprod where 
                    ctbprzmprod.pparametros = pctbprzmprod.pparametros and
                    ctbprzmprod.dtiniper = pctbprzmprod.dtiniper and 
                    ctbprzmprod.dtfimper = pctbprzmprod.dtfimper and 
                    ctbprzmprod.campo = "FILIAL" and 
                    ctbprzmprod.valor = string(titulo.etbcod,"9999") no-error. 
        if not avail ctbprzmprod
        then do:
            create ctbprzmprod.        
            ctbprzmprod.pparametros = pctbprzmprod.pparametros.
            ctbprzmprod.dtiniper   = pctbprzmprod.dtiniper.
            ctbprzmprod.dtfimper   = pctbprzmprod.dtfimper.
            ctbprzmprod.campo      = "FILIAL".
            ctbprzmprod.valorcampo = string(titulo.etbcod,"9999").
            ctbprzmprod.dtrefSAIDA = pdtrefSAIDA.
            ctbprzmprod.vlrPago    = 0.
            ctbprzmprod.qtdPC      = 0.
            ctbprzmprod.PrzMedio   = 0.
            ctbprzmprod.dtinc      = today.
            ctbprzmprod.hrinc      = time.
            ctbprzmprod.dtiniproc  = pdtiniproc.
            ctbprzmprod.hriniproc  = phriniproc.
            ctbprzmprod.dtfimproc  = ?.
            ctbprzmprod.hrfimproc  = ?.
        end.  
        ctbprzmprod.hrfimproc  = time.
        ctbprzmprod.pstatus    = "PROCESSANDO".
        ctbprzmprod.qtdpc     = ctbprzmprod.qtdpc     + 1.
        ctbprzmprod.vlrPago   = ctbprzmprod.vlrPago + titulo.titvlcob /*ctbposhiscart.valorSAIDA*/ .

    end.
    
    if lookup("MODALIDADE",pctbprzmprod.pparametros) > 0
    then do:
        vmodcod = if titulo.tpcontrato <> "" and titulo.modcod = "CRE"  then "CR" + titulo.tpcontrato else titulo.modcod.    
    
        find first ctbprzmprod where 
                    ctbprzmprod.pparametros = pctbprzmprod.pparametros and
                    ctbprzmprod.dtiniper = pctbprzmprod.dtiniper and 
                    ctbprzmprod.dtfimper = pctbprzmprod.dtfimper and 
                    ctbprzmprod.campo = "MODALIDADE" and 
                    ctbprzmprod.valor = vmodcod no-error. 
        if not avail ctbprzmprod
        then do:
            create ctbprzmprod.        
            ctbprzmprod.pparametros = pctbprzmprod.pparametros.
            ctbprzmprod.dtiniper   = pctbprzmprod.dtiniper.
            ctbprzmprod.dtfimper   = pctbprzmprod.dtfimper.
            ctbprzmprod.campo      = "MODALIDADE".
            ctbprzmprod.valorcampo = vmodcod.
            ctbprzmprod.dtrefSAIDA = pdtrefSAIDA.
            ctbprzmprod.vlrPago    = 0.
            ctbprzmprod.qtdPC      = 0.
            ctbprzmprod.PrzMedio   = 0.
            ctbprzmprod.dtinc      = today.
            ctbprzmprod.hrinc      = time.
            ctbprzmprod.dtiniproc  = pdtiniproc.
            ctbprzmprod.hriniproc  = phriniproc.
            ctbprzmprod.dtfimproc  = ?.
            ctbprzmprod.hrfimproc  = ?.
        end.  
        ctbprzmprod.hrfimproc  = time.
        ctbprzmprod.pstatus    = "PROCESSANDO".
        ctbprzmprod.qtdpc     = ctbprzmprod.qtdpc     + 1.
        ctbprzmprod.vlrPago   = ctbprzmprod.vlrPago + titulo.titvlcob /*ctbposhiscart.valorSAIDA*/ .

    end.

    if lookup("PRODUTO",pctbprzmprod.pparametros) > 0
    then do: 
        /*if ctbposhiscart.produto = ""
        then do: */
        
            find ctbpostitprod where ctbpostitprod.contnum = int(titulo.titnum) no-lock no-error.
            vproduto = if avail ctbpostitprod then ctbpostitprod.produto else "NAO CONHECIDO".
            if vproduto = "DESCONHECIDO" and titulo.tpcontrato <> "" then vproduto = titulo.tpcontrato + "OVACAO".
        /*end.
        else do:
            vproduto = ctbposhiscart.produto.
            if vproduto = "DESCONHECIDO" and ctbposhiscart.tpcontrato <> "" then vproduto = ctbposhiscart.tpcontrato + "OVACAO".
        end. */

        find first ctbprzmprod where 
                    ctbprzmprod.pparametros = pctbprzmprod.pparametros and
                    ctbprzmprod.dtiniper = pctbprzmprod.dtiniper and 
                    ctbprzmprod.dtfimper = pctbprzmprod.dtfimper and 
                    ctbprzmprod.campo = "PRODUTO" and 
                    ctbprzmprod.valor = vproduto no-error. 
        if not avail ctbprzmprod
        then do:
            create ctbprzmprod.        
            ctbprzmprod.pparametros = pctbprzmprod.pparametros.
            ctbprzmprod.dtiniper   = pctbprzmprod.dtiniper.
            ctbprzmprod.dtfimper   = pctbprzmprod.dtfimper.
            ctbprzmprod.campo      = "PRODUTO".
            ctbprzmprod.valorcampo = vproduto.
            ctbprzmprod.dtrefSAIDA = pdtrefSAIDA.
            ctbprzmprod.vlrPago    = 0.
            ctbprzmprod.qtdPC      = 0.
            ctbprzmprod.PrzMedio   = 0.
            ctbprzmprod.dtinc      = today.
            ctbprzmprod.hrinc      = time.
            ctbprzmprod.dtiniproc  = pdtiniproc.
            ctbprzmprod.hriniproc  = phriniproc.
            ctbprzmprod.dtfimproc  = ?.
            ctbprzmprod.hrfimproc  = ?.
        end.  
        ctbprzmprod.hrfimproc  = time.
        ctbprzmprod.pstatus    = "PROCESSANDO".
        ctbprzmprod.qtdpc     = ctbprzmprod.qtdpc     + 1.
        ctbprzmprod.vlrPago   = ctbprzmprod.vlrPago + titulo.titvlcob /*ctbposhiscart.valorSAIDA*/ .

    end.
    
    
end.

   def var varq as char format "x(76)".
   def var vcp  as char init ";".

varq = "/admcom/tmp/ctb/przmed" + lc(replace(ctbprzmprod.pparametros," ","")) +
                                   string(ctbprzmprod.dtiniproc,"99999999") + "_" + 
                                   string(ctbprzmprod.dtiniper,"99999999") + "_" + 
                                   string(ctbprzmprod.dtfimper,"99999999")  +
                             ".csv" .
output stream csv to value(varq).

        put stream csv unformatted
        "Produto" vcp
        "Filial"   vcp
        "DataMov"  vcp
        "Contrato" vcp
        "Emissao" vcp
        "Parcela" vcp
        "Vencimento" vcp
        "propriedade" vcp
        "modalidade"  vcp
        "Vlr Nominal" vcp
        "Vlr Juros" vcp
        "Vlr Desconto" vcp
        "Vlr Movimento" vcp                       
        "cliente" vcp 
        "codigoPedido-Ecom" vcp
        
            skip.        
    
for each titulo where titulo.titnat = no and
                      titulo.titdtpag >= pdtrefini and titulo.titdtpag <= pdtrefSAIDA
        no-lock.
    if titulo.titsit <> "PAG"
    then next.    
    if titulo.modcod = "CRE" or
       titulo.modcod = "CP0" or
       titulo.modcod = "CP1" or
       titulo.modcod = "CPN"
    then.
    else next.

            
    vdias = titulo.titdtpag - titulo.titdtemi.

        vconta = vconta - 1.
        if vconta mod 1000 = 0 
        then do:
            hide message no-pause.
            message color normal "fazendo calculos... aguarde...   registros="  vconta " tempo="  string(time - phriniproc,"HH:MM:SS")
               pctbprzmprod.dtiniper pctbprzmprod.dtfimper pdtrefini pdtrefsaida pctbprzmprod.pparametros.
        end.

        for each ctbprzmprod where 
            ctbprzmprod.pparametros = pctbprzmprod.pparametros and
            ctbprzmprod.dtiniper = pctbprzmprod.dtiniper and
            ctbprzmprod.dtfimper = pctbprzmprod.dtfimper:

                vperc = titulo.titvlcob  /*lctbposhiscart.valorSAIDA*/ / ctbprzmprod.vlrPago.
                vfator = vdias * vperc.
                ctbprzmprod.przMed = ctbprzmprod.przMed + vfator.
                ctbprzmprod.hrfimproc  = time.
                ctbprzmprod.pstatus    = "PROCESSANDO".
    
        end.        
        find cobra of titulo no-lock.
        find modal of titulo no-lock. 
        find first contrsite where contrsite.contnum = int(titulo.titnum)  no-lock no-error.

            find ctbpostitprod where ctbpostitprod.contnum = int(titulo.titnum) no-lock no-error.
            vproduto = if avail ctbpostitprod then ctbpostitprod.produto else "NAO CONHECIDO".
            if vproduto = "DESCONHECIDO" and titulo.tpcontrato <> "" then vproduto = titulo.tpcontrato + "OVACAO".
    
        put stream csv unformatted
        vproduto        vcp
        titulo.etbcod   vcp
        titulo.titdtpag format "99/99/9999" vcp
        titulo.titnum vcp
        titulo.titdtemi vcp
        titulo.titpar vcp
        titulo.titdtven  vcp
        string(titulo.cobcod,"99") + "-" + caps(cobra.cobnom) vcp
        modal.modnom  vcp
        titulo.titvlcob vcp
        if titulo.titvlpag > titulo.titvlcob then titulo.titvlpag - titulo.titvlcob else 0   vcp
        0         vcp
        titulo.titvlpag            vcp
        titulo.clifor  vcp
            (if avail contrsite
             then contrsite.codigoPedido
             else "" ) vcp
        
            skip.        
    
end.

output stream csv close.


for each ctbprzmprod where 
            ctbprzmprod.pparametros = pctbprzmprod.pparametros and
            ctbprzmprod.dtiniper = pctbprzmprod.dtiniper and
            ctbprzmprod.dtfimper = pctbprzmprod.dtfimper:

    ctbprzmprod.dtfimproc  = today.
    ctbprzmprod.hrfimproc  = time.
    ctbprzmprod.pstatus    = "PRONTO".

end.


end procedure.
