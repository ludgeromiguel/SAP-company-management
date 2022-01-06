*&---------------------------------------------------------------------*
*&  Include           ZBG16_AULAALV_CLASSES
*&---------------------------------------------------------------------*

CLASS lcl_pp DEFINITION.

  PUBLIC SECTION.
    TYPES: ty_carrinho TYPE STANDARD TABLE OF zbg16_vendas_t.   "tipo do carrinho

    METHODS: init.

    CLASS-METHODS:
      adicionar IMPORTING iv_id_produto TYPE zbg16_produto_t-id_produto   "id produto vindo da tela
                          iv_quantidade TYPE zbg16_vendas_t-quantidade    "quantidade vinda da tela
                          iv_id_empresa TYPE zbg16_produto_t-id_empresa   "id empresa vinda da tela
                EXPORTING ev_total      TYPE zbg16_vendas_t-valor,        "exportar o total
      remover   IMPORTING it_sel_row TYPE lvc_t_row                       "trazer a linha selecionada
                          ev_total   TYPE zbg16_vendas_t-valor
                EXPORTING iv_total   TYPE zbg16_vendas_t-valor,
      get_data_filtrada IMPORTING iv_filtro_id_empresa TYPE zbg16_vendas_t-idempresa
                                  iv_filtro_id_produto TYPE zbg16_vendas_t-idproduto,
      get_data_produtos_empresa IMPORTING iv_id_empresa TYPE zbg16_produto_t-id_empresa,
      rever_carrinho,
      finalizar.

  PROTECTED SECTION.

  PRIVATE SECTION.
    TYPES: ty_vendas_t TYPE STANDARD TABLE OF zbg16_vendas_t.

    METHODS: get_data EXPORTING lt_data TYPE ty_vendas_t,
      get_fieldcat EXPORTING et_fieldcat TYPE lvc_t_fcat.
     CLASS-METHODS: conversao IMPORTING iv_moeda_para_converter TYPE zbg16_empresas_t-moeda
                                       iv_valor                TYPE zbg16_produto_t-preco_venda
                                       iv_moeda_desejada       TYPE zbg16_empresas_t-moeda
                             EXPORTING ev_valor_convertido     TYPE zbg16_produto_t-preco_venda.

ENDCLASS.

CLASS lcl_pp IMPLEMENTATION.

  METHOD init.
    DATA lt_fieldcat TYPE lvc_t_fcat.
    get_fieldcat( IMPORTING et_fieldcat = lt_fieldcat ).     "cabeçalho
    IF lt_fieldcat IS NOT INITIAL.
      gt_fieldcat = lt_fieldcat[].
      get_data( IMPORTING lt_data = gt_data ).
      CALL SCREEN 100.                                     "Começo do programa chamo o ecrã 100
    ENDIF.
  ENDMETHOD.

  METHOD get_fieldcat.
    DATA lt_fieldcat TYPE lvc_t_fcat.
    DATA lt_fieldcat_dados_empresas TYPE lvc_t_fcat.
    DATA lt_fieldcat_produtos TYPE lvc_t_fcat.

    "fieldcat para zbg16_vendas_t
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = 'ZBG16_VENDAS_T'
      CHANGING
        ct_fieldcat            = lt_fieldcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
      MESSAGE 'ERRO NO FIELDCAT' TYPE 'S' DISPLAY LIKE 'E'.
    ELSE.
      IF lt_fieldcat IS NOT INITIAL.
        et_fieldcat = lt_fieldcat[].
      ENDIF.
    ENDIF.

    "fieldcat para zbg16_empresas_t
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = 'ZBG16_EMPRESAS_T'
      CHANGING
        ct_fieldcat            = lt_fieldcat_dados_empresas
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
      MESSAGE 'ERRO NO FIELDCAT' TYPE 'S' DISPLAY LIKE 'E'.
    ELSE.
      IF lt_fieldcat IS NOT INITIAL.
        gt_fieldcat_dados_empresas = lt_fieldcat_dados_empresas[].
      ENDIF.
    ENDIF.

    "fieldcat para zbg16_produtos_t
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = 'ZBG16_PRODUTO_T'
      CHANGING
        ct_fieldcat            = lt_fieldcat_produtos
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
      MESSAGE 'ERRO NO FIELDCAT' TYPE 'S' DISPLAY LIKE 'E'.
    ELSE.
      IF lt_fieldcat IS NOT INITIAL.
        gt_fieldcat_produtos = lt_fieldcat_produtos[].
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD get_data.
    DATA lt_data_dados_empresas TYPE STANDARD TABLE OF zbg16_empresas_t.
    SELECT * FROM zbg16_vendas_t INTO TABLE @lt_data. "Traz a data da tabela vendas para apresentar no historico de venda = gt_data

    SELECT * FROM zbg16_empresas_t INTO TABLE @lt_data_dados_empresas.
    gt_data_dados_empresas = lt_data_dados_empresas[].
  ENDMETHOD.

  METHOD adicionar.     "cada vez clico no botao adicionar vai adicionar o produto correspondente

    DATA(lv_id_produto) = iv_id_produto.
    DATA(lv_quantidade) = iv_quantidade.
    DATA(lv_id_empresa) = iv_id_empresa.
    DATA(lt_data_carrinho_if) = gt_data_carrinho[].
    DATA: lv_valor_singular             TYPE p DECIMALS 2,
          lv_registo_percorrer_carrinho TYPE int1,
          lv_preco_venda                TYPE p DECIMALS 2,
          lv_count_emp                  TYPE int1,
          lv_valor_convertido           TYPE zbg16_produto_t-preco_venda,
          lv_count_prod                 TYPE int1,
          lv_nova_quantidade            TYPE zbg16_vendas_t-quantidade,
          lt_venda                      TYPE STANDARD TABLE OF zbg16_vendas_t,
          lt_carrinho                   TYPE STANDARD TABLE OF zbg16_vendas_t,
          ls_carrinho                   TYPE zbg16_vendas_t.

    SELECT SINGLE * FROM zbg16_empresas_t WHERE id_empresa = @lv_id_empresa INTO @DATA(ls_emp).
    IF ls_emp IS INITIAL.
      MESSAGE 'Não existe a empresa pretendida' TYPE 'I' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM zbg16_produto_t WHERE id_produto = @lv_id_produto INTO @DATA(ls_prod).
    IF ls_prod IS INITIAL.
      MESSAGE 'Não existe o produto pretendido' TYPE 'I' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    IF lt_data_carrinho_if IS INITIAL. "Se a tabela estiver vazia

      SELECT SINGLE *
           FROM zbg16_produto_t
           WHERE id_produto = @lv_id_produto
           AND id_empresa = @lv_id_empresa
           INTO @DATA(ls_produto_i).   "Seleciono o que o utilizador escolho e trago a estrutura dele

      IF ls_produto_i IS NOT INITIAL.     "Se ele encontrar a estrutura desejada
        "----
        IF ls_produto_i-moeda = 'EUR'.
          lv_preco_venda = ls_produto_i-preco_venda.
        ELSE.
          conversao( EXPORTING iv_moeda_para_converter = ls_produto_i-moeda
                               iv_valor = ls_produto_i-preco_venda
                               iv_moeda_desejada = 'EUR'
                     IMPORTING ev_valor_convertido = lv_valor_convertido ).
          lv_preco_venda = lv_valor_convertido.
        ENDIF.
        "----
        "lv_preco_venda = ls_produto_i-preco_venda.
        lv_valor_singular = lv_quantidade * lv_preco_venda. "Valor daquela conta singular será a quantidade * o preço da venda do produto


        ls_carrinho = VALUE #( venda_id = gv_venda_id_carrinho          "Aqui trago os elementos não só para transportar os que me interessa tanto como para apresentar no carrinho
                               idempresa = ls_produto_i-id_empresa
                               idproduto = ls_produto_i-id_produto
                               quantidade = lv_quantidade
                               valor = lv_valor_singular
                               moeda = 'EUR'  "porque converto tudo para euro logo a venda é a conversão para euro logo o valor é apresentar em EURO
                               data_venda = sy-datlo
                               ).
        SELECT SINGLE *
        FROM zbg16_produto_t
        WHERE id_produto = @ls_carrinho-idproduto
        AND id_empresa = @ls_carrinho-idempresa
        INTO @DATA(ls_stock_i).

        IF lv_quantidade <= ls_stock_i-stock_atual.
          gv_total = gv_total + lv_valor_singular.                    "Valor total apresentado a acumulação
          ev_total = gv_total.                                        "Exportar o valor para a tela

          gv_venda_id_carrinho = gv_venda_id_carrinho + 1.    "Para ter ids de venda para aquele cliente aumentar miguelindependete de qualquer coisa, para conseguir fazer track de algum produto que ele tenha produto e queira rever
          gv_registo_carrinho = gv_registo_carrinho + 1.     "Keep track do numero do registo no carrinho para depois comparar futuramente, por cada produto adicionado ele vai ter um numero incrementado diferente

          gv_contador_carrinho = gv_contador_carrinho + 1. "Por cada pedido do botao adicionar ele vai adicionar 1 à variavel que faz track a quantos produtos o cliente ja pediu naquela exata venda


          APPEND ls_carrinho TO gt_data_carrinho.             "Adiciono o registo do produto singular à tabela do carrinho
          go_alv_carrinho->refresh_table_display( ).          "Atualizo a tabela em tempo real para o cliente ver o que está no carrinho, ou o vendedor
        ELSE.
          MESSAGE 'A empresa não tem quantidade suficiente do produto desejado' TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
      ELSE.
        MESSAGE 'O produto desejado não existe na empresa escolhida' TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.


    ELSE. "Se a tabela ja tiver pelo menos 1 registo
      LOOP AT lt_data_carrinho_if INTO DATA(ls_row_carrinho). "percorre o carrinho
        "Se o produto não for o 6 nem diferente dos que já la tem
        IF gv_contador_carrinho < 5 OR ( ls_row_carrinho-idproduto = lv_id_produto AND ls_row_carrinho-idempresa = lv_id_empresa ).

          SELECT SINGLE *
           FROM zbg16_produto_t
           WHERE id_produto = @lv_id_produto
           AND id_empresa = @lv_id_empresa
           INTO @DATA(ls_produto).   "Seleciono o que o utilizador escolho e trago a estrutura dele, do produto singular e através da estrutura do tipo da tabela produto consigo trabalhar da maneira que quero

          IF ls_produto IS NOT INITIAL.     "Se ele encontrar a estrutura desejada
            "---
            IF ls_produto-moeda = 'EUR'.
              lv_preco_venda = ls_produto-preco_venda.
            ELSE.
              conversao( EXPORTING iv_moeda_para_converter = ls_produto-moeda
                                   iv_valor = ls_produto-preco_venda
                                   iv_moeda_desejada = 'EUR'
                         IMPORTING ev_valor_convertido = lv_valor_convertido ).
              lv_preco_venda = lv_valor_convertido.
            ENDIF.
            "----
            "lv_preco_venda = ls_produto-preco_venda.            "Meter o preço do produto numa variável
            lv_valor_singular = lv_quantidade * lv_preco_venda. "Valor daquela conta singular será a quantidade * o preço da venda do produto


            ls_carrinho = VALUE #( venda_id = gv_venda_id_carrinho          "Aqui trago os elementos não só para transportar os que me interessa tanto como para apresentar no carrinho
                                   idempresa = ls_produto-id_empresa
                                   idproduto = ls_produto-id_produto
                                   quantidade = lv_quantidade
                                   valor = lv_valor_singular
                                   moeda = 'EUR'
                                   data_venda = sy-datlo
                                   ).
            SELECT SINGLE *
            FROM zbg16_produto_t
            WHERE id_produto = @ls_carrinho-idproduto
            AND id_empresa = @ls_carrinho-idempresa
            INTO @DATA(ls_stock).

            IF lv_quantidade <= ls_stock-stock_atual.                     "Se a quantidade for igual ou menor que o que há
              gv_total = gv_total + lv_valor_singular.                    "Valor total apresentado a acumulação
              ev_total = gv_total.                                        "Exportar o valor para a tela

              gv_venda_id_carrinho = gv_venda_id_carrinho + 1.    "Para ter ids de venda para aquele cliente aumentar miguelindependete de qualquer coisa, para conseguir fazer track de algum produto que ele tenha produto e queira rever
              gv_registo_carrinho = gv_registo_carrinho + 1.     "Keep track do numero do registo no carrinho para depois comparar futuramente, por cada produto adicionado ele vai ter um numero incrementado diferente
              gv_contador_carrinho = gv_contador_carrinho + 1. "Por cada pedido do botao adicionar ele vai adicionar 1 à variavel que faz track a quantos produtos o cliente ja pediu naquela exata venda

              "-------
*              IF gt_data_carrinho IS INITIAL.
*                APPEND ls_carrinho TO gt_data_carrinho.             "Adiciono o registo do produto singular à tabela do carrinho
*                go_alv_carrinho->refresh_table_display( ).          "Atualizo a tabela em tempo real para o cliente ver o que está no carrinho, ou o vendedor
*              ELSE.
                LOOP AT gt_data_carrinho INTO DATA(ls_percorrer_carrinho). "Aqui faço um loop a todos os produtos existentes no carrinho(vai incrementando à medida que clico no adicionar) e meto-os numa estrutura chamada de percorrer o carrinho
                  lv_registo_percorrer_carrinho = lv_registo_percorrer_carrinho + 1. "Aqui faço track da variavel que está a percorrer o carrinho para não cometer o erro de estar o mesmo miguelproduto e dizer que está repetido, que é explciado no ultimo
                  IF ls_carrinho-idempresa = ls_percorrer_carrinho-idempresa AND ls_carrinho-idproduto = ls_percorrer_carrinho-idproduto AND gv_registo_carrinho <> lv_registo_percorrer_carrinho.
                    gv_contador_carrinho = gv_contador_carrinho - 1.  "Se ele encontrar que já existe um produto no carrinho com o msm id e empresa, ele vai ao contamigueldor e decrementa.
                    ls_percorrer_carrinho-quantidade = ls_percorrer_carrinho-quantidade + ls_carrinho-quantidade.
                    lv_nova_quantidade = ls_percorrer_carrinho-quantidade.
                    "---
                    "testar isto
                    IF lv_nova_quantidade > ls_stock-stock_atual. "Se a nova quantidade do produto > stock existente
                      MESSAGE 'O stock atual da empresa não chega, por favor diminuia a quantidade.' TYPE 'I' DISPLAY LIKE 'E'.
                      "--
                      gv_total = gv_total - lv_valor_singular. "esquece o novo total
                      ev_total = gv_total.
                      gv_venda_id_carrinho = gv_venda_id_carrinho - 1. "não aumentes o id se der erro
                      lv_registo_percorrer_carrinho = lv_Registo_percorrer_carrinho - 1. "tira o que aumentaste
                      gv_registo_carrinho = gv_registo_carrinho - 1.   "tira o que aumentaste
                      EXIT.
                    ENDIF.
                    "---
                    "deletar onde tem o produto igual
                    DELETE gt_data_carrinho WHERE idempresa = ls_carrinho-idempresa AND idproduto = ls_carrinho-idproduto.
                    ls_carrinho-quantidade = lv_nova_quantidade.
                    ls_carrinho-venda_id = ls_percorrer_carrinho-venda_id.
                    ls_carrinho-valor = lv_nova_quantidade * lv_preco_venda.
                    gv_venda_id_carrinho = gv_venda_id_carrinho - 1.
                    APPEND ls_carrinho TO gt_data_carrinho.   "update com os valores corrigidos
                    gv_registo_carrinho = gv_registo_carrinho - 1.
                    EXIT. "Caso encontre quero que depois ele saia do loop porque ja viu que era repetido entao chamo o exit pra sair, n preciso do loop ir ao fim porque estou produto um a um e se viu que era repetido não há mais nada a ver
                  "Se ele percorrer o carrinho todo e não encontrar nenhum produto igual, faz um append de um novo produto
                  ELSEIF ( ls_carrinho-idempresa <> ls_percorrer_carrinho-idempresa OR ls_carrinho-idproduto <> ls_percorrer_carrinho-idproduto ) AND gv_registo_carrinho - 1 = lv_registo_percorrer_carrinho.
                    APPEND ls_carrinho TO gt_data_carrinho.
                    EXIT.
                  ENDIF.
                ENDLOOP.
                SORT gt_data_carrinho BY venda_id.
                go_alv_carrinho->refresh_table_display( ).
*              ENDIF.

            ELSE.
              MESSAGE 'A empresa não tem quantidade suficiente do produto desejado' TYPE 'I' DISPLAY LIKE 'E'.
            ENDIF.
          ELSE.
            MESSAGE 'O produto desejado não existe na empresa escolhida' TYPE 'I' DISPLAY LIKE 'E'.
          ENDIF.
          EXIT.
        ELSEIF gv_contador_carrinho = 5 AND ( ls_row_carrinho-idproduto <> lv_id_produto OR ls_row_carrinho-idempresa <> lv_id_empresa ) AND gv_contador_message <> 4.
          gv_contador_message = gv_contador_message + 1.
          CONTINUE.
        ELSEIF gv_contador_message = 4.
          MESSAGE 'Adição cancelada, só pode comprar no máximo 5 produtos' TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
      ENDLOOP.
    ENDIF.

    gv_contador_message = 0.

  ENDMETHOD.

  METHOD finalizar.
    DATA: ls_venda                      TYPE zbg16_vendas_t,
          lt_vendas                     TYPE STANDARD TABLE OF zbg16_vendas_t,
          lv_preco_venda                TYPE zbg16_produto_t-preco_venda,
          lv_answer                     TYPE char1,
          lv_diferenca_stock            TYPE zbg16_produto_t-stock_atual,
          lv_valor_rebastecimento       TYPE zbg16_produto_t-preco_compra,
          lv_stock_preco_compra         TYPE zbg16_produto_t-preco_compra,
          lv_valor_convertido           TYPE zbg16_empresas_t-capital,
          lv_valor_convertido_r         TYPE zbg16_empresas_t-capital,
          lv_novo_id_venda              TYPE int1,
          lv_registo_carrinho           TYPE int1,
          lv_acumulador_quantidade      TYPE int1,
          lv_venda_quantidade           TYPE zbg16_vendas_t-quantidade,
          lv_rever_stock_atual          TYPE zbg16_produto_t-stock_atual,
          lv_registo_percorrer_carrinho TYPE int1.

    DATA(lt_carrinho) = gt_data_carrinho[].  "Carrinho que vem com os produtos todos adicionados para uma tabela interna

    SELECT * FROM zbg16_vendas_t INTO TABLE @lt_vendas.  "Meto na tabela interna lt_vendas todos os dados já existentes na tabela das vendas

    IF lt_vendas IS NOT INITIAL.
      LOOP AT lt_vendas INTO DATA(ls_venda_id_contador).      "Se tiver dados ir buscar o ultimo registo de id de venda e adicionar + 1
        lv_novo_id_venda = ls_venda_id_contador-venda_id + 1.
      ENDLOOP.
    ELSE.
      lv_novo_id_venda = 1.                                   "Se não o primeiro registo é 1.
    ENDIF.

    LOOP AT lt_carrinho INTO DATA(ls_rever_stocks).
      SELECT SINGLE *
        FROM zbg16_produto_t
        WHERE id_produto = @ls_rever_stocks-idproduto
        AND id_empresa = @ls_rever_stocks-idempresa
        INTO @DATA(ls_stock_revisao).
      lv_rever_stock_atual = ls_stock_revisao-stock_atual.

      IF ls_rever_stocks-quantidade > lv_rever_stock_atual.
        gv_erro_revisao = 1.
        DATA(lv_id_prod_char) = '' && ls_rever_stocks-idproduto.
        DATA(lv_id_emp_char) = '' && ls_rever_stocks-idempresa.
        DATA(lv_stock_char) = '' && lv_rever_stock_atual.
        CONCATENATE 'O produto com o id' lv_id_prod_char 'e a empresa com o ID' lv_id_emp_char 'está acima do atual stock. Por favor baixe a quantidade para no máximo de' lv_stock_char
                    INTO DATA(lv_mensagem_stocks) SEPARATED BY space.
        MESSAGE lv_mensagem_stocks TYPE 'I' DISPLAY LIKE 'E'.
        RETURN.
      ELSE.
        gv_erro_revisao = 0.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_carrinho INTO DATA(ls_carrinho).               "Faço um loop na tabela do carrinho com as compras todas para ir buscar uma a uma atraves da estrutura

      ls_venda = VALUE #( venda_id = lv_novo_id_venda
                          idempresa = ls_carrinho-idempresa
                          idproduto = ls_carrinho-idproduto
                          quantidade = ls_carrinho-quantidade
                          valor = ls_carrinho-valor
                          moeda = ls_carrinho-moeda
                          data_venda = sy-datlo
                          ).

      SELECT SINGLE *
      FROM zbg16_empresas_t
      WHERE id_empresa = @ls_carrinho-idempresa
      INTO @DATA(ls_empresa).

      SELECT SINGLE *
      FROM zbg16_produto_t
      WHERE id_produto = @ls_carrinho-idproduto
      AND id_empresa = @ls_carrinho-idempresa
      INTO @DATA(ls_stock).

      MODIFY zbg16_vendas_t FROM ls_venda.                  "por cada iteração do loop pego no que está em cima modifico na tabela original
      COMMIT WORK AND WAIT.

      IF sy-subrc = 0.
        APPEND ls_venda TO gt_data.
        COMMIT WORK AND WAIT.
      ENDIF.

      "ATUALIZAR CAPITAL DA EMPRESA

      "------

      IF ls_empresa IS NOT INITIAL.
        IF ls_empresa-moeda = 'EUR'.
          ls_empresa-capital = ls_empresa-capital + ls_carrinho-valor.
        ELSE.
          conversao( EXPORTING iv_moeda_para_converter = 'EUR'
                               iv_valor = ls_carrinho-valor
                               iv_moeda_desejada = ls_empresa-moeda
                     IMPORTING ev_valor_convertido = lv_valor_convertido ).
          ls_empresa-capital = ls_empresa-capital + lv_valor_convertido.
        ENDIF.
      ELSE.
        MESSAGE 'Erro a determinar a empresa para deduzir o capital' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
      "-----

*      IF ls_empresa IS NOT INITIAL.
*        ls_empresa-capital = ls_empresa-capital + ls_carrinho-valor.
*      ELSE.
*        MESSAGE 'Erro a determinar a empresa para deduzir o capital' TYPE 'S' DISPLAY LIKE 'E'.
*      ENDIF.

      MODIFY zbg16_empresas_t FROM ls_empresa.
      COMMIT WORK AND WAIT.

      "---
      SELECT * FROM zbg16_empresas_t into TABLE @DATA(lt_emp_atualizado).
        gt_data_dados_empresas = lt_emp_atualizado[].
      "---
      "--------------------------

      "ATUALIZAR STOCKS DA EMPRESA

      ls_stock-stock_atual = ls_stock-stock_atual - ls_carrinho-quantidade.

      MODIFY zbg16_produto_t FROM ls_stock.
      COMMIT WORK AND WAIT.

      CONCATENATE 'Quer reabastecer o stock' ls_stock-nome INTO DATA(lv_text_question) SEPARATED BY space.

      IF ls_stock-stock_atual < ls_stock-stock_min.  " se o stock atual for abaixo do minimo
        CALL FUNCTION 'POPUP_TO_CONFIRM'   "popup a avisar que o stock está em baixo, e se dicidir aceitar reabastecer establece a lógica associada
          EXPORTING
            titlebar              = 'STOCKS ABAIXO DO MINIMO'
            text_question         = lv_text_question
            text_button_1         = 'Sim'
            icon_button_1         = ' '
            text_button_2         = 'Não'
            icon_button_2         = ' '
            default_button        = '1'
            display_cancel_button = 'X'
          IMPORTING
            answer                = lv_answer
          EXCEPTIONS
            text_not_found        = 1
            OTHERS                = 2.
        IF sy-subrc <> 0.  "Se der erro
          MESSAGE 'ERRO NO POPUP' TYPE 'S' DISPLAY LIKE 'E'.
        ELSE.   " Se não der erro
          IF lv_answer = '1'.    "se a resposta do usuario for de reabastecer
            lv_diferenca_stock = ls_stock-stock_max - ls_stock-stock_atual.   "calcular a diferença de stock existente do atual pro max
            "----
            IF ls_stock-moeda <> ls_empresa-moeda.
              conversao( EXPORTING iv_moeda_para_converter = ls_stock-moeda
                                   iv_valor = ls_stock-preco_compra
                                   iv_moeda_desejada = ls_empresa-moeda
                           IMPORTING ev_valor_convertido = lv_valor_convertido_r ).
              lv_stock_preco_compra = lv_valor_convertido_r.

            ELSE.
              lv_stock_preco_compra = ls_stock-preco_compra.
            ENDIF.
            "----
            lv_valor_rebastecimento = lv_diferenca_stock * lv_stock_preco_compra.
            "lv_valor_rebastecimento = lv_diferenca_stock * ls_stock-preco_compra. "valor que vai custar à empresa para reebastecer
            "Se a empresa tiver dinheiro para rebastecer
            IF ls_empresa-capital >= lv_valor_rebastecimento.   "se o capital da empresa for maior que o valor do rebastecimento
              ls_stock-stock_atual = ls_stock-stock_max.        "passa o stock atual para os valores maximos daquele produto
              ls_empresa-capital = ls_empresa-capital - lv_valor_rebastecimento.  "retira à empresa o capital da compra de stock proveniente do rebastecimento
            ELSE.
              MESSAGE 'A empresa não tem dinheiro para reebastecer' TYPE 'E' DISPLAY LIKE 'E'.
            ENDIF.

            "Atualizar as tabelas com as modificações feitas
            MODIFY zbg16_produto_t FROM ls_stock.
            COMMIT WORK AND WAIT.

            MODIFY zbg16_empresas_t FROM ls_empresa.
            COMMIT WORK AND WAIT.

          ELSE. "Se o usario clicar em não reebastecer
            MESSAGE 'Ação de rebastecimento cancelada' TYPE 'S' DISPLAY LIKE 'S'.
          ENDIF.
        ENDIF. "Fechar a condição do erro
      ENDIF. "Fechar a condição de checar se o stock está abaixo do minimo.


      "--------------------------------

*      "go_alv->refresh_table_display( ).
    ENDLOOP.
    IF sy-subrc = 0.
      MESSAGE 'Vendas registadas com sucesso.' TYPE 'S' DISPLAY LIKE 'S'.
      FREE: gt_data_carrinho[],
          gv_contador_carrinho,
          gv_registo_carrinho.
      CLEAR: gt_data_carrinho.
      gv_venda_id_Carrinho = 1.


    ELSE.
      MESSAGE 'Erro a registar as vendas na tabela de dados' TYPE 'I' DISPLAY LIKE 'E'.
    ENDIF.
*    FREE: gt_data_carrinho[],
*          gv_contador_carrinho,
*          gv_registo_carrinho,
*          gv_venda_id_carrinho.
*    CLEAR: gt_data_carrinho.

  ENDMETHOD.

  METHOD remover.

    DATA(lt_sel_row) = it_sel_row.
    DATA(lv_linhas_selecionadas) = lines( lt_sel_row ).
    DATA: lv_venda_id_del      TYPE zbg16_vendas_t-venda_id,
          lv_contador_linhas   TYPE int1,
          lv_venda_id_superior TYPE zbg16_vendas_t-venda_id.

    IF lines( gt_data_carrinho ) > 0.
      IF lv_linhas_selecionadas <> 0.
        IF lv_linhas_selecionadas = 1.
          DATA(lv_index_produto) = lt_sel_row[ 1 ]-index. "index do produto selecionado
          DATA(ls_produto_del) = gt_data_carrinho[ lv_index_produto ]. "estrutura do produto
          DELETE gt_data_carrinho WHERE idempresa = ls_produto_del-idempresa AND idproduto = ls_produto_del-idproduto.
          IF sy-subrc = 0.
            MESSAGE 'Produto removido com sucesso' TYPE 'S' DISPLAY LIKE 'S'.
          ELSE.
            MESSAGE 'Erro a eliminar o produto' TYPE 'S' DISPLAY LIKE 'E'.
          ENDIF.
        ELSE.
          MESSAGE '´Só é possivel adicionar um produto ao carrinho' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ELSE.
        MESSAGE 'Tens de selecionar 1 produto do carrinho' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    ELSE.
      MESSAGE 'Tens de selecionar 1 produto do carrinho' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

    DATA(lv_total) = ev_total.

    lv_total = lv_total - ls_produto_del-valor.
    iv_total = lv_total.
    gv_total = lv_total.


    gv_registo_carrinho = gv_registo_carrinho - 1.
    gv_contador_carrinho = gv_contador_carrinho - 1.
    lv_venda_id_del = ls_produto_del-venda_id.
    DATA(lv_linhas_inicial) = lines( gt_data_carrinho ).
    LOOP AT gt_data_carrinho INTO DATA(ls_data_carrinho).
      lv_contador_linhas = lv_contador_linhas + 1.
      IF ls_data_carrinho-venda_id > lv_venda_id_del.
        lv_venda_id_superior = ls_data_carrinho-venda_id - 1.
        DELETE gt_data_carrinho WHERE venda_id = ls_data_carrinho-venda_id. "deleta a linha com id superior
        ls_data_carrinho-venda_id = lv_venda_id_superior.
        APPEND ls_data_carrinho TO gt_data_carrinho. "acrecsenta a linha com o id atualizado
        "tenho que guarda o ultimo ID! OU...
        IF lv_linhas_inicial = lv_contador_linhas.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    gv_venda_id_carrinho = gv_venda_id_carrinho - 1.
    go_alv_carrinho->refresh_table_display( ).
    FREE: lt_sel_row[].

  ENDMETHOD.

  METHOD get_data_filtrada.

    DATA(lv_id_empresa) = iv_filtro_id_empresa.
    DATA(lv_id_produto) = iv_filtro_id_produto.
    DATA: lt_data_filtrada_produto TYPE STANDARD TABLE OF zbg16_vendas_t,
          lt_data_filtrada_empresa TYPE STANDARD TABLE OF zbg16_vendas_t,
          lt_data_filtrada_ambos   TYPE STANDARD TABLE OF zbg16_vendas_t.

    SELECT * FROM zbg16_vendas_t WHERE idproduto = @lv_id_produto INTO TABLE @lt_data_filtrada_produto.

    SELECT * FROM zbg16_vendas_t WHERE idempresa = @lv_id_empresa INTO TABLE @lt_data_filtrada_empresa.

    SELECT * FROM zbg16_vendas_t WHERE idproduto = @lv_id_produto AND idempresa = @lv_id_empresa INTO TABLE @lt_data_filtrada_ambos.

    gt_data_filtrada_produto = lt_data_filtrada_produto.
    gt_data_filtrada_empresa = lt_data_filtrada_empresa.
    gt_data_filtrada_ambos = lt_data_filtrada_ambos.

  ENDMETHOD.

  METHOD get_data_produtos_empresa.
    DATA(lv_id_empresa) = iv_id_empresa.
    DATA: lt_data_produtos_empresa TYPE STANDARD TABLE OF ZBG16_PRODUTO_T.
          "lt_empresasv2 TYPE STANDARD TABLE OF ZBG16_EMPRESAS_T,
          "ls_data_about_empresa TYPE STANDARD TABLE OF ZBG16_EMPRESAS_T.

    SELECT * FROM zbg16_PRODUTO_t WHERE ID_EMPRESA = @lv_id_empresa INTO TABLE @lt_data_produtos_empresa.

    gt_data_produtos_empresa = lt_data_produtos_empresa[].

    SELECT SINGLE *
       FROM ZBG16_EMPRESAS_T
       WHERE ID_EMPRESA = @lv_id_empresa
       INTO @DATA(ls_data_about_empresa).

*    SELECT * FROM ZBG16_EMPRESAS_T INTO TABLE @lt_empresasV2.
*    SELECT SINGLE * FROM lt_empresasv2 WHERE ID_EMPRESA = @lv_id_empresa INTO @ls_data_about_empresa.
*
    gs_data_about_empresa = ls_data_about_empresa.

  ENDMETHOD.

  METHOD rever_carrinho.

    DATA(lt_carrinho) = gt_data_carrinho[].
    gv_total = 0.
    LOOP AT lt_carrinho INTO DATA(ls_carrinho).
      gv_total = gv_total + ls_carrinho-valor.    "ATUALIZAR O VALOR INTERNAMENTE
    ENDLOOP.
  ENDMETHOD.

  METHOD conversao.
    DATA: lv_valor_convertido TYPE zbg16_produto_t-preco_venda.

    CALL FUNCTION 'CONVERT_AMOUNT_TO_CURRENCY'
      EXPORTING
        date             = sy-datum
        "date             = sy-datlo
        foreign_currency = iv_moeda_para_converter
        foreign_amount   = iv_valor
        local_currency   = iv_moeda_desejada
      IMPORTING
        local_amount     = lv_valor_convertido
      EXCEPTIONS
        error            = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
      MESSAGE 'Erro na conversão' TYPE 'E' DISPLAY LIKE 'E'.
    ELSE.
      ev_valor_convertido = lv_valor_convertido.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
