{admcab.i}

{setbrw.i}

def var vsenha like func.senha format "x(10)".

update  vsenha blank with frame f-senh side-label centered row 10.
if vsenha = "nfe@lebes"
then.
else return.
           
def input parameter p-tipo as char.
assign
    a-seeid = -1
    a-recid = -1
    a-seerec = ?
    .
    
form tab_ini.parametro format "x(40)"
     tab_ini.valor format "x(37)"
      with frame f-linha.

def var vetbcod like estab.etbcod.
find first tab_ini where
           tab_ini.etbcod = setbcod no-lock no-error.
if avail tab_ini
then vetbcod = setbcod.
else vetbcod = 0.

if vetbcod = 0
then do:
    update vetbcod with frame f1 row 5 side-label 1 down width 80.
    
end.            

{sklcls.i
    &file = tab_ini
    &cfield = tab_ini.parametro
    &ofield = " tab_ini.valor "
    &where = "  tab_ini.etbcod = vetbcod and
                tab_ini.parametro begins p-tipo "
    &aftselect1 = "
            if keyfunction(lastkey) = ""RETURN""
            THEN DO:
                update tab_ini.valor with frame f-linha.
                if tab_ini.valor = ""PRODUCAO""
                THEN DO:
                    RUN limpa-testes-nfe.p( input setbcod,
                                            output sresp).
                    if not sresp
                    then tab_ini.valor = ""HOMOLOGACAO"".
                    DISP tab_ini.valor with frame f-linha.
                END. 
            END.      
            next keys-loop.
            "
    &naoexiste1 = " message color red/with
                    ""Nenhum registro encontrado.""
                    view-as alert-box.
                    leave keys-loop.
                  "   
    &form = " frame f-linha 7 down row 7 width 80  overlay "
    
}
hide frame f-linha.
    
