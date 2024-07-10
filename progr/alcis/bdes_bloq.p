/*    alcis/bdes_bloq.p                 */
{admcab.i}
{alcis/tpalcis.i}

def input parameter par-arq as char.

def var vlinha   as char.
def var varquivo as char.
def var varq-dep as char.
def var varq-tmp as char.

def temp-table ttheader
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field Proprietario      as char format "x(12)"
    field Procod            as int
    field Qtd               as dec
    field indicador         as char format "x(2)"
    field motivo            as char format "x(30)".

varquivo = alcis-diretorio + "/" + par-arq.
varq-dep = "/admcom/tmp/alcis/bkp/" + par-arq.
varq-tmp = "/admcom/relat/consulta-bdes_bloq.arq." + string(time).

unix silent value("quoter " + varquivo + " > " + varq-tmp).
input from value(varq-tmp).
repeat.
    import vlinha.
    if substr(vlinha,15,8 ) = "BLOQ"    
    then do.
        create ttheader.
        assign
            ttheader.Remetente      = substr(vlinha,1 ,10)
            ttheader.Nome_arquivo   = substr(vlinha,11,4)
            ttheader.Nome_interface = substr(vlinha,15,8)
            ttheader.Site           = substr(vlinha,23,3)
            ttheader.Proprietario   = substr(vlinha,26,12)
            ttheader.procod         = int( substr(vlinha,38,40) )
            ttheader.qtd            = dec( substr(vlinha,78,18) ) / 1000000000
            ttheader.indicador      = substr(vlinha,96,2)   
            ttheader.motivo         = substr(vlinha,98,30).        
    end.
end.
input close.
unix silent value("rm -f " + varq-tmp).
    
/***
    VALIDACAO DO ARQUIVO
***/
for each ttheader no-lock.
    if ttheader.indicador = "00" /* libera */
    then do.
        find first prodistr where
                        prodistr.procod   = ttheader.procod and
                        prodistr.lipsit   = "A"             and
                        prodistr.etbabast = 995                  
                        no-lock no-error. 
        if not avail prodistr
        then do.
            message "Produto nao bloqueado" ttheader.procod view-as alert-box.
            return.
        end.

        /* 12/09/2013 */
        if prodistr.preqtent + ttheader.qtd > prodistr.lipqtd
        then do.
            message "Quantidade a DESBLOQUEAR invalida" view-as alert-box.
            return.
        end.
    end.

    if ttheader.qtd = 0
    then do.
        message "Quantidade zerada no arquivo" ttheader.procod 
                view-as alert-box.
        return.
    end.

    find produ where produ.procod = ttheader.procod no-lock no-error.
    if NOT avail produ
    then do.
        message "Produto invalido:" ttheader.procod view-as alert-box.
        return.
    end.
end.

/***
    PROCESSAMENTO
***/

for each ttheader no-lock.
    if ttheader.indicador = "00" /* libera */
    then do.
        find first prodistr where
                        prodistr.procod   = ttheader.procod and
                        prodistr.lipsit   = "A"             and
                        prodistr.etbabast = 995.
        assign
            prodistr.preqtent = prodistr.preqtent + ttheader.qtd.

        if prodistr.preqtent >= prodistr.lipqtd
        then prodistr.lipsit = "F".

        /* historico */
        create hprodistr.
        ASSIGN hprodistr.data     = today
               hprodistr.hora     = time
               hprodistr.procod   = prodistr.procod
               hprodistr.lipqtd   = prodistr.lipqtd
               hprodistr.lipsit   = prodistr.lipsit
               hprodistr.preqtent = prodistr.preqtent
               hprodistr.etbcod   = prodistr.etbcod
               hprodistr.numero   = prodistr.numero
               hprodistr.etbabast = prodistr.etbabast
               hprodistr.predt    = prodistr.predt
               hprodistr.lipseq   = prodistr.lipseq
               hprodistr.Tipo     = prodistr.Tipo
               hprodistr.EtbOri   = prodistr.EtbOri
               hprodistr.movpc    = prodistr.movpc
               hprodistr.proposta = "LIVRE_" + par-arq
               hprodistr.funcod   = prodistr.funcod.
    end.

    if ttheader.indicador = "90"
    then do.
        find first prodistr where
                        prodistr.procod   = ttheader.procod and
                        prodistr.lipsit   = "A"             and
                        prodistr.etbabast = 995
                        no-error.
        if not avail prodistr
        then do.
            create prodistr.
            ASSIGN prodistr.PlaCod   = ?                              
                   prodistr.procod   = ttheader.procod
                   prodistr.lipsit   = "A"
                   prodistr.preqtent = 0
                   prodistr.etbcod   = 995
                   prodistr.numero   = next-value(prodistr)
                   prodistr.etbabast = 995
                   prodistr.predt    = today
                   prodistr.lipseq   = prodistr.numero
                   prodistr.Tipo     = "BLOQ_ALCIS"
                   prodistr.EtbOri   = 995
                   prodistr.movpc    = 0
                   prodistr.proposta = par-arq
                   prodistr.funcod   = sfuncod.
        end.
        assign
            prodistr.lipqtd = prodistr.lipqtd + ttheader.qtd.

        /* Historico */                    
        create hprodistr.
        ASSIGN hprodistr.data     = today
               hprodistr.hora     = time
               hprodistr.procod   = prodistr.procod
               hprodistr.lipqtd   = prodistr.lipqtd
               hprodistr.lipsit   = prodistr.lipsit
               hprodistr.preqtent = prodistr.preqtent
               hprodistr.etbcod   = prodistr.etbcod
               hprodistr.numero   = prodistr.numero
               hprodistr.etbabast = prodistr.etbabast
               hprodistr.predt    = prodistr.predt
               hprodistr.lipseq   = prodistr.lipseq
               hprodistr.Tipo     = prodistr.Tipo
               hprodistr.EtbOri   = prodistr.EtbOri
               hprodistr.movpc    = prodistr.movpc
               hprodistr.proposta = "BLOQ_" + par-arq
               hprodistr.funcod   = prodistr.funcod.
    end.

/***
    run alcis/sinc_prodistr.p (input ttheader.procod).
***/
    pause 1 no-message.
end.                      
 
unix silent value("mv " + varquivo + " " + varq-dep).

