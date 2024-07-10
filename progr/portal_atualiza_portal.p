def var c-dir as char initial "/admcom/progr/" no-undo.

output to /admcom/logs/portal/atualiza_portal.log append.

put "Inicio " + STRING( INTEGER( truncate( MTIME( DATETIME( TODAY, MTIME ) ) / 1000, 0 ) ), "HH:MM:SS" ) skip.
put "portal_caracteristica.p" skip.
run value(c-dir + "portal_caracteristica.p").
put "portal_clafis.p" skip.
run value(c-dir + "portal_clafis.p").
put "portal_classe.p" skip.
run value(c-dir + "portal_classe.p").
put "portal_comprador.p" skip.
run value(c-dir + "portal_comprador.p").
put "portal_condicao_pagto.p" skip.
run value(c-dir + "portal_condicao_pagto.p").
put "portal_cor.p" skip.
run value(c-dir + "portal_cor.p").
put "portal_departamento.p" skip.
run value(c-dir + "portal_departamento.p").
put "portal_estabelecimento.p" skip.
run value(c-dir + "portal_estabelecimento.p").
put "portal_estacao.p" skip.
run value(c-dir + "portal_estacao.p").
put "portal_fabricante.p" skip.
run value(c-dir + "portal_fabricante.p").
put "portal_fornecedor.p" skip.
run value(c-dir + "portal_fornecedor.p").
put "portal_mixmoda.p" skip.
run value(c-dir + "portal_mixmoda.p").
put "portal_subcaracteristica.p" skip.
run value(c-dir + "portal_subcaracteristica.p").
put "portal_temporada.p" skip.
run value(c-dir + "portal_temporada.p").
put "portal_unidade.p" skip.
run value(c-dir + "portal_unidade.p").
put "portal_unidadevenda.p" skip.
run value(c-dir + "portal_unidadevenda.p").
put "Fim " + STRING( INTEGER( truncate( MTIME( DATETIME( TODAY, MTIME ) ) / 1000, 0 ) ), "HH:MM:SS" ) skip.

output close.
