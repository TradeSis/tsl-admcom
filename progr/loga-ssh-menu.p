def var vsenha like func.senha.
def var vpropath        as char format "x(150)".
def var vtprnom         as char. /* like tippro.tprnom.   */
input from /admcom/linux/propath no-echo.  /* Seta Propath */
set vpropath with width 200 no-box frame ff.
input close.
propath = vpropath + ",\dlc".
{/admcom/progr/admcab.i.ssh new}

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

setbcod = int(SESSION:PARAMETER).

find admcom where admcom.cliente = scliente no-lock.
wdata = today.

on F5 help.
on PF5 help.
on PF7 help.
on F7 help.
on f6 help.
on PF6 help.
def var vfuncod like func.funcod.

do on error undo, return on endkey undo, retry:
    vsenha = "".
    update vfuncod label "Matricula"
           vsenha blank with frame f-senh side-label centered row 10.
    if vfuncod = 0 and
       vsenha  = "edpro"
    then next.
    find first func where func.funcod = vfuncod and
                          func.etbcod = 999      and
                          func.senha  = vsenha no-lock no-error.
    if not avail func
    then do:
        message "Funcionario Invalido.".
        undo, retry.
    end.
    else sfuncod = func.funcod.
end.
if setbcod = 0
then setbcod = estab.etbcod.

find estab where estab.etbcod = setbcod no-lock.
find first wempre no-lock.
display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
 + "-" + trim(func.funnom)  @  wempre.emprazsoc
                    wdata with frame fc1.

ytit = fill(" ",integer((30 - length(wtittela)) / 2)) + wtittela.

def temp-table tt-sshmenu like sshmenu
        index i1 aplicod menniv ordsup menord
        index i2 ordsup menord.

for each sshmenu no-lock.
    create tt-sshmenu.
    buffer-copy sshmenu to tt-sshmenu.
    tt-sshmenu.mentit = caps(tt-sshmenu.mentit).
end.

def new shared frame f-linha.    
form    tt-sshmenu.menord
        tt-sshmenu.mentit format "x(30)"
        with frame f-linha 10 down no-label row 4 width 38.

form    tt-sshmenu.menord
        tt-sshmenu.mentit format "x(30)"
        with frame f-linha1 15 down no-label row 4 column 40 width 38
        overlay
        .
         
{setbrw.i}

assign
    a-seeid = -1 a-recid = -1 a-seerec = ?.

l1:
repeat:

    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?.

    hide frame f-linha no-pause.
    clear frame f-linha all.

    {sklclstb.i  
        &color = with/cyan
        &file = tt-sshmenu  
        &cfield = tt-sshmenu.mentit
        &noncharacter = /* 
        &ofield = " tt-sshmenu.mentit 
                    tt-sshmenu.menord "
        &aftfnd1 = " "
        &where  = " tt-sshmenu.ordsup = 0 "
        &aftselect1 = " 
                        a-recid = recid(tt-sshmenu).
                        find sshmenu where
                             sshmenu.aplicod = tt-sshmenu.aplicod and
                             sshmenu.menniv  = tt-sshmenu.menniv  and
                             sshmenu.ordsup  = tt-sshmenu.ordsup  and
                             sshmenu.menord  = tt-sshmenu.menord
                             no-lock no-error.
                           
                        run loga-ssh-menu-n2.p(recid(sshmenu)).
                        
                        view frame f-linha. pause 0.    
                        next keys-loop. 
                        
                      "
        &go-on = TAB 
        &naoexiste1 = "  leave l1. "  
        &otherkeys1 = " if keyfunction(lastkey) = ""CLEAR""
                        then do:
                            run mansshmenu.p.
                            next l1.
                        end.    
                        "
        &locktype = " no-lock use-index i2 "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.

procedure loga-ssh-menu-n2.
    def var vprograma as char.
    l2:
    repeat:

    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?.
        
    hide frame f-linha1 no-pause.
    clear frame f-linha1 all.

    {sklclstb.i  
        &color = with/cyan
        &file = tt-sshmenu  
        &cfield = tt-sshmenu.mentit
        &noncharacter = /* 
        &ofield = " tt-sshmenu.mentit " 
                    tt-sshmenu.menord "
        &aftfnd1 = " "
        &where  = " tt-sshmenu.ordsup = sshmenu.menord "
        &aftselect1 = " 
                        if tt-sshmenu.menpro <> """"
                        then do:
                            vprograma = tt-sshmenu.menpro + "".p"".
                            if search(vprograma) <> ?
                            then
                            run value(tt-sshmenu.menpro + "".p""). 
                            else do:
                                bell.
                                message color red/with
                                ""Programa "" vprograma "" não disponível""
                                view-as alert-box.
                            end.
                        end.
                        else do:
                            bell.
                            message color red/with
                            ""Programa "" vprograma "" não disponível""
                            view-as alert-box.
                        end.
                        "
        &go-on = TAB 
        &naoexiste1 = "  leave l2. "  
        &otherkeys1 = " next keys-loop. "
        &locktype = " no-lock use-index i2 "
        &form   = " frame f-linha1 "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        
        leave l2.       
    END.
    end.

    hide frame f-linha1 no-pause.
    clear frame f-linha1 all.
end procedure.
