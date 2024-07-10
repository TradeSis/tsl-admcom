{/admcom/progr/portal_tabela_produto.i}

DEF TEMP-TABLE tt-erros NO-UNDO
    FIELD cod-target AS INT
    FIELD err-message AS CHAR.

DEFINE OUTPUT PARAMETER TABLE FOR tt-erros.
DEFINE INPUT PARAMETER TABLE FOR tt-produtos.

FOR EACH tt-produtos:
	
    if can-find(first produ
        where produ.proindice = string(tt-produtos.cod-barras)
	  and produ.procod <> tt-produtos.cod-produto) then do:

	CREATE tt-erros.
        ASSIGN tt-erros.cod-target = tt-produtos.cod-produto
               tt-erros.err-message = "Código de barras ja cadastrado.".

    end.

    if can-find(first produ
            where produ.itecod = tt-produtos.cod-produto
              and produ.corcod = string(tt-produtos.cod-cor)
              and produ.protam = string(tt-produtos.montagem)) then do:

	CREATE tt-erros.
        ASSIGN tt-erros.cod-target = tt-produtos.cod-produto
               tt-erros.err-message = ("Item " + string(tt-produtos.cod-produto) + " ja cadastrado.").

    end.

    IF  tt-produtos.desc-produto = "" OR 
        tt-produtos.desc-produto = ? THEN DO:

        CREATE tt-erros.
        ASSIGN tt-erros.cod-target = tt-produtos.cod-produto
               tt-erros.err-message = "Descricao do Produto nao pode ser branco.".

    END.

    IF  tt-produtos.desc-produto-abrev = "" OR 
        tt-produtos.desc-produto-abrev = ? THEN DO:

        CREATE tt-erros.
        ASSIGN tt-erros.cod-target = tt-produtos.cod-produto
               tt-erros.err-message = "Descricao para Automacao Comercial nao pode ser branco.".

    END.

    FIND FIRST fabri 
        WHERE fabri.fabcod = tt-produtos.cod-fabricante NO-LOCK NO-ERROR.

    IF NOT AVAIL fabri THEN DO:

        CREATE tt-erros.
        ASSIGN tt-erros.cod-target = tt-produtos.cod-produto
               tt-erros.err-message = "Fabricante nao cadastrado.".

    END.

    FIND FIRST clase 
        WHERE clase.clacod = tt-produtos.cod-subclasse NO-LOCK NO-ERROR.

    IF NOT AVAIL clase THEN DO:

        CREATE tt-erros.
        ASSIGN tt-erros.cod-target = tt-produtos.cod-produto
               tt-erros.err-message = "Classe nao cadastrada.".

    END.

    FIND FIRST categoria 
        WHERE categoria.catcod = tt-produtos.cod-departamento NO-LOCK NO-ERROR.

    IF NOT AVAIL categoria THEN DO:

        CREATE tt-erros.
        ASSIGN tt-erros.cod-target = tt-produtos.cod-produto
               tt-erros.err-message = "categoria nao cadastrada.".

    END.

    IF tt-produtos.dt-cadastro = ? OR
       tt-produtos.dt-cadastro = "" THEN DO:

        CREATE tt-erros.
        ASSIGN tt-erros.cod-target = tt-produtos.cod-produto
               tt-erros.err-message = "Informe a Data de Cadastramento do Produto.".

    END.

END.

/* ** Field Name: procod                                                 */
/*          Help: Informe o Codigo do Produto.                           */
/*       Val-Msg: Digito verificador nao confere, tente novamente.       */
/*       Val-Exp: {dv.v "procod"}                                        */
/*                                                                       */
/* ** Field Name: prouncom                                               */
/*          Help: Informe a Unidade de Compra do Produto (OPCIONAL).     */
/*       Val-Msg: Unidade de Compra nao cadastrada.                      */
/*       Val-Exp: prouncom = "  " or can-find(unida where unida.unicod = */
/*                prouncom)                                              */
/*                                                                       */
/* ** Field Name: prounven                                               */
/*          Help: Informe a Unidade de Venda do Produto.                 */
/*       Val-Msg: Unidade de Venda nao cadastrada.                       */
/*       Val-Exp: can-find(unida where unida.unicod = prounven)          */
/*                                                                       */
/* ** Field Name: proabc                                                 */
/*          Help: Informe a Classificacao ABC ( A/B/C ).                 */
/*       Val-Msg: Classificacao ABC fora de faixa.                       */
/*       Val-Exp: proabc = "A" or proabc = "B" or proabc = "C".          */
/*                                                                       */
/* ** Field Name: itecod                                                 */
/*          Help: Informe o Codigo do Item.                              */
/*       Val-Msg: Digito verificador nao confere, tente novamente.       */
/*       Val-Exp: {dv.v "itecod"}                                        */

