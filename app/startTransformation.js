var exec = require('child_process').exec;

var Transformation = function() {

    var convertArgs = function(obj) {
        let r = ' ';
        for (var property in obj) {
            if (obj.hasOwnProperty(property) && (obj[property] !== undefined) && (obj[property] !== '')) {
                console.log("property: " + property + " wert: " + obj[property]);
                r += property + '=' + obj[property].toString() + ' ';
            }
        }
        console.log("Res: " + r);
        return r;
    }

    this.executeTransformation = function(paramterObject) {

        let cmd = '';
        let xslFile = (paramterObject.welcherNachrichtenTyp === 'meldungen') ? 'transform_meldung_to_indesign.xsl' : 'transform_interview_to_indesign.xsl';

        //paramterObject = (paramterObject != undefined) ? paramterObject : 'testparam=hallo';
        //let paramterString = convertArgs(paramterObject);

        cmd = 'java -jar ./saxon9he.jar -s:./output/rss.xml -xsl:./xslt/' + xslFile + convertArgs(paramterObject) + ' -o:./output/indesign.xml ';

        console.log("Transformation wird ausgeführt. Befehl: " + cmd);

        return new Promise(function(fulfill, reject) {

            let childproc = exec(cmd, function(error, stdout, stderr) {

                if (error) {
                    console.dir(error);
                    reject(error);
                }
                if (stdout)
                    console.log("Output: " + stdout);
            });

            childproc.on('close', function(e) {
                //console.log("Transformation wurde ausgeführt.");
                fulfill();
            })

        });

    }
}

module.exports = Transformation;