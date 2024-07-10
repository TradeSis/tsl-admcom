def var vescolha as char extent 2 init 
["     ENTRADAS    ","     SAIDAS    "] format "x(20)".

disp vescolha with frame f1 centered no-label row 7. 
choose field vescolha with frame f1.

 
if frame-index = 1
then do:
    run int_ent_tci.p.
end.
else if frame-index = 2
    then do :
        run int_sai_tci.p.
    end.






