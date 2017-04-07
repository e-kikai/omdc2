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
#= require bootstrap-fileinput
#= require moment
#= require moment/locale/ja
#= require bootstrap3-datetimepicker
#= require dropzone
#= require_tree .
$(document).on 'ready, turbolinks:load', ->
  # # フォーム共通 : フォーム自動全選択
  # $('input.allselect').click ->
  #   @.select()

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
