request = require('request')
cheerio = require('cheerio')
Wiki = (url)-> 
    @url = url;

Wiki.prototype.hello = () ->
    return 'hello ' + @url;

Wiki.prototype.forge = (title, msg, callback) ->
    request.get @url + 'index.php?' + 'cmd=edit&page=' + encodeURIComponent(title)
        ,(err, res, body) =>
            $ = cheerio.load(body)
            parseDigest = $('*[name=digest]')
            digest = parseDigest[0]['attribs']['value']
            parseTicket = $('*[name=ticket]')
            ticket = parseTicket[0]['attribs']['value']
            Wiki.prototype.update.call @, title, msg, digest, ticket
                , (err, res, body, pageUrl) ->
                    callback err, res, body, pageUrl

Wiki.prototype.template = (title, callback) ->
    request.get @url + 'index.php?' + 'cmd=edit&page=' + encodeURIComponent(title)
        ,(err, res, body) =>
            $ = cheerio.load(body)
            parseTitle = $('*[name=page]')
            title = parseTitle[0]['attribs']['value']
            parseDigest = $('*[name=digest]')
            digest = parseDigest[0]['attribs']['value']
            parseTicket = $('*[name=ticket]')
            ticket = parseTicket[0]['attribs']['value']
            parseMsg = $('*[name=msg]')
            msg = parseMsg.val()
            Wiki.prototype.update.call @, title, msg, digest, ticket
                , (err, res, body, pageUrl) ->
                    callback err, res, body, pageUrl

Wiki.prototype.getTemplateValue = (pageTitle, callBack) ->
    request.get @url + 'index.php?cmd=edit&page=' + encodeURIComponent("#{pageTitle}/template")
      , (err, res, body) =>
        $ = cheerio.load(body)
        value = $('#msg').val()
        callBack err, res, value

Wiki.prototype.update = (title, msg, digest, ticket, callback) ->
    options =
        uri: @url + 'index.php',
        form:
            encode_hint: 'ぷ',
            cmd: 'edit',
            page: title,
            digest: digest,
            ticket: ticket,
            id: '',
            msg: msg,
            write: 'ページの更新',
            original: ''
    
    request.post options
        , (err, res, body) =>
            pageUrl = Wiki.prototype.pageUrl.call @, 'read', title
            callback err, res, body, pageUrl

Wiki.prototype.pageUrl = (cmd, title) ->
    if not cmd
        cmd = 'read'
    pageUrl = @url + 'index.php?'
    pageUrl += 'cmd=' + cmd
    pageUrl += '&page=' + encodeURIComponent(title)

if exports 
    exports.Wiki = Wiki;
