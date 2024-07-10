/*#1 13.03 - Helio - Message das fases para o log */

{admcab-batch.i new}

/* Inicia a execução a partir das 06:00h da manhã */

if time < 21600 then return.

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/
/***************                                              *************/
/***************               ATENÇÃO!!!!!!                  *************/  
/***************                                              *************/
/***************                                              *************/
/***************   NUNCA COLOQUE ESSE PROGRAMA EM TRANSAÇÃO   *************/
/***************                                              *************/
/***************                                              *************/
/***************   SE FOR NECESSARIO GRAVAR EM BANCO REALIZE  *************/
/***************         A CHAMADA À OUTRO PROGRAMA           *************/
/***************              APARTIR DESSE.                  *************/
/***************                                              *************/
/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

def new shared temp-table tt-clien like cliecom
    field tppes     as char
    field protocolo as char
    index idx01 is primary unique cpfcgc.

def new shared temp-table dd-pedido no-undo
    field NumeroDoPedido as char
    field ProtocoloPedido as char
    field StatusPedido as char
    .

def new shared temp-table tt-pedid like pedid.
def new shared temp-table tt-liped like liped.

def new shared temp-table tt-movim like movim.
def new shared temp-table tt-plani like plani.

def var vtoday as date. /*#1*/
def var vtime  as int.  /*#1*/
vtoday = today.
vtime  = time.

message vtoday string(vtime,"HH:MM:SS") "1/7". /*#1*/
run /admcom/web/progr_e/busca_clifor_disp.p.

pause 0.

message  vtoday string(vtime,"HH:MM:SS") "2/7". /*#1*/
run /admcom/web/progr_e/confirma_receb_clifor.p.

pause 0.

message  vtoday string(vtime,"HH:MM:SS") "3/7". /*#1*/
/*run /admcom/web/progr_e/busca_ped_disp.p.*/
run /admcom/web/progr_e/busca_ped_disp_wsdl.p.

pause 0.

message  vtoday string(vtime,"HH:MM:SS") "4/7". /*#1*/
/*run /admcom/web/progr_e/confirma_receb_ped_cron.p.*/
run /admcom/web/progr_e/confirma_receb_ped_cron_wsdl.p.
pause 0.

message  vtoday string(vtime,"HH:MM:SS") "5/7". /*#1*/
run /admcom/web/progr_e/status_pedido_disponiveis_wsdl.p.
pause 0.

message  vtoday string(vtime,"HH:MM:SS") "6/7". /*#1*/
run /admcom/web/progr_e/busca_notas_disp.p.

pause 0.

message  vtoday string(vtime,"HH:MM:SS") "7/7". /*#1*/
run /admcom/web/progr_e/confirma_receb_nota_fiscal.p.

pause 0.

message  vtoday string(vtime,"HH:MM:SS") "FIM/7". /*#1*/

leave.
 
