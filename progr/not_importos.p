{admcab.i}

def buffer betiqpla for etiqpla.

def temp-table tt-os
    field procod like asstec.oscod
    field qtde   as int
    field forcod like asstec.forcod.

def temp-table tt-audit
    field oscod  like asstec.oscod
    field procod like asstec.procod
    field codigo as char.

def var mopcao as char extent 2 format "x(25)"
    init [" Importar OS ", " Importar Auditoria"].

disp mopcao with frame f-opcao no-label centered title " Importacao ".
choose field mopcao with frame f-opcao.
if frame-index = 1
then run importa-os.
else if frame-index = 2
then run importa-audit.

procedure importa-os.

def var vpasta   as char.
def var varquivo as char.
def var vct      as int.
def var vqtd     as int. 
def var voscod   like asstec.oscod.

def buffer basstec for asstec.

vpasta   = "/admcom/TI/leote/CriarOS/".
varquivo = "".

update
    vpasta   label "Pasta"   format "x(40)"
    varquivo label "Arquivo" format "x(40)"
    with frame f-os side-label.

find first asstec where asstec.osobs     = varquivo no-lock no-error.
if avail asstec
then do.
    message "Arquivo ja importado" view-as alert-box.
    return.
end.
    
input from value(vpasta + varquivo).
repeat.
    create tt-os.
    import delimiter ";" tt-os.
end.
input close.

for each tt-os where tt-os.procod > 0 no-lock.
    find produ of tt-os no-lock no-error.
    if not avail produ
    then do.
        message "Produto nao cadastrado:" tt-os.procod tt-os.qtde
                view-as alert-box.
        return.
    end.
end.

find last basstec where basstec.oscod < 900000 no-lock no-error.
if avail basstec
then voscod = basstec.oscod + 1.
else voscod = 1.

disp voscod label "OS inicial".

for each tt-os where tt-os.procod > 0 no-lock.
    vqtd = vqtd + tt-os.qtd.
end.

sresp = no.
message "Confirma criar" vqtd "OSs?" update sresp.
if not sresp
then return.

for each tt-os where tt-os.procod > 0 no-lock.
    disp tt-os.
    disp tt-os.qtde (total) voscod.
    pause 0.

    do vct = 1 to tt-os.qtd.
        create asstec.
        assign
            asstec.etopecod  = 1
            asstec.oscod     = voscod
            asstec.etbcod    = 998
            asstec.etbcodatu = 998
            asstec.forcod    = tt-os.forcod
            asstec.datexp    = 01/01/2013
            asstec.procod    = tt-os.procod
            asstec.osobs     = varquivo
            asstec.serie     = "N" /* Confinado */
            asstec.pladat    = today.
        voscod = voscod + 1.

        if asstec.forcod > 0
        then do.
            create etiqpla.
            assign
                etiqpla.etbplani = 0
                etiqpla.plaplani = ?
                etiqpla.data     = asstec.datexp
                etiqpla.hora     = time
                etiqpla.oscod    = asstec.oscod
                etiqpla.etopeseq = 2
                etiqpla.etmovcod = 2
                
                asstec.etopeseq  = 2.
        end.
    end.        /* vct */
end.

disp voscod @ vct label "OS final".
pause.

end procedure.

procedure importa-audit.

def var vpasta   as char.
def var varquivo as char.
def var vct      as int.
def var vqtd     as int. 
def var voscod   like asstec.oscod.
def var vdata    as date.

def buffer basstec for asstec.

vpasta   = "/admcom/TI/ssc/".

disp
    "Formato: codigo da OS;codigo do produto "
    with frame f-os side-label.

update
    vpasta   label "Pasta"   format "x(40)"
    varquivo label "Arquivo" format "x(40)"
    vdata    label "Data da auditoria"
             validate(vdata <> ? and vdata <= today,"")
    with frame f-os side-label.

input from value(vpasta + varquivo).
repeat.
    create tt-audit.
    import delimiter ";" tt-audit.
end.
input close.

for each tt-audit where tt-audit.oscod > 0.
    find asstec where asstec.oscod = tt-audit.oscod no-lock no-error.
    if not avail asstec
    then do.
        message "OS nao encontrada:" tt-audit.oscod view-as alert-box.
        return.
    end.
    if asstec.procod <> tt-audit.procod
    then do.
        message "Produto divergente na OS" asstec.oscod
                "OS=" asstec.procod "Audit=" tt-audit.procod
            view-as alert-box.
        return.
    end.
    if asstec.dtsaida <> ?
    then do.
        message "OS ja encerrada" tt-audit.oscod view-as alert-box.
        return.
    end.
end.

for each tt-audit where tt-audit.oscod > 0 no-lock.

    find first asstec_aux where asstec_aux.oscod      = tt-audit.oscod and
                                asstec_aux.nome_campo = "Auditoria"
                          no-error.
    if not avail asstec_aux
    then do.
        create asstec_aux.
        assign
            asstec_aux.oscod      = tt-audit.oscod
            asstec_aux.nome_campo = "Auditoria".
    end.
    assign
        asstec_aux.Data_campo  = vdata
        asstec_aux.datexp      = today
        asstec_aux.valor_campo = "Funcod="   + string(sfuncod) +
                                 "|Arquivo=" + varquivo +
                                 "|Hora="    + string(time, "hh:mm:ss") +
                                 "|Codigo="  + tt-audit.codigo.

    /***
    ***/
    find asstec where asstec.oscod = tt-audit.oscod.
    if asstec.etbcodatu = 998
    then do.
        find last etiqpla of asstec no-lock no-error.
        if avail etiqpla
        then do.
            if etiqpla.etmovcod = 2 /* EnvAss */
            then do.
                /* Cria Retorno do Posto */
                create betiqpla.
                assign
                    betiqpla.etbplani = 0
                    betiqpla.plaplani = ?
                    betiqpla.data     = etiqpla.data
                    betiqpla.hora     = etiqpla.hora + 60
                    betiqpla.oscod    = asstec.oscod
                    betiqpla.etopecod = etiqpla.etopecod
                    betiqpla.etmovcod = 6.

                if asstec.etopecod = 1
                then betiqpla.etopeseq = 3.

                if asstec.etopecod = 2
                then betiqpla.etopeseq = 5.

                asstec.etopeseq  = betiqpla.etopeseq.
            end.
        end.
    end.
end.

message "Arquivo importado" view-as alert-box.

end procedure.
