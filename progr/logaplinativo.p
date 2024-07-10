/*
*
*    Esqueletao de Programacao
*
*/

/*----------------------------------------------------------------------------*/
def var vsenha like func.senha format "x(10)".
def var vpropath        as char format "x(150)".
def var vtprnom         as char. /* like tippro.tprnom.   */
def var vetbcod as int.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
set vpropath with width 200 no-box frame ff.
input close.
propath = vpropath + ",\dlc".
{/admcom/progr/admcab.i new}

def var funcao          as char.
def var parametro       as char.
def var v-ok            as log.
def var vok             as log.

input from /admcom/work/admcom.ini no-echo.
repeat:
    set funcao parametro.
    if funcao = "ESTAB"
    then setbcod = int(parametro).
    if funcao = "CAIXA"
    then scxacod = int(parametro).
    if funcao = "CLIEN"
    then scliente = parametro.
    if funcao = "RAMO"
    then stprcod = int(parametro).
    else stprcod = ?.
end.
input close.

find admcom where admcom.cliente = scliente no-lock.
wdata = today.

on F5 help.
on PF5 help.
on PF7 help.
on F7 help.
on f6 help.
on PF6 help.
def var vfuncod like func.funcod.

if num-entries(sparam,";") > 1
then
if entry(1,sparam,";") = "sv-ca-dbr.lebes.com.br"
then do:
    find aplicativo where aplicativo.aplicod = "RELAT" no-lock no-error.
    if avail aplicativo
    then do:
        
        find first dbrfunc where dbrfunc.user_id = userid("ger")
                 no-lock no-error.
        if not avail dbrfunc
        then do:
            message color red/with
            "Usuario " userid("ger") "não cadastrado para acressar o DBR."
             view-as alert-box.
            
            quit.
        end.
        else sfuncod = dbrfunc.funcod.
                    
        if sfuncod > 0
        then run logmenp1.p( input "RELAT",input 0 ).
    end.
    else
        message "Aplicativo de relatorios não disponível." view-as alert-box.
    quit.        
end.

if num-entries(sparam,";") = 3
then do.
    vetbcod = int(entry(3,sparam,";")) no-error.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if avail estab
    then setbcod = vetbcod.
end.    
        
do on error undo, return on endkey undo, retry:
    vsenha = "".
    update vfuncod label "Matricula"
           vsenha blank with frame f-senh side-label centered row 10.
    if vfuncod = 0 and
       vsenha  = "proedlinx"
    then next.
    find first func where func.funcod = vfuncod and
                          (func.etbcod = 999     or
                           func.etbcod = setbcod) and
                          func.senha  = vsenha
                    no-lock no-error.
    if not avail func
    then do:
        message "Funcionario Invalido.".
        undo, retry.
    end.
    else sfuncod = func.funcod.
end.

if num-entries(sparam,";") > 1
then
if entry(1,sparam,";") = "sv-ca-dbr.lebes.com.br"
then.
else do transaction:
    find first acesso where acesso.etbcod = func.etbcod
                        and acesso.funcod = func.funcod no-error.
    if not avail acesso
    then do:
        create acesso.
        acesso.etbcod = func.etbcod.
        acesso.funcod = func.funcod.
    end.
    else do:    
        if acesso.qtdace < 0
        then acesso.qtdace = 0.
        
        if (acesso.qtdace + 1) > 4 and
            func.funcod <> 101 
        and func.funcod <> 65
        and func.funcod <> 323
        and func.funcod <> 508
        and func.funcod <> 1123
        then do:
            message "Numero de Secoes abertas para este usuario excedida.".
            pause 5 no-message. quit.
        end.
        else acesso.qtdace = acesso.qtdace + 1.
    end.
    
    find first acesso where acesso.etbcod = func.etbcod
                  and acesso.funcod = func.funcod no-lock no-error.
end.

find estab where estab.etbcod = setbcod no-lock.
find first wempre no-lock.
display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
 + "-" + trim(func.funnom)
 
 /* +
                    " /CAIXA - " + string(scxacod) +
                    " " + string(vtprnom,"x(18)") */ @  wempre.emprazsoc
                    wdata with frame fc1.

ytit = fill(" ",integer((30 - length(wtittela)) / 2)) + wtittela.

def var recatu1         as recid.
def var v-down           as int.

    v-down = 0.
    for each aplicativo where aplicativo.ativo = no NO-LOCK:
        v-down = v-down + 1.
    end.

if not connected("suporte")
then do.
    message "Nao conectado o banco Suporte. Informe o CPD".
        pause 4 no-message.
    quit.
end.
            /*
if sfuncod = 1101 or  /* CLAUDIR */
   sfuncod = 65 or   /* JOÃO */
   sfuncod = 96 or   /* FERNANDO JACKS */
   sfuncod = 77 or   /* TIAGO */
   sfuncod = 189 or  /* CAMILA */
   sfuncod = 151 or  /* DIEGO LAU */
   sfuncod = 147 or  /* RODRIGO TELEFONIA */
   sfuncod = 152 or  /* ANDRESSA CONFECCAO */
   sfuncod = 219 or  /* KEILE CRM */
   sfuncod = 163 or  /* JESSICA CRM */
   sfuncod = 168 or  /* FELIPE CONFECCAO */
   sfuncod = 206 or  /* JULIANA FLORES */
   sfuncod = 90 or   /* LUIS BROCCA */
   sfuncod = 133 or  /* EDUARDO */
   sfuncod = 223 or  /* BENITO */
   sfuncod = 52 or   /* RAFAEL ANTUNES */
   sfuncod = 66 or   /* DIEGO MILLER */
   sfuncod = 103     /* MARCIO TAVARES */
then    
run menumais.p.
              */
bl-princ:
repeat:

/*** relatorios ***/

hide frame fc1 no-pause.
hide frame fc2 no-pause.
wtitulo  = "                             ADMCOM VERSAO 2.0".
display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
 + "-" + trim(func.funnom)
 
 /* +
                    " /CAIXA - " + string(scxacod) +
                    " " + string(vtprnom,"x(18)") */ @  wempre.emprazsoc
                    wdata with frame fc1.

display wtitulo                with frame fc2.

ytit = fill(" ",integer((30 - length(wtittela)) / 2)) + wtittela.

/*******/

display "" with frame ff1
            1 down centered no-labels
                color normal row 4 width 60 no-box.
display "" with frame ff2
             1 down centered no-labels
                color normal row 5 + v-down width 60 no-box.

    if recatu1 = ?
    then
        find first APLICATIVO where aplicativo.ativo = no and
                   not can-find( aplifun where aplifun.funcod = func.funcod and
                                 aplifun.aplicod = aplicativo.aplicod) 
                                    no-lock no-error.
    else find APLICATIVO where recid(APLICATIVO) = recatu1 no-lock.
    if not available APLICATIVO
    then leave.
    clear frame frame-a all no-pause.
    display
        APLICATIVO.APLINOM at 20
            with frame frame-a v-down down centered no-labels
                color white/blue row 5 width 60 no-box.

    recatu1 = recid(APLICATIVO).
    repeat:
        find next APLICATIVO where aplicativo.ativo = no and
                   not can-find( aplifun where aplifun.funcod = func.funcod and
                       aplifun.aplicod = aplicativo.aplicod) no-lock no-error.
        if not available APLICATIVO
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        display
            APLICATIVO.APLINOM
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        hide frame f-senha.
        find APLICATIVO where recid(APLICATIVO) = recatu1 no-lock.
        put screen row 24 column 1 string(aplicativo.aplihel,"x(80)")
            color black/cyan.
        on F5 get.
        on f10 delete-line.
        choose field APLICATIVO.APLINOM color message
            go-on(cursor-down cursor-up
                  cursor-left cursor-right PF5 F5 PF10 F10
                  tab PF4 F4 ESC return).
        hide message no-pause.
        if keyfunction(lastkey) = "get"
        then do WITH FRAME F-F5 ROW 20 COLUMN 56 SIDE-LABEL overlay
                    on endkey undo, retry.
            disp setbcod @ estab.etbcod.
            prompt-for estab.etbcod.
            find estab using estab.etbcod no-lock no-error.
            hide frame f-f5 no-pause.
            if not avail estab
            then do:
                next.
            end.
            setbcod = input estab.etbcod.
            disp trim(caps(wempre.emprazsoc)) + "/" +
                      trim(caps(estab.etbnom)) @ wempre.emprazsoc wdata
                      with frame fc1.
        end.
        on F5 help.
        hide message no-pause.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next APLICATIVO where aplicativo.ativo = no and
                   not can-find( aplifun where aplifun.funcod = func.funcod  and
                       aplifun.aplicod = aplicativo.aplicod) no-lock no-error.
            if not avail APLICATIVO
            then next.
            color display white/blue
                APLICATIVO.APLINOM.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev APLICATIVO where aplicativo.ativo = no and
                   not can-find( aplifun where aplifun.funcod = func.funcod and
                       aplifun.aplicod = aplicativo.aplicod) no-lock no-error.
            if not avail APLICATIVO
            then next.
            color display white/blue
                APLICATIVO.APLINOM.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do on error undo:
            find acesso where acesso.etbcod = func.etbcod
                          and acesso.funcod = func.funcod no-error.
            if avail acesso
            then acesso.qtdace = acesso.qtdace - 1.
            quit.
        end.

        if keyfunction(lastkey) = "return" or
           keyfunction(lastkey) = "cursor-right"
        then do on error undo, retry on endkey undo, leave.
            v-ok = no.
            for each menu where menu.aplicod = aplicativo.aplicod and
                not can-find(admaplic
                        where admaplic.cliente = scliente and
                              admaplic.aplicod = aplicativo.aplicod and
                              admaplic.menniv  = 1        and
                              admaplic.ordsup  = 0        and
                              admaplic.menord  = menu.menord) and
                    menniv = 1 no-lock:
                v-ok = yes.
                leave.
            end.
            if not v-ok
            then do:
                message "MODULO NAO DISPONIVEL".
                next.
            end.
            hide frame ff1.
            hide frame ff2.
            hide frame f-senha.
            vok = yes.

            if aplicativo.aplicod = "labo"
            then do:
                vsenha = "".
                update vsenha blank with frame f-senha side-label overlay
                                    centered.
                if vsenha <> "senha"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
                /* run senha.p(output vok). */
                hide frame f-senha.
            end.
            
            /**  relatorios ****/
            if aplicativo.aplicod = "relat"
            then do:
                unix silent value("ssh dbr").
                vok = no.
            end.
            /*******/

            if vok = yes
            then do:
              run logmenp1.p( input aplicativo.aplicod,input 0).
            end.
            
            hide all no-pause.
            view frame ff1.
            view frame ff2.
            view frame fc1.
            view frame fc2.
        end.
        
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        if keyfunction(lastkey) = "GET"
        then do with frame fs row 20 col 56 side-labels overlay
            on endkey undo, retry.
            display setbcod @ estab.etbcod.
            prompt-for estab.etbcod.
            find estab using estab.etbcod no-lock no-error.
            hide frame fs no-pause.
            if not available estab
            then next.
            setbcod = input estab.etbcod.
            display trim(caps(wempre.emprazsoc)) + "/" +
                        trim(caps(estab.etbnom)) @ wempre.emprazsoc
                    wdata with frame fc1.
        end.
        display APLICATIVO.APLINOM
                    with frame frame-a.
        recatu1 = recid(aplicativo).

        if num-entries(sparam,";") > 1
        then status default "CUSTOM Business Solutions         Servidor: "
                + entry(1,sparam,";").
        else status default "CUSTOM Business Solutions        ".
   end.
end.
return.
 
