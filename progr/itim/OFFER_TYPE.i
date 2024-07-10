/*  itim/OFFER_TYPE.i   */
def var vOFFER_TYPE as char.
vOFFER_TYPE = if prof_1703.OFFER_TYPE = "NON_PRICE"  
              then "Nao Preco"
              else
              if prof_1703.OFFER_TYPE = "%OFF"  
              then "%OFF"
              else
              if prof_1703.OFFER_TYPE = "VALUE OFF"
              then "Desconto"
              else
              if prof_1703.OFFER_TYPE = "FIXED_PRICE"
              then "Valor Fixo"
              else
              if prof_1703.OFFER_TYPE = "ITEM_LIST"
              then "Lista de Produtos"
              else
              if prof_1703.OFFER_TYPE = "MULTI_UNIT"  
              then "Multi-Unidade"
              else
              if prof_1703.OFFER_TYPE = "MIX_MATCH"  
              then "Casada/Brinde"
              else                       
              if prof_1703.OFFER_TYPE = "MIX_MATCH_CHEAP"  
              then "Casada/Brinde(+Barato)"
              else prof_1703.OFFER_TYPE.