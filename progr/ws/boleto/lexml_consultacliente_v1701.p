
def input parameter p-arquivo as char.



def shared temp-table ClienteEntrada
    field codigo_cpfcnpj as char.


    def var v-return-mode        as log  no-undo.

    v-return-mode =
        TEMP-TABLE ClienteEntrada:READ-XML("FILE",
                                  p-arquivo ,
                                  "EMPTY",
                                  ? /* v-schemapath*/ ,
                                  ? /*v-override-def-map*/ ,
                                  ? /*v-field-type-map*/ ,
                                  ? /*v-verify-schema-mode*/ ).

