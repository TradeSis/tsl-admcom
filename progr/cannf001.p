{admcab.i}

def var varq as char.
def var vmovtdc like tipmov.movtdc.
def var vetbcod like estab.etbcod.
def var vemite  like plani.emite.
def var vserie  as char format "x(3)" .
def var vnumero like plani.numero.
def var vfuncod like func.funcod.
def var vsenha  like func.senha.
def var i as int.

form vmovtdc at 1 label "Tipo Movimento"    format ">>>>>9"
     tipmov.movtnom no-label
     vetbcod at 1 label "        Filial"    format ">>>>>9"
     estab.etbnom  no-label
     vemite  at 1 label "      Emitente"    format ">>>>>9"
     forne.fornom  no-label   
     vserie  at 1 label "         Serie"
     vnumero at 1 label "        Numero"
     vdti as date at 1 label "    Periodo DE"  format "99/99/9999"
     vdtf as date  label "A" format "99/99/9999"
     with frame f-sel 1 down side-label width 80
     color with/blak.
     

update vfuncod with frame f-senha centered row 4
                            side-label title " Seguran‡a ".
find func where func.funcod = vfuncod and
                        func.etbcod = 999 no-lock no-error.
if not avail func
then do:
    message "Funcionario nao Cadastrado".
    undo, retry.
end.
disp func.funnom no-label with frame f-senha.
if func.funfunc <> "CONTABILIDADE" and
   func.funcod <> 101
then do:
     bell.
     message "Funcionario sem Permissao".
     undo, retry.
end.
i = 0.
repeat:
    i = i + 1.
    update vsenha blank label "Senha" with frame f-senha.
    if vsenha = func.senha
    then leave.
    if vsenha <> func.senha
    then do:
        bell.
        message "Senha Invalida".
    end.
    if i > 2
    then return.
end.
if vsenha = ""
then    return.

hide frame f-senha no-pause.

do on error undo, retry with frame f-sel:
    update vmovtdc .
    find tipmov where tipmov.movtdc = vmovtdc no-lock no-error.
    if not avail tipmov
    then do:
        bell.
        message color red/with
            "Tipo de Movimento nao cadastrado"
            view-as alert-box .
        undo.    
    end.
    disp tipmov.movtnom.
    do on error undo:
        update vetbcod.
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            bell.
            message color red/with
                "Filial nao cadastrada"
                view-as alert-box.
            undo.
        end. 
        disp estab.etbnom.
        do on error undo:
            update vemite.
            if vemite <> 0
            then do:
            if vemite = vetbcod
            then do:
                disp estab.etbnom @ forne.fornom.
            end.
            else do:
            find forne where forne.forcod = vemite no-lock no-error.
            if not avail forne
            then do:
                bell.
                message color red/with
                    "Emitente nao cadastrado"
                    view-as alert-box.
                undo.
            end.
            disp forne.fornom. 
            end. 
            end.      
        end.       
    end.
    update vserie vnumero.
    do on error undo:
        update vdti vdtf.
        if vdti = ? or
           vdtf = ? or
           vdti > vdtf
        then do:
            bell.
            message color red/with
                "Periodo invalido"
                view-as alert-box .
            undo.
        end.   
    end.     
end.
def temp-table tt-plani no-undo like plani .

for each    plani where 
            plani.movtdc = vmovtdc and
            plani.etbcod = vetbcod and
            plani.pladat >= vdti   and
            plani.pladat <= vdtf
            no-lock .
    if vemite <> 0 and vemite <> plani.emite
    then next.
    if vserie <> "" and vserie <> plani.serie
    then next.
    if vnumero <> ? and vnumero <> plani.numero
    then next.
    
    create tt-plani.
    buffer-copy plani to tt-plani.
end.    

{setbrw.i}

form tt-plani.numero
     tt-plani.serie    column-label "Ser"
     tt-plani.pladat
     tt-plani.etbcod   column-label "Filial"
     tt-plani.emite format ">>>>>>>9"
     tt-plani.desti format ">>>>>>>9"   column-label "Destino"
     tt-plani.platot
     tt-plani.modcod  column-label "Mod"
     tt-plani.notsit  column-label "S" format "A/F" 
     with frame f-linha down color with/cyan
     width 80
     .
l1: repeat:
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        .
    {sklcls.i
        &color = with/cyan
        &help = "ENTER=Cancela  F4=Retorna  F8=Procura"
        &file = tt-plani
        &cfield = tt-plani.numero
        &noncharacter = /*
        &ofield = " tt-plani.serie
                    tt-plani.pladat
                    tt-plani.etbcod
                    tt-plani.emite
                    tt-plani.desti
                    tt-plani.platot
                    tt-plani.modcod
                    tt-plani.notsit
                  "
        &where = true
        &naoexiste1 = " bell.
                    message color red/with
                    ""Nenhum registro encontrado""
                    view-as alert-box.
                    leave l1.
                    "
        &procura1 = " update vnumero 
                        with frame f-procura centered row 10 
                        side-label overlay.
                     find tt-plani where tt-plani.numero = vnumero no-error.
                     if avail tt-plani
                     then a-recid = recid(tt-plani).
                     a-seeid = -1. 
                     next keys-loop.
                     "   
        &aftselect = " cannf001.as "
        &locktipe = " no-lock "
        &form = " frame f-linha "
    }

    if keyfunction(lastkey) = "end-error"
    then do:
        leave.
    end.
    
end.                         
        

