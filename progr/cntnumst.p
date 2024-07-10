/* helio 02042024 - transporte para prd */
{admcab.i}

def var vdtiv as date format "99/99/9999".
def var vdtfv as date format "99/99/9999".
def var vdtst as date format "99/99/9999".
def var vseri as int format ">>9".
def var vqtd as int.

def var vdtia as date format "99/99/9999".
def var vdtfa as date format "99/99/9999".
def var vdtsa as date format "99/99/9999".
def var vsera as int format ">>9".
def var vqtda as int.


def var v-escolha as char extent 3 format "x(30)"
    init['Consulta saldo','Tranfere saldo','Importar novo range'].
disp v-escolha with frame f1 1 column no-label width 40.
choose field v-escolha with frame f1.

if frame-index = 1
then do:
    run ver-saldo.
end.    
else if frame-index = 2
    then do:
        run tra-saldo.
        
    end.
    else if frame-index = 3
        then do:
            run importa-range.
        end.

procedure ver-saldo:
    find last segnumsorte no-lock no-error.
    if not avail segnumsorte
    then do:
        bell.
        message color red/with
            "Nenhum numero disponivel!"
            view-as alert-box.
    end.
    else do:
        message "Aguarde processando...".
        vdtiv=segnumsorte.dtivig.
        vdtfv=segnumsorte.dtfvig.
        vdtst=segnumsorte.dtsorteio.
        vseri=segnumsorte.serie.
        disp vdtiv label "Inicio" 
             vdtfv label "Fim"
             vdtst label "Sorteio"
             vseri label "Serie"
             vqtd  label "Quantidade"
             with frame f2.
        for each segnumsorte where segnumsorte.dtivig = vdtiv and
                                   segnumsorte.dtfvig = vdtfv and
                                   segnumsorte.dtuso  = ?     and
                                   segnumsorte.dtsorteio = vdtst and
                                   segnumsorte.serie  = vseri
                                   no-lock:
            vqtd = vqtd + 1.
        end.
        disp vqtd with frame f2.         
        hide message no-pause.
        message "Qunatidade disponivel: " vqtd.
                                                    
    end.
end procedure.

procedure tra-saldo:
    def buffer bsegnumsorte for segnumsorte.
    find last segnumsorte no-lock no-error.
    if not avail segnumsorte
    then do:
        bell.
        message color red/with
            "Nenhum numero disponivel!"
            view-as alert-box.
    end.
    else do:
        message "Aguarde processando saldo...".
        vdtiv=segnumsorte.dtivig.
        vdtfv=segnumsorte.dtfvig.
        vdtst=segnumsorte.dtsorteio.
        vseri=segnumsorte.serie.
        vqtd=0.
        disp vdtiv label "Inicio" 
             vdtfv label "Fim"
             vdtst label "Sorteio"
             vseri label "Serie"
             vqtd  label "Quantidade"
             with frame f2
             title "saldo atual".
        for each segnumsorte where segnumsorte.dtivig = vdtiv and
                                   segnumsorte.dtfvig = vdtfv and
                                   segnumsorte.dtuso  = ?     and
                                   segnumsorte.dtsorteio = vdtst and
                                   segnumsorte.serie  = vseri
                                   no-lock:
            vqtd = vqtd + 1.
        end.
        disp vqtd with frame f2.         
        hide message no-pause.
        message "Qunatidade disponivel: " vqtd.
        
        if vdtst = today
        then do:
            vdtia=date(month(vdtst),01,year(vdtst)).
            vdtfa=date(month(vdtst) + 1,01,year(vdtst)) - 1.
            vdtsa=date(month(vdtst) + 1,01,year(vdtst)).
            vsera=vseri.
            vqtda=0.
            disp vdtia label "Inicio"
                 vdtfa label "Fim"
                 vdtsa label "Sorteio"
                 vsera label "Serie"
                 vqtda label "Quantidade"
                 with frame f3
                 title 'transferir saldo'.
                                    
            hide message no-pause.                      
            sresp = no.
            message "Confirma tranferir saldo?" update sresp.          
            if sresp
            then do:
                message "Aguarde transferindo...".
                for each    bsegnumsorte where 
                            bsegnumsorte.dtivig = vdtiv and
                            bsegnumsorte.dtfvig = vdtfv and
                            bsegnumsorte.dtuso  = ?     and
                            bsegnumsorte.dtsorteio = vdtst and
                            bsegnumsorte.serie  = vseri
                            :
                    disp bsegnumsorte.serie 
                         bsegnumsorte.NSorteio
                        with frame f4 1 down no-label centered.
                    pause 0.
                    bsegnumsorte.dtivig = vdtia.
                    bsegnumsorte.dtfvig = vdtfa.
                    bsegnumsorte.dtsorteio = vdtsa.
                    vqtda = vqtda + 1.
                end.
                disp vqtda with frame f3.
                hide message no-pause.
                message "Total transferido: " vqtda.
            end.
        end.
        else do:
            bell.
            message color red/with
                "Tranferencia de saldo somente na data de sorteio." skip
                "Data de sorteio: " string(vdtst,"99/99/9999")   
                view-as alert-box.
        end.
    end.
end procedure. 

procedure importa-range:
    def buffer bsegnumsorte for segnumsorte.
    find last segnumsorte where
              segnumsorte.dtuso = ?  no-lock no-error.
    if not avail segnumsorte
    then do:
        
        run imprangensorte.p.
        
    end.
    else do: 
        message "Aguarde processando...".
        vqtd = 0.
        for each bsegnumsorte where 
                 bsegnumsorte.dtivig = segnumsorte.dtivig and
                 bsegnumsorte.dtfvig = segnumsorte.dtfvig and
                 bsegnumsorte.dtuso  = ?     and
                 bsegnumsorte.dtsorteio = segnumsorte.dtsorteio and
                 bsegnumsorte.serie  = segnumsorte.serie
                                   no-lock:
            vqtd = vqtd + 1.
        end.
        hide message no-pause.
        bell.
        message color red/with
                "Impossivel importar novo range!" skip
                "Ainda constam numeros da sorte disponiveis para uso." skip
                "Serie: " segnumsorte.serie " Quantidade: " vqtd    
                view-as alert-box.
        pause.
        hide message no-pause.
    end.

end procedure.    
