<?php

if (!isset($funcao)) {
  if ($parametro=="consultar") {
    $funcao=$parametro;
    $parametro=null;
  }
}

switch ($funcao) {
   default:
       if ($metodo=="GET"){
           if (!isset($jsonEntrada)){
              if (!isset($funcao)&&isset($parametro)) {
                 //$parametro = $funcao;
                 $funcao = "consultar";
               } else {
                 $jsonSaida = json_decode(json_encode(
                  array("erro" => "401",
                      "retorno" => "conteudo JSON vazio")
                    ), TRUE);
               }
           } else {

             $funcao = "consultar";
           }
        }


      break;
}

if (!isset($jsonSaida)) {
    switch ($funcao) {
      case "consultar":

        include 'consultar.php';

      break;
      default:
         $jsonSaida = json_decode(json_encode(
          array("erro" => "400",
              "retorno" => "Aplicacao " . $aplicacao . " Metodo ".$metodo. " Funcao  '".$funcao."'  Invalida")
            ), TRUE);
         break;
    }
}
