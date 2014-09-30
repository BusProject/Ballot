// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require i18n
//= require i18n/translations
//= require knockout-latest.debug
//= require models
//= require jquery_csv
//= require_tree ./main


var yourLocation = new locationModel(inits);

window.onload = function() {
  $('#show_mobile_menu').click(function() {
    $('.account').toggle();
  });
  if( document.location.hash.length > 1 ){
    setTimeout( function() {
    var pos = $( document.location.hash + ', a[name="'+document.location.hash.replace('#!','')+'"]' ).offset(),
      top = ( pos || {top:0} ).top-30
    document.location.hash = ''
    $(document).scrollTop( top )
    }, 20)
  } // Clearing dumb facebook thing
  $('body').removeClass('no-script') //Fixing body class
  initialize() // This loads goelocation / facebook friends
  $('.clean-no-script').remove() // Removing non-necessary elements that knockout will just rebuild
  ko.applyBindings(yourLocation); // Binds Knockout

  CANDIDATES = 'candidates';
  MEASURES = 'measures';
  var submitFlag = false;
  $('#import-candidates').submit(function(e){
    if(submitFlag){
      //submit the form as normal
      return true;
    }
    e.preventDefault();
    previewImportFile(e, CANDIDATES);
    submitFlag = true;
    return false;
  });
  $('#import-measures').submit(function(e){
    if(submitFlag){
      //submit the form as normal
      return true;
    }
    e.preventDefault();
    previewImportFile(e, MEASURES);
    submitFlag = true;
    return false;
  });
  $('.lightbox').colorbox({height: '452px', width: '800px', scrolling: false, closeButton: false, onOpen: function() { $('#instructions-box').hide() }, onClose: function() { $('#instructions-box').Show() }});
}

function previewImportFile(e, type, submitFlag){
  var self = this;
  var fHandle = e.currentTarget[2].files[0]
  var fr = new FileReader();
  fr.readAsText(fHandle);
  fr.onload = function(e){
    self.buildImportForm(e.target.result, type);
  }

  //prepare the form for submission
  $(e.currentTarget).find('input[type=submit]').val('Import');
}

function buildImportForm(importStr, type){
  var $el = $('#import-' + type + ' #importPreviewContainer');
  var previewRows = 5; //number of rows to show in preview
  var rows = $.csv.toArrays(importStr).slice(0,previewRows);
  var headers = rows[0];
  $el.html(buildImportHtml({rows: rows, headers: headers, options: buildOptions(type)}));
}

function matrixTranspose(origin) {
  var result = [];
  for (var i = 0; i < origin[0].length; i++) {
    var temp = [];
    for (var j = 0; j < origin.length; j++) {
      temp.push(origin[j][i]);
    };
    result.push(temp);
  };
  return result;
}

function buildMatrix(o) {
  var matrix = new Array();
  matrix[0] = new Array();
  for(var i = 0; i < o.headers.length; i++){
    matrix[0][i] = "<select name='headers[]' id='headers-" + i + "'>" + o.options + "</select>";
    setTimeout(function(){$("#headers-" + i).val(o.headers[i])},500);
  }

  for(var i = 0; i < o.rows.length; i++) {
    row = [];
    for (var j = 0; j < o.rows[i].length; j++) {
      var col = o.rows[i][j];
        var maxlen = 50;
      var formatted_row = col.length > maxlen ? col.substr(0, maxlen) + '...' : col;
      row.push(formatted_row);
    }
    matrix.push(row);
  }
  return matrix;
}

function buildImportHtml(o){
  var matrix = matrixTranspose(buildMatrix(o));
  var html = "<table>";
  for(var i = 0; i < matrix.length; i++){
    html += "<tr>";
    for(var j = 0; j < matrix[i].length; j++){
      html += "<td>" + matrix[i][j] + "</td>";
    }
    html += "</tr>";
  }
  html += '</table>';
  return html;
}

function buildOptions(type) {
  var options = '';

  if(type == MEASURES) {
    options += '<option value="nil">Do Not Import</option>';
    options += '<option value="ID">ID</options>';
    options += '<option value="State">State</options>';
    options += '<option value="Title">Title</options>';
    options += '<option value="Subtitle">Subtitle</options>';
    options += '<option value="Brief">Brief</options>';
    options += '<option value="Text">Text</options>';
    options += '<option value="Response 1">Response 1</options>';
    options += '<option value="Response 1 Blurb">Response 1 Blurb</options>';
    options += '<option value="Response 2">Response 2</options>';
    options += '<option value="Response 2 Blurb">Response 2 Blurb</option>';
  }

  if(type == CANDIDATES) {
    options += '<option value="nil">Do Not Import</option>';
    options += '<option value="UID">UID</option>';
    options += '<option value="State">State</option>';
    options += '<option value="Office Level">Office Level</option>';
    options += '<option value="Electoral District">Electoral District</option>';
    options += '<option value="Office Name">Office Name</option>';
    options += '<option value="Candidate Name">Candidate Name</option>';
    options += '<option value="Candidate Party">Candidate Party</option>';
    options += '<option value="Completed?">Completed?</option>';
    options += '<option value="Incumbent">Incumbent</option>';
    options += '<option value="Phone">Phone</option>';
    options += '<option value="Mailing Address">Mailing Address</option>';
    options += '<option value="Website">Website</option>';
    options += '<option value="Email">Email</option>';
    options += '<option value="Facebook URL">Facebook URL</option>';
    options += '<option value="Twitter Name">Twitter Name</option>';
    options += '<option value="Google Plus URL">Google Plus URL</option>';
    options += '<option value="Wiki Word">Wiki Word</option>';
    options += '<option value="Youtube">Youtube</option>';
    options += '<option value="Source">Source</option>';
  }

  return options;
}
