# email-osint
Grape API for OSINT email - basic data, smtp validation and gravatars information

Request email data for an email in the following format:

```bash
GET /api/v1/fetch/<base64-encoded-email>
```

For example:

```ruby
email = 'example.email+misspelled@gmail.cam'
encoded = Base64.encode64(email).strip
# => "ZXhhbXBsZS5lbWFpbCttaXNzcGVsbGVkQGdtYWlsLmNhbQ=="
res = Faraday.get("http://localhost:9292/api/v1/fetch/#{encoded}")
data = JSON.parse(res.body)
puts JSON.pretty_generate(data)
```

Response is:
```json
{
   "provided":"example.email+misspelled@gmail.cam",
   "corrected":"example.email+misspelled@gmail.com",
   "tag":"misspelled",
   "normal":"example.email+misspelled@gmail.com",
   "canonical":"exampleemail@gmail.com",
   "mailbox":"exampleemail",
   "provider":"google",
   "host_name":"gmail.com",
   "temporary":false,
   "success":false,
   "domain":"gmail.com",
   "mail_servers":[
      "74.125.24.26",
      "74.125.28.26",
      "108.177.9.26",
      "74.125.129.27",
      "172.253.112.26"
   ],
   "errors":{
      "smtp":"550-5.1.1 The email account that you tried to reach does not exist. Please try"
   },
   "smtp_debug":{
      "port_opened":true,
      "connection":true,
      "helo":"250 mx.google.com at your service",
      "mailfrom":"250 2.1.0 OK y3si7714883plk.254 - gsmtp",
      "rcptto":false,
      "errors":{
         "rcptto":"550-5.1.1 The email account that you tried to reach does not exist. Please try
"
      }
   },
   "gravatars":{
      "exampleemail@gmail.com":{
         "id":"67250465",
         "md5":"885b30e37fa77a30593ed35f5e314355",
         "primary_md5":"885b30e37fa77a30593ed35f5e314355",
         "urls":[

         ],
         "username":"usernameyaya",
         "preferred_username":"usernameyaya",
         "display_name":"usernameyaya"
      },
      "example.email@gmail.com":{
         "id":"103613831",
         "md5":"aa1d72a7b8c144aa7c8a017288c94141",
         "primary_md5":"320ef8790d0ad5243e46194cb6d9b17d",
         "urls":[

         ],
         "username":"mybrainruth",
         "preferred_username":"mybrainruth",
         "display_name":"mybrainruth"
      }
   }
}
```
