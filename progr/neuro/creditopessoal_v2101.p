/* HUBSEG 19/10/2021 */
/*                    
15042021 helio ID 68725 

#1 TP 22418365 - 08.01.17
*/
def input  parameter par-oper    as char.
def input  parameter s-etbcod     as int.
def input  parameter par-clicod  like clien.clicod.
def input  parameter par-valor   as dec.
def output parameter vvlrlimite as dec.
def output parameter par-status  as char init "S".
def output parameter par-mensag  as char.

def new global shared var setbcod    like estab.etbcod.
setbcod = s-etbcod.
{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */
def var par-limite as dec.
def var vvctolimite as date.
def var sal-aberto   like clien.limcrd.
def var sal-abertopr like clien.limcrd.
def var sal-abertohubseg like clien.limcrd.

def var sal-abertoprEP like clien.limcrd.

def var vdisponivel as dec.
def var parcela-paga    as int format ">>>>9".


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
 
    vvlrlimite = 0.
    find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
    if avail neuclien
    then do:
        vvctolimite = neuclien.vctolimite.
        if neuclien.vlrlimite <> ? and
           neuclien.vlrlimite <> 0 and 
           neuclien.vctolimite >= today 
        then vvlrlimite = neuclien.vlrlimite.
    end.

        run /admcom/progr/neuro/comportamento.p (clien.clicod, ?,  
                                   output var-propriedades). 

        sal-aberto   = dec(pega_prop("LIMITETOM")).
        sal-abertopr = dec(pega_prop("LIMITETOMPR")). /* helio 140421 - tomado total */ 

        sal-abertohubseg = dec(pega_prop("LIMITETOMHUBSEG")). /* helio 140421 - tomado total */ 
        if sal-abertohubseg = ? then sal-abertohubseg = 0.
        sal-abertopr = sal-abertopr - sal-abertohubseg.        
        
        sal-abertoprEP = dec(pega_prop("LIMITETOMPREP")). /* helio 130521 - somente do que pegou de ep */
                                                                        
        parcela-paga = int(pega_prop("PARCPAG")).
        
        par-limite = vvlrlimite. /* passo 1 - pega o limite total */

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
        
                par-limite = (vvlrlimite - sal-abertopr + sal-abertoprEP) * (profinparam.perclimite / 100).
                par-limite = if par-limite > profinparam.vlmaximo
                               then profinparam.vlmaximo
                               else par-limite.

        
        vdisponivel = par-limite - sal-abertoprEP.

        if profinparam.vlmaximo <= vdisponivel
        then assign
                vdisponivel = profinparam.vlmaximo.

        vprof-dispo = vdisponivel.
 
        if vdisponivel < 0
        then vdisponivel = 0.
        
        vprof-saldo = vdisponivel.

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

        vprof-avencer = sal-abertoprEP.

        /*** helio. 14042021 - retirado
        for each estab no-lock,
            each titulo where
                    titulo.empcod = 19 and
                    titulo.titnat = no and
                    titulo.modcod = profin.modcod and
                    titulo.etbcod = estab.etbcod and
                    titulo.clifor = clien.clicod and
                    titulo.titdtpag = ? 
                    no-lock.
            vprof-avencer = vprof-avencer + titulo.titvlcob.
        end.

        /*** Saldo do PRODUTO ***/
        if vprof-avencer > profinparam.vlmaximo
        then do:
            message "NEXT vprof-avencer > profinparam.vlmaximo " vprof-avencer profinparam.vlmaximo.
            next. 
        end.            
        ***/
        
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

