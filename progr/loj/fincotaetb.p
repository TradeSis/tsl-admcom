/*               to                   sfpl
*                                 R
*
*/

{admcab.i}
def input parameter petbcod like estab.etbcod.
def input param ctitle as char.

def input param pdtini as date.
def input param pdtfim as date.

def buffer bfincotaetb for fincotaetb.
def var vcluster as char.
def var vetbcod as int.
def var vfincod as int.
def var vdtini as date.
def var vdtfim as date.
def var vconta as int.
    
def var xtime as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," inclusao "," desativa"," csv ",""].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

if pdtini <> ?
then ctitle = ctitle + " de " + string(pdtini,"99/99/9999").
if pdtfim <> ?
then ctitle = ctitle + " ate " + string(pdtfim,"99/99/9999").


    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.
    pause 0.
    form  
        fincotaetb.etbcod
        estab.munic format "x(10)"
        fincotaetb.fincod
        finan.finnom format "x(10)"
        fincotaetb.dtivig
        fincotaetb.dtfvig
        fincotaetb.ativo        
        fincotaetb.CotasLib
        fincotaetb.CotasUso
            
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find fincotaetb where recid(fincotaetb) = recatu1 no-lock.
    if not available fincotaetb
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(fincotaetb).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available fincotaetb
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find fincotaetb where recid(fincotaetb) = recatu1 no-lock.

        status default "".
        
        vcluster = "".
        
        esqcom1[3] =  if fincotaetb.ativo then " desativa" else " ativa".
        if fincotaetb.dtfvig < today then esqcom1[3] = "".
                
        esqcom1[1] = " parametros".
        
        find fincotaclplan where fincotaclplan.fincod = fincotaetb.fincod no-lock no-error.
        if avail fincotaclplan
        then do:
            find fincotacluster of fincotaclplan no-lock.
            find fincotacllib  where fincotacllib.fcccod = fincotacluster.fcccod and
                                 fincotacllib.etbcod = fincotaetb.etbcod and
                                 fincotacllib.dtivig = fincotaetb.dtivig
                     no-lock no-error.            
            if avail fincotacllib
            then do:                                 
                vcluster = fincotacluster.fcccod.
                hide message no-pause.
                message "cota liberada no cluster " vcluster fincotacluster.fccnom "   Liberado Total =>" fincotacllib.cotaslib.
                esqcom1[1] = "".
            end.
        end.
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field fincotaetb.etbcod

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

                run color-normal.
        hide message no-pause.
                 
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail fincotaetb
                    then leave.
                    recatu1 = recid(fincotaetb).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail fincotaetb
                    then leave.
                    recatu1 = recid(fincotaetb).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail fincotaetb
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail fincotaetb
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = " parametros "
            then do:
                hide frame f-com1 no-pause.

                run pparametros.    
                leave.
            end.
            if esqcom1[esqpos1] = " inclusao "
            then do:
                hide frame f-com1 no-pause.
                run pinclui (output recatu1).
                leave.
                
            end. 
            if esqcom1[esqpos1] = " desativa " or esqcom1[esqpos1] = " ativa "
            then do:
                run color-message.

                run pdesativa.
                recatu1 = ?.
                leave.
            end. 
            
            
            if esqcom1[esqpos1] = " carga "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run pcarga.
                recatu1 = ?.
                leave.
                
            end. 
            
            
             if esqcom1[esqpos1] = " csv "
             then do: 
                    run geraCSV.
                end.
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(fincotaetb).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    find estab of fincotaetb no-lock no-error. 
    find finan of fincotaetb no-lock.
    def var vcotascluster as log.
    vcotascluster = no.
    
        find fincotaclplan where fincotaclplan.fincod = fincotaetb.fincod no-lock no-error.
        if avail fincotaclplan
        then do:
            find fincotacluster of fincotaclplan no-lock.
            find fincotacllib  where fincotacllib.fcccod = fincotacluster.fcccod and
                                 fincotacllib.etbcod = fincotaetb.etbcod and
                                 fincotacllib.dtivig = fincotaetb.dtivig
                     no-lock no-error.            
            if avail fincotacllib
            then do:              
                vcotascluster = yes.
            end.
        end.            
    display  
        fincotaetb.etbcod
        estab.munic  when avail estab
        fincotaetb.fincod
        finan.finnom 
        fincotaetb.dtivig
        fincotaetb.dtfvig
        fincotaetb.ativo        
        fincotaetb.CotasLib when vcotascluster = no
        fincotaetb.CotasUso

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        fincotaetb.etbcod
        estab.munic  when avail estab
        fincotaetb.fincod
        finan.finnom 
        fincotaetb.dtivig
        fincotaetb.dtfvig
        fincotaetb.ativo        
        fincotaetb.CotasLib
        fincotaetb.CotasUso

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        fincotaetb.etbcod
        estab.munic  when avail estab
        fincotaetb.fincod
        finan.finnom 
        fincotaetb.dtivig
        fincotaetb.dtfvig
        fincotaetb.ativo        
        fincotaetb.CotasLib
        fincotaetb.CotasUso
        
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        fincotaetb.etbcod
        estab.munic  when avail estab
        fincotaetb.fincod
        finan.finnom 
        fincotaetb.dtivig
        fincotaetb.dtfvig
        fincotaetb.ativo        
        fincotaetb.CotasLib
        fincotaetb.CotasUso
        
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find last fincotaetb  where if petbcod > 0 then fincotaetb.etbcod = petbcod else true
            and (if pdtini <> ? then fincotaetb.dtivig >= pdtini else true)
            and (if pdtfim <> ? then fincotaetb.dtfvig <= pdtfim else true)
            
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find prev fincotaetb  where if petbcod > 0 then fincotaetb.etbcod = petbcod else true
            and (if pdtini <> ? then fincotaetb.dtivig >= pdtini else true)
            and (if pdtfim <> ? then fincotaetb.dtfvig <= pdtfim else true)
        
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find next fincotaetb  where if petbcod > 0 then fincotaetb.etbcod = petbcod else true
            and (if pdtini <> ? then fincotaetb.dtivig >= pdtini else true)
            and (if pdtfim <> ? then fincotaetb.dtfvig <= pdtfim else true)

                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current fincotaetb exclusive.
        disp fincotaetb.etbcod.
        disp    
            fincotaetb  
                   with row 9 
        centered
        overlay 1 column.
                    
        update fincotaetb.dtivig  fincotaetb.DtFVig 
               fincotaetb.ativo
               fincotaetb.cotaslib.


    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last bfincotaetb no-lock no-error.
    create fincotaetb.
    prec = recid(fincotaetb).
    if petbcod = 0
    then do:
        update fincotaetb.etbcod.
        find estab of fincotaetb no-lock no-error.
        if not avail estab
        then do:
            message "filial invalida".
            undo.
        end.    
    end.    
    else  fincotaetb.etbcod = petbcod.
    disp
        fincotaetb.etbcod 
        with row 9 
        centered
        overlay 1 column.
        update
            fincotaetb.fincod.
        find finan where finan.fincod = fincotaetb.fincod no-lock no-error.
        if not avail finan or (avail finan and finan.fincod = 0)
        then do:
            message "plano invalido".
            undo, retry.
        end.   
        update fincotaetb.dtivig  fincotaetb.DtFVig 
               fincotaetb.ativo
               fincotaetb.cotaslib.


    find last bfincotaetb where bfincotaetb.etbcod = fincotaetb.etbcod and
                                 bfincotaetb.fincod = fincotaetb.fincod and
                                 bfincotaetb.dtivig < fincotaetb.dtivig and
                                 bfincotaetb.dtfvig = ?
        no-error.
    if avail bfincotaetb
    then bfincotaetb.dtfvig = fincotaetb.dtivig - 1.
                                              


end.


end procedure.



procedure pdesativa.
sresp = yes.
message color normal "confirma?" update sresp.
if sresp
then do on error undo:
    find current fincotaetb exclusive no-wait no-error.
    if avail fincotaetb
    then do:
        fincotaetb.ativo = not fincotaetb.ativo.
/*        delete fincotaetb.    */
    end.        
end.
end procedure.



procedure pcarga.
def var vcotas as int.
def var vpasta as char format "x(40)".
disp "                  Filial;Plano;data inicio;data final;Cotas;" skip
    with frame fff.

update vpasta label "Pasta /admcom/" colon 20
    with side-labels frame fff.
def var varquivo as char format "x(50)" label "Arquivo CSV (;)" .
hide frame  fff no-pause.

run   /admcom/progr/get_file.p ("/admcom/" + trim(lc(vpasta) + "/"), "csv", output varquivo) .

disp varquivo colon 20
    with row 3
        centered
        with frame fff.
if search(varquivo) = ?
then do:
    message "arquivo nao encontrado"
        view-as alert-box.
    return.
end.            
def var vokestab as log.
def var vokfinan as log.
vokfinan = yes.
vokestab = no.
vconta = 0.
input from value(varquivo).
repeat on error undo, leave.
    vconta = vconta + 1.
    if vconta = 1 then next.
    
    import delimiter ";" vetbcod vfincod vdtini vdtfim vcotas no-error.
    if vetbcod <> petbcod then do:
        vconta = vconta - 1.
        next.
    end.    
    if vfincod = 0 or vfincod = ? then next.
    find finan where finan.fincod = vfincod no-lock no-error.
    if not avail finan
    then do:
        vokfinan = no.
    end.
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if avail estab
        then do:
            if vetbcod = petbcod
            then vokestab = yes. 
        end.    
    end.
    else do:
        vokestab = yes.
    end.
end.
input close.

if vokestab = no or vokfinan = no
then do:
    message "erro no arquivo, provavelmente formatacao"
        view-as alert-box.
    undo.
end.
 
sresp = no.
message "carga com" vconta - 2 "registros".
message "Antes da Carga, Eliminar os registros antigos na tabela de bloqueios?" update sresp.
if sresp
then do:
    for each fincotaetb where fincotaetb.etbcod = petbcod.
        delete fincotaetb.
    end.    
end.
hide message no-pause.
message "aguarde....".
vconta = 0.
input from value(varquivo).
repeat on error undo, leave.
    vconta = vconta + 1.
    if vconta = 1 then next.
    
    import delimiter ";" vetbcod vfincod vdtini vdtfim vcotas no-error.

    if vfincod = 0 or vfincod = ? then next.
    
    
    find fincotaetb where fincotaetb.etbcod = vetbcod and fincotaetb.fincod = vfincod no-error.
    if not avail fincotaetb
    then do:
        create fincotaetb.
        fincotaetb.etbcod = vetbcod.
        fincotaetb.fincod = vfincod.
        fincotaetb.dtivig = vdtini.
    end.
    fincotaetb.dtfvig = vdtfim.
    fincotaetb.cotaslib = vcotas.    
    fincotaetb.ativo = yes.    
end.
input close.

hide message no-pause.

end procedure.



procedure geraCSV.
def var pordem as int.
 
def var varqcsv as char format "x(65)".
    if petbcod = 0
    then do:
        varqcsv = "/admcom/relat/cotasplano_" + 
                string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
    end.
    else do:
        varqcsv = "/admcom/relat/cotasplano_filial" + string(petbcod) + "_" + 
            string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
    
    end.

    update varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "csv"
                            overlay.


message "Aguarde...". 
output to value(varqcsv).
put unformatted  "filial;muncipio;plano;nomePlano;" 
                 "dataInicio;dataFinal;"
                 "cotas Liberadas;cotas Usadas;"
                 skip.

    for each bfincotaetb  where (if petbcod > 0 then bfincotaetb.etbcod = petbcod else true)
            and (if pdtini <> ? then fincotaetb.dtivig >= pdtini else true)
            and (if pdtfim <> ? then fincotaetb.dtfvig <= pdtfim else true)

        no-lock.

        find estab of bfincotaetb no-lock no-error. 
        find finan of bfincotaetb no-lock.
    
        put unformatted
            bfincotaetb.etbcod ";"
            if avail estab then estab.munic  else "" ";"
            bfincotaetb.fincod ";"
            finan.finnom          ";"
            string(bfincotaetb.dtivig,"99/99/9999") ";"
            (if bfincotaetb.dtfvig = ? then "" else string(bfincotaetb.dtfvig,"99/99/9999")) ";"
            bfincotaetb.CotasLib ";"
            bfincotaetb.CotasUso ";"

            skip.

    end.  


output close.

        hide message no-pause.
        message "Arquivo csv gerado " varqcsv.
        hide frame f1 no-pause.
        pause.    

end procedure.




