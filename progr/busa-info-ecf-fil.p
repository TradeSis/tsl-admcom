def var vetbcod like estab.etbcod.
def var varqget as char.
def var varqput as char.
def var varq as char.
def var vmes as int.
def var vano as int.
vmes = month(today).
vano = int(substr(string(year(today),"9999"),3,2)).
vmes = 01. 
varq = "bemamfd_*" + string(vmes,"99") +
            string(vano,"99") + ".txt".


varqget = "/usr/admcom/ecfinfo/" + varq.
varqput = "/admcom/ecfinfo/" + string(vetbcod,"999").


for each estab where estab.etbcod <= 189 no-lock.
    vetbcod = estab.etbcod.
    pause 2.
    varqput = "/admcom/ecfinfo/" + string(vetbcod,"999").
    unix silent value("/admcom/ecfinfo/criadir.sh " + varqput).
    unix silent 
    value("cd /admcom/ecfinfo/ ; scp root@filial" + string(vetbcod,"999") +
         ":" + varqget + " " + varqput + " ; exit").
end.
