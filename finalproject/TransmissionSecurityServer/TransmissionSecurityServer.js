var express = require("express")
var querystring = require('querystring')
var app = express();
var WebSocketServer = require("ws").Server;
var https = require("https");
var http = require("http");
var bodyParser = require('body-parser');
var validator = require('validator'); // See documentation at https://github.com/chriso/validator.js
// See https://stackoverflow.com/questions/5710358/how-to-get-post-query-in-express-node-js
app.use(bodyParser.json());
// See https://stackoverflow.com/questions/25471856/express-throws-error-as-body-parser-deprecated-undefined-extended
app.use(bodyParser.urlencoded({ extended: true }));

app.get('/httpreq', function(request, response) {
    response.send({"status": "success"});
});

app.get('/pushreq', function(request, response) {
    var body = JSON.stringify({
        "where": {
          "deviceType": "ios"
        },
        "data": {
          "alert": "Push notification"
    }});
    console.log(body)
    var options = {
        hostname: "api.parse.com",
        port: 443,
        path: "/1/push",
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Content-Length": body.length,
            "X-Parse-Application-Id": process.env.APP_ID,
            "X-Parse-REST-API-Key": process.env.API_KEY
    }};
    
    var req = https.request(options, function(res){
        console.log(res.statusCode);
        res.on('data', function (chunk) {
            console.log(chunk);
        });
        response.status = res.statusCode;
        response.send({"status": res.statusCode});
    });
    req.on('error', function(e) {
        console.log('problem with request: ' + e.message);
        response.send(500);
    });
    req.write(body);
    req.end();
});

var httpServer = http.createServer(app).listen(process.env.PORT || 5000);
var wss = new WebSocketServer({server: httpServer});
wss.on('connection', function connection(connection) {
    connection.on('message', function incoming(message) {
        if (message) {
            connection.send("Received");
        }
    });
});
