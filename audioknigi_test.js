const request = require('request');
const CryptoJS = require("crypto-js");

function getBid(body) {
    const regex = /data-global-id\s?=\s?\"(\d{4,8})\"/;

    const match = body.match(regex);

    if (match && match.length > 1) {
        return match[1];
    }

    return null;
}

function getSecurityLSKey(body) {
    const regex = /,LIVESTREET_SECURITY_KEY\s?=\s?'(.*)',LANGUAGE/;

    const match = body.match(regex);

    if (match && match.length > 1) {
        return match[1];
    }

    return null;
}

function buildHash(security_ls_key) {
    const secretPassphrase = "EKxtcg46V";

    const encrypted = CryptoJS.AES.encrypt("\"" + security_ls_key + "\"", secretPassphrase);

    const ct = encrypted.ciphertext.toString(CryptoJS.enc.Base64);
    const iv = encrypted.iv.toString();
    const s = encrypted.salt.toString();

    const values = {
        ct: ct,
        iv: iv,
        s: s
    };

    return encodeURIComponent(JSON.stringify(values));
}

function makeRequest(bid, security_ls_key, hash, cookie) {
    let data = `bid=${bid}&hash=${hash}&security_ls_key=${security_ls_key}`;

    console.log("data:", data)

    const headers = {
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36',
        'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'cookie': cookie
    };

    request({
        url: "https://audioknigi.club/ajax/bid/" + bid,
        method: "POST",
        headers: headers,
        body: data
    }, function (error, response, body) {
        if (response.body !== ' Hacking attemp!') {
            const items = JSON.parse(response.body)['aItems'];

            console.log("Items:", items);
        }
    });
}

const headers = {
    'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36',
};

request({
    url: "https://audioknigi.club",
    method: "GET",
    headers: headers
}, function (error, response, body) {
    const cookie = response.headers['set-cookie'][0];

    console.log("cookie:", cookie);

    let security_ls_key = getSecurityLSKey(body);

    console.log("security_ls_key:", security_ls_key);

    request({
        url: "https://audioknigi.club/king-stiven-pyanye-feyerverki",
        method: "GET"
    }, function (error, response, body) {
        //console.log(body);

        const bid = getBid(body);

        console.log("bid:", bid);

        const hash = buildHash(security_ls_key);

        console.log("hash:", hash);

        makeRequest(bid, security_ls_key, hash, cookie);
    });
});

