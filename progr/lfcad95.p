{admcab.i }
def var varquivo as char.
def var outras-icms as dec format "->>>,>>9.99".
def var vetbcod  like estab.etbcod.
def var nu as int.
def var vvlcont as dec format ">>>>>.99".
def var vlannum as int.
def var i       as int.
def var wni     as int.
def var ni      as int.
def var nf      as int.
def var vdt     as date format "99/99/9999".
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
def stream sarq.

update vetbcod with frame f1.
find estab where estab.etbcod = vetbcod no-lock.
display estab.etbnom no-label with frame f1.
update vdti label "Data Inicial" colon 16
       vdtf label "Data Final" with frame f1 side-label width 80.


def temp-table wforne
    field wforcod like forne.forcod
    field wfornom like forne.fornom
    field wforcgc like forne.forcgc
    field wuf     like forne.ufecod.

def var d-dtini     as   date init today                            no-undo.
def var i-nota      like fiscal.numero                               no-undo.
def var i-seq       as   int format ">>>9"                          no-undo.
def var vcgc as char format "xx.xxx.xxx/xxxx-xx".
def var vemp as int.
for each wforne.
    delete wforne.
end.


output to printer page-size 0.
    for each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 04 and
                         plani.pladat >= vdti - 30 and
                         plani.pladat <= vdtf + 30 no-lock by plani.numero:
                         
        if plani.datexp >= vdti and
           plani.datexp <= vdtf
        then.
        else next.
        
        find forne where forne.forcod = plani.emite no-lock no-error.
        if not avail forne
        then next.
        vcgc = string(forcgc,"xx.xxx.xxx/xxxx-xx").
        vemp = estab.etbcod.
        if estab.etbcod = 1
        then vemp = 50.

        if estab.etbcod = 995
        then vemp = 122. 
        if estab.etbcod = 996
        then vemp = 54.
        if estab.etbcod = 997
        then vemp = 51.
        if estab.etbcod = 98
        then vemp = 53.
        if estab.etbcod = 999
        then vemp = 52.

        find first suporte.lfcad 
                   where suporte.lfcad.cgc = vcgc /* and
                         suporte.lfcad.empcod = vemp */ no-error.
        if not avail suporte.lfcad or vcgc = ""
        then do:
            find first wforne where wforne.wforcod = forne.forcod no-error.
            if not avail wforne
            then create wforne.
            assign wforne.wforcod = forne.forcod
                   wforne.wfornom = forne.fornom
                   wforne.wforcgc = forne.forcgc
                   wforne.wuf     = forne.ufecod.
        end.
        else do:
        
            display plani.numero(count)
                    plani.datexp format "99/99/9999"
                    plani.platot(total)
                    plani.emite
                    suporte.lfcad.codigo with frame ff down.
        
        end.
        
    end.
output close.

    /*
    for each wforne:
        disp wforne.
    end.
    */
    


