DEF VAR VLINHA AS CHAR.
def var vtotal as dec.
def var varquivo as char.
def var vnomes as char extent 12
init["JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"].
def var vnomes1 as char extent 12
init["JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"].

def var v-sel as char extent 6 format "x(20)".
def var v-cab as char extent 50.
def var v-val as char extent 50.
def var vi as int.
def var li as int.

def temp-table tt-estpg
    field lin as int 
    field val as char extent 50
    .
    
def var vmes as int format "99".
def var vano as int format "9999".
def shared var vdti as date.
def shared var vdtf as date.

vmes = month(vdti).
vano = year(vdti).

/*
disp vmes label "Mes"
       vano label "Ano"
       with frame f-linha side-label width 80 1 down.
*/
/*
vdti = date(vmes,01,vano).
vdtf = date(if vmes = 12 then 01 else vmes + 1,01,
            if vmes = 12 then vano + 1 else vano) - 1

            .
 */
 
def var vindex as int.
/*v-sel[1] = "GERAL".
v-sel[2] = "EMISSAO".
v-sel[3] = "RECEBIMENTO".
v-sel[4] = "ESTORNO".
v-sel[5] = "CANCELAMENTO".
v-sel[6] = "LIQUIDACAO".
v-sel[6] = "COMPRA DE ATIVO".*/

v-sel[1] = "CANCELAMENTO".
v-sel[2] = "ESTORNO".
v-sel[3] = "COMPRA DE ATIVO".

disp v-sel[1]
     v-sel[2]
    with frame f-sel 1 down 1 column no-label.
choose field v-sel[1] v-sel[2] with frame f-sel.
    
vindex = frame-index.

if vindex = 3
then do:
    run imp-arq-cessao.p.
end.
else if vindex = 1  /*** CANCELAMENTOS ***/
then do:

    varquivo = "/admcom/financeira/CTB" + string(vano,"9999") + 
                "/Cancelamentos/cancelamentos"
                + lc(vnomes[vmes]) + string(vano,"9999") + ".csv".

    message varquivo. pause.

    li = 0.

    if search(varquivo) <> ?
    then do:
        input from value(varquivo).
        REPEAT:
            import unformatted vlinha.
            li = li + 1.
            create tt-estpg.
            do vi = 1 to num-entries(vlinha,";"):
                lin = li.
                tt-estpg.val[vi] = entry(vi,vlinha,";").
            end.
        end.
        input close.

        for each financeirace where financeirace.datcan >= vdti and
                            financeirace.datcan <= vdtf
                            :
                financeirace.valcan = 0.
        end.
                            
        for each tt-estpg:
            if lin = 1 then next.
            assign
                tt-estpg.val[13] = replace(tt-estpg.val[13],".","")
                tt-estpg.val[13] = replace(tt-estpg.val[13],",",".")
                tt-estpg.val[14] = replace(tt-estpg.val[14],".","")
                tt-estpg.val[14] = replace(tt-estpg.val[14],",",".")
                tt-estpg.val[15] = replace(tt-estpg.val[15],".","")
                tt-estpg.val[15] = replace(tt-estpg.val[15],",",".")
                tt-estpg.val[17] = replace(tt-estpg.val[17],".","")
                tt-estpg.val[17] = replace(tt-estpg.val[17],",",".")
                tt-estpg.val[19] = replace(tt-estpg.val[19],".","")
                tt-estpg.val[19] = replace(tt-estpg.val[19],",",".")
                .

            disp tt-estpg.val[2] format "x(15)" 
                 tt-estpg.val[9]
                 tt-estpg.val[14] .
            pause 0.
    
            vtotal = dec(tt-estpg.val[14]) . 
            find first financeirace where 
                 financeirace.contnum = int(tt-estpg.val[2])
                 no-error.
            if not avail financeirace
            then do on error undo:
                create financeirace.
                financeirace.contnum = int(tt-estpg.val[2]).
            end.    
            do on error undo:
                assign
                    financeirace.datcan = date(tt-estpg.val[9])
                    financeirace.valcan = financeirace.valcan + vtotal  .
            end.

            find fin.contrato where contrato.contnum = int(tt-estpg.val[2]) 
                no-lock no-error.
    
            for each envfinan where
               envfinan.empcod = 19 and
               envfinan.titnat = no and
               envfinan.modcod = "CRE" and
               envfinan.etbcod = contrato.etbcod and
               envfinan.clifor = contrato.clicod and
               envfinan.titnum = string(contrato.contnum)
               .

                find fin.titulo where titulo.empcod = 19 and
                          titulo.titnat = envfinan.titnat and
                          titulo.modcod = envfinan.modcod and
                          titulo.etbcod = envfinan.etbcod and
                          titulo.clifor = envfinan.clifor and
                          titulo.titnum = envfinan.titnum and
                          titulo.titpar = envfinan.titpar
                          no-error.
                if avail titulo 
                then titulo.cobcod = 2. 

                assign
                    envfinan.envsit = "CAN"
                    envfinan.dt1 = date(tt-estpg.val[9]).
                    envfinan.dec1 = vtotal.
            end.  
        end.
    end.
end.
else if vindex = 2   /*** Estorno ***/
then do:

    varquivo =
        "/admcom/financeira/CTB" + string(vano,"9999") + "/Estornos/estornos"
        + lc(vnomes[vmes]) + string(vano,"9999") + ".csv".

    message varquivo.
    pause.

    li = 0.
    if search(varquivo) <> ?
    then do:
        input from value(varquivo).
        REPEAT:
            import unformatted vlinha.
            li = li + 1.
            create tt-estpg.
            do vi = 1 to num-entries(vlinha,";"):
                lin = li.
                tt-estpg.val[vi] = entry(vi,vlinha,";").
            end.
        end.
        input close.

        for each financeirace where financeirace.datest >= vdti and
                            financeirace.datest <= vdtf
                            :
            financeirace.valest = 0.
        end.

        for each tt-estpg:
            if lin = 1 then next.

            assign
                tt-estpg.val[1] = replace(tt-estpg.val[1],"~"","")
                tt-estpg.val[8] = replace(tt-estpg.val[8],".","")
                tt-estpg.val[8] = replace(tt-estpg.val[8],",",".")
                tt-estpg.val[9] = replace(tt-estpg.val[9],".","")
                tt-estpg.val[9] = replace(tt-estpg.val[9],",",".")
                tt-estpg.val[12] = replace(tt-estpg.val[12],".","")
                tt-estpg.val[12] = replace(tt-estpg.val[12],",",".")
                tt-estpg.val[13] = replace(tt-estpg.val[13],".","")
                tt-estpg.val[13] = replace(tt-estpg.val[13],",",".")
                tt-estpg.val[14] = replace(tt-estpg.val[14],".","")
                tt-estpg.val[14] = replace(tt-estpg.val[14],",",".")
                tt-estpg.val[15] = replace(tt-estpg.val[15],".","")
                tt-estpg.val[15] = replace(tt-estpg.val[15],",",".")
                tt-estpg.val[16] = replace(tt-estpg.val[16],".","")
                tt-estpg.val[16] = replace(tt-estpg.val[16],",",".")
                tt-estpg.val[17] = replace(tt-estpg.val[17],".","")
                tt-estpg.val[17] = replace(tt-estpg.val[17],",",".")
                tt-estpg.val[19] = replace(tt-estpg.val[19],".","")
                tt-estpg.val[19] = replace(tt-estpg.val[19],",",".")
                tt-estpg.val[20] = replace(tt-estpg.val[20],".","")
                tt-estpg.val[20] = replace(tt-estpg.val[20],",",".")
                tt-estpg.val[30] = replace(tt-estpg.val[30],"~"","")
                .

            disp tt-estpg.val[1]
                 tt-estpg.val[4]
                 tt-estpg.val[9]
                .
            pause 0.
    
            vtotal = dec(tt-estpg.val[9]) .

            find first financeirace where 
                       financeirace.contnum = int(tt-estpg.val[4])
            no-error.
            if not avail financeirace
            then do:
                create financeirace.
                financeirace.contnum = int(tt-estpg.val[4]).
            end.
            assign
                financeirace.datest = date(tt-estpg.val[1])
                financeirace.valest = financeirace.valest + vtotal  .

            find fin.contrato where 
                    contrato.contnum = int(tt-estpg.val[4]) 
                    no-lock no-error.
    
            find first envfinan where
               envfinan.empcod = 19 and
               envfinan.titnat = no and
               envfinan.modcod = "CRE" and
               envfinan.etbcod = contrato.etbcod and
               envfinan.clifor = contrato.clicod and
               envfinan.titnum = string(contrato.contnum) and
               envfinan.titpar = int(tt-estpg.val[5])
               no-error
               .

            if avail envfinan
            then do:
                find fin.titulo where titulo.empcod = 19 and
                          titulo.titnat = envfinan.titnat and
                          titulo.modcod = envfinan.modcod and
                          titulo.etbcod = envfinan.etbcod and
                          titulo.clifor = envfinan.clifor and
                          titulo.titnum = envfinan.titnum and
                          titulo.titpar = envfinan.titpar
                          no-error.
                if avail titulo 
                then titulo.cobcod = 2.

                assign
                    envfinan.envsit = "EST"
                    envfinan.dt1 = date(tt-estpg.val[1])
                    envfinan.dec1 = vtotal.
            end.  
        end. 
    end.
end.

/******************************************** inicio
if vindex = 1 or vindex = 2
then do:
/***** CONTRATOS ******/

if vano = 2014
then varquivo =
    "/admcom/financeira/CTB2014/contratos/contratos"
    + lc(vnomes[vmes]) + string(vano,"9999") + ".csv".
else varquivo =
    "/admcom/financeira/CTB" + string(vano,"9999") + "/contratos/contratos"
    + lc(vnomes[vmes]) + string(vano,"9999") + ".csv".
 

message varquivo.
pause.

li = 0.
if search(varquivo) <> ?
then do:
input from value(varquivo).
REPEAT:
    import unformatted vlinha.
    li = li + 1.
    create tt-estpg.
    do vi = 1 to num-entries(vlinha,";"):
        lin = li.
        tt-estpg.val[vi] = entry(vi,vlinha,";").
    end.
end.
input close.

for each tt-estpg:

    if lin = 1 then next.

    assign
        tt-estpg.val[4] = replace(tt-estpg.val[2],".","")
        tt-estpg.val[4] = replace(tt-estpg.val[2],",",".")
       /* tt-estpg.val[22] = replace(tt-estpg.val[22],".","")
        tt-estpg.val[22] = replace(tt-estpg.val[22],",",".")
       */ tt-estpg.val[18] = replace(tt-estpg.val[17],".","")
        tt-estpg.val[18] = replace(tt-estpg.val[17],",",".")
        tt-estpg.val[19] = replace(tt-estpg.val[19],".","")
        tt-estpg.val[19] = replace(tt-estpg.val[19],",",".")
        /*tt-estpg.val[9] = replace(tt-estpg.val[9],".","")
        tt-estpg.val[9] = replace(tt-estpg.val[9],",",".")
      */  tt-estpg.val[11] = replace(tt-estpg.val[13],".","")
        tt-estpg.val[11] = replace(tt-estpg.val[13],",",".")
        tt-estpg.val[12] = replace(tt-estpg.val[12],".","")
        tt-estpg.val[12] = replace(tt-estpg.val[12],",",".")
        tt-estpg.val[15] = replace(tt-estpg.val[15],".","")
        tt-estpg.val[15] = replace(tt-estpg.val[15],",",".")
        tt-estpg.val[17] = replace(tt-estpg.val[17],".","")
        tt-estpg.val[17] = replace(tt-estpg.val[17],",",".")
        .

    disp tt-estpg.val[2]
     tt-estpg.val[13]
     tt-estpg.val[18]
     .
     /*
    tt-estpg.val[9] = replace(tt-estpg.val[9],",",".").
    vtotal = dec(tt-estpg.val[9])
    .  */
    disp tt-estpg.val[9] vtotal.
    
    pause 0.

    find contrato where contrato.contnum = int(tt-estpg.val[2]) 
            no-lock no-error.
    /****
    find first envfinan where
               envfinan.empcod = 19 and
               envfinan.titnat = no and
               envfinan.modcod = "CRE" and
               envfinan.etbcod = contrato.etbcod and
               envfinan.clifor = contrato.clicod and
               envfinan.titnum = string(contrato.contnum) and
               envfinan.titpar = int(tt-estpg.val[5])
               no-error.
    if avail envfinan  and envsit = "ENV"
    then do:
        find titulo where titulo.empcod = 19 and
                          titulo.titnat = envfinan.titnat and
                          titulo.modcod = envfinan.modcod and
                          titulo.etbcod = envfinan.etbcod and
                          titulo.clifor = envfinan.clifor and
                          titulo.titnum = envfinan.titnum and
                          titulo.titpar = envfinan.titpar
                          no-error.
        if avail titulo 
        then do:
            if titulo.cobcod <> 10
            then titulo.cobcod = 10.
        end.    
    end. 
    ****/
    
    create ContFinan.
    assign
        ContFinan.tipo_movimento = "CONTRATOS"
        ContFinan.numero_contrato = int(tt-estpg.val[2])
        ContFinan.numero_parcela = int(tt-estpg.val[16])
        ContFinan.data_vencimento = date(tt-estpg.val[4]) 
        ContFinan.data_movimento = date(tt-estpg.val[29])
        ContFinan.valor_compra   = dec(tt-estpg.val[14])
        ContFinan.valor_entrada  = dec(tt-estpg.val[15])
        ContFinan.taxa_mes  = dec(tt-estpg.val[33])
        ContFinan.valor_saldo = dec(tt-estpg.val[12])
        ContFinan.valor_renda = dec(tt-estpg.val[13])
        ContFinan.prazo  = 0 /*int(tt-estpg.val[14])*/
        ContFinan.valor_IOF    = dec(tt-estpg.val[17])
        ContFinan.IOF_financiado = 0 /*dec(tt-estpg.val[16])*/
        ContFinan.valor_principal = dec(tt-estpg.val[17])
        ContFinan.produto = tt-estpg.val[22]
        ContFinan.agencia = tt-estpg.val[23]
        ContFinan.nome = tt-estpg.val[27]
        .

end.
end.
end.

if vindex = 1 or vindex = 3
then do:

/***** RECEBIMENTO ******/

if vano = 2014
then varquivo =
    "/admcom/financeira/CTB2014/recebimentos/recebimentos"
    + lc(vnomes[vmes]) + string(vano,"9999") + ".csv".
else varquivo =
    "/admcom/financeira/CTB" + string(vano,"9999") + "/recebimentos/recebimentos"
    + lc(vnomes[vmes]) + string(vano,"9999") + ".csv".
 

message varquivo.
pause.

li = 0.
if search(varquivo) <> ?
then do:
input from value(varquivo).
REPEAT:
    import unformatted vlinha.
    li = li + 1.
    create tt-estpg.
    do vi = 1 to num-entries(vlinha,";"):
        lin = li.
        tt-estpg.val[vi] = entry(vi,vlinha,";").
    end.
end.
input close.

for each tt-estpg:
    if lin = 1 then next.

    assign
        tt-estpg.val[7] = replace(tt-estpg.val[7],".","")
        tt-estpg.val[7] = replace(tt-estpg.val[7],",",".")
        tt-estpg.val[15] = replace(tt-estpg.val[15],".","")
        tt-estpg.val[15] = replace(tt-estpg.val[15],",",".")
        tt-estpg.val[10] = replace(tt-estpg.val[10],".","")
        tt-estpg.val[10] = replace(tt-estpg.val[10],",",".")
        tt-estpg.val[27] = replace(tt-estpg.val[27],".","")
        tt-estpg.val[27] = replace(tt-estpg.val[27],",",".")
        tt-estpg.val[11] = replace(tt-estpg.val[11],".","")
        tt-estpg.val[11] = replace(tt-estpg.val[11],",",".")
        tt-estpg.val[20] = replace(tt-estpg.val[20],".","")
        tt-estpg.val[20] = replace(tt-estpg.val[20],",",".")
        tt-estpg.val[12] = replace(tt-estpg.val[12],".","")
        tt-estpg.val[12] = replace(tt-estpg.val[12],",",".")
        tt-estpg.val[13] = replace(tt-estpg.val[13],".","")
        tt-estpg.val[13] = replace(tt-estpg.val[13],",",".")
        tt-estpg.val[14] = replace(tt-estpg.val[14],".","")
        tt-estpg.val[14] = replace(tt-estpg.val[14],",",".")
        tt-estpg.val[9] = replace(tt-estpg.val[9],".","")
        tt-estpg.val[9] = replace(tt-estpg.val[9],",",".")
        tt-estpg.val[8] = replace(tt-estpg.val[8],".","")
        tt-estpg.val[8] = replace(tt-estpg.val[8],",",".")
        tt-estpg.val[29] = replace(tt-estpg.val[29],".","")
        tt-estpg.val[29] = replace(tt-estpg.val[29],",",".")
        tt-estpg.val[28] = replace(tt-estpg.val[28],".","")
        tt-estpg.val[28] = replace(tt-estpg.val[28],",",".")
        .


     disp tt-estpg.val[3]
     tt-estpg.val[5]
     tt-estpg.val[7]
     .

    pause 0.
    
    find contrato where contrato.contnum = int(tt-estpg.val[4]) 
            no-lock no-error.
    
    /***
    find first envfinan where
               envfinan.empcod = 19 and
               envfinan.titnat = no and
               envfinan.modcod = "CRE" and
               envfinan.etbcod = contrato.etbcod and
               envfinan.clifor = contrato.clicod and
               envfinan.titnum = string(contrato.contnum) and
               envfinan.titpar = int(tt-estpg.val[5])
               no-error.
    if avail envfinan
    then do:
        if envfinan.envsit = "ENV"
        then envfinan.envsit = "PAG".
        find titulo where titulo.empcod = 19 and
                          titulo.titnat = envfinan.titnat and
                          titulo.modcod = envfinan.modcod and
                          titulo.etbcod = envfinan.etbcod and
                          titulo.clifor = envfinan.clifor and
                          titulo.titnum = envfinan.titnum and
                          titulo.titpar = envfinan.titpar
                          no-error.
        if avail titulo 
        then do:
            if titulo.cobcod <> 10
            then titulo.cobcod = 10.
        end.    
    end. 
    **/
    
    create ContFinan.
    assign
        ContFinan.tipo_movimento = "RECEBIMENTOS"
        ContFinan.numero_contrato = int(tt-estpg.val[3])
        ContFinan.numero_parcela = int(tt-estpg.val[4])
        ContFinan.data_vencimento = date(tt-estpg.val[23]) 
        ContFinan.data_movimento = date(tt-estpg.val[5])
        ContFinan.valor_data = dec(tt-estpg.val[7])
        ContFinan.valor_pago = dec(tt-estpg.val[15])
        ContFinan.valor_multa = dec(tt-estpg.val[10])
        ContFinan.valor_despesa = dec(tt-estpg.val[27])
        ContFinan.valor_juroatraso = dec(tt-estpg.val[11])
        ContFinan.valor_iocatraso = dec(tt-estpg.val[20])
        ContFinan.valor_outros = dec(tt-estpg.val[12])
        ContFinan.valor_descontoautomatico = dec(tt-estpg.val[13])
        ContFinan.valor_descontocomandado = dec(tt-estpg.val[14])
        ContFinan.compermanencia = dec(tt-estpg.val[9])
        ContFinan.correcao = dec(tt-estpg.val[8])
        ContFinan.valor_receita = dec(tt-estpg.val[29])
        ContFinan.valor_creditos = dec(tt-estpg.val[28])
        ContFinan.produto = tt-estpg.val[31]
        ContFinan.evento = int(tt-estpg.val[21])
        ContFinan.agencia = tt-estpg.val[2]
        ContFinan.nome = tt-estpg.val[24]
        /*ContFinan.valor_pmt  = tt-estpg.val[25]
        */
        ContFinan.data_saldo = date(tt-estpg.val[22])
        .

end.
end.
end.

if vindex = 1 or vindex = 6
then do:

/***** LIQUIDACOES ******/

if vano = 2014
then varquivo =
    "/admcom/financeira/CTB2014/liquidados/"
    + lc(vnomes1[vmes]) + ".csv".
else varquivo =
    "/admcom/financeira/CTB" + string(vano,"9999") + "/liquidados/"
    + lc(vnomes1[vmes]) + ".csv".

message varquivo.
pause.

li = 0.

if search(varquivo) <> ?
then do:

input from value(varquivo).
REPEAT:
    import unformatted vlinha.
    li = li + 1.
    create tt-estpg.
    do vi = 1 to num-entries(vlinha,";"):
        lin = li.
        tt-estpg.val[vi] = entry(vi,vlinha,";").
    end.
end.
input close.

for each tt-estpg:
    if lin = 1 then next.

    /*
    assign
        tt-estpg.val[8] = replace(tt-estpg.val[8],".","")
        tt-estpg.val[8] = replace(tt-estpg.val[8],",",".")
        tt-estpg.val[9] = replace(tt-estpg.val[9],".","")
        tt-estpg.val[9] = replace(tt-estpg.val[9],",",".")
        tt-estpg.val[12] = replace(tt-estpg.val[12],".","")
        tt-estpg.val[12] = replace(tt-estpg.val[12],",",".")
        tt-estpg.val[13] = replace(tt-estpg.val[13],".","")
        tt-estpg.val[13] = replace(tt-estpg.val[13],",",".")
        tt-estpg.val[14] = replace(tt-estpg.val[14],".","")
        tt-estpg.val[14] = replace(tt-estpg.val[14],",",".")
        tt-estpg.val[15] = replace(tt-estpg.val[15],".","")
        tt-estpg.val[15] = replace(tt-estpg.val[15],",",".")
        tt-estpg.val[16] = replace(tt-estpg.val[16],".","")
        tt-estpg.val[16] = replace(tt-estpg.val[16],",",".")
        tt-estpg.val[17] = replace(tt-estpg.val[17],".","")
        tt-estpg.val[17] = replace(tt-estpg.val[17],",",".")
        tt-estpg.val[18] = replace(tt-estpg.val[18],".","")
        tt-estpg.val[18] = replace(tt-estpg.val[18],",",".")
        tt-estpg.val[19] = replace(tt-estpg.val[19],".","")
        tt-estpg.val[19] = replace(tt-estpg.val[19],",",".")
        tt-estpg.val[10] = replace(tt-estpg.val[10],".","")
        tt-estpg.val[10] = replace(tt-estpg.val[10],",",".")
        tt-estpg.val[11] = replace(tt-estpg.val[11],".","")
        tt-estpg.val[11] = replace(tt-estpg.val[11],",",".")
        .
    */
    
    disp tt-estpg.val[1]
     tt-estpg.val[4]
     tt-estpg.val[9]
     .

    pause 0.
    
    find contrato where contrato.contnum = int(tt-estpg.val[4]) 
            no-lock no-error.
    /**
    find first envfinan where
               envfinan.empcod = 19 and
               envfinan.titnat = no and
               envfinan.modcod = "CRE" and
               envfinan.etbcod = contrato.etbcod and
               envfinan.clifor = contrato.clicod and
               envfinan.titnum = string(contrato.contnum) and
               envfinan.titpar = int(tt-estpg.val[5])
               no-error.
    if avail envfinan
    then do:
        if envfinan.envsit = "ENV"
        then envfinan.envsit = "PAG".
        find titulo where titulo.empcod = 19 and
                          titulo.titnat = envfinan.titnat and
                          titulo.modcod = envfinan.modcod and
                          titulo.etbcod = envfinan.etbcod and
                          titulo.clifor = envfinan.clifor and
                          titulo.titnum = envfinan.titnum and
                          titulo.titpar = envfinan.titpar
                          no-error.
        if avail titulo 
        then do:
            if titulo.cobcod <> 10
            then titulo.cobcod = 10.
        end.    
    end. 
    */

    create ContFinan.
    assign
        ContFinan.tipo_movimento = "LIQUIDADOS"
        ContFinan.numero_contrato = int(tt-estpg.val[4])
        ContFinan.numero_parcela = int(tt-estpg.val[5])
        ContFinan.data_vencimento = date(int(substr(tt-estpg.val[23],6,2)),
                                         int(substr(tt-estpg.val[23],9,2)),
                                         int(substr(tt-estpg.val[23],1,4)))
        ContFinan.data_movimento = date(entry(1,tt-estpg.val[1],""))
        ContFinan.valor_data = dec(tt-estpg.val[8])
        ContFinan.valor_pago = dec(tt-estpg.val[9])
        ContFinan.valor_multa = dec(tt-estpg.val[12])
        ContFinan.valor_despesa = dec(tt-estpg.val[13])
        ContFinan.valor_juroatraso = dec(tt-estpg.val[14])
        ContFinan.valor_iocatraso = 0
        ContFinan.valor_outros = dec(tt-estpg.val[15])
        ContFinan.valor_descontoautomatico = dec(tt-estpg.val[16])
        ContFinan.valor_descontocomandado = dec(tt-estpg.val[17])
        ContFinan.valor_receita = dec(tt-estpg.val[18])
        ContFinan.valor_creditos = dec(tt-estpg.val[19])
        ContFinan.produto = tt-estpg.val[24]
        ContFinan.evento = int(tt-estpg.val[6])
        ContFinan.agencia = tt-estpg.val[3]
        ContFinan.grupo = tt-estpg.val[20]
        ContFinan.nome = tt-estpg.val[29]
        ContFinan.correcao = dec(tt-estpg.val[10])
        ContFinan.compermanencia = dec(tt-estpg.val[11])
        .
end.
end.
end.
end. /*index <> 6*/

FIM**********************************/
