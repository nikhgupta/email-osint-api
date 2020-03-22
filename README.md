# email-osint
Grape API for OSINT email - basic data, smtp validation and gravatars information

API Key can be set via environment variable `API_KEY`. You can request data for an email in the following format:

```bash
GET /api/v1/fetch/{base64-encoded-email}?api_key={api-key}
```

**[EXAMPLE API CALL](https://email-osint-demo.herokuapp.com/api/v1/fetch/RVhBTXBsZS5lTWFpbCttaXNTcGVsbEBnTWFpbC5jYW0?api_key=test)**

```ruby
email = 'EXAMple.eMail+misSpell@gMail.cam'
encoded = Base64.encode64(email).strip.gsub(/=+\z/, '')
# => "RVhBTXBsZS5lTWFpbCttaXNTcGVsbEBnTWFpbC5jYW0"
url = "https://email-osint-demo.herokuapp.com/api/v1/fetch/#{encoded}?api_key=test"
# => "https://email-osint-demo.herokuapp.com/api/v1/fetch/RVhBTXBsZS5lTWFpbCttaXNTcGVsbEBnTWFpbC5jYW0?api_key=test"
data = JSON.parse(Faraday.get(url).body)
puts JSON.pretty_generate(data)
```

Response is:
```json
{
  "provided": "EXAMple.eMail+misSpell@gMail.cam",
  "corrected": "example.email+misspell@gmail.com",
  "tag": "misspell",
  "normal": "example.email+misspell@gmail.com",
  "canonical": "exampleemail@gmail.com",
  "mailbox": "exampleemail",
  "provider": "google",
  "host_name": "gmail.com",
  "temporary": false,
  "success": false,
  "domain": "gmail.com",
  "mail_servers": [
    "209.85.232.26",
    "64.233.186.26",
    "209.85.202.27",
    "66.102.1.26",
    "172.217.218.27"
  ],
  "errors": {
    "smtp": "550-5.1.1 The email account that you tried to reach does not exist. Please try"
  },
  "smtp_debug": {
    "port_opened": true,
    "connection": true,
    "helo": "250 mx.google.com at your service",
    "mailfrom": "250 2.1.0 OK a14si6466836qtc.229 - gsmtp",
    "rcptto": false,
    "errors": {
      "rcptto": "550-5.1.1 The email account that you tried to reach does not exist. Please try\n"
    }
  },
  "gravatars": {
    "exampleemail@gmail.com": {
      "id": "67250465",
      "md5": "885b30e37fa77a30593ed35f5e314355",
      "primary_md5": "885b30e37fa77a30593ed35f5e314355",
      "urls": [

      ],
      "username": "usernameyaya",
      "preferred_username": "usernameyaya",
      "display_name": "usernameyaya"
    },
    "example.email@gmail.com": {
      "id": "103613831",
      "md5": "aa1d72a7b8c144aa7c8a017288c94141",
      "primary_md5": "320ef8790d0ad5243e46194cb6d9b17d",
      "urls": [

      ],
      "username": "mybrainruth",
      "preferred_username": "mybrainruth",
      "display_name": "mybrainruth"
    }
  }
}
```

**NOTE: Unless RACK_ENV is `production` - any errors generated via the API are dumped with backtraces.**
