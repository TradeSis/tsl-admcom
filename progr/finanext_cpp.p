{admcab.i}

def var vdti as date.
def var vdtf as date.
def var vdata as date.
vdti = today.
vdtf = today.
update vdti label "Emissao de"
       vdtf label "Ate"
       with frame f-data side-label 1 down width 80.
       
if vdti = ? or vdtf = ? or vdti > vdtf
then return.

def var vcont as int.
sresp = no.
message "Confirma desmarcar registros ja processados no periodo informado?"
        update sresp.
if not sresp
then return.

do vdata = vdti to vdtf:
    disp "Processando...."
        vdata with frame f-d 1 down row 10
        width 80 color message no-box no-label.
    pause 0.    
    for each contrato where 
         contrato.dtinicial = vdata no-lock:
         disp contrato.contnum format ">>>>>>>>>9" with frame f-d.
         pause 0.
         for each envfinan where
                  envfinan.empcod = 19 and
                  envfinan.titnat = no and
                  envfinan.modcod = "CP1" and
                  envfinan.etbcod = contrato.etbcod and
                  envfinan.clifor = contrato.clicod and
                  envfinan.titnum = string(contrato.contnum)
                  :
            find titulo where
                  titulo.empcod = envfinan.empcod and
                  titulo.titnat = envfinan.titnat and
                  titulo.modcod = envfinan.modcod and
                  titulo.etbcod = envfinan.etbcod and
                  titulo.clifor = envfinan.clifor and
                  titulo.titnum = envfinan.titnum and
                  titulo.titpar = envfinan.titpar
                  no-error.
            if avail titulo and titulo.cobcod = 10
            then do on error undo.
                titulo.cobcod = 2.
                create titulolog.
                assign
                    titulolog.empcod = titulo.empcod
                    titulolog.titnat = titulo.titnat
                    titulolog.modcod = titulo.modcod
                    titulolog.etbcod = titulo.etbcod
                    titulolog.clifor = titulo.clifor
                    titulolog.titnum = titulo.titnum
                    titulolog.titpar = titulo.titpar
                    titulolog.data    = today
                    titulolog.hora    = time
                    titulolog.funcod  = sfuncod
                    titulolog.campo   = "CobCod"
                    titulolog.valor   = string(titulo.cobcod)
                    titulolog.obs     = "DESMARCA ENVIO".
            end.
            do on error undo:
                delete envfinan.
            end.
            vcont = vcont + 1.
            disp vcont with frame f-d.
            pause 0.
        end.
    end.        
end.
message vcont "registros desmarcados" view-as alert-box.
