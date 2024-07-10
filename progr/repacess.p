
{admcab.i}.
{anset.i}.

def var vfuncod     like func.funcod.
def var vfuncodd    like func.funcod.
def buffer dfunc    for func.
def buffer daplifun for aplifun.
def buffer dadmaplic for admaplic.
def buffer bmenu    for menu.
DEF VAR v-cont      AS INT.
DEF VAR v-cod       AS INT.

form
    vfuncod
    func.funnom no-label
    with frame f-original
        centered 1 down side-labels title "Funcionario ORIGINAL" row 7.

form
    vfuncodd
    dfunc.funnom no-label
    with frame f-destino
        centered 1 down row 10 side-labels title "Funcionario DESTINO". 

def temp-table tt-func
    field funcod like func.funcod format ">>>>9".

form
    an-seelst format "x" column-label "*" 
    dfunc.funcod        format ">>>>9"
    dfunc.funnom
    dfunc.funfunc
        help "ENTER=Seleciona  F4=Confirma"
    with frame f-funcao
        centered
        row 8        color withe/brown
        title color red/withe " POR FUNCAO "
        down.

DEF VAR vopc AS CHAR EXTENT 2 INITIAL ["CODIGO"," FUNCAO "].

FORM
    vopc[1]
    vopc[2]
    WITH FRAME f-opc
        CENTERED ROW 10 NO-LABELS 1 DOWN.

def buffer cfunc for func.
def var vetbcod like estab.etbcod .
vetbcod = setbcod.
update vetbcod label "Filial" with frame f-etb 
    1 down side-label width 80.
find estab where estab.etbcod = vetbcod no-lock.
disp estab.etbnom no-label
    with frame f-etb.
repeat :

    assign vfuncod = 0 vfuncodd = 0 .
    
    update
        vfuncod 
        with frame f-original.
        
    find first func where func.funcod = vfuncod  and
                        func.etbcod = vetbcod no-lock no-error.
    if not avail func
    then do :
        bell. bell.
        message "Codigo do Funcionario digitado invalido".
        pause. clear frame f-original all.
        next.
    end.
    disp func.funnom with frame f-original.
    /*
    DISP vopc WITH FRAME f-opc.
    CHOOSE FIELD vopc WITH FRAME f-opc.

    CLEAR FRAME f-opc ALL.
    HIDE FRAME f-opc.

    IF FRAME-INDEX = 1 
    THEN*/ DO :           
        update 
        vfuncodd
        with frame f-destino.
        
        find first dfunc where dfunc.funcod = vfuncodd and
                               dfunc.etbcod = vetbcod no-lock no-error.
        if not avail dfunc
        then do :
            bell. bell.
            message "Codigo do Funcionario digitado invalido".
            pause. clear frame f-destino all.
            next.
        end.
        disp dfunc.funnom with frame f-destino.       

        message "Confirma Alteracao de " dfunc.funnom update sresp.
    
        if sresp = yes
        then do :
            disp "Aguarde, Atualizando Permissoes - " dfunc.funnom with frame f-m
                centered row 15 no-labels color white/red. pause 0.
            for each aplifun where aplifun.funcod = dfunc.funcod :
                delete aplifun.
            end.
            for each admaplic where admaplic.cliente = string(dfunc.funcod) :
                delete admaplic.
            end.
            for each aplifun where aplifun.funcod = func.funcod no-lock :
                find first cfunc where cfunc.funcod = aplifun.funcod  and
                        cfunc.etbcod = vetbcod no-lock no-error.
                if not avail cfunc then next.
                disp "Aguarde, Atualizando " aplifun.aplicod 
                    with frame f-m
                    centered row 15 no-labels color white/red. pause 0.
                create daplifun.
                daplifun.funcod = dfunc.funcod.
                daplifun.aplicod = aplifun.aplicod.
            end.
        
            for each admaplic where admaplic.cliente = string(func.funcod) no-lock.
                find first cfunc where cfunc.funcod = int(admaplic.cliente)  and
                        cfunc.etbcod = vetbcod no-lock no-error.
                if not avail cfunc then next.
 
                find first bmenu where bmenu.aplicod = admaplic.aplicod and
                                       bmenu.menniv  = admaplic.menniv and
                                       bmenu.ordsup  = admaplic.ordsup and
                                       bmenu.menord  = admaplic.menord
                             no-lock no-error.
                if not avail bmenu
                then next.
                disp "Aguarde, Atualizando " bmenu.mentit
                    with frame f-m
                    centered row 15 no-labels color white/red. pause 0.
                create dadmaplic.
                assign
                    dadmaplic.cliente = string(dfunc.funcod) 
                    dadmaplic.aplicod = admaplic.aplicod
                    dadmaplic.menniv  = admaplic.menniv
                    dadmaplic.ordsup  = admaplic.ordsup 
                    dadmaplic.menord  = admaplic.menord
                    .
             end.
        end.
    END.
    /*
    ELSE DO :
        assign an-seeid = -1 an-recid = -1 an-seerec = ? an-seelst = "".
            
        {anbrowse.i
            &color = withe/brown
            &File   = dfunc
            &CField = dfunc.funnom
            &Ofield = " dfunc.funcod dfunc.funfunc"
            &aftfnd = " 
                      "          
            &Where  = " dfunc.funfunc = func.funfunc and 
                        dfunc.funcod <> func.funcod 
                        AND dfunc.funsit = YES "
            &UsePick = "*" 
            &PickFld = "dfunc.funcod" 
            &PickFrm = "99999" 
            &Form = " frame f-funcao "
        }. 
        FOR EACH tt-func . DELETE tt-func. 
        END.
        hide frame f-funcao.
        v-cont = 2.
        repeat :
            v-cod = 0.
            v-cod = int(substr(an-seelst,v-cont,5)).
            v-cont = v-cont + 6.
            if v-cod = 0
            then leave.
            create tt-func.
            tt-func.funcod = v-cod.
        end.
        find first tt-func no-error.
        if not avail tt-func
        then next.

        message "Confirma Alteracao de " func.funnom update sresp.
    
        IF sresp = YES  
        THEN DO : 
            
            for each tt-func :
                find first dfunc where dfunc.funcod = tt-func.funcod no-lock.
                for each aplifun where aplifun.funcod = dfunc.funcod :
                    delete aplifun.
                end.
                for each admaplic where admaplic.cliente = string(dfunc.funcod) :
                    delete admaplic.
                end.
                for each aplifun where aplifun.funcod = func.funcod no-lock :
                    disp "Aguarde, Atualizando " aplifun.aplicod 
                        with frame f-m23
                        centered row 15 no-labels color white/red. pause 0.
                    create daplifun.
                   daplifun.funcod = dfunc.funcod.
                    daplifun.aplicod = aplifun.aplicod.
                end.
        
               for each admaplic where 
                    admaplic.cliente = string(func.funcod) no-lock.
                    find first bmenu where bmenu.aplicod = admaplic.aplicod and
                                       bmenu.menniv  = admaplic.menniv and
                                       bmenu.ordsup  = admaplic.ordsup and
                                       bmenu.menord  = admaplic.menord
                             no-lock no-error.
                    if not avail bmenu
                    then next.
                    disp "Aguarde, Atualizando " bmenu.mentit
                        with frame f-m32
                        centered row 15 no-labels color white/red. pause 0.
                    create dadmaplic.
                    assign
                    dadmaplic.cliente = string(dfunc.funcod) 
                    dadmaplic.aplicod = admaplic.aplicod
                    dadmaplic.menniv  = admaplic.menniv
                    dadmaplic.ordsup  = admaplic.ordsup 
                    dadmaplic.menord  = admaplic.menord
                    .

                 end.
            END.
        END.
    end.
    */    
end.    

