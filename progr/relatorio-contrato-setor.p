{admcab.i new}
{admcom_funcoes.i}
def var vdti as date.
def var vdtf as date.
update vdti label "Periodo emissao"
       vdtf no-label
       with frame f1 width 80 side-label.
if vdti = ? or vdtf = ? or vdti > vdtf
then undo.

update setor-clacod like clase.clacod  at 1
        label "Classe SETOR"
        with frame f1. 
if setor-clacod = 0
then.
else do:
    find clase where clase.clacod = setor-clacod and
                     clase.clagrau = 1
                     no-lock no-error.
    if not avail clase
    then do:
        bell.
        message color red/with
        "Infome valor valido para SETOR."
        view-as alert-box.
        undo.   
    end.
    disp clase.clanom no-label with frame f1.                 
end.
def temp-table tt-salcont no-undo
    field contnum like contrato.contnum format ">>>>>>>>>9"
    field etbcod  like contrato.etbcod
    field produto like clase.clanom
    field financiado as dec format ">>>>>>>9.99"
    field pago       as dec format ">>>>>>>9.99"
    field aberto     as dec format ">>>>>>>9.99"
    field vencer     as dec format ">>>>>>>9.99"
    field atraso     as dec format ">>>>>>>9.99"
    index i1 contnum 
    .

def temp-table tt-contsal like tt-salcont
    index i2 contnum.
    
def var q-par-pag-dia as int.
def var v-par-pag-dia as dec.

def var qtd-15       as int format ">>>>9".
def var qtd-45       as int format ">>>>9".
def var qtd-46       as int format ">>>>9".
   
def stream stela.
def var vtippes as char.
def var vspc as char.
def var vdata as date.
def var vok as log.
def var vc as char.
def var vn as char.
def var va as char.
vn = "A;a;B;b;C;c;D;d;E;e;F;f;G;g;H;h;I;i;J;j;K;k;L;l;M;m;N;n;O;o;P;p;Q;q;R;r;S~;s;T;t;U;u;V;v;X;x;Y;y;Z;z;W;w".
vc = "1;2;3;4;5;6;7;8;9;0".
def var vi as int.
def var varquivo as char.
varquivo = "/admcom/relat/contratos-por-periodo-setor-"
    + string(vdti,"99999999") + "-" + string(vdtf,"99999999") + ".csv".

output stream stela to terminal.

def temp-table tt-data
    field datai as date
    field dataf as date
    index i1 datai.
    
def var val-orig as dec.
def var vdata-nova as date format "99/99/9999".
def var data-p-cont as date format "99/99/9999".
def var vnota as char.
def var vproseguro as char.
def var valseguro as dec.
def buffer pro-seguro for produ.
def var vdata1a as date.
def var vdata2a as date.
def var vdatref as date.
def var vtitpar as int.
def var vlimite as char.
def var vtot as dec.
def var vcategoria as char.
def var nov-acao as log format "Sim/Nao".
def var atr-orig as int.
def var valor-pag as dec.
def var vjuro-pag as dec.
def var valor-abe as dec.
def var vjuro-abe as dec.
def var vdias-atr as dec. 
def var valor-atr as dec.
def var vjuro-atr as dec. 
def var val-juro-abe as dec.
def var val-contrato as dec.
def var vtitdtven as date.
def var vdataux as date.
def var dia-atraso as int  extent 100.
def var dat-vencto as date extent 100.
def var dat-atraso as date extent 100.
def var dat-refere as date extent 100.
def var val-atraso as dec  extent 100.
def var vatr as int.
def var vtitvlcob as dec.
def var vdtven-aux as date init 09/30/16. 
def var p-setcod as int.
if vdtf > vdtven-aux then vdtf = vdtven-aux.

def var v-financiado as dec.
def var v-pago as dec.
def var v-aberto as dec.
def var v-vencer as dec.
def var v-produto as char.
def var v-atraso as dec.
def var vchepres as dec.
def var val-entrada as dec.
def temp-table tt-setor
    field setcod as int format ">>>>>>>>>9"
    field valor as dec
    index i1 setcod
    .

do vdata = vdti to vdtf:
    disp stream stela vdata with frame f-disp side-label.
    pause 0.
    for each contrato where
             contrato.dtinicial = vdata and
             contrato.situacao  = 1 
             no-lock,
        first contnf where  contnf.etbcod  = contrato.etbcod and
                            contnf.contnum = contrato.contnum
                    no-lock,
        first plani where plani.etbcod = contnf.etbcod and
                          plani.placod = contnf.placod
                          no-lock:
        disp stream stela contrato.contnum format ">>>>>>>>>9"
            with frame f-disp. pause 0.
        find clien where clien.clicod = contrato.clicod
                no-lock no-error.
        if not avail clien then next.

        assign
            v-financiado = 0
            v-pago = 0
            v-aberto = 0
            v-vencer = 0
            v-atraso = 0
            val-orig = 0
            val-entrada = 0
            .
        
        for each titulo where
                 titulo.empcod = 19 and
                 titulo.titnat = no and
                 titulo.modcod = "CRE" and
                 titulo.etbcod = contrato.etbcod and
                 titulo.clifor = contrato.clicod and
                 titulo.titnum = string(contrato.contnum) /*and
                 titulo.titpar > 0                          */
                 no-lock:
            if titulo.titpar = 0
            then val-entrada = titulo.titvlcob.
            else do:
                if titulo.titsit = "PAG" or
                   titulo.titdtpag <> ?
                then v-pago = v-pago + (titulo.titvlpag /*- titulo.titjuro*/).
                else if titulo.titsit = "LIB"
                then do:
                    v-aberto = v-aberto + titulo.titvlcob.   
                    if titulo.titdtven >= today
                    then v-vencer = v-vencer + titvlcob.
                    else v-atraso = v-atraso + titulo.titvlcob.
                end.
            end.
        end.         
        val-orig = plani.platot - (plani.vlserv + plani.descprod).
                if acha("VOUCHER-TROCAFONE",plani.notobs[1]) <> ?
                then val-orig = val-orig -
                        dec(acha("VOUCHER-TROCAFONE=",plani.notobs[1])).
                if acha("BLACK-FRIDAY",plani.notobs[1]) <> ?
                then val-orig = val-orig -
                    dec(entry(2,acha("BLACK-FRIDAY",plani.notobs[1]),";")).
                if acha("BLACK-FRIDAY-DESCONTO",plani.notobs[1]) <> ?
                then val-orig = val-orig -
                    dec(entry(3,
                        acha("BLACK-FRIDAY-DESCONTO",plani.notobs[1]),";")).
        vchepres = 0.
        if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ?
        then do vi = 1 to int(acha("QTDCHQUTILIZADO",plani.notobs[3])):
            vchepres = vchepres + 
            dec(acha("VALCHQPRESENTEUTILIZACAO" + string(vi),plani.notobs[3]))
            .
        end. 
        val-orig = val-orig - vchepres.
        if val-orig < 0 or val-orig = ?
        then val-orig = 0.
        if val-entrada > contrato.vlentra
        then v-financiado = val-orig - val-entrada.
        else v-financiado = val-orig - contrato.vlentra.
        
        for each tt-setor: delete tt-setor. end.
        
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat
                             no-lock:
            find produ where produ.procod = movim.procod no-lock no-error.
            if avail produ
            then run ver-setor.
            else p-setcod = 0.
            find first tt-setor where tt-setor.setcod = p-setcod no-error.
            if not avail tt-setor
            then create tt-setor.
            tt-setor.setcod = p-setcod.
            tt-setor.valor = tt-setor.valor + (movim.movpc * movim.movqtm)
            .
            
        end.     
        for each tt-setor by valor descending:
            find clase where clase.clacod = tt-setor.setcod 
                        no-lock no-error.
            if avail clase
            then do:
                v-produto = clase.clanom. 
                leave.
            end.               
        end.   
        if (v-pago + v-vencer + v-atraso) < v-financiado
        then v-financiado = (v-pago + v-vencer + v-atraso).                
        find first tt-salcont where
                   tt-salcont.contnum = contrato.contnum
                   no-error.
        if not avail tt-salcont
        then do:
            create tt-salcont.
            assign
                tt-salcont.contnum = contrato.contnum
                tt-salcont.etbcod  = contrato.etbcod
                tt-salcont.produto = v-produto
                tt-salcont.financiado = v-financiado
                tt-salcont.pago  = v-pago
                tt-salcont.aberto = v-aberto
                tt-salcont.vencer = v-vencer
                tt-salcont.atraso = v-atraso
                .   
        end.
    end.
end.

output to value(varquivo).
put "Contrato;Valor Financiado;Valor Pago;Valor Atraso;Valor vencer;Produto"
    skip.
for each tt-salcont.
    put unformatted 
        tt-salcont.contnum ";"
        tt-salcont.financiado ";"
        tt-salcont.pago ";"
        tt-salcont.atraso ";"
        tt-salcont.vencer ";"
        tt-salcont.produto
        skip.
end.
output close.        

message color red/with
varquivo
view-as alert-box
title " arquivo gerado "
.

def buffer sclase for clase.
def buffer grupo for clase.
def buffer setor for clase.

procedure ver-setor:
    find sclase where sclase.clacod = produ.clacod no-lock no-error.
    p-setcod = 0.
    if avail sclase
    then do:
        find clase where clase.clacod = sclase.clasup no-lock no-error.
        if avail clase
        then do:
            find grupo where grupo.clacod = clase.clasup no-lock no-error.
            if avail grupo
            then do:
                find setor where setor.clacod = grupo.clasup no-lock no-error.
                if avail setor
                then p-setcod = setor.clacod.
            end.
        end.
    end.
end procedure.
