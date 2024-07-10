{admcab.i}
{admcom_funcoes.i}
def workfile wacum
    field mes as int format "99"
    field ano as int format "9999"
    field acum       like plani.platot.

/*********** DATA DA ULTIMA COMPRA                       ***************/
/*********** LIMITE DE CREDITO DO CADASTRO               ***************/
/*********** QUANTIDADE DE CONTRATO                      ***************/
/*********** QTD DE PARCELAS                             ***************/
/*********** QTD DE PARCELAS PAGAS MENOS DE 15 DE ATRASO ***************/
/*********** QTD DE PARCELAS PAGAS DE 16 ATE 45 DIAS     ***************/
/*********** QTD DE PARCELAS ACIMA DE 46 DIAS            ***************/
/*********** SE TEM REPARCELAMENTO   (SIM/NAO)           ***************/
/*********** MAIOR ACUMULO MENSAL (VALOR / MES E ANO)    ***************/
/*********** SALDO EM ABERTO                             ***************/
/*********** MEDIA DE PRESTACOES LIQUIDADAS              ***************/
/*********** PRESTACOES DO PROXIMO MES                   ***************/


def var maior-atraso like plani.pladat.
def var vencidas like clien.limcrd.
def var v-mes as int format "99".
def var v-ano as int format "9999".
def var v-acum like clien.limcrd.
def var qtd-contrato as int format ">>>9".
def var parcela-paga    as int format ">>>>9".
def var parcela-aberta  as int format ">>>>9".
def var qtd-15       as int format ">>>>9".
def var qtd-45       as int format ">>>>9".
def var qtd-46       as int format ">>>>9".
def var vrepar       as log format "Sim/Nao".
def var v-media      like clien.limcrd.
def var ult-compra   like plani.pladat.
def var sal-aberto   like clien.limcrd.
def var lim-calculado like clien.limcrd format "->>,>>9.99".
/***def var vclicod like clien.clicod.***/
def var scli like clien.clicod.

def var vtotal like plani.platot.
def var vqtd   as int.
def var proximo-mes like clien.limcrd.
def var vdata1 like plani.pladat.
def var vdata2 like plani.pladat.
def var maior-credito-aberto as dec.
def var media-credito-aberto as dec.
def var limite-cred-scor as dec.


def var regua1      as char format "x(10)" extent /*8*/ 2
    initial ["Historico","" /*"Cadastro"*/ ].
                 
form regua1 with frame f-regua1
          row 19 no-labels side-labels column 1 centered title "Operacoes".


/***repeat: 
    hide frame f-regua1.
    ***/
def input parameter vclicod like clien.clicod.
    
    /***
    update vclicod label "Codigo" with frame f-cli side-label width 80.
    ***/
    find clien where clien.clicod = vclicod no-lock no-error.
/*    display clien.clinom no-label with frame f-cli.*/
 

for each wacum:
    delete wacum.
end.


qtd-contrato = 0.
ult-compra   = ?.
vtotal = 0.
vqtd = 0.
for each contrato where contrato.clicod = clien.clicod
                                            no-lock by contrato.dtinicial.
    qtd-contrato = qtd-contrato + 1.
    ult-compra   = contrato.dtinicial.
end.

v-acum = 0.
v-mes  = 0.
v-ano  = 0.

qtd-15  = 0.
qtd-45  = 0.
qtd-46  = 0.
parcela-paga = 0.
parcela-aberta = 0.
vencidas = 0.

proximo-mes = 0.
sal-aberto = 0.
vrepar  = no.

if month(today) = 12
then vdata1 = date(1,1,year(today) + 1).
else vdata1 = date(month(today) + 1,1,year(today)).


if month(vdata1) = 12
then vdata2 = date(1,1,year(vdata1) + 1) - 1.
else vdata2 = date(month(vdata1) + 1,1,year(vdata1)) - 1.
   

maior-atraso = today.
for each titulo where titulo.clifor = clien.clicod no-lock:
    if titulo.modcod = "DEV" or
       titulo.modcod = "BON" or
       titulo.modcod = "CHP"
    then next.

    if titulo.titpar <> 0
    then do:
        if titulo.titsit = "LIB"
        then do:
            parcela-aberta  = parcela-aberta + 1.
            if titulo.titdtven < today
            then do:
                vencidas = vencidas + titulo.titvlcob.
                if titulo.titdtven < maior-atraso
                then maior-atraso = titulo.titdtven.
            end.
        end.
        else parcela-paga = parcela-paga + 1.
    end.
         /*
    if titulo.titpar >= 51
    then vrepar = yes.
    */
    if titulo.titpar <> 0 and titulo.titdtpag <> ?
    then do:
        if (titulo.titdtpag - titulo.titdtven) <= 15
        then qtd-15 = qtd-15 + 1.

        if (titulo.titdtpag - titulo.titdtven) >= 16 and
           (titulo.titdtpag - titulo.titdtven) <= 45
        then qtd-45 = qtd-45 + 1.

        if (titulo.titdtpag - titulo.titdtven) >= 46
        then qtd-46 = qtd-46 + 1.

        v-media = v-media + titulo.titvlcob.

        find first wacum where wacum.mes = month(titulo.titdtpag) and
                               wacum.ano = year(titulo.titdtpag) no-error.
        if not avail wacum
        then do:
            create wacum.
            assign wacum.mes = month(titulo.titdtpag)
                   wacum.ano = year(titulo.titdtpag).
        end.
        wacum.acum = wacum.acum + titulo.titvlcob.
    end.

    if titulo.titsit = "LIB"
    then do:
        sal-aberto = sal-aberto + titulo.titvlcob.
        if titulo.titdtven >= vdata1 and
           titulo.titdtven <= vdata2
        then proximo-mes = proximo-mes + titulo.titvlcob.
    end.

end.
       
def var v1 as int.
def var v2 as int.                         
find first flag where flag.clicod = clien.clicod no-lock no-error.
if avail flag and flag.flag1 = yes
then vrepar = yes.
    
    
    for each wacum by wacum.acum:
        assign v-mes = wacum.mes
               v-ano = wacum.ano
               v-acum = wacum.acum.
        vtotal = vtotal + wacum.acum.
        vqtd   = vqtd + 1.
    end.


    lim-calculado = (clien.limcrd - sal-aberto).
    
    /*******************SOMA CREDSCOR****************/
    
    find first credscor where credscor.clicod = clien.clicod no-lock no-error.
    if avail credscor
    then do:
    
        if credscor.dtultc > ult-compra
        then ult-compra = credscor.dtultc.
        
        qtd-contrato = qtd-contrato + credscor.numcon.
        parcela-paga = parcela-paga + credscor.numpcp.
        
        qtd-15 = qtd-15 + credscor.numa15.
        qtd-45 = qtd-45 + credscor.numa16.
        qtd-46 = qtd-46 + credscor.numa45.
        vtotal = (vala15 + vala16 + vala45).

        vqtd = credscor.numcon.

        if credscor.valacu > v-acum
        then do:
            v-mes = credscor.mesacu.
            v-ano = credscor.anoacu.
            v-acum = credscor.valacu.
        end.    
    
        v-media = (vala15 + vala16 + vala45).
    
    end.    

    /***********************************************/
    
                               
    v-media = v-media / (qtd-15 + qtd-45 + qtd-46).

    /*****************************************/
    
    run stcrecli.p(input clien.clicod,
                               input 24, 
                               output maior-credito-aberto,
                               output media-credito-aberto,
                               output v1,
                               output v2).
                               
    lim-calculado = maior-credito-aberto - sal-aberto.
    if lim-calculado < 0
    then lim-calculado = 0.
    
    limite-cred-scor = limite-cred-scor(recid(clien)).
    
    disp limite-cred-scor label "Limite"
         clien.limcrd label "Credito"
         sal-aberto   label "Credito Aberto"
         lim-calculado label "Credito Pre Arpovado"
         maior-credito-aberto label "Maior Credito Aberto"
         ult-compra      label "Ult. Compra"
         qtd-contrato    label "Contratos"
         parcela-paga    label "    Pagas "
         parcela-aberta  label "Abertas"
            with frame f1 side-label width 80
                    title "C R E D I T O / C O M P R A S  P R E S T A C O E S" row 6.
           /*28224*/
   /* disp ult-compra      label "Ult. Compra"
         qtd-contrato    label "Contratos"
         parcela-paga    label "    Pagas "
         parcela-aberta  label "Abertas"
            with frame f2 side-label width 80
                title "  C O M P R A S              P R E S T A C O E S " 
                row 10.*/
     disp qtd-15       label "(ate 15 dias)"  COLON 20
         ((qtd-15 * 100) / parcela-paga) format ">>9.99%"
         (vtotal / vqtd) label "Media por Contrato" format ">,>>9.99"
         qtd-45       label "(16 ate 45 dias)"  COLON 20
         ((qtd-45 * 100) / parcela-paga) format ">>9.99%"
         v-acum          label "Maior Acum. "
         v-mes        label "Mes/Ano" "/"
         v-ano        no-label
         qtd-46       label "(acima de 45 dias)" COLON 20
         ((qtd-46 * 100) / parcela-paga) format ">>9.99%"
         v-media      label "Prest. Media"
         vrepar       label "Reparcelamento " colon 20
         proximo-mes  label "Proximo Mes " colon 48
            with frame f4 side-label width 80 row 11
         title "A T R A S O               P A R C E L A S                    ".

def var vsomapar as int.
def var vcontrpar as int. /* controla as ultimas 10 parcelas */                
def var vmaioratraso as int.                                                  
def var vmediaatraso as dec.
def var vnumparcpg as int.
/* Quantidade de Parcelas Pagas */                                             ~ find first credscore where credscore.campo = "NUMPARCPG"                      ~       no-lock no-error.                                                       ~  if avail credscore                          
then assign vnumparcpg = credscore.vl-ini.
else assign vnumparcpg = 0.

def var vatraso as dec.
vcontrpar = 0.                                                                 
vmaioratraso = 0.                                                               
for each fin.titulo where fin.titulo.titnat = no
                  and fin.titulo.titdtpag <> ?
                  and fin.titulo.clifor = clien.clicod
                  and fin.titulo.titsit = "PAG"
                  /*and fin.titulo.modcod =  "CRE"
                  and fin.titulo.moecod <> "DEV" */
                      no-lock
     break by fin.titulo.titdtpag descending.      
     if titulo.modcod = "DEV" or
       titulo.modcod = "BON" or
       titulo.modcod = "CHP"
    then next.

     if vatraso = 0 or ((today - fin.titulo.titdtven) > 0 and
                         vatraso < (today - fin.titulo.titdtven))
     then vatraso = (today - fin.titulo.titdtven).
     if vcontrpar < vnumparcpg
     then do:
      vcontrpar = vcontrpar + 1.                                               ~       vmaioratraso = vmaioratraso + (fin.titulo.titdtpag - fin.titulo.titdtven~).
    end.
    vsomapar = vsomapar + 1.
end.

vmediaatraso = vmaioratraso / vcontrpar.

if vmediaatraso < 0
then vmediaatraso = 0.


    disp
         (today - maior-atraso) label "Maior Atraso " colon 21
                format ">>>9 dias"
         vencidas     label "Vencidas    " /*colon 49*/
         vmediaatraso label "Media Atraso"
            with frame f5 color white/red side-label no-box width 80.
    /*
    vdia = (today - maior-atraso).
    */
    
    
    display regua1 with frame f-regua1.
        choose field regua1
               go-on(F4 PF4 h H)
               with frame f-regua1.
                                
    if frame-index = 1 /*Historico*/
    then do:
    
        hide frame f-regua1 no-pause.
        /*if clien.clicod > 1
        then do:
            sresp = no.
            run mensagem.p (input-output sresp,
                            input "Para consultar o Historico o sistema fara                                    uma nova busca de Informacoes na Matriz, 
                                   esta operacao podera levar alguns minutos                                   ."      + "!!" + "          VOCE CONFIRMA ? ",
                                  input "",
                                  input "    Sim",
                                  input "    Nao").
            if sresp then */   run conpreco.p(input estab.etbcod,
                                            input recid(clien)).
        /* end.
            view frame fcli . pause 0.*/
    end.
    
    /*if frame-index = 2 /*Cadastro*/
    then do:
        scli = clien.clicod.
        run clienf7.p.
    /*if  clien.clicod > 1 and
        search("/usr/admcom/progr/agil4_WG.p") <> ?
        then do:
            conecta-ok = no.
            run agil4_WG.p (input "clihisto",
                            input (string(setbcod,"999") +                             string(vclicod,"9999999999"))).
   
            run p-grava-clien-matfil(input vclicod).
               
         end.
         retorna-cadastro = yes.
         next monta-tela. */
     end.  */
/***end.    ***/
