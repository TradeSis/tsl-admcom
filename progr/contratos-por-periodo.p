{admcab.i}
{admcom_funcoes.i}
def var vdti as date.
def var vdtf as date.
update vdti label "Periodo emissao"
       vdtf no-label
       with frame f1 width 80 side-label.
if vdti = ? or vdtf = ? or vdti > vdtf
then undo.

def var q-par-pag-dia as int.
def var v-par-pag-dia as dec.

def var qtd-15       as int format ">>>>9".
def var qtd-45       as int format ">>>>9".
def var qtd-46       as int format ">>>>9".
def var pagas-base as int.
   
def stream stela.
def var maior-atraso as date.
def var v-acum as dec.
def var vtippes as char.
def var vspc as char.
def var vdata as date.
def var vok as log.
def var vc as char.
def var vn as char.
def var va as char.
vn = "A;a;B;b;C;c;D;d;E;e;F;f;G;g;H;h;I;i;J;j;K;k;L;l;M;m;N;n;O;o;P;p;Q;q;R;r;S;s;T;t;U;u;V;v;X;x;Y;y;Z;z;W;w".
vc = "1;2;3;4;5;6;7;8;9;0".
def var vi as int.
def var varquivo as char.
varquivo = "/admcom/relat/contratos-por-periodo-"
    + string(vdti,"99999999") + "-" + string(vdtf,"99999999") + ".csv".
output to value(varquivo).
output stream stela to terminal.
put unformatted
"Loja Origem;Usuario Cadastro;Emissao;Contrato;Valor Financiado;Valor Entrada;
Valor Parcelas;Limite do Cliente;Prazo;Vencimento 1a Parcela;Departamento;
Seguro Adquirido;Valor Seguro;CPF/CNPJ;Tip Cliente;Valor Renda;
Data Nascimento;Nota Cliente;Pontualidade 0-15;Pontualidade 16-45;
Pontualidade > 45;
Valores Vencer;Valor Vencidos;Comprometimento;Dias Atraso;Seguro Vigente;
Primeiro Contrato;Quantidade Quitadas;Valor Quitadas;Data Renegociacao;
Maior Atraso;Maior Acumulo".

def var vo as int.
do vo = 1 to 30.
    put unformatted 
        ";Venc-" + string(vo)
        ";Paga-" + string(vo)
        .
end.
put skip.

def var vdata-nova as date format "99/99/9999".
def var data-p-cont as date format "99/99/9999".
def var vnota as char.
def var vproseguro as char.
def var valseguro as dec.
def buffer pro-seguro for produ.
def var vdata1a as date.
def var vtitpar as int.
def var vlimite as char.
def var vpar as int.
def var vtot as dec.
def var vcategoria as char.
def var vdt-vencimento as date extent 100.
def var vdt-pagamento  as date extent 100.
def var val-parcela as dec.
do vdata = vdti to vdtf:
    disp stream stela vdata with frame f-disp side-label.
    pause 0.
    for each contrato where
             contrato.dtinicial = vdata 
             /*and (contrato.contnum = 10681119 or
                  contrato.contnum = 10969276 or
                  contrato.contnum = 18105094)
             */no-lock:
        disp stream stela contrato.contnum format ">>>>>>>>>9"
            with frame f-disp. pause 0.
        find clien where clien.clicod = contrato.clicod
                no-lock no-error.
        if not avail clien then next.
        find cpclien of clien no-lock no-error.
        if ciccgc = ? or ciccgc = "" then next.        
        va = substr(string(clien.clinom),1,1).
        vok = no.
        do vi = 1 to num-entries(vn,";"):
            if va = entry(vi,vn,";")
            then do:
                vok = yes.
                leave.
            end.  
        end.
        if vok = no then next.
        va = substr(clien.ciccgc,1,1).
        vok = no.
        do vi = 1 to num-entries(vc,";"):
            if va = entry(vi,vc,";")
            then do:
                vok = yes.
                leave.
            end.
        end.
        if vok = no then next.
        for each contnf where
                 contnf.etbcod = contrato.etbcod and
                 contnf.contnum = contrato.contnum
                no-lock:
            find first plani where plani.etbcod = contnf.etbcod and
                             plani.placod = contnf.placod
                             no-lock no-error.
            if avail plani
            then do:
                if acha("LIMITE-CREDITO",plani.notobs[1]) <> ?
                then vlimite = acha("LIMITE-CREDITO",plani.notobs[1]).
            end.            
        end.
        vtitpar = 0.
        vdata1a = ?.
        val-parcela = 0.
        vdt-vencimento = ?.
        vdt-pagamento = ?.
        for each titulo where
                 titulo.empcod = 19 and
                 titulo.titnat = no and
                 titulo.modcod = "CRE" and
                 titulo.etbcod = contrato.etbcod and
                 titulo.clifor = contrato.clicod and
                 titulo.titnum = string(contrato.contnum) and
                 titulo.titpar > 0
                 no-lock by titpar:
            vtitpar = vtitpar + 1.
            if vdata1a > titulo.titdtven or vdata1a = ?
            then vdata1a = titulo.titdtven.
            vdt-vencimento[vtitpar] = titulo.titdtven.
            vdt-pagamento[vtitpar] = titulo.titdtpag.
            if val-parcela < titulo.titvlcob
            then val-parcela = titulo.titvlcob.
        end.           
        if vtitpar = 0 then next.
        vcategoria = "".  
        find first finesp where finesp.fincod = contrato.crecod
                       no-lock no-error.
        if avail finesp
        then do:
            find first categoria where categoria.catcod =
                            finesp.catcod no-lock no-error.
            if avail categoria
            then vcategoria = categoria.catnom.
        end.                       
        find first vndseguro where
                   vndseguro.contnum = contrato.contnum
                   no-lock no-error.
        if avail vndsegur
        then do:
            find first pro-seguro where 
                       pro-seguro.procod = vndseguro.procod
                        no-lock no-error.
            if avail pro-seguro
            then assign
                    vproseguro = pro-seguro.pronom
                    valseguro  = vndseguro.prseguro.            
        end.
        vnota = "".
        if avail cpclien
        then vnota = string(cpclien.var-int3).
        vdata-nova = ?.
        
        for each tit_novacao where
                   tit_novacao.ori_empcod = 19 and
                   tit_novacao.ori_titnat = no and
                   tit_novacao.ori_modcod = "CRE" and
                   tit_novacao.ori_etbcod = contrato.etbcod and
                   tit_novacao.ori_clifor = contrato.clicod and
                   tit_novacao.ori_titnum = string(contrato.contnum)
                   no-lock:
            vdata-nova = tit_novacao.DtNovacao.
            
        end.
        vtippes = "".
        if clien.tippes
        then vtippes = "PF".
        else vtippes = "PJ".

        maior-atraso = ?.
        v-acum = 0.
        run historico.
        /*
        message pagas-base
        qtd-15 qtd-45 qtd-46
        (qtd-15 / pagas-base) * 100 format ">>9.99"
        .
        pause.
        */
        
        put unformatted
             contrato.etbcod
             ";;"
             contrato.dtinicial    ";"
             contrato.contnum      ";"
             (contrato.vltotal - contrato.vlentra)      ";"
             contrato.vlentra      ";"
             val-parcela  ";"
             vlimite      ";"
             vtitpar      ";"
             vdata1a      ";"
             vcategoria   ";"
             vproseguro   ";"
             valseguro    ";"
             clien.ciccgc  ";"
             vtippes            ";"
             clien.prorenda[1]   ";"
             clien.dtnasc format "99/99/9999" ";"
             vnota   ";"
             qtd-15  ";"
             qtd-45  ";"
             qtd-46  ";"
             ";"
             ";"
             ";"
             ";"
             ";"
             data-p-cont    ";"
             q-par-pag-dia  ";"
             v-par-pag-dia  ";"
             vdata-nova format "99/99/9999" ";"
             today - maior-atraso ";"
             v-acum ";"
             .
        do vpar = 1 to vtitpar:
            put unformatted 
                vdt-vencimento[vpar] format "99/99/9999" ";"
                vdt-pagamento [vpar] format "99/99/9999" ";"
                .            
        end.
        put skip.

    end.
end.

output stream stela close.
output close.
message color red/with
"Arquivo gerado: " varquivo
view-as alert-box.


def workfile wacum
    field mes as int format "99"
    field ano as int format "9999"
    field acum       like plani.platot.


procedure historico:

/*def var maior-atraso like plani.pladat.*/
def var vencidas like clien.limcrd.
def var v-mes as int format "99".
def var v-ano as int format "9999".
/*def var v-acum like clien.limcrd.*/
def var qtd-contrato as int format ">>>9".
def var parcela-paga    as int format ">>>>9".
/*def var pagas-base as int format ">>>>9".*/
def var parcela-aberta  as int format ">>>>9".
def var vrepar       as log format "Sim/Nao".
def var v-media      like clien.limcrd.
def var ult-compra   like plani.pladat.
def var sal-aberto   like clien.limcrd.
def var lim-calculado like clien.limcrd format "->>,>>9.99".
def var scli like clien.clicod.

def var vtotal like plani.platot.
def var vqtd   as int.
def var proximo-mes like clien.limcrd.
def var vdata1 like plani.pladat.
def var vdata2 like plani.pladat.
def var maior-credito-aberto as dec.
def var media-credito-aberto as dec.
def var limite-cred-scor as dec.


for each wacum:
    delete wacum.
end.


qtd-contrato = 0.
ult-compra   = ?.
vtotal = 0.
vqtd = 0.
data-p-cont = ?.
q-par-pag-dia = 0.
v-par-pag-dia = 0.
/*
for each fin.titulo where titulo.clifor = clien.clicod 
                     /*and titulo.titnat = no 
                     and titulo.modcod = "CRE" */
                    no-lock
                    /*break by titulo.titnum
                          by titulo.titdtemi*/:
    if titulo.titnat <> no then next.
    if titulo.modcod <> "CRE" then next.
    /*                      
    if last-of(titulo.titnum)
    then assign
             qtd-contrato = qtd-contrato + 1.
    */                    
    assign ult-compra   = if ult-compra = ?
                          then  titulo.titdtemi
                          else max(ult-compra,titulo.titdtemi).
    if data-p-cont = ? or
       data-p-cont > titulo.titdtemi
    then data-p-cont = titulo.titdtemi.  
    if titulo.titdtpag <> ? and
       titulo.titdtpag <= titdtven 
    then assign
             q-par-pag-dia = q-par-pag-dia + 1
             v-par-pag-dia = v-par-pag-dia + titulo.titvlcob
             .                  
end.
*/                                  
v-acum = 0.
v-mes  = 0.
v-ano  = 0.

qtd-15  = 0.
qtd-45  = 0.
qtd-46  = 0.
pagas-base = 0.
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
for each fin.titulo where titulo.clifor = clien.clicod 
            and titulo.titnat = no 
            and titulo.modcod = "CRE"
                no-lock:
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
        
        ult-compra   = if ult-compra = ?
                          then  titulo.titdtemi
                          else max(ult-compra,titulo.titdtemi).
        if data-p-cont = ? or
            data-p-cont > titulo.titdtemi
        then data-p-cont = titulo.titdtemi.  
        if titulo.titdtpag <> ? and
            titulo.titdtpag <= titdtven 
        then assign
             q-par-pag-dia = q-par-pag-dia + 1
             v-par-pag-dia = v-par-pag-dia + titulo.titvlcob
             .   
    end.

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

pagas-base = parcela-paga.

find first posicli where posicli.clicod = clien.clicod
       no-lock no-error.
if avail posicli
then assign
        parcela-paga = parcela-paga + posicli.qtdparpg
        qtd-contrato = qtd-contrato + posicli.qtdconpg
        .

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
    
    find first credscor where credscor.clicod = clien.clicod no-lock no-error.
    if avail credscor
    then do:
    
        if credscor.dtultc > ult-compra
        then ult-compra = credscor.dtultc.
        
        qtd-contrato = qtd-contrato + credscor.numcon.
        parcela-paga = parcela-paga + credscor.numpcp.
        pagas-base = pagas-base + credscor.numpcp.
        
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

    v-media = v-media / (qtd-15 + qtd-45 + qtd-46).

    /****
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
    *****/
    
    /**********************
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
                    title "C R E D I T O / C O M P R A S  P R E S T A C O E S" ~row 6.
           /*28224*/
   /* disp ult-compra      label "Ult. Compra"
         qtd-contrato    label "Contratos"
         parcela-paga    label "    Pagas "
         parcela-aberta  label "Abertas"
            with frame f2 side-label width 80
                title "  C O M P R A S              P R E S T A C O E S " 
                row 10.*/
     disp qtd-15       label "(ate 15 dias)"  COLON 20
         ((qtd-15 * 100) / pagas-base /*parcela-paga*/) format ">>9.99%"
         (vtotal / vqtd) label "Media por Contrato" format ">,>>9.99"
         qtd-45       label "(16 ate 45 dias)"  COLON 20
         ((qtd-45 * 100) / pagas-base /*parcela-paga*/) format ">>9.99%"
         v-acum          label "Maior Acum. "
         v-mes        label "Mes/Ano" "/"
         v-ano        no-label
         qtd-46       label "(acima de 45 dias)" COLON 20
         ((qtd-46 * 100) / pagas-base /*parcela-paga*/) format ">>9.99%"
         v-media      label "Prest. Media"
         vrepar       label "Reparcelamento " colon 20
         proximo-mes  label "Proximo Mes " colon 48
            with frame f4 side-label width 80 row 11
         title "A T R A S O               P A R C E L A S                    ".


    disp
         (today - maior-atraso) label "Maior Atraso " colon 21
                format ">>>9 dias"
         vencidas     label "Vencidas    " colon 49
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
                            input "Para consultar o Historico o sistema fara   ~                                 uma nova busca de Informacoes na Matriz, 
                                   esta operacao podera levar alguns minutos   ~                                ."      + "!!" + "          VOCE CONFIRMA ? ",
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
                            input (string(setbcod,"999") +                     ~        string(vclicod,"9999999999"))).
   
            run p-grava-clien-matfil(input vclicod).
               
         end.
         retorna-cadastro = yes.
         next monta-tela. */
     end.  */
     ***************/

end procedure.
