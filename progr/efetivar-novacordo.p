{admcab.i}

def input parameter p-recid as recid.
def output parameter ret-ok as log.

ret-ok = no.
find novacordo where recid(novacordo) = p-recid no-lock no-error.
if not avail novacordo then return.

def temp-table wf-contrato like contrato.
def temp-table wf-titulo like titulo.

def var vtot as dec.
def var ventrada as dec.
def var vvezes as int.
assign
    vtot = novacordo.valor_acordo
    ventrada = novacordo.valor_entrada
    vvezes = novacordo.qtd_parcelas
    .

if ventrada > 0
then vvezes = vvezes + 1.

find clien where clien.clicod = novacordo.clicod no-lock no-error.

def var vgera like geranum.contnum.
do for geranum on error undo on endkey undo:
    find geranum where geranum.etbcod = setbcod exclusive.
    vgera = geranum.contnum.
    geranum.contnum = geranum.contnum + 1.
    find current geranum no-lock.
end.


do on error undo:
    create wf-contrato.

    if setbcod >= 100
    then wf-contrato.contnum =  int("1" + string(setbcod,"999") +
                                          string(vgera,"999999")).
    else wf-contrato.contnum = int(string(string(vgera,"99999999") +
                                   string(setbcod,"99"))).

    assign wf-contrato.clicod    = clien.clicod
           wf-contrato.dtinicial = today 
           wf-contrato.etbcod    = setbcod 
           wf-contrato.datexp    = today 
           wf-contrato.vltotal   = vtot 
           wf-contrato.vlentra   = ventrada.
    
end.     
   
def var vdata as date init today.
if setbcod < 200
then run gera-novacao.p(input clien.clicod,
                   input vtot,
                   input ventrada,
                   input vvezes,
                   input novacordo.destino,
                   input novacordo.tipnova,
                   input vdata).
else do:
    bell.
    message color red/with
    "Novação somente na filial."
    view-as alert-box.
end.
/*****************
   
    /*******************************  ENTRADA *************************/

do on error undo: 
    create wf-titulo.
    assign wf-titulo.empcod = wempre.empcod
               wf-titulo.modcod = "CRE"
               wf-titulo.cxacod = scxacod
               wf-titulo.cliFOR = clien.clicod
               wf-titulo.titnum = string(wf-contrato.contnum) 
               wf-titulo.titpar = 0
               wf-titulo.titnat = no
               wf-titulo.etbcod = setbcod
               wf-titulo.titdtemi = today
               wf-titulo.titdtven = today
               wf-titulo.titvlcob = ventrada
               wf-titulo.titvlcob = ventrada
               wf-titulo.cobcod = 2
               wf-titulo.titsit = "LIB"
               wf-titulo.datexp = today
               .

        down with frame f4.
        display  wf-titulo.titpar column-label "PC"
                 wf-titulo.titnum column-label "Contrato"
                 wf-titulo.titdtemi column-label "Emissao"
                 wf-titulo.titdtven column-label "Vencimento"
                 wf-titulo.titvlcob format ">,>>>,>>9.99"
                 wf-titulo.titsit 
                        column-label "Vl.Cob" with frame f4 down centered
                 title " Pagar Entrada na tela de Caixa ".
        down with frame f4.
        
end.

    /******** PARCELAS ***********************************************/

def var nov31 as log init yes.
def var wcon as int.
def var vday as int.
def var vmes as int.
def var vano as int.    
def var vdata as date.    
vdata = today.
    
if nov31
then wcon = 30.
else wcon = 50.

assign
    vdata = today
    vday = day(vdata)
    vtot = vtot - ventrada
    vmes = month(vdata)
    vano = year(vdata)
    .
    
if vmes = 1
then assign vmes = 12
                vano = year(vdata) - 1.
else assign vmes = month(vdata) - 1
                vano = year(vdata).
    
assign
    vdata = date(vmes,day(vdata),vano) 
    vano = year(vdata).
   
def var i as int.
    
do i = 1 to vvezes - 1:
                      
    
    assign wcon = wcon + 1
           vmes = vmes + 1.
                 
    if vmes > 12 
    then assign vano = vano + 1
                vmes = 1.
        
    create wf-titulo.
    assign wf-titulo.empcod = wempre.empcod
                   wf-titulo.modcod = "CRE"
                   wf-titulo.cxacod = scxacod
                   wf-titulo.cliFOR = clien.clicod
                   wf-titulo.titnum = string(wf-contrato.contnum) 
                   wf-titulo.titpar = wcon
                   wf-titulo.titnat = no
                   wf-titulo.etbcod = setbcod
                   wf-titulo.titdtemi = today
                   wf-titulo.titdtven = date(vmes,
                                        IF VMES = 2
                                        THEN IF VDAY > 28
                                             THEN 28
                                             ELSE VDAY
                                        ELSE if VDAY > 30
                                             then 30
                                             else vday,
                                        vano)

                   wf-titulo.titvlcob = vtot / ( vvezes - 1)
                   wf-titulo.cobcod = 2
                   wf-titulo.titsit = "LIB"
                   wf-titulo.datexp = today.

        
      down with frame f4.
        
      display  wf-titulo.titpar column-label "PC"
                 wf-titulo.titnum column-label "Contrato"
                 wf-titulo.titdtemi column-label "Emissao"
                 wf-titulo.titdtven column-label "Vencimento"
                 wf-titulo.titvlcob format ">,>>>,>>9.99"
                 wf-titulo.titsit
                        column-label "Vl.Cob" with frame f4 down centered.
        
      down with frame f4.
        
end.

for each wf-titulo where wf-titulo.empcod = 0:
    delete wf-titulo.
end.    
    
    for each wf-titulo where 
             wf-titulo.titpar = 0 no-lock:
        create titulo.
        assign titulo.empcod   = wf-titulo.empcod
                   titulo.modcod   = wf-titulo.modcod
                   titulo.clifor   = wf-titulo.clifor
                   titulo.titnum   = wf-titulo.titnum 
                   titulo.titpar   = wf-titulo.titpar 
                   titulo.titsit   = "PAG" 
                   titulo.titnat   = wf-titulo.titnat 
                   titulo.etbcod   = wf-titulo.etbcod 
                   titulo.titdtemi = wf-titulo.titdtemi 
                   titulo.titdtven = wf-titulo.titdtven 
                   titulo.titdtpag = today 
                   titulo.titvlcob = wf-titulo.titvlcob 
                   titulo.cobcod   = wf-titulo.cobcod 
                   titulo.titvlpag = wf-titulo.titvlcob 
                   titulo.titvljur = wf-titulo.titvljur 
                   titulo.etbcobra = wf-titulo.etbcod 
                   titulo.titjuro  = wf-titulo.titjuro 
                   titulo.titdesc  = wf-titulo.titdesc 
                   titulo.cxacod   = scxacod 
                   titulo.cxmdata  = today 
                   titulo.datexp   = today
                   titulo.moecod   = "REA".
    end.

    for each wf-titulo where wf-titulo.titpar <> 0 no-lock:
        create titulo.
        buffer-copy wf-titulo to titulo.
    end.    
    
    find first wf-contrato where
               wf-contrato.contnum > 0
               no-lock.
    create contrato.
    buffer-copy wf-contrato to contrato.
    
    find novacordo where recid(novacordo) = p-recid no-error.      
    assign
        novacordo.contnum = contrato.contnum
        novacordo.etb_efetiva = setbcod
        novacordo.user_efetivacao = sfuncod
        novacordo.dtefetivacao = today
        novacordo.horefetivacao = time
        novacordo.situacao = "EFETIVADO"
        .
         
    /************ PAGAMENTO DE PRESTACOES ANTIGAS *************/
    
    for each tit_novacao where
             tit_novacao.id_acordo = string(novacordo.id_acordo)
                :
        find titulo where titulo.empcod = tit_novacao.ori_empcod
                          and titulo.titnat = tit_novacao.ori_titnat
                          and titulo.modcod = tit_novacao.ori_modcod
                          and titulo.clifor = tit_novacao.ori_clifor
                          and titulo.etbcod = tit_novacao.ori_etbcod
                          and titulo.titnum = tit_novacao.ori_titnum
                          and titulo.titpar = tit_novacao.ori_titpar
                          and titulo.titdtemi = tit_novacao.ori_titdtemi
                          no-error.
        if avail titulo
        then do:
            assign titulo.titsit   = "PAG"
                   titulo.titdtpag = today
                   titulo.titvlpag = titulo.titvlcob
                   titulo.moecod   = "NOV"
                   titulo.cxacod   = scxacod
                   titulo.cxmdata  = today
                   titulo.etbcobra = setbcod
                   titulo.datexp   = today
                   .
        end.
        assign
            tit_novacao.ger_contnum = contrato.contnum
            tit_novacao.dtnovacao = today
            tit_novacao.hrnovacao = time
            tit_novacao.etbnovacao = setbcod
            tit_novacao.funcod = sfuncod
            tit_novacao.ori_titdtpag = today
            .
    end.    

**********************************/    
