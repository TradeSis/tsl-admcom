{admcab.i}

def var vsenha as char format "x(10)".

update vsenha blank label "Senha"
       with frame f-senha centered side-labels. 
           
hide frame f-senha no-pause.
             
if vsenha <> "crm-drebes"
then leave.   
               
def var vopcao as char extent 8  format "x(60)"
    init ["1. Verificacao de valores / Geracao de campanha ",
          "2. Arquivo para Grafica / Geracao de Bonus ",
          "3. Listagem de Bonus Presente - Mensal ",
          "4. Listagem - Acao Aniversario do Conjuge",
          "5. Exclusao de Bonus",
          "6. Geracao de Bonus (Valor e Percentual de Desconto)",
          "7. Gera Acao para clientes que nao movimentaram - RFV 000",
          "8. Gera Acao para clientes que pagaram a ultima parcela  "].
         
def var vop1 as char extent 2 format "x(35)"
    init ["1. Bonus Presente ",
          "2. Aniversario do Conjuge "].


if connected ("crm")
then disconnect crm.

/*** Conectando Banco CRM no server CRM ***/
/*connect crm -H 192.168.0.8 -S sdrebcrm -N tcp -ld crm no-error.*/
    connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.

               
if not connected ("crm")
then do:
    message "Nao foi possivel conectar o banco CRM. Avise o CPD.".
    pause.
    leave.
end.

repeat:
    view frame fc1. pause 0.
    view frame fc2. pause 0.
    disp  skip(1)
          space(3) vopcao[1] skip(1)
          space(3) vopcao[2] skip(1)
          space(3) vopcao[3] skip(1)
          space(3) vopcao[4] skip(1)
          space(3) vopcao[5] skip(1)
          space(3) vopcao[6] skip(1)
          space(3) vopcao[7] skip(1)
          space(3) vopcao[8] skip(1)
          with frame f-opcao title " Bonus " row 3
          centered no-label overlay.  
           
    choose field vopcao auto-return with frame f-opcao.
    if frame-index = 1
    then do:
        hide frame f-opcao no-pause.

        disp  skip(1) 
              space(3) vop1[1] skip(1) 
              space(3) vop1[2] skip
              with frame f-op1a title " Verificacao de valores / Geracao de campanha " row 7 
                                 centered no-label overlay.  
        choose field vop1 auto-return with frame f-op1a.
        hide frame f-op1a no-pause.
        
        if frame-index = 1
        then do:
            run conecta_d.p.
            run bonus002.p.
            if connected("d")
            then disconnect d.
        end.
        else 
        if frame-index = 2
        then do:
           run conecta_d.p.
           run bonus005.p.
           if connected("d")
           then disconnect d.
        end.
    end.
    else
    if frame-index = 2
    then do:
        hide frame f-opcao no-pause.

        disp  skip(1) 
              space(3) vop1[1] skip(1) 
              space(3) vop1[2] skip
              with frame f-op1 title 
              " Arquivo para Grafica / Geracao de Bonus " row 7 
                                 centered no-label overlay.  
        choose field vop1 auto-return with frame f-op1.
        hide frame f-op1 no-pause.
        
        if frame-index = 1
        then do:
            run bonus004.p.
        end.
        else 
        if frame-index = 2
        then do:
            run bonus007.p.
        end.
    
    end.
    else
    if frame-index = 3
    then do:
        hide frame f-opcao no-pause.
        run lisbon01.p.
    end.
    else
    if frame-index = 4
    then do:
        hide frame f-opcao no-pause.
        run impconj1.p.
    end.
    else
    if frame-index = 5
    then do:
        hide frame f-opcao no-pause.
        run delbon01.p.
    end.
    else
    if frame-index = 6
    then do:
        hide frame f-opcao no-pause.
        run gerbon01.p.
    end.
    else
    if frame-index = 7
    then do:
        hide frame f-opcao no-pause.
        run rfv000.p.
    end.
    else
    if frame-index = 8
    then do:
        hide frame f-opcao no-pause.
        run conecta_d.p.
        if not connected("d")
        then do:
            message color red/with
            "Banco nao conectado." view-as alert-box.
        end.
        else do:
            run clultpar.p.
            if connected("d")
            then disconnect d.
        end.
    end.        
end.

if connected ("crm")
then disconnect crm.
