{admcab.i}

def var total_loja     as int.
def var vqtd-vendedor  as int format ">>>>9".
def var vqtd-loja      as int format ">>>>9".
def var varquivo       as char.
def var vetbcod        like estab.etbcod.
def var vdtini         as   date format "99/99/9999".
def var vdtfin         as   date format "99/99/9999".
def var vop            as   log  format "Habilitacao/Migracao" init yes.
def var vgercod like habil.gercod.

def var voperacao as char format "x(12)".
def new shared temp-table tt-habil
        field funcod like func.funcod
        field funnom like func.funnom
        field vope    as char format "x(12)"
        field celular like habil.celular
        field ciccgc  like habil.ciccgc
        field habsit  like habil.habsit
        field habdat  like habil.habdat
            index ind-1 habdat
                        vope.


repeat: 


    for each tt-habil:
        
        delete tt-habil.
        
    end.
        

    assign
        vetbcod = 0
        vgercod = 0
        vdtini = today - 7
        vdtfin = today
        vqtd-vendedor = 0
        vqtd-loja = 0
        voperacao = ""
        vop     = yes
        total_loja     = 0.

    update vetbcod label "Filial" with frame f-dados.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Filial Nao Cadastrada".
        pause.
        undo, retry.
    end.
    display estab.etbnom no-label with frame f-dados.
    

    update vdtini label "Periodo" 
           vdtfin no-label 
                   with frame f-dados side-labels width 80.

               

    for each habil use-index ihabdat 
                       where habil.habdat >= vdtini and
                             habil.habdat <= vdtfin and
                             habil.etbcod = estab.etbcod no-lock
                                                       break by habil.etbcod
                                                             by habil.vencod
                                                             by habil.gercod:


        if habil.gercod = 1
        then voperacao = "Habilitacao". 
        else if habil.gercod = 2
             then voperacao = "Migracao".
             else if habil.gercod = 3
                  then voperacao = "Cancelada".
                  else voperacao = "".
        
        vqtd-vendedor = vqtd-vendedor + 1. 
        vqtd-loja = vqtd-loja + 1.
        
        total_loja     = total_loja     + 1.
        
        find first tt-habil where tt-habil.celular = habil.celular and
                                  tt-habil.ciccgc  = habil.ciccgc
                                            no-error.
        if not avail tt-habil
        then do:
            create tt-habil.
            assign tt-habil.celular = habil.celular
                   tt-habil.ciccgc  = habil.ciccgc
                   tt-habil.funcod  = habil.vencod
                   tt-habil.habsit  = habil.habsit
                   tt-habil.vope    = voperacao.
                   
            find func where func.etbcod = habil.etbcod and
                            func.funcod = habil.vencod no-lock no-error.
                            
            if avail func
            then tt-habil.funnom = func.funnom.
        
        end.

    end.
    
    run tt-habil.p(input total_loja,
                   input vdtini,
                   input vdtfin).

end.