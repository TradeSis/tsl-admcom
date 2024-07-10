/*  criarepexporta.p    */
def input parameter par-tabela  as char.
def input parameter par-evento  as char.
def input parameter par-rec     as recid.

do on error undo.
    create repexporta.
    ASSIGN repexporta.TABELA       = par-tabela 
           repexporta.DATATRIG     = today 
           repexporta.HORATRIG     = time 
           repexporta.EVENTO       = par-evento 
           repexporta.DATAEXP      = ? 
           repexporta.HORAEXP      = ? 
           repexporta.BASE         = "ADMCOM" 
           repexporta.Tabela-Recid = par-rec.
end.    
