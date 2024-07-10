    
    vjuros = 0.
    
    run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad,
                   titulo.titdtven,
                   titulo.titvlcob,
                   output vjuros).
    
    run pegaproduto.
                           
    vcarteira = if titulo.cobcod = 1 or titulo.cobcod = 2 then "LEBES" else
                if titulo.cobcod = 10 then "FINANCEIRA" else
                if titulo.cobcod = 14 or titulo.cobcod = 16 then "FIDC"
                else "OUTROS".
               
               put {1} unformatted
                clien.ciccgc vcp
                tiporeceita vcp
                titulo.clifor vcp
                replace(clien.clinom, vcp, " ") /*format "x(40)"*/ vcp
                clien.dtnasc format "99/99/9999" vcp
                replace(clien.pai, vcp, " ") /*format "x(40)"*/ vcp
                replace(clien.mae, vcp, " ") /*format "x(40)"*/ vcp
                replace(clien.zona, vcp, " ") /*format "x(60)"*/ vcp
                clien.ciinsc /*format "x(20)"*/ vcp
                cestcivil /*format "x(10)"*/ vcp
                trim(replace(clien.conjuge, vcp, " ")) /*format "x(40)"*/ vcp
                vcp
                 replace(clien.endereco[1], vcp, " ") /*format "x(40)"*/  vcp
                 replace(string(clien.numero[1]), vcp, " ")  vcp
                 replace(clien.compl[1], vcp, " ") /*format "x(12)"*/ vcp
                 replace(clien.bairro[1], vcp, " ") /*format "x(40)" */ vcp
                 replace(clien.cep[1], vcp, " ")  vcp 
                 replace(clien.cidade[1], vcp, " ") /*format "x(40)"*/  vcp
                replace(clien.uf[1], vcp, " ") /*format "x(2)" */ vcp 
                replace(clien.fax, vcp, " ") /*format "x(15)"*/  vcp  
                replace(clien.fone, vcp, " ") /*format "x(15)"*/ vcp
                replace(clien.protel[1], vcp, " ") /*format "x(15)"*/ vcp
                replace(clien.protel[2], vcp, " ") /*format "x(15)"*/ vcp
                replace(clien.cobfone, vcp, " ") /*format "x(15)"*/ vcp
                replace(refctel[1], vcp, " ") /*format "x(15)"*/ vcp
                replace(refctel[2], vcp, " ") /*format "x(15)"*/ vcp
                titulo.titnum vcp 
                titulo.modcod vcp
                titulo.titpar vcp
                trim(string(titulo.titvlcob,"->>>>>>>>>>>9.99")) vcp
                trim(string(titulo.titvlcob + vjuros,"->>>>>>>>>>9.99"))   vcp
                titulo.titdtven format "99/99/9999" vcp
                titulo.titsit vcp
                titulo.titdtpag format "99/99/9999" vcp
                vcp
                vcp
                vcp
                trim(string(vjuros,"->>>>>>>>>9.99")) 
                ";LEBES;FINANCEIRA;"
                titulo.tpcontrato format "x(1)" vcp 
                /* novos campos */
                titulo.titdtemi format "99/99/9999"  vcp
                vproduto    vcp
                titulo.etbcod vcp
                trim(string(vrendapresumida,"->>>>>>>>>>>9.99")) vcp
                trim(string(vpercpag,"->>>>>>>>>>>9.99")) vcp
                trim(string(vQTDECONT,"->>>>>>>>>>>9")) vcp
                string(vfpd,"SIM/NAO") vcp
                 trim(string((today - clien.dtcad) / 365,"->>>>>>>>>>>9")) vcp 
                vinstrucao vcp 
                clien.proprof[1] vcp
                trim(string(vvlrLimite,">>>>>>>9.99")) vcp 
                (if avail neuclien then neuclien.catprof else "") vcp
                string(clien.tipres,"Propria/Alugada") vcp
                vcarro vcp                                                                                                
                vcarteira vcp
                "FIM"
                 skip.
