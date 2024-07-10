/* Ajuste 28/10/2021  88743 Helio */ 

{admcab.i}
{/admcom/progr/api/acentos.i} /* helio 27/10/2021 */

Function Data returns character
    (input par-data as date).

    if par-data = ?
    then return "00000000".
    else return string(year(par-data),"9999") +
                string(month(par-data),"99") +
                string(day(par-data),"99").

end function.


FUNCTION f-trata-num returns character
    (input cpo as char).
    
    def var vret as char.
    def var i    as int.
    
    do i = 1 to length(cpo):   
       if substring(cpo,i,1) = "0" or
          substring(cpo,i,1) = "1" or
          substring(cpo,i,1) = "2" or
          substring(cpo,i,1) = "3" or
          substring(cpo,i,1) = "4" or
          substring(cpo,i,1) = "5" or
          substring(cpo,i,1) = "6" or
          substring(cpo,i,1) = "7" or
          substring(cpo,i,1) = "8" or
          substring(cpo,i,1) = "9" 
       then vret = vret
                 + substring(cpo,i,1).
    end.    
                                   
    return vret. 
    
end FUNCTION.

def var vnome like clien.clinom.


                
                
def var vdir                  as char init "/admcom/seguro/".
def var vdtini                as date    label "Data Inicial" form "99/99/99".
def var vdtfim                as date    label "Data Final"   form "99/99/99".
def var mempresa              as char extent 2 init [" QBE ", " FFC "].
def var vempresa              as int.
def var vseqreg-ffc           as int.
def var vseqreg-ffc-tot-reg   as int.
def var vcont                 as int.
def var vsimular            like sresp.

def temp-table tt-venseguro
    field rec    as recid
    field dtincl like vndseguro.dtincl
    field dtcanc like vndseguro.dtcanc
    index seguro is primary unique rec.

def temp-table tt-canseguro
    field rec    as recid
    field dtincl like vndseguro.dtincl
    field dtcanc like vndseguro.dtcanc
    index seguro is primary unique rec.
    
    
do on error undo with frame f-filtro side-label.
    disp "Layout:" colon 10 mempresa no-label.
    choose field mempresa.
    vempresa = frame-index.

    /*
        Datas
    */
    assign
        vdtini = date( month(today), 1, year(today) )
        vdtfim = date( month(today + 30), 1, year(today + 30) ) - 1.
    update vdtini colon 18 vdtfim.
    if vDtFim < vDtIni
    then do:
        message "Data invalida" view-as alert-box.
        undo.
    end.

    disp vdir label "Diretorio" colon 18 format "x(45)".
    update vsimular colon 18 label "Somente Simular?".
end.

def temp-table tt-reg
    field regcod as int
    field supcod as int
    field supnom as char
    .
    
def temp-table tt-etb
    field etbcod as int
    field etbnom as char
    field regcod as int
    field supcod as int
    field supnom as char
    .
    
for each estab no-lock:

    find first tt-etb where
               tt-etb.etbcod = estab.etbcod no-error.
    if not avail tt-etb
    then do:
        create tt-etb.
        tt-etb.etbcod = estab.etbcod.
        tt-etb.etbnom = estab.etbnom.
        tt-etb.regcod = estab.regcod.
    end.         
    find first tt-reg where
               tt-reg.regcod = estab.regcod no-error.
    if not avail tt-reg
    then do:
        create tt-reg.
        tt-reg.regcod = estab.regcod.
    end.           
    find first filialsup where 
               filialsup.etbcod = estab.etbcod
               no-lock no-error.
    if avail filialsup
    then do:           
        find first supervisor where
                   supervisor.supcod = filialsup.supcod
                   no-lock no-error.
        if avail supervisor
        then do:
            assign
                tt-etb.supcod = supervisor.supcod
                tt-etb.supnom = supervisor.supnom
                tt-reg.supcod = supervisor.supcod
                tt-reg.supnom = supervisor.supnom
                .
        end.
    end.
end.

if vempresa = 1
then do.
    run geraarq-qbe (569131).
    run geraarq-qbe (1).
end.
else do:
    run carrega-tt-ffc-seguros.
    run   gera-arq-ffc.
end.    
message "Arquivos gerados em" vdir view-as alert-box.


/******
        QBE
******/
procedure geraarq-qbe.

    def input parameter par-procod as int.

    def var varq            as char.
    def var vtime           as char.
    def var vdata           as date.
    def var vseqreg         as int.
    def var vseqarq         as int.
    def var vclicod         as char.
    def var vsegproduto     as char.
    def var vfinnpc         as int.
    def var vdt_venc_parc_1 as date.

    assign
        vtime = replace(string(time, "hh:mm:ss"), ":", "").
        varq  = "LEBES_CPS_QBE_" + Data(today) + "_" + vtime + "_CP.TXT".

empty temp-table tt-venseguro.
empty temp-table tt-canseguro.
for each estab no-lock.
    do vdata = vdtini to vdtfim.
        for each vndseguro where vndseguro.tpseguro = 3
                             and vndseguro.etbcod   = estab.etbcod
                             and vndseguro.dtincl   = vdata
                             and vndseguro.procod   = par-procod
                             /*and vndseguro.dtcanc   = ? */
                           no-lock.
            find clien of vndseguro no-lock.
            vnome = RemoveAcento(clien.clinom).
            if vnome = "CLIENTE SEM NOME"
            then do:
                message color red/with
                vnome skip
                "Codigo: " string(clien.clicod,">>>>>>>>>9")
                 view-as alert-box.
            end.
            find contrato of vndseguro no-lock no-error.
            if not avail contrato
            then next.
            create tt-venseguro.
            assign
                tt-venseguro.rec    = recid(vndseguro)
                tt-venseguro.dtincl = vndseguro.dtincl
                tt-venseguro.dtcanc = ?
                .
        end.

        for each vndseguro where vndseguro.tpseguro = 3
                             and vndseguro.etbcod   = estab.etbcod
                             and vndseguro.dtcanc   = vdata
                             and vndseguro.procod   = par-procod
                          /* and vndseguro.dtincl   < vdtini */
            no-lock.
            find contrato of vndseguro no-lock no-error.
            if not avail contrato
            then next.
            find tt-canseguro where 
                tt-canseguro.rec = recid(vndseguro) no-error.
            if not avail tt-canseguro
            then do.
                create tt-canseguro.
                assign
                    tt-canseguro.rec    = recid(vndseguro)
                    tt-canseguro.dtincl = vndseguro.dtincl
                    tt-canseguro.dtcanc = vndseguro.dtcanc.
                    
            end.
        end.
    end.
end.

if not vsimular
then do on error undo.
    find first tab_ini where tab_ini.parametro = "QBE-ARQ-PRESTAMISTA" no-error.
    vseqarq = int(tab_ini.valor) + 1.
    tab_ini.valor = string(vseqarq).
end.

/*
    Header
*/
output to value(vdir + varq).
vseqreg = vseqreg + 1.
put unformatted
    "01"
    Data(today)
    vseqarq format "999999"
    "0001"
    "9839"
    "SEGURADORA" format "x(20)"
    ""      format "x(856)"    
    skip.

/*
    Vendas
*/

for each tt-venseguro where tt-venseguro.dtcanc = ? no-lock.
    assign
        vfinnpc = 0
        vseqreg = vseqreg + 1.
        
    find vndseguro where recid(vndseguro) = tt-venseguro.rec no-lock.
    find clien of vndseguro no-lock.

    find contrato of vndseguro no-lock no-error.
    
    if not avail contrato
    then next.

/***find finan where finan.fincod = contrato.crecod no-lock no-error.
    if avail finan
    then vfinnpc = finan.finnpc.
***/

    vsegproduto = "3610".
    vclicod = string(clien.clicod).
    if length(vclicod) > 8
    then vclicod = substr(vclicod, length(vclicod) - 7, 8).

    /* helio 27/10/2021 - le pelo contrato */
    for each titulo where titulo.empcod = 19
                      and titulo.titnat = no
                      and titulo.modcod = contrato.modcod
                      and titulo.etbcod = contrato.etbcod
                      and titulo.clifor = contrato.clicod
                      and titulo.titnum = string(contrato.contnum)
                      and titulo.titpar > 0
                    no-lock.
        vfinnpc  = vfinnpc + 1.
    end.
         
    assign vdt_venc_parc_1 = ?.

    release titulo.
    find last titulo where titulo.empcod = 19
                           and titulo.titnat = no
                           and titulo.modcod = contrato.modcod
                           and titulo.etbcod = vndseguro.etbcod
                           and titulo.clifor = vndseguro.clicod
                           and titulo.titnum = string(vndseguro.contnum)
                           and titulo.titpar = 1 no-lock no-error.
                           
    if avail titulo
    then assign vdt_venc_parc_1 = titulo.titdtven.

    put unformatted
        "02"
        "9839"
        "E"
        vseqreg format "999999"
        ""      format "x(2)"          /* 14 filial */
        ""      format "x(5)"          /* 16 */
        vclicod format "x(8)"          /* 21 */
        "3610" + vndseguro.certifi format "x(20)" /* 29 */
        clien.ciccgc    format "x(14)" /* 49 */
        f-trata-num(clien.ciinsc) format "x(14)"
        ""              format "x(10)" /* Órgão Emissor */
        ""              format "x(2)"  /* UF */
        "00000000"                     /* Data Emissao */
        RemoveAcento(clien.clinom)    format "x(50)"
        Data(clien.dtnasc)
        if clien.sexo then "M" else "F"
        " "             /* Estado Civil */
        RemoveAcento(clien.endereco[1]) + " " + RemoveAcento(clien.compl[1])
                                    format "x(70)"
        clien.numero[1]             format ">>>>>>>>>9"
        RemoveAcento(clien.zona)           format "x(70)" /* e-mail */
        RemoveAcento(clien.bairro[1])      format "x(25)"
        RemoveAcento(clien.cidade[1])      format "x(35)"
        f-trata-num(clien.cep[1])   format "x(8)"
        RemoveAcento(clien.ufecod[1])      format "x(2)"
        0                   format "9999" /* ddd*/
        0                   format "99999999" /* fone */
        0                   format "999999"   /* ramal */
        ""                  format "x(6)"     /* filler */
        0                   format "9999"     /* numero seguro */
        vsegproduto         format "x(4)" /* Produto */
        ""                  format "x(4)" /* Plano */
        ""                  format "x(4)" /* Faixa etaria */
        ""                  format "x(4)" /* Vigencia */
        ""                  format "x(4)" /* Nivel */
        vsegproduto         format "x(4)" /* Campanha */
        vndseguro.prseguro * 100 format "999999999999999"
        0                   format "99"
        Data(vndseguro.dtincl)
        0                   format "999999" /* Prestacao */
        vfinnpc             format "99"
        vfinnpc             format "99"
        ""                  format "x(8)"   /* Vendedor */
        string(vndseguro.etbcod) format "x(10)"
        Data(vdt_venc_parc_1)               /* vencimento primeira */
        Data(?)
        0                   format "9999"       /* DDD 2 */
        0                   format "99999999"
        0                   format "999999"
        0                   format "9999"       /* DDD 3 */
        0                   format "99999999"
        0                   format "999999"
        "3445"              format "x(4)"       /* Produto */
        "SEG PREST PREM LEBES" format "x(30)"
        vndseguro.numerosorte format "x(8)"
        ""                  format "x(25)" /* filler */
        ""                  format "x(300)"
        skip.
end.

/*
    Cancelamentos
    Cancelado no mesmo mes nao envia
*/
for each tt-canseguro where tt-canseguro.dtcanc <> ?.

    find vndseguro where recid(vndseguro) = tt-canseguro.rec no-lock.
    find clien of vndseguro no-lock.
        
    vseqreg = vseqreg + 1.
    vsegproduto = if vndseguro.procod = 559911 then "3610" else "9840".
    vclicod = string(clien.clicod).
    if length(vclicod) > 8
    then vclicod = substr(vclicod, length(vclicod) - 7, 8).
 
    put unformatted
        "04"
        "3610"
        "E"
        vseqreg format "999999"
        "  "    /* filial */
        ""      format "x(5)"
        vclicod format "x(8)"
        "3610" + vndseguro.certifi format "x(20)"
        ""      format "x(4)"
        vsegproduto
        "0000"  format "x(4)"   /* 057- 060 */
        Data(vndseguro.dtcanc)
        1       format "99"
        "Devolucao"     format "x(255)" /* Motivo */
        ""      format "x(275)"
        ""      format "x(300)"
        skip.
        
end.

/*
    Trailer
*/
vseqreg = vseqreg + 1.
put unformatted
    "16"
    vseqreg format "999999999"
    ""      format "x(889)"
    skip.
output close.

end procedure.


/********

         FFC

********/

def temp-table tt-exp-seguro
    field num-ordenacao                  as int
    field tipo_registro                  as char
    field tipo_produto                   as char
    field tipo_secundario_produto        as char
    field origem_produto                 as char
    field forma_pagamento                as char
    field data_operacao                  as char
    field qtde_parcelas                  as char
    field valor_elegivel                 as char
    field valor_seguro                   as char
    field cod_loja                       as char
    field cod_vendedor                   as char
    field cpf                            as char
    field nome                           as char
    field numero_sorteio                 as char
    field data_pri_pag                   as char
    field motivo_cancelamento            as char
    field cod_item                       as char
    field cod_identificador              as char
    index ordem is primary unique num-ordenacao.

def temp-table tt-estab
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field munic  like estab.munic
    index estab is primary unique etbcod.

def temp-table tt-func
    field etbcod like func.etbcod
    field funcod like func.funcod
    field funnom like func.funnom
    index func is primary unique etbcod funcod.


procedure carrega-tt-ffc-seguros.
          
    def var vdata     as date.
    def var vclicod   as char.
    def var vsegproduto as char.
    def var vfinnpc   as int.
    def var vvltotal  as dec.
    def var vdtpri    as date.
    def var vmotcanc  as char.

empty temp-table tt-venseguro.
empty temp-table tt-canseguro.
empty temp-table tt-func.
empty temp-table tt-estab.

for each estab no-lock.
    do vdata = vdtini to vdtfim.
        for each vndseguro where vndseguro.tpseguro = 3
                             and vndseguro.etbcod   = estab.etbcod
                             and vndseguro.dtincl   = vdata
                             /*and vndseguro.dtcanc   = ?*/
                           no-lock.
            find contrato of vndseguro no-lock no-error.
            if not avail contrato
            then next.

            vseqreg-ffc = vseqreg-ffc + 1.
            vseqreg-ffc-tot-reg = vseqreg-ffc-tot-reg + 1.
            create tt-venseguro.
            assign
                tt-venseguro.rec    = recid(vndseguro)
                tt-venseguro.dtincl = vndseguro.dtincl
                tt-venseguro.dtcanc = ?
                .
        end.

        for each vndseguro where vndseguro.tpseguro = 3
                             and vndseguro.etbcod   = estab.etbcod
                             and vndseguro.dtcanc   = vdata
                             /*and vndseguro.dtincl   < vdtini*/
                           no-lock.
            find contrato of vndseguro no-lock no-error.
            if not avail contrato
            then next.

            find tt-canseguro where 
                tt-canseguro.rec = recid(vndseguro) no-error.
            if not avail tt-canseguro
            then do:
                vseqreg-ffc = vseqreg-ffc + 1.
                vseqreg-ffc-tot-reg = vseqreg-ffc-tot-reg + 1.
                create tt-canseguro.
                assign
                    tt-canseguro.rec    = recid(vndseguro)
                    tt-canseguro.dtincl = vndseguro.dtincl
                    tt-canseguro.dtcanc = vndseguro.dtcanc.
            end.
        end.
    end.
end.

/*
    Vendas e Cancelamentos
    Cancelado no mesmo mes nao envia
*/

for each tt-venseguro:
    find tt-canseguro where 
         tt-canseguro.rec = tt-venseguro.rec no-error.
    if avail tt-canseguro and
             tt-venseguro.dtincl = tt-canseguro.dtincl
    then do:
        delete tt-canseguro.
        delete tt-venseguro.
    end.
end.

for each tt-canseguro:
    find tt-venseguro where
         tt-venseguro.rec = tt-canseguro.rec no-error.
    if not avail tt-venseguro
    then do:

        create tt-venseguro.
        buffer-copy tt-canseguro to tt-venseguro.
    
    end.

end.    
    
for each tt-venseguro no-lock:
    assign
        vfinnpc  = 0
        vvltotal = 0
        vdtpri   = ?
        vmotcanc = "".
        
    find vndseguro where recid(vndseguro) = tt-venseguro.rec no-lock.
    find clien of vndseguro no-lock.
    find contrato of vndseguro no-lock.

    find tt-estab of vndseguro no-lock no-error.
    if not avail tt-estab
    then do.
        find first estab where estab.etbcod = vndseguro.etbcod
                                    no-lock no-error.
        if avail estab
        then do:
            create tt-estab.
            assign tt-estab.etbcod = vndseguro.etbcod
                   tt-estab.etbnom = estab.etbnom
                   tt-estab.munic  = estab.munic.
        end.
    end.

    find tt-func where tt-func.etbcod = vndseguro.etbcod
                   and tt-func.funcod = vndseguro.vencod
                 no-lock no-error.
    if not avail tt-func
    then do.
        find first func where func.etbcod = vndseguro.etbcod
                          and func.funcod = vndseguro.vencod
                                        no-lock no-error.
        if avail func
        then do:
            create tt-func.
            assign
                tt-func.etbcod = vndseguro.etbcod
                tt-func.funcod = vndseguro.vencod
                tt-func.funnom = func.funnom.
        end.    
    end.

    vsegproduto = if vndseguro.procod = 559911 then "M" else "P".
     /***"3610" else "9840"***/
    vclicod = string(clien.clicod).
    if length(vclicod) > 8
    then vclicod = substr(vclicod, length(vclicod) - 7, 8).

    for each titulo where titulo.empcod = 19
                      and titulo.titnat = no
                      and titulo.modcod = contrato.modcod
                      and titulo.etbcod = contrato.etbcod
                      and titulo.clifor = contrato.clicod
                      and titulo.titnum = string(contrato.contnum)
                      and titulo.titpar > 0
                    no-lock
                    by titulo.titdtven.
        if vdtpri = ?
        then vdtpri = titulo.titdtven.
        vvltotal = vvltotal + titulo.titvlcob.
        vfinnpc  = vfinnpc + 1.
    end.
    if vfinnpc  = 0
    then do:
        vvltotal = 0.
        vdtpri = ?.
    end.

    vdata = vndseguro.dtincl.
    if vndseguro.dtcanc <> ?
    then vdata = vndseguro.dtcanc.

    vmotcanc = "".
    if vndseguro.dtcanc <> ?
    then
        if vndseguro.motcanc > 0
        then vmotcanc = string(vndseguro.motcanc,"99").
        else vmotcanc = "09" /* Desconhecido */.

    assign vcont = vcont + 1.

    vsegproduto = "E".
    
    create tt-exp-seguro.
    assign
    tt-exp-seguro.num-ordenacao           = vcont
    tt-exp-seguro.tipo_registro           = if vndseguro.dtcanc = ?
                                            then "A"
                                            else "C"
    tt-exp-seguro.tipo_produto            = "PF"
    tt-exp-seguro.tipo_secundario_produto = vsegproduto 
    tt-exp-seguro.origem_produto          = "EP"
    tt-exp-seguro.forma_pagamento         = "B" 
    tt-exp-seguro.data_operacao           = Data(vdata)
    tt-exp-seguro.qtde_parcelas           = string(vfinnpc) 
    tt-exp-seguro.valor_elegivel          = string(vvltotal)
    tt-exp-seguro.valor_seguro            = string(vndseguro.prseguro)
    tt-exp-seguro.cod_loja                = string(vndseguro.etbcod)  
    tt-exp-seguro.cod_vendedor            = string(vndseguro.vencod)  
    tt-exp-seguro.cpf                     = clien.ciccgc
    tt-exp-seguro.nome                    = RemoveAcento(clien.clinom)
    tt-exp-seguro.numero_sorteio          = vndseguro.numerosorte
    tt-exp-seguro.data_pri_pag            = Data(vdtpri)
    tt-exp-seguro.motivo_cancelamento     = vmotcanc    
    tt-exp-seguro.cod_item                = ""
    tt-exp-seguro.cod_identificador       = "".
end.

end procedure.



procedure gera-arq-ffc:

    def var varq      as char.
    def var vtime     as char.
    def var vseqarq   as int.

    assign
        vtime = replace(string(time, "hh:mm:ss"), ":", "").
        varq  = "4146SF" + substr(Data(today), 3) + "_CP.TXT".

if not vsimular
then do on error undo.
    find first tab_ini where tab_ini.parametro = "FFC-ARQ-PRESTAMISTA" no-error.
    vseqarq = int(tab_ini.valor) + 1.
    tab_ini.valor = string(vseqarq).
end.

/*
    Header
*/

output to value(vdir + varq).
put unformatted
    "H"     "|"
    "4146"  "|"
    Data(today) "|"
    vseqarq format "999999" "|"
    0       "|"
    vseqreg-ffc "|"
    vseqreg-ffc-tot-reg "|"
    skip.
vseqreg-ffc = vseqreg-ffc + 1.
vseqreg-ffc-tot-reg = vseqreg-ffc-tot-reg + 1.

for each tt-exp-seguro no-lock by tt-exp-seguro.num-ordenacao:

    put unformatted
    tt-exp-seguro.tipo_registro           "|"
    tt-exp-seguro.tipo_produto            "|"
    tt-exp-seguro.tipo_secundario_produto "|"
    tt-exp-seguro.origem_produto          "|"
    tt-exp-seguro.forma_pagamento         "|"
    tt-exp-seguro.data_operacao           "|"
    tt-exp-seguro.qtde_parcelas           "|"
    tt-exp-seguro.valor_elegivel          "|"
    tt-exp-seguro.valor_seguro            "|"
    tt-exp-seguro.cod_loja                "|"
    tt-exp-seguro.cod_vendedor            "|"
    tt-exp-seguro.cpf                     "|"
    tt-exp-seguro.nome                    "|"
    tt-exp-seguro.numero_sorteio          "|"
    tt-exp-seguro.data_pri_pag            "|"
    tt-exp-seguro.motivo_cancelamento     "|"
    tt-exp-seguro.cod_item                "|"
    tt-exp-seguro.cod_identificador
    skip.
end.

/*
    Trailer
*/
vseqreg-ffc = vseqreg-ffc + 1.
vseqreg-ffc-tot-reg = vseqreg-ffc-tot-reg + 1.
put unformatted
    "T"     "|"
    vseqreg-ffc-tot-reg "|"
    skip.
output close.
unix silent value("unix2dos -q " + vdir + varq).

/*
  Regionais
*/
varq  = "4146GEREG" + substr(Data(today), 3) + "_CP.TXT".
output to value(vdir + varq).

for each tt-reg no-lock by tt-reg.regcod:
put unformatted
    tt-reg.supcod "|"
    tt-reg.supnom "|"
    skip.
end.
output close.
unix silent value("unix2dos -q " + vdir + varq).

/*
  Lojas
*/
varq  = "4146GELJS" + substr(Data(today), 3) + "_CP.TXT".
output to value(vdir + varq).
for each tt-estab where tt-estab.etbcod > 0 no-lock.
    find first tt-etb where tt-etb.etbcod = tt-estab.etbcod 
            no-lock no-error.
    put unformatted
        tt-estab.etbcod "|"
        tt-estab.munic "|"
        .
    if avail tt-etb
    then put unformatted tt-etb.supcod "|".
    put skip.
end.
output close.
unix silent value("unix2dos -q " + vdir + varq).

/*
  Vendedores
*/
varq  = "4146GEVDR" + substr(Data(today), 3) + "_CP.TXT".
output to value(vdir + varq).
for each tt-func where tt-func.funcod > 0 no-lock.
    put unformatted
        tt-func.funcod "|"
        tt-func.funnom "|"
        tt-func.etbcod "|"
        skip.
end.
output close.
unix silent value("unix2dos -q " + vdir + varq).

end procedure.



