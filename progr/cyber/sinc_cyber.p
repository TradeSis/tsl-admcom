def input parameter par-clicod  like clien.clicod.

find clien where clien.clicod = par-clicod no-lock no-error.
if not avail clien
then leave.

find cyber_clien of clien no-lock no-error.
if not avail cyber_clien
then leave.

find first cyber_contrato of cyber_clien where 
                cyber_contrato.situacao = yes /* aberto */ 
                use-index cyber_contrato1 no-lock no-error.
if avail cyber_contrato and cyber_clien.situacao = no
then do on error undo. 
    find current cyber_clien.
    cyber_clien.situacao = yes.
end.
find current cyber_clien no-lock.
if not avail cyber_contrato and cyber_clien.situacao = yes
then do on error undo. 
    find current cyber_clien.
    cyber_clien.situacao = no.
end.

