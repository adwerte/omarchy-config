# adwerte-config

Configuration files for Adwerte's Windows and Linux setups.
You will need to install alacritty manually.

This repository uses [Just](https://just.systems/) to provide cross-platform commands.
Install Just using cargo:

```sh
cargo install just
```

Once installed, run just --list from the repository directory to see the available commands.


### Linux
On linux you need to add cargo location to path to use executables
```sh
export PATH=$PATH:/home/adwerte/.cargo/bin
```

## Creating a Valid Certificate
### Setting up a Certificate Authority
First we must generate our private key:
```sh
openssl genrsa -des3 -out myCA.key 2048
```
Then we generate a root certificate using this key.
This is the certificate of our certificate authority (CA).
Now we generate a certificate for our CA.
```sh
openssl req -x509 -new -nodes -key myCA.key -sha256 -days 1825 -out myCA.pem
```
This is valid for 1825 days,
and creates myCA.pem which is needed in order to trust our CA.
This will ask a number of questions.
The answer to these is only important for the purpose of documentation.

### Generating a Certificate for a Site
We'll now generate a certificate for our site.
First we generate a private key for the site:
```sh
openssl genrsa -out local.key 2048
```
Then we make a certificate request file:
```sh 
openssl req -new -key local.key -out local.csr
```
Again we get a wave of questions, this is only important for the
purpose of documentation.

Finally we use the following command to generate a signed certificate.
```sh
openssl x509 -req -in local.csr -CA myCA.pem -CAkey myCA.key \
-CAcreateserial -out local.crt -days 825 -sha256 -extfile server_file.ext
```
It is valid for 825 days, or about 2 years.
Now we use the `local.key` and the `local.crt` in caddy
to attach a valid certificate to our site. 

Based on this guide: [SSL Certificate Guide](https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development) 

This has been implemented as just commands.
