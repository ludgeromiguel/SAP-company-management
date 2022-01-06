*----------------------------------------------------------------------*
***INCLUDE ZBG16_PP_DISPLAY_PRODUTOS_EO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_PRODUTOS_EMPRESA_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_produtos_empresa_alv OUTPUT.

  DATA: ls_layout_produtos_empresa TYPE lvc_s_layo.

  "--
  out_id_empresa = gs_data_about_empresa-id_empresa.
  out_nome_empresa = gs_data_about_empresa-nome.
  out_capital_empresa = gs_data_about_empresa-capital.
  out_moeda_empresa = gs_data_about_empresa-moeda.
  "--
  IF go_container_produtos_empresa IS NOT BOUND.

    CREATE OBJECT go_container_produtos_empresa
      EXPORTING
        container_name              = 'CONTAINER_PRODUTOS_EMPRESA'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      LEAVE PROGRAM.
    ENDIF.

    ls_layout_produtos_empresa = VALUE #(  zebra = abap_true "Efeito zebra
                          cwidth_opt = abap_true "Optimizar a largura das colunas
                          sel_mode = 'A' "Permitir selecionar linha por meio de pushbutons no lado esquerdo
                          grid_title = 'Produtos da empresa pedida' "título ou frase antes da tabela em si
                    ).

    CREATE OBJECT go_alv_produtos_empresa
      EXPORTING
        i_parent          = go_container_produtos_empresa
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4. "Mensagem Standard
      LEAVE PROGRAM.
    ENDIF.


    CALL METHOD go_alv_produtos_empresa->set_table_for_first_display  "go_alv objeto tem um metodo que preenche a tabela
      EXPORTING
        i_save                        = 'U'
        is_layout                     = ls_layout_produtos_empresa
      CHANGING
        it_outtab                     = gt_data_produtos_empresa
        it_fieldcatalog               = gt_fieldcat_produtos
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4. "Mensagem Standard
      LEAVE PROGRAM.
    ENDIF.

  ELSE.

    go_alv_produtos_empresa->refresh_table_display( ). "aqui tem um metodo que dá refresh. Tá dentro do else

  ENDIF.

ENDMODULE.
