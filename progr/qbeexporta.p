/* helio 01/12/2021 ajste data primeira parcela */
/* Ajuste 28/10/2021  88743 Helio */ 

{admcab.i}
{/admcom/progr/api/acentos.i} /* helio 27/10/2021 */
def var vdtpri as date.

Function Data returns character
    (input par-data as date).

    if par-data = ?
    then return "00000000".
    else return string(year(par-data),"9999") +
                string(month(par-data),"99") +
                string(day(par-data),"99").

end function.



function Valor return character
    (input par-valor as dec).

    return trim(string(par-valor, ">>>>>9.99")).
    
end FUNCTION.
                
                
def var vdir                as char init "/admcom/seguro/".
def var vdtini              as date    label "Data Inicial" form "99/99/99".
def var vdtfim              as date    label "Data Final"   form "99/99/99".
def var mempresa            as char extent 2 init [" QBE ", " FFC "].
def var vempresa            as int.
def var vseqreg-ffc         as int.
def var vseqreg-ffc-tot-reg as int.
def var vcont               as int.
def var vsimular            like sresp.

def temp-table tt-seguro
    field rec    as recid
    field dtincl like vndseguro.dtincl
    field dtcanc like vndseguro.dtcanc
    
    index seguro is primary unique rec.

hide message no-pause.

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
    update vsimular colon 18 label "Somente Simular".
end.

hide message no-pause.
message "Ajustando seguros sem numeros da sorte ...".
for each vndseguro where vndseguro.tpseguro = 1
                     and vndseguro.dtincl  >= vdtini
                     and vndseguro.dtincl  <= vdtfim
                     and (vndseguro.dtcanc   = ? or
                         /* Cancelamento de seguro incluido em mes anterior */
                         (vndseguro.dtcanc <> ? and vndseguro.dtincl < vdtini))
                     and (vndseguro.vencod = 0 or vndseguro.numerosorte = "").

    if vndseguro.vencod = 0
    then do.
        find plani where plani.etbcod = vndseguro.etbcod
                     and plani.placod = vndseguro.placod
                   no-lock no-error.
        if avail plani
        then vndseguro.vencod = plani.vencod.
    end.

    if (vndseguro.procod = 559911 /* Moda   */ or
        vndseguro.procod = 579359 /* Moveis */ or
        vndseguro.procod = 578790 /* Moveis */) and
       vndseguro.numerosorte = ""
    then do.
        find contrato of vndseguro no-lock no-error.
        if not avail contrato
        then next. 

        find first segnumsorte use-index venda where
                  segnumsorte.dtivig <= vndseguro.dtincl  and
                  segnumsorte.dtfvig >= vndseguro.dtincl and
                  segnumsorte.dtuso = ?
              no-error.
        if avail segnumsorte
        then do.
            assign
                segnumsorte.dtuso   = vndseguro.dtincl
                /***segnumsorte.hruso   = time***/
                segnumsorte.etbcod  = vndseguro.etbcod
                segnumsorte.placod  = vndseguro.placod
                segnumsorte.contnum = vndseguro.contnum
                segnumsorte.certifi = vndseguro.certifi

                vndseguro.numerosorte = string(segnumsorte.serie,"999") +
                                        string(segnumsorte.nsorteio,"99999")
                vndseguro.datexp      = today
                vndseguro.exportado   = no.
        end.
    end.
end.

if vempresa = 1
then do.
    run geraarq-qbe (559910).
    run geraarq-qbe (559911).
    run geraarq-qbe (579359).
    run geraarq-qbe (578790).
    run geraarq-qbe (1).
end.
else do:
    run carrega-tt-ffc-seguros.
    run carrega-tt-ffc-elegiveis.
    run gera-arq-ffc.
end.    
hide message no-pause.
message "Arquivos gerados em" vdir view-as alert-box.

/******

        QBE

******/
procedure geraarq-qbe.

    def input parameter par-procod as int.

    def var varq      as char.
    def var vtime     as char.
    def var vdata     as date.
    def var vseqreg   as int.
    def var vseqarq   as int.
    def var vclicod   as char.
    def var vsegproduto as char.
    def var vfinnpc   as int.

    assign
        vtime = replace(string(time, "hh:mm:ss"), ":", "").
        varq  = "LEBES_CPS_QBE_" + Data(today) + "_" + vtime + "_" +
                string(par-procod) + ".TXT".

hide message no-pause.
message "Gerando dados QBE" par-procod.
empty temp-table tt-seguro.
for each estab no-lock.
    do vdata = vdtini to vdtfim.
        for each vndseguro where vndseguro.tpseguro = 1
                             and vndseguro.etbcod   = estab.etbcod
                             and vndseguro.dtincl   = vdata
                             and vndseguro.procod   = par-procod
                             and vndseguro.dtcanc   = ?
                           no-lock.
            find contrato of vndseguro no-lock no-error.
            if not avail contrato
            then next. 
            create tt-seguro.
            assign
                tt-seguro.rec    = recid(vndseguro)
                tt-seguro.dtincl = vndseguro.dtincl.
        end.

        for each vndseguro where vndseguro.tpseguro = 1
                             and vndseguro.etbcod   = estab.etbcod
                             and vndseguro.dtcanc   = vdata
                             and vndseguro.procod   = par-procod
                             and vndseguro.dtincl   < vdtini
                           no-lock.
            find contrato of vndseguro no-lock no-error.
            if not avail contrato
            then next. 
            find tt-seguro where tt-seguro.rec = recid(vndseguro) no-error.
            if not avail tt-seguro
            then do.
                create tt-seguro.
                assign
                    tt-seguro.rec    = recid(vndseguro).
            end.
            tt-seguro.dtcanc = vndseguro.dtcanc.
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
    "9839"
    "9839"
    "SEGURADORA" format "x(20)"
    ""      format "x(856)"    
    skip.

/*
    Vendas
*/

for each tt-seguro where tt-seguro.dtcanc = ? no-lock.
    assign
        vfinnpc = 0
        vseqreg = vseqreg + 1.
        
    find vndseguro where recid(vndseguro) = tt-seguro.rec no-lock.
    find clien of vndseguro no-lock.
    find contrato of vndseguro no-lock.
    

    vsegproduto = if vndseguro.procod = 559911 then "9839" else "9840".
    
    if vndseguro.procod = 559911 then do:
        vsegproduto = "9839".
    end.

    if vndseguro.procod = 579910 then do:    
            vsegproduto = "9840".                
    end.                                     

    if vndseguro.procod = 573959 then do: 
        vsegproduto = "9840".           
    end.                                
              
    if vndseguro.procod = 578790 then do:    
        vsegproduto = "5188".                        
    end.                                     
    
    
    vclicod = string(clien.clicod).
    if length(vclicod) > 8
    then vclicod = substr(vclicod, length(vclicod) - 7, 8).
    vdtpri = ?.
    for each titulo where titulo.empcod = 19
                      and titulo.titnat = no
                      and titulo.modcod = contrato.modcod
                      and titulo.etbcod = contrato.etbcod
                      and titulo.clifor = contrato.clicod
                      and titulo.titnum = string(contrato.contnum)
                      and titulo.titpar > 0
                    no-lock.
        vfinnpc  = vfinnpc + 1.
        if vdtpri = ?
        then vdtpri = titulo.titdtven.
    end.
               
/*     if vndseguro.prseguro <> 29.90 then next. */         
               
              /*
 valordaparcela = 0.
 valordaparcela = vndseguro.prseguro / vfinnpc.
   
     if (valordaparcela = 3.99 or valordaparcela = 2.99) then next.
   
        qtdparcelas = 0.
     qtdparcelas = vfinnpc - 1.
     
     valordaparcela = vndseguro.prseguro / qtdparcelas.
     
    if valordaparcela <> 3.99 then next.
*/

    put unformatted
        "02"
        "9839"
        "E"
        vseqreg format "999999"
        ""      format "x(2)"          /* 14 filial */
        ""      format "x(5)"          /* 16 */
        vclicod format "x(8)"          /* 21 */
        "9839" + vndseguro.certifi format "x(20)" /* 29 */
        clien.ciccgc    format "x(14)" /* 49 */
        RemoveAcento(clien.ciinsc) format "x(14)"
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
        RemoveAcento(clien.cep[1])         format "x(8)"
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
        Data(vdtpri)             /* vencimento primeira */
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
for each tt-seguro where tt-seguro.dtcanc <> ?.

    find vndseguro where recid(vndseguro) = tt-seguro.rec no-lock.
    find clien of vndseguro no-lock.
        
    vseqreg = vseqreg + 1.
    
    vsegproduto = if vndseguro.procod = 559911 then "9839" else "9840".
   

       if vndseguro.procod = 559911 then do:     
              vsegproduto = "9839".                 
                 end.                                      
                                                              
       if vndseguro.procod = 579910 then do:     
           vsegproduto = "9840".             
              end.                                      
                                                           
     if vndseguro.procod = 573959 then do:     
       vsegproduto = "9840".                 
          end.                                      
                                                       
      if vndseguro.procod = 578790 then do:     
       vsegproduto = "5188".                 
          end.                                      
    
    vclicod = string(clien.clicod).
    if length(vclicod) > 8
    then vclicod = substr(vclicod, length(vclicod) - 7, 8).
 
    put unformatted
        "04"
        "9839"
        "E"
        vseqreg format "999999"
        "  "    /* filial */
        ""      format "x(5)"
        vclicod format "x(8)"
        "9839" + vndseguro.certifi format "x(20)"
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

empty temp-table tt-seguro.
empty temp-table tt-func.
empty temp-table tt-estab.

hide message no-pause.
message "Gerando dados FFC".
for each estab no-lock.
    do vdata = vdtini to vdtfim.
        for each vndseguro where vndseguro.tpseguro = 1
                             and vndseguro.etbcod   = estab.etbcod
                             and vndseguro.dtincl   = vdata
                             and vndseguro.dtcanc   = ?
                           no-lock.
            find contrato of vndseguro no-lock no-error.
            if not avail contrato
            then next. 
            vseqreg-ffc = vseqreg-ffc + 1.
            vseqreg-ffc-tot-reg = vseqreg-ffc-tot-reg + 1.
            create tt-seguro.
            assign
                tt-seguro.rec    = recid(vndseguro)
                tt-seguro.dtincl = vndseguro.dtincl.
        end.

        for each vndseguro where vndseguro.tpseguro = 1
                             and vndseguro.etbcod   = estab.etbcod
                             and vndseguro.dtcanc   = vdata
                             and vndseguro.dtincl   < vdtini
                           no-lock.
            find contrato of vndseguro no-lock no-error.
            if not avail contrato
            then next. 
            find tt-seguro where tt-seguro.rec = recid(vndseguro) no-error.
            if not avail tt-seguro
            then do.
                vseqreg-ffc = vseqreg-ffc + 1.
                vseqreg-ffc-tot-reg = vseqreg-ffc-tot-reg + 1.
                create tt-seguro.
                assign
                    tt-seguro.rec    = recid(vndseguro).
            end.
            tt-seguro.dtcanc = vndseguro.dtcanc.
        end.
    end.
end.

/*
    Vendas e Cancelamentos
    Cancelado no mesmo mes nao envia
*/
for each tt-seguro no-lock.
    assign
        vfinnpc  = 0
        vvltotal = 0
        vdtpri   = ?
        vmotcanc = "".
        
    find vndseguro where recid(vndseguro) = tt-seguro.rec no-lock.
    find clien of vndseguro no-lock.
    find contrato of vndseguro no-lock.

    find tt-estab of vndseguro no-lock no-error.
    if not avail tt-estab
    then do.
        find estab where estab.etbcod = vndseguro.etbcod no-lock no-error.
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
   
     
        if vndseguro.procod = 559911 then do:     
               vsegproduto = "M".                 
                  end.                                      
                                                               
        if vndseguro.procod = 579910 then do:     
           vsegproduto = "P".             
              end.                                      
                                                           
      if vndseguro.procod = 573959 then do:     
       vsegproduto = "P".                 
          end.                                      
                                                       
               if vndseguro.procod = 578790 then do:     
       vsegproduto = "M".                 
          end.                                      
     
     
     
     /***"9839" else "9840"***/
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

    if vndseguro.dtcanc <> ?
    then vmotcanc = if vndseguro.motcanc > 0
                    then string(vndseguro.motcanc,"99")
                    else "09" /* Desconhecido */.

    assign vcont = vcont + 1.

    create tt-exp-seguro.
    assign
    tt-exp-seguro.num-ordenacao           = vcont
    tt-exp-seguro.tipo_registro           = if vndseguro.dtcanc = ?
                                            then "A"
                                            else "C"
    tt-exp-seguro.tipo_produto            = "PF"
    tt-exp-seguro.tipo_secundario_produto = vsegproduto 
    tt-exp-seguro.origem_produto          = "CD"
    tt-exp-seguro.forma_pagamento         = "B" 
    tt-exp-seguro.data_operacao           = Data(vdata)
    tt-exp-seguro.qtde_parcelas           = string(vfinnpc) 
    tt-exp-seguro.valor_elegivel          = Valor(vvltotal)
    tt-exp-seguro.valor_seguro            = Valor(vndseguro.prseguro)
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
    varq  = "4146SF" + substr(Data(today), 3) + ".TXT".

if not vsimular
then do on error undo.
    find first tab_ini where tab_ini.parametro = "FFC-ARQ-PRESTAMISTA" no-error.
    vseqarq = int(tab_ini.valor) + 1.
    tab_ini.valor = string(vseqarq).
end.

hide message no-pause.
message "Gerando Arquivos FFC".
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
1  Regionais
*/
varq  = "4146GEREG" + substr(Data(today), 3) + ".TXT".
output to value(vdir + varq).
put unformatted
    1          "|"
    "Regional" "|"
    skip.
output close.
unix silent value("unix2dos -q " + vdir + varq).

/*
  Lojas
*/
varq  = "4146GELJS" + substr(Data(today), 3) + ".TXT".
output to value(vdir + varq).
for each tt-estab where tt-estab.etbcod > 0 no-lock.
    put unformatted
        tt-estab.etbcod "|"
        tt-estab.etbnom " " tt-estab.munic "|"
        1               "|"
        skip.
end.
output close.
unix silent value("unix2dos -q " + vdir + varq).

/*
  Vendedores
*/
varq  = "4146GEVDR" + substr(Data(today), 3) + ".TXT".
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


procedure carrega-tt-ffc-elegiveis:

    def var vqtde-parcelas as int.
    def var vvencod        as int.
    def var vdt            as date.
    def var vval-parcela   as dec.
    def var vtipo-prod-sec as char.
    def var vtot-finan     as dec.

do vdt = vdtini to vdtfim:
    hide message no-pause.
    message "Carregando elegiveis FFC" vdt.
    for each estab where estab.tipo = "normal"
                      or estab.tipo = "outlet" no-lock,
                      
        each contrato where contrato.etbcod = estab.etbcod
                        and contrato.dtinicial = vdt no-lock,
                      
        first clien where clien.clicod = contrato.clicod no-lock.

        assign vqtde-parcelas = 0         
               vvencod        = 0
               vtot-finan = 0.
        
        release vndseguro.
        find first vndseguro where vndseguro.contnum = contrato.contnum
                             no-lock no-error.
        if avail vndseguro
        then next.

        release contnf.
        release plani.
        release movim.
        release produ.   

        vtipo-prod-sec = "".
        find first contnf where contnf.etbcod = contrato.etbcod
                            and contnf.contnum = int(contrato.contnum)
                          no-lock no-error.
        if avail contnf
        then do:
             find first plani where plani.etbcod = contnf.etbcod
                                and plani.placod = contnf.placod
                                and plani.pladat = contrato.dtinicial
                                and plani.desti  = contrato.clicod
                              no-lock no-error.
             if avail plani
             then do:
                find first movim where movim.etbcod = plani.etbcod
                                and movim.placod = plani.placod
                                and movim.movtdc = plani.movtdc
                                and movim.movdat = plani.pladat
                                no-lock no-error.
                if avail movim
                then do:
                    find produ where produ.procod = movim.procod
                            no-lock no-error.
                    if avail produ and produ.catcod = 41
                    then vtipo-prod-sec = "M".
                    else vtipo-prod-sec = "P".
                end.
            end.
        end.
        if vtipo-prod-sec = "" then next.
        for each titulo
           where titulo.empcod = 19
             and titulo.titnat = no
             and titulo.modcod = "CRE"
             and titulo.etbcod = contrato.etbcod
             and titulo.clifor = contrato.clicod
             and titulo.titnum = string(contrato.contnum)
             and titulo.titdtemi = contrato.dtinicial
                        no-lock.
              
             if titulo.titpar > 0
             then assign 
                      vqtde-parcelas = vqtde-parcelas + 1
                      vtot-finan = vtot-finan + titulo.titvlcob.
             
             if vvencod = 0 and avail plani
             then assign vvencod = plani.vencod.
             
             if vval-parcela = 0
             then assign vval-parcela = titulo.titvlcob.
        end.

        if vqtde-parcelas < 3  then next.
        if vtot-finan < 100 then next.
        /*
        if vval-parcela < 10
        then next.
        */
        vcont = vcont + 1.
        vseqreg-ffc-tot-reg = vseqreg-ffc-tot-reg + 1.
        create tt-exp-seguro.
        assign
        tt-exp-seguro.num-ordenacao           = vcont
        tt-exp-seguro.tipo_registro           = "O"
        tt-exp-seguro.tipo_produto            = "PF"
        tt-exp-seguro.tipo_secundario_produto = vtipo-prod-sec 
        tt-exp-seguro.origem_produto          = "PF"
        tt-exp-seguro.forma_pagamento         = "" 
        tt-exp-seguro.data_operacao           = data(contrato.dtinicial)
        tt-exp-seguro.qtde_parcelas           = string(vqtde-parcelas) 
        tt-exp-seguro.valor_elegivel          = Valor(contrato.vltotal)
        tt-exp-seguro.valor_seguro            = "0"
        tt-exp-seguro.cod_loja                = string(contrato.etbcod)  
        tt-exp-seguro.cod_vendedor            = string(vvencod)  
        tt-exp-seguro.cpf                     = clien.ciccgc
        tt-exp-seguro.nome                    = RemoveAcento(clien.clinom)
        tt-exp-seguro.numero_sorteio          = ""
        tt-exp-seguro.data_pri_pag            = ""
        tt-exp-seguro.motivo_cancelamento     = ""    
        tt-exp-seguro.cod_item                = ""
        tt-exp-seguro.cod_identificador       = "".
    end.
end.
    
end procedure.

