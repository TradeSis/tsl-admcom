{admcab.i}

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
/*
def temp-table tt-tipmov
    field movtdc like tipmov.movtdc
    field movtnom like tipmov.movtnom  format "x(60)"
    index i1 movtnom.
for each tipmov no-lock:
    find first tipmovaux where
                tipmovaux.movtdc = tipmov.movtdc and
                tipmovaux.nome_campo = "natureza-operacao"
                no-lock no-error.
    if avail tipmovaux
    then do:
        create tt-tipmov.
        assign
            tt-tipmov.movtdc = tipmov.movtdc
            tt-tipmov.movtnom = tipmovaux.valor_campo.
    end.
end.
    
{setbrw.i}
{sklcls.i
    &file = tt-tipmov
    &cfield = tt-tipmov.movtnom
    &where = true
    &form = " frame f-linha down "
     
}     
**/

form opcom.opcnom format "x(60)" with frame f-linha down.
{setbrw.i}         
{sklcls.i
    &file = opcom
    &cfield = opcom.opcnom  
    &ofield = opcom.movtdc
    &where = "true use-index ind-2"
    &form = " frame f-linha "
}  

if keyfunction(lastkey) = "end-error"
then return.
find tipmov where tipmov.movtdc = opcom.movtdc no-lock.

assign
    a-seeid = -1
    a-recid = -1
    a-seerec = ?.
    
{sklcls.i
    &file = plani
    &cfield = plani.numero
    &noncharacter = /*
    &ofield = " plani.pladat  plani.emite plani.desti plani.platot "
    &where = " plani.etbcod = 22 and
               plani.movtdc = tipmov.movtdc
               and plani.pladat >= 01/01/10
               use-index pladat 
                            "     
    &form = " frame flinha1 down 
    "
    }

if keyfunction(lastkey) = "END-ERROR"
THEN RETURN.

/*    

find last plani where plani.etbcod = 22 and plani.emite = 22 and
plani.movtdc = tipmov.movtdc no-lock.
*/
disp plani.pladat plani.numero.
create tt-plani.
buffer-copy plani to tt-plani.
disp plani.desti.
for each movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc
                        no-lock:
    create tt-movim.
    buffer-copy movim to tt-movim.
end.

tt-plani.serie = "55".

find last A01_infnfe where
          A01_infnfe.emite = plani.emite and
          A01_infnfe.serie = "55"
          no-lock no-error.
if avail A01_infnfe
then tt-plani.numero = A01_infnfe.numero + 1.
else tt-plani.numero = 1.
/*
update tt-plani.numero.
*/
def var vok as log init no.
if tipmov.movtdc = 6
then do:
    tt-plani.opccod = 5152.
    run nfe_5152.p (output vok).
end.
else if tipmov.movtdc = 14
then do:
    tt-plani.opccod = 5901.
    run nfe_5901.p (output vok).
end.
else if tipmov.movtdc = 16
then do:
    tt-plani.opccod = 5915.
    run nfe_5915.p (output vok).
end.


/**
for each A01_infnfe :
    run /admcom/custom/desenv/del_nfe.p(recid(A01_infnfe)).
    end.
    */