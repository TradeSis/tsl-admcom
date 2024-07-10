/* 05012022 helio iepro */

def {1} shared temp-table ttfiltros no-undo serialize-name "filtros" 
    field clicod        as int format ">>>>>>>>>>9" init 0
    field qtdsel        as int format ">,>>>,>>9" init 1000
    field vlrctrmin     as dec format ">>>>,>>9.99" 
    field vlrctrmax     as dec format ">>>>,>>9.99" 
    field vlrabemin     as dec format ">>>>,>>9.99" 
    field vlrabemax     as dec format ">>>>,>>9.99"
    field vlrparcmin    as dec format ">>,>>9.99"
    field vlrparcmax    as dec format ">>,>>9.99"
    field diasatrasmin  as int format "99999" init 1
    field diasatrasmax  as int format "99999" init 99999
    field dtemiini      as date format "99/99/9999"
    field dtemimax      as date format "99/99/9999"
    field modcod        as char format "x(25)"
    field tpcontrato    as char format "x(12)" 

    field arrastaparcelasvencidas as log format "Sim/Nao"
    field arrastaparcelas as log format "Sim/Nao"
    field arrastacontratosvencidos as log format "Sim/Nao"
    field arrastacontratos    as log format "Sim/Nao"
    field comarca           as int format ">>>>>>>>9".
    

def {1} shared temp-table ttcontrato no-undo  serialize-name "contratos"
    field marca     as log format "*/ " serialize-hidden
    field clicod    like contrato.clicod
    field clinom    like clien.clinom
    field contnum   like contrato.contnum    format ">>>>>>>>9"
/*    field titpar    like titulo.titpar       format ">9" column-label "Pr" -- visao sempre sera por contrato*/
    field vlrctr    like contrato.vltotal
    field vlrpag    as dec
    field vlrabe    as dec
    field vlratr    as dec
    field vlrjur    as dec
    field vlrdiv    as dec
    field titdtemi  like titulo.titdtemi
    field titdtven  like titulo.titdtven
    field modcod    like titulo.modcod
    field tpcontrato like titulo.tpcontrato
/*    field titvlcob  as dec    */
    field qtdpag    as int
    field diasatraso    as int format "-99999"
/*    field trecid    as recid serialize-hidden */
    field nossonumero like titprotesto.nossonumero
    index contnum is unique primary clicod asc contnum asc /*titpar asc*/ .


def {1} shared temp-table ttparcela no-undo  serialize-name "parcelas"
    field contnum   like contrato.contnum    format ">>>>>>>>9"
    field titpar    like titulo.titpar       format ">9" 
    
    field titvljur  as dec   
    field trecid    as recid serialize-hidden 
    index contnum is unique primary contnum asc titpar asc .





 