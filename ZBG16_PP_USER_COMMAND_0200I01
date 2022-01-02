*----------------------------------------------------------------------*
***INCLUDE ZBG16_PP_USER_COMMAND_0200I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  DATA: in_filtrar_id_empresa TYPE ZBG16_VENDAS_T-IDEMPRESA,
        in_filtrar_id_produto TYPE ZBG16_VENDAS_T-IDPRODUTO.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'LEAVE'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'FCT_FILTRAR'.
      IF in_filtrar_id_empresa is INITIAL AND in_filtrar_id_produto IS INITIAL.
        FREE: gt_data_filtrada[].
        CLEAR: gt_data_filtrada[].
        MESSAGE 'Tem de preencher pelo menos um dos campos' TYPE 'I' DISPLAY LIKE 'E'.
      ELSEIF in_filtrar_id_empresa is NOT INITIAL AND in_filtrar_id_produto IS INITIAL.
        lcl_pp=>get_data_filtrada( EXPORTING  iv_filtro_id_empresa = in_filtrar_id_empresa
                                              iv_filtro_id_produto = in_filtrar_id_produto ).
        gt_data_filtrada = gt_data_filtrada_empresa.
      ELSEIF in_filtrar_id_empresa is INITIAL AND in_filtrar_id_produto IS NOT INITIAL.
        lcl_pp=>get_data_filtrada( EXPORTING  iv_filtro_id_empresa = in_filtrar_id_empresa
                                              iv_filtro_id_produto = in_filtrar_id_produto ).
        gt_data_filtrada = gt_data_filtrada_produto.
      ELSEIF in_filtrar_id_empresa is NOT INITIAL AND in_filtrar_id_produto IS NOT INITIAL.
        lcl_pp=>get_data_filtrada( EXPORTING  iv_filtro_id_empresa = in_filtrar_id_empresa
                                              iv_filtro_id_produto = in_filtrar_id_produto ).
        gt_data_filtrada = gt_data_filtrada_ambos.
      ENDIF.
      go_alv_vendas_filtradas->refresh_table_display( ).

   ENDCASE.

ENDMODULE.
