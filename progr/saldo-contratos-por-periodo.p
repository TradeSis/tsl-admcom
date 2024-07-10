{admcab.i new}
{admcom_funcoes.i}
def var vdti as date.
def var vdtf as date.
update vdti label "Periodo emissao"
       vdtf no-label
       with frame f1 width 80 side-label.
if vdti = ? or vdtf = ? or vdti > vdtf
then undo.

def temp-table tt-salcont
    field dataref as date
    field contnum like contrato.contnum format ">>>>>>>>>9"
    field etbcod  like contrato.etbcod
    field dataemi as date
    field cpfcnpj as char
    field tipocli as char
    field valorab as dec
    field vjuroab as dec
    field valorpg as dec
    field vjuropg as dec
    field diasatr as int
    field novacao as log
    field atrorig as int
    field dataven as date
    field valparc as dec
    index i1 contnum dataref
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
vn = "A;a;B;b;C;c;D;d;E;e;F;f;G;g;H;h;I;i;J;j;K;k;L;l;M;m;N;n;O;o;P;p;Q;q;R;r;S;s;T;t;U;u;V;v;X;x;Y;y;Z;z;W;w".
vc = "1;2;3;4;5;6;7;8;9;0".
def var vi as int.
def var varquivo as char.
varquivo = "/admcom/relat/saldo-contratos-por-periodo-"
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

if vdtf > vdtven-aux then vdtf = vdtven-aux.

do vdata = vdti to vdtf:
    disp stream stela vdata with frame f-disp side-label.
    pause 0.
    for each contrato where
             contrato.dtinicial = vdata and
             contrato.situacao = 1
             no-lock:
             
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
        val-orig = 0.
        for each contnf where
                 contnf.etbcod = contrato.etbcod and
                 contnf.contnum = contrato.contnum
                no-lock:
            find first plani where plani.etbcod = contnf.etbcod and
                             plani.placod = contnf.placod and
                             plani.pladat = contrato.dtinicial
                             no-lock no-error.
            if avail plani
            then do:
                if acha("LIMITE-CREDITO",plani.notobs[1]) <> ?
                then vlimite = acha("LIMITE-CREDITO",plani.notobs[1]).
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
            end.
        end.    
        vtitpar = 0.
        vdata1a = ?.
        nov-acao = yes.
        val-contrato = 0.
        for each tt-data: delete tt-data. end.
        for each titulo where
                 titulo.empcod = 19 and
                 titulo.titnat = no and
                 titulo.modcod = "CRE" and
                 titulo.etbcod = contrato.etbcod and
                 titulo.clifor = contrato.clicod and
                 titulo.titnum = string(contrato.contnum) and
                 titulo.titpar > 0
                 no-lock:
            if titulo.titdtven = ?
            then next.
            vtitpar = vtitpar + 1.
            if titulo.titdtpag < titulo.titdtven and vdata1a = ?
            then vdata1a = titulo.titdtpag.
            if vdata1a > titulo.titdtven or vdata1a = ?
            then vdata1a = titulo.titdtven.
            if vdata2a < titulo.titdtven or vdata2a = ?
            then vdata2a = titulo.titdtven.
            if titulo.titpar < 30
            then nov-acao = no.
            val-contrato = val-contrato + titulo.titvlcob.
        end.
        val-contrato = contrato.vltotal - contrato.vlentra.
        if vtitpar = 0 then next.
        vdataux = vdata1a.
        vdata2a = date(if month(vdata2a) = 12 then 1
                       else month(vdata2a) + 1,01,
                       if month(vdata2a) = 12
                       then year(vdata2a) + 1
                       else year(vdata2a)) - 1.
        repeat:
            vdatref = date(if month(vdataux) = 12 
                           then 1
                           else month(vdataux) + 1,01,
                           if month(vdataux) = 12
                           then year(vdataux) + 1
                           else year(vdataux)) - 1.
            vdataux = vdatref + 1.
            create tt-data.
            tt-data.datai = date(month(vdatref),01,year(vdatref)).
            tt-data.dataf = vdatref.
            if vdatref = vdata2a or
               vdatref = vdtven-aux
            then leave.
        end.          
        if vtitpar = 0
        then nov-acao = no. 
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
        atr-orig = 0.
        if val-orig = 0
        then 
        for each tit_novacao where
                 tit_novacao.ger_contnum = contrato.contnum
                 no-lock:
            find first titulo where
                       titulo.empcod = tit_novacao.ori_empcod and
                       titulo.titnat = tit_novacao.ori_titnat and
                       titulo.modcod = tit_novacao.ori_modcod and
                       titulo.etbcod = tit_novacao.ori_etbcod and
                       titulo.clifor = tit_novacao.ori_clifor and
                       titulo.titnum = tit_novacao.ori_titnum and
                       titulo.titpar = tit_novacao.ori_titpar 
                       no-lock no-error.
            val-orig = val-orig + tit_novacao.ori_titvlcob.     
            if  avail titulo and
                tit_novacao.dtnovacao - titulo.titdtven > atr-orig
            then atr-orig = tit_novacao.dtnovacao - titulo.titdtven.
            nov-acao = yes.
        end.             
        if val-orig < 0 or
           val-orig > (contrato.vltotal - contrato.vlentra)
        then val-orig = 0. 
        if val-orig > 0
        then val-orig = val-orig / vtitpar.
        
        vtippes = "".
        if clien.tippes
        then vtippes = "PF".
        else vtippes = "PJ".
        assign
            valor-pag = 0
            vjuro-pag = 0
            valor-abe = 0
            vjuro-abe = 0
            valor-atr = 0
            vjuro-atr = 0
            vdias-atr  = 0  
            vtitdtven = ? 
            val-juro-abe = 0
            dia-atraso = 0
            dat-atraso = ?
            dat-refere  = ?
            dat-vencto = ?
            val-atraso = 0
            vdataux = contrato.dtinicial
            .

         repeat:
            
            if month(vdataux) = month(vdata1a)
            then leave.

            vdatref = date(if month(vdataux) = 12 
                           then 1
                           else month(vdataux) + 1,01,
                           if month(vdataux) = 12
                           then year(vdataux) + 1
                           else year(vdataux)) - 1.
            vdataux = vdatref + 1.
            find first tt-salcont where
                   tt-salcont.contnum = contrato.contnum and
                   tt-salcont.dataref  = vdatref 
                   no-error.
            if not avail tt-salcont
            then do:
                create tt-salcont.
                assign
                    tt-salcont.contnum = contrato.contnum
                    tt-salcont.dataref  = vdatref 
                    .
            end.
            assign
                tt-salcont.etbcod  = contrato.etbcod
                tt-salcont.dataemi = contrato.dtinicial
                tt-salcont.cpfcnpj = clien.ciccgc
                tt-salcont.tipocli = vtippes
                .

            assign
                tt-salcont.valorpg = 0
                tt-salcont.vjuropg = 0
                tt-salcont.valorab = val-contrato
                tt-salcont.vjuroab = 0
                tt-salcont.diasatr = 0
                tt-salcont.novacao = nov-acao
                tt-salcont.atrorig = atr-orig
                .

        end.
        for each tt-data:
            find first tt-salcont where
                   tt-salcont.contnum = contrato.contnum and
                   tt-salcont.dataref  = tt-data.dataf
                   no-error.
            if not avail tt-salcont
            then do:
                create tt-salcont.
                assign
                    tt-salcont.contnum = contrato.contnum
                    tt-salcont.dataref  = tt-data.dataf
                    .
            end.
            assign
                tt-salcont.etbcod  = contrato.etbcod
                tt-salcont.dataemi = contrato.dtinicial
                tt-salcont.cpfcnpj = clien.ciccgc
                tt-salcont.tipocli = vtippes
                .
            vjuro-atr = 0.
            vdias-atr = 0.
            
            for each titulo where
                 titulo.empcod = 19 and
                 titulo.titnat = no and
                 titulo.modcod = "CRE" and
                 titulo.etbcod = contrato.etbcod and
                 titulo.titdtven >= tt-data.datai and
                 titulo.titdtven <= tt-data.dataf and
                 titulo.clifor = contrato.clicod and
                 titulo.titnum = string(contrato.contnum) and
                 titulo.titpar > 0 /*and
                 titulo.titsit = "LIB"*/
                 no-lock:
                 if /*titulo.titdtven < today and*/
                    (titulo.titsit = "LIB" or
                     (titulo.titsit = "PAG" and
                      titulo.titdtpag > tt-data.dataf))
                 then do:
                    if titulo.titdtven < today and
                       titulo.titdtven < tt-data.dataf
                    then
                    valor-atr = valor-atr + titulo.titvlcob.
                    do vatr = 1 to 100:
                        if dia-atraso[vatr] = 0 and
                           dat-vencto[vatr] = ? and
                           dat-refere[vatr] = ? and
                           val-atraso[vatr] = 0
                        then do:
                            assign
                                dat-vencto[vatr] = titulo.titdtven
                                dat-refere[vatr] = tt-data.dataf
                                dia-atraso[vatr] = 
                                        (tt-data.dataf - titulo.titdtven)
                                val-atraso[vatr] = titulo.titvlcob 
                                vdatref = tt-data.dataf
                                /*vtitdtven = titulo.titdtven*/
                                vtitvlcob = titulo.titvlcob
                                .
                            if vtitdtven = ?
                            then vtitdtven = titulo.titdtven.
                            run cal-juro.
                            vjuro-atr = vjuro-atr + val-juro-abe .
                            vdias-atr = /*vdias-atr +*/ (vdatref - vtitdtven).
                            leave.
                        end.
                        else if /*dat-vencto[vatr] <> ? and
                                dat-refere[vatr] <> ? and*/
                                val-atraso[vatr] > 0
                            then do:
                                assign
                                    vdatref = tt-data.dataf
                                    /*vtitdtven = dat-vencto[vatr]*/
                                    vtitvlcob = val-atraso[vatr] 
                                    .

                                if vtitdtven = ?
                                then vtitdtven = dat-vencto[vatr].
                                           
                                if vdatref = ?
                                then vdatref = tt-data.dataf.
                                run cal-juro.
                                vjuro-atr = vjuro-atr + val-juro-abe .
                                vdias-atr = /*vdias-atr +*/ 
                                    (vdatref - vtitdtven).
                            end.        
                    end.        
                end.
            end.
            for each titulo where
                 titulo.empcod = 19 and
                 titulo.titnat = no and
                 titulo.modcod = "CRE" and
                 titulo.etbcod = contrato.etbcod and
                 titulo.titdtpag >= tt-data.datai and
                 titulo.titdtpag <= tt-data.dataf and
                 titulo.clifor = contrato.clicod and
                 titulo.titnum = string(contrato.contnum) and
                 titulo.titpar > 0  and
                 titulo.titsit = "PAG"
                 no-lock:
                
                valor-pag = valor-pag + titulo.titvlcob.
                val-contrato = val-contrato - titulo.titvlcob.
                
                if val-contrato < 0
                then do:
                    assign
                        val-contrato = 0
                        valor-atr = 0
                        vjuro-atr = 0
                        vjuro-abe = 0
                        vdias-atr = 0
                        .
                    leave.
                end.  

                if titulo.titdtven < tt-data.datai and
                   valor-atr >= titulo.titvlcob
                then do:
                    do vatr = 1 to 100:
                        if dat-vencto[vatr] = titulo.titdtven
                        then do:
                            assign
                                valor-atr = valor-atr - val-atraso[vatr]
                                /*vdias-atr = vdias-atr - dia-atraso[vatr]
                                */
                                vtitdtven = ?
                                val-atraso[vatr] = 0
                                .
                            leave.
                            
                        end.        
                    end.
                end.
            end.
            if valor-atr > 0 and
                vdias-atr = 0 and
                vjuro-atr = 0
            then do:
                do vatr = 1 to 100:
                    if val-atraso[vatr] > 0
                    then do:
                        assign
                            vdatref = tt-data.dataf
                            vtitdtven = dat-vencto[vatr]
                            vtitvlcob = val-atraso[vatr] 
                            .
                        run cal-juro.
                        vjuro-atr = vjuro-atr + val-juro-abe .
                        vdias-atr = /*vdias-atr +*/ (vdatref - vtitdtven).
                        leave.

                    end.        
                end. 
            end.            

            if valor-atr <= 0 /*or tt-data.dataf > today */
            then assign
                    valor-atr = 0
                    vdias-atr = 0
                    vjuro-atr = 0
                    .
            assign
                tt-salcont.valorpg = valor-atr
                tt-salcont.vjuropg = vjuro-atr
                tt-salcont.valorab = val-contrato
                tt-salcont.vjuroab = vjuro-abe
                tt-salcont.diasatr = vdias-atr
                tt-salcont.novacao = nov-acao
                tt-salcont.atrorig = atr-orig
                .
            /****
            disp tt-data.dataf
                 tt-salcont.valorab
                 tt-salcont.valorpg
                 tt-salcont.vjuropg
                 tt-salcont.diasatr
                 .
                 pause.   
            ****/ 
            if val-contrato = 0 and valor-atr = 0
            then for each tt-salcont where
                          tt-salcont.contnum = contrato.contnum
                            :
                    delete tt-salcont.
                 end. 
            find first tt-contsal where
                       tt-contsal.contnum = contrato.contnum
                       no-error.
            if not avail tt-contsal
            then create tt-contsal.
            assign
                tt-contsal.contnum = contrato.contnum
                tt-contsal.valorpg = valor-atr
                tt-contsal.vjuropg = vjuro-atr
                tt-contsal.valorab = val-contrato
                tt-contsal.vjuroab = vjuro-abe
                tt-contsal.diasatr = vdias-atr
                tt-contsal.novacao = nov-acao
                tt-contsal.atrorig = atr-orig
                .
            
        end.
    end.
end.

output stream stela close.

output to value(varquivo).

put "Data Visao;Nro Contrato;Loja Origem;Data Emissao;CPF/CNPJ;Tipo Cliente;
Valor Aberto;Juro Aberto;Valor Atraso;Juro Atraso;Dias Atraso;Renegociacao;
Atraso Original" skip.

for each tt-contsal where
         tt-contsal.valorpg > 0:
for each tt-salcont where tt-salcont.contnum = tt-contsal.contnum:
    put unformatted
        tt-salcont.dataref ";"
        tt-salcont.contnum ";"
        tt-salcont.etbcod  ";"
        tt-salcont.dataemi ";"
        tt-salcont.cpfcnpj ";"
        tt-salcont.tipocli ";"
        tt-salcont.valorab format ">>>>>>9.99" ";"
        tt-salcont.vjuroab format ">>>>>>9.99" ";"
        tt-salcont.valorpg format ">>>>>>9.99" ";"
        tt-salcont.vjuropg format ">>>>>>9.99" ";"
        tt-salcont.diasatr ";"
        tt-salcont.novacao ";"
        tt-salcont.atrorig 
        skip.
end.
end.

output close.
message color red/with
"Arquivo gerado: " varquivo
view-as alert-box.

procedure cal-juro:
    def var vnumdia as int.
    if vdatref > vtitdtven
    then do:
        vnumdia = vdatref - vtitdtven.
        find first tabjur where
               tabjur.etbcod = 0 and
               tabjur.nrdias = vnumdia no-lock no-error.
        if avail tabjur
        then val-juro-abe = (vtitvlcob * tabjur.fator) - vtitvlcob.
        else val-juro-abe = 0.
        /*disp vdatref vtitdtven vtitvlcob tabjur.fator val-juro-abe
        vnumdia.
        pause.*/
    end.
end procedure.
                                                
