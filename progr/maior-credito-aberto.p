def input parameter p-clien like clien.clicod.
def input parameter p-qtd as int.
def output parameter p-max-valor as dec.
def output parameter p-med-valor as dec.
def output parameter p-pagas as int.
def output parameter p-pontual as int.
def temp-table ttacu
    field mes like credscor.mesacu
    field ano like credscor.anoacu
    field dat as date
    field val like credscor.valacu.

def var qtd-15 as int.
def var qtd-45 as int.
def var qtd-46 as int.

def var vnumpcp as int.
def var vdata as date .
vdata = today - (p-qtd * 30).
def var vdttit as date.
p-pagas = 0.
p-pontual = 0.
p-med-valor = 0.
for each estab no-lock:        
    for each titulo where titulo.empcod = 19 and
                               titulo.titnat = no and
                               titulo.modcod = "CRE" and
                               titulo.etbcod = estab.etbcod and
                               titulo.clifor = p-clien 
                               no-lock.
            
            if titulo.modcod = "DEV" or
               titulo.modcod = "BON" or
               titulo.modcod = "CHP"
            then next.

            if (titulo.titdtpag - titulo.titdtven) <= 15
            then qtd-15 = qtd-15 + 1.

            if (titulo.titdtpag - titulo.titdtven) >= 16 and
               (titulo.titdtpag - titulo.titdtven) <= 45
            then qtd-45 = qtd-45 + 1.

            if (titulo.titdtpag - titulo.titdtven) >= 46
            then qtd-46 = qtd-46 + 1.

            if titulo.titpar <> 0 and
               titulo.titsit = "PAG"
            then p-pagas = p-pagas + 1.   
            
            if titdtven < vdata then next.
            
            find first ttacu where ttacu.mes = month(titulo.titdtven) and
                                   ttacu.ano = year(titulo.titdtven) no-error.
            if not avail ttacu
            then do:
                create ttacu.
                assign ttacu.mes = month(titulo.titdtven)
                       ttacu.ano = year(titulo.titdtven).                
            end.
            ttacu.val = ttacu.val + titulo.titvlcob.
    end.
end.
def var p-qtdmes as int.
    p-max-valor = 0.    
    p-med-valor = 0.
    p-qtdmes = 0.
    for each ttacu:
        if ttacu.val > 0
        then 
            assign
                p-qtdmes = p-qtdmes + 1
                p-med-valor = p-med-valor + ttacu.val
                .
        if ttacu.val <= p-max-valor
        then.
        else p-max-valor = ttacu.val.
    end. 
    p-pontual = qtd-15.
    p-med-valor = p-med-valor / p-qtdmes. 


