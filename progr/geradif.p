{admcab_l.i}

if not connected ("finctb")
then connect finctb -H linux -S sfinctb -N tcp -ld finctb no-error.

            
if connected ("finctb")
then do:

    run imptipo4.p.
    
    disconnect finctb.
    
end. 