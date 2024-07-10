/* Relatorio Lote Access */
{admcab.i}

def input parameter par-reclotcre  as recid.

def var vtitnumnovo     like titulo.titnum.
def var vtitulo         as char.
def var vtotvlpag       like titulo.titvlpag.
def var vtotvlcob       like titulo.titvlcob.
def var vdiasatraso     as int.
def var vclfnom         as char format "x(30)".
def var vcgccpf         as char.
def var vclfcod         as int.
def var vsaldo          like titulo.titvlcob.
def var vok             as int.
def var vnok            as int.
def var vgertot         as dec.
def var vgerven         as dec.
def var vvencido        as dec.
def var vsituacao       as log.
def var varquivo        as char.
def var vlrcomissao     as dec.
def var vcomissao       as dec.
def var vtotcomissao    as dec.
def buffer btitulo      for titulo.
def var vtotcli         as int.
def var vokcli          as int.
def var vnokcli         as int.
def var vcob            as char format "x(12)".
def var vatraso         as int.
def var vpct            as int.
def var vreneg          as char.
def var vtotjuros       as dec.
def var vtotdescontos   as dec.
def var ventradaren like fin.titulo.titvlpag.
def var vparcela as int.

form with frame f-linc down no-box.
find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

varquivo = "../relat/ltaccessrel" + string(time).
{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "121"
    &Page-Line = "66"
    &Nom-Rel   = ""CERRELINC""
    &Nom-Sis   = """BS"""
    &Tit-Rel   = "lotcretp.LtCreTNom + "" - LOTE "" +
                  string(lotcre.ltcrecod) + "" - "" + lotcre.ltselecao"
    &Width     = "280"
    &Form      = "frame f-cabcab"}

run conecta_d.p.
if connected ("d")
then do:
    run ltaccessrelpglp.p (input recid(lotcre), 
                            output vgertot, 
                            output vtotcomissao).
disp skip(3).
for each lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod
                   /*and lotcretit.titnum = "101329808" */
                   no-lock
                   break by lotcretit.titnum by lotcretit.clfcod.
    find fin.titulo where fin.titulo.empcod = wempre.empcod
                  and fin.titulo.titnat = lotcretp.titnat
                  and fin.titulo.modcod = lotcretit.modcod
                  and fin.titulo.etbcod = lotcretit.etbcod
                  and fin.titulo.clifor = lotcretit.clfcod
                  and fin.titulo.titnum = lotcretit.titnum
                  and fin.titulo.titpar = lotcretit.titpar
                no-lock no-error.
                
    vreneg = "".
    vtitnumnovo = "".
                
    if not avail fin.titulo then next.
    run clifor.
    find lotcreag of lotcretit no-lock.
    

    vsaldo = fin.titulo.titvlcob - fin.titulo.titvlpag.
    vsituacao = lotcreag.ltsituacao = yes /* clifor marcado */ and
                lotcreag.ltvalida   = ""  /* valido */   and
                lotcretit.ltsituacao      /* titulo marcado */.

    if fin.titulo.cobcod = 11 then vcob = "ok".
    else vcob = "sem retorno".
    vatraso = fin.titulo.titdtpag - fin.titulo.titdtven.
    run calcula-comissao (input vatraso , output vpct).
    
    for each btitulo where btitulo.empcod = 19
                      and  btitulo.titnat = no
                      and  btitulo.modcod = "CRE"
                      and  btitulo.etbcod = titulo.etbcod
                      and  btitulo.clifor = titulo.clifor
                      and  btitulo.titnum = titulo.titnum
                      no-lock break by btitulo.titnum by btitulo.titpar.

        if btitulo.etbcobra > 900 or btitulo.moecod = "NOV"
        then do:
            assign vreneg = "R".
            
            if btitulo.etbcobra > 900
            then vparcela = 51.
            else vparcela = 0 .
        end.
        else do:
            assign vreneg = "R".
        end.
        
    end. /*fin.btitulo*/
    
    
    if vreneg = "R"
    then do:
        run ltnovacoes.p (  input titulo.clifor, 
                            input titulo.titdtpag,
                            input titulo.titnum,
                            input vparcela,
                            output ventradaren, 
                            output vtitnumnovo ).
        
        if first-of(lotcretit.clfcod)
        then do:
        
        end.
        else do:
            ventradaren = 0.                
        end.                    

    end.
    else do:
        if fin.titulo.titvlpag > 0 
        then assign ventradaren = fin.titulo.titvlpag.
    end.

    vtitulo =  "C" + "-" + string(titulo.etbcod,"999") + "-" + titulo.titnum.
    vcomissao = (ventradaren * vpct / 100). 

    disp vsituacao no-label format "*/"
         space(0)
         "ACCESS"                               column-label "Codigo"
         /*
         {titnum.i}
         */
         vtitulo           format "x(20)"       column-label "Titulo"
         titulo.titpar     format "99"          column-label "Par"
         titulo.titdtven                        column-label "Dt.Venc"
         titulo.titdtpag                        column-label "Dt.Pagto"
         (titulo.titdtpag - titulo.titdtven) 
                           format "-9999"       column-label "Atr"                      /*titulo.titvlpag                      column-label "Valor Pago" */
         ventradaren       format ">>>,>>9.99"  column-label "Valor Pago"
         vpct              format "99"          column-label "Perc!Com"
         titulo.titjur     format ">,>>9.99"           column-label "Juros"
         0                 format ">,>>9.99"    column-label "Devolucao"
         0                 format ">,>>9.99"    column-label "PercDev"
         vcomissao                              column-label "Comissao"
         lotcretit.clfcod  format "9999999999"  column-label "Cliente"
         vclfnom           format "x(20)"       column-label "Nome Cliente" 
         lotcre.ltdtenvio                       column-label "Data Remes"
         titulo.titvlcob   format ">>>,>>9.99"  column-label "Valor Parcela"
         0                                      column-label "Vl.Multa"
         titulo.titdesc    format ">>>,>>9.99"  column-label "Desconto"
         vtitnumnovo       format "x(8)"    column-label "Nr.Recibo"
         vreneg            format "x(2)"        column-label "Reneg"
         "FIN"               column-label "Banco"
         with frame f-linc no-box width 280 down.
         down with frame f-linc.

    if vsituacao
    then assign
            vtotvlpag       = vtotvlpag         + titulo.titvlpag
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
end. /*lotcretit*/
disconnect d.
end.                     
hide message no-pause.

 

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
end. /*lotcreag*/       


down 1 with frame f-linc.
disp "Total LP"    @ vtitulo
     vtotvlpag     @ ventradaren
     vtotjuros     @ titulo.titjuro
     vtotvlcob     @ titulo.titvlcob
     vtotcomissao  @ vcomissao
     vtotdescontos @ titulo.titdesc     
     with frame f-linc.

if opsys = "UNIX"
then do:
    output close.
    run visurel.p (varquivo,"").
end.
else do:
    {mrod.i}
end.    


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

