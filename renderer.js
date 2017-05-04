// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.

var rssReaderModule = require('./app/myRssReader.js');
var transformationsModule = require('./app/startTransformation.js')

var rssreader = new rssReaderModule();
var trans = new transformationsModule();
var fs = require('fs');

console.log("Los gehts...");

$('#loader').hide();

var dir = './output';
if (!fs.existsSync(dir)){
    fs.mkdirSync(dir);
}

$('#ressort_row, #select_row, #calendar_row').hide();

/******************************** Initialisierung der Input Felder: *****************************************/

$('#start-button').on('click', function(event) {
    event.preventDefault();

    // validateIfJavaAndSaxonIsInstalled()

    $('#start-button').addClass('disabled');
    $( "#loader" ).toggle();


    let inputsOk = validateInputs();
    if (inputsOk !== "Alle Input Felder ok") {
        alert(inputsOk);
        return false;
    }
    console.log("Ergebnis der Input Validation: " + inputsOk);

    // leseFeed()
    let ressortNumber;
    if (welcherNachrichtenTyp === 'interviews') {
        ressortNumber = 28;
    } else {
        switch (welchesRessort) {
            case 'Steuerrecht':
                ressortNumber = 12;
                break;
            case 'Wirtschaftsrecht':
                ressortNumber = 14;
                break;
            case 'Arbeitsrecht':
                ressortNumber = 13;
                break;
            case 'Betriebswirtschaft':
                ressortNumber = 15;
                break;
            default:
                ressortNumber = 11;
        }
    }

    let transformationArgs = { // muss direkt nach dem readInputs gefüllt werden
        welcherNachrichtenTyp: welcherNachrichtenTyp,
        dieLetztenWieviele: dieLetztenWieviele,
        welchesRessort: welchesRessort,
        zeitraumOderDieLetztenX: zeitraumOderDieLetztenX,
        startDate: startDate,
        endDate: endDate,
        dieLetztenWieviele: dieLetztenWieviele
    }

    
    rssreader.leseFeed("https://www.der-betrieb.de/feed/?cat=" + ressortNumber).then(function() {
        console.log("Datei erstellt... Promise Rückgabe");

        // konvertiereFeedDatei()
        trans.executeTransformation(transformationArgs).then(function() {
            console.log("Transformation wurde ausgeführt.");

            $('#start-button').removeClass('disabled');
            $( "#loader" ).toggle();
        });
    });

    // gibRückmeldung()

    // danach lade Seite neu

});

// $('#test-button').on('click', function(event) {
//     event.preventDefault();
//     //rssreader.test();
//     //alert("test");

//     readAllInputs();

//     let transformationArgs = { // muss direkt nach dem readInputs gefüllt werden
//         welcherNachrichtenTyp: welcherNachrichtenTyp,
//         dieLetztenWieviele: dieLetztenWieviele,
//         welchesRessort: welchesRessort,
//         zeitraumOderDieLetztenX: zeitraumOderDieLetztenX,
//         startDate: startDate,
//         endDate: endDate,
//         dieLetztenWieviele: dieLetztenWieviele
//     }

//     trans.executeTransformation(transformationArgs).then(function() {
//         console.log("Transformation wurde ausgeführt.");
//     });
// });

$('.datepicker-start, .datepicker-end').pickadate({
    selectMonths: true, // Creates a dropdown to control month
    selectYears: 2, // Creates a dropdown of 15 years to control year
    max: true, // spätestes Datum heute
    format: 'dd.mm.yyyy',
    today: 'Heute',
    clear: '',
    close: 'Datum übernehmen',
    closeOnSelect: true
});
$('select').material_select();

/******************************** End: Initialisierung der Input Felder: *****************************************/

// Input Variablen:
var welcherNachrichtenTyp, welchesRessort, zeitraumOderDieLetztenX, startDate, endDate, dieLetztenWieviele;

// alle Inputfelder lesen:
var readAllInputs = function() {
    welcherNachrichtenTyp = $('input[name=group1]:checked').attr('id');
    welchesRessort = $('select[id=ressortAuswahl] option:selected').text();
    zeitraumOderDieLetztenX = $('input[name=group2]:checked').attr('id');
    startDate = $('#start_interval_date').val();
    endDate = $('#end_interval_date').val();
    dieLetztenWieviele = $('select[id=dieLetztenWieviele] option:selected').text();
    console.log(welcherNachrichtenTyp, welchesRessort, zeitraumOderDieLetztenX, startDate, endDate, dieLetztenWieviele);
}

var validateInputs = function() {
    readAllInputs();
    if ($('input[name=group1]:checked').length === 0) {
        return 'Bitte noch einen Meldungstyp auswählen';
    }

    if ($('input[name=group1]:checked').attr('id') == 'meldungen' && $('select[id=ressortAuswahl] option:selected').text() === 'Welches Ressort?') {
        return 'Bitte noch ein Ressort auswählen';
    }

    if ($('input[name=group2]:checked').length === 0) {
        return 'Zeitraum auswählen';
    }

    if ($('input[name=group2]:checked').attr('id') == 'itemAusInterval') {
        if (startDate == '' || endDate == '') {
            return 'Bitte noch Start und Enddatum auswählen';
        }
        let temp_start = new Array(startDate.split(".")[2], startDate.split(".")[1], startDate.split(".")[0]).join("");
        let temp_end = new Array(endDate.split(".")[2], endDate.split(".")[1], endDate.split(".")[0]).join("");

        if (temp_start > temp_end) {
            return 'Bitte korrektes Enddatum wählen';
        }

    }

    //Datumsintervall überprüfen

    if ($('input[name=group2]:checked').attr('id') == 'dieLetztenXItems' && dieLetztenWieviele == "Die letzten..") {
        return 'Bitte noch auswählen wieviele ' + capitalizeFirstLetter(welcherNachrichtenTyp) + "Sie verarbeiten wollen";
    }

    return "Alle Input Felder ok";
}

function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}


/******************************** Form Events: *****************************************/
$('input[name=group1]').change(function() {
    if ($('input[name=group1]:checked').attr('id') == 'meldungen') {
        //Animation?
        $('#ressort_row').show();
    } else { // Interviews:
        //Animation?
        $('#ressort_row').hide();
    }
});

$('input[name=group2]').change(function() {
    if ($('input[name=group2]:checked').attr('id') == 'itemAusInterval') {
        //Animation?
        $('#select_row').hide();
        $('#calendar_row').show();
    } else { // Interviews:
        //Animation?
        $('#calendar_row').hide();
        $('#select_row').show();
    }

    //console.log($('input[name=group2]:checked').attr('id'));
});

/******************************** End: Form Events: *****************************************/