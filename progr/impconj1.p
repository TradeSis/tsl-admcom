{admcab.i}

/*connect crm -H 192.168.0.8 -S sdrebcrm -N tcp -ld crm no-error.*/

connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.

def var vacaocod as int.

repeat:

    update vacaocod label "Acao"
           with side-labels centered width 80 1 down.

    run impconj2.p(input vacaocod).


end.

disconnect crm.