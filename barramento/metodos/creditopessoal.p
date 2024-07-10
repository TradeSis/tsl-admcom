/*
#1 TP 22418365 - 08.01.17
*/
def input  parameter par-oper    as char.
def input  parameter setbcod     as int.
def input  parameter par-clicod  like clien.clicod.
def input  parameter par-valor   as dec.
def output parameter par-limite  as dec.
def output parameter par-status  as char init "S".
def output parameter par-mensag  as char.

def var vcpf    as char.
def var vdtnasc as date.
def var vidade  as int.
def var vok     as log.
def var vprof-avencer as dec. /* #1 */
def var vprof-dispo   as dec. /* #1 */
def var vprof-saldo   as dec. /* #1 */

def SHARED temp-table tt-profin
    field codigo     as int
    field nome       as char
    field avencer    as dec
    field disponivel as dec
    field saldo      as dec
    field modcod     as char
    field tfc        as dec
    field token      as log
    field deposito   as char
    field codsicred  as int.

/*** ***/

def NEW shared temp-table tp-titulo like fin.titulo
    index dt-ven titdtven 
    index titnum /*is primary unique*/ empcod  
                                   titnat  
                                   modcod  
                                   etbcod 
                                   clifor 
                                   titnum  
                                   titpar.


/* PDV hiscli2.p */
def NEW SHARED var pagas-db as int.

def NEW SHARED var maior-atraso as int /***like plani.pladat***/.
def NEW SHARED var vencidas like clien.limcrd.
def NEW SHARED var v-mes as int format "99".
def NEW SHARED var v-ano as int format "9999".
def NEW SHARED var v-acum like clien.limcrd.
def NEW SHARED var qtd-contrato as int format ">>>9".
def NEW SHARED var parcela-paga    as int format ">>>>9".
def NEW SHARED var parcela-aberta  as int format ">>>>9".
def NEW SHARED var qtd-15       as int format ">>>>9".
def NEW SHARED var qtd-45       as int format ">>>>9".
def NEW SHARED var qtd-46       as int format ">>>>9".
def NEW SHARED var vrepar       as log format "Sim/Nao".
def NEW SHARED var v-media      like clien.limcrd.
def NEW SHARED var ult-compra   like plani.pladat.
def NEW SHARED var sal-aberto   like clien.limcrd.
def NEW SHARED var lim-calculado like clien.limcrd format "->>,>>9.99".
def NEW SHARED var cheque_devolvido like plani.platot.
def NEW SHARED var vclicod like clien.clicod.
def NEW SHARED var vtotal like plani.platot.
def NEW SHARED var vqtd        as int.
def NEW SHARED var proximo-mes like clien.limcrd.

/*** CREDSCORE - 17/05/2016 ***/
def var vcalclim as dec.
def var vpardias as dec.
def var vdisponivel as dec.

def NEW shared temp-table tt-dados
    field parametro as char
    field valor     as dec
    field valoralt  as dec
    field percent   as dec
    field vcalclim  as dec
    field operacao  as char format "x(1)" column-label ""
    field numseq    as int
    index dado1 numseq.

/*** ***/

find clien where clien.clicod = par-clicod no-lock.

/*** validacao de cliente ***/
assign
    vcpf    = clien.ciccgc
    vdtnasc = clien.dtnasc.

run cpf.p (vcpf, output vok).
if not vok
then run erro ("CPF invalido").
else if vdtnasc = ?
then run erro ("Data de Nascimento Invalida").
else do.
    vidade = year(today) - year(vdtnasc).
    if vidade < 16 or vidade > 89
    then run erro ("Data de Nascimento Invalida: + string(vdtnasc)").
end.

if par-status = "E"
then return.

    run ./progr/hiscli.p (clien.clicod).

    run calccredscore.p (input string(setbcod),
                         input recid(clien),
                         output vcalclim,
                         output vpardias,
                         output vdisponivel).

    par-limite = vcalclim - sal-aberto.

    for each profin where profin.situacao no-lock.
        find first profinparam where profinparam.fincod  = profin.fincod
                                 and profinparam.etbcod  = setbcod
                                 and profinparam.dtinicial <= today
                                 and (profinparam.dtfinal = ? or
                                      profinparam.dtfinal >= today)
                              no-lock no-error.
        if not avail profinparam
        then find first profinparam where profinparam.fincod = profin.fincod
                                 and profinparam.etbcod  = 0
                                 and profinparam.dtinicial <= today
                                 and (profinparam.dtfinal = ? or
                                      profinparam.dtfinal >= today)
                              no-lock no-error.
        if not avail profinparam
        then do:
            next.
        end.    

        vdisponivel = par-limite * (profinparam.perclimite / 100).

        /*** Valor minimo ***/
        if profinparam.vlminimo > vdisponivel
        then do:
            next.
        end.    

        /*** Parcelas pagas ***/
        if profinparam.parcpagas > 0 and
           profinparam.parcpagas > parcela-paga
        then do:
            next.
        end.    

        /*** Tempo de relacionamento **/
        if profinparam.temporel > 0 and
           clien.dtcad > today - profinparam.temporel
        then do:
            next.
        end.    

        vprof-avencer = 0.
        for each estab no-lock,
            each titulo where
                    titulo.empcod = 19 and
                    titulo.titnat = no and
                    titulo.modcod = profin.modcod and
                    titulo.etbcod = estab.etbcod and
                    titulo.clifor = clien.clicod and
                    titulo.titdtpag = ? 
                    no-lock.
            vprof-avencer = vprof-avencer + titulo.titvlcob - titulo.titvlpag.
        end.
        /*** Saldo do PRODUTO ***/
        if vprof-avencer > profinparam.vlmaximo
        then do:
            next.
        end.            

        if profinparam.vlmaximo <= vdisponivel
        then assign
                vprof-dispo = profinparam.vlmaximo
                vprof-saldo = profinparam.vlmaximo - vprof-avencer. /*#1*/
        else assign
                vprof-dispo = vdisponivel
                vprof-saldo = vdisponivel.

        if par-valor > vprof-saldo
        then do:
            next.
        end.    

        create tt-profin.
        assign
            tt-profin.codigo    = profin.fincod
            tt-profin.nome      = profin.findesc
            tt-profin.modcod    = profin.modcod
            tt-profin.disponivel = vprof-dispo
            tt-profin.deposito  = profin.obrigadeposito
            tt-profin.token     = par-valor >= profin.limite_token
            tt-profin.saldo     = vprof-saldo
            tt-profin.codsicred = profin.codigo_sicred
            tt-profin.avencer   = vprof-avencer.
    end.

/***
find first tt-profin no-lock no-error.
if avail tt-profin
then do.
    /*** Saldo por produto financeiro ***/
    /*** Nao tem indice no banco ***/
    for each titulo where titulo.clifor   = clien.clicod
                      and titulo.titdtpag = ?
                    no-lock.
        find first tt-profin where tt-profin.modcod = titulo.modcod
                no-error.
        if avail tt-profin
        then assign
                tt-profin.avencer = tt-profin.avencer +
                                    titulo.titvlcob - titulo.titvlpag.
    end.

    for each tt-profin.
        tt-profin.saldo = tt-profin.disponivel /*- tt-profin.avencer*/.
        if tt-profin.saldo <= 0 or
           par-valor > tt-profin.saldo /*** Deixa somente disponiveis  ***/
        then delete tt-profin.
    end.
end.
***/

/*** ATE TER UMA LOGICA MAIS BEM DEFINIDA 
     SE TEM SALDO PARA FACIL SOMENTE MOSTRA ESTE
***/
if par-valor > 0
then do.
    find first tt-profin where tt-profin.codigo = 8000
                           and tt-profin.saldo > par-valor
                           no-lock no-error.
    if avail tt-profin
    then do.
        find first tt-profin where tt-profin.codigo = 8001 no-error.
        if avail tt-profin
        then delete tt-profin.
    end.
end.


procedure erro.
    def input parameter par-erro as char.

    assign
        par-status = "E"
        par-mensag = par-erro.

end procedure.

