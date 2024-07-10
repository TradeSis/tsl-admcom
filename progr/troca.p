{admcab.i}
def var recpla as recid.
def var vprocod like produ.procod.
def var vetbcod like estab.etbcod.
def var vfuncod like func.funcod.
def buffer xplani for plani.
def buffer yplani for plani.
def buffer bmovim for movim.
def buffer cmovim for movim.
def var qtd1 like estoq.estatual.
def var vqtd like estoq.estatual.
def var vdoc like plani.numero.
def var vdoc1 like plani.numero.
def var vop as log format "Entrada/Saida".
def var i as int.
def var vest like estoq.estatual.
def var vsenha like func.senha.
def buffer bplani for plani.
def buffer cplani for plani.
def var vplacod like plani.placod.
def var vnumero like plani.numero.
def var vserie like plani.serie.
def temp-table tt-estoq like estoq.

form vop label "Operacao" 
     vprocod column-label "Produto"
     produ.pronom
     vqtd  format "->>>>>9" with frame f2 down.



bl-1:
repeat:
        
    hide frame f2 no-pause.
    clear frame f2 all.
          
    update vfuncod with frame f-senha centered row 4 
        side-label title " Seguranca ".
    find func where func.funcod = vfuncod and
                    func.etbcod = 999 no-lock no-error.
    if not avail func 
    then do: 
        message "Funcionario nao Cadastrado". 
        undo, retry.
    end. 
    disp func.funnom no-label with frame f-senha. 
    if func.funfunc <> "ESTOQUE" 
    then do: 
        bell.  
        message "Funcionario sem Permissao". 
        undo, retry.
    end.
    i = 0.
    repeat: 
        i = i + 1. 
        update vsenha blank with frame f-senha. 
        if vsenha = func.senha 
        then leave. 
        if vsenha <> func.senha 
        then do: 
            bell. 
            message "Senha Invalida".
        end. 
        if i > 2 
        then leave bl-1.
    end. 
    if vsenha = ""  
    then undo, retry.
    hide frame f2 no-pause.
    clear frame f2 all.
          
          
    update vetbcod with frame f1 side-labels 
                        centered color white/red row 4.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
           
    find last xplani where xplani.movtdc = 17 and
                           xplani.etbcod = estab.etbcod and
                           xplani.emite  = estab.etbcod and
                           xplani.serie  = "TR" and
                           xplani.numero <> ? /*and
                           xplani.numero > 99*/ no-lock no-error.

    if avail xplani
    then vdoc = xplani.numero + 1.
    else vdoc = 1.
    find last yplani where yplani.movtdc = 18 and
                           yplani.etbcod = estab.etbcod and
                           yplani.emite  = estab.etbcod and
                           yplani.serie  = "TR" and
                           yplani.numero <> ? /*and
                           yplani.numero > 99 */ no-lock no-error.

    if avail yplani
    then vdoc1 = yplani.numero + 1.
    else vdoc1 = 1.


    disp vdoc label "Entrada"
         vdoc1 label "Saida"
     with frame f1.
         
         
    repeat:

        update vop label "Operacao" with frame f2.
        vprocod = 0.
        update vprocod with no-validate
            frame f2 centered down color white/cyan.
        find produ where produ.procod = vprocod no-lock.
        disp produ.pronom with frame f2.

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod 
                         no-lock no-error.
        if not avail estoq
        then do:
            for each tt-estoq: delete tt-estoq. end.
            find estoq where estoq.procod = produ.procod and
                             estoq.etbcod = 93
                             no-lock no-error.
            if avail estoq
            then do transaction:
                create tt-estoq.
                buffer-copy estoq to tt-estoq.
                tt-estoq.etbcod = estab.etbcod.
                tt-estoq.estatual = 0.
                create estoq.
                buffer-copy tt-estoq to estoq.
            end.
            else next.
        end.
        find estoq where estoq.etbcod = estab.etbcod and
                    estoq.procod = produ.procod no-lock.
        update vqtd format "->>>>>9" with frame f2.
        down with frame f2.
        
        if vop
        then do:
             
            find last cplani where cplani.etbcod = estab.etbcod and
                                   cplani.placod <= 500000 no-error.
            if avail cplani
            then vplacod = cplani.placod + 1.
            else vplacod = 1.

            do transaction:
            
                create plani.
                assign plani.etbcod   = estab.etbcod
                       plani.placod   = vplacod
                       plani.protot   = estoq.estcusto
                       plani.emite    = estab.etbcod
                       plani.platot   = estoq.estcusto
                       plani.serie    = "TR"
                       plani.numero   = vdoc
                       plani.movtdc   = 17
                       plani.desti    = estab.etbcod
                       plani.pladat   = today
                       plani.dtinclu  = today
                       plani.horincl  = time
                       plani.notsit   = no
                       plani.vencod   = vfuncod.
                create movim.
                ASSIGN movim.movtdc = plani.movtdc
                       movim.PlaCod = plani.placod
                       movim.etbcod = plani.etbcod
                       movim.movseq = 1
                       movim.procod = produ.procod
                       movim.movqtm = vqtd
                       movim.movpc  = estoq.estcusto
                       movim.movdat = plani.pladat
                       movim.MovHr  = int(time)
                       movim.desti  = plani.desti
                       movim.emite  = plani.emite.

                recpla = recid(plani).
                
                run atuest.p(input recid(movim),
                             input "I",
                             input 0).
            
            end.
            
            
            repeat:
            
                vprocod = 0.
                display vop with frame f2.
                update vprocod with no-validate
                frame f2 centered down color white/cyan.
                find produ where produ.procod = vprocod no-lock.
                disp produ.pronom with frame f2.

                find estoq where estoq.etbcod = estab.etbcod and
                                 estoq.procod = produ.procod
                                 no-lock no-error.
                if not avail estoq
                then do:
                    for each tt-estoq: delete tt-estoq. end.
                    find estoq where estoq.procod = produ.procod and
                             estoq.etbcod = 93
                             no-lock no-error.
                    if avail estoq
                    then do transaction:
                        create tt-estoq.
                        buffer-copy estoq to tt-estoq.
                        tt-estoq.etbcod = estab.etbcod.
                        tt-estoq.estatual = 0.
                        create estoq.
                        buffer-copy tt-estoq to estoq.
                    end.
                    else next.
                end.
                find estoq where estoq.etbcod = estab.etbcod and
                    estoq.procod = produ.procod no-lock.
                update vqtd format "->>>>>9" with frame f2.
                down with frame f2.
                
                find plani where recid(plani) = recpla no-lock.
                
                do transaction:
                
                    create bmovim.
                    ASSIGN bmovim.movtdc = plani.movtdc
                           bmovim.PlaCod = plani.placod
                           bmovim.etbcod = plani.etbcod
                           bmovim.movseq = 1
                           bmovim.procod = produ.procod
                           bmovim.movqtm = vqtd
                           bmovim.movpc  = estoq.estcusto
                           bmovim.movdat = plani.pladat
                           bmovim.MovHr  = int(time)
                           bmovim.desti  = plani.desti
                           bmovim.emite  = plani.emite.
               
                    run atuest.p(input recid(bmovim),
                                 input "I",
                                 input 0).
                end.
                    
                
            end.
        end.

        else do:
             
            
            find last cplani where cplani.etbcod = estab.etbcod and
                                   cplani.placod <= 500000 no-error.

            if avail cplani
            then vplacod = cplani.placod + 1.
            else vplacod = 1.

            do transaction:
                create plani.
                assign plani.etbcod   = estab.etbcod
                       plani.placod   = vplacod
                       plani.protot   = estoq.estcusto
                       plani.emite    = estab.etbcod
                       plani.platot   = estoq.estcusto
                       plani.serie    = "TR"
                       plani.numero   = vdoc1
                       plani.movtdc   = 18
                       plani.desti    = estab.etbcod
                       plani.pladat   = today
                       plani.dtinclu  = today
                       plani.horincl  = time
                       plani.notsit   = no
                       plani.vencod   = vfuncod.

                create movim.
                ASSIGN movim.movtdc = plani.movtdc
                       movim.PlaCod = plani.placod
                       movim.etbcod = plani.etbcod
                       movim.movseq = 1
                       movim.procod = produ.procod
                       movim.movqtm = vqtd
                       movim.movpc  = estoq.estcusto
                       movim.movdat = plani.pladat
                       movim.MovHr  = int(time)
                       movim.desti  = plani.desti
                       movim.emite  = plani.emite.

                recpla = recid(plani).
                
                run atuest.p(input recid(movim),
                             input "I",
                             input 0).
            
            end.
            
            
            repeat:
                vprocod = 0.
                display vop with frame f2.
                update vprocod with no-validate
                frame f2 centered down color white/cyan.
                find produ where produ.procod = vprocod no-lock.
                disp produ.pronom with frame f2.

                find estoq where estoq.etbcod = estab.etbcod and
                                 estoq.procod = produ.procod
                                 no-lock no-error.
                if not avail estoq
                then do:
                    for each tt-estoq: delete tt-estoq. end.
                    find estoq where estoq.procod = produ.procod and
                             estoq.etbcod = 93
                             no-lock no-error.
                    if avail estoq
                    then do transaction:
                        create tt-estoq.
                        buffer-copy estoq to tt-estoq.
                        tt-estoq.etbcod = estab.etbcod.
                        tt-estoq.estatual = 0.
                        create estoq.
                        buffer-copy tt-estoq to estoq.
                    end.
                    else next.
                end.
                 find estoq where estoq.etbcod = estab.etbcod and
                    estoq.procod = produ.procod no-lock.
 
                update vqtd format "->>>>>9" with frame f2.
                down with frame f2.
                
                find plani where recid(plani) = recpla no-lock.
    
                do transaction:
                    create cmovim.
                    ASSIGN cmovim.movtdc = plani.movtdc 
                           cmovim.PlaCod = plani.placod 
                           cmovim.etbcod = plani.etbcod 
                           cmovim.movseq = 1 
                           cmovim.procod = produ.procod 
                           cmovim.movqtm = vqtd 
                           cmovim.movpc  = estoq.estcusto 
                           cmovim.movdat = plani.pladat 
                           cmovim.MovHr  = int(time) 
                           cmovim.emite  = plani.emite 
                           cmovim.desti  = plani.desti.

                    run atuest.p(input recid(cmovim),
                                 input "I",
                                 input 0).
                end.    
                
            end.
        
        end.

    end.
end.
