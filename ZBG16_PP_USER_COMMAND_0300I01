*----------------------------------------------------------------------*
***INCLUDE ZBG16_PP_USER_COMMAND_0300I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  DATA: in_produtos_empresa TYPE zbg16_produto_t-id_empresa,
        out_id_empresa      TYPE zbg16_empresas_t-id_empresa,
        out_nome_empresa    TYPE zbg16_empresas_t-nome,
        out_capital_empresa TYPE zbg16_empresas_t-capital,
        out_moeda_empresa   TYPE zbg16_empresas_t-moeda.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'LEAVE'.
      CLEAR: gt_data_produtos_empresa,
             out_id_empresa,
             out_nome_empresa,
             out_capital_empresa,
             out_moeda_empresa,
             in_produtos_empresa.
      "--
      FREE:  gs_data_about_empresa.
      "---
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'FCT_PRODUTOS_EMPRESA'.
      IF in_produtos_empresa IS NOT INITIAL.
        lcl_pp=>get_data_produtos_empresa( EXPORTING  iv_id_empresa = in_produtos_empresa ).
        out_id_empresa = gs_data_about_empresa-id_empresa.
        out_nome_empresa = gs_data_about_empresa-nome.
        out_capital_empresa = gs_data_about_empresa-capital.
        out_moeda_empresa = gs_data_about_empresa-moeda.
        IF gt_data_produtos_empresa IS NOT INITIAL.        "tabela que vem com os produtos da empresa
          go_alv_produtos_empresa->refresh_table_display( ).
        ELSE.
          MESSAGE 'Não existem produtos nessa empresa' TYPE 'I' DISPLAY LIKE 'E'.
          CLEAR: gt_data_produtos_empresa.
        ENDIF.
      ELSE.
        MESSAGE 'Tens de colocar o ID da empresa para obter o desejado' TYPE 'I' DISPLAY LIKE 'E'.
        CLEAR: gt_data_produtos_empresa,
               out_id_empresa,
               out_nome_empresa,
               out_capital_empresa,
               out_moeda_empresa.
      ENDIF.
  ENDCASE.
ENDMODULE.
