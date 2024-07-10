/* {tsframe.i} */

find first func where func.funcod = sfuncod and
                      func.etbcod = 999      no-lock no-error.
if avail func
then 
    display wempre.emprazsoc + "/" + estab.etbnom + "-" + 
        func.funnom @ wempre.emprazsoc
            wdata with frame fc1.
else
    display wempre.emprazsoc + "/" + estab.etbnom  @ wempre.emprazsoc
            wdata with frame fc1.

display wtitulo                with frame fc2.



/***
if opsys <> "UNIX"
then do:
    assign
        current-window:bgcolor = 8.
end.

find func where /*func.empcod = wempre.empcod and*/
                func.funcod = sfuncod
        no-lock no-error.
sfunape = if avail func
          then func.funape
          else "".
/*
display trim(caps(wempre.emprazsoc)) + " - " + trim(caps(estab.etbnom)) +
                    " - " + sestacao + "/" + sfunape @  wempre.emprazsoc
                    wdata with frame fc1.

*/

    display wempre.empfant + "/" + estab.etbnom + "/" +
            /***sestacao +***/ "/" + sfunape
            @ wempre.emprazsoc
            /***sversao + "/" + srelease @ sversao
            vsemcomp[weekday(wdata)] @ vsemcomp[1]***/
            wdata 
            with frame fc1.

/*
display trim(caps(sversao)) + " " +
        trim(caps(sfunape)) + " " +
        trim(caps(wempre.empfant)) + "/" + 
        trim(caps(westab.etbnom)) @
        wempre.empfant
        {1} format "x(12)" @ wareasis
        wdata
        vsemcomp[weekday(wdata)]
                with frame fc1.
                */


display 

        
        {2}  + " " + 

            fill(" ",
            integer(
                truncate((78 - length({3})) / 2,0) - length({2}) - 1
                   )
             ) +
    caps({3})
+ " "         +
            fill(" ",
            integer(78 - (length({2}) + length({3}) +
                (truncate((78 - length({3})) / 2,0) - length({2}) - 1)) -
                length({4})
                   )
             ) +


/*
    fill("2",integer(string(truncate((((78 - length({2}) - length({3})) -
        length({4}) ) / 2),0),"999")))                    +
        " " +
 */
        {4} 
@ wtittela /***wtitle ***/
              with frame fc2.
***/
