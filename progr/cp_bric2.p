{admcab.i}
    
def temp-table tt-produ like produ.

def buffer bprodu for produ.
def buffer bestoq for estoq.
def buffer bplani for plani.
def buffer vplani for plani.

def var vplacod like plani.placod.
def var vnumero like plani.numero.
def var vcod7 like plani.placod.
def var vcod8 like plani.placod.
def var vnum7 like plani.numero.
def var vnum8 like plani.numero.
def var vetbcod like estab.etbcod.
def var vprocod like produ.procod.
def var vqtdpro as int.

vetbcod = 998.
find estab where estab.etbcod = vetbcod no-lock.
disp vetbcod label "Filial" at 5
    estab.etbnom no-label
    with frame f-1.
update vprocod at 4 with frame f-1 side-label width 80.
find produ where produ.procod = vprocod no-lock no-error.
if not avail produ
then do:
    bell.
    message color red/with
    "Produto nao cadatrado."
    view-as alert-box .
    undo.
end.
disp produ.pronom no-label  with frame f-1.
vqtdpro = 1.
disp vqtdpro label "Quantidade" 
    with frame f-1.
 
update vqtdpro validate(vqtdpro > 0, "Informe a quantidade")
with frame f-1.

sresp = no.
message "Confirma criar produto de brick?" update sresp.
if not sresp then undo.

find first probrick where
           probrick.procod = produ.procod no-lock no-error.
if avail probrick
then do:
    find bprodu where bprodu.procod = probrick.codbrick no-lock
    .
    create tt-produ.
    buffer-copy bprodu to tt-produ.
    
end.
else do:           

    create tt-produ.
    buffer-copy produ to tt-produ.

    find last bprodu where bprodu.procod >= 980000 and
                           bprodu.procod <= 999999
                          no-lock no-error.
    if available bprodu
    then tt-produ.procod = bprodu.procod + 1.
    else tt-produ.procod = 980001.
    
    find last bprodu no-lock.
    if produ.catcod = 31
    then tt-produ.catcod = 35.
    else tt-produ.catcod = 45.
    
    if tt-produ.procod = produ.procod
    then return.
    
    assign
        tt-produ.corcod = "BRICK" 
        tt-produ.pronom = "BRICK " + produ.pronom
        tt-produ.proindice = string(tt-produ.procod).
        
    do transaction:
    create bprodu.
    buffer-copy tt-produ to bprodu.
    bprodu.datexp = today.
    
    create probrick.
    assign
        probrick.codbrick = bprodu.procod
        probrick.procod   = produ.procod
        probrick.dtinclu  = today
        probrick.datexp   = today 
        .
    for each estab no-lock:
        find bestoq where bestoq.etbcod = estab.etbcod and
                          bestoq.procod = produ.procod
                          no-lock no-error.
        if not avail bestoq
        then next.                  
        create estoq.
        assign estoq.etbcod    = bestoq.etbcod
               estoq.procod    = bprodu.procod
               estoq.estcusto  = bestoq.estcusto
               estoq.estdtcus  = bestoq.estdtcus
               estoq.estvenda  = bestoq.estvenda
               estoq.estdtven  = bestoq.estdtven
               estoq.tabcod    = bestoq.tabcod
               estoq.estideal  = bestoq.estideal
               estoq.datexp    = today.
    end.
      
    end.
end.
do transaction:
          
    find last vplani where vplani.etbcod = vetbcod and
                           vplani.placod <= 500000 exclusive-lock no-error.
    if avail vplani
    then vplacod = vplani.placod + 1.
    else vplacod = 1.

    find last bplani use-index nota where bplani.movtdc = 7 and
                                          bplani.etbcod = vetbcod and 
                                          bplani.emite  = vetbcod and
                                          bplani.serie  = "B"
                                exclusive-lock no-error.
    if not avail bplani
    then vnumero = 1.
    else vnumero = bplani.numero + 1.

    find tipmov where tipmov.movtdc = 7 no-lock.

    vcod7 = vplacod.
    vnum7 = vnumero.
    find motiv where  motiv.motcod = "TB" no-lock.
    do:
        create plani.
        assign plani.etbcod   = vetbcod
               plani.placod   = vcod7
               plani.emite    = vetbcod
               plani.serie    = "B"
               plani.numero   = vnum7
               plani.movtdc   = tipmov.movtdc
               plani.desti    = vetbcod
               plani.pladat   = today
               plani.modcod   = tipmov.modcod
               plani.opccod   = 4
               plani.dtinclu  = today
               plani.horincl  = time
               plani.notsit   = no
               plani.datexp   = today
               plani.notobs[2] = motiv.motnom.

        /**
        if vmanda = no
        then plani.usercod = "NAO".
        **/

        find last vplani where vplani.etbcod = vetbcod and
                               vplani.placod <= 500000
                                    no-error.
        if avail vplani
        then vplacod = vplani.placod + 1.
        else vplacod = 1.
        find last bplani use-index nota where bplani.movtdc = 8 and
                               bplani.etbcod = vetbcod and
                               bplani.emite  = vetbcod and
                               bplani.serie  = "B"  no-error.
        if not avail bplani
        then vnumero = 1.
        else vnumero = bplani.numero + 1.
    end.
    
    find tipmov where tipmov.movtdc = 8 no-lock.

    vcod8 = vplacod.
    vnum8 = vnumero.
    
    find motiv where  motiv.motcod = "TR" no-lock.

    do :
        create plani.
        assign plani.etbcod   = vetbcod
               plani.placod   = vcod8
               plani.emite    = vetbcod
               plani.serie    = "B"
               plani.numero   = vnum8
               plani.movtdc   = tipmov.movtdc
               plani.desti    = vetbcod
               plani.pladat   = today
               plani.modcod   = tipmov.modcod
               plani.opccod   = 4
               plani.dtinclu  = today
               plani.datexp   = today
               plani.horincl  = time
               plani.notsit   = no
               plani.notobs[2] = motiv.motnom.
        /**      
        if vmanda = no
        then plani.usercod = "NAO".
        **/
    end.

    find estoq where estoq.etbcod = vetbcod and
                     estoq.procod = bprodu.procod
                     no-lock.
    find motiv where  motcod = "TB" no-lock.
    do :
            create movim.
            ASSIGN movim.movtdc = 7
                   movim.PlaCod = vcod7
                   movim.etbcod = estoq.etbcod
                   movim.movseq = 1
                   movim.procod = estoq.procod
                   movim.movqtm = vqtdpro
                   movim.movpc  = estoq.estcusto
                   movim.movdat = today
                   movim.datexp = today
                   movim.MovHr  = int(time)
                   movim.emite  = estoq.etbcod
                   movim.desti  = estoq.etbcod
                    .

            run atuest.p (input recid(movim),
                          input "I",
                          input 0).
    end.
    find estoq where estoq.etbcod = vetbcod and
                     estoq.procod = produ.procod
                     no-lock.
    do :
            create movim.
            ASSIGN movim.movtdc = 8
                   movim.PlaCod = vcod8
                   movim.etbcod = estoq.etbcod
                   movim.movseq = 1
                   movim.procod = estoq.procod
                   movim.movqtm = vqtdpro
                   movim.movpc  = estoq.estcusto
                   movim.movdat = today
                   movim.datexp = today
                   movim.MovHr  = int(time)
                   movim.emite  = estoq.etbcod
                   movim.desti  = estoq.etbcod.
            run atuest.p (input recid(movim),
                          input "I",
                          input 0).
    end.
end.
 
disp bprodu.procod
     bprodu.pronom
     with frame f-2 1 down width 80 side-label
     title " Produto criado para BRICK "
     .

     pause 0.

sresp = no.
message "Emitir etiqueta do produto BRICK ?" update sresp.

if sresp 
then do:
    run etiq_m1.p (recid(bprodu), vqtdpro, "").
end.

return.