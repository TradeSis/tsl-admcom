def workfile wftot
    field etbcod        like contrato.etbcod
    field dtinicial     like contrato.dtinicial
    field datexp        like contrato.datexp.

for each contrato where contrato.dtinicial >= 05/15/1996 by dtinicial.
    if contrato.banco <> 99
    then next.
    find first wftot where wftot.etbcod    = contrato.etbcod and
			   wftot.dtinicial = contrato.dtinicial and
			   wftot.datexp    = contrato.datexp no-error.
    if not avail  wftot
    then do:
	create wftot.
	assign wftot.etbcod    = contrato.etbcod
	       wftot.dtinicial = contrato.dtinicial
	       wftot.datexp    = contrato.datexp.
    end.
end.

output to printer page-size 64.
for each wftot by WFTOT.DATEXP.
    disp wftot.datexp       column-label "Digitacao"
	 wftot.dtinicial    column-label "Dt.Compra"
	 wftot.etbcod       column-label "Loja".
end.
output close.
