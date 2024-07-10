def input parameter vdti as date.
def input parameter vdtf as date.

def input parameter vtabela as char.
def output parameter vstatus as char.
def var vqtd as int.

def new shared temp-table tt-A01_InfNFe      like nfe.A01_InfNFe.
def new shared temp-table tt-Tab_log         like nfe.tab_log.
def new shared temp-table tt-B01_IdeNFe      like nfe.B01_IdeNFe.
def new shared temp-table tt-B12_NFref       like nfe.B12_NFref.
def new shared temp-table tt-C01_Emit        like nfe.C01_Emit.
def new shared temp-table tt-docrefer        like nfe.docrefer.
def new shared temp-table tt-E01_Dest        like nfe.E01_Dest.
def new shared temp-table tt-I01_Prod        like nfe.I01_Prod.
def new shared temp-table tt-N01_icms        like nfe.N01_icms.
def new shared temp-table tt-O01_IPI         like nfe.O01_IPI.
def new shared temp-table tt-Q01_PIS         like nfe.Q01_PIS.
def new shared temp-table tt-S01_cofins      like nfe.S01_cofins.
def new shared temp-table tt-W01_total       like nfe.W01_total.
def new shared temp-table tt-X01_Transp      like nfe.X01_Transp.
def new shared temp-table tt-Z01_InfAdic     like nfe.Z01_InfAdic.
def new shared temp-table tt-placon          like nfeloja.placon.
def new shared temp-table tt-movcon          like nfeloja.movcon.
def new shared temp-table tt-planiaux        like nfeloja.planiaux.

vqtd = 0.

run cria-temp.    

run atu-dados.

vstatus = string(vqtd) + " REGISTROS ATUALIZADOS ".


procedure cria-temp:

for each nfeloja.A01_infnfe where A01_infnfe.situacao <> ""
        no-lock,
    first nfeloja.B01_IdeNFe of nfeloja.A01_infnfe where
          nfeloja.B01_IdeNFe.demi >= vdti and
          nfeloja.B01_IdeNFe.demi <= vdtf 
                           no-lock:
          
    find first tt-A01_infnfe where
               tt-A01_infnfe.emite = A01_infnfe.emite and
               tt-A01_infnfe.serie = A01_infnfe.serie and
               tt-A01_infnfe.numero = A01_infnfe.numero
               no-error.
    if not avail tt-A01_infnfe
    then do:           
        create tt-A01_infnfe.
        buffer-copy A01_infnfe to tt-A01_infnfe.
    end.
end.        

for each tt-A01_infnfe no-lock,

    first nfeloja.A01_infnfe where A01_infnfe.emite = tt-A01_infnfe.emite and
                               A01_infnfe.serie = tt-A01_infnfe.serie and
                               A01_infnfe.numero = tt-A01_infnfe.numero
                               no-lock:
               
    find nfeloja.B01_IdeNFe of nfeloja.A01_infnfe no-lock no-error.
    if avail nfeloja.B01_IdeNFe
    then do:
        create tt-B01_IdeNFe.
        buffer-copy nfeloja.B01_IdeNFe to tt-B01_IdeNFe.
    end.
    for each nfeloja.B12_NFref of nfeloja.A01_infnfe no-lock:
        create tt-B12_NFref.
        buffer-copy B12_NFref to tt-B12_NFref.
    end.    
    find nfeloja.C01_Emit of nfeloja.A01_infnfe no-lock no-error.
    if avail nfeloja.C01_Emit
    then do:
        create tt-C01_Emit.
        buffer-copy nfeloja.C01_Emit to tt-C01_Emit.
    end.     
    for each nfeloja.docrefer where 
             nfeloja.docrefer.etbcod = nfeloja.A01_infnfe.etbcod and
             nfeloja.docrefer.serieori  = nfeloja.A01_infnfe.serie  and
             nfeloja.docrefer.numori = nfeloja.A01_infnfe.numero
             no-lock:
        create tt-docrefer.
        buffer-copy nfeloja.docrefer to tt-docrefer.         
    end.
    find nfeloja.E01_Dest of nfeloja.A01_infnfe no-lock no-error.
    if avail nfeloja.E01_Dest
    then do:
        create tt-E01_Dest.
        buffer-copy nfeloja.E01_Dest to tt-E01_Dest.
    end.    
    for each nfeloja.I01_Prod of nfeloja.A01_infnfe no-lock:
        create tt-I01_Prod.
        buffer-copy nfeloja.I01_Prod to tt-I01_Prod.
    end.
    for each nfeloja.N01_icms of nfeloja.A01_infnfe no-lock:
        create tt-N01_icms.
        buffer-copy nfeloja.N01_icms to tt-N01_icms.
    end.            
    for each nfeloja.O01_IPI of nfeloja.A01_infnfe no-lock:
        create tt-O01_IPI.
        buffer-copy nfeloja.O01_IPI to tt-O01_IPI.
    end.    
    for each nfeloja.Q01_PIS of nfeloja.A01_infnfe no-lock:
        create tt-Q01_PIS.
        buffer-copy nfeloja.Q01_PIS to tt-Q01_PIS.
    end.    
    for each nfeloja.S01_cofins of nfeloja.A01_infnfe no-lock:
        create tt-S01_cofins.
        buffer-copy nfeloja.S01_cofins to tt-S01_cofins.
    end.    
    find nfeloja.W01_total of nfeloja.A01_infnfe no-lock no-error.
    if avail nfeloja.W01_total
    then do:
        create tt-W01_total.
        buffer-copy nfeloja.W01_total to tt-W01_total.
    end.    
    for each nfeloja.X01_Transp of nfeloja.A01_infnfe no-lock:
        create tt-X01_Transp.
        buffer-copy nfeloja.X01_Transp to tt-X01_Transp.
    end.    
    find nfeloja.Z01_InfAdic of nfeloja.A01_infnfe no-lock no-error.
    if avail nfeloja.Z01_InfAdic
    then do:
        create tt-Z01_InfAdic.
        buffer-copy nfeloja.Z01_InfAdic to tt-Z01_InfAdic.
    end.
    find first nfeloja.tab_log where tab_log.etbcod = A01_InfNFe.etbcod and
                        tab_log.nome_campo = "NFe-Solicitacao" and
                        tab_log.valor_campo = A01_InfNFe.chave
                        no-lock no-error.
    if avail tab_log
    then do:
        create tt-tab_log.
        buffer-copy tab_log to tt-tab_log.
    end.
    find first nfeloja.tab_log where tab_log.etbcod = A01_InfNFe.etbcod and
                        tab_log.nome_campo = "NFe-UltimoEvento" and
                        tab_log.valor_campo = A01_InfNFe.chave
                        no-lock no-error.
    if avail tab_log
    then do:
        create tt-tab_log.
        buffer-copy tab_log to tt-tab_log.
    end.    
end.
 
end procedure. 

procedure atu-dados:

for each tt-A01_InfNFe:
    find nfe.A01_InfNFe where 
         nfe.A01_InfNFe.chave = tt-A01_InfNFe.chave no-lock no-error.
    if not avail nfe.A01_InfNFe
    then do:
        create nfe.A01_InfNFe.
        buffer-copy tt-A01_InfNFe to nfe.A01_InfNFe.
        vqtd = vqtd + 1.
    end.
end.
for each tt-tab_log:
    find first nfe.tab_log where 
               nfe.tab_log.etbcod = tt-tab_log.etbcod and
               nfe.tab_log.nome_campo = tt-tab_log.nome_campo and
               nfe.tab_log.valor_campo = tt-tab_log.valor_campo
                        no-lock no-error.
    if not avail nfe.tab_log
    then do:
        create nfe.tab_log.
        buffer-copy tt-tab_log to nfe.tab_log.
    end.
end.
for each tt-B01_IdeNFe:
    find nfe.B01_IdeNFe of tt-B01_IdeNFe no-lock no-error.
    if not avail nfe.B01_IdeNFe
    then do:
        create nfe.B01_IdeNFe.
        buffer-copy tt-B01_IdeNFe to nfe.B01_IdeNFe.
    end.
end.    
for each tt-B12_NFref:
    find nfe.B12_NFref of tt-B12_NFref no-lock no-error.
    if not avail nfe.B12_NFref
    then do:
        create nfe.B12_NFref.
        buffer-copy tt-B12_NFref to nfe.B12_NFref.
    end.
end.
for each tt-C01_Emit:
    find nfe.C01_Emit of tt-C01_Emit no-lock no-error.
    if not avail nfe.C01_Emit
    then do:
        create nfe.C01_Emit.
        buffer-copy tt-C01_Emit to nfe.C01_Emit.
    end.
end.    
for each tt-docrefer:
    find nfe.docrefer where
         nfe.docrefer.etbcod = tt-docrefer.etbcod and
         nfe.docrefer.codedori = tt-docrefer.codedori and
         nfe.docrefer.serieori = tt-docrefer.serieori and
         nfe.docrefer.numori = tt-docrefer.numori
         no-lock no-error.
    if not avail nfe.docrefer
    then do:
        create nfe.docrefer.
        buffer-copy tt-docrefer to nfe.docrefer.    
    end.
end.    
for each tt-E01_Dest:
    find nfe.E01_Dest of tt-E01_Dest no-lock no-error.
    if not avail nfe.E01_Dest
    then do:
        create nfe.E01_Dest.
        buffer-copy tt-E01_Dest to nfe.E01_Dest.
    end.
end.        
for each tt-I01_Prod:
    find nfe.I01_Prod of tt-I01_Prod no-lock no-error.
    if not avail nfe.I01_Prod
    then do:
        create nfe.I01_Prod.
        buffer-copy tt-I01_Prod to nfe.I01_Prod.
    end.
end.    
for each tt-N01_icms:
    find nfe.N01_icms of tt-N01_icms no-lock no-error.
    if not avail nfe.N01_icms
    then do:
        create nfe.N01_icms.
        buffer-copy tt-N01_icms to nfe.N01_icms.
    end.
end.
for each tt-O01_IPI:
    find nfe.O01_IPI of tt-O01_IPI no-lock no-error.
    if not avail nfe.O01_IPI
    then do:
        create nfe.O01_IPI.
        buffer-copy tt-O01_IPI to nfe.O01_IPI.
    end.
end.    
for each tt-Q01_PIS:
    find nfe.Q01_PIS of tt-Q01_PIS no-lock no-error.
    if not avail nfe.Q01_PIS
    then do:
        create nfe.Q01_PIS.
        buffer-copy tt-Q01_PIS to  nfe.Q01_PIS.
    end.
end.
for each tt-S01_cofins:
    find nfe.S01_cofins of tt-S01_cofins no-lock no-error.
    if not avail nfe.S01_cofins
    then do:
        create nfe.S01_cofins.
        buffer-copy tt-S01_cofins to nfe.S01_cofins.
    end.
end.    
for each tt-W01_total:
    find nfe.W01_total of tt-W01_total no-lock no-error.
    if not avail nfe.W01_total
    then do:
        create nfe.W01_total.
        buffer-copy tt-W01_total to nfe.W01_total.    
    end.
end.
for each tt-X01_Transp:
    find nfe.X01_Transp of tt-X01_Transp no-lock no-error.
    if not avail nfe.X01_Transp
    then do:
        create nfe.X01_Transp.
        buffer-copy tt-X01_Transp to nfe.X01_Transp.
    end.
end.    
for each tt-Z01_InfAdic:
    find nfe.Z01_InfAdic of tt-Z01_InfAdic no-lock no-error.
    if not avail nfe.Z01_InfAdic
    then do:
        create nfe.Z01_InfAdic.
        buffer-copy tt-Z01_InfAdic to nfe.Z01_InfAdic.    
    end.
end.

end procedure.
