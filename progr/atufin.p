{admdisparo.i}
def shared temp-table tt-contnf        like fin.contnf.
def shared temp-table tt-titulo        like fin.titulo.
def shared temp-table tt-contrato      like fin.contrato.
def shared temp-table tt-salexporta    like fin.salexporta.
def shared temp-table tt-depban        like fin.depban.
def shared temp-table tt-correio       like fin.correio.
def shared temp-table tt-chq           like fin.chq.
def shared temp-table tt-chqtit        like fin.chqtit.

                                        /*
def temp-table tt-finan like fin.finan.   */

def var vlog1   as char.
def var i as int.

def temp-table ttservidor
    field etbcod like estab.etbcod
    field servidor like estab.etbcod.
    

vlog1  = "/usr/admcom/work/log." + string(day(today)) + string(month(today)).

input from /usr/admcom/progr/servidor.txt.
repeat :
    create ttservidor.
    import ttservidor.
end.
input close.

def var cont as int.
def buffer bestab   for estab.
def var vlog as char.
def var vdata as date.
def var vweek as i.
def var d as date.

vlog = "/usr/admcom/work/atufin" + string(time) + ".log". 

vweek = int(weekday(today)).
if vweek = 2 
then vdata = today - 2.
else vdata = today - 1.

output to value(vlog1) append.
    put "Atufin.p - Im Finan " + 
        string(time,"hh:mm:ss") skip.
output close.

cont = 0.
do :
    
    for each finmatriz.cpag no-lock,
        each finmatriz.finan where 
             finmatriz.finan.fincod = finmatriz.cpag.cpagcod
                                      no-lock.
        find fin.finan where fin.finan.fincod = finmatriz.finan.fincod
                            no-error.
        cont = cont + 1.
        if not avail fin.finan
        then  create fin.finan.
        {tt-finan.i fin.finan finmatriz.finan}
    end.
end.

output to value(vlog1) append.
    put "Atufin.p - Finan " cont 
        string(time,"hh:mm:ss") skip.
output close.

output to value(vlog1) append.
    put "Atufin.p - Im Depban " + 
        string(time,"hh:mm:ss") skip.
output close.

cont = 0.
do  :
    for each tt-depban:
        find finmatriz.depban where 
                        finmatriz.depban.etbcod = tt-depban.etbcod and 
                        finmatriz.depban.datexp = tt-depban.datexp and
                        finmatriz.depban.dephora = tt-depban.dephora no-error.
        if not avail finmatriz.depban
        then create finmatriz.depban.
        cont = cont + 1.
        {tt-depban.i finmatriz.depban tt-depban}.
    end.
end.

output to value(vlog1) append.
    put "Atufin.p - Depban " cont 
        skip
        "Atufin.p - Im Correio " 
        string(time,"hh:mm:ss") skip.
output close.

cont = 0.
/*
do :
    for each tt-correio transaction:
        find first finmatriz.correio where finmatriz.correio.funemi = 
                        tt-correio.funemi and
                        finmatriz.correio.etbcod = tt-correio.etbcod and
                        finmatriz.correio.funcod = tt-correio.funcod
                     and finmatriz.correio.assunto = tt-correio.assunto
                     no-error.
        if not avail finmatriz.correio
        then create finmatriz.correio.
        cont = cont + 1.
        {tt-correio.i finmatriz.correio tt-correio}.
    end.
    
    for each finmatriz.correio where finmatriz.correio.dtmens >= today - 1 :
        find first fin.correio where 
                               fin.correio.funemi = finmatriz.correio.funemi
                           and fin.correio.etbcod = finmatriz.correio.etbcod    
                           and fin.correio.funcod = finmatriz.correio.funcod
                           and fin.correio.assunto = finmatriz.correio.assunto
                               no-error.
        if not avail fin.correio
        then do :
            create fin.correio.
            {tt-correio.i fin.correio finmatriz.correio}.
        end.
    end.
end.
*/
output to value(vlog1) append.
    put "Atufin.p - Correio " cont 
        skip
        "Atufin.p - Im ContNF " 
        string(time,"hh:mm:ss") skip.
output close.
cont = 0.

do :
for each tt-contnf transaction:
    find finmatriz.contnf where 
         finmatriz.contnf.etbcod  = tt-contnf.etbcod and
         finmatriz.contnf.placod  = tt-contnf.placod and
         finmatriz.contnf.contnum = tt-contnf.contnum  no-error.
    if not avail finmatriz.contnf
    then create finmatriz.contnf.
    
    ASSIGN
        finmatriz.contnf.contnum   = tt-contnf.contnum
        finmatriz.contnf.PlaCod    = tt-contnf.PlaCod
        finmatriz.contnf.notanum   = tt-contnf.notanum
        finmatriz.contnf.notaser   = tt-contnf.notaser
        finmatriz.contnf.EtbCod    = tt-contnf.EtbCod.
                           
    find fin.contnf where 
         fin.contnf.etbcod  = tt-contnf.etbcod and
         fin.contnf.placod  = tt-contnf.placod and
         fin.contnf.contnum = tt-contnf.contnum  no-error.
    fin.contnf.exportado = yes.    
    
    cont = cont + 1.

    delete tt-contnf.
end.
end.

output to value(vlog1) append.
    put "Atufin.p - ContNF " cont 
        skip
        "Atufin.p - Im Contrato " 
        string(time,"hh:mm:ss") skip.
output close.
cont = 0.

do :
for each tt-contrato transaction:
    find finmatriz.contrato where 
         finmatriz.contrato.contnum = tt-contrato.contnum  no-error.
    if not avail finmatriz.contrato
    then create finmatriz.contrato.

    ASSIGN
        finmatriz.contrato.contnum   = tt-contrato.contnum
        finmatriz.contrato.clicod    = tt-contrato.clicod
        finmatriz.contrato.autoriza  = tt-contrato.autoriza
        finmatriz.contrato.dtinicial = tt-contrato.dtinicial
        finmatriz.contrato.etbcod    = tt-contrato.etbcod
        finmatriz.contrato.banco     = tt-contrato.banco
        finmatriz.contrato.vltotal   = tt-contrato.vltotal
        finmatriz.contrato.vlentra   = tt-contrato.vlentra
        finmatriz.contrato.situacao  = tt-contrato.situacao
        finmatriz.contrato.indimp    = tt-contrato.indimp
        finmatriz.contrato.lotcod    = tt-contrato.lotcod
        finmatriz.contrato.crecod    = tt-contrato.crecod
        finmatriz.contrato.vlfrete   = tt-contrato.vlfrete
        finmatriz.contrato.datexp    = tt-contrato.datexp.
        
    find fin.contrato where 
         fin.contrato.contnum = tt-contrato.contnum  no-error.
    fin.contrato.exportado = yes.
    
    cont = cont + 1.
    delete tt-contrato.
end.
end.

output to value(vlog1) append.
    put "Atufin.p - Contrato " cont 
        skip
        "Atufin.p - Im Salexporta " 
        string(time,"hh:mm:ss") skip.
output close.
cont = 0.

do :
for each tt-salexporta transaction:
    find finmatriz.salexporta where 
         finmatriz.salexporta.etbcod = tt-salexporta.etbcod and
         finmatriz.salexporta.cxacod = tt-salexporta.cxacod and
         finmatriz.salexporta.saldt  = tt-salexporta.saldt  and
         finmatriz.salexporta.modcod = tt-salexporta.modcod and
         finmatriz.salexporta.moecod = tt-salexporta.moecod no-error.
    if not avail finmatriz.salexporta
    then create finmatriz.salexporta.
    
    ASSIGN
        finmatriz.salexporta.etbcod    = tt-salexporta.etbcod
        finmatriz.salexporta.cxacod    = tt-salexporta.cxacod
        finmatriz.salexporta.SalDt     = tt-salexporta.SalDt
        finmatriz.salexporta.saldo     = tt-salexporta.saldo
        finmatriz.salexporta.dtexp     = tt-salexporta.dtexp
        finmatriz.salexporta.moecod    = tt-salexporta.moecod
        finmatriz.salexporta.modcod    = tt-salexporta.modcod
        finmatriz.salexporta.salqtd    = tt-salexporta.salqtd
        finmatriz.salexporta.salexp    = tt-salexporta.salexp
        finmatriz.salexporta.salimp    = tt-salexporta.salimp.
        
    find fin.salexporta where 
         fin.salexporta.etbcod = tt-salexporta.etbcod and
         fin.salexporta.cxacod = tt-salexporta.cxacod and
         fin.salexporta.saldt  = tt-salexporta.saldt  and
         fin.salexporta.modcod = tt-salexporta.modcod and
         fin.salexporta.moecod = tt-salexporta.moecod no-error.
    fin.salexporta.exportado = yes.
    
    cont = cont + 1.
    delete tt-salexporta.
end.
end.
/********************/

output to value(vlog1) append.
    put "Atufin.p - SalExporta " cont 
        skip
        "Atufin.p - Im titulo " 
        string(time,"hh:mm:ss") skip.
output close.
cont = 0.

connect dragao -H erp.lebes.com.br -S sdragao -N tcp -ld d.

run atutitlm.p (vlog1).

disconnect d.


/*****    
for each tt-titulo :
    cont = cont + 1.
    
    do transaction : 

        find finmatriz.titulo where 
             finmatriz.titulo.empcod  = tt-titulo.empcod and
             finmatriz.titulo.titnat  = tt-titulo.titnat and
             finmatriz.titulo.modcod  = tt-titulo.modcod and
             finmatriz.titulo.etbcod  = tt-titulo.etbcod and
             finmatriz.titulo.clifor  = tt-titulo.clifor and
             finmatriz.titulo.titnum  = tt-titulo.titnum and
             finmatriz.titulo.titpar  = tt-titulo.titpar  no-error.
        if not avail finmatriz.titulo
        then do:
            if tt-titulo.clifor <> 1    and
               tt-titulo.titsit = "PAG" and
               tt-titulo.titpar <> 0
            then do:
                find finmatriz.titexporta where  
                            finmatriz.titexporta.empcod  = tt-titulo.empcod and
                            finmatriz.titexporta.titnat  = tt-titulo.titnat and
                            finmatriz.titexporta.modcod  = tt-titulo.modcod and
                            finmatriz.titexporta.etbcod  = tt-titulo.etbcod and
                            finmatriz.titexporta.clifor  = tt-titulo.clifor and
                            finmatriz.titexporta.titnum  = tt-titulo.titnum and
                            finmatriz.titexporta.titpar  = tt-titulo.titpar and
                            finmatriz.titexporta.datexp  = tt-titulo.datexp
                            no-error. 
                if not avail finmatriz.titexporta
                then do:
                   create finmatriz.titexporta.
                   {tt-titexporta.i finmatriz.titexporta tt-titulo}. 
                end.
            end.
            find first flag where flag.clicod = tt-titulo.clifor 
                        no-lock no-error.
            if avail flag and flag.flag1 = yes
            then do:
                if setbcod <> 32
                then do :
                    repeat:
                       connect dragao -H erp.lebes.com.br -S sdragao -N tcp -ld d.
                        if not connected ("d")
                        then do: 
                            if i = 5  
                            then leave. 
                            i = i + 1. 
                            next. 
                        end.  
                        else leave.
                    end.
                    run cardrag.p(recid(tt-titulo)).
        
                    disconnect d.
                    hide message no-pause.
                end.    
            end.
            else do:
                create finmatriz.titulo.
                {tt-titulo.i finmatriz.titulo tt-titulo}.
            end.
        end.
        else do:
            if finmatriz.titulo.titsit <> "PAG"
            then {tt-titulo.i finmatriz.titulo tt-titulo}.
        end.
        if avail finmatriz.titulo
        then do :
            if tt-titulo.titdtpag <> ? and
                finmatriz.titulo.titdtpag <> ?
            then do:
                if tt-titulo.titdtpag <> finmatriz.titulo.titdtpag or
                   tt-titulo.titvlpag <> finmatriz.titulo.titvlpag or
                   tt-titulo.etbcobra <> finmatriz.titulo.etbcobra
                then do:
                    create finmatriz.titexporta.
                    {tt-titexporta.i finmatriz.titexporta tt-titulo}.
                end.
            end.
        end.    
        if avail finmatriz.titulo
        then do : 
            if finmatriz.titulo.etbcod = setbcod
            then finmatriz.titulo.exportado = yes.
            else finmatriz.titulo.exportado = no.
        end.
        
        find first fin.titulo where fin.titulo.empcod  = tt-titulo.empcod 
                                and fin.titulo.titnat  = tt-titulo.titnat 
                                and fin.titulo.modcod  = tt-titulo.modcod 
                                and fin.titulo.etbcod  = tt-titulo.etbcod 
                                and fin.titulo.clifor  = tt-titulo.clifor 
                                and fin.titulo.titnum  = tt-titulo.titnum 
                                and fin.titulo.titpar  = tt-titulo.titpar  
                              no-error.
        if avail fin.titulo
        then do :
            if avail finmatriz.titulo 
            then fin.titulo.exportado = yes.
            else if avail finmatriz.titexporta
                 then fin.titulo.exportado = yes.
        end.    
            
        delete tt-titulo.
    end.
end.
*****/


output to value(vlog1) append.
    put "Atufin.p - Titulo " cont 
        skip
        "Atufin.p - Im TituloMatriz " 
        string(time,"hh:mm:ss") skip.
output close.
cont = 0.

    
run atutitml.p (vlog1).
    
/*****    
for each ttservidor where ttservidor.servidor = setbcod no-lock : 
    
    for each finmatriz.titulo where 
             finmatriz.titulo.exportado = no and 
             finmatriz.titulo.etbcod = ttservidor.etbcod
             use-index exportado. 
    
        if finmatriz.titulo.etbcobra = ttservidor.etbcod 
        then next.        
         
        if finmatriz.titulo.titnat = yes
        then next.
    
        cont = cont + 1.
        
        do transaction: 
            find first fin.titulo where 
                       fin.titulo.empcod = finmatriz.titulo.empcod
                   and fin.titulo.titnat = finmatriz.titulo.titnat 
                   and fin.titulo.modcod = finmatriz.titulo.modcod 
                   and fin.titulo.etbcod = finmatriz.titulo.etbcod 
                   and fin.titulo.clifor = finmatriz.titulo.clifor 
                   and fin.titulo.titnum = finmatriz.titulo.titnum 
                   and fin.titulo.titpar = finmatriz.titulo.titpar
                       no-error.
            if not avail fin.titulo
            then create fin.titulo.

            if fin.titulo.titsit <> "PAG" 
            then do :
                {tt-titulo.i fin.titulo finmatriz.titulo}.
            end.    
        
            assign 
                fin.titulo.exportado       = yes.
                
            find first fin.titulo where 
                       fin.titulo.empcod = finmatriz.titulo.empcod
                   and fin.titulo.titnat = finmatriz.titulo.titnat 
                   and fin.titulo.modcod = finmatriz.titulo.modcod 
                   and fin.titulo.etbcod = finmatriz.titulo.etbcod 
                   and fin.titulo.clifor = finmatriz.titulo.clifor 
                   and fin.titulo.titnum = finmatriz.titulo.titnum 
                   and fin.titulo.titpar = finmatriz.titulo.titpar
                       no-error.
            if avail fin.titulo
            then do  :
                if fin.titulo.titsit = finmatriz.titulo.titsit and
                   fin.titulo.titvlcob = finmatriz.titulo.titvlcob and 
                   fin.titulo.titdtpag = finmatriz.titulo.titdtpag 
                then finmatriz.titulo.exportado = yes.
            end.      
        end.    
    end. 
end.
*****/



output to value(vlog1) append.
    put "Atufin.p - TituloMatriz " cont 
        skip.
output close.

output to value(vlog1) append.
    put skip
        "Atufin.p - Im Chq " 
        string(time,"hh:mm:ss") skip.
output close.
cont = 0.

do :
for each tt-chq transaction:
    find finmatriz.chq where 
         finmatriz.chq.banco   = tt-chq.banco   and
         finmatriz.chq.agencia = tt-chq.agencia and
         finmatriz.chq.conta   = tt-chq.conta   and
         finmatriz.chq.numero  = tt-chq.numero  no-error.
    if not avail finmatriz.chq
    then create finmatriz.chq.

    ASSIGN  finmatriz.chq.banco     = tt-chq.banco 
            finmatriz.chq.agencia   = tt-chq.agencia 
            finmatriz.chq.valor     = tt-chq.valor 
            finmatriz.chq.data      = tt-chq.data 
            finmatriz.chq.controle1 = tt-chq.controle1 
            finmatriz.chq.controle2 = tt-chq.controle2 
            finmatriz.chq.controle3 = tt-chq.controle3 
            finmatriz.chq.comp      = tt-chq.comp 
            finmatriz.chq.exportado = no
            finmatriz.chq.datemi    = tt-chq.datemi 
            finmatriz.chq.conta     = tt-chq.conta 
            finmatriz.chq.numero    = tt-chq.numero. 
        
    find fin.chq where 
         fin.chq.banco   = tt-chq.banco     and
         fin.chq.agencia = tt-chq.agencia   and
         fin.chq.conta   = tt-chq.conta     and
         fin.chq.numero  = tt-chq.numero    no-error.
    fin.chq.exportado = yes.
    
    cont = cont + 1.
    delete tt-chq.
end.
end.

output to value(vlog1) append.
    put "Atufin.p - Chq " cont 
        skip
        string(time,"hh:mm:ss") skip.
output close.

output to value(vlog1) append.
    put skip
        "Atufin.p - Im Chqtit " 
        string(time,"hh:mm:ss") skip.
output close.
cont = 0.

do :
for each tt-chqtit transaction:
    /*
    find finmatriz.chqtit where 
         finmatriz.chqtit.modcod    = tt-chqtit.modcod  and 
         finmatriz.chqtit.CliFor    = tt-chqtit.CliFor  and
         finmatriz.chqtit.titnum    = tt-chqtit.titnum  and
         finmatriz.chqtit.titpar    = tt-chqtit.titpar  and
         finmatriz.chqtit.titnat    = tt-chqtit.titnat  and
         finmatriz.chqtit.etbcod    = tt-chqtit.etbcod  and
         finmatriz.chqtit.agencia   = tt-chqtit.agencia and 
         finmatriz.chqtit.banco     = tt-chqtit.banco   and
         finmatriz.chqtit.conta     = int(tt-chqtit.conta)    and
         finmatriz.chqtit.numero    = int(tt-chqtit.numero)   no-error.

    if not avail finmatriz.chqtit
    then create finmatriz.chqtit.
    
    ASSIGN  finmatriz.chqtit.modcod    = tt-chqtit.modcod 
            finmatriz.chqtit.CliFor    = tt-chqtit.CliFor 
            finmatriz.chqtit.titnum    = tt-chqtit.titnum 
            finmatriz.chqtit.titpar    = tt-chqtit.titpar 
            finmatriz.chqtit.titnat    = tt-chqtit.titnat 
            finmatriz.chqtit.etbcod    = tt-chqtit.etbcod 
            finmatriz.chqtit.agencia   = tt-chqtit.agencia 
            finmatriz.chqtit.banco     = tt-chqtit.banco 
            finmatriz.chqtit.exportado = no 
            finmatriz.chqtit.conta     = int(tt-chqtit.conta)
            finmatriz.chqtit.numero    = int(tt-chqtit.numero). 
            
    find fin.chqtit where  
         fin.chqtit.modcod    = tt-chqtit.modcod  and 
         fin.chqtit.CliFor    = tt-chqtit.CliFor  and
         fin.chqtit.titnum    = tt-chqtit.titnum  and
         fin.chqtit.titpar    = tt-chqtit.titpar  and
         fin.chqtit.titnat    = tt-chqtit.titnat  and
         fin.chqtit.etbcod    = tt-chqtit.etbcod  and
         fin.chqtit.agencia   = tt-chqtit.agencia and 
         fin.chqtit.banco     = tt-chqtit.banco   and
         fin.chqtit.conta     = tt-chqtit.conta   and
         fin.chqtit.numero    = tt-chqtit.numero  no-error.

    fin.chqtit.exportado = yes.
    */
    cont = cont + 1.
    
    delete tt-chqtit.
end.
end.

output to value(vlog1) append.
    put "Atufin.p - Chqtit " cont 
        skip
        string(time,"hh:mm:ss") skip.
output close.
output to value(vlog1) append.
    put  skip
        "Atufin.p - Finalizando " 
        string(time,"hh:mm:ss") skip.
output close.


output to /usr/admcom/ultimo.ini.
    put time.
output close.
