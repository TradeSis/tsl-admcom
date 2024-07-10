{admcab.i}
def var count as int format ">>>>>>>>9".

def var dataCadastro as date format "99/99/9999".

def var localFile as char format "x(50)".

DEFINE TEMP-TABLE tt-relat
field tt-procod     as int                label "Cod Produto" format ">>>>>>>>9"
field tt-tempGar    as char               label "Tempo Garantia" format "x(15)"
field tt-descricao  as char               label "Descricao" format "x(40)"
field tt-dataExp    as date               label "Data Exportacao" format "99/99/9999"
field tt-dtcad      as date               label "Data Cadastro" format "99/99/9999"
field tt-fimVida    as char               label "Fim Vida" format "x(30)".


repeat:
  UPDATE dataCadastro LABEL "Data Inicial de Cadastro" skip
      WITH FRAME header-relat-INPUT columns 0 ROW 0 SIDE-LABELS width 80.

  if dataCadastro = ? then do:
    dataCadastro = 01/01/1900.
  end.

  LEAVE.
end.


for each produ where catcod = 31 and
                     proseq <> 99 and
                     proseq <> 98 and
                     proipiper <> 98 and
                     procod < 999999 and
                     produ.prodtcad >= dataCadastro no-lock:

      count = count + 1.

      DISP count label "Produtos processados"
      WITH FRAME header-relat-COUNT columns 0 ROW 0 SIDE-LABELS width 80.

      pause 0.

      create tt-relat.
        tt-procod = produ.procod.
        tt-descricao = produ.pronom.
        tt-dataExp = produ.datexp.
        tt-dtcad = produ.prodtcad.

        if produ.datfimvida <> ? then do:
          tt-fimVida = string(string(produ.datfimvida) + "").
        end.
        else do:
          tt-fimVida = "Nao cadastrado".
        end.

      find first produaux where produaux.procod = produ.procod and
                                produaux.nome_campo = "tempoGar" no-lock no-error.
           if avail produaux then do:

              tt-tempGar = produaux.valor_campo.

           end.
           else do:

              tt-tempGar = "Nao Cadastrado".

           end.

end.

/*
field tt-procod     as int                label "Cod Produto" format ">>>>>>>>9"
field tt-tempGar    as char               label "Tempo Garantia" format "x(15)"
field tt-descricao  as char               label "Descricao" format "x(40)"
field tt-dataExp    as date               label "Data Exportacao" format "99/99/9999"
field tt-dtcad      as date               label "Data Cadastro" format "99/99/9999"
field tt-fimVida    as char               label "Fim Vida" format "x(30)".
*/
 if opsys = "UNIX"
 then localFile = "../financeira/rel_produto_tempo_garantia" + string(time) + ".csv".
 else localFile = "..\financeira\rel_produto_tempo_garantia" + string(time) + ".csv".

output to value(localFile).

export delimiter ";"
        "Cod Produto"
        "Tempo Garantia"
        "Descricao"
        "Data Exportacao"
        "Data Cadastro"
        "Fim Vida".

for each tt-relat no-lock:

  export delimiter ";"
      tt-relat.

end.

output close.

run visurel.p(localFile,"").

DISP localFile label "Relatorio salvo em"
WITH FRAME header-relat-file columns 0 ROW 0 SIDE-LABELS width 80.
