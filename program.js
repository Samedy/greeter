var fs=require('fs');
var buf=fs.readFileSync('./test.txt');
var arr=buf.toString().split("\n");
console.log(arr.length);