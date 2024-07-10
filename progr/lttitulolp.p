/* Busca os titulos lp */
def shared temp-table tt-contrato
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
 
def shared temp-table tt-contratolp like fin.contrato.

def buffer btitulo for d.titulo.
def buffer ctitulo for d.titulo.

def var vtitvlpag like d.titulo.titvlpag.
def var vtotreg as int.
def var vltotal like d.contrato.vltotal.
def var vdtinicial like d.contrato.dtinicial.
def var vqtd-parcelas  as int.
def var vdtultimopag   as date.
def var vultimaparpag  as int.
def var vsaldocontrato like d.contrato.vltotal.
def var vspc     as char.  
def var vnumerocontrato as int.
def var vvalorcontrato like d.contrato.vltotal.
def var vsaldo like d.contrato.vltotal.
def var vparcela as int.

def var vreneg as char.
def var vdtpag like d.titulo.titdtpag.

/* busca todos os titulos dos contratos */
for each tt-contrato 
break by tt-contrato.numerotitulo.


    
    vtotreg = vtotreg + 1. 
    vqtd-parcelas  = 0.
    vdtultimopag   = ?.
    vultimaparpag  = 0.
    vsaldocontrato = 0.
    vvalorcontrato = 0.
    vsaldo         = 0.
    vspc = "N".

    find d.clispc where d.clispc.clicod  = tt-contrato.codigocliente and
                      d.clispc.contnum = int(tt-contrato.numerotitulo)
                      no-lock no-error.

    if avail d.clispc 
    then do:
        if d.clispc.dtcanc = ?
        then vspc = "S".
    end.

    vreneg = "".
    vtitvlpag = 0.
    vparcela = 0.
    

    for each d.titulo where d.titulo.empcod = 19
                      and d.titulo.titnat = no
                      and d.titulo.modcod = "CRE"
                      and d.titulo.etbcod = tt-contrato.etbcod
                      and d.titulo.clifor = tt-contrato.codigocliente
                      and d.titulo.titnum = tt-contrato.numerotitulo
                      no-lock break by titulo.titnum.
        


        vvalorcontrato = vvalorcontrato + d.titulo.titvlcob.
        vqtd-parcelas = vqtd-parcelas + 1.

        if d.titulo.titdtpag <> ?  
        then vsaldocontrato = vsaldocontrato +  d.titulo.titvlcob.
        
        if vsaldocontrato < 0 then vsaldocontrato = 0.
        
        if d.titulo.titdtpag <> ?
        then assign tt-contrato.dataultpagamento = d.titulo.titdtpag.
        
        for each btitulo where 
                         btitulo.empcod         =  d.titulo.empcod    and
                         btitulo.titnat         =  d.titulo.titnat    and
                         btitulo.modcod         =  d.titulo.modcod    and
                         btitulo.etbcod         =  d.titulo.etbcod    and
                         btitulo.clifor         =  d.titulo.clifor    and
                         btitulo.titnum         =  d.titulo.titnum
                         no-lock.


            if btitulo.moecod = "NOV" or btitulo.etbcobra > 90
            then do:
                assign vreneg = "R".
                assign vdtpag = btitulo.titdtpag.
                if btitulo.etbcobra > 90
                then vparcela = 51.
                else vparcela =  0.
                
            end.
        end.

         
    end. /*d.titulo*/

    
    if vreneg = "R" 
    then do:
        for each ctitulo where  ctitulo.clifor = tt-contrato.codigocliente and 
                                ctitulo.titdtemi = vdtpag           and
                                ctitulo.titnum <> d.titulo.titnum   
                                no-lock.
                                
            vtitvlpag = vtitvlpag + ctitulo.titvlpag.
        end.
    end.
    
    vsaldo = vvalorcontrato - vsaldocontrato.
    if vsaldo <= 0 then vsaldo = 0.
    
    if vsaldo = 0 
    then assign tt-contrato.tipooper = "R".

    assign tt-contrato.valorcontrato      = vvalorcontrato.
    assign tt-contrato.qtdparcelascontr   = vqtd-parcelas.                     
    assign tt-contrato.saldocontrato      = vsaldo.
    assign tt-contrato.constaspc          = vspc.
    
    if vreneg = "R"
    then do:
        assign tt-contrato.vlrentcontrreneg   = vtitvlpag.

    end.
end.

