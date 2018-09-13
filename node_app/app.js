const express = require('express')
const app = express()
const version=0;
var count = 0;

app.get('/', (req, res) => res.send('Hello'))

app.get('/version', function(req, res) {
  count = count + 1;
  res.send({'New Version':count});
})

app.listen(3000, () => console.log('Example app listening on port 3000......'))
