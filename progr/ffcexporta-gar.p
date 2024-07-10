/* Ajuste 28/10/2021  88743 Helio */ 

/*                       
Nov/2017: Projeto Garantia / RFQ
#1 20.03.2018 TP 23748994- Helio -  
        Quando loja nao vendeu nada de seguro no periodo, 
        nao estava entrao trazendo o registro O
#2 20.03.2018 Helio - Melhoria performance dos temp-table        
#3 27.03.2018 TP 23748994- Helio - DtInicial vai ficar conforme o digitado no dtini1
#4 27803.2018 TP 23748994- Helio - Tirar teste que excluia pessoa juridica


*/
             
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



function Valor return character
    (input par-valor as dec).

    return trim(string(par-valor, ">>>>>9.99")).
    
end FUNCTION.


def var vdir           as char init "/admcom/seguro/".
def var vdtini         as date label "Data Inicial" form "99/99/99".
def var vdtfim         as date label "Data Final"   form "99/99/99".
def var vseqreg-ffc-5  as int.
def var vseqreg-ffc-6  as int.
def var vdata          as date.
def var vpreco         as dec.
def var videntificador as char.

do on error undo with frame f-filtro side-label centered
        title " GARANTIA / RFQ ".
    /*
        Datas
    */
    disp vdir label "Diretorio" colon 16 format "x(45)".
    assign
        vdtini = date( month(today), 1, year(today) )
        vdtfim = date( month(today + 30), 1, year(today + 30) ) - 1.
    update vdtini colon 16 vdtfim.
    if vDtFim < vDtIni
    then do:
        message "Data invalida" view-as alert-box.
        undo.
    end.
end.

def temp-table tt-exp-seguro no-undo /* #2 */
    field rec                  as recid
    field tpseguro             like segtipo.tpseguro
    field tipo_registro        as char
    field etbcod               as int
    field vencod               as int
    field procod               as int
    field clicod               as int
    field tempo                as char
    field preco_pro            as dec
    field preco_gar            as char
    field dtincl               as char
    field data_operacao        as date
    field identificador        as char
    field motivo_cancelamento  as char.

def temp-table tt-estab no-undo /* #2 */
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field munic  like estab.munic
    index estab is primary unique etbcod.

def temp-table tt-func no-undo /* #2 */
    field etbcod like func.etbcod
    field funcod like func.funcod
    field funnom like func.funnom
    index func is primary unique etbcod funcod.

def temp-table tt-reg no-undo /* #2 */
    field supcod as int
    field supnom as char.
    
def temp-table tt-etb no-undo /* #2 */
    field etbcod as int
    field etbnom as char
    field regcod as int
    field supcod as int
    field supnom as char.

def temp-table tt-clase no-undo /* #2 */
    field clacod like clase.clacod
    index clase is primary unique clacod.

empty temp-table tt-func.
empty temp-table tt-estab.

for each estab where estab.usap2k no-lock:

    create tt-etb.
    assign
        tt-etb.etbcod = estab.etbcod
        tt-etb.etbnom = estab.etbnom
        tt-etb.regcod = estab.regcod.

    find first filialsup where filialsup.etbcod = estab.etbcod no-lock no-error.
    if avail filialsup
    then do:           
        find first supervisor where supervisor.supcod = filialsup.supcod
                   no-lock no-error.
        if avail supervisor
        then do.
            assign
                tt-etb.supcod = supervisor.supcod
                tt-etb.supnom = supervisor.supnom.

            find first tt-reg where tt-reg.supcod = supervisor.supcod
                              no-error.
            if not avail tt-reg
            then do:
                create tt-reg.
                tt-reg.supcod = supervisor.supcod.
                tt-reg.supnom = supervisor.supnom.
            end.
        end.
    end.
end.

pause 0 before-hide.
/*
    Vendas e Cancelamentos
*/
message "Processando Vendas e Cancelamentos".
for each segtipo where segtipo.tpseguro = 5
                    or segtipo.tpseguro = 6
                 no-lock.
    for each estab where estab.usap2k no-lock.
        do vdata = vdtini to vdtfim.
            /* Vendas */
            for each vndseguro where vndseguro.tpseguro = segtipo.tpseguro
                                 and vndseguro.etbcod   = estab.etbcod
                                 and vndseguro.dtincl   = vdata
                                 and vndseguro.dtcanc   = ?
                               no-lock.
                run cria-registro.
            end.

            /* Cancelado no mesmo mes nao envia */
            for each vndseguro where vndseguro.tpseguro = segtipo.tpseguro
                                 and vndseguro.etbcod   = estab.etbcod
                                 and vndseguro.dtcanc   = vdata
                                 and vndseguro.dtincl   < vdtini
                               no-lock.
                run cria-registro.
            end.
        end.
    end.
end.

/*
    Elegiveis
*/
message "Processando Elegiveis".
def var vdtinicial as date.

for each tipmov where tipmov.movtvenda
                  and tipmov.movtdev = no
                no-lock.

    for each estab where estab.usap2k no-lock.

        /* #1 */
        find first vndseguro where vndseguro.tpseguro = 5
                               and vndseguro.etbcod = estab.etbcod
/* #1                               and vndseguro.dtincl >= vdtini */
                               and vndseguro.dtincl <= vdtfim
                             no-lock no-error.
        if not avail vndseguro
        then find first vndseguro where vndseguro.tpseguro = 6
                               and vndseguro.etbcod = estab.etbcod
/* #1                               and vndseguro.dtincl >= vdtini */
                               and vndseguro.dtincl <= vdtfim
                             no-lock no-error.
        /* #1 
        if not avail vndseguro 
        then next. 
        vdtinicial = vndseguro.dtincl.         
        if vdtinicial < vdtini
        then vdtinicial = vdtini.
        */
        
        /* #3
        /* #1 */
        if avail vndseguro
        then vdtinicial = if vndseguro.dtincl < vdtini
                          then vdtini
                          else vndseguro.dtincl.  
        else vdtinicial = vdtini.
        /* #1 */        
        #3 */
        
        vdtinicial = vdtini. /* #3 */
                

        disp estab.etbcod vdtinicial label "De" vdtfim label "Ate".

        do vdata = /*vdtini*/ vdtinicial to vdtfim.

            for each plani where plani.movtdc = tipmov.movtdc
                             and plani.etbcod = estab.etbcod
                             and plani.pladat = vdata
                           no-lock.

                find clien where clien.clicod = plani.desti no-lock no-error.
                if not avail clien
                then next.
                /* #4
                if not clien.tippes
                then next.
                */

                for each movim where movim.etbcod = plani.etbcod
                                 and movim.placod = plani.placod
                                 and movim.movtdc = plani.movtdc
                                 and movim.movdat = plani.pladat
                               no-lock.

                    for each segtipo where segtipo.tpseguro = 5 /* Gar */
                                        or segtipo.tpseguro = 6 /* RFQ */
                                     no-lock.
                        /* verificar enquadramento */
                        find first segprodu
                                     where segprodu.procod = movim.procod
                                       and segprodu.tpseguro = segtipo.tpseguro
                                       and segprodu.dtivig <= movim.movdat
                                       and (segprodu.dtfvig = ? or
                                            segprodu.dtfvig >= movim.movdat)
                                     no-lock no-error.
                        if not avail segprodu
                        then next.

                        /* Verifica se há seguro do produto na venda */
                        find first movimseg
                                     where movimseg.etbcod = movim.etbcod
                                       and movimseg.placod = movim.placod
                                       and movimseg.movseq = movim.movseq
                                       and movimseg.tpseguro = segtipo.tpseguro
                                     no-lock no-error.
                        if avail movimseg
                        then next.

        if segtipo.tpseguro = 5
        then vseqreg-ffc-5 = vseqreg-ffc-5 + 1.
        else vseqreg-ffc-6 = vseqreg-ffc-6 + 1.

        videntificador = string(plani.etbcod,"999") +
                     plani.serie + string(plani.numero) +
                     string(segtipo.tpseguro) +
                     string(movim.movseq,"999").

        find tt-func where tt-func.etbcod = plani.etbcod
                       and tt-func.funcod = plani.vencod
                     no-lock no-error.
        if not avail tt-func
        then do.
            find first func where func.etbcod = plani.etbcod
                              and func.funcod = plani.vencod
                            no-lock no-error.
            if avail func
            then do:
                create tt-func.
                assign
                    tt-func.etbcod = plani.etbcod
                    tt-func.funcod = plani.vencod
                    tt-func.funnom = func.funnom.
            end.    
        end.

        create tt-exp-seguro.
        assign
            tt-exp-seguro.rec           = recid(vndseguro)
            tt-exp-seguro.tpseguro      = segtipo.tpseguro
            tt-exp-seguro.tipo_registro = "O"
            tt-exp-seguro.etbcod        = plani.etbcod
            tt-exp-seguro.vencod        = plani.vencod
            tt-exp-seguro.procod        = movim.procod
            tt-exp-seguro.clicod        = plani.desti
          /*tt-exp-seguro.tempo         = vndseguro.tempo*/
            tt-exp-seguro.preco_pro     = movim.movpc
          /*tt-exp-seguro.preco_gar     = vndseguro.prseguro*/
          /*tt-exp-seguro.dtincl        = plani.dtincl*/
            tt-exp-seguro.data_operacao = plani.dtincl
            tt-exp-seguro.identificador = videntificador
          /*tt-exp-seguro.motivo_cancelamento = vmotcanc*/.

                    end. /* segtipo */
                end. /* movim */
            end. /* plani */
        end. /* vdata */
    end. /* estab */
end. /* tipmov */

run gera-arq-ffc.

message "Arquivos gerados em" vdir view-as alert-box.

/********
         FFC
********/

procedure cria-registro.

    def var vdata as date.
    def var vmotcanc  as char.

    find tt-exp-seguro where tt-exp-seguro.rec = recid(vndseguro) no-error.
    if avail tt-exp-seguro
    then return.

    assign
        vmotcanc = "".

    find clien of vndseguro no-lock no-error.
    if not avail clien
    then return.

    if vndseguro.tpseguro = 5
    then vseqreg-ffc-5 = vseqreg-ffc-5 + 1.
    else vseqreg-ffc-6 = vseqreg-ffc-6 + 1.

    find tt-estab of vndseguro no-lock no-error.
    if not avail tt-estab
    then do.
        find estab of vndseguro no-lock.
        create tt-estab.
        assign tt-estab.etbcod = vndseguro.etbcod
               tt-estab.etbnom = estab.etbnom
               tt-estab.munic  = estab.munic.
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

    vdata = vndseguro.dtincl.
    if vndseguro.dtcanc <> ?
    then vdata = vndseguro.dtcanc.

    if vndseguro.dtcanc <> ?
    then vmotcanc = if vndseguro.motcanc > 0
                    then string(vndseguro.motcanc,"99")
                    else "09" /* Desconhecido */.

    vpreco = 0.
    find movim where movim.etbcod = vndseguro.etbcod
                 and movim.placod = vndseguro.placod
                 and movim.procod = vndseguro.procod
               no-lock.
    find plani where plani.etbcod = movim.etbcod
                 and plani.placod = movim.placod
               no-lock.
    vpreco = movim.movpc.

    if vndseguro.tpseguro = 6
    then do.
        find estoq where estoq.procod = vndseguro.procod
                     and estoq.etbcod = vndseguro.etbcod
                   no-lock no-error.
        if avail estoq
        then vpreco = estoq.estvenda.
    end.

    videntificador = string(plani.etbcod,"999") +
                     plani.serie + string(plani.numero) +
                     string(vndseguro.tpseguro) +
                     string(vndseguro.movseq, "999").

    create tt-exp-seguro.
    assign
        tt-exp-seguro.rec = recid(vndseguro)
        tt-exp-seguro.tpseguro          = segtipo.tpseguro
        tt-exp-seguro.tipo_registro     = if vndseguro.dtcanc = ?
                                          then "A" else "C"
        tt-exp-seguro.etbcod            = vndseguro.etbcod
        tt-exp-seguro.vencod            = vndseguro.vencod
        tt-exp-seguro.procod            = vndseguro.procod
        tt-exp-seguro.clicod            = vndseguro.clicod
        tt-exp-seguro.tempo             = string(vndseguro.tempo)
        tt-exp-seguro.preco_pro         = vpreco
        tt-exp-seguro.preco_gar         = Valor(vndseguro.prseguro)
        tt-exp-seguro.dtincl            = string(vndseguro.dtincl, "99999999")
        tt-exp-seguro.data_operacao     = vdata
        tt-exp-seguro.identificador     = videntificador
        tt-exp-seguro.motivo_cancelamento = vmotcanc.

end procedure.


procedure gera-arq-ffc:

    def var varq      as char.
    def var vseqarq   as int.
    def var vtempogar as int.

/***
    GARANTIA
***/
message "Gerando arquivos: Garantias ...".

    assign
        varq  = "4146GEPF" + substr(Data(today), 3) + ".TXT".

do on error undo.
    find first tab_ini where tab_ini.parametro = "FFC-ARQ-GARANTIA" no-error.
    if not avail tab_ini
    then do.
        create tab_ini.
        tab_ini.parametro = "FFC-ARQ-GARANTIA".
    end.
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
    vseqreg-ffc-5 "|"
    skip.

for each tt-exp-seguro where tt-exp-seguro.tpseguro = 5 no-lock.
    find produ of tt-exp-seguro no-lock.
    find fabri of produ no-lock.
    find clien of tt-exp-seguro no-lock.

    vtempogar = 0.
    find first produaux where produaux.procod     = produ.procod
                          and produaux.nome_campo = "TempoGar"
                    NO-LOCK no-error.
    if avail produaux 
    then vtempogar = int(produaux.valor_campo).

    put unformatted
        /* 1*/ tt-exp-seguro.tipo_registro
        /* 2*/ "|" tt-exp-seguro.procod
        /* 3*/ "|" produ.pronom
        /* 4*/ "|" Valor(tt-exp-seguro.preco_pro)
        /* 5*/ "|" vtempogar
        /* 6*/ "|" tt-exp-seguro.tempo
        /* 7*/ "|" tt-exp-seguro.preco_gar
        /* 8*/ "|" tt-exp-seguro.vencod
        /* 9*/ "|" tt-exp-seguro.etbcod
        /*10*/ "|" string(tt-exp-seguro.data_operacao, "99999999")
        /*11*/ "|" removeacento(clien.ciccgc)
        /*12*/ "|" removeacento(clien.clinom)
        /*13*/ "|" tt-exp-seguro.dtincl
        /*14*/ "|" removeacento(fabri.fabnom)
        /*15*/ "|"
        /*16*/ "|" tt-exp-seguro.identificador
        /*17*/ "|" removeacento(clien.fone)
        /*18*/ "|" removeacento(clien.fax) /* celular */
        /*19*/ "|" removeacento(clien.zona) /* e-mail */
        /*20*/ "|" if clien.sexo then "M" else "F"
        /*21*/ "|" Data(clien.dtnasc)
        /*22*/ "|" trim(removeacento(clien.endereco[1]) + " " +
                        removeacento(string(clien.numero[1])) + " " +
                        removeacento(clien.compl[1]))
        /*23*/ "|" removeacento(clien.cidade[1])
        /*24*/ "|" removeacento(clien.ufecod[1])
        /*25*/ "|" removeacento(clien.cep[1])
        /*26*/ "|"
        /*27*/ "|"
        /*28*/ "|"
        /*29*/ "|"
        /*30*/ "|"
        /*31*/ "|"
        skip.
end.

/*
    Trailer
*/
put unformatted
    "T"
    "|" vseqreg-ffc-5 + 2
    "|"
    skip.
output close.
unix silent value("unix2dos -q " + vdir + varq).

/***
    RFQ
***/
message "Gerando arquivos: RFQ ...".
    assign
        varq  = "4146RFQ" + substr(Data(today), 3) + ".TXT".

do on error undo.
    find first tab_ini where tab_ini.parametro = "FFC-ARQ-RFQ" no-error.
    if not avail tab_ini
    then do.
        create tab_ini.
        tab_ini.parametro = "FFC-ARQ-RFQ".
    end.

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
    vseqreg-ffc-6 "|"
    skip.

for each tt-exp-seguro where tt-exp-seguro.tpseguro = 6 no-lock.
    find produ of tt-exp-seguro no-lock.
    find fabri of produ no-lock.
    find clien of tt-exp-seguro no-lock.

    vtempogar = 0.
    find first produaux where produaux.procod     = produ.procod
                          and produaux.nome_campo = "TempoGar"
                        NO-LOCK no-error.
    if avail produaux 
    then vtempogar = int(produaux.valor_campo).

    put unformatted
        /* 1*/ tt-exp-seguro.tipo_registro
        /* 2*/ "|" tt-exp-seguro.procod
        /* 3*/ "|" produ.pronom
        /* 4*/ "|" Valor(tt-exp-seguro.preco_pro)
        /* 5*/ "|" vtempogar
        /* 6*/ "|" tt-exp-seguro.preco_gar
        /* 7*/ "|" tt-exp-seguro.vencod
        /* 8*/ "|" tt-exp-seguro.etbcod
        /* 9*/ "|" string(tt-exp-seguro.data_operacao, "99999999")
        /*10*/ "|" clien.ciccgc
        /*11*/ "|" removeacento(clien.clinom)
        /*12*/ "|" tt-exp-seguro.dtincl
        /*13*/ "|" fabri.fabnom
        /*14*/ "|" /* modelo */
        /*15*/ "|"
        /*16*/ "|" tt-exp-seguro.identificador
        skip.
end.

/*
    Trailer
*/
put unformatted
    "T"     "|"
    vseqreg-ffc-6 + 2 "|"
    skip.
output close.
unix silent value("unix2dos -q " + vdir + varq).

/*
  Regionais
*/
message "Gerando arquivos: Tabelas ...".
varq  = "4146GEREG" + substr(Data(today), 3) + ".TXT".
output to value(vdir + varq).

for each tt-reg no-lock by tt-reg.supcod:
    put unformatted
        tt-reg.supcod
        "|" tt-reg.supnom
        "|"
        "|"
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
    find estab of tt-estab no-lock.
    find first tt-etb where tt-etb.etbcod = tt-estab.etbcod no-lock no-error.
    put unformatted
        tt-estab.etbcod
        "|" estab.munic
        "|" if avail tt-etb then tt-etb.supcod else 0
        "|"
        "|"
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
        tt-func.funcod
        "|" tt-func.funnom
        "|" tt-func.etbcod
        "|"
        skip.
end.
output close.
unix silent value("unix2dos -q " + vdir + varq).

/*
  Produtos - enviar os elegiveis
*/
message "Gerando arquivos: Produtos ...".
varq  = "4146GEPRD" + substr(Data(today), 3) + ".TXT".
output to value(vdir + varq).
for each produaux where produaux.Nome_Campo = "TempoGar" no-lock.
    vtempogar = int(produaux.valor_Campo).
    if vtempogar <= 0
    then next.

        find produ of produaux no-lock.
        find fabri of produ no-lock no-error.

        find tt-clase where tt-clase.clacod = produ.clacod no-error.
        if not avail tt-clase
        then do.
            create tt-clase.
            tt-clase.clacod = produ.clacod.
        end.

        put unformatted
            produ.procod
            "|" produ.pronom
            "|" produ.clacod
            "|" if avail fabri then fabri.fabnom else ""
            "|"
            skip.
end.
output close.
unix silent value("unix2dos -q " + vdir + varq).

/*
  Linhas
*/
varq  = "4146GELIN" + substr(Data(today), 3) + ".TXT".
output to value(vdir + varq).

for each tt-clase no-lock.
    find clase of tt-clase no-lock.
    put unformatted
        /*1*/ clase.clacod
        /*2*/ "|" removeacento(clase.clanom)
        /*3*/ "|"
        /*4*/ "|"
        /*5*/ "|"
        /*6*/ "|"
        /*7*/ "|"
        /*8*/ "|"
        /*9*/ "|" substr(removeacento(clase.clanom),1,30)
        skip.
end.
output close.
unix silent value("unix2dos -q " + vdir + varq).

end procedure.

