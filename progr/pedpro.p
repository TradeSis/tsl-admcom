{admcab.i}
    
def buffer xclase  for  clase.

def input parameter vcatcod like produ.catcod.
def input parameter vforcod like forne.forcod.
def input parameter vfrete  like pedid.condes.
def input parameter vnfdes  like pedid.nfdes.
def input parameter vacrfin like pedid.nfdes.
def output parameter vprocod like produ.procod.
def output parameter valtera as log initial no.

def var vpedpro like produ.procod.
def var vclacod like produ.clacod.
def buffer cprodu for produ.
def buffer bprodu for produ.
def temp-table wclase like clase.

find forne where forne.forcod = vforcod no-lock.

do on error undo:    
    display vcatcod colon 18 with frame f-choo.
    find categoria where categoria.catcod = vcatcod no-lock.
    display categoria.catnom no-label with frame f-choo.
    
    do on error undo:
        update vclacod colon 18 help "[P] Procura de Classes" go-on(P p)
               with frame f-choo centered width 80 side-label 
                                 row 14 overlay color white/red.
                                 
        if keyfunction(lastkey) = "P" or
           keyfunction(lastkey) = "p"
        then do:
            for each cprodu where cprodu.catcod = vcatcod and
                                  cprodu.fabcod = vforcod no-lock:
                find first wclase where wclase.clacod = cprodu.clacod no-error.
                if not avail wclase
                then do:
                    find clase where clase.clacod = cprodu.clacod 
                                     no-lock no-error.
                    if avail clase
                    then do:
                        create wclase.
                        assign wclase.clacod = cprodu.clacod
                               wclase.clanom = clase.clanom.
                    end.
                end.
            end.
            
            {zoomesq.i wclase wclase.clacod wclase.clanom 50 Classes true}
            vclacod = int(frame-value).
        end.

        find first xclase where xclase.clasup = vclacod no-lock no-error.
        if avail xclase
        then do:
            message "Classe Superior - Invalida para Cadastro".
            undo.
        end.

        find clase where clase.clacod = vclacod no-lock no-error.
        display vclacod
                clase.clanom no-label with frame f-choo.
    end.
    
    find fabri where fabri.fabcod = forne.forcod no-lock no-error.
    display fabri.fabcod colon 18
            fabri.fabnom no-label with frame f-choo.
    
    update vpedpro colon 18
           help "[C] - Aciona Pesquisa por Nome"
           go-on(C c return) with frame f-choo.

    if keyfunction(lastkey) = "C" or
       keyfunction(lastkey) = "c"
    then do:
        {zoomesq.i1 produ produ.procod pronom 50 Produtos
                                               "produ.catcod = vcatcod and
                                                produ.clacod = vclacod and
                                                produ.fabcod = vforcod"}
         vpedpro = int(frame-value).
         vprocod = int(frame-value).
    end.
    
    if keyfunction(lastkey) = "Return" and vpedpro = 0
    then run cad_produman.p ("Inc",
                         vcatcod,
                         fabri.fabcod,
                         vfrete,
                         vnfdes,
                         vacrfin,
                         input-output vprocod).
end.

