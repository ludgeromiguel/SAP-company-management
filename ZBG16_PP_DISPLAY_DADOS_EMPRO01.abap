*----------------------------------------------------------------------*
***INCLUDE ZBG16_PP_DISPLAY_DADOS_EMPRO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_DADOS_EMPRESA_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_dados_empresa_alv OUTPUT.

  DATA: ls_layout_dados_empresas TYPE lvc_s_layo.

  IF go_container_dados_empresas IS NOT BOUND.

    CREATE OBJECT go_container_dados_empresas
      EXPORTING
        container_name              = 'CONTAINER_DADOS_EMPRESAS'
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

    ls_layout_dados_empresas = VALUE #(  zebra = abap_true "Efeito zebra
                          cwidth_opt = abap_true "Optimizar a largura das colunas
                          sel_mode = 'A' "Permitir selecionar linha por meio de pushbutons no lado esquerdo
                          grid_title = 'Lista das empresas' "título ou frase antes da tabela em si
                    ).

    CREATE OBJECT go_alv_dados_empresas
      EXPORTING
        i_parent          = go_container_dados_empresas
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

    CALL METHOD go_alv_dados_empresas->set_table_for_first_display
      EXPORTING
        i_save                        = 'U'
        is_layout                     = ls_layout_dados_empresas
      CHANGING
        it_outtab                     = gt_data_dados_empresas
        it_fieldcatalog               = gt_fieldcat_dados_empresas
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

    go_alv_dados_empresas->refresh_table_display( ). "aqui tem um metodo que dá refresh. Tá dentro do else

  ENDIF.

ENDMODULE.
