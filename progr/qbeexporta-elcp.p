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


function Texto return character
    (input par-texto as char).

    if par-texto = ?
    then return "".
    else return(trim(par-texto)).

end function.

 
function Valor return character
    (input par-valor as dec).

    return trim(string(par-valor, ">>>>>9.99")).
    
end FUNCTION.
 

def var vdir                  as char init "/admcom/seguro/".
def var vdtini                as date    label "Data Inicial" form "99/99/99".
def var vdtfim                as date    label "Data Final"   form "99/99/99".
def var mempresa              as char extent 2 init [" QBE ", " FFC "].
def var vempresa              as int.
def var vseqreg-ffc           as int.
def var vseqreg-ffc-tot-reg   as int.
def var vcont                 as int.

def temp-table tt-seguro
    field rec    as recid
    field dtincl like vndseguro.dtincl
    field dtcanc like vndseguro.dtcanc
    
    index seguro is primary unique rec.

do on error undo with frame f-filtro side-label width 80.
    /*disp "Layout:" colon 8 mempresa no-label.
    choose field mempresa.
    vempresa = frame-index.
    */
    vempresa = 0.
    /*
        Datas
    */
    assign
        vdtini = date( month(today), 1, year(today) )
        vdtfim = date( month(today + 30), 1, year(today + 30) ) - 1.
    update vdtini colon 16 vdtfim.
    if vDtFim < vDtIni
    then do:
        message "Data invalida" view-as alert-box.
        undo.
    end.

    disp vdir label "Diretorio" colon 16 format "x(45)".
end.

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

def temp-table tt-reg
    field regcod as int
    field supcod as int
    field supnom as char.
    
def temp-table tt-etb
    field etbcod as int
    field etbnom as char
    field regcod as int
    field supcod as int
    field supnom as char.
    
for each estab no-lock:

    find first tt-etb where tt-etb.etbcod = estab.etbcod no-error.
    if not avail tt-etb
    then do:
        create tt-etb.
        tt-etb.etbcod = estab.etbcod.
        tt-etb.etbnom = estab.etbnom.
        tt-etb.regcod = estab.regcod.
    end.         
    find first tt-reg where tt-reg.regcod = estab.regcod no-error.
    if not avail tt-reg
    then do:
        create tt-reg.
        tt-reg.regcod = estab.regcod.
    end.           
    find first filialsup where filialsup.etbcod = estab.etbcod
               no-lock no-error.
    if avail filialsup
    then do:           
        find first supervisor where supervisor.supcod = filialsup.supcod
                   no-lock no-error.
        if avail supervisor
        then do:
            assign
                tt-etb.supcod = supervisor.supcod
                tt-etb.supnom = supervisor.supnom
                tt-reg.supcod = supervisor.supcod
                tt-reg.supnom = supervisor.supnom.
        end.
    end.
end.

def buffer bestab for estab.

run carrega-tt-ffc-elegiveis.
/*run carrega-tt-ffc-seguros. */
run gera-arq-ffc.


procedure carrega-tt-ffc-elegiveis:

    def var vqtde-parcelas as int.
    def var vvencod        as int.
    def var vdt            as date.
    def var vval-parcela   as dec.
    def var vtipo-prod-sec as char.
    def var vtot-finan     as dec.
    def var vdata     as date.
    def var vsegproduto as char.
    def var vdtpri    as date.
    def var vmotcanc  as char.

do vdt = vdtini to vdtfim:

    for each estab where estab.tipo = "normal"
                      or estab.tipo = "outlet" no-lock,
        each contrato where contrato.etbcod = estab.etbcod
                        and contrato.dtinicial = vdt 
                      no-lock,
        first clien where clien.clicod = contrato.clicod no-lock.

        assign vqtde-parcelas = 0         
               vvencod        = 0
               vtot-finan = 0.
        
        find first vndseguro where vndseguro.contnum = contrato.contnum
                             no-lock no-error.
            
        vtipo-prod-sec = "".  
        if contrato.banco = 13
        then vtipo-prod-sec = "E".

        find first contnf where contnf.etbcod = contrato.etbcod
                            and contnf.contnum = int(contrato.contnum)
                          no-lock no-error.
        if avail contnf
        then do:
             find first plani where plani.etbcod = contnf.etbcod
                                and plani.placod = contnf.placod
                                and plani.movtdc = 5
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
                if avail movim and vtipo-prod-sec = ""
                then do:
                    find first produ where produ.procod = movim.procod
                            no-lock no-error.
                            
                    if avail produ and produ.catcod = 41
                    then vtipo-prod-sec = "M".
                    else vtipo-prod-sec = "P".
                end.
                if vvencod = 0 
                then assign vvencod = plani.vencod.
            end.
        end.                
        
        if vtipo-prod-sec = "" then next.
        vdtpri = ?. 
        vqtde-parcelas = 0.
        vtot-finan = 0.
        vval-parcela = 0.
        for each titulo
           where titulo.empcod = 19
             and titulo.titnat = no
             and titulo.modcod = contrato.modcod
             and titulo.etbcod = contrato.etbcod
             and titulo.clifor = contrato.clicod
             and titulo.titnum = string(contrato.contnum)
             and titulo.titpar > 0
             and titulo.titdtemi = contrato.dtinicial
                        no-lock.
              
             assign 
                  vqtde-parcelas = vqtde-parcelas + 1
                  vtot-finan = vtot-finan + titulo.titvlcob.
             
             if vval-parcela = 0
             then assign vval-parcela = titulo.titvlcob.
             
             if vdtpri = ?
             then vdtpri = titulo.titdtven.
        end.

        if not avail vndseguro and vqtde-parcelas < 3  then next.
        if not avail vndseguro and vtot-finan < 100 then next.
        
        vcont = vcont + 1.
        vseqreg-ffc-tot-reg = vseqreg-ffc-tot-reg + 1.
        if not avail vndseguro
        then do:
            create tt-exp-seguro.
            assign
            tt-exp-seguro.num-ordenacao           = vcont
            tt-exp-seguro.tipo_registro           = "O"
            tt-exp-seguro.tipo_produto            = "PF"
            tt-exp-seguro.tipo_secundario_produto = vtipo-prod-sec 
            tt-exp-seguro.origem_produto          = if vtipo-prod-sec = "E"
                                                    then "EP" else "CD"
            tt-exp-seguro.forma_pagamento         = "" 
            tt-exp-seguro.data_operacao           = data(contrato.dtinicial)
            tt-exp-seguro.qtde_parcelas           = string(vqtde-parcelas) 
            tt-exp-seguro.valor_elegivel          = Valor(contrato.vltotal)
            tt-exp-seguro.valor_seguro            = "0"
            tt-exp-seguro.cod_loja                = string(contrato.etbcod)  
            tt-exp-seguro.cod_vendedor            = string(vvencod)  
            tt-exp-seguro.cpf                     = clien.ciccgc
            tt-exp-seguro.nome                    = removeacento(clien.clinom)
            tt-exp-seguro.numero_sorteio          = ""
            tt-exp-seguro.data_pri_pag            = ""
            tt-exp-seguro.motivo_cancelamento     = ""    
            tt-exp-seguro.cod_item                = ""
            tt-exp-seguro.cod_identificador       = "".
        end.
        else do:
            if vndseguro.tpseguro = 1
            then vsegproduto = if vndseguro.procod = 559911 then "M" else "P".
            else vsegproduto = "E".
            
            vdata = vndseguro.dtincl.
            vmotcanc = "".
            if vndseguro.dtcanc <> ?
            then do.
                vdata = vndseguro.dtcanc.
                vmotcanc = if vndseguro.motcanc > 0
                           then string(vndseguro.motcanc,"99")
                           else "09" /* Desconhecido */.
            end.

            create tt-exp-seguro.
            assign
            tt-exp-seguro.num-ordenacao           = vcont
            tt-exp-seguro.tipo_registro           = if vndseguro.dtcanc = ?
                                                    then "A"
                                                    else "C"
            tt-exp-seguro.tipo_produto            = "PF"
            tt-exp-seguro.tipo_secundario_produto = vsegproduto 
            tt-exp-seguro.origem_produto          = if vsegproduto = "E"
                                                    then "EP" else "CD"
            tt-exp-seguro.forma_pagamento         = "B" 
            tt-exp-seguro.data_operacao           = Data(vdata)
            tt-exp-seguro.qtde_parcelas           = string(vqtde-parcelas) 
            tt-exp-seguro.valor_elegivel          = Valor(contrato.vltotal)
            tt-exp-seguro.valor_seguro            = Valor(vndseguro.prseguro)
            tt-exp-seguro.cod_loja                = string(vndseguro.etbcod)  
            tt-exp-seguro.cod_vendedor            = string(vndseguro.vencod)  
            tt-exp-seguro.cpf                     = clien.ciccgc
            tt-exp-seguro.nome                    = removeacento(clien.clinom)
            tt-exp-seguro.numero_sorteio          = vndseguro.numerosorte
            tt-exp-seguro.data_pri_pag            = Data(vdtpri)
            tt-exp-seguro.motivo_cancelamento     = vmotcanc    
            tt-exp-seguro.cod_item                = ""
            tt-exp-seguro.cod_identificador       = "".

            find tt-estab of vndseguro no-lock no-error.
            if not avail tt-estab
            then do.
                find first bestab where bestab.etbcod = vndseguro.etbcod
                                    no-lock no-error.
                if avail bestab
                then do:
                    create tt-estab.
                    assign tt-estab.etbcod = vndseguro.etbcod
                        tt-estab.etbnom = bestab.etbnom
                        tt-estab.munic  = bestab.munic.
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
        end.
    end.
end.
    
end procedure.




procedure gera-arq-ffc:

    def var varq      as char.
    def var vtime     as char.
    def var vseqarq   as int.

assign
    vtime = replace(string(time, "hh:mm:ss"), ":", "").
    varq  = "4146SF" + substr(Data(today), 3) + ".TXT".

do on error undo.
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
varq  = "4146GEREG" + substr(Data(today), 3) + ".TXT".
output to value(vdir + varq).

for each supervisor no-lock:
put unformatted
    supervisor.supcod "|"
    supervisor.supnom "|"
    skip.
end.
output close.
unix silent value("unix2dos -q " + vdir + varq).

/*
  Lojas
*/
varq  = "4146GELJS" + substr(Data(today), 3) + ".TXT".
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

