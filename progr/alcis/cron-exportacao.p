def var vtabela     as char extent 4 init
    ["estab",
     "forne",
     "nao_envia_mais_produ",
     "frete"].
def var vprograma   as char extent 4 init
    ["/admcom/progr/alcis/expcliente.p",
     "/admcom/progr/alcis/expforne.p",
     "/admcom/progr/alcis/expprodu.p",
     "/admcom/progr/alcis/exptransp.p"].

def var vdiretorio-ant  as char.
vdiretorio-ant = "/admcom/tmp/alcis/INS/".
def var vdiretorio-apos as char.
vdiretorio-apos = "/usr/ITF/dat/in/".

def var i as int.

def new shared var vALCIS-ARQ-ESTAB   as int.
def new shared var vALCIS-ARQ-FORNE   as int.
def new shared var vALCIS-ARQ-PRODU   as int.
def new shared var vALCIS-ARQ-TRANSP  as int.
vALCIS-ARQ-ESTAB  = 0.
vALCIS-ARQ-FORNE  = 0.
vALCIS-ARQ-PRODU  = 0.
vALCIS-ARQ-TRANSP = 0.


for each repexporta where repexport.DATAEXP = ? no-lock.
    do i = 1 to 4.  
        if repexporta.tabela = vtabela[i]
        then do.
            def var vrec as recid.
            vrec = recid(repexporta).
            run value(vprograma[i]) (repexporta.tabela-recid).
            run p.
        end.
    end.
end.    

unix silent value("mv " + vdiretorio-ant + "*.DAT " + vdiretorio-apos).

procedure p.
find repexporta where recid(repexporta) = vrec.
repexport.DATAEXP = today.
end procedure.
