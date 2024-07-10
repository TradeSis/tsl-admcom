/* helio 27042021 - projeto cadastramento cliente na integracao jsin para filial 200 */
def output parameter p-gera as int.

        do for geranum on error undo on endkey undo:
            /*** Numeracao para CLIENTES criados na matriz ***/
            find geranum where geranum.etbcod = 999 exclusive no-error.
            if not avail geranum
            then do:
                create geranum.
                assign
                    geranum.etbcod  = 999
                    geranum.clicod  = 300000000
                    geranum.contnum = 300000000.
            end.
            p-gera = geranum.clicod. 
            geranum.clicod = geranum.clicod + 1.
            release geranum.
        end.
             
