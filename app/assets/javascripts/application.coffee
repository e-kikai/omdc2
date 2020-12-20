# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file. JavaScript code in this file should be added after the last require_* statement.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require jquery-ui/widgets/sortable
#= require turbolinks
#= require bootstrap
# require jquery_nested_form
# require bootstrap-fileinput
#= require fixed_midashi
#= require jquery.ui.touch-punch.min
#= require modernizr.custom
#= require jquery.dlmenu
#= require bootstrap-fileinput
#= require moment
#= require moment/locale/ja
#= require bootstrap3-datetimepicker
#= require dropzone
#= require google-analytics-turbolinks
#= require js.cookie
#= require_tree .
$(document).on 'ready, turbolinks:load', ->
  # # フォーム共通 : フォーム自動全選択
  # $('input.allselect').click ->
  #   @.select()

  # tooltip
  # $('.tooltip').remove()
  # $('[data-toggle="tooltip"]').tooltip()

  # フォーム共通 : datetimepicker
  $('input.datepicker').datetimepicker({locale: 'ja', format: 'YYYY/MM/DD'})
  $('input.datetimepicker').datetimepicker({locale: 'ja', format: 'YYYY/MM/DD HH:mm:ss'})

  # テーブルスクロール制御
  FixedMidashi.create()

  $_topBtn = $('#page-top')
  $_topBtn.hide()

  # スクロールが100に達したらボタン表示
  $(window).scroll ->
    if $(this).scrollTop() > 100
      $_topBtn.fadeIn()
    else
      $_topBtn.fadeOut()

  # スクロールしてトップ
  $_topBtn.click ->
    $('body,html').animate({ scrollTop: 0 }, 500)
    return false

  # カンマ区切り処理 : フォーカスを得たとき
  $("input.price").focus ->
    $(@).val(priceUnformat($(@).val()))

  # カンマ区切り処理 : フォーカスを失ったとき
  $("input.price").blur ->
    $(@).val(priceFormat($(@).val()))

  # カンマ区切り処理 : 初期化
  $("input.price").each ->
    $(this).triggerHandler "blur"

  # カンマ区切り処理 : フォームのアップロード
  $("form").submit ->
    $(@).find("input.price").each ->
      $(this).triggerHandler "focus"

  # ハンバーガー
  $('#dl-menu').dlmenu()


  ### ロギング ###
  if !$("#nologging").val()

    ### 詳細ページログ取得 ###
    if $("input#logging").val() == "detail"
      $.ajax
        async:    true
        url:      "/detail_logs/"
        type:     'POST',
        dataType: 'json',
        data :    { product_id : $('#product_id').val(), r : $('#r').val(), referer : $('#referer').val()  },
        timeout:  3000,
        # success:  (data, status, xhr)   -> alert status
        # error:    (xhr,  status, error) -> alert status

    ## 検索ログ ###
    if $("input#logging").val() == "search"
      $.ajax
        async:    true
        url:      "/search_logs/"
        type:     'POST',
        dataType: 'json',
        data :    { keywords : $('#keywords').val(), path : $('#path').val(), page : $('#page').val(), r : $('#r').val(), referer : $('#referer').val() },
        timeout:  3000,
        # success:  (data, status, xhr)   -> alert status
        # error:    (xhr,  status, error) -> alert status

    ### トップページログ ###
    if $("input#logging").val() == "toppage"
      $.ajax
        async:    true
        url:      "/toppage_logs/"
        type:     'POST',
        dataType: 'json',
        data :    { r : $('#r').val(), referer : $('#referer').val() },
        timeout:  3000,



priceUnformat = (str) ->
  num = new String(str).replace(/０/g, "0").replace(/１/g, "1").replace(/２/g, "2").replace(/３/g, "3").replace(/４/g, "4").replace(/５/g, "5").replace(/６/g, "6").replace(/７/g, "7").replace(/８/g, "8").replace(/９/g, "9").replace(/[^0-9]/g, "")
  num = "" if num == '0'
  return num

priceFormat = (str) ->
  num = "" + priceUnformat(str)
  while num != (num = num.replace(/^(-?\d+)(\d{3})/, "$1,$2"))
    num
  return num
