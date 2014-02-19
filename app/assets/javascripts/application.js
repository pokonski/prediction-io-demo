// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require jquery.raty.js
//= require_self

$(function(){
  $(document).foundation();
});

var rating = $('#rating');
rating.raty({
  half: false,
  size: 48,
  width: false,
  starOn: rating.data('starOn'),
  starHalf: rating.data('starHalf'),
  starOff: rating.data('starOff'),
  click: function(score, evt) {
    $.ajax(rating.data('url'), {
      dataType: "json",
      data: {
        value: score
      }
    }).done(function(data) {
      window.location.reload(true);
    });
  }
});
