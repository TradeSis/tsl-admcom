{admcab.i}
def var vultimo as dec.
def var vcusto as dec.
def var vqtd as dec.
def var vcto-atu as dec.
def var vqtd-atu as dec.
def var vctomed-ini as dec.
def var vctomed-atu as dec.
def var vctomed-ant as dec.
def var vqtdest-ant as dec.
def var vqtdest-atu as dec.
def var vpis as dec.
def var vcofins as dec.
def buffer vmovim for movim.
def var vdti as date.
def var vdtf as date.
def var vetbcod like estab.etbcod.

update vetbcod label " Cod. Filial"
    with frame f1 width 80 side-label.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
end.
vdti = date(if month(today) = 1 then 12 else month(today) - 1,01,
            if month(today) = 1 then year(today) - 1 else year(today)).
vdtf = date(month(today),01,year(today)) - 1.
            
update vdti at 1 label "Data Inicial"   format "99/99/9999"
       vdtf label "Data Final"          format "99/99/9999"
       with frame f1.
       
if vdti = ? or vdtf = ? or vdti > vdtf
then undo.
if day(vdtf) < 28
then undo.
if day(vdti) > 1
then undo.

sresp = no.
message "Confirma gerar inventario ?" update sresp.
if not sresp then return.
def buffer bctbhie for ctbhie.
def buffer octbhie for ctbhie.
/*
find first ctbhie   use-index ind-1
                    where (if vetbcod > 0
                         then ctbhie.etbcod = vetbcod else true) and
                        ctbhie.ctbano = year(vdtf) and
                        ctbhie.ctbmes = month(vdtf)
                        no-lock no-error.
if avail ctbhie
then do:
    bell.
    message color red/with
    "Ja exite inventario no periodo informado."
    view-as alert-box.
    undo.
end.
*/
for each produ no-lock:
    disp produ.procod format ">>>>>>>>9" 
            with frame f-d 1 down centered row 10 no-label
            no-box color message.
    pause 0.
    find last octbhie use-index ind-2 where octbhie.etbcod = 0 and
                      octbhie.procod = produ.procod and
                      octbhie.ctbano = year(vdtf) and
                      octbhie.ctbmes <= month(vdtf)
                      no-lock no-error.
    if not avail octbhie
    then  find last octbhie use-index ind-2 where octbhie.etbcod = 0 and
                      octbhie.procod = produ.procod and
                      octbhie.ctbano < year(vdtf) 
                      no-lock no-error.
                 
    for each estab no-lock:
        disp estab.etbcod with frame f-d.
        find hiest where hiest.etbcod = estab.etbcod and
                         hiest.procod = produ.procod and
                         hiest.hieano = year(vdtf) and
                         hiest.hiemes = month(vdtf)
                         no-lock no-error.
        if avail hiest
        then do:
            create ctbhie.
            assign
                ctbhie.etbcod = estab.etbcod 
                ctbhie.procod = produ.procod
                ctbhie.ctbano = hiest.hieano
                ctbhie.ctbmes = hiest.hiemes
                ctbhie.ctbcus = hiest.hiepcf
                ctbhie.ctbest = hiest.hiestf
                ctbhie.ctbven = hiest.hiepvf
                .
        end.                 
        else do:
            find last bctbhie use-index ind-2 where
                      bctbhie.procod = produ.procod and
                      bctbhie.etbcod = estab.etbcod 
                      no-lock no-error.
            if avail bctbhie
            then do:
                create ctbhie.
                assign
                ctbhie.etbcod = estab.etbcod 
                ctbhie.procod = produ.procod
                ctbhie.ctbano = year(vdtf)
                ctbhie.ctbmes = month(vdtf)
                ctbhie.ctbcus = bctbhie.ctbcus
                ctbhie.ctbest = bctbhie.ctbest
                ctbhie.ctbven = bctbhie.ctbven
                .
 
            end.
        end.
        find ctbcad where ctbcad.etbcod = estab.etbcod and
                      ctbcad.ctbmes = ctbhie.ctbmes         and
                      ctbcad.ctbano = ctbhie.ctbano no-error.
        if not avail ctbcad
        then do :
            create ctbcad.
            assign ctbcad.etbcod = estab.etbcod
                   ctbcad.ctbmes = ctbhie.ctbmes
                   ctbcad.ctbano = ctbhie.ctbano.
        end.
        if avail octbhie
        then do:
            ctbcad.salini = ctbcad.salini + (octbhie.ctbcus * ctbhie.ctbest).
            ctbcad.salfin = ctbcad.salfin + (octbhie.ctbcus * ctbhie.ctbest).
        end.
     end.
end.
                
message "Fim da geracao do Inventario " vdti " a " vdtf.
               
