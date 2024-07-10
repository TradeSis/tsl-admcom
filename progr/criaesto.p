{admcab.i}

def var vetbcod like estab.etbcod.
def var vsenha like func.senha.

def buffer bestoq for estoq.

update vsenha blank label "Senha" with frame f0 1 down
    side-label .

if vsenha <> "x15w16"
then next.

update vetbcod label "Filial"
        with frame f1 side-label width 80 row 3.
find estab where estab.etbcod = vetbcod no-lock no-error.
if not avail estab
then do:
     bell.
     message color red/with
            "Filial nao exite" view-as alert-box.
     undo.
end.
disp estab.etbnom no-label with frame f1.

sresp = no.
message 
    "Confirma gerar estoque?" 
    update sresp.
if not sresp then return.    
    
for each produ no-lock:
    disp produ.procod format ">>>>>>>>9" produ.pronom
        with frame f2 1 down no-label no-box
        row 10 centered.
        pause 0.
    
    
    find estoq where estoq.etbcod = vetbcod and
                     estoq.procod = produ.procod no-lock no-error.
    if not avail estoq 
    then do:
        
        
        find first bestoq where bestoq.procod = produ.procod no-lock no-error.
        
        
        create estoq.
        assign
            estoq.etbcod   = vetbcod 
            estoq.procod   = produ.procod.
            
        if avail bestoq
        then assign estoq.estcusto = bestoq.estcusto
                    estoq.estvenda = bestoq.estvenda
                    estoq.DtAltPreco = today
                    .
                    
    end.                 
end.            


