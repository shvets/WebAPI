import * as request from 'request';
import * as CryptoJS from "crypto-js";

class AudioKnigi {
    private getBid(body: any) {
        const regex = /data-global-id\s?=\s?\"(\d{4,8})\"/;

        const match = body.match(regex);

        if (match && match.length > 1) {
            return match[1];
        }

        return null;
    }

    private getSecurityLSKey(body: any) {
        const regex = /,LIVESTREET_SECURITY_KEY\s?=\s?'(.*)',LANGUAGE/;

        const match = body.match(regex);

        if (match && match.length > 1) {
            return match[1];
        }

        return null;
    }

    private buildHash(security_ls_key: string) {
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

    private makeRequest(bid: string, security_ls_key: string, hash: any, cookie: string) {
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
        }, (error, response, body) => {
            if (response.body !== ' Hacking attemp!') {
                const items = JSON.parse(response.body)['aItems'];

                console.log("Items:", items);
            }
        });
    }

    public run() {
        const headers = {
            'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36',
        };

        request({
            url: "https://audioknigi.club",
            method: "GET",
            headers: headers
        }, (error, response, body) => {
            const cookie = response.headers['set-cookie'][0];

            console.log("cookie:", cookie);

            let security_ls_key = this.getSecurityLSKey(body);

            console.log("security_ls_key:", security_ls_key);

            request({
                url: "https://audioknigi.club/king-stiven-pyanye-feyerverki",
                method: "GET"
            }, (error, response, body) => {
                //console.log(body);

                const bid = this.getBid(body);

                console.log("bid:", bid);

                const hash = this.buildHash(security_ls_key);

                console.log("hash:", hash);

                this.makeRequest(bid, security_ls_key, hash, cookie);
            });
        });
    }
}

const runner = new AudioKnigi();

runner.run();
