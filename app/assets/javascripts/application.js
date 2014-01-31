// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
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
    previewImportFile(e, CANDIDATES);
    submitFlag = true;
    return false;
  });
  $('#import-measures').submit(function(e){
    if(submitFlag){
      //submit the form as normal
      return true;
    }
    previewImportFile(e, MEASURES);
    submitFlag = true;
    return false;
  });
}

function previewImportFile(e, type, submitFlag){
  var self = this;
  var fHandle = e.currentTarget[0].files[0]
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
    options += '<option value="id">ID</options>';
    options += '<option value="state">State</options>';
    options += '<option value="title">Title</options>';
    options += '<option value="subtitle">Subtitle</options>';
    options += '<option value="brief">Brief</options>';
    options += '<option value="text">Text</options>';
    options += '<option value="response_1">Response 1</options>';
    options += '<option value="blurb">Response 1 Blurb</options>';
    options += '<option value="response_2">Response 2</options>';
    options += '<option value="response_2_blurb">Response 2 Blurb</option>';
  }

  if(type == CANDIDATES) {
    options += '<option value="uid">UID</option>';
    options += '<option value="state">State</option>';
    options += '<option value="office_level">Office Level</option>';
    options += '<option value="electoral_district">Electoral District</option>';
    options += '<option value="office_name">Office Name</option>';
    options += '<option value="candidate_name">Candidate Name</option>';
    options += '<option value="candidate_party">Candidate Party</option>';
    options += '<option value="completed">Completed?</option>';
    options += '<option value="incumbent">Incumbent</option>';
    options += '<option value="phone">Phone</option>';
    options += '<option value="mailing_address">Mailing Address</option>';
    options += '<option value="website">Website</option>';
    options += '<option value="email">Email</option>';
    options += '<option value="facebook_url">Facebook URL</option>';
    options += '<option value="twitter_name">Twitter Name</option>';
    options += '<option value="google_plus_url">Google Plus URL</option>';
    options += '<option value="wiki_word">Wiki Word</option>';
    options += '<option value="youtube">Youtube</option>';
    options += '<option value="source">Source</option>';
  }

  return options;
}
