*----------------------------------------------------------------------*
***INCLUDE ZBG16_AULAALV_USER_COMMAND_I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*


MODULE user_command_0100 INPUT.

  DATA: in_id_produto TYPE zbg16_produto_t-id_produto,
        in_quantidade TYPE int2,
        out_total     TYPE p DECIMALS 2,
        lt_sel_row    TYPE lvc_t_row,
        in_id_empresa TYPE int2.


  CASE sy-ucomm.
    WHEN 'BACK' OR 'LEAVE'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'FCT_HISTORICO_VENDAS'.
      CALL SCREEN 200.

    WHEN 'FCT_CALC'.                                                                                                                                          "miguel
      IF in_id_produto IS INITIAL.
        MESSAGE 'Tem de preencher o campo do ID do produto.' TYPE 'I' DISPLAY LIKE 'E'.
      ELSEIF in_quantidade IS INITIAL.
        MESSAGE 'A quantidade tem de ser preenchida ou não pode ser 0.' TYPE 'I' DISPLAY LIKE 'E'.
      ELSEIF in_id_empresa IS INITIAL.
        MESSAGE 'Tens de preencher o campo do ID empresa.' TYPE 'I' DISPLAY LIKE 'E'.
      ELSE.
        lcl_pp=>adicionar( EXPORTING  iv_id_produto = in_id_produto
                                      iv_quantidade = in_quantidade
                                      iv_id_empresa = in_id_empresa
                           IMPORTING ev_total = DATA(lv_total)
                                     ).
        out_total = lv_total.
      ENDIF.

    WHEN 'FCT_FINALIZAR'.
      IF gt_data_carrinho IS NOT INITIAL.
        lcl_pp=>finalizar( ).
        IF gv_erro_revisao = 0.
          FREE: gv_total.
          CLEAR: out_total.
        ELSE.
          lcl_pp=>rever_carrinho( ).
          out_total = gv_total.
        ENDIF.
      ELSE.
        MESSAGE 'CARRINHO VAZIO' TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.

    WHEN 'FCT_REMOVER'.
      CALL METHOD go_alv_carrinho->get_selected_rows
        IMPORTING
          et_index_rows = lt_sel_row.
      DATA(lv_linhas_selecionadas) = lines( lt_sel_row ).
      IF lv_linhas_selecionadas = 1.
        lcl_pp=>remover( EXPORTING it_sel_row = lt_sel_row
                                   ev_total = lv_total
                         IMPORTING iv_total = DATA(new_lv_total) ).
        out_total = new_lv_total.
        lv_total = new_lv_total.  "Para uma segunda passagem ao clicar no botão de remover
        CLEAR: lt_sel_row[].
        FREE: lt_sel_row[].
      ELSE.
        MESSAGE 'TENS DE SELECIONAR UM E APENAS UM REGISTO PARA REMOVER' TYPE 'E' DISPLAY LIKE 'E'.
      ENDIF.

    WHEN 'FCT_LIMPAR'.
      FREE: gt_data_carrinho[],
            gv_contador_carrinho,
            out_total,
            lv_total,
            gv_total,
            gv_registo_carrinho.
      CLEAR: gt_data_carrinho.

    WHEN 'FCT_DADOS_EMPRESA'.
      IF in_id_empresa IS INITIAL.
        CLEAR: gt_data_produtos_empresa.
        CALL SCREEN 300.
      ELSE.
        lcl_pp=>get_data_produtos_empresa( EXPORTING  iv_id_empresa = in_id_empresa ).
        "go_alv_produtos_empresa->refresh_table_display( ).
        CALL SCREEN 300.

      ENDIF.

  ENDCASE.
ENDMODULE.
