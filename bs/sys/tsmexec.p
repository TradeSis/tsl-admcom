{cabec.i}
                
def input parameter par-progcod as char.
def input parameter par-funcod  as int.
def input parameter par-mencod  as int.
def output parameter vok as log.

/*** Admcom
if search("../etc/2001.ini") <> ?
then do:
    for each paramsis.
        delete paramsis.
    end.
    input from ../etc/2001.ini no-echo.
    repeat with width 100.
        create paramsis no-error.
        import delimiter "=" paramsis no-error.
    end.
    input close.
end.

for each paramsis where paramsiscod = "".
        delete paramsis.
end.
***/

def buffer ts-func for func.
def buffer ts-menu for menu.
                
                find first ts-func where
                        ts-func.etbcod = setbcod and
                        ts-func.funcod = par-funcod
                        no-lock no-error.
                        
                find first ts-menu where
                        ts-menu.mencod = par-mencod
                        no-lock no-error.

                /*    SEGURANCA */
                vok = yes.
                if not sremoto
                then run sys/tsmsegur.p 
                                (par-progcod,
                                 par-funcod,
                                 ts-menu.mencod,
                                 yes, /* Com mensagem? */
                                 output vok).
                if vok
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.

                    SPROGRAMA = ts-MENU.MENPRO.
                    smencod   = ts-menu.mencod.

                    do for menfun transaction:
                        find first menfun where 
                                menfun.funcod = par-funcod and
                                menfun.mencod = ts-menu.mencod
                                no-error. 
                        if not avail menfun
                        then do:
                            create menfun.
                            menfun.funcod = par-funcod.
                            menfun.mencod = ts-menu.mencod.
                            menfun.dtacess = today.
                            menfun.hrinicio = time.
                        end.
                        menfun.qtdentradas = menfun.qtdentradas + 1.
                    end.

                    if ts-menu.menpar <> ""
                    then
                        if ts-menu.menare <> ""
                        then 
                            run value (ts-menu.menare + "/" +
                                       ts-menu.menpro + ".p") (ts-menu.menpar).
                        else
                            run value(ts-menu.menpro + ".p") (ts-menu.menpar).
                    else
                        if ts-menu.menare <> ""
                        then run value (ts-menu.menare + "/" +
                                       ts-menu.menpro + ".p").
                        else run value(ts-menu.menpro + ".p").
                end.
