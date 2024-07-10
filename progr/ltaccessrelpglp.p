/* Relatorio dos pagamentos de titulos lp */
{admcab.i}


def input parameter par-reclotcre  as recid.
def output parameter vgertot as dec.
def output parameter vtotcomissao as dec.

def buffer etitulo for d.titulo.
def var vnovotitulo     like d.titulo.titnum.
def var vtitvlpag       like d.titulo.titvlpag.
def var vdtpag          like d.titulo.titdtpag.
def var vtotvlpag       like d.titulo.titvlpag.
def var vtotvlcob       like d.titulo.titvlcob.
def var vdiasatraso   as int.
def var vclfnom     as char format "x(30)".
def var vcgccpf     as char.
def var vclfcod     as int.
def var vsaldo      like d.titulo.titvlcob.
def var vok         as int.
def var vnok        as int.
def var vgerven     as dec.
def var vvencido    as dec.
def var vsituacao   as log.
def var varquivo    as char.
def var vlrcomissao as dec.
def var vcomissao   as dec.
def buffer btitulo for d.titulo.
def var vtotcli    as int.
def var vokcli     as int.
def var vnokcli    as int.
def var vcob as char format "x(12)".
def var vatraso as int.
def var vpct    as int.
def var vreneg  as char.
def var vtitulo as char.
def var vtotjuros       as dec.
def var vtotdescontos   as dec.
def var vparcela as int.
def buffer ctitulo for d.titulo.

form with frame f-linc down no-box.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

/* BUSCA TODOS OS TITULOS DO LOTE E VERIFICA QUAIS SAO OS TITULOS LP */

for each lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod 
                   /*
                   and lotcretit.titnum = "24573272" or  and
                       lotcretit.titnum = "105156208"
                   and lotcretit.titnum = "92805508"
                   */
                   no-lock
                   break by lotcretit.titnum by lotcretit.clfcod.
    find d.titulo where d.titulo.empcod = wempre.empcod
                  and d.titulo.titnat = lotcretp.titnat
                  and d.titulo.modcod = lotcretit.modcod
                  and d.titulo.etbcod = lotcretit.etbcod
                  and d.titulo.clifor = lotcretit.clfcod
                  and d.titulo.titnum = lotcretit.titnum
                  and d.titulo.titpar = lotcretit.titpar
                no-lock no-error.


    if not avail d.titulo then next.
    run clifor.
    
    find lotcreag of lotcretit no-lock.

    vreneg = "".
    vnovotitulo = "".
    vtitvlpag   = 0.
    vparcela = 0.
    
    vsaldo = d.titulo.titvlcob - d.titulo.titvlpag.
    vsituacao = lotcreag.ltsituacao = yes /* clifor marcado */ and
                lotcreag.ltvalida   = ""  /* valido */   and
                lotcretit.ltsituacao      /* titulo marcado */.

    if d.titulo.cobcod = 11 then vcob = "ok".
    else vcob = "sem retorno".
    
    vatraso = d.titulo.titdtpag - d.titulo.titdtven.
    run calcula-comissao (input vatraso , output vpct).
    
    for each btitulo where btitulo.empcod = 19
                      and  btitulo.titnat = no
                      and  btitulo.modcod = "CRE"
                      and  btitulo.etbcod = d.titulo.etbcod
                      and  btitulo.clifor = d.titulo.clifor
                      and  btitulo.titnum = d.titulo.titnum
                      no-lock break by btitulo.titnum.
                      
        if btitulo.etbcobra > 90 or btitulo.moecod = "NOV"
        then do: 
            assign vreneg = "R".
            assign vdtpag = btitulo.titdtpag.
            
            if btitulo.etbcobra > 90
            then vparcela = 51.
            else vparcela = 0.
        end.
        
                  
                           
    end.


    /* busca o novo contrato */
    if vreneg = "R"
    then do:
        for each ctitulo where  ctitulo.clifor = d.titulo.clifor    and 
                                ctitulo.titdtemi = vdtpag           and
                                ctitulo.titnum <> d.titulo.titnum   and
                                ctitulo.titdtpag <> ?
                                no-lock.
                                
            assign vtitvlpag = vtitvlpag + ctitulo.titvlpag.
            vnovotitulo = ctitulo.titnum.
        end.

        if not first-of(lotcretit.titnum)
        then do:
            vtitvlpag = 0.
        end.

    end.
    else do:
        vtitvlpag = d.titulo.titvlpag.
    end.    

    
    vtitulo =  "C" + "-" + string(d.titulo.etbcod,"999") + "-" 
                + d.titulo.titnum.
     
    vcomissao = (vtitvlpag * vpct / 100) . 
    disp vsituacao no-label format "*/"
         space(0)
         "ACCESS"                               column-label "Codigo"
         /*
         {titnum.i}
         */
         vtitulo           format "x(20)"       column-label "Titulo"
         d.titulo.titpar     format "99"        column-label "Par"
         d.titulo.titdtven                        column-label "Dt.Venc"
         d.titulo.titdtpag                        column-label "Dt.Pagto"
         (d.titulo.titdtpag - d.titulo.titdtven) 
                           format "-9999"       column-label "Atr"                      /*
         d.titulo.titvlpag   format ">>>,>>9.99"  column-label "Valor Pago" 
         */
         vtitvlpag           format ">>>,>>9.99"  column-label "Valor Pago" 
         vpct                format "99"          column-label "Perc!Com"
         d.titulo.titjur     format ">,>>9.99"    column-label "Juros"
         0                   format ">,>>9.99"    column-label "Devolucao"
         0                   format ">,>>9.99"    column-label "PercDev"
         vcomissao                                column-label "Comissao"
         lotcretit.clfcod    format "9999999999"  column-label "Cliente"
         vclfnom             format "x(20)"       column-label "Nome Cliente" 
         lotcre.ltdtenvio                         column-label "Data Remes"
         d.titulo.titvlcob   format ">>>,>>9.99"  column-label "Valor Parcela"
         0                                        column-label "Vl.Multa"
         d.titulo.titdesc    format ">>>,>>9.99"  column-label "Desconto"
         vnovotitulo         format "99999999"    column-label "Nr.Recibo"
         vreneg              format "x(2)"        column-label "Reneg"

         /*
         d.titulo.titdtven
         d.titulo.titdtpag
         (d.titulo.titdtpag - d.titulo.titdtven) format "-9999"
                                               column-label "Atr"              
         d.titulo.titvlpag
         vpct              format "99"          column-label "Perc!Com"
         d.titulo.titjur
         0                                      column-label "Devolucao"
         0                                      column-label "PercDev"
         vcomissao                              column-label "Comissao"
         lotcretit.clfcod   format "9999999999" column-label "Cliente"
         vclfnom            format "x(20)"      column-label "Nome Cliente" 
         lotcre.ltdtenvio                       column-label "Data Remes"
         d.titulo.titvlcob                      column-label "Valor Parcela"
         0                                      column-label "Vl.Multa"
         d.titulo.titdesc                       column-label "Desconto"
         0                                      column-label "Nr.Recibo"
         vreneg                                 column-label "Reneg"
         */
         "LP"                                   column-label "Banco"
         with frame f-linc no-box width 260 down.
    down with frame f-linc.

 

    
    
    if vsituacao
    then assign
            vtotvlpag       = vtotvlpag         + vtitvlpag
            vtotvlcob       = vtotvlcob         + titulo.titvlcob
            vtotjuros       = vtotjuros         + titulo.titjuro
            vtotcomissao    = vtotcomissao      + vcomissao 
            vtotjuros       = vtotjuros         + titulo.titvljur
            vok             = vok               + 1
            vgertot         = vgertot           + vsaldo
            vgerven         = vgerven           + vvencido
            vtotdescontos   = vtotdescontos     + titulo.titdesc.
    else assign
            vnok    = vnok + 1.

end.
for each lotcreag of lotcre no-lock.
        vtotcli = vtotcli + 1.
        if lotcreag.ltsituacao = yes /* clifor marcado */ and
        lotcreag.ltvalida   = ""  /* valido */ 
        then do:
            vokcli = vokcli + 1.
        end.
        else do:
            vnokcli = vnokcli + 1.
        end.
end.        

down 1 with frame f-linc.
disp "Total FIN" @ vtitulo
     vtotvlpag   @ vtitvlpag
     vtotjuros   @ d.titulo.titjuro
     vtotvlcob   @ d.titulo.titvlcob
     vtotjuros   @ d.titulo.titjuro
     vtotcomissao @ vcomissao
     vtotdescontos @ d.titulo.titdesc     
     with frame f-linc.
 

procedure clifor.
    if lotcretp.titnat
    then do.
        find forne where forne.forcod = lotcretit.clfcod no-lock.
        assign
            vclfcod = forne.forcod
            vcgccpf = forne.forcgc
            vclfnom = forne.fornom.
    end.
    else do.
        find clien where clien.clicod = lotcretit.clfcod no-lock no-error.
        if avail clien then
        assign
            vclfcod = clien.clicod
            vcgccpf = clien.ciinsc
            vclfnom = clien.clinom.
    end.
end.

procedure calcula-comissao.
def input  parameter par-dias  as int.
def output parameter vcomissao as dec.

if par-dias > 0 and par-dias <= 30
then
    assign 
        vcomissao   = 6.

if par-dias > 31 and par-dias <= 60
then 
    assign 
        vcomissao = 8.

if par-dias > 61 and par-dias <= 90
then 
    assign 
        vcomissao   = 11.

if par-dias > 91 and par-dias <= 120
then 
    assign
        vcomissao   = 14.

if par-dias > 121 and par-dias <= 180
then
    assign 
        vcomissao = 18.

if par-dias > 181 and par-dias <= 360
then 
    assign 
    vcomissao = 20.

if par-dias >= 361
then 
    assign 
        vcomissao = 23.



end.

