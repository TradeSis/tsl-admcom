def input parameter par-clicod as int.

        find gerloja.clien where gerloja.clien.clicod = par-clicod
            no-lock.
        disp gerloja.clien.flag.
        if gerloja.clien.flag = no
        then update gerloja.clien.flag.                                        
